/*
    (c) 2020 Griffon Studios
    
    by Taylor Mouse
    
    Warcraft III Reforged exporter 
    0.01
    
*/
GLOBAL WC3_DEBUG = true

STRUCT GriffonStudios_Warcraft_3_Writer_Functions
(
    function WriteFixedString stream str len=
    (
        if ( WC3_DEBUG ) then  Format "Writing %\n" str
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
    function WriteMODLBoundingBox stream=
    (
        local bbox = GriffonStudios_Helper_Functions.GetMODLBoundingBox()
        local writer = GriffonStudios_Writer_Functions()
        
        if ( WC3_DEBUG ) then  Format "Writing bbox %\n" bbox
        
        writer.WriteVector3 stream bbox[1]
        writer.WriteVector3 stream bbox[2]
        
    ),
    function WriteSEQS stream=
    (
        local help = GriffonStudios_Helper_Functions()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        local seqs = help.GetSEQS()
        
        writeLong stream ( 132 * seqs.count)
        
        -- ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
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
            
            if ( WC3_DEBUG ) then  Format " - %\n" seq
        )

        
    )
    
)

STRUCT GriffonStudios_Helper_Functions
(
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
                        last_frame = GriffonStudios_Helper_Functions.FindLastKeyFrameByObject obj[i] last_frame
                    )
                    
                )
            )
        )
        return last_frame
        
    ),
    function FindLastKeyFrame =
    (
        local last_frame = 0
        for obj in objects do
        (
            last_frame = GriffonStudios_Helper_Functions.FindLastKeyFrameByObject obj last_frame
        )
        return last_frame
    ),
    function GetMODLBoundingBox =
    (
        local help = GriffonStudios_Helper_Functions()
        local lastFrame = help.FindLastKeyFrame()

        help.GetMODLBoundingBoxBetweenFrames 1 lastFrame
        
        return bboxVolumeList[biggestId].bbox
        
    ),
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        local help = GriffonStudios_Helper_Functions()
        
        struct bboxVolume ( bbox, volume )

        bboxVolumeList = #()

        for f = startFrame to endFrame do
            at time f (
                
                local bbox = help.GetBoundingBox()
                local vol = help.GetBoundingBoxVolume bbox
                local bv = bboxVolume bbox:bbox volume:vol
                
                append bboxVolumeList bv
            )
            

        biggestId = 1
        for i=1 to bboxVolumeList.count do
        (
            for j=(i+1) to bboxVolumeList.count do
            (
                if ( bboxVolumeList[i].volume > bboxVolumeList[j].volume ) then biggestId = i
            )
        )
        
        return bboxVolumeList[biggestId].bbox  
    ),
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
                
                local StartFrameStr = (getnotekeytime track i) as string 
                local EndFrameStr = (getnotekeytime track (i+1)) as string 
                
                StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
                EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
                
                local startFrame = StartFrameStr as integer
                local endFrame = EndFrameStr as integer
                
                
                s.BBox = GriffonStudios_Helper_Functions.GetMODLBoundingBoxBetweenFrames startFrame endFrame
                    
                seqLength = ( EndFrame - startFrame ) * 1000 / 30 
                
                wc3EndFrame = wc3startFrame + seqLength
                
                s.StartFrame = wc3startFrame --startFrame * 1000 / 30
                s.EndFrame = wc3EndFrame -- EndFrame * 1000 / 30
                
                wc3startFrame = wc3EndFrame + 34
                s.Default = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                     
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.movementSpeed = value as float
                    if ( key == "nonLoop" ) then s.noLoop = value as float
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local startFrame = 1000 / 30
            local endFrame = 50 * 1000 / 30
            local seq = WC3RefAnimSequence Name:"Stand" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = GriffonStudios_Helper_Functions.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        --print seqs
        return seqs
    )
)


STRUCT GriffonStudios_Warcraft_3_Reforged_Exporter
(
    function Export file=
    (
        if ( objects.count == 0 ) then return undefined
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        local stream = fopen file "wb"
        
        try (
            /* MDLX */
            writer.WriteFixedString stream "MDLX" 4
            
            /* VERS */
            writer.WriteFixedString stream "VERS" 4
            writeLong stream 4
            writeLong stream 1000
            
            /* MODL */
            writer.WriteFixedString stream "MODL" 4
            writeLong stream 372
            
            writer.WriteFixedString stream ( getFileNameFile file ) 80
            writer.WriteFixedString stream "" 260
            writeLong stream 0
            writer.WriteMODLBoundingBox stream
            writeLong stream 150
            
            /* SEQS */
            writer.WriteFixedString stream "SEQS" 4
            writer.WriteSEQS stream
            
            /* MTLS */
            writer.WriteFixedString stream "MTLS" 4
            
        
            print "DONE!"
        ) catch ( print ( getCurrentException() ) )

        fFlush stream
        fClose stream
        gc()
    )
    
    
)

clearlistener()


file = @"G:\Game Dev\Griffon Studios\My 3D Models\Warcraft\WC3 Reforged\tm_tulip.mdx"

GriffonStudios_Warcraft_3_Reforged_Exporter.Export file

