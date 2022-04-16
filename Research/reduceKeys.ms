function GetLastKeyFrame =
(
    local lastKeyFrame = 0
    for obj in objects do 
    (
        try(
            if obj.pos.controller != undefined and obj.pos.controller.keys != undefined then 
            (
                local lastKey = obj.pos.controller.keys.count
                local keyFrame = obj.pos.controller.keys[lastKey].time
                if ( keyFrame > lastKeyFrame ) then 
                    lastKeyFrame = keyFrame
            )
            if obj.rotation.controller != undefined and obj.rotation.controller.keys != undefined then 
            (
                local lastKey = obj.rotation.controller.keys.count
                local keyFrame = obj.rotation.controller.keys[lastKey].time
                if ( keyFrame > lastKeyFrame ) then 
                    lastKeyFrame = keyFrame
            )
        )catch()
    )
    lastKeyFrame as integer / TicksPerFrame
)

function ReduceKeysBetween step:5 =
(
    local start = animationrange.start
    local end = animationrange.end
    
    local framesToKeep = #()
    for f=start to end by step do
    (
        append framesToKeep f
    )
    appendIfUnique framesToKeep end
    
    for obj in objects do
    (
        if obj.pos.controller != undefined and obj.pos.controller.keys != undefined then
        (
            for k=obj.pos.controller.keys.count to 1 by -1 do
            (
                local key = obj.pos.controller.keys[k]
                if key != undefined then (
                    if key.time > animationrange.start and key.time < animationrange.end then
                        if ( findItem framesToKeep key.time == 0 ) then 
                            deletekey obj.pos.controller k
                        
                )
            )
            for k= obj.rotation.controller.keys.count to 1 by -1 do
            (
                
                local key = obj.rotation.controller.keys[k]
                if key != undefined then (
                    if key.time > animationrange.start and key.time < animationrange.end then
                        if ( findItem framesToKeep key.time == 0 ) then 
                            deletekey obj.rotation.controller k
                )
            )
        )
    )
    framesToKeep
)

clearlistener()
gc()

-- ReduceKeysBetween step:3