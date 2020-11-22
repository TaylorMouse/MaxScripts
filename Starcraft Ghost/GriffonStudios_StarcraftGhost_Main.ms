/* 
    .SYNOPSYS
        (c) 2020 Griffon Studios by Taylor Mouse
    
    .DESCRIPTION
        Imports Starcraft Ghost (xbox game) models ( .nod, .noc )
    
    .VERSIONING
        v0.09 - Reading nad files
        v0.08 - testing different models & bugfixing
        v0.07 - apply bone Id's and vertex weights to the model
        v0.06 - read bone Id's and vertex weights
        v0.05 - fixed issues with the faces
        v0.04 - build the mesh and apply materials
        v0.03 - build the bones
        v0.02 - find the materials through the shaders and textures
        v0.01 - read the nod file

*/
filein "GriffonStudios_HelperScripts.ms"

global ghostModel
global ghostConvertMaterialToSC2 = true
global ghostShaderList 
global ghostStartAnimationFrame = 10.0

struct Starcraft_Ghost_Main
(
    /* Find stuff */
    
    function FindNadFile file nadFile=
    (
        local filePath = getFileNamePath file
        local fileName = tolower ( getFileNameFile nadFile )
        local rootPath = substring file 1 (findString filePath @"\3D\")
        
        local nadFiles = GriffonStudios_Helpers.FindFiles rootPath "*.nad"
        
        local animFile = undefined
        
        for nad in nadFiles do
        (
            local nadFileName = tolower ( getFilenameFile nad )
            if ( nadFileName == fileName ) then 
            (
                --format "Animation file found '%.nad'\n" fileName
                animFile = nad
                exit
            )
            
        )
        return animFile
        
    ),
    function FindMotionFile file=
    (
        local filePath = getFileNamePath file
        local fileName = tolower ( getFileNameFile file )
        local rootPath = substring file 1 (findString filePath @"\3D\")
        
        local motionFiles = GriffonStudios_Helpers.FindFiles rootPath "*.nms"
        
        local motionFile = undefined
        
        for nms in motionFiles do
        (
           -- format "Checking %\n" nms
            local nmsFileName = tolower ( getFilenameFile nms )
            if ( nmsFileName == fileName ) then 
            (
                format "Motion file found '%.nms'\n" fileName
                motionFile = nms
                exit
            )
            
        )
        return motionFile
    ),
    function FindMaterial nod materials=
    (
        struct ghost_shader   ( name, shader, texture, sound, surfflags, envmap, meshtype, sightForce, refMaterial)
        
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
                    mats[i] = ghostShader
                    exit
                )
            )
           
            if ( mats[i] == undefined ) then 
            (
                for textureShader in materials.textures do
                (
                    texture = textureShader.Texture
                    if ( ( findstring ( tolower texture ) textureName ) != undefined ) then
                    (
                        mats[i] = textureShader
                        exit
                    )
                )
            )
            
            
            if ( mats[i] == undefined ) then 
            (
                -- additional searching
                local newShaderName = substituteString shaderName "_gloss" ""
                
                if ( newShaderName == shaderName ) then newShaderName = substituteString shaderName "_glo" ""
                
                for ghostShader in materials.shaders do
                (
                    if ( ( tolower ghostShader.name ) == newShaderName ) then
                    (
                        mats[i] = ghostShader
                        exit
                    )
                )
                if ( mats[i] == undefined ) then 
                (
                    for textureShader in materials.textures do
                    (
                        texture = textureShader.Texture
                        if ( ( findstring ( tolower texture ) newShaderName ) != undefined ) then
                        (
                            mats[i] = textureShader
                            exit
                        )
                    )
                )
                if ( mats[i] == undefined ) then 
                (
                    mats[i] = ghost_shader ()
                    mats[i].name = shaderName
                )
            )
            
        )
        
        return mats
    ),
    function FindTextureFile textureName=
    (
        --format "Looking for %\n" textureName
        local fileFound = undefined
        if (textureName != undefined ) then 
        (
            for f in ghostShaderList.textures do
            (
                if ( (findString f.texture textureName ) != undefined ) then 
                (
                    --format "File found\n" 
                    fileFound= f.texture
                    exit 
                )
            )
        )
        return fileFound
        
    ),
    
    /* Read stuff */
    
    function ReadMotionFile nmsFile=
    (
       struct ghost_motion 
            ( OverlayName, AnimName, animFile, lowPriority, noLoop, variable, fidget, endPause, endTag, noFadeIn, noFadeOut, noFrameReset, highPriority )
        
        local motionStream = openfile nmsFile
        local l = readLine motionStream
        
        local motions = #()
        local currentOverlayName = "Standard"
        
        Format "Parsing motion file '%.nms'\n" ( getFileNameFile nmsFile )
        
        while ( ( eof motionStream ) == false ) do
        (
            if ( eof motionStream ) then exit
            
            l = readLine motionStream
            
            if ( l.count == 0 ) then continue
            if ( l[1] == ";" ) then continue
            
            local parts = filterString l "\t, "
            
            
            if ( parts.count < 2 ) then continue --> for the moment do nothing
            if ( parts[1] == "numOverlays" ) then continue
            
            if ( parts[1] == "overlay" ) then
            (
                currentOverlayName = parts[2]
                continue
            )
            
            local motion = ghost_motion noLoop:false lowPriority:false variable:false fidget:false endPause:false endTag:false noFadeIn:false noFrameReset:false noFadeOut:false highPriority:false
            motion.overlayName = currentOverlayName
            motion.animName = parts[1]
            motion.animFile = Starcraft_Ghost_Main.FindNadFile nmsFile parts[2]
            
            for i=3 to parts.count do
            (
                if ( parts[i] == "noloop" ) then motion.noLoop = true
                if ( parts[i] == "lowpriority" ) then motion.lowPriority = true
                if ( parts[i] == "variable" ) then motion.variable = true
                if ( parts[i] == "fidget" ) then motion.fidget = true
                if ( parts[i] == "endpause" ) then motion.endPause = true
                if ( parts[i] == "endtag" ) then motion.endTag = true
                if ( parts[i] == "nofadein" ) then motion.noFadeIn = true
                if ( parts[i] == "noframereset" ) then motion.noFrameReset = true
            )
            
            --motion.nad =  Starcraft_Ghost_Main.ReadNadFile motion.animFile
            --format "%\n" motion
            append motions motion
            
        )
        close motionStream
        
        
        
        
        return motions
    ),
    function ReadGhostBone stream=
    (
        struct Ghost_bone ( id, parentId, tagId, unk1, unk2, identityMatrix, translation, invTranslation, boneRef )
        -- 64 bytes
        
        local gb = Ghost_bone()
        
        
        local row4 = [readFloat stream, readFloat stream, readFloat stream] * 100.0 
        local row1 = [readFloat stream, readFloat stream, readFloat stream] 
        local row2 = [readFloat stream, readFloat stream, readFloat stream] 
        local row3 = [readFloat stream, readFloat stream, readFloat stream]
        
        gb.identityMatrix = matrix3 row1 row2 row3 row4
        gb.invTranslation = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        gb.unk1 = readByte stream as integer
        gb.unk2 = readByte stream as integer
        gb.parentId = ( readByte stream as integer ) + 1
        gb.tagId    = readByte stream as integer
        
        return gb
    ),
    function ReadNadFile file=
    (
        
        struct nad_header ( version, numBoneTracks, flags, duration, boneTracks, numTags, tags )
        struct nad_bone_track ( numKeys, boneNum, trackType, keys )
        struct nad_tag ( frameNum, tagType )
        struct nad_keyFrame ( frame, values, CFactor, BFactor, AFactor )
        
        local stream = fOpen file "rb"
        
        local nad = nad_header version:(readLong stream #unsigned) \
                               numBoneTracks:(readLong stream #unsigned) \
                               flags:(readLong stream #unsigned) \
                               duration:(readFloat stream) --> duration in frames

        nad.boneTracks = #()
        for i=1 to nad.numBoneTracks do
        (
            local bt = nad_bone_track numKeys:(readLong stream #unsigned) \
                                      boneNum:(readLong stream #unsigned) \
                                      trackType:(readLong stream #unsigned) -- // 0 = rotation, 1 = translate, 2 = scale
            
            bt.keys = #()
            for k=1 to bt.numKeys do
            (
                local bk = nad_keyFrame()
                
                bk.frame = readFloat stream
                
                bk.values  = [readFloat stream, readFloat stream, readFloat stream]
                bk.CFactor = [readFloat stream, readFloat stream, readFloat stream]
                bk.BFactor = [readFloat stream, readFloat stream, readFloat stream]
                bk.AFactor = [readFloat stream, readFloat stream, readFloat stream]
                
                append bt.keys bk
            )
            append nad.boneTracks bt
        )
        
        nad.numTags = readLong stream
        nad.tags = #()
        for j=1 to nad.numTags do
        (
            local t = nad_tag()
            t.frameNum = readFloat stream
            t.tagType = readFloat stream

            append nad.tags t
        )
        
        fclose stream
        
        return nad
    ),
    function ReadMaterials file=
    (
        --format "Looking for shaders and textures\n"
        
        struct ghost_material ( shaders, textures )
        struct ghost_shader   ( name, shader, texture, sound, surfflags, envmap, meshtype, sightForce, refMaterial)
        
        local filePath = getFilenamePath file
        local rootPath = substring file 1 (findString filePath @"\3D\")
        
        local gmat = ghost_material ()
        
        gmat.textures = #()
        gmat.shaders = #()
        
        if ( doesdirectoryexist rootPath ) then
        (
            local textureFiles = GriffonStudios_Helpers.FindFiles rootPath "*.dds"
            
            for f in textureFiles do
            (
                local gs = ghost_shader()
                gs.name = getfilenamefile f
                gs.texture = f
                append gmat.textures gs
            )
            
            
            --format "- % textures (.dds) found\n" gmat.textures.count
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
            --format "- % shaders found\n" gmat.shaders.count
        )
        
        return gmat
    ),
    function ReadNod file=
    (
        format "Reading 3D model file '%'\n" (filenameFromPath file)
        struct ghost_nod ( name, version, nShaders, nBones, nVertGrp, nMeshGrp, flags, bbox, vertexGroups, vertexGroupOffsets, meshGroups, nIndices, indices, lodStarts, lodCount, shaderNames, boneList, materials, motions )
        struct ghost_mesh_grp ( id, matId, vertexCount, flags, nBlendShapes, blendGroup, boneList, nBones, vertexGroupId, lods, faces, vertexStart, refMesh, refWeights, refBoneIds )
        struct ghost_vert_grp ( vertexCount, vertexType, vertices, normals, uvs, vertexOffset, boneIds, vertexWeights )
        struct ghost_mesh_lod ( lod, stripStart, stripCount, listStart, listCount, vertexCount )
        
        local gshelp = GriffonStudios_Helpers()
        
        local stream = fOpen file "rb"

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
            local gb = Starcraft_Ghost_Main.ReadGhostBone stream
            gb.id = i
            append nod.boneList gb

        )

        for g=1 to nod.nVertGrp do
        (
            local vg = nod.vertexGroups[g]
            vg.vertices = #()
            vg.normals  = #()
            vg.uvs      = #()
            vg.boneIds  = #()
            vg.vertexWeights = #()
            
            --format "Vertex Type %\n" vg.vertexType
            for i=1 to vg.vertexCount do
            (
                append vg.vertices ( gshelp.ReadVector3 stream 100.0 )
                append vg.normals  ( gshelp.ReadVector3 stream 1.0)
                append vg.uvs      ( gshelp.ReadUV3 stream )
            
                if ( vg.vertexType == 0 ) then 
                (
                    append vg.boneIds ( #(1) )
                    append vg.vertexWeights ( #(1.0) )
                )
                
                if ( vg.vertexType == 1 or vg.vertexType == 4 ) then
                (
                    append vg.boneIds ( #(readLong stream + 1) )
                    append vg.vertexWeights ( #(1.0) )
                    
                )
                
                if ( vg.vertexType == 2 or vg.vertexType == 5 ) then
                (
                    local weights = #()
                    
                    for w=1 to 3 do 
                        append weights ( readfloat stream )
                        
                    append vg.vertexWeights weights
                    
                    local boneIndices = #()
                    
                    for b=1 to 4 do
                        append boneIndices ( (readByte stream #unsigned ) as integer + 1 )
                    
                    append vg.boneIds boneIndices
                )

                
            )
            if ( vg.vertexType >= 3 ) then gshelp.SkipBytes stream ( vg.vertexCount * 36 )

           
            -- clean up for max
            for v=1 to vg.vertexCount do
            (
                local weights = #()
                local boneIds = #()
                for w=1 to vg.vertexWeights[v].count do
                (
                    if ( vg.vertexWeights[v][w] > 0.0 ) then
                    (
                        append weights vg.vertexWeights[v][w]
                        append boneIds vg.boneIds[v][w]
                    )
                )    
                vg.vertexWeights[v] = weights
                vg.boneIds[v] = boneIds
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
                append mg.boneList ((readByte stream #unsigned as integer) + 1 )
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

        /* Materials and shaders */
        ghostShaderList = Starcraft_Ghost_Main.ReadMaterials file
        nod.materials = Starcraft_Ghost_Main.FindMaterial nod ghostShaderList
        
        /* motion and animations */
        motionFile = Starcraft_Ghost_Main.FindMotionFile file
        if ( motionFile != undefined ) then nod.motions = Starcraft_Ghost_Main.ReadMotionFile motionFile
        
        return nod
    ),
    
    /* Build stuff */
    
    function BuildMaterials nod=
    (

        for m=1 to nod.materials.count do
        (
            local mat = nod.materials[m]
            local matRef = StandardMaterial()

            showTextureMap matRef true

            if (mat != undefined ) then 
            (
                matRef.name = mat.name
                
                local textureFile = Starcraft_Ghost_Main.FindTextureFile mat.texture
                local envTexture  = Starcraft_Ghost_Main.FindTextureFile mat.envMap
                
                if ( textureFile != undefined ) then
                (
                    matRef.diffuseMap = Bitmaptexture fileName:textureFile
                    
                    matRef.opacityMap = Bitmaptexture fileName:textureFile
                    matRef.opacityMap.alphaSource = 2
                    matRef.opacityMapEnable = off --> to be set manully if required !
                )
                if ( envTexture != undefined )  then 
                (
                    matRef.reflectionMap = Bitmaptexture fileName:envTexture

                )
                
            )
            else
            (
                matRef.name = nod.shaderNames[m]
            )
            mat.refMaterial = matRef
            meditMaterials[m] = matRef
        )
    ),
    function BuildGhostBones nod=
    (
        local boneList = nod.BoneList
        local boneLayer = GriffonStudios_Helpers.CreateLayer "Bones"
        
        format "Building Bones\n"
        -- create the bones
        for b in boneList do
        (
            local bName = "bone_" + (b.id as string)
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
                
            aBone.Name = bName
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.Pos.controller      = TCB_position ()
            aBone.rotation.controller = TCB_rotation ()
            aBone.setBoneEnable false 0
            
            b.boneRef = aBone
            
            boneLayer.AddNode aBone
        )
        
        -- link the parents
        for b in boneList do
        (
            if (b.parentID > 0) then
            (
                b.boneRef.Parent = boneList[b.parentID].boneRef
            )
        )   

        for b in boneList do
        (
            if (b.parentID > 0) then
            (
                b.boneRef.Rotation = b.identityMatrix.rotationPart
                b.boneRef.pos = b.identityMatrix.translationpart + b.boneRef.parent.pos
            )
            else
                b.boneRef.Pos = b.identityMatrix.translationpart
        ) 


        
    ),
    function BuildMesh nod=
    (
        format "Building Materials\n"
        Starcraft_Ghost_Main.BuildMaterials nod
        
        format "Building 3D Model\n"
        local help = GriffonStudios_Helpers()
        
        local bboxLayer = help.CreateLayer "Bounding Box"
        local meshLayer = help.CreateLayer "Unit"
        
        /* build bounding box */
        
        --local bbox = help.BuildBoundingBox nod.bbox
        --bboxLayer.AddNode bbox
        
        
        /* build the correct set of faces */
        local meshId = 0
        for mg in nod.meshGroups do
        (
            meshId = meshId + 1
            local name = nod.name + "_" + (meshId as string)
            
            local mat = nod.materials[mg.matId+1].refMaterial

            format "Building Mesh '%'\n" name
            for l in mg.lods do
            (
                if (l.lod == 0 ) then 
                (
                    --// get the vertices, normals, uvs, weights and boneIds
                    local vg = nod.vertexGroups[mg.vertexGroupId]
                    local vStart = mg.vertexStart
                    
                    local verts = #()
                    local norms = #()
                    local uvs = #()
                    local weights = #()
                    local boneIds = #()
                    
                    for v=vStart+1 to vStart + l.vertexCount do
                    (
                        append verts vg.vertices[v]
                        append norms vg.normals[v]
                        append uvs   vg.uvs[v]
                        append weights vg.vertexWeights[v] --> corrected weights 
                        append boneIds vg.boneIds[v] --> correctedBoneIds
                        
                    )


                    
                    --// get the faces
                    local backfaceCullingIssue = 0
                    local faces = #()
                    
                    if( l.stripCount > 0 ) then
                    (
                        --format " - Strip % Indices to process: %\n" meshId l.stripCount 
                    
                        for i=0  to l.stripCount - 3 do
                        (
                            local s = l.stripStart
                            local a = nod.indices[s + i+1]
                            local b = nod.indices[s + i+2]
                            local c = nod.indices[s + i+3]
                            
                            
                            backfaceCullingIssue = 1 - backfaceCullingIssue
                            if( a!=b and a!=c and b!=c ) then 
                            (
                                if ( backfaceCullingIssue == 1 ) then
                                    append faces [a,b,c]
                                else
                                    append faces [a,c,b] 
                            )

                        )
                    )
                                       
                    if( l.listCount > 0 ) then 
                    (
                        --format " - List  % Indices to process: %\n" meshId l.listCount 
                        for i=0  to l.listcount / 3  do
                        (
                            local s = l.ListStart + 1 
                            local a = nod.indices[s + i*3]
                            local b = nod.indices[s + i*3+1]
                            local c = nod.indices[s + i*3+2]
                            
                            try ( 
                                append faces [a,b,c]
                            )
                            catch (
                                format "ERROR - Unable to add face % % % \n" a b c
                            )
                            
                        )
                    )
                    
                    /*
                        Create the mesh
                    
                    */
                    
                    
                    try 
                    (
                        theMesh = mesh name:name vertices:verts faces:faces vnorms:norms tverts:uvs
                        
                        local wirecolor = color (random 100 150) (random 100 150) (random 50 250)
                
                        theMesh.WireColor = wireColor
                        
                        if( uvs.count > 0 ) then 
                        (
                            try (
                                buildTVFaces theMesh false
                                for i = 1 to faces.count do
                                ( setTVFace theMesh i faces[i] )
                            )
                            catch()
                        )
                        
                        theMesh.Material = mat
                        meshLayer.AddNode theMesh
                        mg.refMesh = theMesh
                        mg.refWeights = weights
                        mg.refBoneIds = boneIds
                        
                    )
                    catch
                    (
                        format "ERROR - Unable to create Mesh '%'\n" name
                        
                    )

                )
                
            )
            max views redraw
        )
        
    ),
    function ApplySkin nod=
    (
        Format "Applying Vertex Weights\n"
        --disableSceneRedraw()
        
        for mg in nod.meshGroups do
        (
            if ( mg.refMesh == undefined ) then continue
            --// apply skin modifier to the mesh
            local skinMod = skin name:"Skin"
            max modify mode
            addModifier mg.refMesh skinMod
            modPanel.setCurrentObject skinMod
            
            -- //  add the bones to the mesh
            for i=1 to mg.nBones do
            (
                if ( mg.boneList[i] != 205) then  --// bone 205 is not a real bone
                (
                    
                    local b = nod.boneList[mg.boneList[i]].boneRef
                    if ( b != undefined ) then
                    (
                        if ( i == mg.nBones ) then 
                            skinOps.addBone skinMod b 1
                        else
                            skinOps.addBone skinMod b 0
                    )
                )
            )
            
            --// apply vertex weights
            for v=1 to mg.refWeights.count do 
            (
                local weights = mg.refWeights[v]
                local boneIds = mg.refBoneIds[v]
                skinOps.ReplaceVertexWeights skinMod v boneIds weights
            )
            update mg.refMesh
        )
        enableSceneRedraw()
    ),
    function CreateSequences nod=
    (
        
        local theAnimTrack = undefined
        local nNoteTracks = numNoteTracks rootNode
        
        if(  nNoteTracks > 0 ) then
        (
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode (getNoteTrack rootNode 1)
        )
        
        if( numNoteTracks rootNode == 0 ) then
        (
            local animTrack1 = notetrack "AnimTrack"
            addNoteTrack rootNode animTrack1
        )
        
        local theAnimTrack = getNoteTrack rootNode 1
        local startFrame = ghostStartAnimationFrame as integer
        
       
        for motion in nod.motions do
        (
            local uniqueMotionName = motion.overlayName + " - " + motion.animName
            
            local startNote = AddNewNoteKey theAnimTrack startFrame
            local endFrame = (startFrame + motion.nad.duration) as integer
            local endNote = AddNewNoteKey theAnimTrack endFrame
            
            local rarity = 100
            local pri = 0
             
            if ( motion.highPriority == true ) then pri= 100
            
            local movementSpeed = 0
            if (motion.noFrameReset == true ) then movementSpeed = 300
            
            local val = uniqueMotionName + "\r\n"
                  val += "rarity = " 	 + (rarity as string)    + "\r\n"
                  val += "moveSpeed = "  + (movementSpeed as string) + "\r\n"
                  val += "nonLoop = " 	 + (motion.NoLoop as string)    + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\n"
                  val += "defaultPriority = " + (pri as string )

           
            startNote.Value = val
            endNote.Value = val

            --format "% (% - %)\n" theAnimTrack.name uniqueMotionName startFrame endFrame
            
            startFrame = (startFrame + motion.nad.duration + 10.0) as integer
        )
        
    ),
    function AddSequences animName startFrame endFrame=
    (
        
        local theAnimTrack = undefined
        local nNoteTracks = numNoteTracks rootNode
        
        if( numNoteTracks rootNode == 0 ) then
        (
            local animTrack1 = notetrack "AnimTrack"
            addNoteTrack rootNode animTrack1
        )
        
        local theAnimTrack = getNoteTrack rootNode 1
        local startNote = AddNewNoteKey theAnimTrack startFrame
        local endNote = AddNewNoteKey theAnimTrack endFrame
        
        local rarity = 100
        local pri = 0
        local movementSpeed = 0
        
        
        local val = animName + "\r\n"
              val += "rarity = " 	 + (rarity as string)    + "\r\n"
              val += "moveSpeed = "  + (movementSpeed as string) + "\r\n"
              val += "nonLoop = " 	 + (true as string)    + "\r\n"
              val += "default_Anim = false\r\nsub_anim = false\r\n"
              val += "defaultPriority = " + (pri as string )

       
        startNote.Value = val
        endNote.Value = val

        format "% (% - %)\n" theAnimTrack.name animName startFrame endFrame
        
    ),
    function ApplyMotion nod index=
    (
        local animFile = nod.motions[index].animFile
        
        local nad = Starcraft_Ghost_Main.ReadNadFile animFile
        local uniqueMotionName = getfilenamefile animFile
        
        local startFrame = 10 --GriffonStudios_Helpers.FindLastKeyFrame() + 10
        local endFrame = startFrame + (nad.duration as integer)
        format "- % (% - %)\n" uniqueMotionName startFrame endFrame

        Starcraft_Ghost_Main.AddSequences uniqueMotionName startFrame endFrame
        
        for boneTrack in nad.boneTracks do
        (
            --local boneRef = getnodebyname nod.boneList[boneTrack.boneNum + 1].boneRef.name
            print boneTrack
            boneRef = nod.boneList[boneTrack.boneNum + 1].boneRef
            
            if ( boneRef == undefined ) then continue
            
            --local parentBone = boneRef.parent
            --boneRef.assumeSkinPose()
           -- for k=1 to boneTrack.numKeys do
           -- (

                if ( boneTrack.trackType==0 ) then --// 0 = rotation, 1 = translate, 2 = scale
                (
--                     local dr = dummy name:"DummyRotationController"
--                     dr.rotation.controller = boneRef.rotation.controller
--                     local q0 = dr.transform
--                     
                    for k=1 to boneTrack.keys.count do
                    (
                        local key = boneTrack.keys[k]
--                         at time 0
--                             q0 = boneRef.transform
                        
                        
                        
                        
                        rot = eulerangles key.values[1] key.values[2] key.values[3]
                        
                        if k > 1 then
                        (
                            
                            local prevKey = boneTrack.keys[k-1]
                            local values = key.values - prevKey.values
                            --rot = eulerangles values[1] values[2] values[3]
                            
                        )
                        
                        format "Bone %   frame % rotate %\n" boneRef.Name (key.frame + startFrame) rot
                        
                        with animate on
                            at time (key.frame + startFrame)
--                                 in coordsys q0
                                    rotate boneRef rot
--                         with animate on 
--                             at time (key.frame + startFrame)
                                --in coordsys q0 dr.rotation = q
                                
                    )
                    
--                     with animate on boneRef.rotation.controller = copy dr.rotation.controller
                        
--                     delete dr
                )
                if ( boneTrack.trackType==1 ) then --// 0 = rotation, 1 = translate, 2 = scale
                (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = boneRef.position.controller
                    local p0 = dp.transform
                    
                    for key in boneTrack.keys do
                    (
                        with animate on 
                            at time (key.frame + startFrame)
                                boneRef.pos = key.values
                                --in coordsys p0 dp.pos = key.values
                    )
                    with animate on boneRef.position.controller = copy dp.position.controller
                        
                    delete dp
                )
                
            --)
        )
        return nad
    ),
    /*  Main Method */
    function ImportModel file=
    (
        local _ghost = Starcraft_Ghost_Main()
        
        /* read in all data for this model */
        local nod = _ghost.ReadNod file
        
        --//  debugging only
        ghostModel = nod
        
        
        _ghost.BuildMesh nod
        _ghost.BuildGhostBones nod
        _ghost.ApplySkin nod
        --_ghost.CreateSequences nod
        --_ghost.ApplyMotions nod
        
        gc()
        
        format "Import Done\n"
        
        return nod
    )
)
/*
    Testing only
*/
clearListener()

file = @"F:\Blizzard\Starcraft Ghost\StarCraft Ghost Xbox\3D\Models\missileturret_01.nod"

nod = Starcraft_Ghost_Main.ImportModel file

for motion in nod.motions do
    print motion.animName

GriffonStudios_Helpers.ResetNoteTracks() 
--nad = Starcraft_Ghost_Main.ApplyMotion nod 1
--nod.boneList




enableSceneRedraw()