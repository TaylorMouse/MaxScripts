STRUCT Warcraft_III_Helpers
(
    function ReadVector3Anim stream=
    (
        struct anim800 ( numPts, LineType, ParentId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = [readFloat stream, readFloat stream, readFloat stream]

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
        struct anim800 ( numPts, LineType, ParentId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = lineType
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
        
        struct anim800 ( numPts, LineType, ParentId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readFloat stream -- always 1, indicating it starts or ends

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
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    )
)