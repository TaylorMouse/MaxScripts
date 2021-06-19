/*
    .COPYRIGHT 
    | (c) 2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse
    
    .DESCRIPTION
    | Warcraft III Reforged mdx exporter 
    
    .PROGRESS
	| 0.23 - Speed up the process to calculate the bounding boxes, fixed a bug for the MATS to export with always the same texture ID
    |        Copy all the textures used into the export folder for easy backup and selection
    | 0.22 - Added functionality for using the standard black32.dds and EnvironmentMap.dds
    | 0.21 - EUREKA first complex correct export is done!
    | 0.20 - translation issue under investigation, seems like child bones are not correctly positioning
    | 0.19 - fixed a vertex weight issue
    | 0.18 - finally fixed the rotation and translation animation !!
    | 0.17 - fixing the translation and rotation animation... still working on it...
    | 0.16 - fixed the two sided texture flag, added the alpha animation for the texture, added emssive map, does not seem to animate (yet) :/
    | 0.15 - fixed an issue with the texture replacable id
    | 0.14 - fixed rotation and translation of the overall model, still 90� off in the vertical axis :/
    | 0.13 - fixed multibone export, however, still a overall rotation issue
    | 0.12 - multiple bones export work but the rotation is not correct yet, and fixed an export issue when the timetracker is not at frame 0
    | 0.11 - One bone seems to animate ok, bone hierarchy and animation is still off.
    | 0.10 - Scale, position and rotation seem to animate, however wrong weird initial rotation, needs to be fixed
    | 0.09 - Linetype was wrong, fixed that, now it animates in the world editor :D
    | 0.08 - Animation seqs problems, they require ( always ) to have a number at the end of the name
    | 0.07 - Completely redid the GEOS block issues with mesh vertice and teture vertices
    | 0.06 - Writing bones and its animatons
    | 0.05 - Getting the bones and the KGTR, KGRT and KGSC animations
    | 0.04 - Writing out the GEOS with LOD's
    | 0.03 - Getting the GEOS data
    | 0.02 - Writes MDLX, VERS, MODL, SEQS, MTLS, LAYS, KMTA, TEXS
    | 0.01 - Main setup

    
*/
GLOBAL WC3_DEBUG = false
GLOBAL TEXTURE_PATH = "war3mapImported/" 
GLOBAL USE_BLACK32 = false
GLOBAL USE_ENVIRONMENT_MAP = false

