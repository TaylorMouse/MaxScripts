ClearListener()
fileIn "GriffonStudios_HelperScripts.ms"

struct LeagueOfLegends
(
    
    function ReadSKN file=
    (
        struct LOL_MESH ( name, startVertex, numVertices, startIndex, numIndices, mesh_ref )
        struct LOL_SKN ( fileVersion, materialVersion, numObjects, vertices, indices, boneIds, vertexWeights, normals, uvws, meshes )
        
        local stream = fOpen file "rb"
        local magic = readLong stream
        
        if magic != 1122867 then throw "File type is not supported!"
        
        local skn = LOL_SKN()
        
        skn.fileVersion = readShort stream
        skn.materialVersion = readShort stream
        skn.numObjects = readLong stream
        
        skn.meshes = #()
        for i=1 to skn.numObjects do
        (
            local msh = LOL_MESH()
            msh.name = ReadFixedString stream 64
            msh.startVertex = readLong stream
            msh.numVertices = readLong stream
            msh.startIndex = readLong stream
            msh.numIndices = readLong stream
            append skn.meshes msh
        )
        
        if (skn.fileVersion == 4 ) then SkipBytes stream 4
        
        local numIndices = readLong stream
        local numVertices = readLong stream
        
        if (skn.fileVersion == 4 ) then SkipBytes stream 48 -- 2 int's followed by 10 floats ?
        
        skn.vertices = #()
        skn.indices = #()
        skn.boneIds = #()
        skn.vertexWeights = #()
        skn.normals = #()
        skn.uvws = #()
        
        for i=1 to numIndices do
        (
            append skn.indices (readShort stream )
        )

        for i=1 to numVertices do
        (
            append skn.vertices ( [readFloat stream, readFloat stream, readFloat stream])
            append skn.boneIds ( [readByte stream #unsigned+1, readByte stream #unsigned +1, readByte stream #unsigned +1, readByte stream #unsigned +1] )
            append skn.vertexWeights ( [readFloat stream, readFloat stream, readFloat stream, readFloat stream] )
            append skn.normals ( [readFloat stream, readFloat stream, readFloat stream])
            append skn.uvws ( [readFloat stream, (1.0 - readFloat stream), 0.0 ] )
        )
        
        /* bone index - weight correction: floats are just a floating point, so this could be an issue */
        for i=1 to numVertices do
        (
            local vw = skn.vertexWeights[i]
            local bId = skn.boneIds[i]
            
            for b=1 to 4 do
            (
                if ( bId[b] == 0 ) then vw[b] = 0
            )
            
            local totalWeight = vw[1] + vw[2] + vw[3] + vw[4]
            local weightError = 1.0 - totalWeight
            
            if (weightError != 0.0 ) then
                skn.vertexWeights[i][1] = vw[1] + weightError
        )
        
    
        fclose stream
        
        return skn
    ),
    
    function ReadSKL file=
    (
        struct LOL_SKL ( fileVersion, numBones, numBoneIndices, dataOffset, boneIndicesOffset, boneNameOffset, boneNames, bone_list )
        struct LOL_BONE ( id, parentBoneId, name, position, scale, rotation, hash, localMatrix, globalMatrix, bone_ref )
        
        local sklFileName = ( substring file 1 ( file.count - 3 ) ) + "skl"
        if ( doesFileExist sklFileName != true ) then exit
        
        local stream = fOpen sklFileName "rb"
        local magic = readLong stream
        
        local skl = LOL_SKL()
        
        skl.fileVersion = readLong stream
        
        if (skl.fileVersion != 587026371 ) then exit
        
        SkipBytes stream 6 --> very weird but ok :/
        
        skl.numBones = readShort stream
        skl.numBoneIndices = readLong stream
        skl.dataOffset = readLong stream
        SkipBytes stream 4 --> ??
        
        skl.boneIndicesOffset = readLong stream
        SkipBytes stream 8
        
        skl.boneNameOffset = readLong stream


        /* bone names */
        local size = GetFileSize sklFileName
        fseek stream skl.boneNameOffset #seek_set
        
        local names  = ""
        local prev = ""
        
        for i=1 to (size - skl.boneNameOffset ) do
        (
            local s= bit.IntAsChar(ReadByte stream)
            if ( s == "" ) then
            (
                if ( prev == "" ) then 
                (
                    s= ","
                    prev = "|"
                )
                else
                    s = ""
            )
            else
                prev = ""
            
            names += s
            
        )
        skl.boneNames = filterstring names ","
        
        /* bone data */
        fseek stream skl.dataOffset #seek_set
        
        skl.bone_list = #()
        for i=1 to skl.numBones do
        (
            local b = LOL_BONE()
            
            SkipBytes stream 2
            
            b.id = readShort stream

            b.name = skl.boneNames[b.id + 1]
            
            b.parentBoneId = readShort stream
            
            SkipBytes stream 2
            
            b.hash = readBytes stream 4

            SkipBytes stream 4
            
            b.position = [readFloat stream, readFloat stream, readFloat stream]
            b.scale = [readFloat stream, readFloat stream, readFloat stream]
            b.rotation = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream)
            
            skipbytes stream 44
            
            append skl.bone_list b
            
        )

        
        return skl
        
    ),
    
    function BuildSkeleton skl=
    (
        local boneLayer = CreateLayer "Bones"
        
        for b in skl.bone_list do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
			aBone.Width = 0.05
			aBone.Height = 0.05
            b.bone_Ref = aBone
        
            boneLayer.addNode aBone
        )
        
        for b in skl.bone_list do
        (
            if( b.parentBoneId != -1) then
                b.bone_ref.parent = skl.bone_list[b.parentBoneId + 1].bone_ref
            
        )
        
        for b in skl.bone_list do
        (
            in coordsys parent b.bone_ref.rotation = b.rotation
            in coordsys parent b.bone_ref.position = b.position
            in coordsys parent b.bone_ref.scale = b.scale
        )    
        
    ),
    function BuildMeshes skn=
    (
        
        local meshLayer = CreateLayer "Meshes"
        
        for x = 1 to skn.meshes.count do
        (
            local m = skn.meshes[x]

            local verts = #()
            for v= m.startVertex+1 to m.startVertex + m.numVertices do
            (
                append verts skn.vertices[v]
            )

            local faces = #()
            for i= m.startIndex+1 to m.startIndex + m.numIndices by 3 do
            (
                local a = ( skn.indices[i] + 1 - m.startVertex )
                local b = ( skn.indices[i+1] + 1 - m.startVertex  )
                local c = ( skn.indices[i+2] + 1 - m.startVertex)
                
                append faces [a, b, c]
            )

            local normals = #()
            for v= m.startVertex+1 to m.startVertex + m.numVertices do
            (
                append normals skn.normals[v]
            )
            
            local uvws = #()
            for v= m.startVertex+1 to m.startVertex + m.numVertices do
            (
                append uvws skn.uvws[v]
            )
            
            local theMesh = mesh name:m.name vertices:verts faces:faces vnorms:normals tverts:uvws
            buildTVFaces theMesh false
            for i = 1 to faces.count do
            ( setTVFace theMesh i faces[i] )
            
            meshLayer.addNode theMesh
            skn.meshes[x].mesh_ref = theMesh
        )
    ),
    
    function ApplySkin skn skl=
    (

        for m in skn.meshes do
        (
            local obj = m.mesh_ref
            local boneList = skl.bone_list
            
            local boneIdList = #()
            local weightList = #()
            
           
            local mshSkin = skin name:"Skin"

            max modify mode
            addmodifier obj mshSkin

            modPanel.setCurrentObject mshSkin

            for i=1 to boneList.count do
            (
                local b = boneList[i].bone_ref
                skinOps.addBone mshSkin b 0
            )
 
            update obj
            max views redraw
            
--             for x=1 to obj.verts.count do
--             (
--                 local w = #(skn.vertexWeights[x][1], skn.vertexWeights[x][2], skn.vertexWeights[x][3], skn.vertexWeights[x][4])

--                 local bl = #()

--                 for y=1 to 4 do
--                 (
--                                   
--                     local listId =skinOps.GetListIDByBoneID mshSkin (skn.boneIds[x + m.startVertex][y])
--                     append bl (skinOps.GetBoneIDByListID mshSkin listId)
--                     
--                 )
--                 
--                 skinOps.ReplaceVertexWeights mshSkin x bl w
--                 
--             )
            update obj
        )
    ),
    function Import file=
    (
        local skn = LeagueOfLegends.ReadSKN file
        local skl = LeagueOfLegends.ReadSKL file
        
        BuildSkeleton skl
        BuildMeshes skn
        ApplySkin skn skl
        
    )
)

lol = LeagueOfLegends()

lol.Import @"G:\Game Dev\3D Models\Game Models\League of Legends\Extracted\assets\characters\ryze\skins\base\ryze.skn"
