/* 
    .SYNOPSIS
    | Install Warcraft III Tools Menu
        
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse
        
*/

/* Animation Sequence Window */
macroscript Animation_Window 
	category:"Griffon Studios Tools" 
    internalcategory:"Griffon Studios Tools"
	tooltip:"Animation Window" 
    buttonText:"Animation Window"
    icon:#("GriffonStudios",1)
(
    on execute do (
        if(GriffonStudios_AnimationWindow != undefined) then destroydialog GriffonStudios_AnimationWindow
            CreateDialog GriffonStudios_AnimationWindow lockwidth: true      
    )
)

/* Import an mdx model */
macroScript GriffonStudios_ImportWarcraftIIIMdx800
    category:"Griffon Studios Tools"
    internalcategory:"Griffon Studios Tools"
    buttonText:"Import Warcraft III Model"
    toolTip:"Import a 3D Model (.mdx) from Warcraft III version 800"
    icon:#("GriffonStudios",2)
(
    on execute do (
        file = getOpenFileName caption:"Import MDX" types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|" historyCategory:"ImportWarcraftIIImdx"

        if ( file != undefined and doesfileexist file ) then 
            WC3_MDX800.Import file
    )
)

/* Export an mdx model */
macroScript GriffonStudios_ExportWarcraftIIIMdx800
    category:"Griffon Studios Tools"
    internalcategory:"Griffon Studios Tools"
    buttonText:"Export Warcraft III Model"
    toolTip:"Export a 3D Model (.mdx) from Warcraft III version 800"
    icon:#("GriffonStudios",3)
(
    on execute do (
        file = getSaveFileName caption:"Export MDX" types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|" historyCategory:"ExportWarcraftIIImdx"
        
        WC3_MDX800_EXPORTER.Export file
    )
)