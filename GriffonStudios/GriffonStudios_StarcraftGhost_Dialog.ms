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
            cbUseSC2ArtTools.checked = falsep
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


rollout GriffonStudios_StarcraftGhostAnimationsImport_Rollout "Import Starcraft Ghost Animation(s)" height:570 width:500 
(
    local motions
    local file
    local fileType
    
    label info "\xa9 2020 Importer by Taylor Mouse"
    
    group "Options"
    (
        CheckBox cbResetAnimTrack "Reset animation track"
    )
    
    group "Select motion/model file"
    (
        edittext txtSelectedFile "" fieldWidth:440 align:#left height:20
        button   btnSelectFile "..." align:#right offset:[0,-26]
    )

    group "Animation List"
    (
        dotnetControl lv "System.Windows.Forms.ListView" width:470 height:350 
        button   btnSelectAll "Select all" align:#left
        button   btnSelectNone "Deselect all" align:#left offset:[65,-26]
        button   btnSelectInvert "Invert selection" align:#left offset:[140,-26]
    )
    
    button btnImport "Import selected animations" width:400 height:35
    
    on btnSelectAll pressed do
    (
        for i=0 to lv.Items.Count - 1 do
            lv.Items.Item[i].checked = true
    )
    on btnSelectNone pressed do
    (
        for i=0 to lv.Items.Count - 1 do
            lv.Items.Item[i].checked = false
    )
    on btnSelectInvert pressed do
    (
        for i=0 to lv.Items.Count - 1 do
        (
            if ( lv.Items.Item[i].checked ) then 
                lv.Items.Item[i].checked = false
            else 
                lv.Items.Item[i].checked = true
        )
    )    
    on btnImport pressed do
    (
        if ( cbResetAnimTrack.checked == true ) then GriffonStudios_Helpers.ResetNoteTracks() 
        
        local motionsToImport = #()
        local errors = false
        
        for i=0 to lv.Items.Count - 1 do
        (
            if ( lv.Items.Item[i].checked ) then 
            (
                local m = i+1
                
                try (
                    if ( fileType == ".nod" or fileType == ".noc" ) then Starcraft_Ghost_Main.ApplyMotion2 nod.motions[m]
                    if ( fileType == ".nms" ) then Starcraft_Ghost_Main.ApplyMotion2 motions[m]
                )
                catch
                (
                    errors = true
                    format "%\n" (getCurrentException())
                    
                    local version = maxversion()
                    if( version[1] > 18000 ) then 
                        format "%\n" (getCurrentExceptionStackTrace())
                )
                
            
            )
        )
        destroyDialog GriffonStudios_StarcraftGhostAnimationsImport_Rollout
        if ( errors ) then 
            messagebox "There where errors during the import, please verify the Listener for details"
        else
            messagebox "Import success!"
       
    )
    
    on GriffonStudios_StarcraftGhostAnimationsImport_Rollout open do
    (
        lv.view = (dotnetClass "System.Windows.Forms.View").Details
        lv.fullRowSelect = true
        lv.checkBoxes = true
        lv.gridLines = true
        
        lv.Columns.Add " " 20
        lv.Columns.Add "Overlay" 80
        lv.Columns.Add "Animation" 200
        
        cbResetAnimTrack.checked = false
    )
    
    function UpdateLV motions=
    (
        lv.items.Clear()
        if (motions == undefined ) then 
        (
            format "No animations or motions found!\n"
            return false
            
        )
        for motion in motions do
        (
            --format "Adding motion %\n" motion
            local newItem = dotNetObject "System.Windows.Forms.ListViewItem" ""  
            
            newItem.SubItems.Add (motion.OverlayName)
            newItem.SubItems.Add (motion.animname)
            
            --newItem.Tag = motion
            lv.items.add newItem	
        )
        
        for i=0 to lv.Items.Count - 1 do
            lv.Items.Item[i].checked = true
        
        return true
    )
    
    on btnSelectFile pressed do
    (
        file = getOpenFileName \
			caption:"Starcraft Ghost Model or Motion File" \
			types:"Supported Files (*.nod,*.noc, *.nms)|*.nod;*.noc;*.nms|All Files|*.*" \
			historyCategory:"StarcraftGhostMotionObjectPresets"
        
        if ( file == undefined or doesFileExist file != true ) then
        (
            fileType = undefined
            motions = #()
            return false
        )

        txtSelectedFile.Text = file
        
        local extension = getFilenameType file 
        if ( extension == ".nod" ) then
        (
            fileType = ".nod"
            
            setWaitCursor() 
            try (
                nod = Starcraft_Ghost_Main.ReadNod file
            )
            catch()
            setArrowCursor()

            motions = nod.motions
            UpdateLV motions
        )
        if( extension == ".nms" ) then
        (
            fileType = ".nms"
            setWaitCursor()
            try(
                motions = StarCraft_Ghost_Main.ReadMotionFile file
            ) catch()
            setArrowCursor()
            
            UpdateLV motions
        )
    )
    
)