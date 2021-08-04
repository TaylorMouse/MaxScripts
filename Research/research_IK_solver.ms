
--> returns the list of bones in the IK Chain
function GetBoneChain startBone endBone=
(
    local chain = #(endBone)
    endBone = endBone.parent
    while ( endBone != undefined and endBone != startBone ) do
    (
        append chain endBone
        endBone = endBone.parent
    )
    append chain startBone
    return chain
)

obj = $IK_Chain_Foot_R
for obj in objects do
(
    if ( classof obj.controller == ikchaincontrol ) then 
    (
        chain = GetBoneChain obj.controller.startJoint obj.controller.EndJoint

        --> get the animated keys from the objects in the chain
        --> Sample the range to the same nbr as the total amount of frames or at least half of it, 
        -- > then delete the IK Chain and delete the keys that were previously added! 
        
        format "% %\n" obj.name chain
    )
    
)