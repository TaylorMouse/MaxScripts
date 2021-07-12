/*
    .SYNOPSIS
    | Behavior (GLBS) for Warcraft III
    
    .COPYRIGHT
    | ©2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

plugin simpleManipulator WarcraftIII_Behavior
    name: "Behavior"
    classID:#(0x23d03ade, 0x7a156813)
    category:"Warcraft III"
(
    local selectedItem
    local selectedBone
    
    parameters main rollout:params 
    ( 
        listOfBones type:#nodeTab tabSizeVariable:true
    )
    
    rollout params "Behavior Properties"
    (
        label lbl1 "Press the Add button and pick a bone to add to the list" align:#left offset:[0,20] width:130 height:50
        
        dotNetControl lvBoneList "System.Windows.Forms.ListView" width:130 height:200 align:#center
        
        button btnAdd  "Add" height:30 width:62 align:#left offset:[2,0]
        button btnRemove "Remove" height:30 width:62 align:#right offset:[-2,-35]
        button btnInfo "Info" height:30 width:130
        
        groupbox group1 "Common" height:400 width:155 pos:[3,5]
        
        function UpdateList=
        (
            format "Current bone list\n%\n" listOfBones
                
            try(lvBoneList.Items.clear()) catch()
            
            if listOfBones.count == 0 then return undefined
            
            local listOfItems = #()
            for b in ListOfBones do
            (
                local item = dotNetObject "System.Windows.Forms.ListViewItem"
                item.Text = b.Name 
                append listOfItems item
            )
            lvBoneList.Items.AddRange listOfItems

        )
        
        function AddItem=
        (
            obj = pickobject()
            
            if ( classof obj == BoneGeometry ) then appendifunique listOfBones obj

            format "Added Bone\n%\n" listOfBones
            UpdateList()
        )
        
        function RemoveItem=
        (
            if selectedItem == undefined then 
                return undefined
            
            for i=1 to listOfBones.count do
                if selectedItem.Text == listOfBones[i].name then deleteItem listOfBones i
            
            format "Removed Bone\n%\n" listOfBones
            UpdateList()
        )
        
        function ShowMessageBox message title=
        (
            local msgbox = dotnetclass "System.Windows.Forms.MessageBox"
            local msgboxbuttons = dotnetclass "System.Windows.Forms.MessageBoxButtons"
            local msgboxicons = dotnetclass "System.Windows.Forms.MessageBoxIcon"
           
            msgbox.show message title msgboxbuttons.OK msgboxicons.none
        )
        
        on params open do
        (
            lvBoneList.View = (dotNetClass "System.Windows.Forms.View").Details
            lvBoneList.FullRowSelect = true
            lvBoneList.gridLines = true
            lvBoneList.HideSelection = false
            lvBoneList.Columns.Add "Bones Global Sequence" -2
            lvBoneList.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").Ascending
            try(lvBoneList.Items.clear()) catch() 
            UpdateList()
        )
        on lvBoneList ItemSelectionChanged arg do
        (
            selectedItem = arg.Item
            selectedBone = getnodebyname arg.Item.Text
            
            if selectedBone == undefined then RemoveItem()

        )
        
        on btnAdd    pressed do ( AddItem() )
        on btnRemove pressed do ( RemoveItem() )
        on btnInfo   pressed do ( ShowMessageBox "The selected bone(s) will be marked for the Global Sequence (GLBS) Animation " "Warcraft III Global Sequence Animation" )
        
    )
    
    tool create
    (
        on mousePoint click do
        (
            case click of
                 (
                    1:(
                        nodeTM.translation = gridPoint
                        listOfItems = #()
                        #stop
                      )
                    2:( #stop )
                  )
        )
    )
    function BuildGizmo points=
    (
        local unselectedColor = [1,0.5,0] 
        local selectedColor = [1,1,0]
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    function BuildGizmoCircle radius=
    (
        local unselectedColor = [1,0.5,0] 
        local selectedColor = [1,1,0]

        local giz = manip.makeCircle [0,0,0] radius 24

        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    on updateGizmos do
    (
        this.clearGizmos()

        BuildGizmoCircle 50.0
        BuildGizmo #([-20,30,0], [10,30,0],[20,20,0],[20,10,0], [10,0,0],[20,-10,0], [20,-20,0], [10,-30,0],[-20,-30,0],[-20,30,0])
        BuildGizmo #( [-12.5,25,0], [6.5,25,0], [12.5,20,0], [12.5,11,0], [6.5,5,0], [-12.5,5,0],[-12.5,25,0] )
        BuildGizmo #( [-12.5,-25,0], [6.5,-25,0], [12.5,-20,0], [12.5,-11,0], [6.5,-5,0], [-12.5,-5,0],[-12.5,-25,0] )
    )
    
)
