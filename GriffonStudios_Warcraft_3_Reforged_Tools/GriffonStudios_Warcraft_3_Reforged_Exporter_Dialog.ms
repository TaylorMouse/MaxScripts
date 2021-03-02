/*
    .SYNOPSIS
    | Opens up a popup window for exporting to mdx
    
    .COPYRIGHT
    | ©2020 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/
GLOBAL WC3_DEBUG = false

rollout GriffonStudios_WC3_ExportDialog "Warcraft 3 Reforged Export" height:180 width:250
(
    
    group "Export"
    (
        
        checkBox chkCopyTextures "Copy textures to export folder"
        checkBox chkDebugmode "Debug mode"
        button btn_export "Export" height:30 width:150
    )
    
    label info "\xa9 2020 Exporter by Taylor Mouse" align:#center
    
    on GriffonStudios_WC3_ExportDialog open do
    (
        chkCopyTextures.checked = true
    )

    on btn_export pressed do
    (
        filein "GriffonStudios_Warcraft_3_Reforged_Exporter.ms"
        local saveFile = getSaveFileName caption:"Export file location" \
                                         types:"Warcraft III Reforged Model (.mdx)|*.mdx|All Files|*.*"\
                                         historyCategory:"WC3RefExportHistory"

        local startedAt = timestamp()
        local exporter = GriffonStudios_Warcraft_3_Reforged_Exporter()

        exporter.Export saveFile
        
        local endedAt = timestamp()
        
        txt = "DONE (export took " + (((endedAt - startedAt) / 1000.0 as integer ) as string ) + " seconds )" 
        messagebox txt
        destroydialog GriffonStudios_WC3_ExportDialog
    )
)
