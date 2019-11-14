

struct WC3Seqs ( Name, StartFrame, EndFrame, Rarity, MoveSpeed, NonLoop, DefaultAnim, Sub_Anim, Priority )

seqs = #()

clearlistener()
track = getNoteTrack rootNode 1
keys = track.Keys

for i=1 to keys.count by 2 do
(
    local note = keys[i].value
    local parts = filterstring note "\r\n"
    
    local s = WC3Seqs()
    
    s.name = parts[1]
    
    local StartFrameStr = (getnotekeytime track i) as string 
    local EndFrameStr = (getnotekeytime track (i+1)) as string 
    
    StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
    EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
    
    local startFrame = StartFrameStr as integer
    local endFrame = EndFrameStr as integer
        
    s.StartFrame =  startFrame * 1000 / 30
    s.EndFrame =     EndFrame * 1000 / 30
    s.sub_anim = false
    s.DefaultAnim = false
        
    for i=2 to parts.count do
    (
        local split = filterString parts[i] " = "
        local key = split[1]
        local value = split[2]
         
        if ( key == "rarity" ) then s.rarity = value as float
        if ( key == "moveSpeed" ) then s.moveSpeed = value as float
        if ( key == "nonLoop" ) then s.nonLoop = value as integer
        if ( key == "defaultPriority" ) then s.Priority = value as float

    )
    
    append seqs s
    

    
)

    print seqs