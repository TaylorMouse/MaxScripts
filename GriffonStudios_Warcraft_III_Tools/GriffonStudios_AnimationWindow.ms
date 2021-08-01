/*
    .SYNOPSIS
    | Opens up a popup window that reads the data from the notes track in Max and interpretes them as animation sequences
    | Compatible with Warcraft III, Warcraft III Reforged and StarCraft II
    
    .COPYRIGHT
    | © 2020 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

rollout GriffonStudios_AnimationWindow "Animation Window 2" 
    width:250 
    height:750
(

    dropdownlist ddlTracks "" height:20
    dotNetControl lv "System.Windows.Forms.ListView" width:230 height:300 align:#center
    checkbox cbUpdateTimeLine "Update timeline" checked:true
    button btn_RefreshList "Refresh" align:#right offset:[0,-20]
    
    local leftPos = - 20
    local selectedAnimationTrack = undefined 
    local selectedAnimation = undefined
    local selectedAnimationName = ""
    
    group "Properties"
    (
        edittext txt_newName "" width:120 
        button btn_rename "Update" width:80 height:20 offset:[70,-25] tooltip:"Update the name or the properties of this animation sequence"
        
        label lblStartFrame "Start "    align:#left
        spinner txt_StartFrame ""       width:50 offset:[leftPos,-20] type:#integer range:[0,100000,0]

        label lblEndFrame "End "        align:#left
        spinner txt_EndFrame ""         width:50 offset:[leftPos,-20] type:#integer range:[0,100000,0]

        label lblRarity "Rarity (%)"    align:#left
        spinner spinRarity ""           width:50 offset:[leftPos,-20] type:#integer

        label lblMovementSpeed "Movement Speed" align:#left
        spinner spinMovementSpeed ""    width:50 offset:[leftPos,-20] type:#float range:[0,1000,0]
        
        label lblPriority "Priority"    align:#left
        spinner spinPriority ""         width:50 offset:[leftPos,-20] type:#integer

        label lblNonLooping "Non-Looping" align:#left
        checkbox chkNonLooping "" offset:[122,-20]
        

    )

    group "Add new animation"
    (
        edittext txt_newAnimName "" width:120 
        button btn_add "Add" width:80 height:20 offset:[70,-25]
        checkbox chk_useTrackBar "Use start and end frame from the track bar"
    )
    
    group "Remove selected Animation"
    (
        button btn_delete "Remove" width:180 height:30
    )

    group "Remove note track"
    (
        button btn_removeNoteTrack "Remove all animations (note track)" width:180 height:30
    )
    
    label lblTM "© 2021 Taylor Mouse"
    
    function SetAnimationNoteTrack anim=
    (
        
        /* clear existing notes */
        local starAnimTrack = undefined
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
           
        local strLastNoteFrame = "0f"
        local lastNoteFrame = 0
        
        if( (hasNoteTracks rootNode) == true ) then
        (
            starAnimTrack    = getNoteTrack rootNode selectedAnimationTrack
            strLastNoteFrame = getNoteKeyTime starAnimTrack starAnimTrack.keys.count as string
            lastNoteFrame    = substring strLastNoteFrame 1  (strLastNoteFrame.count - 1) as integer
        )
        else
        (
            starAnimTrack = notetrack "starAnimTrack"
            addNoteTrack rootNode starAnimTrack
        )
        
        local noteExists = getNoteKeyIndex starAnimTrack  anim.start_frame
        
        /* validation */
        local isValid = true
        if ( anim.start_frame >= anim.end_frame ) then isValid = false
        if ( anim.start_frame <= lastNoteFrame ) then isValid = false
        
        if isValid == false then 
        (
            messagebox "One of the following was invalid:\nEnd Frame must be higher then the Start Frame\nThe start frame must start later then the previous end frame"
            return undefined
        )
        /* apply new notes */
        
        if( noteExists == undefined) then
        (
            --( name, start_frame, end_frame, rarity, movement_speed, priority, non_looping )
            
            local startNote = AddNewNoteKey starAnimTrack anim.start_frame
            local endNote = AddNewNoteKey starAnimTrack anim.end_frame
            
            /* this is based on StarCraft 2 animation note track */
            local val = anim.name + "\r\n"
                  val += "rarity = " + anim.rarity + "\r\n"
                  val += "moveSpeed = " + anim.movement_speed + "\r\n"
                  val += "nonLoop = " + anim.non_looping + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + anim.priority

            startNote.Value = val
            endNote.Value = val
            
        )

        
    )

    function ResetTrackList=
    (
        local nNoteTracks = numNoteTracks rootNode
        local items = #()
        for i=1 to nNoteTracks do
        (
            local track = getNoteTrack rootNode i
            local name = track.name
            if track.name == undefined or track.name == "" then
            (
                name = "Animation track " + ( i as string )
            )
            append items name
        )
        
        if items.count > 0 then 
        (
            selectedAnimationTrack = 1
            ddlTracks.items = items
            ddlTracks.selection = 1
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
            if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
            local track = getNoteTrack rootNode selectedAnimationTrack

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
        ResetTrackList()
    )
    
    on btn_refreshList pressed do
    (
        ResetTrackList()
        ResetListView()
    )
    
    on btn_removeNoteTrack pressed do
    (
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
        
        try(
            if ( numNoteTracks rootnode == 1 ) then
            (
                local track = getNoteTrack rootNode selectedAnimationTrack
                deleteNoteTrack rootnode track
                ResetListView()
            )
            
        )catch
        (
            messageBox "Unable to remove the animation note track" title:"Error occured deleting note track"
        )
    )
    
    on btn_add pressed do
    (
        if( txt_newAnimName.Text == "") then 
        (
            messageBox "Please enter a valid animation name!" title:"Incorrect Animation name"
            return undefined
        )
        
        struct animStruct ( name, start_frame, end_frame, rarity, movement_speed, priority, non_looping )
        
        local anim = animStruct()
        anim.name = txt_newAnimName.Text
        anim.start_frame    = txt_StartFrame.value
        anim.end_frame      = txt_EndFrame.value
        
        if ( chk_useTrackBar.checked ) then 
        (
            anim.start_frame    = animationrange.start as integer / ticksperframe
            anim.end_frame      = animationrange.end as integer / ticksperframe
        )   
        anim.rarity         = spinRarity.value as string
        anim.movement_speed = spinMovementSpeed.value as string
        anim.priority       = spinPriority.value as string
        anim.non_looping    = chkNonLooping.checked as string
        
        SetAnimationNoteTrack anim
        
        ResetListView()
        
        txt_newAnimName.Text = ""
    )
    
    on btn_rename pressed do
    (
        
        if( selectedAnimation == undefined or txt_newName.text == "") then return undefined
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
        local newName = txt_newName.text
        local track = getNoteTrack rootNode selectedAnimationTrack
        local keys = track.Keys

        
        struct animStruct ( name, start_frame, end_frame, rarity, movement_speed, priority, non_looping )
        
        local anim = animStruct()
        anim.name           = txt_newName.text
        anim.start_frame    = txt_StartFrame.value
        anim.end_frame      = txt_EndFrame.value
        anim.rarity         = spinRarity.value as string
        anim.movement_speed = spinMovementSpeed.value as string
        anim.priority       = spinPriority.value as string
        anim.non_looping    = chkNonLooping.checked as string
        
        format "%\n" anim
        
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
--                     note = newName + (substring note (pos+1) -1)
--                     
--                     keys[i].value = note
--                     keys[i+1].value = note
                    SetAnimationNoteTrack anim
                    
                    exit
                )
                catch 
                (
                    format "[Error] %\n" (getCurrentException())
                )
            )
        )
        
        ResetListView()
        ResetTrackList()
        selectedAnimation = undefined
        txt_newName.text = ""
    )
 
    on btn_delete pressed do
    (
        --format "Animation found:%\n" selectedAnimation
        if ( selectedAnimation == undefined) then return undefined
        
        local msg = "Are you sure you want to delete the animation ("+ selectedAnimation.Text + ")?\n\nNOTE:\nThis does not delete the actual keyframes only the entry in the list!"
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
        if( querybox msg Title:"Confirm animation delete" ) then
        (
            track = getNoteTrack rootNode selectedAnimationTrack
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
    
    on GriffonStudios_AnimationWindow open do
    (
        InitializeListView()


    )

    on lv ItemSelectionChanged arg do
    (
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
        selectedAnimation = arg.Item
        selectedAnimationName = selectedAnimation.Text
        txt_newName.text = selectedAnimationName
        
        track = getNoteTrack rootNode selectedAnimationTrack
        keys = track.Keys

        for i=1 to keys.count by 2 do
        (
            local note = keys[i].value
            local pos = (findString note "\n") - 2
            local animationName = substring note 1 pos
            local propNote = substring note (pos + 2 ) -1
            
            if( animationName == selectedAnimation.Text) then
            (
                startTime = getNoteKeyTime track i
                endTime = getNoteKeyTime track (i + 1)

                if( cbUpdateTimeLine.checked ) then
                (
                    animationrange = interval startTime endTime
                    slidertime = startTime
                )

                
                sStartTime = startTime as string
                sEndTime = endTime as string
                
                
                txt_StartFrame.value = ( substring sStartTime 1 ( sStartTime.count  - 1)) as integer
                txt_EndFrame.value = (substring sEndTime 1 ( sEndTime.count  - 1)) as integer
                
                local parts = filterstring propNote "\r\n ,"

                    
                spinRarity.value = parts[3] as integer
                spinMovementSpeed.value = parts[6] as float
                spinPriority.value = parts[18] as integer
        
                if parts[9] == "true" then 
                    chkNonLooping.checked = true
                else 
                    chkNonLooping.checked = false
                
                exit
            )
        )

    )
    
    on ddlTracks selected selectedItem do
    (
        selectedAnimationTrack = selectedItem
        ResetListView()
    
    )
)
