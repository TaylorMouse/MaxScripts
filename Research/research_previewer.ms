/*
    test previewer
*/

(
    local previewerPath = @"F:\Blizzard\Warcraft III\War3ModelEditor-Bogdan\War3ModelEditor.exe"
    
    file = getSaveFileName caption:"Export MDX" \
                           types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|" \
                           historyCategory:"ExportWarcraftIIImdx"
    
    WC3_MDX800_DEBUG = false
    MDX_EXPORT = undefined
    WC3_INVERT_UVW = false
    WC3_TEXTURE_EXPORT_EXTENSION = ".blp" --> .blp, .dds, .tga have been tested
    WC3_VALIDATE_MESHES = false
    
    WC3_MDX800_EXPORTER.Export file
    local params = file
 
    format "%\n" previewerPath
    format "%\n" file
    
    doscommand ("f:")
    doscommand (previewerPath + " " + "anduin.mdx")
    
    --ShellLaunch previewerPath ( "'" + params  + "'" )
    
    
)