STRUCT GriffonStudios_Helper_Functions
(
    
    /* Keys in a controller return a weird uint64 this is converted here */
    function TimeToInt theTime=
    (
        local strTime = theTime as string
        local intTime = ( substring strTime 1 (strTime.count - 1) ) as integer
        return intTime
    ),
    function GetBONE = 
    (
        struct WC3Bones ( totalSize = 0, WC3RefBoneList = #())
        struct WC3RefBone ( Size = 96, Name, Id, ParentId = -1, Flag = 0x100, Animations = #(), BoneRef, geosetId = -1, geosetAnimationId = -1 )
        
        local help = GriffonStudios_Helper_Functions()
        local boneList = help.GetBones()

        /* get a list of all the bones */
        local allBones = WC3Bones()
            
        for i=1 to boneList.count do
        (
            local b = WC3RefBone Id:(i-1) Name:boneList[i].Name boneRef:boneList[i]
            append allBones.WC3RefBoneList b
        )
        
        /* build the hierarchy */
        for i=1 to allBones.WC3RefBoneList.Count do
        (
            local b = allBones.WC3RefBoneList[i]
            
            if( b.boneRef.Parent != undefined ) then
            (
                for x=1 to allBones.WC3RefBoneList.Count do
                (
                    if( x != i ) then 
                    (
                        if ( allBones.WC3RefBoneList[x].BoneRef.Name == b.boneRef.Parent.Name ) then 
                        (
                            b.ParentId = x-1
                            exit
                        )
                    )
                )
            )
        )

        /* get the animations */
        help.GetKGTR allBones.WC3RefBoneList
        help.GetKGRT allBones.WC3RefBoneList
        help.GetKGSC allBones.WC3RefBoneList
        
        /* calculate total size */
        for b in allBones.WC3RefBoneList do
        (
            allBones.totalSize += b.size + 8
            
            for anim in b.Animations do
                if ( anim.AnimBlock.count > 0 ) then 
                (
                    b.Size += anim.size
                    allBones.totalSize += anim.size
                )
        )

        return allBones
    ),
    /* Get the KGTR ( Key Global Transformation ) of the bones */
    function GetKGTR wc3Bones=
    (
        local help = GriffonStudios_Helper_Functions()
        struct WC3Anim ( Size = 16, nbrKeys, Type = "KGTR", LineType=1, ParentId = -1, AnimBlock = #() )
        struct AnimKeyValues ( Key, Val )

        for i=1 to wc3Bones.Count do
        (
            local kg = WC3Anim()
            
            local b = wc3Bones[i].BoneRef
            
            b.assumeSkinPose()
            
            local basePos = b.pos
            
            if ( b.parent != undefined ) then
                in coordsys parent 
                    basePos = b.pos
            
            kg.nbrKeys = numkeys b.pos.controller 
            kg.Size += kg.nbrKeys * 16
            for k=1 to kg.nbrKeys do
            (
                local kv = AnimKeyValues()
                kv.key =  help.TimeToInt ( getKeyTime b.pos.controller k )
                
                at time kv.key 
                (
                    kv.val= b.pos - basepos
                    if ( b.parent != undefined ) then
                        in coordsys parent
                            kv.val= b.pos - basepos
                )
                append kg.AnimBlock kv
            )
            
            append wc3Bones[i].Animations kg
        )

    ),
    /* Get the KGRT ( Key Global Rotation ) of the bones */
    function GetKGRT wc3Bones=
    (
        local help = GriffonStudios_Helper_Functions()
        struct WC3Anim ( Size = 16, nbrKeys, Type = "KGRT", LineType=1, ParentId = -1, AnimBlock = #() )
        struct AnimKeyValues ( Key, Val )

        for i=1 to wc3Bones.Count do
        (
            local kg = WC3Anim()
            
            local b = wc3Bones[i].BoneRef

            kg.nbrKeys = numkeys b.rotation.controller 
            kg.Size += kg.nbrKeys * 20
            
            for k=1 to kg.nbrKeys do
            (
                local kv = AnimKeyValues()
                kv.key =  help.TimeToInt ( getKeyTime b.rotation.controller k )
                
                at time kv.key 
                (
                    kv.val = b.rotation
                    
                    if( b.parent != undefined ) then 
                        kv.val = b.rotation - b.parent.rotation

                )
                append kg.AnimBlock kv
            )
            
            append wc3Bones[i].Animations kg
        )
        
    ),
        /* Get the KGSC ( Key Global Scale ) of the bones */
    function GetKGSC wc3Bones=
    (
        local help = GriffonStudios_Helper_Functions()
        struct WC3Anim ( Size = 16, nbrKeys, Type = "KGSC", LineType=1, ParentId = -1, AnimBlock = #() )
        struct AnimKeyValues ( Key, Val )

        for i=1 to wc3Bones.Count do
        (
            local kg = WC3Anim()
            
            local b = wc3Bones[i].BoneRef
          --  kg.ParentId = wc3Bones[i].parentID
            kg.nbrKeys = numkeys b.scale.controller 
            kg.Size += kg.nbrKeys * 16
            for k=1 to kg.nbrKeys do
            (
                local kv = AnimKeyValues()
                kv.key =  help.TimeToInt ( getKeyTime b.scale.controller k )
                at time kv.key 
                    kv.val = b.scale
                append kg.AnimBlock kv
            )
            
            append wc3Bones[i].Animations kg
        )
        
    ),
    /* Get mesh alpha animation  */
    function GetGEOA =
    (
        struct WC3RefGEOA ( size, id, alpha, flag, color, KGAO )
        
        local meshes =  GriffonStudios_Helper_Functions.GetMeshesToExport()
        
        local geoas = #()
        for i=1 to meshes.count do
        (
            local g = WC3RefGEOA()
            g.size = 28 --> alter this when there is a KGAO block
            g.id = i - 1
            g.alpha = 1.0
            g.flag = 0
            g.color = [1.0, 1.0, 1.0]
            
            append geoas g
        )
        
        return geoas
    ),
    /* Get the bounding box of a specific object */
    function GetBoundingBox =
    (
        local bbPoints = #()
        local bbMax = [0,0,0]
        local bbMin = [0,0,0]
        
        for obj in objects do
        (
            if ( classof obj == Editable_mesh ) then
            (
                --> TODO loop over every frame 
                
                if ( obj.Max.X > bbMax.X) then bbMax.X = obj.Max.X
                if ( obj.Max.Y > bbMax.Y) then bbMax.Y = obj.Max.Y
                if ( obj.Max.Z > bbMax.Z) then bbMax.Z = obj.Max.Z
                if ( obj.Min.X < bbMin.X) then bbMin.X = obj.Min.X
                if ( obj.Min.Y < bbMin.Y) then bbMin.Y = obj.Min.Y
                if ( obj.Min.Z < bbMin.Z) then bbMin.Z = obj.Min.Z
                
            )
        )
        append bbPoints bbMin 
        append bbPoints bbMax
        return bbPoints
    ),
    /* Calculate the volume of a bounding box in order to see which one is the biggest */
    function GetBoundingBoxVolume bbox=
    (
        local p1 = bbox[1]
        local p2 = bbox[2]
        
        local height = distance [p2.X,0,0] [p1.X,0,0]
        local width  = distance [p2.Y,0,0] [p1.Y,0,0]
        local depth  = distance [p2.Z,0,0] [p1.Z,0,0]
        
        local volume = height * width * depth
        
        return volume
    ),
    function GetAllAnimatedKeyFrames=
    (
        local uniqueKeys = #()
        for obj in objects do
        (
            
                --print obj.Name
                --if(obj.Name == "bone_turret" ) then 
                for i=1 to obj.numSubs do 
                (
                    if obj[i].Keys != undefined then
                    (
                        
                        for j=1 to obj[i].numsubs do
                        (
                            if obj[i][j].Keys != undefined then
                            (
                                --print obj[i][j].keys
                                for k in obj[i][j].keys do
                                (
                                    local strTime = k.time as string
                                    local iTime = substring strTime 1 (strTime.count - 1 ) as integer
                                    
                                    appendifunique uniqueKeys iTime
                                    
                                )
                            )
                        )
                    )
                    
                )
        )

        local sortedKeys = sort uniqueKeys   
        return sortedKeys
        
    ),

    /* Get the last key on the animation track from ALL objects */
    function FindLastKeyFrame =
    (
        local allKeys = GriffonStudios_Helper_Functions.GetAllAnimatedKeyFrames()
        
        return allKeys[allKeys.count]
    ),
    /* Get the biggest bounding box from all models between 2 frame, as animation changes these bounding boxes */
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        if ( WC3_DEBUG ) then Format "Calculating MODL Boundingbox between frame % and %\n" startFrame endFrame
        local allKeys = GriffonStudios_Helper_Functions.GetAllAnimatedKeyFrames()

        maxPoint = [0,0,0]
        minPoint = [0,0,0]

        for t in allKeys do
        (
            if ( t >= startFrame and t <= endFrame ) then 
            (
                at time t 
                for obj in objects do
                (
                    if ( classof obj == Editable_Mesh and obj.visibility == true ) then
                    (
                        local bbMax = obj.max
                        
                        for i=1 to 3 do
                            if( maxPoint[i] < bbMax[i] ) then maxPoint[i] = bbMax[i]
                        
                        local bbMin = obj.min
                        
                        for i=1 to 3 do
                            if( minPoint[i] > bbMin[i] ) then minPoint[i] = bbMin[i]
                        
                    )
                )
            )
        )
        local bbox = #()
        append bbox minPoint
        append bbox maxPoint
        
        --format "%\n" bbox

        return bbox
    ),
    /* Get the biggest bounding box for the whole set of animations keys, specifically needed for the MODL chunk */
    function GetMODLBoundingBox =
    (
        local help = GriffonStudios_Helper_Functions()
        local lastFrame = GriffonStudios_Helper_Functions.FindLastKeyFrame()

        if ( WC3_DEBUG ) then Format "Lastframe found at :%\n" lastFrame
        if ( lastFrame <= 1 ) then lastFrame = 10
        bbox = help.GetMODLBoundingBoxBetweenFrames 1 lastFrame
        
        return bbox
        
    ),
    /* get the list of animation sequences from the animation track */
    function GetSEQS =
    (
        struct WC3RefAnimSequence ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
        local size = 132

        local seqs = #()
        
        local wc3startFrame = 0
        local wc3EndFrame = 0
        
        if( numNoteTracks rootNode > 0 ) then 
        (
            local track = getNoteTrack rootNode 1
            local keys = track.Keys
            
            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local parts = filterstring note "\r\n"
                local s = WC3RefAnimSequence()
                
                s.name = parts[1]
                if ( WC3_DEBUG ) then  format " %\n" s.name
                local StartFrameStr = (getnotekeytime track i) as string 
                local EndFrameStr = (getnotekeytime track (i+1)) as string 
                
                StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
                EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
                
                local startFrame = StartFrameStr as integer
                local endFrame = EndFrameStr as integer
                
                
                s.BBox = GriffonStudios_Helper_Functions.GetMODLBoundingBoxBetweenFrames startFrame endFrame
                s.StartFrame =  startFrame * 1000 / 30 --wc3startFrame
                s.EndFrame =  EndFrame * 1000 / 30 -- wc3EndFrame
                
                --wc3startFrame = wc3EndFrame + 34
                s.Default = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                    
                    --if ( WC3_DEBUG ) then format " -  %: '%' \n" key value
                    
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.movementSpeed = value as float
                    if ( key == "nonLoop" ) then 
                    (
                        s.noLoop = value as float
                        if ( value == "true" ) then s.noLoop = 1
                        if ( value == "false" ) then s.noLoop = 0
                        
                    )       
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local startFrame = 1000 / 30
            local endFrame = 50 * 1000 / 30
            local seq = WC3RefAnimSequence Name:"Stand 1" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = GriffonStudios_Helper_Functions.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        return seqs
    ),
    /* Get the list of materials and their properties and the list of associated textures */
    function GetMTLS=
    (
        local help = GriffonStudios_Helper_Functions()
        local default_shader_name = "Shader_HD_DefaultUnit"
        
        struct _mtls ( TotalSize = 0, ShaderList = #(), TEXSList = #() )
        
        struct _shaders ( shaderSizeIncluded, priorityPlane, shaderName = default_shader_name, flag = 0, Layers = #() )
        struct _lays ( layerSizeIncluded, emissive_multiplier = 0.0, filterMode, shadingFlag, textureId, textureAnimationId, KMTA, KMTE )
        struct _kmta ( timeList = #(), valueList = #() )
        struct _kmte ( timeList = #(), valueList = #() )
        local mtls = _mtls()
        
        local uniqueMaterials = #()
        
        for obj in objects do
        (
            if ( obj.material != undefined and ( classof obj.material == WC3RefMaterial ) ) then
                appendIfUnique uniqueMaterials obj.material
        )
        /* get the textures, their ID is important in writing the MTLS */
        _TEXSList = GriffonStudios_Helper_Functions.GetUniqueTextures uniqueMaterials
        
        mtls.TEXSList = _TEXSList
        
        for mat in uniqueMaterials do
        (
            mtls.TotalSize = mtls.TotalSize + 92 --> 92 bytes -> priority plane, shadername, flag
            
            local s = _shaders()
            
            s.shaderSizeIncluded = 92 --> starter header size 
            s.priorityPlane = mat.priorityplane

            if ( mat.twosided ) then s.flag = 0x02
            
            s.shaderSizeIncluded = s.shaderSizeIncluded + 8 --> 4 byte characters LAYS, 4 bytes nbr layers
            mtls.TotalSize = mtls.TotalSize + 8 --> 4 byte characters LAYS, 4 bytes nbr layers

            -- LAYS
            for i=1 to 6 do
            (
                local lay = _lays()
                
                lay.layerSizeIncluded = 52
                s.shaderSizeIncluded = s.shaderSizeIncluded + 52
                mtls.TotalSize = mtls.TotalSize + 52
                lay.filterMode = mat.filterMode - 1
                lay.shadingFlag = 0
                
                lay.emissive_multiplier = mat.emissive_multiplier
                
                if( mat.twosided ) then lay.shadingFlag = 0x10
                
                if (i==1) then 
                (
                    lay.textureId = GriffonStudios_Helper_Functions.GetLayerTextureId2 _TEXSList mat.diffuse_map
                    
                    if ( mat.material_alpha.controller != undefined ) then 
                    (
                        --> KMTA, nbr Key Values, Linetype, parent Id -> extra 16 bytes
                        s.shaderSizeIncluded  = s.shaderSizeIncluded + 16
                        mtls.TotalSize        = mtls.TotalSize + 16
                        lay.layerSizeIncluded = lay.layerSizeIncluded + 16
                        
                        local kmta = _kmta()
                        
                        for key in mat.material_alpha.controller.keys do
                        (
                            s.shaderSizeIncluded  = s.shaderSizeIncluded + 8
                            mtls.TotalSize        = mtls.TotalSize + 8
                            lay.layerSizeIncluded = lay.layerSizeIncluded + 8
                            
                            local theTime = help.TimeToInt key.time
                            theTime = theTime * 1000 / 30
                            append kmta.timeList theTime
                            append kmta.valueList ( key.value / 100.0 )
                        )
                        
                        lay.KMTA = kmta
                    )
                    
                )
                if (i==2) then lay.textureId = GriffonStudios_Helper_Functions.GetLayerTextureId2 _TEXSList mat.normal_map
                if (i==3) then lay.textureId = GriffonStudios_Helper_Functions.GetLayerTextureId2 _TEXSList mat.orm_map
                if (i==4) then 
                (
                    lay.emissive_multiplier = mat.emissive_multiplier
                    lay.textureId = GriffonStudios_Helper_Functions.GetLayerTextureId2 _TEXSList mat.emissive_map
                    
                    if ( mat.emissive_alpha.controller != undefined ) then 
                    (
                        --> KMTE, nbr Key Values, Linetype, parent Id -> extra 16 bytes
                        s.shaderSizeIncluded  = s.shaderSizeIncluded + 16
                        mtls.TotalSize        = mtls.TotalSize + 16
                        lay.layerSizeIncluded = lay.layerSizeIncluded + 16
                        
                        local kmte = _kmte()
                        
                        for key in mat.emissive_alpha.controller.keys do
                        (
                            s.shaderSizeIncluded  = s.shaderSizeIncluded + 8
                            mtls.TotalSize        = mtls.TotalSize + 8
                            lay.layerSizeIncluded = lay.layerSizeIncluded + 8
                            
                            local theTime = help.TimeToInt key.time
                            theTime = theTime * 1000 / 30
                            append kmte.timeList theTime
                            append kmte.valueList key.value
                        )
                        
                        lay.KMTE = kmte
                    )
                )
                if (i==5) then lay.textureId = GriffonStudios_Helper_Functions.GetLayerTextureId2 _TEXSList mat.replacable_map
                if (i==6) then lay.textureId = GriffonStudios_Helper_Functions.GetLayerTextureId2 _TEXSList mat.reflection_map
                
                lay.textureAnimationId = -1
                
                
                append s.Layers lay
            )
            
            
            append mtls.shaderlist s
        )
        
        
        
        
        return mtls
    ),
    /* Get the unique list of textures so that a reference can be made when writing the mtls block */
    function GetTEXS bitmap=
    (
        if ( TEXTURE_PATH == undefined ) then TEXTURE_PATH = "war3mapImported/" 
        if( bitmap==undefined ) then 
            tex = ""
        else
        (
            --local fileName = filenameFromPath bitmap.fileName
            local fileName = (getFilenameFile  bitmap.fileName ) + ".dds"
            
            if( fileName == "" or fileName.count <=4 ) then 
                tex = ""
            else
            (
                
                
                tex = TEXTURE_PATH + fileName 
                
            )
        )
        return tex
    ),
    /* helper function to list only the unique texs based on the reference to texture files */
    function GetUniqueTextures uniqueMaterials=
    (
        struct _texs ( id, replaceableId, fileName, flag = 3 )
        
        /* get the list of textures */
        local texsList = #()
        for mat in uniqueMaterials do
        (
            local tex  = undefined
            
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.diffuse_map
            if ( getfilenamefile tex == "Black32" and USE_BLACK32 == true ) then tex = "Textures/Black32.blp"
            appendIfUnique texsList tex

            tex = GriffonStudios_Helper_Functions.GetTEXS mat.normal_map
            if ( getfilenamefile tex == "Black32" and USE_BLACK32 == true ) then tex = "Textures/Black32.blp"
            appendIfUnique texsList tex
            
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.orm_map
            if ( getfilenamefile tex == "Black32" and USE_BLACK32 == true ) then tex = "Textures/Black32.blp"
            appendIfUnique texsList tex
            
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.emissive_map
            if ( getfilenamefile tex == "Black32" and USE_BLACK32 == true ) then tex = "Textures/Black32.blp"
            appendIfUnique texsList tex
            
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.replacable_map
            if ( getfilenamefile tex == "Black32" and USE_BLACK32 == true ) then tex = "Textures/Black32.blp"
            appendIfUnique texsList tex
            
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.reflection_map
            if ( getfilenamefile tex == "EnvironmentMap" and USE_ENVIRONMENT_MAP == true ) then tex = "ReplaceableTextures/EnvironmentMap.blp"
            if ( getfilenamefile tex == "Black32" and USE_BLACK32 == true ) then tex = "Textures/Black32.blp"
            appendIfUnique texsList tex
            
        )
        
        local mtlsTextures = #()
        for i=1 to texsList.count do
        (
            textureFile = texsList[i]
            local t = _texs id:i replaceableId:1 fileName:"" --> replaceable Id 1 holds no texture
            
            if ( textureFile != "" ) then t = _texs id:i replaceableId:0 fileName:textureFile
            
            append mtlsTextures t
        )
        
        return mtlsTextures
    ),
    /* depending on the map to export, get the matching ID from the TEXS */
    function GetLayerTextureId2 textureList map=
    (
        local textureToFind = ""
        if ( map == undefined ) then textureToFind = ""
        if ( map != undefined ) then 
        (
            textureToFind = filenameFromPath map.fileName
            if ( textureToFind.count <= 4 ) then textureToFind = ""
            if ( textureToFind.count > 4) then textureToFind = TEXTURE_PATH + textureToFind
            if ( USE_BLACK32 AND ( getfilenamefile textureToFind ) == "Black32"  ) then textureToFind = "Textures/Black32.blp"
            if ( USE_ENVIRONMENT_MAP AND ( getfilenamefile textureToFind ) == "EnvironmentMap" ) then textureToFind = "ReplaceableTextures/EnvironmentMap.blp"
                
        )
        --format "Looking for %\n" textureToFind
        local textureId = 0
        for x=1 to textureList.count do
        (
            local t = textureList[x]
            if ( t.fileName == textureToFind ) then 
            (
                textureId = x
                exit
            )
        )
        if textureId == 0 then throw "Texture ID not found !!"
        --format "Texture ID : %\n" textureId
        return textureId
        
    ),
    function GetMeshesToExport = 
    (
        local meshes = #()
        for obj in objects do
        (
            /* meshes, prefixed with "B_KGS_" are collision objects */
            if (classof obj == Editable_mesh ) then 
            (
                if ( substring obj.name 1 6 != "B_KGS_"  and obj.isHidden == false ) then 
                (
                    if ( obj.material != undefined ) then 
                        if ( classof obj.material == WC3RefMaterial ) then 
                            append meshes obj
                    
                )
            )
        )
        return meshes
    ),
    function GetGEOS=
    (
        
        local help = GriffonStudios_Helper_Functions()
       
        struct WC3RefGeometry 
            ( TotalSize = 0, Geos = #() )
        
        struct WC3RefGeo
            ( size, vrtx = #(), nrms = #(), ptyp = #(), pcnt = #(), pvtx = #(), gndx , mtgc = #(), mats, tang = #(), skins = #(), uvas, uvbs = #() )

        struct WC3RefMATS
            ( nbrBones, boneIdList = #(), MaterialReferenceId, sectionGroupId = 0, sectionGroupType = 0, LodId, LodName, sevenFloats = #(), oneLong = 0 )
        
        local geos = WC3RefGeometry()
        
        local meshes = help.GetMeshesToExport()
        
        for m in meshes do
        (
            if ( WC3_DEBUG ) then format "Writing %\n" m.name
            
            local lod_name = substring m.name (m.name.count - 3) -1
            
            local lod_id = 0
            if ( lod_name == "LOD1" ) then lod_id = 1
            if ( lod_name == "LOD2" ) then lod_id = 2
            if ( lod_name == "LOD3" ) then lod_id = 3
            
            local geo = WC3RefGeo()
            
            local original_vertices = #()
            local original_normals  = #()
            local original_tangents = help.CalculateTangents m
            local original_weights  = help.GetWeights m
            for v=1 to m.numVerts do
            (
                original_vertices[v] = getVert m v
                original_normals[v] = getNormal m v
            )
            

            local tvVertices = #()
            local faces = #()
            for i=1 to m.numFaces do
            (
                local f = getFace m i
                local u = getTvFace m i

                faces[i] = u
                tvVertices[u.x] = f.x
                tvVertices[u.y] = f.y
                tvVertices[u.z] = f.z
                
            )
            
            local vertices = #()
            local normals = #()
            local uvs = #()
            local tangents = #()
            local weights = #()
            for i=1 to tvVertices.count do
            (
                local uv = getTvert m i
                
                uvs[i] = [uv.x, 1.0 - uv.y]
                vertices[i] = original_vertices[tvVertices[i]]
                normals[i]  = original_normals[tvVertices[i]]
                tangents[i] = original_tangents[tvVertices[i]]
                weights[i]  = original_weights[tvVertices[i]]
            )
            
            
            geo.Size = 4 
            -- VRTX
            geo.Size += 8
            geo.vrtx = vertices
            geo.Size +=  vertices.count * 12
            
            -- NRMS
            geo.Size += 8
            geo.nrms = normals
            geo.Size +=  normals.count * 12
            
            -- PTYP
            geo.Size += 12
            append geo.ptyp 0x4 --> export triangles only
            
            -- PCNT
            geo.Size += 12
            append geo.pcnt ( m.numFaces * 3 ) --> number of corners or indices in the group
            
            -- PVTX
            geo.Size += 8
            for f=1 to faces.count do
            (
                local face = faces[f]
                append geo.pvtx [face.x - 1, face.y - 1, face.z - 1]
            )
            geo.Size += faces.count * 6
            
            -- GNDX
            geo.Size += 8 --> only GNDX and nbr of gndx's which is zero
            geo.gndx = 0
            
            -- MTGC
            geo.Size += 8
            local nBones = help.GetNumberOfBones m
            
            for n=1 to nBones do append geo.mtgc 1
            
            geo.Size += nBones * 4
            
            -- MATS
            geo.Size += 8
            
            geo.mats = WC3RefMATS()
            
            geo.mats.nbrBones = nBones
            for n=1 to nBones do append geo.mats.boneIdList (n-1)
            geo.Size += nBones * 4
            
            local uniqueMaterials = #()
            for obj in objects do
            (
                if ( obj.material != undefined and ( classof obj.material == WC3RefMaterial ) ) then
                    appendIfUnique uniqueMaterials obj.material
            )

            for matId = 1 to uniqueMaterials.count do
            (
                local mat = uniqueMaterials[matId]
                if ( mat == m.material ) then geo.mats.MaterialReferenceId = matId - 1
            )
            geo.Size += 4 --> texture ID
            geo.Size += 8 --> section group id, section group type
            
            geo.mats.LodId = lod_id
            geo.Size += 4
            geo.mats.LodName = m.name
            geo.Size += 80
            
            for i= 1 to 7 do append geo.mats.sevenFloats 0.0
            geo.Size += 7 * 4

            geo.Size += 4 --> one long
            
            -- TANG
            geo.Size += 8
            geo.tang = tangents
            geo.Size +=  tangents.count * 16
            
            -- SKIN
            geo.Size += 8
            geo.skins = weights
            geo.Size += weights.count * 8
            
            -- UVAS / UVBS
            geo.Size += 8

            geo.uvas = 1 --help.GetNumUVMaps m
            for u=1 to geo.uvas do
            (
                geo.Size += 8
                geo.uvbs = uvs
                geo.Size += uvs.count * 8
                --if ( WC3_DEBUG ) then format " - UVBS: %\n" uvs
            )
            
            --if ( WC3_DEBUG ) then format " - %\n" geo
            append geos.geos geo
        )
        
        for geo in geos.geos do geos.totalSize += geo.Size
        
        --if ( WC3_DEBUG ) then format " - Total Size: %\n" geos.totalSize
        
        return geos
    ),
    /* Get the number of bones in the skin modifier */
    function GetNumberOfBones theMesh=
    (
        select theMesh
        max modify mode
        local sk = modPanel.getCurrentObject()
        local nbrBones = 0
        if (classof sk == Skin ) then nbrBones = skinOps.GetNumberBones sk
           
        /*
            It should not be possible that there is no bone !!
            If that is the case, simulate one and have ever vertex have a weight of 1.0
        */
        deselect theMesh
        return nbrBones
    ),
    /* Calculate tangent, since Max does not support TANGENTS we need to calculate then however, Reforged and this method does not seem to be aligned */
    function CalculateTangents theMesh=
    (
        local tan1 = #()
        local tan2 = #()
        local tangent = #()
        for i=1 to theMesh.numFaces do
        (

            local f = getFace theMesh i

            local v1 = getVert theMesh f[1]
            local v2 = getVert theMesh f[2]
            local v3 = getVert theMesh f[3]

            local w1 = getTVert theMesh f[1]
            local w2 = getTVert theMesh f[2]
            local w3 = getTVert theMesh f[3]


            local x1 = v2.x - v1.x
            local x2 = v3.x - v1.x
            local y1 = v2.y - v1.y
            local y2 = v3.y - v1.y
            local z1 = v2.z - v1.z
            local z2 = v3.z - v1.z

            local s1 = w2.x - w1.x
            local s2 = w3.x - w1.x
            local t1 = w2.y - w1.y
            local t2 = w3.y - w1.y

            local r = 1.0 / ( s1 * t2 - s2 * t1)

            local sdir = [ ( t2 * x1 - t1 * x2) * r , ( t2 * y1 - t1 * y2 ) * r, ( t2 * z1 - t1 * z2 ) * r ]
            local tdir = [ ( s1 * x2 - s2 * x1) * r , ( s1 * y2 - s2 * y1 ) * r, ( s1 * z2 - s2 * z1 ) * r ]

            tan1[f[1]] = sdir
            tan1[f[2]] = sdir
            tan1[f[3]] = sdir

            tan2[f[1]] = tdir
            tan2[f[2]] = tdir
            tan2[f[3]] = tdir

        )

        for i=1 to theMesh.numVerts do
        (
            local n = getnormal theMesh i
            local t = tan1[i]
            
            local v = normalize ( ( t - n ) * ( dot n t ) )
            local w = dot ( cross n t ) tan2[i]
            
            if ( w < 0.0 ) then w = -1.0 else w = 1.0
            tangent[i] = [v.x, v.y, v.z, w]
        )
        return tangent
    ),
    /* get the bones in the scene */
    function GetBones=
    (
        local boneList = #()
        for obj in objects do 
            if ( classof obj == BoneGeometry ) then 
                append boneList obj
        
        return boneList
    ),
    /* get the vertex weights and vertec bone indices */
    function GetWeights theMesh=
    (
        local boneList = GriffonStudios_Helper_Functions.GetBones()
        select theMesh
        max modify mode
        local sk = modPanel.getCurrentObject()
        
        struct vertexWeights ( vertexId, boneIndices, weights )
        local vertices = #()
        
        if (classof sk == Skin ) then
        (
            for v=1 to skinOps.getnumbervertices sk do
            (
                local count = skinops.getvertexweightcount sk v
                local boneIndices = #(0,0,0,0)
                local weights = #(0,0,0,0)
                
                if count > 4 then count = 4
                for k=1 to count do
                (
                    local weight = skinOps.getvertexweight sk v k
                    local boneId = skinOps.getvertexweightboneid sk v k
                    local boneName = skinOps.getBonename sk boneId 0
                    
                    for b=1 to boneList.count do
                    (
                        if ( boneList[b].name == boneName ) then 
                        (
                            boneId = b - 1
                            exit
                        )
                    )
                    
                    boneIndices[k] = boneId
                    weights[k] = ( weight * 255 ) as integer
                )
                
                if( 255 - weights[1] - weights[2] - weights[3] - weights[4] != 0 ) then
                    weights[1] = 255 - weights[2] - weights[3] - weights[4]

                local vertex = vertexWeights vertexId:v boneIndices:boneIndices weights:weights
                
                append vertices vertex
            )
            
        )
        deselect theMesh
        return vertices
    ),
    /* get the number of uv maps */
    function GetNumUVMaps m=
    (
        local n = meshop.getnummaps m
        
        local availableUVMaps = 0
        
        for i=1 to n do
        (
            if( ( meshop.getMapSupport m i ) == true ) then availableUVMaps +=1 
        )
        
        return availableUVMaps
        
    ),
    /* get the texture coordinates of the mesh of that mapchannel */
    function GetUVCoordinates theMesh mapChannel=
    (
        local uvs = #()
        
        for v=1 to theMesh.NumVerts do
        (
            local uv = meshop.getMapVert theMesh mapChannel v
            
            append uvs [ uv.x, ( 1.0 - uv.y ) ]
        )
        return uvs
    ),
    function CopyFilesToOutputFolder outputfolder=
    (
        
        makeDir ( outputfolder + "Textures" )
        
        gUniqueMaterials = #()

        for obj in objects do
        (
            if ( obj.material != undefined and ( classof obj.material == WC3RefMaterial ) ) then
                append gUniqueMaterials obj.material
        )

        gTextureFiles = #()

        for mat in gUniqueMaterials do
        (
            --local fileName = getfilenamefile 
            appendifunique gTextureFiles mat.diffuse_map.filename
            appendifunique gTextureFiles mat.normal_map.filename
            appendifunique gTextureFiles mat.orm_map.filename
            appendifunique gTextureFiles mat.emissive_map.filename
            appendifunique gTextureFiles mat.replacable_map.filename
            appendifunique gTextureFiles mat.reflection_map.filename

        )
        for t in gTextureFiles do 
        (
            local fileNameOnly = getfilenamefile t
            local targetFile = outputFolder + "Textures\\" + (filenameFromPath t)
            if( fileNameOnly != "" ) then 
            (
                Format "Copying file %\n" (filenameFromPath t)
                copyfile t  targetFile
                
            )
        )
    )
    
)

STRUCT GriffonStudios_Warcraft_3_Writer_Functions
(
    function WriteMatrix stream someBone=
    (
        local matrix = someBone.transform
        
        if ( someBone.parent != undefined ) then 
            matrix = someBone.transform * someBone.parent.transform
        
        for r=1 to 4 do
        (
            for i=1 to 3 do
                writeFloat stream matrix[r][i]
        )
        
    ),
    function WriteKGAnimations2 stream wc3Bone=
    (
        
        local animations= wc3Bone.Animations
        local theBone = wc3Bone.BoneRef
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        for i=1 to animations.count do
        (
            if ( animations[i].AnimBlock.count > 0 ) then
            (
                writer.WriteFixedString stream animations[i].Type 4
                writeLong stream animations[i].AnimBlock.Count
                writeLong stream animations[i].LineType
                writeLong stream animations[i].ParentId

                for anim in animations[i].AnimBlock do
                (
                    
                    local wc3key = anim.Key * 1000 / 30
                    writeLong stream wc3key
                    
                    --if ( WC3_DEBUG ) then format " - Frame: % (%)\n" anim.Key wc3key
                    
                    if ( animations[i].Type == "KGTR" ) then writer.WriteVector3 stream anim.Val
                    if ( animations[i].Type == "KGRT" ) then writer.WriteQuat stream anim.Val 
                    if ( animations[i].Type == "KGSC" ) then writer.WriteVector3 stream anim.Val
                
                )
            )
        )
    ),
    function WriteFixedString stream str len=
    (
        if ( WC3_DEBUG ) then  Format " - Writing %\n" str
        for i=1 to str.count do
        (
            local byte = bit.charasint str[i]
            writeByte stream byte
        )
        for i=1 to (len - str.count) do
            writeByte stream 0
    ),
    function WriteTris stream tris=
    (
        writeShort stream tris[1]
        writeShort stream tris[2]
        writeShort stream tris[3]
    ),
    function WriteVector3 stream vector3=
    (
         writeFloat stream vector3.X
         writeFloat stream vector3.Y
         writeFloat stream vector3.Z
        
        
    ),
    function WriteQuat stream quaternian=
    (
        writeFloat stream quaternian.x
        writeFloat stream quaternian.y
        writeFloat stream quaternian.z
        writeFloat stream quaternian.w

    ),
    function WriteVector4 stream vector4=
    (
        writeFloat stream vector4[1]
        writeFloat stream vector4[2]
        writeFloat stream vector4[3]
        writeFloat stream vector4[4]
        
    ),
    function WriteVertexWeights stream vertexWeights=
    (
        for i=1 to 4 do writeByte stream vertexWeights.boneIndices[i]
        for i=1 to 4 do writeByte stream vertexWeights.weights[i]
        
    ),
    function WriteTextureCoordinates stream uv=
    (
        writeFloat stream uv[1]
        writeFloat stream uv[2]
    ),
    function WriteMODLBoundingBox stream=
    (
        local bbox = GriffonStudios_Helper_Functions.GetMODLBoundingBox()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        if ( WC3_DEBUG ) then  Format "Writing bbox %\n" bbox
        
        writer.WriteVector3 stream bbox[1]
        writer.WriteVector3 stream bbox[2]
        
    ),
    function WriteSEQS stream=
    (
        local help = GriffonStudios_Helper_Functions()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        local seqs = help.GetSEQS()
        
        --if ( WC3_DEBUG ) then for s in seqs do format " - %\n" s
        
        writeLong stream ( 132 * seqs.count)
        
        for seq in seqs do
        (
            writer.WriteFixedString stream seq.Name 80
            WriteLong  stream seq.StartFrame
            WriteLong  stream seq.EndFrame
            WriteFloat stream seq.MovementSpeed
            WriteLong  stream seq.NoLoop
            WriteFloat stream seq.Rarity
            WriteLong  stream seq.Default
            WriteFloat stream seq.Priority
            
            writer.WriteVector3 stream seq.BBox[1]
            writer.WriteVector3 stream seq.BBox[2]
            
            --if ( WC3_DEBUG ) then  Format " - %\n" seq
        )

        
    ),
    function WriteMTLS stream=
    (
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        local mtls = GriffonStudios_Helper_Functions.GetMTLS()
        
        if (WC3_DEBUG) then 
        (
            for i=1 to mtls.TEXSList.Count do
                format " - %\n" mtls.TEXSList[i].filename
        )
        
        writeLong stream mtls.TotalSize
        
        for s in mtls.ShaderList do
        (
            writeLong stream s.shaderSizeIncluded
            writeLong stream s.priorityPlane
            writeLong stream s.flag
            writer.WriteFixedString stream s.shaderName 80
            
            writer.WriteFixedString stream "LAYS" 4
            writeLong stream s.Layers.Count --> usually 6
            
            for l=1 to s.Layers.Count do
            (
                local lay = s.Layers[l]
                --format "DEBUG: TextureID: %\n" lay.TextureID
                writeLong stream lay.layerSizeIncluded
                writeLong stream lay.filterMode
                writeLong stream lay.shadingFlag
                writeLong stream ( lay.TextureId - 1 )
                writeLong stream lay.textureAnimationId
                
                writeLong  stream 0 -- UV Mappting Coord map id --> TODO get this from the mesh
                writeFloat stream 1.0 -- Alpha --> animatable -> if not animated, this value will be taken
                
                writeFloat stream lay.emissive_multiplier -- Emissive --> works, kinda, it does multiply
                
                --> TODO get this from the material
                writeFloat stream 1 -- Fresnel Color R --> works 
                writeFloat stream 1 -- Fresnel Color G --> works 
                writeFloat stream 1 -- Fresnel Color B --> works 
                writeFloat stream 0 -- Fresnel Multiplier --> works 
                writeFloat stream 0 -- Team Color Multiplier --> does not work
                
                if ( l==1) then  --> Alpha animation
                (
                    if ( lay.KMTA != undefined ) then
                    (
                        writer.WriteFixedString stream "KMTA" 4
                        writeLong stream lay.KMTA.timeList.count
                        writeLong stream 1 --> line type
                        writeLong stream -1 --> parentId
                        
                        for k=1 to lay.KMTA.timeList.count do
                        (
                            writeLong stream lay.KMTA.timeList[k]
                            writeFloat stream lay.KMTA.valueList[k]
                        )
                        
                    )
                )
                if ( l==4) then --> Emissive Animation -> DOES NOT WORK 
                (
                    if ( lay.KMTE != undefined ) then
                    (
                        writer.WriteFixedString stream "KMTE" 4
                        writeLong stream lay.KMTE.timeList.count
                        writeLong stream 1 --> line type
                        writeLong stream -1 --> parentId
                        
                        for k=1 to lay.KMTE.timeList.count do
                        (
                            writeLong stream lay.KMTE.timeList[k]
                            writeFloat stream lay.KMTE.valueList[k]
                        )
                        
                    )
                )
                
            )

        )
        
        GriffonStudios_Warcraft_3_Writer_Functions.WriteTEXS stream mtls.TEXSList
    ),
    function WriteTEXS stream texsList =
    (
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        writer.WriteFixedString stream "TEXS" 4
        
        writeLong stream ( texslist.count * 268 )
        for tex in texsList do
        (
            writeLong stream tex.replaceableId
            writer.WriteFixedString stream tex.fileName 260
            writeLong stream tex.flag
        )            
        
    ),
    function WriteMODL stream file=
    (
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        writeLong stream 372
        writer.WriteFixedString stream ( getFileNameFile file ) 80
        writer.WriteFixedString stream "" 260
        writeLong stream 0
        writer.WriteMODLBoundingBox stream
        writeLong stream 150
    ),
    function WriteGEOS stream=
    (
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        local geos = GriffonStudios_Helper_Functions.GetGEOS()
        
        writeLong stream geos.TotalSize
        
        for geo in geos.geos do
        (
            writeLong stream geo.size

            writer.WriteFixedString stream "VRTX" 4
            writeLong stream geo.VRTX.count
            for v in geo.VRTX do 
            (
                --local v2 = [-v.y, v.x, v.z]
                writer.WriteVector3 stream v
            )
            writer.WriteFixedString stream "NRMS" 4
            writeLong stream geo.NRMS.count
            for n in geo.NRMS do 
            (
                --local n2 = [-n.y, n.x, n.z]
                writer.WriteVector3 stream n
            )

            writer.WriteFixedString stream "PTYP" 4
            writeLong stream geo.PTYP.count
            for p in geo.PTYP do writeLong stream p
                
            writer.WriteFixedString stream "PCNT" 4
            writeLong stream geo.PCNT.count
            for p in geo.PCNT do writeLong stream p
            
            writer.WriteFixedString stream "PVTX" 4
            writeLong stream ( geo.PVTX.count * 3 )
            for p in geo.PVTX do 
            (
                
                writer.WriteTris stream p
            )
            writer.WriteFixedString stream "GNDX" 4 --> probably need to change this...
            writeLong stream 0
            
            writer.WriteFixedString stream "MTGC" 4
            writeLong stream geo.MTGC.count
            for m in geo.MTGC do writeLong stream m
                
            writer.WriteFixedString stream "MATS" 4
            writeLong stream geo.MATS.boneIdList.count
            for b in geo.MATS.boneIdList do writeLong stream b
            writeLong stream geo.MATS.MaterialReferenceId
            writeLong stream geo.MATS.sectionGroupId 
            writeLong stream geo.MATS.sectionGroupType 
            writeLong stream geo.MATS.LodId
            writer.WriteFixedString stream geo.MATS.LodName 80 
            for f in geo.MATS.sevenFloats do writeFloat stream f
            writeLong stream geo.MATS.oneLong
            
            writer.WriteFixedString stream "TANG" 4
            writeLong stream geo.TANG.count
            for t in geo.TANG do writer.WriteVector4 stream t
                
            writer.WriteFixedString stream "SKIN" 4
            writeLong stream ( geo.SKINS.count * 8 )
            for s in geo.SKINS do writer.WriteVertexWeights stream s
            
            writer.WriteFixedString stream "UVAS" 4
            writeLong stream geo.UVAS
            
            writer.WriteFixedString stream "UVBS" 4
            writeLong stream geo.UVBS.count
            for uvbs in geo.UVBS do
            (
                writer.WriteTextureCoordinates stream uvbs
            )

        )
    ),
    function WriteGEOA stream=
    (
        local help = GriffonStudios_Helper_Functions()
        local geoas = help.GetGEOA()
        
        local totalSize = 0
        for geoa in geoas do totalSize += geoa.size
            
        writeLong stream totalSize
        
        for geoa in geoas do
        (
            writeLong stream geoa.size
            writeFloat stream geoa.alpha
            writeLong  stream geoa.flag
            writeFloat stream geoa.color[1]
            writeFloat stream geoa.color[2]
            writeFloat stream geoa.color[3]
            writeLong  stream geoa.id
        )
        
    ),
    function WriteBONE stream=
    (
        local help = GriffonStudios_Helper_Functions()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        -- ( Id, Name, ParentBoneId, Flags, boneRef, KGTR, KGRT, KGSC, offset, geosetId, geosetAnimationId )
        local wc3Bones = help.GetBONE()
        
        
        if (WC3_DEBUG) then 
        (
            --format "Total Size: % \n" wc3Bones.totalSize
            for b in wc3Bones.WC3RefBoneList do format " - %\t%\n" b.id b.name
        )
        
        writeLong stream wc3Bones.totalSize
        
        for b in wc3Bones.WC3RefBoneList do
        (
            writeLong stream b.Size -- 96 when there is no animation
            writer.WriteFixedString stream b.name 80
            writeLong stream b.Id
            writeLong stream b.ParentId
            writeLong stream b.Flag --> 0x100 or 256
            
            writer.WriteKGAnimations2 stream b
            
            writeLong stream b.geosetId
            writeLong stream b.geosetAnimationId
        )
        
        
    ),
    function WritePIVT stream=
    (
        local boneList = GriffonStudios_Helper_Functions.GetBones()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        WriteLong stream ( boneList.count * 12 )
        
        for b in boneList do
            writer.WriteVector3 stream b.pos
        
    ),
    function WriteBPOS stream=
    (
        local boneList = GriffonStudios_Helper_Functions.GetBones()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        WriteLong stream ( boneList.count * 48 + 4 )
        WriteLong stream boneList.count
        
            
        for b in boneList do
            writer.WriteMatrix stream b
        
    )
)

STRUCT GriffonStudios_Warcraft_3_Reforged_Exporter
(
    function Export file cfg=
    (
        -- ( debug_mode, find_textures, useBlack32, useEnvMap, base_texture_path )
        WC3_DEBUG           = cfg.debug_mode
        TEXTURE_PATH        = cfg.base_texture_path
        USE_BLACK32         = cfg.useBlack32
        USE_ENVIRONMENT_MAP = cfg.useEnvMap
        if ( file == undefined ) then return undefined
        if ( objects.count == 0 ) then return undefined
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        local stream = fopen file "wb"
        
        local animationInterval = animationrange
        --try (
            setWaitCursor()
            disableSceneRedraw()
            clearlistener()
            
            -- set the T-pose of the object to export correctly
            animationrange = interval 0 100
            slidertime = 0
         
        
            /* MDLX */
            format "Writing MDLX\n"
            writer.WriteFixedString stream "MDLX" 4
            
            /* VERS */
            format "Writing VERS\n"
            writer.WriteFixedString stream "VERS" 4
            writeLong stream 4
            writeLong stream 1000
            
            /* MODL */
            format "Writing MODL\n"
            writer.WriteFixedString stream "MODL" 4
            writer.WriteMODL stream file
            
            /* SEQS */
            format "Writing SEQS\n"
            writer.WriteFixedString stream "SEQS" 4
            writer.WriteSEQS stream
            
            /* MTLS & TEXS */
            format "Writing MTLS & TEXS\n"
            writer.WriteFixedString stream "MTLS" 4
            writer.WriteMTLS stream
        
            /* GEOS */
            format "Writing GEOS\n"
            writer.WriteFixedString stream "GEOS" 4
            writer.WriteGEOS stream

            /* GEOA */
            format "Writing GEOA\n"
            writer.WriteFixedString stream "GEOA" 4
            writer.WriteGEOA stream

            /* BONE */
            format "Writing BONE\n"
            writer.WriteFixedString stream "BONE" 4
            writer.WriteBONE stream

            /* PIVT */
            format "Writing PIVT\n"
            writer.WriteFixedString stream "PIVT" 4
            writer.WritePIVT stream

            /* BPOS */
            format "Writing BPOS\n"
            writer.WriteFixedString stream "BPOS" 4
            writer.WriteBPOS stream

            /* Copy textures to output folder */
            local outputFolder = getfilenamepath file
            GriffonStudios_Helper_Functions.CopyFilesToOutputFolder outputFolder

            Format "DONE!\n"
        --) catch ( messagebox ( getCurrentException() ) )

        fFlush stream
        fClose stream

        -- set the position back to orignal animation interval
        animationrange = interval animationInterval.start animationInterval.end
        gc() 
        enableSceneRedraw() 
        setArrowCursor()        
    )
)