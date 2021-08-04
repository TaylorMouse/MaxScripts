/*
    .SYNOPSIS
    | Opens up a popup window for exporting to mdx
    
    .COPYRIGHT
    | ©2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

rollout Warcraft_III_Export_Dialog "Warcraft 3 Export" width:250 height:300
(
    /*
        GLOBAL WC3_VALIDATE_MESHES = false
     if WC3_VALIDATE_MESHES then Warcraft_III_Helpers.ValidateMeshesForExport mdx
    */
    
    
    local workingDir = getdir #temp
    
    function CopyTextures mdx=
    (
        for t in mdx.texs do
        (
            
            local targetFile = fileNameFromPath t.original_path
            if targetFile != "" then 
            (
                local cmd = "xcopy /Y \"" +  t.original_path + "\" \"" +  (getdir #temp) + "\\" + targetFile + "\""
                print cmd
                HiddenDosCommand cmd
            )
        )
        
    )
    
    group "Export Settings"
    (
        button   btn_export          "Export" height:30 width:220
        checkBox cbx_Debugmode       "Debug mode"        tooltip:"This may slow the process but prints out all debug stuff"
        checkbox cbx_InvertUVW       "Invert UV Mapping" tooltip:"Original blp files have their uv coordinates inverted. Check or uncheck this to avoid this problem"
        label lbl_extension          "Texture extension:" align:#left
        dropdownlist ddl_Extension   "" items:#( ".blp",".dds",".tga") height:20 width:80 offset:[140,-20] tooltip:"This does NOT convert the textures, it is how they are referenced in the mdx file" 
    )
    
    group "Preview"
    (
        button   btn_preview          "Preview" height:30 width:220 tooltip:"This will export the model and open up a previewer to see if your model is performing correctly"
        
        
    )
    
    label info "\xa9 2021 Exporter by Taylor Mouse" align:#center
    
    on Warcraft_III_Export_Dialog open do
    (
        filein "GriffonStudios_Warcraft_III_Export.ms"
        filein "GriffonStudios_Warcraft_III_Helpers.ms"
        
        WC3_MDX800_DEBUG = false
        WC3_DEBUG = false
        WC3_INVERT_UVW = false
        ddl_Extension.selection = 1
    )

    on btn_export pressed do
    (
        
        local saveFile = getSaveFileName caption:"Export file location" \
                                         types:"Warcraft III Model (.mdx)|*.mdx|All Files|*.*"\
                                         historyCategory:"WarcraftIIIExportHistory"

        if ( saveFile == undefined ) then return undefined
        
        if cbx_Debugmode.checked then 
        (
            WC3_MDX800_DEBUG = true
            WC3_DEBUG = true
        )
        if cbx_InvertUVW.checked then WC3_INVERT_UVW = true
        
        local startedAt = timestamp()
        local exporter = WC3_MDX800_EXPORTER()
        
        exporter.Export saveFile
        
        local endedAt = timestamp()
        
        txt = "DONE (export took " + (((endedAt - startedAt) / 1000.0 as integer ) as string ) + " seconds )" 
        messagebox txt
        
    )
    
    on btn_preview pressed do
    (
         local exe = "\"" + ( getdir #startupScripts ) + "\\GriffonStudios_Warcraft_III_Tools\\Previewer\\.\""
         local cmd = "xcopy /E /Y " + exe + " \"" + (getdir #temp) + "\""
--         print cmd
--         DosCommand cmd
--         
--         local mdx = WC3_MDX800_EXPORTER.Export tmpFile
--         CopyTextures mdx
         exe = (getdir #temp) + "\\War3ModelPreviewer.exe"
         ShellLaunch exe ""
    )
)
clearlistener()

CreateDialog Warcraft_III_Export_Dialog 
