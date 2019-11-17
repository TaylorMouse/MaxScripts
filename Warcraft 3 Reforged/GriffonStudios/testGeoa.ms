function GetLastControllerFrame ctrl=
(
    local lastTimeFrame = 0
    if(ctrl != undefined ) then 
    (
        if(ctrl.keys.count > 0 ) then 
        (
            local maxTimeFrame = ctrl.keys[ctrl.keys.count].time
    
            if (lastTimeFrame < maxTimeFrame) then lastTimeFrame = maxTimeFrame
        )
    )

    return lastTimeFrame
)
function GetLastAnimFrame=
(
    local lastFrame = 0
    
    for obj in objects do
    (
        local lastPosFrame = GetLastControllerFrame obj.pos.controller
        local lastRotFrame = GetLastControllerFrame obj.rotation.controller
        local lastScaleFrame = GetLastControllerFrame obj.scale.controller

        if ( lastFrame < lastPosFrame ) then lastFrame = lastPosFrame
        if ( lastFrame < lastRotFrame ) then lastFrame = lastRotFrame
        if ( lastFrame < lastScaleFrame ) then lastFrame = lastScaleFrame
    )
    return lastFrame
)


function ReadGEOA=
(
    struct wc3geoa ( meshId, frame, visible )
    
    local meshes = #()
    local geoa = #()
    local meshId = 1
    
    for obj in objects do 
        if (classof obj == Editable_mesh ) then append meshes obj

    for m in meshes do
    (
        if ( m.visibility != undefined ) then 
        (
            -- add ZERO frame
            local g = wc3geoa meshid:meshId frame:0
            with animate on at time 0 g.visible = m.visibility
            append geoa g
            
            for i= 1 to ( numKeys m.visibility.controller ) do
            (
                local t = getkeytime m.visibility.controller i
                local t_before = t - 1
                
                -- add previous frame state
                local g = wc3geoa frame:t_before meshid:meshId
                with animate on at time t_before
                    g.visible = m.visibility
                append geoa g
                
                local g = wc3geoa frame:t meshid:meshId
                with animate on at time t
                    g.visible = m.visibility
                append geoa g
            )
            
            -- add last frame
            local lastFrame = GetLastAnimFrame()
            local g = wc3geoa meshid:meshId frame:lastFrame
            local t = getkeytime m.visibility.controller ( numKeys m.visibility.controller )
            with animate on at time t g.visible = m.visibility
            append geoa g
            
            
        )
        meshId += 1 
    )
    return geoa
)


x = ReadGEOA()
print x