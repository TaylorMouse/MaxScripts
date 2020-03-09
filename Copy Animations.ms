-- d = $
-- b = $

-- b.pos.controller
-- b.rotation.controller


-- d.controller = b.controller
clearlistener()

d.parent = b.parent

for i=1 to b.rotation.controller.keys.count do
(
    local t = b.rotation.controller.keys[i].time
    
    with animate on
        at time t 
           in coordsys b.parent
                d.rotation = b.rotation
    
    
)

for i=1 to b.pos.controller.keys.count do
(
    local t = b.pos.controller.keys[i].time
    
     with animate on
            at time t 
                in coordsys b.parent
                    d.pos = b.pos
    
    
)

