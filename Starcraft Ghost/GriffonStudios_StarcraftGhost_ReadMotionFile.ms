clearListener()
nmsFile = @"F:\Blizzard\Starcraft Ghost\StarCraft Ghost Xbox\3D\Motions\zergling.nms"

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
        
    )

function ReadMotionFile nmsFile=
(
    struct ghost_motion 
        ( OverlayName, AnimName, animFile, lowPriority, noLoop, variable, fidget, endPause, endTag, noFadeIn )
    
    local str = openfile nmsFile
    local l = readLine str
    
    local motions = #()
    local currentOverlayName = "Standard"
    
    Format "Parsing motion file '%.nms'\n" ( getFileNameFile nmsFile )
    
    while ( ( eof str ) == false ) do
    (
        if ( eof str ) then exit
        
        l = readLine str
        
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
        
        local motion = ghost_motion noLoop:false lowPriority:false variable:false fidget:false endPause:false endTag:false noFadeIn:false
        motion.overlayName = currentOverlayName
        motion.animName = parts[1]
        motion.animFile = FindNadFile nmsFile parts[2]
        
        for i=3 to parts.count do
        (
            if ( parts[i] == "noloop" ) then motion.noLoop = true
            if ( parts[i] == "lowpriority" ) then motion.lowPriority = true
            if ( parts[i] == "variable" ) then motion.variable = true
            if ( parts[i] == "fidget" ) then motion.fidget = true
            if ( parts[i] == "endpause" ) then motion.endPause = true
            if ( parts[i] == "endtag" ) then motion.endTag = true
            if ( parts[i] == "nofadein" ) then motion.noFadeIn = true
        )
        
        --format "%\n" motion
        append motions motion
        
    )
    close str
    return motions
)


motions = ReadMotionFile nmsFile