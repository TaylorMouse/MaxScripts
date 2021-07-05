/*
for obj in objects do
(
    if (classof obj == BoneGeometry and obj.parent == undefined ) then
    (
        
        local child = obj.children[1]
        
        local d = child.pos.z - obj.pos.z
        print d
        
        for k in child.pos.controller.keys do
        (
            print k.time
            if (k.time > 0) then (
                print k.time
                with animate on
                    at time k.time
                        child.pos.z += d
            )
        )
    )
)
for obj in objects do 
(
    if ( classof obj == bonegeometry ) then
    (
        local name = "sphere_" + obj.name
        local s = sphere name:name radius:3
        s.transform = obj.transform
        s.parent = obj.parent
        
    )
    
)
*/
clearListener()

theMesh = $

select theMesh
max modify mode
sk = modPanel.getCurrentObject()

if (classof sk == Skin ) then
(
    for v=1 to skinOps.getnumbervertices sk do
    (
        local count = skinops.getvertexweightcount sk v
        
        for k=1 to count do
        (
            local weight = skinOps.getvertexweight sk v k
            local boneId = skinOps.getvertexweightboneid sk v k
            local boneName = skinOps.getBonename sk boneId 0
            
            print boneName
            print weight
            
        )
        
        
    )
    
)
deselect theMesh