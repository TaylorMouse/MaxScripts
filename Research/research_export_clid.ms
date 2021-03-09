-- gbpos
-- gcollisions

clearlistener()
-- gbones.count

-- gbpos.count
GriffonStudios_Helpers.BuildBoundingBox
for c=1 to gcollisions.count do
(
    
    print gcollisions[c].name
    print gcollisions[c].boundingtype
    print gcollisions[c].pos
    print gcollisions[c].radius
    print gcollisions[c].height
    print gcollisions[c].something
    /*
    0: cube
    1: plane
    2: sphere
    3: cylinder
*/
    if gcollisions[c].boundingtype == 0 then
    (
        local p1 = gcollisions[c].pos
        local p2 = [gcollisions[c].radius, gcollisions[c].height, gcollisions[c].something]
        
        local bbox = GriffonStudios_Helpers.BuildBoundingBox #(p1,p2)
        bbox.name = gcollisions[c].name
        bbox.transform = gbpos[c].matrix
        
    )
--     if gcollisions[c].boundingtype == 2 then
--     (
--         local rad = gcollisions[c].radius * gcollisions[c].something
--         local b = sphere name:gcollisions[c].name \
--                          radius:rad

--         centerpivot b
--         b.wirecolor = color 128 128 255
--         b.transform = gbpos[c].matrix
--     )
)
 