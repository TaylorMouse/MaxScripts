$.min
$.max

WC3_MDX.modl

$.pos


for i=1 to WC3_MDX.BONE.count do
(
    if (WC3_MDX.BONE[i].KGSC != undefined ) then
    (
        if (WC3_MDX.BONE[i].KGSC.glbsId  > 0 ) then 
        (
            print WC3_MDX.BONE[i] --> if this is not ZERO this points to a GLBS chunk, this means there is frame limit set on this object...
            print WC3_MDX.GLBS[WC3_MDX.BONE[i].KGSC.glbsId]
            
            
--             for p=1 to WC3_MDX.BONE[i].KGSC.numPts do
--             (
--                 print WC3_MDX.BONE[i].KGSC.KG[p] 
--             )
        )
    )
    
)



GriffonStudios_Helpers.RoundToFrame 2261

100*1000/30.0

behavior.behaviorHolders_array
Show $
behavior.behaviorState
behavior.bone
showClass "SC2BehaviorHolder"
apropos "TrackSet"
showProperties "TrackSet"


getPropNames behavior
getproperty behavior "boneStates"






startools.behaviors.behaviorHolders_array




