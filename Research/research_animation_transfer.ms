
clearListener()

function ListChildren node newNode space = 
(
    local dummyLayer = GriffonStudios_Helpers.CreateLayer "Dummy Layer"
    
    for child in node.children do
    (
        local newName = "dummy_" + child.name
        local d = dummy name:newName
        d.scale = [0.1,0.1,0.1]
        d.transform = node.transform
        d.parent = newNode
        d.showlinks = true
        
        d.controller = copy child.controller
        dummyLayer.addNode d
        
        format "% %\n" space child.name
        if (child.children != undefined and child.children.count > 0 ) then
            ListChildren child d (space + " ")
    )
    
)

function CopyExistingAnimationToDummyState=
(
    local dummyLayer = GriffonStudios_Helpers.CreateLayer "Dummy Layer"

    for obj in objects do
    (
        if ( classof obj == BoneGeometry and 
             obj.controller != undefined and 
             obj.IsHidden == false
            ) then
        (
            if ( obj.parent == undefined ) then 
            (
                print obj.name
                local newName = "dummy_" + obj.name
                local d = dummy name:newName
                d.transform = obj.transform
                d.showlinks = true
                d.controller = copy obj.controller
                dummyLayer.addNode d
                ListChildren obj d " "
            )
        )
    )

)

function DeleteAnimationFromSelectedBones=
(
    for obj in selection do
    (
        deletekeys obj #allKeys
    )
)

function CopyDummyAnimationToExisting=
(
    
    
)

for obj in objects do
(
    if (classof obj == Dummy ) then
    (
        local originalname = substring obj.name 7 -1
        print obj.Name
        local originalBone = getNodeByName originalname
        originalBone.controller = copy obj.controller
            
    )
    
)

