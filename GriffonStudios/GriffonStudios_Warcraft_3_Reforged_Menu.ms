struct Warcraft3_Reforged_Menu
(
    function RemoveMenu menuName=
    (
        for i = 1 to menuman.numMenus() do
        (
            local mnu = menuman.FindMenu menuName
            if( mnu == undefined ) then
                exit
            else
                menuMan.unRegisterMenu mnu
        )

    ),
    function GetHelpMenuPosition =
    (
        local mainMenu = menuMan.getMainMenuBar() 
        for i=1 to mainMenu.numItems() do
        (
            local title = ((mainMenu.getItem(i)).getTitle())
            if(title == "&Help" ) then return i
        )
        
        return undefined
    ),
    function CreateMenu=
    (
        local mainMenu = menuMan.getMainMenuBar() 

        Warcraft3_Reforged_Menu.RemoveMenu "WC3 Reforged Tools"
        Warcraft3_Reforged_Menu.RemoveMenu "Reforged Helpers"
            
        local wc3Menu = menuMan.createMenu "WC3 Reforged Tools"
        local wc3MenuItems = menuMan.createSubMenuItem "ReforgedToolsSubMenu" wc3Menu
        local wc3Seperator = menuMan.createSeparatorItem()
        
        local subset = "Warcraft 3 Reforged Tools"
        
        local wc3Action1 = menuMan.createActionItem "Warcaft3Reforged_ImportModel" subset
        local wc3Action2 = menuMan.createActionItem "Warcaft3Reforged_ExportModel" subset
        local wc3Action3 = menuMan.createActionItem "Warcaft3Reforged_Animations" subset
        local wc3Action4 = menuMan.createActionItem "Warcaft3Reforged_About" subset
        local wc3Action11 = menuMan.createActionItem "Warcaft3Reforged_Settings" subset
        local wc3Action12 = menuMan.createActionItem "Warcraft3Reforged_ResetAnimationTracks" subset
        
        wc3Action1.SetTitle "Import Model ..."
        wc3Action2.SetTitle "Export Model ..."
        wc3Action3.SetTitle "Animation Selector"
        wc3Action4.SetTitle "About"
        wc3Action11.SetTitle "Settings ..."
        wc3Action12.SetTitle "Reset Animation Tracks"
        
        wc3Action1.setUseCustomTitle true
        wc3Action2.setUseCustomTitle true
        wc3Action3.setUseCustomTitle true
        wc3Action4.setUseCustomTitle true
        wc3Action11.setUseCustomTitle true
        wc3Action12.setUseCustomTitle true

        local helperMenu = menuMan.createMenu "Reforged Helpers"
        local helperMenuItems = menuMan.createSubMenuItem "ReforgedToolsSubMenu" helperMenu
        helperMenuItems.SetTitle "Helpers"
        helperMenuItems.setUseCustomTitle true
        
        local wc3Action5 = menuMan.createActionItem "Warcaft3Reforged_Ribbon" subset
        local wc3Action6 = menuMan.createActionItem "Warcaft3Reforged_Event" subset
        local wc3Action7 = menuMan.createActionItem "Warcaft3Reforged_FaceFX" subset
        local wc3Action8 = menuMan.createActionItem "Warcaft3Reforged_Attachment" subset
        local wc3Action9 = menuMan.createActionItem "Warcaft3Reforged_Particles" subset
        local wc3Action10 = menuMan.createActionItem "Warcaft3Reforged_PopCorn" subset

        wc3Action5.SetTitle "Create Ribbon"
        wc3Action6.SetTitle "Create Event"
        wc3Action7.SetTitle "Create Face FX"
        wc3Action8.SetTitle "Create Attachment"
        wc3Action9.SetTitle "Create Particle Emitter"
        wc3Action10.SetTitle "Create Popcorn Effect"

        wc3Action5.setUseCustomTitle true
        wc3Action6.setUseCustomTitle true
        wc3Action7.setUseCustomTitle true
        wc3Action8.setUseCustomTitle true
        wc3Action9.setUseCustomTitle true
        wc3Action10.setUseCustomTitle true

        helperMenu.addItem wc3Action5 1
        helperMenu.addItem wc3Action6 2
        helperMenu.addItem wc3Action7 3
        helperMenu.addItem wc3Action8 4
        helperMenu.addItem wc3Action9 5
        helperMenu.addItem wc3Action10 6

        wc3Menu.addItem wc3Action1 -1
        wc3Menu.addItem wc3Action2 -1
        wc3Menu.addItem wc3Action3 -1
        wc3Menu.addItem helperMenuItems -1
        wc3Menu.addItem wc3Seperator -1
        wc3Menu.addItem wc3Action11 -1
        wc3Menu.addItem wc3Action12 -1
        wc3Menu.addItem wc3Action4 -1
        
        local pos = Warcraft3_Reforged_Menu.GetHelpMenuPosition()
        
        mainMenu.AddItem wc3MenuItems pos
        
        menuMan.updateMenuBar()
        
    )
    
)

