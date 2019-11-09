fileIn "GriffonStudios\GriffonStudios_Warcraft_3_Reforged_Main.ms"

utility GriffonStudios_Warcraft3Reforged_Tools "Warcraft 3 Reforged (v1.0)"
(
    group "Warcraft 3 Reforged"
    (
        
        button btnImport "Import ..." width:130 height:30
        button btnSetting "Settings" width:130 height:30
        Label lbl30 "©2020 by Taylor Mouse"  align:#center
    )
    on btnImport pressed do
    (
        file = @"F:\Blizzard\Warcraft - Reforged\Exported\Assets\units\undead\varimathras\varimathras.mdx"
        file = getOpenFileName \
                    caption:"Warcraft 3 Reforged" \
                    types:"Supported Files|*.mdx|Warcraft 3 Reforged(*.mdx)|*.mdx|All Files|*.*" \
                    historyCategory:"ReforgedPreset"

        Warcraft3_Reforged.Import file
    )
)