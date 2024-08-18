clearlistener()
struct GriffonStudioTools (
    
    function ExportAnimation file= 
    (
        if ( doesfileexist file ) then deletefile file
        
        local outStream = fOpen file "wb"
        
        writeLong outStream objects.count
        
        for obj in objects do
        (
                        
            local name = obj.name
            local posCtrl = obj.pos.controller
            local rotCtrl = obj.rotation.controller
            
            local nbrPosKeys = numKeys posCtrl
            local nbrRotKeys = numKeys rotCtrl
            
            --print name
            writeString outStream name
            
            --print nbrPosKeys
            writeLong outStream nbrPosKeys
            
            if (nbrPosKeys > 0 ) then (
                for key in posCtrl.Keys do
                (
                    local t = key.time as integer / TicksPerFrame
                --    print t
                    writeLong outStream t
                    local pos = at time key.time in coordsys parent obj.pos
              --      print pos
                    writeFloat outStream pos.x
                    writeFloat outStream pos.y
                    writeFloat outStream pos.z
                )
            )
            
            --print nbrRotKeys
            writeLong outStream nbrRotKeys
            if (nbrRotKeys > 0 ) then (
                for key in rotCtrl.Keys do
                (
                    local t = key.time as integer / TicksPerFrame
                    --print t
                    writeLong outStream t
                    local rot = at time key.time in coordsys parent obj.rotation
                    --print rot
                    writeFloat outStream rot.x
                    writeFloat outStream rot.y
                    writeFloat outStream rot.z
                    writeFloat outStream rot.w
                )
            )
            
        )
        
        fclose outStream
    ),
    
    function ImportAnimation file startFrame=
    (
        struct nodeAnimation ( ref, posKeys = #(), posVlaues = #(), rotKeys = #(), rotValues = #() ) 

        local animations = #()
        
        local stream = fOpen file "rb"
        
        local nbrObjects = readLong stream
        
        -- read animation
        for i=1 to nbrObjects do
        (
            local anim = nodeAnimation()
            
            local objName = readString stream
            anim.ref = getNodeByName objName

            --print objName
            
            local nbrPosKeys = readLong stream
            for n=1 to nbrPosKeys do
            (
                append anim.posKeys ( readLong stream )
                append anim.posVlaues ( [readfloat stream, readfloat stream, readfloat stream] )
            )
            
            local nbrRotKeys = readLong stream
            for n=1 to nbrRotKeys do
            (
                append anim.rotKeys ( readLong stream )
                append anim.rotValues ( quat (readfloat stream) (readfloat stream) (readfloat stream) (readfloat stream) )
            )
            
            append animations anim
        )
        
        -- apply animation
        
        
        
    )
    
)

file = @"G:\Blizzard\Arclight Rumble\MY STL\Ogre\GameObject\Stand.animation"

-- GriffonStudioTools.ExportAnimation file
GriffonStudioTools.ImportAnimation file 100
