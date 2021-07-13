/*
    .SYNOPSIS
    | Some usefull functions :)
    
    .COPYRIGHT
    | (c)2005 - 2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

struct GriffonStudios_Helpers
(
    /* get all unique keys from all objects */
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
    /* Check if the file exists */
    function CheckFile file=
    (
        if ( file == undefined ) then  
            return undefined 
        if ( doesFileExist file == false ) then 
        ( 
            throw("File does not exist!"); 
            return undefined 
        )  
        return true
    ), 
    /* Read a Vector 3 => 3 floats from a binary stream */    
    function ReadVector3 stream=
    (
        local vector3 = [readFloat stream, readFloat stream, readFloat stream]
        return vector3
    ),
    /* Read a triangle => 3 shorts(2bytes) from a binary stream */
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    ),
    function drawLineBetweenTwoPoints pointA pointB =
    (
      local ss = SplineShape pos:pointA
      addNewSpline ss
      addKnot ss 1 #corner #line PointA
      addKnot ss 1 #corner #line PointB
      updateShape ss
      return ss
    ),
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
    /* build a spline box based on 2 corner points */
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
            
        return s
    ),
    function IsUndefinedBoolean val=
    (
        if (val == undefined ) then false else true
    ),
    /* creates a layer if it does not exist by name else returns a reference to the existing layer */
    function CreateLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),
    function GetStreamLength stream =
    (
        local currentPos = ftell stream
        fseek stream 0 #seek_end
        local streamLen = ftell stream
        
        fseek stream currentPos #seek_set
        
        return streamLen
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
    function RoundToFrame val=
    (
        local a = val * 30 / 1000
        local b = val * 30 / 1000.0
        
        if ( b - a ) > 0.5 then return a + 1 else return a
       
    ),
    function CreateAttachmentPoint aName=
    (
        theName = "AttachmentPoint"

        ss = SplineShape pos:[0,0,0]
        ss.renderable = off
        ss.name = theName
        if( aName != undefined ) then ss.name = aName

        addNewSpline ss
        addKnot ss 1 #corner #curve [0,0,10]
        addKnot ss 1 #corner #curve [5,0,0]
        close ss 1
        addNewSpline ss
        addKnot ss 2 #corner #curve [5,0,0]
        addKnot ss 2 #corner #curve [0,5,0]
        addKnot ss 2 #corner #curve [0,-5,0]
        close ss 2
        addNewSpline ss
        addKnot ss 3 #corner #curve [0,0,10]
        addKnot ss 3 #corner #curve [0,5,0]
        addKnot ss 3 #corner #curve [0,-5,0]
        close ss 3
        ss.WireColor = yellow
        updateShape ss
        setUserProp ss "Type" "Attachment Point"
        return ss
    ),
    function CreateAttachmentPoint2 aName=
    (
        theName = "AttachmentPoint"

        ss = SplineShape pos:[0,0,0]
        ss.renderable = off
        ss.name = theName
        if( aName != undefined ) then ss.name = aName

        addNewSpline ss
        addKnot ss 1 #corner #curve [0,0,10]
        addKnot ss 1 #corner #curve [0,-4,0]
        close ss 1
        addNewSpline ss
        addKnot ss 2 #corner #curve [-4,0,0]
        addKnot ss 2 #corner #curve [4,0,0]
        addKnot ss 2 #corner #curve [0,0,10]
        close ss 2
        addNewSpline ss
        addKnot ss 3 #corner #curve [-4,0,0]
        addKnot ss 3 #corner #curve [0,-4,0]
        addKnot ss 3 #corner #curve [4,0,0]
        close ss 3
        ss.WireColor = yellow
        updateShape ss
        
        setUserProp ss "Type" "Attachment Point"
        return ss
    ),
    function CreateFacialEffectsSpline=
    (
        fafxText = Text size:20 alignment:2 text:"FAFX" kerning:-1 wirecolor:yellow 
        centerPivot fafxText
        fafxText.pos = [0,0,0]
        fafxCircle = Circle radius:22.3 wirecolor:yellow pos:[0,0,0]
        
        convertToSplineShape fafxText
        convertToSplineShape fafxCircle
        addAndWeld fafxText fafxCircle -1
        
        fafxText.Name = "FAFX\n"
        setUserProp fafxText "Type" "Facial FX"
        return fafxText
    )
    
)
