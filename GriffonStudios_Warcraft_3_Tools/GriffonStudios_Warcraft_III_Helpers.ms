STRUCT Warcraft_III_Helpers
(
    /*
        .INFO
        | LineType:
        |   NO_INTERP = 0x0
        |   LINEAR    = 0x1
        |   HERMITE   = 0x2
        |   BEZIER    = 0x3

    */
    function ReadVector3Anim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = [readFloat stream, readFloat stream, readFloat stream]
            k.LineType = anim.lineType

            if( anim.lineType > 1)  then
            (
                k.inTan = [readFloat stream, readFloat stream, readFloat stream]
                k.outTan = [readFloat stream, readFloat stream, readFloat stream]
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadQuatAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                --format "Linetype: %\n" lineType
                k.inTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
                k.outTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadFloatAnim stream=
    (
        
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readFloat stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadVector3 stream=
    (
        local vector3 = [readFloat stream, readFloat stream, readFloat stream]
        return vector3
    ),
    function ReadColor stream=
    (
        local r = (readFloat stream * 255.0) as integer
        local g = (readFloat stream * 255.0) as integer
        local b = (readFloat stream * 255.0) as integer
        return ( color r g b )
    ),
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    ),
    function ReadColorAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = Warcraft3_Reforged.ReadColor stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadLongAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readLong stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
        
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
    /* Get the biggest bounding box from all models between 2 frame, as animation changes these bounding boxes */
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        if ( WC3_DEBUG ) then Format "Calculating MODL Boundingbox between frame % and %\n" startFrame endFrame
        local allKeys = GriffonStudios_Helpers.GetAllAnimatedKeyFrames()

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
        local lastFrame = GriffonStudios_Helpers.FindLastKeyFrame()
        if ( lastFrame <= 1 ) then lastFrame = 10
        bbox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 1 lastFrame
        
        return bbox
        
    ),
    /* get the list of animation sequences from the animation track */
    function GetSEQS =
    (
        struct WC3AnimSequence ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
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
                local s = WC3AnimSequence()
                
                s.name = parts[1]
                if ( WC3_DEBUG ) then  format " %\n" s.name
                local StartFrameStr = (getnotekeytime track i) as string 
                local EndFrameStr = (getnotekeytime track (i+1)) as string 
                
                StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
                EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
                
                local startFrame = StartFrameStr as integer
                local endFrame = EndFrameStr as integer

                s.BBox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames startFrame endFrame
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
            local seq = WC3AnimSequence Name:"Stand 1" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        return seqs
    ),
    /* Get the list of materials and their properties and the list of associated textures */
    function GetMTLS mdx=
    (
        
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
    )
)