/*
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Start necessary scripts
*/

fileIn "GriffonStudios\\GriffonStudios_Macros.ms"
filein "Starcraft Ghost\\GriffonStudios_StarcraftGhost_Macros.ms"

struct GriffonStudios_Menu
(
    function CreateMenu=
    (
        local category = "Griffon Studios"

        /* remove existing menu */
        GriffonStudios_Helpers.RemoveMenu "Griffon Studios - Main"
        GriffonStudios_Helpers.RemoveMenu "Griffon Studios - Diablo III Tools"
        GriffonStudios_Helpers.RemoveMenu "Griffon Studios - World Of Warcraft Tools"
        GriffonStudios_Helpers.RemoveMenu "Griffon Studios - Starcraft Ghost"
        GriffonStudios_Helpers.RemoveMenu "Griffon Studios - Help"

        /* get the Help menu position*/
        helpMenuPosition = GriffonStudios_Helpers.GetHelpMenuPosition()

        /* generic separator menu item*/
        separator = menuMan.createSeparatorItem()

        /* root menu */
        gsMenuItems = menuMan.createMenu "Griffon Studios - Main"

        /* define root actions */
        actionOpenMaxScriptHelp = menuman.createActionItem "GriffonStudios_OpenMaxScriptHelp" category
        actionOpenAbout = menuMan.createActionItem "GriffonStudios_About" category

        
        /* Starcraft Ghost Tools */
        ghostSubMenu = menuMan.creatrMenu "Griffon Studios - Starcraft Ghost Tools"
        ghostImportModel = menuMan.createActionItem "GriffonStudios_ImportStarcraftGhostModel" category
        ghostImportAnimation = menuMan.createActionItem "GriffonStudios_ImportStarcraftGhostAnimation" category

        ghostSubMenu.AddItem ghostImportModel -1
        ghostSubMenu.AddItem ghostImportAnimation -1

        ghostMenu = menuMan.CreateSubMenuItem "Griffon Studios - Starcraft Ghost Tools" ghostSubMenu
        ghostMenu.SetTitle "Starcraft Ghost Tools"
        ghostMenu.setUseCustomTitle true


        /* Diablo III Tools */
        gsDiabloMenuItems = menuMan.createMenu "Griffon Studios - Diablo III Tools"

        actionDiabloImportModel = menuMan.createActionItem "GriffonStudios_ImportDiabloIIIModel" category
        actionDiabloImportAnimation = menuMan.createActionItem "GriffonStudios_ImportDiabloIIIAnimation" category

        gsDiabloMenuItems.AddItem actionDiabloImportModel -1
        gsDiabloMenuItems.AddItem actionDiabloImportAnimation -1

        gsDiabloMenu = menuMan.CreateSubMenuItem "Griffon Studios - Diablo III Tools" gsDiabloMenuItems
        gsDiabloMenu.SetTitle "Diablo III Tools"
        gsDiabloMenu.setUseCustomTitle true

        /* World Of Warcraft Tools */
        gsWoWMenuItems = menuMan.createMenu "Griffon Studios - World Of Warcraft Tools"

        actionWmoImportModel = menuMan.createActionItem "GriffonStudios_ImportWmoModel" category
        actionM2StaticImportModel = menuMan.createActionItem "GriffonStudios_ImportM2StaticModel" category


        gsWoWMenuItems.AddItem actionWmoImportModel -1
        gsWoWMenuItems.AddItem actionM2StaticImportModel -1


        gsWoWMenu = menuMan.CreateSubMenuItem "Griffon Studios - World Of Warcraft Tools" gsWoWMenuItems
        gsWoWMenu.SetTitle "World of Warcraft Tools"
        gsWoWMenu.setUseCustomTitle true

        /* create a Help menu items EXAMPLE */
        gsHelpMenuItems = menuMan.createMenu "Griffon Studios - Help"
        openTest = menuMan.createActionItem "GriffonStudios_TestMacroScript" category
        gsHelpMenuItems.AddItem openTest -1

        gsHelpMenu = menuMan.CreateSubMenuItem "Griffon Studios - Help" gsHelpMenuItems
        gsHelpMenu.SetTitle "Help"
        gsHelpMenu.setUseCustomTitle true

        /* create a settings menu root item  */
        actionWoWSettings = menuMan.createActionItem "GriffonStudios_WoWSettings" category
        actionShrinkUV = menuMan.CreateActionItem "GriffonStudios_ShrinkUV2x" category
        actionGradientTool = menuMan.CreateActionItem "GriffonStudios_GradienMapTool" category

        /* build the menu structure*/
        gsMenuItems.AddItem gsDiabloMenu -1
        gsMenuItems.AddItem ghostMenu -1
        gsMenuItems.AddItem gsWoWMenu -1
        gsMenuItems.AddItem separator -1
        gsMenuItems.AddItem actionWoWSettings -1
        gsMenuItems.AddItem actionShrinkUV -1
        gsMenuItems.AddItem actionGradientTool -1 
        gsMenuItems.AddItem actionOpenMaxScriptHelp -1
        gsMenuItems.AddItem actionOpenAbout -1


        /* create the menu based on the menu items previously created */
        mainMenu = menuMan.getMainMenuBar()
        gsMenu = menuMan.createSubMenuItem "Griffon Studios - Main" gsMenuItems
        gsMenu.SetTitle "Griffon Studios Tools"
        gsMenu.setUseCustomTitle true




        /* add the menu to the menu bar */
        mainMenu.addItem gsMenu helpMenuPosition



        menuMan.UpdateMenuBar()
    )
)