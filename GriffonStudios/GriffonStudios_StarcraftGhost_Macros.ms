/*
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Starcraft Ghost Macros

*/
fileIn "GriffonStudios_StarcraftGhost_Dialog.ms"

macroscript GriffonStudios_ImportStarcraftGhostModel
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Import Model"
    toolTip:"Import Starcraft Ghost model (.nod, .noc)"
(
    on execute do
    (
        createDialog GriffonStudios_StarcraftGhostModelImport_Rollout
    )
)

macroscript GriffonStudios_ImportStarcraftGhostAnimation
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Import Animation(s)"
    toolTip:"Import Starcraft Ghost animation(s)"
(
    on execute do
    (
        createDialog GriffonStudios_StarcraftGhostAnimationsImport_Rollout
    )
)