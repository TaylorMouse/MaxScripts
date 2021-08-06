/*
    .SYNOPSIS
    | Opens up a popup window for exporting to mdx
    
    .COPYRIGHT
    | ©2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

rollout Warcraft_III_Tools_Dialog "Warcraft 3 Tools" width:250 height:500
(
    /*
        GLOBAL WC3_VALIDATE_MESHES = false
     if WC3_VALIDATE_MESHES then Warcraft_III_Helpers.ValidateMeshesForExport mdx
    */

    local workingDir = getdir #temp
    local configFile = (getdir #temp) + "\\wc3tools.config"
    local rotation_keys_to_keep = #()
    local position_keys_to_keep = #()
    local scale_keys_to_keep = #()
    
    group "Settings"
    (
        checkBox     cbx_Debugmode   "Debug mode"        tooltip:"This may slow the process but prints out all debug stuff"
        
        label        lbl_sharedTextureFolder "Shared texture folder" align:#left
        edittext     txt_sharedTextureFolder "" width:210 height:25 align:#left offset:[-5,0]
        button       btn_browseSharedTextures "..." width:20 height:25 align:#right offset:[5,-30]
    )
    
    group "Import"
    (
        button       btn_import      "Import mdx (800)" height:30 width:220
    )
    
    group "Export"
    (
        button       btn_export      "Export mdx (800)"     height:30 width:220
        checkbox     cbx_InvertUVW   "Invert UV Mapping"    tooltip:"Original blp files have their uv coordinates inverted. Check or uncheck this to avoid this problem"
        label        lbl_extension   "Texture extension:"   align:#left
        dropdownlist ddl_Extension   "" items:#( ".blp",".dds",".tga") height:20 width:80 offset:[140,-20] tooltip:"This does NOT convert the textures, it is how they are referenced in the mdx file" 
    )
    
    group "Animation Tools"
    (
        button btn_getallkeys          "Gather all animation keys"  height:30 width:220 tooltip:"Gather a list of animation keys for all selected objects, do this prior to deleting the generated keys"
        
        label lbl_maxinterval          "Max Frame Interval:" align:#left
        spinner spn_frameinterval      "" type:#integer range:[0,20,5] offset:[-40,-20]  width:50 tooltip:"Baked keys too far apart may introduce issues, set to zero if not needed, else set this to a specific interval"
        
        button btn_reducekeys          "Reduce baked keys" height:30 width:220 tooltip:"Reduce the newly generated keys created by the bake and limit it to the previously set"
        
    )
    
    group "Material Tools"
    (
        button btn_create_tc_material "Create a Team Color Material" height:30 width:220 tooltip:"Add a team colored material in the material editor"
        button btn_clean_material_editor "Clean up the material editor" height:30 width:220 tooltip:"Clean up the material editor and fill only with scene materials"
    )
    
    label info "\xa9 2021 Warcraft III Tools by Taylor Mouse" align:#center
    
    
    
    on Warcraft_III_Tools_Dialog open do
    (

        /* Required plugins */
        fileIn "GriffonStudios_Warcraft_III_Plugins_ParticleEmitter.ms"
        fileIn "GriffonStudios_Warcraft_III_Plugins_Attachment.ms"
        fileIn "GriffonStudios_Warcraft_III_Plugins_Material.ms"
        fileIn "GriffonStudios_Warcraft_III_Plugins_Event.ms"
        fileIn "GriffonStudios_Warcraft_III_Plugins_Ribbon.ms"
        fileIn "GriffonStudios_Warcraft_III_Plugins_Behavior.ms"

        /* Helper methods */
        fileIn "GriffonStudios_Warcraft_III_Helpers.ms"
        fileIn "GriffonStudios_Helpers.ms"
        
        /* Main methods*/
        filein "GriffonStudios_Warcraft_III_Import.ms"
        filein "GriffonStudios_Warcraft_III_Export.ms"

        
        WC3_MDX800_DEBUG = false
        WC3_DEBUG = false
        WC3_INVERT_UVW = false
        ddl_Extension.selection = 1
        
        local sharedFolder = getinisetting configFile "WarcraftIII" "SharedTextureFolder"
        if sharedFolder == undefined then txt_sharedTextureFolder.text = "" else txt_sharedTextureFolder.text = sharedFolder
        
    )

    on btn_browseSharedTextures pressed do
    (
        local sharedFolder = getSavePath caption:"Select Shared Teture Folder" initialDir:(txt_sharedTextureFolder.text)
        if ( sharedFolder != undefined) then 
        (
            sharedFolder = sharedFolder  + "\\"   
            txt_sharedTextureFolder.text = sharedFolder 
            setIniSetting configFile "WarcraftIII" "SharedTextureFolder" sharedFolder
        )
    )
    on btn_clean_material_editor pressed do
    (
        for i=1 to 24 do meditmaterials[i] = Standard()
        
        scene_materials = #()
        for obj in objects do
            if ( obj.material != undefined ) then appendIfUnique scene_materials obj.material
    
        for i=1 to scene_materials.count do
        (
            meditmaterials[i] = scene_materials[i]
        )

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
        
        WC3_TEXTURE_EXPORT_EXTENSION = ddl_Extension.text
        
        format "Extension is set to%\n" ddl_Extension.text
        
        local startedAt = timestamp()
        local exporter = WC3_MDX800_EXPORTER()
        
        exporter.Export saveFile
        
        local endedAt = timestamp()
        
        txt = "DONE (export took " + (((endedAt - startedAt) / 1000.0 as integer ) as string ) + " seconds )" 
        messagebox txt
        
    )
    
    on btn_import pressed do
    (
        
        file = getOpenFileName caption:"Import MDX" types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|" historyCategory:"ImportWarcraftIIImdx"

        if ( file != undefined and doesfileexist file ) then 
            WC3_MDX800.Import file
        
    )
    on btn_getallkeys pressed do
    (
        rotation_keys_to_keep = #()
        position_keys_to_keep = #()
        scale_keys_to_keep = #()
        for obj in selection do
        (
            if classof obj != bonegeometry and classof obj != SplineShape then 
            (
                format "Skipping object : %\n" obj.name (classof obj )
                continue
                
            )
            if ( classof obj.pos.controller == position_list ) then (
                for i=1 to obj.pos.controller.count do (
                    for key in obj.pos.controller[i].keys do
                        appendifunique position_keys_to_keep ( key.time as integer / ticksperframe )
                )
            )
            if ( classof obj.pos.controller == Position_XYZ ) then (
                    for key in obj.pos.controller.keys do
                        appendifunique position_keys_to_keep ( key.time as integer / ticksperframe )
            )
            if ( classof obj.rotation.controller == rotation_list ) then (
                for i=1 to obj.rotation.controller.count do (
                    for key in obj.rotation.controller[i].keys do
                        appendifunique rotation_keys_to_keep ( key.time as integer / ticksperframe )
                )
            )
            if ( classof obj.rotation.controller == Euler_XYZ ) then (
                    for key in obj.rotation.controller.keys do
                        appendifunique rotation_keys_to_keep ( key.time as integer / ticksperframe )
            )
            if ( classof obj.scale.controller == scale_list ) then (
                for i=1 to obj.scale.controller.count do (
                    for key in obj.scale.controller[i].keys do
                        appendifunique scale_keys_to_keep ( key.time as integer / ticksperframe )
                )
            )
            if ( classof obj.scale.controller == Bezier_Scale ) then (
                    for key in obj.scale.controller.keys do
                        appendifunique scale_keys_to_keep ( key.time as integer / ticksperframe )
            )

        )
        position_keys_to_keep = sort position_keys_to_keep
        rotation_keys_to_keep = sort rotation_keys_to_keep
        scale_keys_to_keep = sort scale_keys_to_keep
        
        format "Number of Position keys: %\nNumber of Rotation keys: %\nNumber of Scale Keys: %\n" position_keys_to_keep.count rotation_keys_to_keep.count scale_keys_to_keep.count

        all_keys = sort ( makeUniqueArray ( position_keys_to_keep + rotation_keys_to_keep + scale_keys_to_keep ) )
        
        print all_keys
    )
    on btn_reduceKeys pressed do
    (
        all_keys = sort ( makeUniqueArray ( position_keys_to_keep + rotation_keys_to_keep + scale_keys_to_keep ) )
        
        if all_keys == undefined or all_keys.count <= 1 then return undefined
            
        if spn_frameinterval.value > 0 and all_keys.count > 1 then
        (
            local current_key = 0
            local last_key = all_keys[all_keys.count]
            
            while ( current_key <= last_key ) do
            (    
                appendIfUnique all_keys current_key
                current_key = current_key + spn_frameinterval.value
            )
            all_keys = sort all_keys
        )
        
        keys_to_keep = all_keys
        
        for obj in selection do
        (
            format "Reducing keys for %\n" obj.name
            
            for key in all_keys do
                at time key 
                (
                    addNewKey obj.pos.controller key
                    addNewKey obj.rotation.controller key
                    addNewKey obj.scale.controller key
                )

            deselectKeys obj.pos.controller
            deselectKeys obj.rotation.controller
            deselectKeys obj.scale.controller
            
            for i=1 to obj.pos.controller.keys.count do
            (
                local key = obj.pos.controller.keys[i]
                if key == undefined then continue
                local foundIt = findItem keys_to_keep key.time
                if foundit == 0 then selectKeys obj.pos.controller key.time
            )
            deleteKeys obj.pos.controller #selection
            deselectKeys obj.pos.controller
            
            for i=1 to obj.rotation.controller.keys.count do
            (
                local key = obj.rotation.controller.keys[i]
                if key == undefined then continue
                local foundIt = findItem keys_to_keep key.time
                if foundit == 0 then selectKeys obj.rotation.controller key.time
            )
            deleteKeys obj.rotation.controller #selection
            deselectKeys obj.rotation.controller
            
            
            for i=1 to obj.scale.controller.keys.count do
            (
                local key = obj.scale.controller.keys[i]
                if key == undefined then continue
                local foundIt = findItem keys_to_keep key.time
                if foundit == 0 then selectKeys obj.scale.controller key.time
            )
            deleteKeys obj.scale.controller #selection
            deselectKeys obj.scale.controller

            
            
        )
        
        
    )
)
--CreateDialog Warcraft_III_Tools_Dialog
