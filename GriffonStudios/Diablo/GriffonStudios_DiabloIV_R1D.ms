/*
    Diablo IV R&D 
    Taylor Mouse

*/

(
    function SkipBytes stream nBytesToSkip = (
        fseek stream nBytesToSkip #seek_cur
    )
    
    local stream = fOpen @"G:\Blizzard\Diablo 4\Extracted\Base\meta\Appearance\lilith.app" "rb"
    
    
    fseek stream 552 #seek_set
    
    local vectors1 = #()
    local vectors2 = #()
    
    for i=1 to 20 do
    (
        local v1 = [ readFloat stream, readFloat stream, readFloat stream ] * 50
        local v2 = [ readFloat stream, readFloat stream, readFloat stream ]

        append vectors1 v1
        append vectors2 v2
        
        local s = sphere radius:1
        s.position = v1

        SkipBytes stream 216
        
    )
    
    fClose stream
    
    
    
)
