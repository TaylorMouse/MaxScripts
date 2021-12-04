/*
    .AUTHOR
        Taylor Mouse

    .DATE
        4 Sept 2021

    .COPYRIGHT
        (c)2010-2021 Griffon Studios   
        
    .DESCRIPTION
        Read Rockstar's Manhunt DFF files

    .UPDATES
    | - Initial import

    .NOTES
    | myScale: the initial model is so tiny I added a scale factor
    | texturePath: directory on the hard drive where all the textures can be found, independant of the extension, however, the txd files must be extracted

*/
(
    clearListener()
    local myScale = 100.0
    local texturePath = @"G:\Game Dev\3D Models\Game Models\Rockstar Games\Manhunt\Textures\"
    
    function CreateLayer layerName =
    (
        /* Create layer in MAX, if it exists, just return a reference to that layer */
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    )
    function FindTexture textureName=
    (
        struct manhunt_texture ( theFile, isAlpha )
        local searchOptions = dotnetClass "System.IO.SearchOption"
        local directory = dotnetClass "System.IO.Directory"
        local wildCard = "*" + textureName + "*.*"
        local theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
        
        local shitList = #("alpha", "ALPHA", "_A", "Alph", "_ALPHA", "der_" )
        local isAlpha = false
        
        if ( theFile == undefined ) then 
        (
            for shit in shitList do 
            (
                wildCard = ""
                if ( findstring textureName shit ) != undefined then 
                (
                    wildCard = "*" +  ( ReplaceString textureName shit "" ) + "*.*"    
                    theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
                    isAlpha = true
                )
                if ( theFile != undefined ) then exit
            )
                
            if theFile == undefined then 
            (   
                -- refine the algoritm
                isAlpha = true
                for c=textureName.count to 1 by -1 do
                (
                    local rifinedName = substring textureName 1 c
                    wildCard = "*" + rifinedName + "*.*"
                    theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
                    if theFile != undefined then exit
                    
                )
                
                if theFile == undefined then (
                    format "Unable to find the following texture: % \n\n" textureName
                    theFile = textureName
                    isAlpha = false
                )
            )

        )
        manhunt_texture theFile:theFile isAlpha:isAlpha
    )
    function CreateLayer layerName =
    (
        /* Create layer in MAX, if it exists, just return a reference to that layer */
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    )
    function GetStreamSize stream=
    (
        fSeek stream 0 #seek_end
        local size = ftell stream
        fseek stream 0 #seek_set
        size
    )
    function SkipBytes stream nbrBytesToSkip=
    (
        fseek stream nbrBytesToSkip #seek_cur
    )
    function ReadChunkHeader stream=
    (
        struct dff_chunk ( Id, Size, Flags, Offset, Type )

        local h = dff_chunk()
        
        h.Offset = ftell stream
        h.Id   = readLong stream #unsigned
        h.Size = readLong stream #unsigned
        h.Flags = [readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned]
        
        h.Type = 
            case h.Id of
            (
                1: "CHUNK DATA"
                2: "STRING DATA"
                3: "OBJECT DATA"
                6: "TEXTURE DATA"
                7: "MATERIAL DATA"
                8: "MATERIALS"
                9: "SUBMESH DATA"
                10: "MODEL DATA"
                11: "BSP FILE"
                15: "MESH DATA"
                16: "DFF FILE"
                14: "BONES"
                26: "SKINNED MESH"
                286: "BONE DATA"
                39056126: "BONE NAME"
            )
        
        if ( h.Id == 3 and h.Size == 0 ) then h.Type = "IGNORE"
        
        --format"%\n" h
        h
    )
    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    )
    function ReadTransformationMatrix s =
    (
        matrix3 [readFloat s, readFloat s,readFloat s] [readFloat s, readFloat s,readFloat s] [readFloat s, readFloat s,readFloat s] [readFloat s * myScale, readFloat s * myScale,readFloat s * myScale]
    )
    function ReadBones stream chunk=
    (
        struct dff_bone ( type= 256, frameBoneId= 0, bone_count= 0, parentId, unk1, unk2, name, bone_anim = #(), transform_matrix, bone_ref, bonesys_ref )
        struct dff_bone_anim ( id, index, frameBoneId )
        
        --format "- Reading %\n" chunk.Type
        if ( chunk.Id != 14 ) then return undefined
        
        local totalOffset = chunk.Offset + 12 + chunk.Size
        
        fseek stream (chunk.Offset + 12) #seek_set
        
        local boneChunks = #()
        while ( ftell stream < totalOffset ) do
        (
            local c = ReadChunkHeader stream
            SkipBytes stream c.Size
            append boneChunks c
        )
        
        local bone_list = #()
        local boneIndex = 0
        for bChunk in boneChunks do
        (
            fSeek stream (bChunk.offset + 12) #seek_set
            
            if ( bChunk.Id == 1 ) then --> contains the bind transforms and parent hierarchy
            (
                local nbrBones = readLong stream
                local miniSize = ( bChunk.Size - 4 ) / nbrBones
                for i=1 to nbrBones do
                (
                    local binding = dff_bone()
                    binding.transform_matrix = ReadTransformationMatrix stream
                    binding.parentId = ( readLong stream #signed ) + 1
                    binding.unk1 = readShort stream
                    binding.unk2 = readShort stream
                    append bone_list binding
                )
            )
            if ( bChunk.Id == 3 and bChunk.Size == 0 ) then bone_list[1].name = "Root" --> contains the root bone or helper
                
            if ( bChunk.Id == 3 and bChunk.Size > 0 ) then 
            (
                local bone_chunk = ReadChunkHeader stream
                bone_list[boneIndex].type = readLong stream
                bone_list[boneIndex].frameBoneId = readLong stream
                bone_list[boneIndex].bone_count = readLong stream
                
                if ( bone_list[boneIndex].bone_count > 0 ) then SkipBytes stream 8
                
                for i=1 to bone_list[boneIndex].bone_count do 
                (
                    local ba = dff_bone_anim()
                    ba.id = readLong stream
                    ba.index = readLong stream
                    ba.frameBoneId = readLong stream
                    append bone_list[boneIndex].bone_anim ba
                    
                )
                --print bone_list[boneIndex].bone_anim
                
                fSeek stream (bChunk.offset + 24 + bone_chunk.size) #seek_set
                local chunkName = ReadChunkHeader stream
                if ( chunkName.Id =  0x0253F2FE ) then 
                    bone_list[boneIndex].name = ReadFixedString stream chunkName.Size
            )
            boneIndex += 1
        )
        
        bone_list
        
    )
    function ReadChunks stream chunk=
    (
        local subchunks = #()
        fSeek stream ( chunk.offset + 12 ) #seek_set
        
        while ( ftell stream < ( chunk.offset + chunk.size + 12 ) ) do
        (
            local c = ReadChunkHeader stream
            SkipBytes stream c.Size
            append subchunks c
        )
        subchunks
    )
    function ReadMaterials stream chunk=
    (
        if ( chunk.id != 8 ) then return undefined --> material
        
        struct dff_material ( name, ManhuntTexture, MaterialRef = Standard() )
        
        local materialChunks = ReadChunks stream chunk
        local materials = #()
        
        fSeek stream (chunk.offSet + 12 ) #seek_set
        
        for m in materialChunks do
        (
            if ( m.id == 7 ) then ( --> material layer
                local layers = ReadChunks stream m
                local mat = dff_material()
                
                for l in layers do
                (
                    if ( l.id == 6 ) then  --> texture data
                    (
                        local textureData = ReadChunks stream l
                        
                        for t in textureData do
                        (
                            if ( t.id == 2 ) then  --> texture names
                            (
                                fSeek stream (t.offSet + 12 ) #seek_set

                                local textureName = ReadFixedString stream t.Size
                                if ( textureName !="" ) then 
                                (
                                    mat.name = textureName
                                    mat.ManhuntTexture = FindTexture textureName
                                
                                    mat.MaterialRef.DiffuseMap = BitmapTexture fileName:mat.ManhuntTexture.theFile
                                    showTextureMap mat.MaterialRef mat.MaterialRef.diffuseMap true
                                    if mat.ManhuntTexture.isAlpha then 
                                    (
                                        mat.MaterialRef.opacityMap = BitmapTexture fileName:mat.ManhuntTexture.theFile
                                        mat.MaterialRef.opacityMap.monooutput = 1
                                        showTextureMap mat.MaterialRef true
                                    )
                                    append materials mat
                                    
                                )
                            )
                        )
                    )
                )
                
            )
            
        )

        return materials

    )
    function ReadMesh stream chunk=
    (
        struct dff_mesh ( faces = #(), verts = #(), norms = #(), uvs = #(), matIds = #() )
        
        
        /* geometry flags
        1   use Tri-Strip
        2   Position
        4   Texture UV
        8   Prelit (Vertex Colors)
        16  Normal
        32  Light
        64  Modulate Material Color
        128 2 set of coordinates
        */

        fSeek stream (chunk.offSet + 12 ) #seek_set
        
        local meshObj = dff_mesh()
        
        local geometryFlag = readShort stream
        local nUvSets      = readShort stream
        local nFaces       = readLong stream
        local nVerts       = readLong stream
        local nMaterials   = readLong stream
        
        if ( chunk.Flags[4] != 0x10 and chunk.Flags[4] != 0x18 ) then SkipBytes stream 12 -- self lighting?
        if ( mod geometryFlag 16 >=8 ) then SkipBytes stream ( 4 * nVerts ) -- vertex colors?
        
        
        if ( mod geometryFlag 8 >=4 or nUvSets > 0 ) then
            for v=1 to nVerts do append meshObj.uvs [readFloat stream, 1 - (readFloat stream), 0]

        for u=2 to nUvSets do SkipBytes stream ( nVerts * 8 ) --> skip multi uv layer sets
        
        for f=1 to nFaces do
        (
            local b = readShort stream + 1
            local a = readShort stream + 1
            local matId = readShort stream + 1
            local d = readShort stream + 1

            append meshObj.faces [a, b, d]
            append meshObj.matIds matId
            
        )

        SkipBytes stream 24 --> bounding box stuff
        
        for v=1 to nVerts do
        (
            local x = readFloat stream * myScale
            local y = readFloat stream * myScale
            local z = readFloat stream * myScale
            append meshObj.verts [x, y, z]
        )
    
        if ( mod geometryFlag 32 >=16 ) then
        (
            for v=1 to nVerts do
                append meshObj.norms [readFloat stream, readFloat stream, readFloat stream]
        )
        
        meshObj
    )
    function ReadGeometry stream chunk =
    (
        if ( chunk.Id != 26 ) then return undefined

        struct dff_geo ( materials, meshObj )
        
        local geoChunks = ReadChunks stream chunk
        local geometry_list = #()
        
        for g in geoChunks do 
        (
            fSeek stream (g.offset + 12) #seek_set
            if ( g.id == 1 ) then SkipBytes stream g.Size
            
            if( g.id == 15 ) then
            (
                local geoSubChunks = ReadChunks stream g
                local geo = dff_geo()
                for c in geoSubChunks do
                (
                    if ( c.id == 1 ) then geo.meshObj = ReadMesh stream c 
                    if ( c.id == 8 ) then geo.materials = ReadMaterials stream c 
                )
                append geometry_list geo
            )
        )
        return geometry_list
    )
    function BuildBones bone_list=
    (
        local boneLayer = CreateLayer "Bones"
        
        local boneSize = myScale / 12.5 --> calculate this when scaling the object
        
        for b in bone_list do
            b.bone_ref = Point pos:[0,0,0] Box:on size:( boneSize * 2 ) Cross:off wirecolor:(color 0 128 0) name:b.name
            
        for b in bone_list do
            if b.parentId > 0 then (
                b.bone_ref.parent = bone_list[b.parentId].bone_ref
                b.bone_ref.showlinks = false
            )
        
        local rootBone = undefined
        local rootTransform = undefined
        for b in bone_list do
        (
            if b.parentId > 0 then
            (
               in coordsys parent b.bone_ref.pos = b.transform_matrix.position
               in coordsys local  b.bone_ref.rotation = inverse b.transform_matrix.rotation 
            )
            else
            (
               b.bone_ref.pos = b.transform_matrix.position
               in coordsys local b.bone_ref.rotation = inverse b.transform_matrix.rotation
            )
        )
        
        for b in bone_list do
        (
            local theBone = b.bone_ref
            
            if ( theBone.children.count >= 1 ) then 
            (
                local theChild = theBone.children[1]
                local aBone = BoneSys.CreateBone theBone.Position theChild.Position [0,0,-1]
                
                aBone.width = boneSize
                aBone.height = boneSize
                
                if boneSize > aBone.length then
                (
                    aBone.width = aBone.length
                    aBone.height = aBone.length
                )
                --if aBone.length < boneSize then aBone.length = boneSize
                aBone.name = b.name
                aBone.Parent = theBone
                b.bonesys_ref = aBone
            )
            else
            (
                local aBone = BoneSys.CreateBone theBone.Position [0,0,0] [0,0,-1]
                aBone.width = boneSize / 2
                aBone.height = boneSize / 2
                aBone.length = boneSize 
                aBone.name = theBone.name
                aBone.Parent = theBone
                in coordsys parent aBone.Rotation = inverse b.transform_matrix.rotation
                b.bonesys_ref = aBone
            )
        )

        -- rebuild the hiearchy
        for b in bone_list do
        (
            boneLayer.AddNode b.bonesys_ref
            if b.parentId > 0 then
                b.bonesys_ref.parent = bone_list[b.parentId].bonesys_ref
            
            delete b.bone_ref
            b.bone_ref = undefined
        )
    )
    function BuildMeshes geometry_list file=
    (
        local name = getFileNameFile file
        local layer = createLayer name
        local index = 0
        
        for geo in geometry_list do
        (
            
            local WireColor = Color (random 0 128) (random 0 255) (random 0 128)
            local m = geo.meshObj
            
            /* build the material */
            local uniqueMatIds = #()
            for i=1 to m.matIds.Count do appendIfUnique uniqueMatIds m.matIds[i]
            
            local mm = MultiMaterial numsubs:uniqueMatIds.Count
            
            for i=1 to uniqueMatIds.Count do
            (
                if ( geo.materials[uniqueMatIds[i]].MaterialRef != undefined ) then 
                mm[i] = geo.materials[uniqueMatIds[i]].MaterialRef
            )
            
            /* build the mesh */
            local meshName = name + "_" + (index as string )
            local theMesh = mesh vertices:m.verts vnorms:m.norms name:meshName faces:m.faces tverts:m.uvs
            theMesh.WireColor = wireColor
            buildTVFaces theMesh false
            for i = 1 to m.faces.count do setTVFace theMesh i m.faces[i]
            update theMesh
            
            layer.AddNode theMesh
            
            /* apply the material */
            theMesh.Material = mm
            update theMesh
            
            /* assign the material ids to the faces */
            for i=1 to m.faces.count do
            (
                
                local faceMatId = 1
                for j=1 to uniqueMatIds.Count do
                (
                    if ( uniqueMatIds[j] == m.matIds[i] ) then 
                    (
                        faceMatId = j
                        exit
                    )
                )
                setFaceMatID theMesh i faceMatId
            )
            update theMesh
            index += 1
        )
    )
    function ImportDFF file=
    (
        local stream = fOpen file "rb"
        
        local streamSize = GetStreamSize stream
        local header = ReadChunkHeader stream
        
        if ( header.Size + 12 != streamSize ) then throw ("Incorrect fileformat. Chunks not recognized")

        local currentPos = 12
        local chunks = #()
        
        
        while ( currentPos < streamSize ) do
        (
            local chunk = ReadChunkHeader stream
            SkipBytes stream chunk.Size
            currentPos += ftell stream
            append chunks chunk
        )
        
        local bone_list = undefined
        local geometry_list = undefined
        
        for chunk in chunks do
        (
            if ( chunk.Id == 14 ) then bone_list = ReadBones stream chunk
            if ( chunk.Id == 26 ) then geometry_list = ReadGeometry stream chunk
        )
                
        fClose stream

        if ( bone_list != undefined ) then BuildBones bone_list
        if ( geometry_list != undefined ) then BuildMeshes geometry_list file
        
        
        GC()
        FreeSceneBitmaps()
        ClearUndoBuffer()
    )
    
    --local file = @"G:\Game Dev\3D Models\Game Models\Rockstar Games\Manhunt\DFF\bun_pc.dff"
    local file = @"G:\Game Dev\3D Models\Game Models\Rockstar Games\Manhunt\DFF\cash_pc.dff"
    
    
    ImportDFF file
)