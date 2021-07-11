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
    function GetTEXS =
    (
        struct texs800 ( replacableId, path= "", flags = 3, check )
        local texs = #()
        
        for obj in objects do
        (
            if ( classof obj == Editable_Mesh and obj.material != undefined ) then
            (
                if ( classof obj.material == compositematerial) then 
                (
                    for subMat in obj.material.materialList do
                    (
                        if ( classof subMat == WarcraftIII_Standard ) then
                        (
                            local tex = texs800()
                            tex.replacableId = subMat.ReplaceableTexture - 1
                            if( tex.replacableId == 0 ) then 
                                tex.path = ( getfilenamefile subMat.Diffuse_map.filename ) + ".blp" 
                            if ( tex.replacableId == 2 ) then tex.flags = 0
                            tex.check = tex.replacableId as string + tex.path + tex.flags as string
                            append texs tex
                        )
                    )
                )
                if ( classof obj.material == WarcraftIII_Standard ) then
                (
                    local tex = texs800()
                    tex.replacableId = obj.material.ReplaceableTexture - 1
                    if( tex.replacableId == 0 ) then 
                        tex.path = ( getfilenamefile obj.material.Diffuse_map.filename ) + ".blp" 
                    if ( tex.replacableId == 2 ) then tex.flags = 0
                    tex.check = tex.replacableId as string + tex.path + tex.flags as string
                    append texs tex
                )
                
            )
        )
        uniqueTexs = #()
        for t in texs do
        (
            if uniqueTexs.count == 0 then 
            (
                append uniqueTexs t
            )
            else
            (
                local addit = true
                for u in uniqueTexs do
                (
                    if u.check == t.check then
                    (
                       addit = false
                        exit
                    )
                )
                if ( addit ) then append uniqueTexs t
            )
        )

        if WC3_MDX800_DEBUG then  for t in uniqueTexs do print t
        return uniqueTexs
    )
)