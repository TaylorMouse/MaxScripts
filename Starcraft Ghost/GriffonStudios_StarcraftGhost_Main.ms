/* 
    (c) 2020 Griffon Studios
    
    by Taylor Mouse
    
    Imports Starcraft Ghost (xbox game) models
    
    Based on the initial script found here: https://github.com/RenolY2/scg-modeldump

    Imports .nod, .noc

*/
global ghostModel
struct GriffonStudios_Helpers
(
    function BuildSpline spline points=
    (
        if spline == undefined then spline = SplineShape pos:[0,0,0]
        spline.WireColor = gray
        spline.renderable = off
        
        local index = addNewSpline spline
        
        for p in points do addKnot spline index #corner #curve p
        
        close spline index

        updateShape spline
        
        return spline
    ),
    function BuildBoundingBox bbBox=
    (
        local p1 = bbBox[1]
        local p2 = bbBox[2]

        local xMin = 0
        local xMax = 0
        local yMin = 0
        local yMax = 0
        local zMin = 0
        local zMax = 0
        
        if p1.x < p2.x then 
            ( 
                xMin = p1.x
                xMax = p2.X
            )
        else
            ( 
                xMin = p2.x
                xMax = p1.x
            )
        if p1.y < p2.y then 
            ( 
                yMin = p1.y
                yMax = p2.y
            )
        else
            ( 
                yMin = p2.y
                yMax = p1.y
            )
        if p1.z < p2.z then 
            ( 
                zMin = p1.z
                zMax = p2.z
            )
        else
            ( 
                zMin = p2.z
                zMax = p1.z
            )
        
        local help = GriffonStudios_Helpers()
        local s = help.BuildSpline s #([xMin, yMin, zMin], [xMax, yMin, zMin], [xMax,yMin, zMax], [xMin,yMin, zMax], [xMin, yMin, zMin] )
        s = help.BuildSpline s #([xMin, yMax, zMin], [xMax, yMax, zMin], [xMax,yMax, zMax], [xMin,yMax, zMax], [xMin, yMax, zMin] )
        s = help.BuildSpline s #([xMin, yMax, zMin], [xMin, yMin, zMin])
        s = help.BuildSpline s #([xMin, yMax, zMax], [xMin, yMin, zMax])    
        s = help.BuildSpline s #([xMax, yMax, zMin], [xMax, yMin, zMin])
        s = help.BuildSpline s #([xMax, yMax, zMax], [xMax, yMin, zMax])
        
        s.name = "Bounding Box"
        freeze s
        return s
    ),
    function CreateLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),
    function FindFiles root pattern=
    (
        dirList = GetDirectories (root+"/*")
        for d in dirList do
          join dirList (GetDirectories (d+"/*"))
        files = #()
        for f in dirList do
          join files (getFiles (f + pattern))
        return files
    ),
    function ReadBoundingBox stream=
    (
        local bbox = #()
        local pointA = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        local pointB = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        append bbox pointA
        append bbox pointB
        
        return bbox
    ),
    function ReadFixedString stream val =
    (
        /* Read n-length string */
        local str = ""

        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if ( s !="\0") then str+=s
        )
        return str

    ),
    function SkipBytes stream nBytesToSkip=
    (
        /* Skip n-bytes without reading them into memory */
        fseek stream nBytesToSkip #seek_cur
    ),
    function ReadVector3 stream correction=
    (
        return [readFloat stream, readFloat stream, readFloat stream] * correction
    ),
    function ReadUV3 stream=
    (
        return [readFloat stream, 1.0 - (readFloat stream), 0.0]
    )
)

