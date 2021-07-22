/*
    .SYNOPSIS
    | Convert objects exported from other games into this
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

function ConvertSC2AttToWCIIIAtt removeOriginals =
(
    disableSceneRedraw()
    local animationInterval = animationrange
    animationrange = interval 0 100
    slidertime = 0
    
    local layerName = "Attachments"
    local layer = LayerManager.GetLayerFromName layerName
    if(layer == undefined) then layer = LayerManager.NewLayerFromName layerName
    
    for obj in objects do
    (
        if (classof obj == SC2AttachPt ) then
        (
            format "Changing attachment %\n" obj.name
            local d = undefined
            
            try (
                d = WarcraftIII_Attachment name:obj.name pos:obj.pos parent:obj.parent
            ) 
            catch (
                d = dummy name:obj.name pos:obj.pos parent:obj.parent
            )
            layer.addNode d
            if removeOriginals then delete obj
        )
    )
    animationrange = interval animationInterval.start animationInterval.end
    gc()
    enableSceneRedraw() 
)



ClearListener()
--ConvertSC2AttToWCIIIAtt true

RemoveUnanimatedBones 0



