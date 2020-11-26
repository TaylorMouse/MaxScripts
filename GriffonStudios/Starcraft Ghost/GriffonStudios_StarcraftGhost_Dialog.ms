/*
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Starcraft Ghost Dialog interfaces

*/
filein "GriffonStudios_StarcraftGhost_Main.ms"

rollout GriffonStudios_StarcraftGhostModelImport_Rollout "Import Starcraft Ghost Model" height:180 width:500 
(
    label info "\xa9 2020 Importer by Taylor Mouse" align:#right

    group "Options"
    (
        CheckBox cbUseSC2ArtTools "Use SC2 Art Tools"
    )
    group "Select model file (.nod, .noc)"
    (
        edittext txtSelectedFile "" fieldWidth:440 align:#left height:20
        button   btnSelectFile "..." align:#right offset:[0,-26]
    )
    button btnImport "Import..." width:400 height:35
    
    on GriffonStudios_StarcraftGhostModelImport_Rollout Open do
	(
        if ( STARCRAFT_II_ARTTOOLS_INSTALLED == undefined or STARCRAFT_II_ARTTOOLS_INSTALLED == false ) then 
        (
            cbUseSC2ArtTools.enabled = false
            cbUseSC2ArtTools.checked = false
        )
	)
    
    on btnSelectFile pressed do
    (
        file = getOpenFileName \
			caption:"Starcraft Ghost Model File" \
			types:"Supported Files (*.nod,*.noc)|*.nod;*.noc|Starcraft Ghost Model File(*.nod,*.noc)|*.nod;*.noc|All Files|*.*" \
			historyCategory:"StarcraftGhostObjectPresets"
        
		if(file!=undefined ) then 
        (
            txtSelectedFile.Text = file
            
        )
    )
    
    on btnImport pressed do
    (
        selectedFile = txtSelectedFile.Text
        if ( selectedFile != undefined and selectedFile != "") then
        (
            if( doesFileExist selectedFile ) then
            (
                try (
                    Starcraft_Ghost_Main.ImportModel selectedFile
                    messagebox "Import success!"
                )
                catch
                (
                    format "[ERROR]\n"
                    format "% \n" (getCurrentException())
                    local version = maxversion()
                    if( version[1] > 18000 ) then 
                        format "% \n" (getCurrentExceptionStackTrace())
                    messagebox "Error occured please see the MaxScript listener for more details! "
                    
                )
                destroyDialog GriffonStudios_StarcraftGhostModelImport_Rollout
            )
        )
    )
    
)


rollout GriffonStudios_StarcraftGhostAnimationsImport_Rollout "Import Starcraft Ghost Animation" height:200 width:400 
(
    label info "\xa9 2020 Importer by Taylor Mouse"
)

/*
    TESTING
*/
createDialog GriffonStudios_StarcraftGhostModelImport_Rollout