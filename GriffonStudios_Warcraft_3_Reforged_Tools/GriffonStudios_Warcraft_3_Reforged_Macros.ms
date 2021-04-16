global Warcraft3_AssetFolder
global Warcraft3_ImportAllLOD = false
global Warcraft3_ConvertToSC2

macroscript Warcaft3Reforged_ImportModel category:"Warcraft 3 Reforged Tools" tooltip:"Import model" 
(
    rollout ImportWindow "Warcraft 3 Reforged Import (v1.0)"
    (
        group "Select mdx file:"
        (
            edittext txtSelectedFile width:270 align:#left offset:[-5,0]
            button btnBrowse "..." align:#right offset:[3,-25]
        )
        group "Options"
        (
            checkbox chkImportAllLOD "Import all Level of Details (LOD's)"
            checkbox chkConvertToSC2 "Convert to SC2 Compatible"
        )

        label lbl1 "©2020" align:#center
        label lbl2 "Taylor Mouse"  align:#center
        button btnClose "Close" height:30 width:80 offset:[115,-35]
        button btnImport "Import" height:30 width:80 offset:[-115,-35]
        
        on btnClose pressed do destroydialog ImportWindow
        on chkImportAllLOD changed theState do (
            Warcraft3_ImportAllLOD = theState
            format "Import all LOD's: %\n" Warcraft3_ImportAllLOD
        )
        on chkConvertToSC2 changed theState do (
            Warcraft3_ConvertToSC2 = theState
            format "Import SC2 Conversion: %\n" Warcraft3_ConvertToSC2
        )
        
        on ImportWindow open do
        (
            Warcraft3_ImportAllLOD = false
            Warcraft3_ConvertToSC2 = false
            
        )    
        
        on btnBrowse pressed do
        (
            local file = getOpenFileName \
                        caption:"Warcraft 3 Reforged" \
                        types:"Supported Files|*.mdx|Warcraft 3 Reforged(*.mdx)|*.mdx|All Files|*.*" \
                        historyCategory:"ReforgedPreset"
            if (file != undefined) then 
                if (doesfileexist file == true ) then 
                    txtSelectedFile.Text = file
        )
        on btnImport pressed do
        (
            fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"
            local file = txtSelectedFile.Text
            if (doesfileexist file == true ) then 
                Warcraft3_Reforged.Import file
            else
                MessageBox "Please select a correct or existing file!" 
            
        )
        
        on ImportWindow open do
        (
            if ( STARCRAFT_II_ARTTOOLS_INSTALLED == false ) then 
                chkConvertToSC2.enabled = false

        )
    )
    if(ImportWindow != undefined) then destroydialog ImportWindow
        CreateDialog ImportWindow width:320 lockwidth: true 
    
)

macroscript Warcraft3Reforged_ResetAnimationTracks category:"Warcraft 3 Reforged Tools" tooltip:"Reset Animation Tracks"
(
    local nNoteTracks = numNoteTracks rootNode
        
    if(  nNoteTracks > 0 ) then
    (
        for n=1 to nNoteTracks do 
            deleteNoteTrack rootNode (getNoteTrack rootNode 1)
    )
)

macroscript Warcaft3Reforged_Settings category:"Warcraft 3 Reforged Tools" tooltip:"Settings" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"
    local workingDir = getdir #temp
    
    rollout SettingsWindow "Warcraft 3 Reforged Settings"
    (
        group "Root asset folder"
        (
            edittext txtRootAssetFolder width:270 align:#left offset:[-5,0]
            button btnBrowse "..." align:#right offset:[3,-25]
        )
        button btnCancel "Cancel" height:30 width:80 offset:[115,0]
        button btnSave "Save & Close" height:30 width:80 offset:[-115,-35]
        
        on btnCancel pressed do destroydialog SettingsWindow
        
        on btnBrowse pressed do
        (
            local assetFolder = getSavePath caption:"Select Asset Root Folder" initialDir:Warcraft3_AssetFolder
            if ( assetFolder != undefined) then 
                txtRootAssetFolder.text = assetFolder  + "\\"
        )
        
        on btnSave pressed do 
        (
            local assetFolder = txtRootAssetFolder.text
            if ( assetFolder != undefined) then 
            (
                local iniFile = workingDir + "\\wc3ref.config"
                setinisetting iniFile "Warcraft3Reforged" "AssetFolder" assetFolder
                Warcraft3_AssetFolder = assetFolder 
            )
            destroydialog SettingsWindow
        )
        
        on SettingsWindow open do
        (
            local iniFile = workingDir + "\\wc3ref.config"
            
            local assetFolder = getinisetting iniFile "Warcraft3Reforged" "AssetFolder"
            if assetFolder == undefined then txtRootAssetFolder.text = "" else txtRootAssetFolder.text = assetFolder
            Warcraft3_AssetFolder = assetFolder   
            
        )    
    )
    if(SettingsWindow != undefined) then destroydialog SettingsWindow
        CreateDialog SettingsWindow width:320 lockwidth: true 
    
)

macroscript Warcaft3Reforged_ExportModel category:"Warcraft 3 Reforged Tools" tooltip:"Export model" 
(
    filein "GriffonStudios_Warcraft_3_Reforged_Exporter_Dialog.ms"
    if(GriffonStudios_WC3_ExportDialog != undefined) then destroydialog GriffonStudios_WC3_ExportDialog
        CreateDialog GriffonStudios_WC3_ExportDialog lockwidth: true
)

