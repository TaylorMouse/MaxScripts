/*
    ©2020 Script by Taylor Mouse
    Amped up my initial script to display notes on the animation track
*/


rollout GriffonStudios_AnimationProperties "Animation Properties" width:200 height:780
(
    /*********************************************************************************************************/
    label lblTM "©2020 Taylor Mouse"
    dotNetControl lv "System.Windows.Forms.ListView" width:180 height:300 align:#center
    checkbox cbUpdateTimeLine "Update timeline"
    button btn_RefreshList "Refresh" align:#right offset:[0,-20]
    
    
    local bUpdateTimeLine = true
    
    local selectedAnimation = undefined
    local selectedAnimationName = ""
    
    /*********************************************************************************************************/
    function SetAnimationNoteTrack list_animations=
    (
        
        /* clear existing notes */
        local starAnimTrack = undefined
            
        if( (hasNoteTracks rootNode) == true ) then
        (
            starAnimTrack = getNoteTrack rootNode 1
        )
        else
        (
            starAnimTrack = notetrack "starAnimTrack"
            addNoteTrack rootNode starAnimTrack
        )
        
        /* apply new notes */
        for anim in list_animations do
        (
            local noteExists = getNoteKeyIndex starAnimTrack  anim.start_frame
            if( noteExists == undefined) then
            (
                local startNote = AddNewNoteKey starAnimTrack anim.start_frame
                local endNote = AddNewNoteKey starAnimTrack anim.end_frame
                
                /* this is based on StarCraft 2 animation note track */
                local val = anim.name + "\r\n"
                      val += "rarity = 100\r\n"
                      val += "moveSpeed = 0\r\n"
                      val += "nonLoop = 0\r\n"
                      val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = 0"

                startNote.Value = val
                endNote.Value = val
                
            )
            
        )
        
    )

    function ResetListView=
    (
        local items = #()
        
        lv.Items.Clear()
        /* Check if there is a note track */
        local nNoteTracks = numNoteTracks rootNode
      
        if(nNoteTracks > 0) then
        (
            local track = getNoteTrack rootNode 1

            keys = track.Keys
            for i=1 to keys.count by 2 do
            (
                note = keys[i].value
                
                --format "Parsing note: %\n" note
                
                pos = (findString note "\n") - 2
                if (pos != undefined) then
                (
                    animationName = substring note 1 pos
                    item = dotNetObject "System.Windows.Forms.ListViewItem"
                    item.Text = animationName
                    append items item
                )
            )

            lv.Items.AddRange items
        )
    )
    
    function InitializeListView =
    (

        lv.View = (dotNetClass "System.Windows.Forms.View").Details
        lv.FullRowSelect = true
        lv.HideSelection = false
        lv.Columns.Add "Animation Name" -2

        lv.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").Ascending

        ResetListView()
    )
    
    /*********************************************************************************************************/
    group "Properties"
    (
        label lblStartFrame "Start " align:#left
        label lblEndFrame "End " align:#left
        label lblProperty "" align:#left height:40

    )

    group "Rename animation"
    (
        edittext txt_newName "" width:180 
        button btn_rename "Rename" width:180 height:40
    )
    
    group "Add new animation"
    (
        edittext txt_newAnimName "" width:180 
        button btn_add "Add" width:180 height:40
    )
    
    group "Remove selected Animation"
    (
        button btn_delete "Delete" width:180 height:40
    )
    group "Remove note track"
    (
        button btn_removeNoteTrack "Remove all animations" width:180 height:40
    )
    /*********************************************************************************************************/
    on btn_refreshList pressed do
    (
        ResetListView()
        
    )
    
    /*********************************************************************************************************/
    on btn_removeNoteTrack pressed do
    (
        try(
            if ( numNoteTracks rootnode == 1 ) then
            (
                local track = getNoteTrack rootNode 1
                deleteNoteTrack rootnode track
                ResetListView()
            )
            
        )catch
        (
            messageBox "Unable to remove the animation note track" title:"Error occured deleting note track"
        )
    )
    
    /*********************************************************************************************************/
    on btn_add pressed do
    (
        if( txt_newAnimName.Text == "") then 
        (
            messageBox "Please enter a valid animation name!" title:"Incorrect Animation name"
            return undefined
        )
        local list_animations = #()
        
        struct animStruct ( name, start_frame, end_frame )
        
        local anim = animStruct()
        anim.name = txt_newAnimName.Text
        
        anim.start_frame = animationrange.start
        anim.end_frame = animationrange.end
        
        append list_animations anim
        
        SetAnimationNoteTrack list_animations
        
        ResetListView()
        
        txt_newAnimName.Text = ""
    )
    
    /*********************************************************************************************************/
    on btn_rename pressed do
    (
        
        if( selectedAnimation == undefined or txt_newName.text == "" or txt_newName.text == selectedAnimation.Text ) then return undefined
        
        local newName = txt_newName.text
        local track = getNoteTrack rootNode 1
        local keys = track.Keys

        for i=1 to keys.count by 2 do
        (
            local note = keys[i].value
            local pos = (findString note "\n") - 2
            local animationName = substring note 1 pos
            if( animationName == selectedAnimation.Text) then
            (
                try 
                (
                    note = newName + (substring note (pos+1) -1)
                    
                    keys[i].value = note
                    keys[i+1].value = note

                    exit
                )
                catch 
                (
                    format "[Error] %\n" (getCurrentException())
                )
            )
        )
        
        ResetListView()
        selectedAnimation = undefined
        txt_newName.text = ""
    )
    /*********************************************************************************************************/
    on btn_delete pressed do
    (
        --format "Animation found:%\n" selectedAnimation
        if ( selectedAnimation == undefined) then return undefined
        
        local msg = "Are you sure you want to delete the animation ("+ selectedAnimation.Text + ")?\n\nNOTE:\nThis does not delete the actual keyframes only the entry in the list!"
        
        if( querybox msg Title:"Confirm animation delete" ) then
        (
            track = getNoteTrack rootNode 1
            keys = track.Keys

            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local pos = (findString note "\n") - 2
                local animationName = substring note 1 pos
                if( animationName == selectedAnimation.Text) then
                (
                    try 
                    (
                        deleteNoteKey keys (i+1)
                        deleteNoteKey keys i
                        exit
                    )
                    catch 
                    (
                        format "[Error] %\n" (getCurrentException())
                    )
                )
            )
            ResetListView()
        )
    )
    /*********************************************************************************************************/
    on cbUpdateTimeLine changed theState do
    (
        if(bUpdateTimeLine) then bUpdateTimeLine = false else bUpdateTimeLine= true
    )

   
    
    on GriffonStudios_AnimationProperties open do
    (
        InitializeListView()
        cbUpdateTimeLine.Checked = true
        
    )

    on lv ItemSelectionChanged arg do
    (
        
        
        selectedAnimation = arg.Item
        selectedAnimationName = selectedAnimation.Text
        txt_newName.text = selectedAnimationName
        
        track = getNoteTrack rootNode 1
        keys = track.Keys

        for i=1 to keys.count by 2 do
        (
            local note = keys[i].value
            local pos = (findString note "\n") - 2
            local animationName = substring note 1 pos
            if( animationName == selectedAnimation.Text) then
            (
                startTime = getNoteKeyTime track i
                endTime = getNoteKeyTime track (i + 1)

                if( bUpdateTimeLine) then
                (
                    animationrange = interval startTime endTime
                    slidertime = startTime
                )

                startLbl = "Start " + startTime as string
                endLbl = "End " + endTime as string
                startLen = startLbl.count-1
                endLen = endLbl.count-1

                lblStartFrame.Text = substring startlbl 1 startLen
                lblEndFrame.Text = substring endLbl 1 endLen
                lblProperty.Text = substring note (pos+3) -1
            )
        )

    )
    

)
