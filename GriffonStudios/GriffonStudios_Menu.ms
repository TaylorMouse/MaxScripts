fileIn "GriffonStudios_Macros.ms"
fileIn "GriffonStudios_HelperScripts_Struct.ms"
fileIn "GriffonStudios_StarcraftGhost_Macros.ms"

struct GriffonStudios_Menu
(
    function BuildMenu category menus=
    (
        local helpMenuPosition = GriffonStudios_Helpers.GetHelpMenuPosition()
        local seperator = menuMan.createSeparatorItem()
        local mainMenuItems = undefined
        local mainMenu = undefined
        local menuItems = #()
        
        for menu in menus do
        (
            if ( menu[1] == "0" ) then 
            (
                mainMenuItems = menuMan.createMenu (category + " - " + menu[2])
                mainMenu = menuMan.createSubMenuItem (category + " - " + menu[2]) mainMenuItems
                mainMenu.SetTitle (category + " Tools")
                mainMenu.setUseCustomTitle true
            )
            
            if ( menu[1] == "--" ) then append menuItems seperator
            
            if ( menu[1] == "2" ) then append menuItems ( menuMan.createActionItem menu[2] category )
            
            if ( menu[1] == "1" ) then 
            (
                local gsMenuItems = menuMan.createMenu ( category + " - " + menu[2] )

                for submenu in menu[3] do
                (
                    local action = menuMan.createActionItem submenu category
                    gsMenuItems.AddItem action -1
                )
                local gsMenu = menuMan.CreateSubMenuItem (category + " - " + menu[2]) gsMenuItems
                gsMenu.SetTitle menu[2]
                gsMenu.setUseCustomTitle true   
                
                append menuItems gsMenu
            
            )
            
        )
        
        for item in menuItems do mainMenuItems.AddItem item -1
        
        menuBar = menuMan.getMainMenuBar()
        menuBar.addItem mainMenu helpMenuPosition

        menuMan.UpdateMenuBar()
        
        return true
        
    ),
    function RemoveMenus category menus=
    (
        for menu in menus do
        (
            if ( menu[1] == "0" or menu[1] == "1" ) then
            (
                local menuName = category + " - " + menu[2]
                GriffonStudios_Helpers.RemoveMenu menuName
            )
        )
    ),
    function CreateMenu= 
    (
        local menuCategory = "Griffon Studios"
        local menus =
            #(
                /* root menu */
                #("0", "Main", undefined),
                
                /* menus with sub action items */
                #("1", "Diablo III Tools",        #("GriffonStudios_ImportDiabloIIIModel", "GriffonStudios_ImportDiabloIIIAnimation") ),
                #("1", "World Of Warcraft Tools", #("GriffonStudios_WoWSettings", "GriffonStudios_ImportWmoModel", "GriffonStudios_ImportM2StaticModel") ),
                #("1", "Starcraft Ghost Tools",   #("GriffonStudios_ImportStarcraftGhostModel", "GriffonStudios_ImportStarcraftGhostAnimation", "GriffonStudios_ConvertToSC2Materials") ),
                #("1", "Other Tools",             #("GriffonStudios_ShrinkUV2x", "GriffonStudios_GradienMapTool", "GriffonStudios_AnimationSelection") ),
                
                /* seperator */
                #("--", undefined, undefined ),
                
                /* root menu action items */
                #("2", "GriffonStudios_OpenMaxScriptHelp", undefined),
                #("2", "GriffonStudios_About", undefined)
            
            )
        
        GriffonStudios_Menu.RemoveMenus menuCategory menus
        GriffonStudios_Menu.BuildMenu   menuCategory menus

    )
)