macroscript Warcaft3Reforged_Animations category:"Warcraft 3 Reforged Tools" tooltip:"Animation Selector" 
(
    filein "GriffonStudios_Warcraft_3_Reforged_AnimationProperties.ms"
    if(GriffonStudios_WC3_AnimationProperties != undefined) then destroydialog GriffonStudios_WC3_AnimationProperties
        CreateDialog GriffonStudios_WC3_AnimationProperties lockwidth: true     
)

macroscript Warcaft3Reforged_About 
    category:"Warcraft 3 Reforged Tools" 
    tooltip:"About"
(
    if ( aboutWindow != undefined ) then destroydialog aboutWindow
    
    rollout aboutWindow "Warcraft 3 Reforged Tools" 
    (
        label lbl1 "©2020~2021 Griffon Studios" align:#center
        label lbl3 "Created by Taylor Mouse" align:#center
        label lbl2 "Get the latest version from my github:\n" align:#center
        hyperlink lnk1 "github.com/TaylorMouse/Warcraft 3 Reforged"  address:"https://github.com/TaylorMouse/MaxScripts" align:#center color:(color 255 128 0)
        button btn "Close" height:30 width:80 offset:[0,10]
        
        on btn pressed do
        (
            destroydialog aboutWindow
        )
 
    )
    createdialog aboutWindow  width:300 lockwidth: true
    
)

macroscript Warcaft3Reforged_Ribbon     
    category:"Warcraft 3 Reforged Tools" 
    tooltip:"Create Ribbon" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Ribbon.ms"
    WC3RefRibbon()
)

macroscript Warcaft3Reforged_Event      
    category:"Warcraft 3 Reforged Tools" 
    tooltip:"Create Event" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Event.ms"
    WC3RefEvent()
)

macroscript Warcaft3Reforged_FaceFX     
    category:"Warcraft 3 Reforged Tools" 
    tooltip:"Create Face FX" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_FaceFX.ms"
    WC3RefFaceFX()
)

macroscript Warcaft3Reforged_Attachment category:"Warcraft 3 Reforged Tools" tooltip:"Create Attachment" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Attachment.ms"
    WC3RefAttachment()
)

macroscript Warcaft3Reforged_Particles  category:"Warcraft 3 Reforged Tools" tooltip:"Create Particle Emitter" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Emitter.ms"
    WC3RefEmitter()
)

macroscript Warcaft3Reforged_PopCorn    category:"Warcraft 3 Reforged Tools" tooltip:"Create Popcorn Emitter" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_PopCorn.ms"
    WC3RefPopCorn()
)

macroscript Warcaft3Reforged_SC2AttachmentpointConvertor    category:"Warcraft 3 Reforged Tools" tooltip:"Convert Attachmentpoints" 
(
    if ( STARCRAFT_II_ARTTOOLS_INSTALLED ) then (
        fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"
        StarTools_Helpers.ConvertAttachmentPoints()
    )
    else 
        messagebox "Starcraft II Art Tools not installed or not supported"
)

macroscript Warcaft3Reforged_SC2MaterialConvertor    category:"Warcraft 3 Reforged Tools" tooltip:"Convert Materials" 
(
    if ( STARCRAFT_II_ARTTOOLS_INSTALLED ) then (
        fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"
        StarTools_Helpers.ConvertMaterials()
    )
    else 
        messagebox "Starcraft II Art Tools not installed or not supported"
)


macroscript Warcaft3Reforged_SC2HitTestBoxes    category:"Warcraft 3 Reforged Tools" tooltip:"Convert HitTestBoxes" 
(
    if ( STARCRAFT_II_ARTTOOLS_INSTALLED ) then (
    fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"
    StarTools_Helpers.ConvertHitTestBoxes()
    StarTools_Helpers.ConvertToBoundingSphere collBox "Vol_Shield"
    )
    else 
        messagebox "Starcraft II Art Tools not installed or not supported"
)

macroscript Warcaft3Reforged_CollapseHitTests category:"Warcraft 3 Reforged Tools" tooltip:"Collapse Hit Tests" 
(
    for obj in objects do 
    (
        if ( findstring obj.name "B_KGS_" != undefined ) then
        (
            obj.wirecolor = color 0 64 255
            
            if ( obj.name == "B_KGS_Root") then obj.wirecolor = color 255 64 0
        
            freeze obj
            obj.boxmode = on
        )
    )    
)

macroscript Warcaft3Reforged_ExpandHitTests category:"Warcraft 3 Reforged Tools" tooltip:"Expand Hit Tests" 
(
    for obj in objects do 
    (
        if ( findstring obj.name "B_KGS_" != undefined ) then
        (
            unfreeze obj
            obj.boxmode = off
        )
    )    
)

macroscript Warcaft3Reforged_CollapseAttachments category:"Warcraft 3 Reforged Tools" tooltip:"Collapse Attachments" 
(
    for obj in objects do 
    (
        if( classof obj == WC3RefAttachment ) then 
        (
            freeze obj
        )
    )
)

macroscript Warcaft3Reforged_ExpandAttachments category:"Warcraft 3 Reforged Tools" tooltip:"Expand Attachments" 
(
    for obj in objects do 
    (
        if( classof obj == WC3RefAttachment ) then 
        (
            unfreeze obj
        )
    )
)