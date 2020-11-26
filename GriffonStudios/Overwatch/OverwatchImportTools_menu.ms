fileIn "OverwatchImportTools_importmodel_dialog.ms"
fileIn "OverwatchImportTools_importanimation_dialog.ms"
fileIn "OverwatchImportTools_importmultianimation_dialog.ms"
fileIn "TMsHelperScripts.ms"
fileIn "TMsAnimationProperties.ms"
fileIn "OverwatchImportTools_macros.ms"


function GriffonStudios_RemoveMenu menuName=
(
	for i = 1 to menuman.numMenus() do
    (
        local mnu = menuman.FindMenu menuName
        if( mnu == undefined ) then
            exit
        else
            menuMan.unRegisterMenu mnu
    )

)

function GriffonStudios_GetHelpMenuPosition =
(
    local mainMenu = menuMan.getMainMenuBar() 
    for i=1 to mainMenu.numItems() do
    (
        local title = ((mainMenu.getItem(i)).getTitle())
        if(title == "&Help" ) then return i
    )
    
    return undefined
)

/* get the position of the help menu, to position our menu in front of it */
function CreateOverwatchToolsMenu=
(
    local mainMenu = menuMan.getMainMenuBar() 

    GriffonStudios_RemoveMenu "Overwatch Tools"
        
    local owMenu = menuMan.createMenu "Overwatch Tools"
    local owMenuItems = menuMan.createSubMenuItem "OverwatchToolsSubMenu" owMenu
    local owSeperator = menuMan.createSeparatorItem()
    
    owAction1 = menuMan.createActionItem "ImportModel" "OverwatchImportTools"
    owAction2 = menuMan.createActionItem "ImportSingleAnim" "OverwatchImportTools"
    owAction3 = menuMan.createActionItem "ImportMultiAnim" "OverwatchImportTools"
    owAction4 = menuMan.createActionItem "AnimationProperties" "OverwatchImportTools"
    owAction5 = menuMan.createActionItem "OverwatchAboutWindow" "OverwatchImportTools"
    owAction6 = menuMan.createActionItem "FixAnimationAxisUp" "OverwatchImportTools"
    
    owAction1.SetTitle "Import Model"
    owAction2.SetTitle "Import Single Animation"
    owAction3.SetTitle "Import Muliple Animations"
    owAction4.SetTitle "Open Animation Selection"
    owAction5.SetTitle "About"
    owAction6.SetTitle "Fix Animation Up Axis"
    
    owAction1.setUseCustomTitle true
    owAction2.setUseCustomTitle true
    owAction3.setUseCustomTitle true
    owAction4.setUseCustomTitle true
    owAction5.setUseCustomTitle true
    owAction6.setUseCustomTitle true
    
    owMenu.addItem owAction1 1
    owMenu.addItem owAction2 2
    owMenu.addItem owAction3 3
    owMenu.addItem owSeperator 4
    owMenu.addItem owAction6 5
    owMenu.addItem owAction4 6
    owMenu.addItem owAction5 7
    
	pos = GriffonStudios_GetHelpMenuPosition()
	
    mainMenu.AddItem owMenuItems pos
    
    menuMan.updateMenuBar()
    
)