struct Starcraft_Ghost_Tools
(
    function ReadGhostBone stream=
    (
        struct Ghost_bone ( id, parentId, tagId, translation, invTranslation, boneRef )
        -- 64 bytes
        
        local gb = Ghost_bone()
        gb.translation = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        SkipBytes stream 36
        
        gb.invTranslation = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        local unk1 = readByte stream as integer
        local unk2 = readByte stream as integer
        gb.parentId = ( readByte stream as integer ) + 1
        gb.tagId    = readByte stream as integer
        return gb
    ),
    function ReadMaterials file=
    (
        format "Parsing materials ( shaders and textures )\n"
        
        struct ghost_material ( shaders, textures )
        struct ghost_shader   ( name, shader, texture, sound, surfflags, envmap, meshtype, sightForce )
        
        local filePath = getFilenamePath file
        local rootPath = substring file 1 (findString filePath @"\3D\")
        
        local gmat = ghost_material ()
        
        gmat.textures = #()
        gmat.shaders = #()
        
        if ( doesdirectoryexist rootPath ) then
        (
            gmat.textures = GriffonStudios_Helpers.FindFiles rootPath "*.dds"
            format "- % textures (.dds) found\n" gmat.textures.count
            local shaderFiles = GriffonStudios_Helpers.FindFiles rootPath "*.nsa"

            
            for f in shaderFiles do
            (
                local str = openfile f
                
                while ( ( eof str ) == false ) do
                (
                    local l = readLine str
                    if ( eof str ) then exit
                    
                    local gs = ghost_shader()
                    
                    gs.name = l
                    
                    l = readLine str
                    if ( eof str ) then exit
                    while ( l != "}" ) do
                    (
                        if ( eof str ) then exit
                        
                        l = trimleft (trimright l)

                        if ( findstring l "shader" != undefined )       then gs.shader     = trimleft(substitutestring l "shader" "")
                        if ( findstring l "sightForce" != undefined )   then gs.sightForce = l
                        if ( findstring l "texture" != undefined )      then gs.texture    = trimleft(substitutestring l "texture" "")
                        if ( findstring l "sound" != undefined )        then gs.sound      = trimleft(substitutestring l "sound" "")
                        if ( findstring l "surfflags" != undefined )    then gs.surfflags  = trimleft(substitutestring l "surfflags" "")
                        if ( findstring l "envmap" != undefined )       then gs.envmap     = trimleft(substitutestring l "envmap" "")
                        if ( findstring l "meshtype" != undefined )     then gs.meshtype   = trimleft(substitutestring l "meshtype" "")

                        l = readLine str
                        if ( eof str ) then exit
                    )
                    
                    append gmat.shaders gs
                )
                close str
            )
            format "- % shaders found\n" gmat.shaders.count
        )
        
        return gmat
    ),
    function FindMaterial nod materials=
    (
        local mats = #()
        for i=1 to nod.nShaders do
        (
            local shaderName = tolower nod.shaderNames[i]
            local textureName = "\\" + ( tolower nod.shaderNames[i] ) + ".dds"
            
            mats[i] = undefined
           
            for ghostShader in materials.shaders do
            (
                if ( ( tolower ghostShader.name ) == shaderName ) then
                (
                    --format "Shader found %\n" ghostShader.name
                    mats[i] = ghostShader
                    format "Shader '%'\n" shaderName 
                    shaderFound = true
                    exit
                )
            )
           
            if ( mats[i] == undefined ) then 
            (
                
                
                for texture in materials.textures do
                (
                    if ( ( findstring ( tolower texture ) textureName ) != undefined ) then
                    (
                        --format "Texture found '%'\n" texture
                        mats[i] = texture
                        format "Texture '%.dds' \n" shaderName
                        textureFound = true
                        exit
                    )
                )
           
            )
        )
        
        return mats
    ),
    function BuildGhostBones boneList=
    (
        local boneLayer = GriffonStudios_Helpers.CreateLayer "Bones"
        
        for b in boneList do
        (
            local bName = "bone_" + (b.id as string)
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
                
            aBone.Name = bName
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            
            b.boneRef = aBone
            
            boneLayer.AddNode aBone
        )
        
        for b in boneList do
        (
            if (b.parentID > 0) then
            (
                b.boneRef.Parent = boneList[b.parentID].boneRef
                
                b.boneRef.Pos = b.translation + boneList[b.parentID].boneRef.pos
            )
            else
                b.boneRef.Pos = b.translation

        )        
    ),
    function BuildMesh nod=
    (
        local maxIndex = 0
        for i=1 to nod.indices.count do
        (
            if maxIndex < nod.indices[i] then maxIndex = nod.indices[i]
            
        )    
        format "Max index (vertex) found : % \n" maxIndex
        
        for i=1 to nod.vertexGroups.count do
        (
            if ( nod.vertexGroups[i].vertices != undefined ) then 
                format "Vertexgroup % has % vertices \n" i nod.vertexGroups[i].vertices.count
        )
        
        for i=1 to nod.meshGroups.count do
        (
            local l=1
            format "Meshgroup %   nbrVerts: %    VertexGroup: %    VertexStart: %\n" i nod.meshGroups[i].lods[l].vertexCount nod.meshGroups[i].vertexGroupId nod.meshGroups[i].vertexStart
        )
        
        for mg in nod.meshGroups do
        (
            for l in mg.lods do
            (
                if (l.lod == 0 ) then print l
            )
            
        )
        
        local meshId = 0
        for mg in nod.meshGroups do
        (
            for l in mg.lods do
            (
                if (l.lod == 0 ) then 
                (
                    local nbrIndices = l.stripCount --+ l.listCount
                    if( nbrIndices == 0 ) then continue
                    
                    format "Nbr Indices to process: %\n" ( nbrIndices  )
                    
                    local faces = #()
                    local backfaceCullingIssue = 1
                    for i=1  to nbrIndices - 3 do
                    (
                        local s = l.stripStart + 1
                        local a = nod.indices[s + i]
                        local b = nod.indices[s + i+1]
                        local c = nod.indices[s + i+2]
                        backfaceCullingIssue = 1 - backfaceCullingIssue
                        if( a!=b and a!=c and b!=c ) then 
                        (
                            if ( backfaceCullingIssue == 1 ) then
                                append faces [a,b,c]
                            else
                                append faces [a,c,b] 
                        )
                    )
                    
                    backfaceCullingIssue = 1
                    for i=1  to l.listcount /3 + 6  do
                    (
                        local s = l.ListStart +1 
                        local a = nod.indices[s + i*3]
                        local b = nod.indices[s + i*3+1]
                        local c = nod.indices[s + i*3+2]
                        
                        backfaceCullingIssue = 1 - backfaceCullingIssue
                        if( a!=b and a!=c and b!=c ) then 
                        (
                            if ( backfaceCullingIssue == 1 ) then
                                append faces [a,b,c]
                            else
                                append faces [a,c,b]    
                        )
                    )
                    
                    local vg = nod.vertexGroups[mg.vertexGroupId]
                    local vStart = mg.vertexStart
                    
                    local verts = #()
                    for v=vStart+1 to vStart + l.vertexCount do
                    (
                        append verts vg.vertices[v]
                        
                    )
                    name = "Test " + (meshId as string)
                    theMesh = mesh name:name vertices:verts faces:faces
                    
                    
                    meshId = meshId + 1
                )
            )
            
        )
        
        ghostModel.indices.count
        
    ),
    
    function BuildNodMesh nod=
    (
        format "Building 3D Model\n"
        local help = GriffonStudios_Helpers()
        
        local bboxLayer = help.CreateLayer "Bounding Box"
        local meshLayer = help.CreateLayer "Unit"
        
        /* build bounding box */
        
        local bbox = help.BuildBoundingBox nod.bbox
        bboxLayer.AddNode bbox
       
        for mg in nod.meshGroups do
        (
            local meshName = nod.name + "_" + ( mg.id as string )
            
            local verts = #()
            local faces = #()
            local norms = #()
            local uvs = #()
            
            local l = mg.lods[1] 
            local vg = nod.VertexGroups[mg.vertexGroupId]
            
            if vg == undefined then continue
                    
            for v=1 to l.vertexCount do
            (
                append verts vg.vertices[v + vg.vertexOffset]
                append norms vg.normals[v + vg.vertexOffset]
                append uvs vg.uvs[v + vg.vertexOffset]
                
            )
            
            if verts.count < vg.vertices.count then vg.vertexOffset = verts.count
            
            local backfaceCullingIssue = 0
            
            if l.stripCount > 0 then
            (
                for i=l.stripStart + 1 to (l.stripStart + 1 + l.stripCount ) do
                (
                    local a = nod.indices[i]
                    local b = nod.indices[i+1]
                    local c = nod.indices[i+2]
                    
                    backfaceCullingIssue = 1 - backfaceCullingIssue
                    
                    if a == b or a == c or b == c then continue --> some weird chizzle over here ... 
                    if ( backfaceCullingIssue == 1 ) then
                        append faces [a,b,c]
                    else
                        append faces [a,c,b]
                    
                    
                )
            )
            
            if l.listCount > 0 then
            (
                for i=0 to (l.listCount)/3 do
                (
                    local a = nod.indices[l.listStart + 1 + i*3]
                    local b = nod.indices[l.listStart + 1 + i*3 + 1]
                    local c = nod.indices[l.listStart + 1 + i*3 + 2]
                   
                    if a == b or a == c or b == c then continue
                    
                    append faces [a,b,c]
                )
            )
            
            local theMesh = mesh name:meshName vertices:verts faces:faces vnorms:norms tverts:uvs
            local wirecolor = color (random 100 200) (random 100 150) (random 1 50)
            
            theMesh.WireColor = wireColor
            try (
                buildTVFaces theMesh false
                for i = 1 to faces.count do
                ( setTVFace theMesh i faces[i] )
            )
            catch()
            
            meshLayer.AddNode theMesh
            
        )
                
    ),
    function ReadNod file=
    (
        format "Reading 3D model file '%'\n" (filenameFromPath file)
        struct ghost_nod ( name, version, nShaders, nBones, nVertGrp, nMeshGrp, flags, bbox, vertexGroups, vertexGroupOffsets, meshGroups, nIndices, indices, lodStarts, lodCount, shaderNames, boneList, materials )
        struct ghost_mesh_grp ( id, matId, vertexCount, flags, nBlendShapes, blendGroup, boneList, nBones, vertexGroupId, lods, faces, vertexStart )
        struct ghost_vert_grp ( vertexCount, vertexType, vertices, normals, uvs, vertexOffset )
        struct ghost_mesh_lod ( lod, stripStart, stripCount, listStart, listCount, vertexCount )
        
        local gshelp = GriffonStudios_Helpers()
        
        stream = fOpen file "rb"

        local nod = ghost_nod()
        nod.name = getfilenamefile file
        nod.version  = readLong stream
        nod.nShaders = readByte stream as integer
        nod.nBones   = readByte stream as integer
        nod.nVertGrp = readByte stream as integer
        nod.nMeshGrp = readByte stream as integer 
        nod.flags    = readLong stream
        nod.bbox     = gshelp.ReadBoundingBox stream
        
        nod.vertexGroups = #()
        for i=1 to 4 do
        (
            local vg = ghost_vert_grp()
            vg.vertexType = readLong stream
            vg.vertexCount = readLong stream
            vg.vertexOffset = 0
            append nod.vertexGroups vg
        )

        nod.nIndices = readLong stream
        
        nod.lodStarts = #()
        for i=1 to 4 do
            append nod.lodStarts (readLong stream)

        nod.lodCount = readLong stream

        nod.shaderNames = #()
        for i=1 to nod.nShaders do
            append nod.shaderNames ( gshelp.ReadFixedString stream 0x20 )

        nod.boneList = #()
        for i=1 to nod.nBones do
        (
            local gb = ReadGhostBone stream
            gb.id = i
            append nod.boneList gb

        )

        for i=1 to nod.nVertGrp do
        (
            local vg = nod.vertexGroups[i]
            vg.vertices = #()
            vg.normals  = #()
            vg.uvs      = #()
            
            for i=1 to vg.vertexCount do
            (
                append vg.vertices ( gshelp.ReadVector3 stream 100.0 )
                append vg.normals  ( gshelp.ReadVector3 stream 1.0)
                append vg.uvs      ( gshelp.ReadUV3 stream )
            
                if ( vg.vertexType == 1 ) then
                    gshelp.SkipBytes stream 4
                if ( vg.vertexType == 2 ) then
                    gshelp.SkipBytes stream 16
            )
        )
        
        nod.indices = #()
        for i=1 to nod.nIndices do
        (
           append nod.indices ( readShort stream #unsigned +1 )
        )
        nod.meshGroups = #()
        local indexOffset = 0
        
        for i=1 to nod.nMeshGrp do
        (
            local mg = ghost_mesh_grp()
            mg.id = i
            mg.vertexStart = 0
            mg.matId = readLong stream
            mg.lods  = #()
            
            
            for l=1 to 4 do
            (
                
                local d = ghost_mesh_lod()
                
                local stripCount  = readShort stream #unsigned
                local listCount   = readShort stream #unsigned
                local vertexCount = readShort stream #unsigned
                
                d.lod = l-1
                d.stripStart    = indexOffset
                d.stripCount    = stripCount
                d.listStart     = indexOffset + stripCount
                d.listCount     = listCount
                d.vertexCount   = vertexCount
                  
                --format "lod: %  indexStart: %      indexCount: %        listStart: %        listCount: %        vertexCount: % \n" (l-1) indexOffset indexCount  d.listStart listCount vertexCount
                
                indexOffset = indexOffset + stripCount + listCount
                append mg.lods d
            )

            mg.vertexCount = readShort stream
            mg.flags = readByte stream
            mg.nBlendShapes = readByte stream as integer
            mg.blendGroup = readByte stream as integer
            mg.boneList = #()
            for b=1 to 20 do --> bones with id 204 -> are not used...
            (
                append mg.boneList (readByte stream #unsigned as integer)
            )

            mg.nBones = readByte stream as integer
            mg.vertexGroupId = readShort stream + 1
            
            append nod.meshGroups mg
        )

        -- determine the start of the vertices in the vertex groups
        for i=1 to nod.meshGroups.count do
        (
            local l=1
            
            if ( i>1 ) then 
            (
                for v=1 to i-1 do
                (
                    if ( nod.meshGroups[v].vertexGroupId == nod.meshGroups[i].vertexGroupId ) then 
                        nod.meshGroups[i].vertexStart = nod.meshGroups[v].vertexStart + nod.meshGroups[v].lods[l].vertexCount
                )
            )
            
         
            
        )
        
        nod.vertexGroupOffsets = #()
        for i=1 to nod.nVertGrp do
        (
            if i==1 then 
                append nod.vertexGroupOffsets 0
            else
                append nod.vertexGroupOffsets ( nod.vertexGroups[i-1].vertices.count )
        )
        
        fClose stream

        local materials = ReadMaterials file
        nod.materials = FindMaterial nod materials
        
        return nod
    ),
    /* 
        Main functions
    */
    function ImportModel file=
    (
        
        local nod = ReadNod file
        
        ghostModel = nod
        
        BuildMesh nod
       -- BuildNodMesh nod
       -- BuildGhostBones nod.boneList
        
        return "Import Done"
    )
)
/*
    Testing only
*/
clearListener()
--file = @"F:\Blizzard\Starcraft Ghost\StarCraft Ghost Xbox\3D\Models\Zealot.nod"
file = @"F:\Blizzard\Starcraft Ghost\StarCraft Ghost Xbox\3D\Models\Zealot.nod"

Starcraft_Ghost_Tools.ImportModel file
