clearlistener()

rotation_keys_to_keep = #()
position_keys_to_keep = #()
scale_keys_to_keep = #()
for obj in selection do
(
    
    if classof obj != bonegeometry and classof obj != SplineShape then continue
    if ( classof obj.pos.controller == position_list ) then (
        for i=1 to obj.pos.controller.count do (
            for key in obj.pos.controller[i].keys do
                appendifunique position_keys_to_keep key.time
        )
    )
    if ( classof obj.pos.controller == Position_XYZ ) then (
            for key in obj.pos.controller.keys do
                appendifunique position_keys_to_keep key.time
    )
    if ( classof obj.rotation.controller == rotation_list ) then (
        for i=1 to obj.rotation.controller.count do (
            for key in obj.rotation.controller[i].keys do
                appendifunique rotation_keys_to_keep key.time
        )
    )
    if ( classof obj.rotation.controller == Euler_XYZ ) then (
            for key in obj.rotation.controller.keys do
                appendifunique rotation_keys_to_keep key.time
    )
    if ( classof obj.scale.controller == scale_list ) then (
        for i=1 to obj.scale.controller.count do (
            for key in obj.scale.controller[i].keys do
                appendifunique scale_keys_to_keep key.time
        )
    )
    if ( classof obj.scale.controller == Bezier_Scale ) then (
            for key in obj.scale.controller.keys do
                appendifunique scale_keys_to_keep key.time
    )

)
position_keys_to_keep = sort position_keys_to_keep
rotation_keys_to_keep = sort rotation_keys_to_keep
scale_keys_to_keep = sort scale_keys_to_keep

/*
    baking should happen here !!!!

*/
all_keys = sort ( makeUniqueArray ( position_keys_to_keep + rotation_keys_to_keep + scale_keys_to_keep ) )
obj = $
for obj in selection do
(
    for key in all_keys do
        at time key 
        (
            addNewKey obj.pos.controller key
            addNewKey obj.rotation.controller key
            addNewKey obj.scale.controller key
        )

    deselectKeys obj.pos.controller
    deselectKeys obj.rotation.controller
    deselectKeys obj.scale.controller
    
    for i=1 to obj.pos.controller.keys.count do
    (
        local key = obj.pos.controller.keys[i]
        
        local foundIt = findItem keys_to_keep key.time
        if foundit == 0 then selectKeys obj.pos.controller key.time
    )
    deleteKeys obj.pos.controller #selection
    deselectKeys obj.pos.controller
    
    for i=1 to obj.rotation.controller.keys.count do
    (
        local key = obj.rotation.controller.keys[i]
        
        local foundIt = findItem keys_to_keep key.time
        if foundit == 0 then selectKeys obj.rotation.controller key.time
    )
    deleteKeys obj.rotation.controller #selection
    deselectKeys obj.rotation.controller
    
    
    for i=1 to obj.scale.controller.keys.count do
    (
        local key = obj.rotation.controller.keys[i]
        
        local foundIt = findItem keys_to_keep key.time
        if foundit == 0 then selectKeys obj.scale.controller key.time
    )
    deleteKeys obj.scale.controller #selection
    deselectKeys obj.scale.controller

    
    
)















