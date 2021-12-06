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
    | - implementig bone indices and vertex weights
    | - fixed a bug when the texture path did not exist
    | - fixed a bug with the mesh type
    | - parsing the dff files that conctain multiple models
    | - Initial import

    .NOTES
    | myScale: the initial model is so tiny I added a scale factor
    | texturePath: directory on the hard drive where all the textures can be found, independant of the extension, however, the txd files must be extracted

*/
(
    clearListener()
    local myScale = 100.0
    local texturePath = @"G:\Game Dev\3D Models\Game Models\Rockstar Games\Manhunt\Textures\"
    local debug = false
    
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
    function CleanUpLayers=
    (
    
        local nLayers = LayerManager.Count
        local defaultLayer = LayerManager.GetLayer(0)
        defaultLayer.current = true
    
        local layers = #()
        for i= 1 to nLayers do append layers (LayerManager.GetLayer(i-1))
    
        for layer in layers do
        (
            layer.nodes &nodes
            
            if ( layer.name != "0" and nodes.count == 0 ) then 
                LayerManager.deleteLayerByName layer.name 
        )  
    )
    function ReplaceString str oldStr newStr=
    (
        local foundAt = findstring str oldStr
        local left    = substring str 1 (foundAt - 1)
        local right   = substring str (foundAt + oldStr.count) -1
        
        (left + newStr + right )
    )
    function FindTexture textureName=
    (
        struct manhunt_texture ( theFile, isAlpha )
        local fallBackMaterial = manhunt_texture theFile:textureName isAlpha:false
        
        if ( doesFileExist texturePath == false ) then return fallBackMaterial
        
        try( 
            local searchOptions = dotnetClass "System.IO.SearchOption"
            local directory = dotnetClass "System.IO.Directory"
            local wildCard = "*" + textureName + "*.*"
            local theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
            
            local shitList = #("_ALPHA", "ALPHA", "_A", "ALPH",  "der_" )
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
        catch(
            format "[ERROR]\n Error occured in FindTexture '%' in \nfolder: '%'\n" textureName texturePath
            return fallBackMaterial
        )
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
                16: "MANHUNT MODEL"
                14: "BONES"
                20: "UNKNOWN ..."
                26: "SKINNED MESH"
                278: "SKIN DATA"
                286: "BONE DATA"
                1294: "SPLIT DATA"
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
    function ReadChunks stream chunk=
    (
        
        local subchunks = #()
        fSeek stream ( chunk.offset + 12 ) #seek_set
        try(
            while ( ftell stream < ( chunk.offset + chunk.size + 12 ) ) do
            (
                local c = ReadChunkHeader stream
                SkipBytes stream c.Size
                append subchunks c
            )
        )
        catch(
            format "Error reading chunk %\n" chunk
            )
        subchunks
    )
    function ReadBones stream chunk=
    (
        struct dff_bone ( id, name, parentId, Flags, bone_anim = #(), transform_matrix, bone_ref, type= 256, frameBoneId= 0, bone_count= 0, unk1 )
        struct dff_bone_anim ( id, index, frameBoneId )
        
        if ( chunk.Id != 14 ) then return undefined
        
        local boneChunks = ReadChunks stream chunk
        local bone_list = #()
        local boneIndex = 0

        for bChunk in boneChunks do
        (
            fSeek stream (bChunk.offset + 12) #seek_set
            
            if ( bChunk.Id == 1 ) then --> contains the bind transforms and parent hierarchy
            (
                local nbrBones = readLong stream
                local validation = ( bChunk.Size == ( nbrBones * 12 * 4 + nbrBones * 8 + 4  )  )
                if validation then
                for i=1 to nbrBones do
                (
                    local binding = dff_bone()
                    binding.id = i
                    binding.transform_matrix = ReadTransformationMatrix stream
                    binding.parentId = ( readLong stream #signed ) + 1
                    binding.unk1 = readShort stream
                    binding.Flags = readShort stream
                    append bone_list binding
                )
            )
            if ( bChunk.Id == 3 and bChunk.Size == 0 ) then bone_list[1].name = "ROOT" --> contains the root bone or helper
                
            if ( bChunk.Id == 3 and bChunk.Size > 0 ) then 
            (
                local subChunks = ReadChunks stream bChunk
                
                for bone_chunk in subChunks do
                (
                    
                    fSeek stream ( bone_chunk.offset + 12 ) #seek_set
                    if( bone_chunk.Id == 256 ) then --> contains the framebone id's
                    (
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
                    )
                    if ( bone_chunk.Id =  0x0253F2FE ) then --> contains the bone name
                        bone_list[boneIndex].name = ReadFixedString stream bone_chunk.Size
                )
            )
            boneIndex += 1
        )
--        print bone_list

        bone_list
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
                append materials mat
                
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
                                
                                if ( textureName != "" ) then 
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
                                    
                                    
                                )
                            )
                        )
                    )
                )
                
            )
            
        )
        
        materials
    )
    function ReadMesh stream chunk=
    (
        struct dff_mesh ( faces = #(), verts = #(), norms = #(), uvs = #(), matIds = #())
        
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

        SkipBytes stream 24
        
        for v=1 to nVerts do
        (
            local x = readFloat stream * myScale
            local y = readFloat stream * myScale
            local z = readFloat stream * myScale
            append meshObj.verts [x, -y, -z]
            if v==1 then print [x,-y,-z]
        )
    
        if ( mod geometryFlag 32 >=16 ) then
        (
            for v=1 to nVerts do
                append meshObj.norms [readFloat stream, readFloat stream, readFloat stream]
        )
        
        meshObj
    )
    function ReadSkin stream chunk nVertices=
    (
        local skinChunks = ReadChunks stream chunk

        struct dff_skin ( bone_weights, bone_indices, animated_bones = #())
        local dffSkin = dff_skin()
        
        for skinChunk in skinChunks do
        (    
            -- if ( skinChunk.Id == 1294 ) then Format "Not sure why I need this ..."
            if ( skinChunk.Id == 278 ) then
            (
                fSeek stream ( skinChunk.Offset + 12 ) #seek_set
                
                local nTotalBones    = readByte stream #unsigned
                local nAnimatedBones = readByte stream #unsigned
                local nWeights       = readbyte stream #unsigned
                local nPrecision     = readbyte stream #unsigned

                for i=1 to nAnimatedBones do append dffSkin.animated_bones (readByte stream + 1)
                local boneIndices = #()
                for v=1 to nVertices do 
                (
                    local boneIds = #()
                    for w=1 to nWeights do 
                    (
                        local id = readByte stream #signed
                        if id != 0 then id += 1
                        append boneIds id
                    )
                    append boneIndices boneIds
                )
                
                local boneWeights = #()
                for v=1 to nVertices do 
                (
                    local weights = #()
                    for w=1 to nWeights do 
                    (
                        local weight = readFloat stream
                        append weights weight
                    )
                    -- fix the total weight !!
                    local totalWeight = 1.0
                    for w=1 to nWeights do
                        totalWeight -= weights[w]
                    
                    if totalWeight > 0.000000 then weights[1] += totalWeight
                    append boneWeights weights
                )
                
                -- reduce the arrays when boneIndex = 0 or weight = 0.0
                for v=1 to nVertices do
                (
                    local newIndices = #()
                    local newWeights = #()
                    
                    local nNonZeroBones = 0
                    local nNonZeroWeights = 0
                    for w=1 to nWeights do (
                        if boneIndices[v][w] > 0 then nNonZeroBones += 1
                        if boneWeights[v][w] > 0 then nNonZeroWeights += 1
                    )
                    
                    local nActual = nNonZeroBones
                    if nNonZeroWeights < nActual then nActual = nNonZeroWeights
                    
                    for n=1 to nActual do
                    (
                        newIndices[n] = boneIndices[v][n]
                        newWeights[n] = boneWeights[v][n]
                    )
                    boneIndices[v] = newIndices
                    boneWeights[v] = newWeights
                )
                
                dffSkin.bone_weights = boneWeights
                dffSkin.bone_indices = boneIndices
                
            )
        )
        
        dffSkin
    )
    function ReadGeometry stream chunk =
    (
        if ( chunk.Id != 26 ) then return undefined

        struct dff_geo ( materials, meshObj, skinData )
        
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
                    if ( c.id == 1 ) then try ( geo.meshObj = ReadMesh stream c ) catch ( Format "Error occured in Read Mesh\n" )
                    if ( c.id == 8 ) then try ( geo.materials = ReadMaterials stream c ) catch ( Format "Error occured in Read Materials\n")
                    if ( c.id == 3 ) then try ( geo.skinData = ReadSkin stream c geo.meshObj.verts.count ) catch ( Format "Error occured in Read Skin\n")
                )
                append geometry_list geo
            )
        )
        return geometry_list
    )
    function BuildBones bone_list=
    (
        local boneLayer = CreateLayer "Bones"
        
        -- creation
        for b in bone_list do
        (
            b.bone_ref = boneSys.CreateBone [0,0,0] [0,0,0] [0,0,-1]
            b.bone_ref.name = b.name
            b.bone_ref.Width = 0.05
			b.bone_ref.Height = 0.05
            b.bone_ref.ShowLinks = true
            boneLayer.AddNode b.bone_ref
        )
        -- hierarchy
        for b in bone_list do
            if b.parentId > 0 then
                b.bone_ref.parent = bone_list[b.parentId].bone_ref
        
        -- position
        with animate on 
            at time 0
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
            
    )
    function ApplySkinning theMesh bone_list skin_data=
    (
        local bone_mapping = #(
            #("Bip01", "Bip01" ),
            #("Bip01 Pelvis", "Bip01 Pelvis" ),
            #("Bip01 Spine", "Bip01 Spine" ),
            #("Bip01 Spine1", "Bip01 Spine1" ),
            #("Bip01 Head" , "Bip01 R UpperArm" ),
            #("Bip01 L Calf", "Bip01 L Forearm" ),
            #("Bip01 L Clavicle", "Bip01 R Forearm" ),
            #("Bip01 L Finger0" , "Bip01 R Foot" ),
            #("Bip01 L Finger01", "Bip01 R Toe0" ),
            #("Bip01 L Foot", "Bip01 L Hand" ),
            #("Bip01 L Forearm" , "Bip01 R Thigh" ),
            #("Bip01 L Hand", "Bip01 R Calf" ),
            #("Bip01 L Thigh", "Bip01 Spine2" ),
            #("Bip01 L Toe0", "Bip01 L Finger0" ),
            #("Bip01 L UpperArm", "Bip01 L Toe0" ),
            #("Bip01 Neck" , "Bip01 R Clavicle" ),
            #("Bip01 R Calf", "Bip01 Head" ),
            #("Bip01 R Clavicle", "Bip01 R Hand" ),
            #("Bip01 R Finger0" , "Bip01 L Calf" ),
            #("Bip01 R Finger01", "Bip01 L Foot" ),
            #("Bip01 R Foot", "Bip01 L Clavicle" ),
            #("Bip01 R Forearm", "Bip01 R Finger01" ),
            #("Bip01 R Hand", "Bip01 L Thigh" ),
            #("Bip01 R Thigh"   , "Bip01 L Finger01" ),
            #("Bip01 R Toe0"   , "Bip01 L UpperArm" ),
            #("Bip01 R UpperArm", "Bip01 R Finger0" ),
            #("Bip01 Spine2"   , "Bip01 Neck" )
        )
        
        /* build the correct bones: DOUBLE CHECK THIS, THIS IS WEIRD */
        local correct_bone_list = #()
        for b=1 to bone_list.count do
        (
            local currentBoneName = bone_list[b].name
            local mapped_bone_name = undefined
            for m=1 to bone_mapping.count do (
                if ( currentBoneName == bone_mapping[m][1] ) then (
                    
                    mapped_bone_name = bone_mapping[m][2]
                    
                    exit
                )
            )
            if ( mapped_bone_name == undefined  ) then
            (
                append correct_bone_list bone_list[b]
            )
            else (
                for n=1 to bone_list.count do (
                    if ( bone_list[n].name == mapped_bone_name ) then (
                        append correct_bone_list bone_list[n]
                        exit
                    )
                )
            )
        )
        
        /* apply skin modifier */
        local mshSkin = skin name:"Skin"
        max modify mode
        addmodifier theMesh mshSkin
        modPanel.setCurrentObject mshSkin
        
        /* add the bones to skin of the mesh */
        for b in bone_list do
        --for b in correct_bone_list do
            if b.name != "ROOT" then
                skinOps.addBone mshSkin b.bone_ref 0
        update theMesh
        max views redraw

        /* apply the weights */
        for v=1 to theMesh.verts.count do
            skinOps.ReplaceVertexWeights mshSkin v skin_data.bone_indices[v]  skin_data.bone_weights[v]

        update theMesh

    )
    function BuildMeshes geometry_list bone_list=
    (
        local idName = "Object"
        if ( bone_list != undefined ) then
        (
            for b in bone_list do 
                if b.Flags == 2 then idName = b.name
            
            if idName == "ROOT" then 
                idName = bone_list[2].name
        )
        format "Building object '%'\n" idName
        local layer = createLayer idName
        local index = 0
        
        for geo in geometry_list do
        (
            index += 1
            
            local WireColor = Color (random 0 128) (random 0 255) (random 0 128)
            if debug then wirecolor = color 86 86 86
            local m = geo.meshObj
            
            /* build the material */
            local uniqueMatIds = #()
            for i=1 to m.matIds.Count do appendIfUnique uniqueMatIds m.matIds[i]

            local mm = MultiMaterial numsubs:geo.materials.Count
            
            for i=1 to geo.materials.Count do
                mm[i] = geo.materials[i].MaterialRef
            
            /* build the mesh */
            local meshName = idName + "_" + (index as string )
            local theMesh = undefined
            
            if ( m.uvs.count > 0 ) then 
                theMesh = mesh vertices:m.verts vnorms:m.norms name:meshName faces:m.faces tverts:m.uvs
            else
                theMesh = mesh vertices:m.verts vnorms:m.norms name:meshName faces:m.faces
            
            theMesh.WireColor = wireColor
            layer.AddNode theMesh
            
            /* apply texture coordinates correctly */
            if ( m.uvs.count > 0 ) then (
                buildTVFaces theMesh false
                for i = 1 to m.faces.count do setTVFace theMesh i m.faces[i]
                update theMesh
            )
            
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

            --ApplySkinning theMesh bone_list geo.skinData 
            
            rotate (getNodeByname "Root") (angleaxis -90 [1,0,0])
            

        )
    )
    function ImportDFF file=
    (
        local stream = fOpen file "rb"
        local streamSize = GetStreamSize stream
        
        local dff_chunks = #()
        while ( ftell stream < streamSize ) do
        (
            local chunk = ReadChunkHeader stream
            SkipBytes stream chunk.Size
            append dff_chunks chunk
        )

        if ( dff_chunks.count > 1 ) then 
            format "Multiple dff models found: %\n" dff_chunks.count

        for dff in dff_chunks do
        (
            try( local chunks = ReadChunks stream dff ) catch()

            local bone_list = undefined
            local geometry_list = undefined
            for chunk in chunks do
            (
              if ( chunk.Id == 14 ) then try( bone_list = ReadBones stream chunk ) catch( format "Error occured in readbones\n" )
              if ( chunk.Id == 26 ) then try( geometry_list = ReadGeometry stream chunk ) catch( format "Error occured in readGeometry\n" )
            )

            if ( bone_list != undefined ) then BuildBones bone_list
            if ( geometry_list != undefined ) then BuildMeshes geometry_list bone_list
            
        )
        fClose stream
        CleanUpLayers()
        GC()
        FreeSceneBitmaps()
        ClearUndoBuffer()
    )
        
    if debug then 
        file = @"G:\Game Dev\3D Models\Game Models\Rockstar Games\Manhunt\DFF\bun_pc.dff"
    else
        file = getOpenFileName \
			caption:"Manhunt" \
			types:"Supported Files|*.dff*|Manhunt Models(*.dff)|*.dff*|All Files|*.*" \
			historyCategory:"ManhuntPresets"

    if (file != undefined ) then ImportDFF file
)