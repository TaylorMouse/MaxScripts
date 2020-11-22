/*
    ©2014 ~ 2020 Script by Taylor Mouse
	Shiro Games models from 
    - Northgard
    - Darksburg
    FBX

*/

fileIn @"GriffonStudios_Helpers.ms"

global hmdModel
global help
global darksburgAssets= @"G:\Game Dev\3D Models\Game Models\Darksburg\"

ClearListener()

struct Darksburg
(
    function GetFilesRecursive root pattern =
    (
        dir_array = GetDirectories ( root + "*" )
        for d in dir_array do
            join dir_array (GetDirectories ( d + "*"))
        
        
        my_files = #()
        for f in dir_array do
            join my_files (getFiles (f + pattern + "*"))
        return my_files
    ),
    function FindAndRename file = 
    (
        file = filenameFromPath file
        
        local files =  Darksburg.GetFilesRecursive darksburgAssets file 
        
        if files.count > 0 then
        (
            local f = files[1]
            local extension = getfilenametype f
            if extension != ".dds" then
            (
                renameFile f ( f + ".dds")
                f = f + ".dds"
            )
            foundIt = f
        )        
        else
            foundIt = file
        
        return foundIt
    ),
    function ReadByteLengthString stream=
    (
        local len = readByte stream #signed
        
        local name = undefined
        if len > 0 then 
            name = GriffonStudios_Helpers.ReadFixedString stream len
        
        return name
        
    ),
    function ImportHMD file=
    (
        struct HMD ( stream, meshes, meshNames, Materials, nbrMeshes, nbrMaterials, nbrMeshNames )
        
        struct HMDMesh ( hasPosition, hasNormal, hasTangent, hasUV, hasUV2, hasWeights, hasIndexes, hasColor, 
                         nbrVertices, nbrIndexGroups, 
                         VertexOffset, IndexOffset, 
                         Vertices, Normals, UVs, UVs2, Tangents, Colors, Indexes, Weights, Groups, IndexGroups, BBox )
        
        struct HMDMaterial ( name, albedoMap, metallicGlossAoMap, NormalMap, materialRef )
        
        _db = Darksburg()
        help = GriffonStudios_Helpers()
                         
        local stream = fOpen file "rb"

        /* read the header */
        hmdModel = HMD stream:stream
        
        local header = help.ReadFixedString stream 3
        
        if header != "HMD" then throw "File not supported !"
        
        readByte stream
        local dataStartOffset = readLong stream
        
        /* read the mesh specifications */
        readByte stream
        hmdModel.nbrMeshes = readLong stream
        
        hmdModel.meshes = #()
        for n=1 to hmdModel.nbrMeshes do
        (
            local m = HMDMesh()
            readByte stream
            
            m.nbrVertices = readLong stream 
            readByte stream
            
            local nbrDataSubjects = readByte stream
            for i=1 to nbrDataSubjects do
            (
                local nameLen = readByte stream
                local dataName = help.ReadFixedString stream nameLen
                local dataSize = readByte stream

                if dataName == "position" then  m.hasPosition = true;  
                if dataName == "normal"   then  m.hasNormal   = true; 
                if dataName == "tangent"  then  m.hasTangent  = true; 
                if dataName == "uv"       then  m.hasUv       = true; 
                if dataName == "uv2"      then  m.hasUv2      = true; 
                if dataName == "weights"  then  m.hasWeights  = true; 
                if dataName == "indexes"  then  m.hasIndexes  = true; 
                if dataName == "color"    then  m.hasColor    = true; 
            )

            m.VertexOffset = readLong stream
            m.nbrIndexGroups = readByte stream
            
            m.IndexGroups = #()
            for i=1 to m.nbrIndexGroups do
            (
                local nbrIndices = readLong stream    
                append m.IndexGroups nbrIndices
            )
            
            m.IndexOffset = readLong stream
            m.BBox = #()
            for i= 1 to 2 do 
            (   
                local x = readFloat stream * 100
                local y = readFloat stream * 100
                local z = readFloat stream * 100
                append m.bBox  [z, -x, y]
            )
            append hmdModel.meshes m
        )
        
        /* read materials */
        hmdModel.nbrMaterials = readLong stream
        hmdModel.materials = #()
        
        try (
            for m=1 to hmdModel.nbrMaterials do
            (
                local mat = hmdMaterial()
                
                local type = readByte stream
                if type == 1 then local two = readByte stream
                    
                local nameLen = readByte stream
                mat.name = help.ReadFixedString stream nameLen
                
                local nbrTextures = 3
                if type == 0 then nbrTextures = 1
            
                for i=1 to nbrTextures do
                (
                    local textNameLen = readByte stream
                    
                    if textNameLen > 0 then 
                    (
                        local textName = help.ReadFixedString stream textNameLen
                    
                        if i == 1 then mat.albedoMap = _db.FindAndRename textName
                        if i == 2 then mat.metallicGlossAoMap = _db.FindAndRename textName
                        if i == 3 then mat.NormalMap = _db.FindAndRename textName
                    )
                    if i==1 then help.SkipBytes stream 6
                )
                append hmdModel.materials mat
            )
            
            
            
            
        )
        catch ( format "****************************************************************\n[ERROR] Something went wrong, no worries, we continue !!\n****************************************************************\n")
        
        
        /* read names */
        
        hmdModel.nbrMeshNames = readLong stream
        hmdModel.MeshNames = #()
        Format "Reading % names \n" hmdModel.nbrMeshNames
        for i=1 to hmdModel.nbrMeshNames do
        (
            if ( i > 1 ) then readLong stream
            readByte stream
            local objNameLen = readByte stream
            local objName = help.ReadFixedString stream objNameLen
            
            readLong stream
            local ff = readByte stream #signed
             
--              while ( ( readByte stream #singed ) != -1 ) do 
--              (                    
--              )
            help.SkipBytes stream ( 9 * 4 ) -- 3 x 3 matrix
            
            print objName
            append hmdModel.MeshNames objName
            
        )
        
        -- 3 x 3 matrix
        Format "Reading bones \n"
        print (ftell stream )

        local one = readLong stream
        local two = readLong stream
        readByte stream
        
        local hasBones = true
        if ( two == 2 ) then 
        (
            local check = readLong stream
        )
        
        local rootBone = Darksburg.ReadByteLengthString stream
        
        print rootBone
       
        struct hmdBone ( id, parentId, boneName, localPos, localRot, boneRef )
        local boneList = #()

        
        
        if (rootBone != undefined ) then (
            readByte stream
            local nbrBones = readShort stream
            readByte stream
        
            local root = hmdBone boneName:rootBone id:1 parentId:0 localPos:[0,0,0] localRot:[0,0,0]
            append boneList root
            
            for i=1 to nbrBones do
            (
                
                local boneName = Darksburg.ReadByteLengthString stream
                local parentBoneId = readByte stream 
                
                local zeros = readByte stream
                
                local pos = [readFloat stream, readFloat stream, readFloat stream] * 100.0
                local rot = [readFloat stream, readFloat stream, readFloat stream]
                
                local b = hmdBone boneName:boneName localPos:pos localRot:rot id:i parentId:parentBoneId
                
                local unk1 = readByte stream
                
                if (unk1 == 0 ) then
                (
                    readByte stream
                )
                else
                (
                    local type = readByte stream
                    if type == 0 then 
                        help.SkipBytes stream 24
                    else 
                        help.SkipBytes stream 48
                )
                
                readbyte stream
                
                --format "% % \n" boneName parentBoneId
             
                append boneList b
            )
        )
        /* start reading the data */
        
        for m=1 to hmdModel.nbrMeshes do
        (
            local msh = hmdModel.Meshes[m]
            fseek stream ( dataStartOffset + msh.VertexOffset ) #seek_set
             
            msh.Vertices = #()
            msh.Normals = #()
            msh.Tangents = #()
            msh.UVs = #()
            msh.UVs2 = #()
            msh.Colors = #()
            msh.Weights = #()
            msh.Indexes = #()
            for v=1 to msh.nbrVertices do
            (
                if msh.hasPosition == true then
                (
                    local x = readFloat stream * 100
                    local y = readFloat stream * 100
                    local z = readFloat stream * 100
                    append msh.Vertices [z, -x, y] 
                )
                if msh.hasNormal == true    then append msh.Normals  [readFloat stream, readFloat stream, readFloat stream]
                if msh.hasTangent == true   then append msh.Tangents [readFloat stream, readFloat stream, readFloat stream]
                if msh.hasUV == true        then append msh.UVs      [readFloat stream, 1.0 - (readFloat stream ), 0]
                if msh.hasUV2 == true       then append msh.UVs2     [readFloat stream, 1.0 - (readFloat stream ), 0]
                if msh.hasColor == true     then append msh.Colors   [readFloat stream, readFloat stream, readFloat stream]
                if msh.hasWeights == true   then append msh.Weights  [readFloat stream, readFloat stream, readFloat stream]
                if msh.hasIndexes == true   then append msh.Indexes  [readByte stream, readByte stream, readByte stream, readByte stream]
                
            )
            
            fseek stream ( dataStartOffset + msh.IndexOffset ) #seek_set
            
            msh.Groups = #()
            for g=1 to msh.nbrIndexGroups do
            (
                local idxGrp = msh.IndexGroups[g]
                local faces = #()
                for f=1 to idxGrp by 3 do
                (
                    local f1 = readShort stream + 1
                    local f2 = readShort stream + 1
                    local f3 = readShort stream + 1
     
                    append faces [f1, f2, f3]
                )
                append msh.Groups faces

            )
            
        )
 
        fClose stream

        /* build the objects */
        BuildMaterials = false
        
        -- materials
        if BuildMaterials == true then (
            for i=1 to 24 do meditmaterials[i] = standard()
            for i=1 to  hmdModel.materials.count do
            (
                local mat = standard()
                
                if hmdModel.materials[i].name != undefined then 
                    mat.name = hmdModel.materials[i].name
                
                if hmdModel.materials[i].albedoMap != undefined then 
                mat.diffuseMap = Bitmaptexture fileName:hmdModel.materials[i].albedoMap
                
                if hmdModel.materials[i].normalMap != undefined then (
                    mat.bumpMap = Normal_Bump ()
                    mat.bumpMap.normal_map = Bitmaptexture fileName:hmdModel.materials[i].normalMap
                )
                
                if hmdModel.materials[i].metallicGlossAoMap != undefined then (
                    mat.specularMapEnable = on
                    mat.specularMap = Bitmaptexture fileName:hmdModel.materials[i].metallicGlossAoMap
                )
                
                showTextureMap mat true
                meditmaterials[i] = mat
                
                hmdModel.materials[i].materialRef = mat
                
            )
        )
        
        BuildBBox = false
        
        -- bounding box
        if( BuildBBox == true ) then 
        (
            local bboxLayer = help.CreateLayer "Bounding Boxes"
            local objName = hmdModel.MeshNames[1]
            for msh in hmdModel.Meshes do (
                local b = help.BuildBoundingBox msh.bBox
                b.Name = objName
                freeze b
                bboxLayer.AddNode b
            )
        )
        
        BuildBones = true
        if (BuildBones == true) then
        (
            for b in boneList do
            (
                b.boneRef = bonesys.createbone [0,0,0] [0,0,0] [0,0,1]
                b.boneRef.Name = b.BoneName
                b.boneRef.ShowLinks = false
            )
            
            for i=1 to boneList.count do
            (
                local b = boneList[i]
                local parentId = b.parentId
                if ( parentId > 0 ) then
                (
                    b.boneRef.parent = boneList[parentId].boneRef
                )
            )

            for i=1 to boneList.Count do
            (
                local b = boneList[i]
                if ( b.boneRef.parent != undefined ) then
                (
                    b.boneRef.pos = b.boneref.parent.pos + b.localpos
                )
                else
                    b.boneRef.pos = b.localpos
                
            )
            
            
        )
        
        BuildMeshes = false
        -- meshes
        if ( BuildMeshes == true ) then 
        (
            local objName = hmdModel.MeshNames[1]
            if objName == undefined then objName = "NoName"
            
            local layer = help.CreateLayer "Meshes"
            
            for m=1 to hmdModel.nbrMeshes do
            (
                local msh   = hmdModel.Meshes[m]
                local verts = msh.Vertices
                local norms = msh.Normals
                local uvs   = msh.UVs
                for i=1 to msh.Groups.count do
                (
                    
                    local faces = msh.groups[i]
                    local mesh_name = objName + "_" + ( i as string )
                    local theMesh = mesh vertices:verts faces:faces vnorms:norms name:mesh_name tverts:uvs
                    
                    theMesh.WireColor = color ( random 0 255 ) ( random 0 128 ) ( random 128 255 )
                    
                    try (
                        buildTVFaces theMesh false
                        for i = 1 to faces.count do
                        ( setTVFace theMesh i faces[i] )
                        
                        if( i <= hmdModel.materials.count ) then 
                        (
                            if hmdModel.materials[i].materialRef != undefined then theMesh.Material = hmdModel.materials[i].materialRef
                        )
                        else
                        (
                            if ( hmdModel.materials.count >= 0 ) then
                                if hmdModel.materials[1].materialRef != undefined then 
                                    theMesh.Material = hmdModel.materials[1].materialRef
                            
                        )
                        max modify mode
                        modPanel.setCurrentObject theMesh
                        meshOps.removeIsolatedVerts theMesh
                        
                        layer.AddNode theMesh
                    )
                    catch ( Format "[Error] Something went wrong when altering the mesh\n" )
                )
            )
        )
        
        
        
        clearSelection()
        max zoomext sel
        
    )
)
    
-- 

file = getOpenFileName \
			caption:"Darksburg" \
			types:"Supported Files|*.fbx|Darksburg(*.fbx)|*.fbx|All Files|*.*" \
			historyCategory:"DarksburgPreset"

print file
if (file != undefined ) then Darksburg.ImportHMD file

GC()
