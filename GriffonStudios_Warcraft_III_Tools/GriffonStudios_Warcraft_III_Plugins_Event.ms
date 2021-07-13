/*
    .SYNOPSIS
    | Event object for Warcraft III
    
    .COPYRIGHT
    | ©2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

plugin simpleManipulator WarcraftIII_Event
    name: "Event"
    classID:#(0x72b66f71, 0x5f4ea111)
    category:"Warcraft III"
(

    local selectedKey
    
    parameters main rollout:params
    (
       keyList type:#IntTab tabSizeVariable:true
    )
    rollout params "Event Properties"
    (
        label lbl1 "Move the animation slider to indicate the position of the key" align:#left offset:[0,20] width:130 height:50
        
        dotNetControl lvNotes "System.Windows.Forms.ListView" width:130 height:200 align:#center
        
        button btnAddKey  "Add" height:30 width:62 align:#left offset:[2,0]
        button btnRemoveKey "Remove" height:30 width:62 align:#right offset:[-2,-35]
        button btnInfo "Info" height:30 width:130
        
        groupbox group1 "Common" height:400 width:155 pos:[3,5]

        function UpdateListOfKeys=
        (
            local items = #()
            listOfKeys = #()
            lvNotes.Items.Clear()
            
            for k in keyList do
            (
                local item = dotNetObject "System.Windows.Forms.ListViewItem"
                item.Text = k as string
                append items item
            )
            
            lvNotes.Items.AddRange items
            
        )
        
        on params open do
        (
            lvNotes.View = (dotNetClass "System.Windows.Forms.View").Details
            lvNotes.FullRowSelect = true
            lvNotes.HideSelection = false
            lvNotes.Columns.Add "Keys found at frame:" -2
            lvNotes.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").Ascending
            UpdateListOfKeys()
        )
        on lvNotes ItemSelectionChanged arg do
        (
            selectedKey = arg.Item.Text
        )
        
        function ShowMessageBox message title=
        (
            local msgbox = dotnetclass "System.Windows.Forms.MessageBox"
            local msgboxbuttons = dotnetclass "System.Windows.Forms.MessageBoxButtons"
            local msgboxicons = dotnetclass "System.Windows.Forms.MessageBoxIcon"
           
            msgbox.show message title msgboxbuttons.OK msgboxicons.none
        )
            
        on btnAddKey pressed do
        (
            local keyFrame = (sliderTime as integer)/ticksperframe
            appendifunique keyList keyFrame
            UpdateListOfKeys()
            
        )
        
        on btnRemoveKey pressed do
        (
            if selectedKey == undefined then return undefined
            print selectedKey
            for i=1 to keyList.count do
                if selectedKey == (keyList[i] as string) then deleteItem keyList i
                
            selectedKey = undefined
                
            UpdateListOfKeys()
            
        )
        
        on btnInfo pressed do
        (
            ShowMessageBox "The events will happen on the places where the keys are set.\nThe names of the objects can be found in the official Warcraft III Art Tools Documentation" "Warcraft III Event Info"
        )
        
    )
       
    tool create
    (
        on mousePoint click do
        (
            case click of
                 (
                    1:(
                        nodeTM.translation = gridPoint
                        
                        myNoteTrack = notetrack "Notes"
                        addNoteTrack this myNoteTrack
                        
                     
                         #stop
                      )
                  )
        )
    )
    function BuildGizmo points=
    (
        local unselectedColor = [0,1,0] 
        local selectedColor = [1,1,0]
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    function BuildGizmoCircle radius=
    (
        local unselectedColor = [0,1,0] 
        local selectedColor = [1,1,0]

        local giz = manip.makeCircle [0,0,0] radius 32

        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    on updateGizmos do
    (
        this.clearGizmos()

        BuildGizmoCircle 5.0
        BuildGizmo #([-3.5,-3.5,0], [-3.5,3.5,0], [3.5,3.5,0], [3.5,-3.5,0],[-3.5,-3.5,0], [0,0,4], [3.5,3.5,0])
        BuildGizmo #([-3.5,3.5,0], [0,0,4], [3.5,-3.5,0])


    )
    
)

