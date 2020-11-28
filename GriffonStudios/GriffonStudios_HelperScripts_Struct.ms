/*
    (c)2016 - 2021 Griffon Studios
    Author: Taylor Mouse

    Helper functions
    
*/

STRUCT GriffonStudios_Helpers
(
    /*
        .DESCRIPTION
            Copy and map the SC2 textures to the destination folder.
    */
    function CopyAndMapSC2MaterialFileName matTexture=
    (
        
        if( matTexture == undefined ) then 
            return undefined
        
        if( matTexture.filename != "") then 
        (
            
            fullFilename = matTexture.filename
            
            print fullFilename
            
            fileName = filenameFromPath fullFilename
            
            targetFileName = maxfilepath + fileName
            
            print targetFileName
            
            if( findstring matTexture.filename ".." != undefined) then
                fullFilename = pathconfig.getCurrentProjectFolder() + "\\" + fullFilename
            
            if( (doesfileexist fullFilename) == true ) then 
                copyFile  fullFilename targetFileName
            
            matTexture.fileName = targetFileName
        )

    ),
    
    /* 
        .DESCRIPTION
            Remove a menu from the menu bar
    */
    function RemoveMenu menuName=
    (
        for i = 1 to menuman.numMenus() do
        (
            local mnu = menuman.FindMenu menuName
            if( mnu == undefined ) then
                exit
            else
                menuMan.unRegisterMenu mnu
        )

    ),
    
    /* 
        .DESCRIPTION
            Search for the position of the help menu
    */
    function GetHelpMenuPosition =
    (
        local mainMenu = menuMan.getMainMenuBar() 
        for i=1 to mainMenu.numItems() do
        (
            local title = ((mainMenu.getItem(i)).getTitle())
            if(title == "&Help" ) then return i
        )
        
        return undefined
    ),
    
    /* 
        .DESCRIPTION
            Build bounding box from 2 points
    */
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

    /* 
        .DESCRIPTION
            Build spline
    */
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


    /* 
        .DESCRIPTION
            Remove all note tracks
    */
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

    /* 
        .DESCRIPTION
            Get the last note frame from the notetrack
    */
    function GetLastNoteFrame=
    (
        local nNoteTracks = numNoteTracks rootNode
        if (nNoteTracks == 0 ) then return 0
        local theAnimTrack = getNoteTrack rootNode 1
        
        local frame = getNoteKeyTime theAnimTrack theAnimTrack.keys.count as string
        local lastKeyFrame = substring frame 1 ( frame.count - 1 ) as integer
        return lastKeyFrame
    ),
    
    /* 
        .DESCRIPTION
            Check the animation note track for unique name, if it exists, add a letter
    */
    function CheckUniqueSequenceName name=
    (
        local nNoteTracks = numNoteTracks rootNode
        if (nNoteTracks == 0 ) then return name
        
        local theAnimTrack = getNoteTrack rootNode 1
        
        local existingNames = #()
        for key in theAnimTrack.keys do
        (
            if ( key.value != undefined and key.value.count > 2 ) then 
            (
                local pos = (findstring key.value "\n" ) - 2
                if( pos != undefined ) then 
                (
                    local animName = substring key.value 1 pos
                    appendifunique existingNames animName
                )
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


    /* 
        .DESCRIPTION
            Find the last animation keyframe of a specific object
    */
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


    /* 
        .DESCRIPTION
            Get the last frame on the time line of all objects

    */
    function FindLastKeyFrame =
    (
        local last_frame = 0
        for obj in objects do
        (
            last_frame = FindLastKeyFrameByObject obj last_frame
        )
        return last_frame
    ),


    /*
        .DESCRIPTION
            Remove the menu from the main Max Menu interface
    */
    function RemoveMenu menuName=
    (
        for i = 1 to menuman.numMenus() do
        (
            local mnu = menuman.FindMenu menuName
            if( mnu == undefined ) then
                exit
            else
                menuMan.unRegisterMenu mnu
        )
    ),


    /*
        .DESCRIPTION
            Add a custom menu in front of the Max Help Menu by positioning it at the same position as the original Help menu itme
    */
    function GetHelpMenuPosition =
    (
        local mainMenu = menuMan.getMainMenuBar() 
        for i=1 to mainMenu.numItems() do
        (
            local title = ((mainMenu.getItem(i)).getTitle())
            if(title == "&Help" ) then return i
        )
        
        return undefined
    ),


    /* 
        .DESCRIPTION
            Free up max memory 
    */
    function FreeUpMemory=
    (
        GC()
        FreeSceneBitmaps()
        ClearUndoBuffer()
    ),


    /* 
        .DESCRIPTION
            Pass in a filestream and skips the number of bytes without reading them to memory 
    */
    function SkipBytes stream nBytesToSkip=
    (
        fseek stream nBytesToSkip #seek_cur
    ),


    /* 
        .DESCRIPTION
            Takes in a filestream and reads out a float, moves the stream pointer 2 bytes 
    */
    function ReadHalfFloat stream = 
    (
        hf = readshort stream
        sign = bit.get hf 16
        exponent = (bit.shift (bit.and hf (bit.hexasint "7C00")) -10) as integer - 16
        
        fraction = bit.and hf (bit.hexasint "03FF")
        
        if ( sign == true)  then 
            sign = 1 
        else 
            sign = 0
        
        exponentF = exponent + 127
        outputAsFloat = bit.or (bit.or (bit.shift fraction 13) \
                    (bit.shift exponentF 23)) (bit.shift sign 31)
        
        return bit.intasfloat outputasfloat*2
    ),

    /* 
        .DESCRIPTION
            Create layer in MAX, if it exists, just return a reference to that layer 
    */
    function CreateLayer layerName =
    (

        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),

    /* 
        .DESCRIPTION
            Read the Hexadecimal value of a stream 
    */
    function ReadHexLength stream len=
    (
        local result = ""
        for i=1 to len do
        (
            local val = readByte stream #unsigned
            local str = toUpper ( ( bit.IntAsHex val ) as string )
            
            if( str.count != 2) then
            (
                str = substring ( "00" + str ) 2 2
            )
            
            
            result = str + result
        )
        
        
        return result
    ),


    /* 
        .DESCRIPTION
            Read the hex string from a stream and move the pointer 4 bytes 
    */
    function ReadHex stream =
    (
        local result = ""
        for i=1 to 4 do
        (
            local val = readByte stream #unsigned
            local str = toUpper ( ( bit.IntAsHex val ) as string )
            
            result = str + result
        )
        
        return result
    ),


    /* 
        .DESCRIPTION
            Quick create on bones in max 
    */
    function CreateBone boneName transformation scaling boneLayer=
    (
        local l = CreateLayer boneLayer
        local b = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
        l.AddNode b
        
        b.Name = boneName
        b.ShowLinks = true
        b.Width  = 0 --> if sized, it becomes ugly
        b.Height = 0
        b.Length = 0
        b.transform = transformation
        b.scale = [1,1,1] * scaling
        
        return b
    ),


    /* 
        .DESCRIPTION
            Pass in nbr of characters that need to be read and returns a string 
    */
    fn ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    ),


    /* 
        .DESCRIPTION
            Pass in nbr of characters that need to be read and returns a string 
    */
    fn ReadFourCC stream =
    (
        local str = ""
        for i=1 to 4 do
        (
            local s = bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then 
                str = s + str
        )
        return str
    ),

    /* 
        .DESCRIPTION
            First byte holds the length of the string to be read 
    */
    fn ReadString2 stream =
    (
        len = ( readByte stream as integer )
        
        str = ReadFixedString stream len
        
        return str
    ),

    /*
        .DESCRIPTION
            Clean up the materials in the library
    */
    function CleanUpMaterialLibrary=
    (
        for m=1 to 24 do 
        (
            local mat = Standardmaterial()
            mat.name = "Standard - " + m as string
            meditMaterials[m] = mat
            
        )

    ),

     /* 
        .DESCRIPTION
            Recursively search for files in a path based on a pattern
    */
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

     /* 
        .DESCRIPTION
            Read 2xVector3 (6 floats) indicating the corners of the bounding box 
    */
    function ReadBoundingBox stream=
    (
        local bbox = #()
        local pointA = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        local pointB = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        append bbox pointA
        append bbox pointB
        
        return bbox
    ),

    /* 
        .DESCRIPTION
            Read 3 floats and return them as an array, like a Vector3 struct
            Use a correction to multiply each element
    */
    function ReadVector3 stream correction=
    (
        return [readFloat stream, readFloat stream, readFloat stream] * correction
    ),

    /* 
        .DESCRIPTION
            Read 2 floats and return them as an array, like a Vector3 struct with a zero as the w element (uvw)
    */
    function ReadUV3 stream=
    (
        return [readFloat stream, 1.0 - (readFloat stream), 0.0]
    )


)