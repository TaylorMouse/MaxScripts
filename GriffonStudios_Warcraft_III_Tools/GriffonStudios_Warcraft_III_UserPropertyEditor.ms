/*
    .SYNOPSIS
    | Opens up a popup window that gets and set the userpoperies
    | this is a trimmed down version of the original Warcraft III User Porperty window
    | since the actual one only had a mere functionality anyways
    
    .COPYRIGHT
    | © 2020 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/
GLOBAL USERPROP_DEBUG = false

rollout GriffonStudios_Warcraft_III_UserPropertyEditor "User Property Editor" 
    width:200 
    height:220
(

    local selectedObject

    group "Selected object"
    (
        label lblSelectedObject "No object selected"
    )
    group "Billboarding"
    (
        dropdownlist ddBillboarding "" items:#("None", "Full", "Pivot on X Axis", "Pivot on Y Axis", "Pivot on Z Axis")
    )
    group "Other properties"
    (
        checkbox chkCollisionObject "Collision Box"
       
    )
    label lblTM "\xa9 2021 Taylor Mouse"
    button btnClose "Save & Close" height:45 width:190
    
    function UpdateUI=
    (
        local buffer = getUserPropBuffer selectedObject
        if USERPROP_DEBUG then format "Current properties set:\n%" buffer
        
        lblSelectedObject.text =  selectedObject.name + " (" + (classof selectedObject as string) + ")"
        
        chkCollisionObject.checked = false
        if ( getUserProp selectedObject "COLLISION-OBJECT" == true ) then chkCollisionObject.checked = true
        
        ddBillBoarding.selection = 1
        if ( getUserProp selectedObject "BILLBOARD" == true )        then ddBillBoarding.selection = 2
        if ( getUserProp selectedObject "BILLBOARD-LOCK-X" == true ) then ddBillBoarding.selection = 3
        if ( getUserProp selectedObject "BILLBOARD-LOCK-Y" == true ) then ddBillBoarding.selection = 4
        if ( getUserProp selectedObject "BILLBOARD-LOCK-Z" == true ) then ddBillBoarding.selection = 5
    )
    
    function ToggleCollisionObject =
    (
        if ( classof selectedObject != box and classof selectedObject != sphere and classof selectedObject != plane and classof selectedObject != cylinder ) then return undefined
        if ( getUserProp selectedObject "COLLISION-OBJECT" == true ) then
        (
            selectedObject.boxmode = true
            selectedObject.wirecolor = color 64 128 255
            selectedObject.renderable = off
            selectedObject.castShadows = off
            selectedObject.receiveshadows = off
            freeze selectedObject
        )
        else
        (
            selectedObject.boxmode = false
            unfreeze selectedObject
        )
    )
    
    on GriffonStudios_Warcraft_III_UserPropertyEditor open do
    (
        if USERPROP_DEBUG then format "selected object: %\n" $
        selectedObject = $
        UpdateUI()
    )

    on ddBillboarding selected index do
    (
        
        if USERPROP_DEBUG then format "Selected item :% %\n" index ddBillboarding.selected 
        
        local cleanBuffer = ""

        -- remove the previous billboard settings
        local buffer = getUserPropBuffer selectedObject
        local parts  = filterstring buffer "\r\n"
        for p in parts do
            if ( substring p 1 9 != "BILLBOARD" ) then cleanBuffer += p + "\r\n"
        setUserPropBuffer selectedObject cleanBuffer

        if ( index == 2 ) then setUserProp selectedObject "BILLBOARD" true
        if ( index == 3 ) then setUserProp selectedObject "BILLBOARD-LOCK-X" true
        if ( index == 4 ) then setUserProp selectedObject "BILLBOARD-LOCK-Y" true
        if ( index == 5 ) then setUserProp selectedObject "BILLBOARD-LOCK-Z" true

    )
 
    on chkCollisionObject changed theState do
    (
        if ( theState == false ) then 
        (
            local cleanBuffer = ""
            local buffer = getUserPropBuffer selectedObject
            local parts  = filterstring buffer "\r\n"
            for p in parts do
                if ( substring p 1 9 != "COLLISION" ) then cleanBuffer += p + "\r\n"
            setUserPropBuffer selectedObject cleanBuffer
        )
        if ( theState == true ) then 
        (
            setUserProp selectedObject "COLLISION-OBJECT" true
        )
        ToggleCollisionObject()
    )
    
    on btnClose pressed do
    (
        local buffer = getUserPropBuffer selectedObject
        if USERPROP_DEBUG then format "Current properties set: %\n" buffer
        
        destroydialog GriffonStudios_Warcraft_III_UserPropertyEditor
    )
    

)

