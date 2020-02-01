global Warcraft3_AssetFolder
global Warcraft3_ImportAllLOD
global Warcraft3_ConvertToSC2

macroscript Warcaft3Reforged_ImportModel category:"Warcraft 3 Reforged Tools" tooltip:"Import model" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"

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

        label lbl1 "©2020 Created by" align:#center
        label lbl2 "Taylor Mouse"  align:#center
        button btnClose "Close" height:30 width:80 offset:[115,-35]
        button btnImport "Import" height:30 width:80 offset:[-115,-35]
        
        on btnClose pressed do destroydialog ImportWindow
        on chkImportAllLOD changed theState do Warcraft3_ImportAllLOD = theState
        on chkConvertToSC2 changed theState do Warcraft3_ConvertToSC2 = theState
        
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

            if (doesfileexist file == true ) then 
                txtSelectedFile.Text = file
        )
        on btnImport pressed do
        (
            local file = txtSelectedFile.Text
            if (doesfileexist file == true ) then 
                Warcraft3_Reforged.Import file
            else
                MessageBox "Please select a correct or existing file!" 
            
        )
        
    )
    if(ImportWindow != undefined) then destroydialog ImportWindow
        CreateDialog ImportWindow width:320 lockwidth: true 
    
)

macroscript Warcaft3Reforged_Settings category:"Warcraft 3 Reforged Tools" tooltip:"Settings" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Main.ms"

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
                setinisetting "griffonstudios.config" "Warcraft3Reforged" "AssetFolder" ( assetFolder   )
                Warcraft3_AssetFolder = assetFolder 
            )
            destroydialog SettingsWindow
        )
        
        on SettingsWindow open do
        (
            local assetFolder = getinisetting "griffonstudios.config" "Warcraft3Reforged" "AssetFolder"
            if assetFolder == undefined then txtRootAssetFolder.text = "" else txtRootAssetFolder.text = assetFolder
            Warcraft3_AssetFolder = assetFolder   
            
        )    
    )
    if(SettingsWindow != undefined) then destroydialog SettingsWindow
        CreateDialog SettingsWindow width:320 lockwidth: true 
    
)


macroscript Warcaft3Reforged_ExportModel category:"Warcraft 3 Reforged Tools" tooltip:"Export model" 
(
    messagebox "Please be patient, I'm working on it :)"
)

macroscript Warcaft3Reforged_Animations category:"Warcraft 3 Reforged Tools" tooltip:"Animation Selector" 
(
    filein "GriffonStudios_AnimationProperties.ms"
    if(GriffonStudios_AnimationProperties != undefined) then destroydialog GriffonStudios_AnimationProperties
        CreateDialog GriffonStudios_AnimationProperties lockwidth: true     
)

macroscript Warcaft3Reforged_About      category:"Warcraft 3 Reforged Tools" tooltip:"About"
(
    if ( aboutWindow != undefined ) then destroydialog aboutWindow
    
    rollout aboutWindow "Warcraft 3 Reforged Tools" 
    (
        label lbl1 "©2020 Created by Taylor Mouse" align:#center
        label lbl2 "Get the latest version from my github:" align:#center
        hyperlink lnk1 "github.com/TaylorMouse/Warcraft 3 Reforged"  address:"https://github.com/TaylorMouse/MaxScripts/tree/master/Warcraft 3 Reforged" align:#center color:(color 255 128 0)
        button btn "Close" height:30 width:80 offset:[0,10]
        
        on btn pressed do
        (
            destroydialog aboutWindow
        )
 
    )
    createdialog aboutWindow height:110 width:300 lockwidth: true
    
)

macroscript Warcaft3Reforged_Ribbon     category:"Warcraft 3 Reforged Tools" tooltip:"Create Ribbon" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Ribbon.ms"
    WC3RefRibbon()
)

macroscript Warcaft3Reforged_Event      category:"Warcraft 3 Reforged Tools" tooltip:"Create Event" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Event.ms"
    WC3RefEvent()
)

macroscript Warcaft3Reforged_FaceFX     category:"Warcraft 3 Reforged Tools" tooltip:"Create Face FX" 
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
