
struct GriffonStudios_Helpers
(
    function CheckUniqueSequenceName name=
    (
        local nNoteTracks = numNoteTracks rootNode
        if (nNoteTracks == 0 ) then return name
        
        local theAnimTrack = getNoteTrack rootNode 1
        
        local existingNames = #()
        for key in theAnimTrack.keys do
        (
            local pos = (findstring key.value "\n" ) - 2
            if( pos != undefined ) then 
            (
                local animName = substring key.value 1 pos
                appendifunique existingNames animName
            )
        )
        local nameAlreadyExist = false
        for n in existingNames do
            if ( n == name ) then nameAlreadyExist = true

        if ( nameAlreadyExist == false) then return name
        
        local nbrSameName = 65
        
        for n in existingNames do
            if ((findstring n name) != undefined ) then nbrSameName = nbrSameName + 1 
        
        local newName = name + " " + (bit.intAsChar nbrSameName )
            
    ),
    function FindLastKeyFrameByObject obj last_frame = 
    (
        for i=1 to obj.numSubs do -- number of possible animation controllers
        (
            local keys = obj[i].keys
            if( keys != undefined ) then
            (
                if( keys.count > 0 ) then
                (
                    local timeFrame = keys[keys.count].time
                    if( timeFrame > last_frame ) then
                        last_frame = timeFrame
                )
                if (obj[i].numSubs > 0 ) then
                (
                    for j=1 to obj[i].numSubs do
                    (
                        last_frame = FindLastKeyFrameByObject obj[i] last_frame
                    )
                    
                )
            )
        )
        return last_frame
        
    ),
    function FreeUpMemory=
    (
        GC()
        FreeSceneBitmaps()
        ClearUndoBuffer()
        
    ),
    function ResetNoteTracks=
    (
        local nNoteTracks = numNoteTracks rootNode
        
        if(  nNoteTracks > 0 ) then
        (
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode (getNoteTrack rootNode 1)
        )
        true
    ),
    function FindLastKeyFrame =
    (
        local last_frame = 0
        for obj in objects do
        (
            last_frame = FindLastKeyFrameByObject obj last_frame
        )
        return last_frame
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