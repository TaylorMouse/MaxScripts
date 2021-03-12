/*
    .SYNOPSIS
    | Opens up a popup window for exporting to mdx
    
    .COPYRIGHT
    | ©2020 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/


rollout GriffonStudios_WC3_ExportDialog "Warcraft 3 Reforged Export" width:250
(
    
    group "Export"
    (
        label    lbl01              "Texture Path:" align:#left
        edittext txt_texturePath    "" width:230 height:20 align:#left offset:[-5,0]
        checkBox chkUseBlack32      "Map to standard black32.dds"
        checkBox chkUseEnvMap       "Map to standard EnvironmentMap.dds"
        checkBox chkDebugmode       "Debug mode"
        button   btn_export         "Export" height:30 width:150
    )
    
    label info "\xa9 2020 Exporter by Taylor Mouse" align:#center
    
    on GriffonStudios_WC3_ExportDialog open do
    (
        txt_texturePath.text = TEXTURE_PATH
    )

    on btn_export pressed do
    (
        struct _config ( debug_mode, useBlack32, useEnvMap, base_texture_path )

        filein "GriffonStudios_Warcraft_3_Reforged_Exporter.ms"
        local saveFile = getSaveFileName caption:"Export file location" \
                                         types:"Warcraft III Reforged Model (.mdx)|*.mdx|All Files|*.*"\
                                         historyCategory:"WC3RefExportHistory"

        local startedAt = timestamp()
        local exporter = GriffonStudios_Warcraft_3_Reforged_Exporter()

        local cfg = _config debug_mode:chkDebugmode.checked \
                            useBlack32:chkUseBlack32.checked \
                            useEnvMap:chkUseEnvMap.checked \
                            base_texture_path:txt_texturePath.text
        
        exporter.Export saveFile cfg
        
        local endedAt = timestamp()
        
        txt = "DONE (export took " + (((endedAt - startedAt) / 1000.0 as integer ) as string ) + " seconds )" 
        messagebox txt
        destroydialog GriffonStudios_WC3_ExportDialog
    )
)
