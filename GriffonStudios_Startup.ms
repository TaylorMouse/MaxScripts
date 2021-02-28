/* 
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Call the necessary scripts from here that need to start up
        
*/

global STARCRAFT_II_ARTTOOLS_INSTALLED = false

fileIn "GriffonStudios\\GriffonStudios_HelperScripts.ms"
fileIn "GriffonStudios\\GriffonStudios_HelperScripts_Struct.ms" --> new approach

fileIn "GriffonStudios\\GriffonStudios_Menu.ms"

fileIn "GriffonStudios\\GriffonStudios_WoW_M2_Import_v3.3.ms"
fileIn "GriffonStudios\\GriffonStudios_Starcraft_HotS_M3_Import_v3.5.ms"

gs = GriffonStudios_Menu()
gs.CreateMenu()

try ( 
    test = SC2_Standard_Material() 
    STARCRAFT_II_ARTTOOLS_INSTALLED = true
) catch()
    

-- flat color
actionMan.executeAction 0 "554"  -- Views: Viewport Visual Style Consistent Colors
actionMan.executeAction 0 "618"  -- Tools: Use Solid Colors Toggle