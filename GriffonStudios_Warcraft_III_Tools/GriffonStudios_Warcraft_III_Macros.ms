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
    category:"Warcraft III Tools"
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
    category:"Warcraft III Tools"
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
/* set or unset an object as a collision object */
macroScript GriffonStudios_ToggleCollisionObject
    category:"Warcraft III Tools"
    internalcategory:"Griffon Studios Tools"
    buttonText:"Toggle collision objects"
    toolTip:"Toggle all collision object"
    icon:#("GriffonStudios",4)
(
    on execute do (
    
        for obj in objects do
        (
            if ( getUserProp obj "COLLISION-OBJECT" == true ) then 
            (
                if obj.boxmode == true then 
                (
                    obj.boxmode = false
                    unfreeze obj
                    
                )
                else
                (
                    obj.boxmode = true
                    obj.wirecolor = color 64 128 255
                    obj.renderable = off
                    obj.castShadows = off
                    obj.receiveshadows = off
                    freeze obj
                )
            )
        )
    )
)

/* opens the User Property window */
macroScript GriffonStudios_UserPropertyWindow
    category:"Warcraft III Tools"
    internalcategory:"Griffon Studios Tools"
    buttonText:"Show User Property Window"
    toolTip:"Show User Property Window"
    icon:#("GriffonStudios",5)
(
    on execute do (
        if ( $ == undefined ) then 
        (
            messagebox "Please select an object first"
            return undefined
        )
        if ( $ != undefined ) then 
        (
        
            if(GriffonStudios_Warcraft_III_UserPropertyEditor != undefined) then destroydialog GriffonStudios_Warcraft_III_UserPropertyEditor
                CreateDialog GriffonStudios_Warcraft_III_UserPropertyEditor lockwidth: true  
        )
    )
)

/* opens the User Tools window */
macroScript GriffonStudios_WC3ToolsWindow
    category:"Warcraft III Tools"
    internalcategory:"Griffon Studios Tools"
    buttonText:"Show Warcraft III Tools Window"
    toolTip:"Show Warcraft III Tools Window"
    icon:#("GriffonStudios",6)
(
    on execute do (
        if(Warcraft_III_Tools_Dialog != undefined) then 
            Destroydialog Warcraft_III_Tools_Dialog
        CreateDialog Warcraft_III_Tools_Dialog lockwidth: true  
    )
)