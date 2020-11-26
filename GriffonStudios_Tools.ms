/*
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Start necessary scripts
*/

/* 
    HELPER SCRIPTS
*/
fileIn "GriffonStudios\\GriffonStudios_HelperScripts.ms"

/* 
    MENUS 
*/
fileIn "GriffonStudios\\GriffonStudios_Menu.ms"
fileIn "GriffonStudios\\GriffonStudios_Warcraft_3_Reforged_Menu.ms"

wc3ref = Warcraft3_Reforged_Menu()
wc3ref.CreateMenu()

gsTools = GriffonStudios_Menu()
gsTools.CreateMenu()

/* 
    UTILITIES
*/
fileIn "GriffonStudios\\GriffonStudios_WoW_M2_Import_v3.3.ms"
fileIn "GriffonStudios\\GriffonStudios_Starcraft_HotS_M3_Import_v3.5.ms"

global STARCRAFT_II_ARTTOOLS_INSTALLED = false

try ( 
    local mat = SC2_Standard_Material() 
    STARCRAFT_II_ARTTOOLS_INSTALLED = true
) 
catch ("NOTE: Starcraft II Art Tools are not installed")

clearListener()