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
    local selectedObj
    
    parameters main rollout:params 
    ( 
        listOfObjects type:#nodeTab tabSizeVariable:true
    )
    
    rollout params "Behavior Properties"
    (
        label lbl1 "Press the Add button and pick an object to add to the list" align:#left offset:[0,20] width:130 height:50
        
        dotNetControl lvBoneList "System.Windows.Forms.ListView" width:130 height:200 align:#center
        
        button btnAdd  "Add" height:30 width:62 align:#left offset:[2,0]
        button btnRemove "Remove" height:30 width:62 align:#right offset:[-2,-35]
        
        button btnSelect "Select Object" height:30 width:130
        button btnInfo "Info" height:30 width:130
        
        groupbox group1 "Common" height:400 width:155 pos:[3,5]
        
        function UpdateList=
        (
            --format "Current bone list\n%\n" listOfObjects
                
            try(lvBoneList.Items.clear()) catch()
            
            if listOfObjects.count == 0 then return undefined
            
            local objectsToAdd = #()
            
            for obj in listOfObjects do
            (
                if ( obj != undefined and not (isdeleted obj ) ) then append objectsToAdd obj
                
            )
            listOfObjects = objectsToAdd
            
            local listOfItems = #()
            for b in listOfObjects do
            (
                local item = dotNetObject "System.Windows.Forms.ListViewItem"
                
                local type = ""
                
                if ( classof b == Editable_Mesh ) then type = "(Material)"
                if ( classof b == Dummy ) then type = "(Dummy)"
                if ( classof b == BoneGeometry ) then type = "(Bone)"
                
                item.Text = b.Name + " " + type
                item.Name = b.Name
                append listOfItems item
            )
            lvBoneList.Items.AddRange listOfItems

        )
        
        function AddItem=
        (
            obj = pickobject()
            
            if ( classof obj == BoneGeometry or classof obj == Dummy ) then appendifunique listOfObjects obj
            
            if ( classof obj == Editable_Mesh and obj.material != undefined ) then appendifunique listOfObjects obj
            
            format "Added Object\n%\n" listOfObjects
            UpdateList()
        )
        
        function RemoveItem=
        (
            if selectedItem == undefined then 
                return undefined
            
            for i=1 to listOfObjects.count do
            (
                if selectedItem.Name == listOfObjects[i].name then 
                (
                    deleteItem listOfObjects i
                    exit
                )
            )
            
            format "Removed Object\n%\n" listOfObjects
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
            lvBoneList.Columns.Add "Global Sequence List" -2
            lvBoneList.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").Ascending
            try(lvBoneList.Items.clear()) catch() 
            UpdateList()
        )
        on lvBoneList ItemSelectionChanged arg do
        (
            selectedItem = arg.Item
            
            selectedObj = getnodebyname arg.Item.Name
            
            if selectedObj == undefined then RemoveItem()

        )
        
        on btnAdd    pressed do ( AddItem() )
        on btnRemove pressed do ( RemoveItem() )
        on btnInfo   pressed do ( ShowMessageBox "The selected bone or object material will be marked for the Global Sequence (GLBS) Animation " "Warcraft III Global Sequence Animation" )
        
        on btnSelect pressed do (
            
            if ( selectedObj == undefined ) then return undefined
            
            select selectedObj
            
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
