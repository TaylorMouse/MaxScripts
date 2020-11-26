/*
    Written by Taylor Mouse © 2020
    for
    Warcraft 3 Reforged

*/

plugin simpleManipulator WC3RefEvent
    name: "Event"
    classID:#(0x332e6a9a, 0x23f39a9d)
    category:"Warcraft 3 Reforged"
(
    local myNoteTrack
    local listOfKeys = #()
    local selectedKey
    
    parameters main rollout:params
    (
       -- eventNotes type:#noteTrack
        
    )
    rollout params "Event Properties"
    (
        label lbl1 "Move the animation slider to indicate the position of the key" align:#left offset:[0,20] width:130 height:50
        
        dotNetControl lvNotes "System.Windows.Forms.ListView" width:130 height:200 align:#center
        
        button btnAddNote "Add key" height:30 width:130
        button btnRemNote "Remove key" height:30 width:130
        button btnInfo "Info" height:30 width:130
        
        groupbox group1 "Common" height:400 width:155 pos:[3,5]

        function UpdateListOfKeys=
        (
            local items = #()
            listOfKeys = #()
            lvNotes.Items.Clear()
            
            if ( myNoteTrack == undefined ) then return undefined
            
            local allKeys = myNoteTrack.keys
            
            for k in allKeys do
            (
                
                local t = (k.Time as integer)/ticksperframe
                append listOfKeys t
                
                local item = dotNetObject "System.Windows.Forms.ListViewItem"
                item.Text = t as string
                
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
            
        on btnAddNote pressed do
        (
            if ( myNoteTrack == undefined ) then myNoteTrack = notetrack "Notes"
                
            local keyFrame = (sliderTime as integer)/ticksperframe
            local keyAlreadyExists = false
            for key in listOfKeys do
            (
                if ( key == keyFrame ) then keyAlreadyExists = true
            )
            
            if ( keyAlreadyExists == false ) then 
            (
                addNewNoteKey myNoteTrack keyFrame
            
                UpdateListOfKeys()
            )
            
        )
        
        on btnRemNote pressed do
        (
            if ( myNoteTrack != undefined and selectedKey != undefined ) then 
            (
                local allKeys = myNoteTrack.keys
                local keyToRemoveAtTime = selectedKey as integer
                
                for i=1 to allKeys.count do
                (
                    local k = allKeys[i]
                    if k.Time == keyToRemoveAtTime then
                    (
                        deleteNoteKey myNoteTrack i
                        exit
                    )
                )
                
                selectedKey = undefined
                
                UpdateListOfKeys()
            )
        )
        
        on btnInfo pressed do
        (
            ShowMessageBox "The events will happen on the places where the keys are set.\nThe names of the objects can be found in the official Warcraft III Art Tools Documentation" "Reforged Event Info"
        )
        
    )
    
    function AddKey key=
    (
        if ( myNoteTrack == undefined ) then myNoteTrack = notetrack "Notes"
        
        addNewNoteKey myNoteTrack key
        
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

