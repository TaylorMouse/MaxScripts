filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_Material.ms"
filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_Ribbon.ms"
filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_Attachment.ms"
filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_Event.ms"
filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_Emitter.ms"
filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_FaceFX.ms"
filein "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Plugins_Popcorn.ms"
fileIn "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Main.ms"

global Warcraft3_AssetFolder
global Warcraft3_ImportAllLOD
global Warcraft3_ConvertToSC2

utility GriffonStudios_Warcraft3Reforged_Utility "Warcraft 3 Reforged (v1.0)"
(
    group "Change Settings"
    (
        checkbox chkImportAllLOD "Import all LOD"
        checkbox chkConvertSeqs "SC2 Anim Seqs"
        label lbl1 "Root Asset folder:" align:#left
        edittext txtRootAssetFolder offset:[-10,0] width:130
        button btnAssetFolder "..." width:20 height:20 offset:[7,-23] align:#right
    )
    group "Import"
    (
        button btnImport "Import ..." width:130 height:30
    )

    Label lbl30 "©2020 by Taylor Mouse"  align:#center
    
    on chkImportAllLOD changed theState do Warcraft3_ImportAllLOD = theState
    on chkConvertSeqs changed theState do Warcraft3_ConvertToSC2 = theState
    
    on GriffonStudios_Warcraft3Reforged_Utility open do
    (
        Warcraft3_ImportAllLOD = false
        Warcraft3_ConvertToSC2 = false
        local assetFolder = getinisetting "griffonstudios.config" "Warcraft3Reforged" "AssetFolder"
        if assetFolder == undefined then txtRootAssetFolder.text = "" else txtRootAssetFolder.text = assetFolder
        Warcraft3_AssetFolder = assetFolder   
        
    )    
    on btnAssetFolder pressed do
    (
        local assetFolder = getSavePath caption:"Select Asset Root Folder" initialDir:Warcraft3_AssetFolder
        if ( assetFolder != undefined) then 
        (
            setinisetting "griffonstudios.config" "Warcraft3Reforged" "AssetFolder" ( assetFolder  + "\\" )
            txtRootAssetFolder.text = assetFolder  + "\\"
            Warcraft3_AssetFolder = assetFolder + "\\"
        )
    )
    on btnImport pressed do
    (
        file = getOpenFileName \
                    caption:"Warcraft 3 Reforged" \
                    types:"Supported Files|*.mdx|Warcraft 3 Reforged(*.mdx)|*.mdx|All Files|*.*" \
                    historyCategory:"ReforgedPreset"

        Warcraft3_Reforged.Import file
    )
)