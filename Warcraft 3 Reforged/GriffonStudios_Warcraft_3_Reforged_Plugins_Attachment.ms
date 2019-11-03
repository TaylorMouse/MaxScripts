/*
    Written by Taylor Mouse © 2020
    for
    Warcraft 3 Reforged

*/


plugin simpleManipulator WC3RefAttachment
    name: "Attachment"
    classID:#(0x516e789, 0x5987888c)
    category:"Warcraft 3 Reforged"
(
    tool create
    (
        on mousePoint click do
        (
            case click of
                 (
                    1:(
                        nodeTM.translation = gridPoint
                         #stop
                      )
                  )
        )
    )
    
    function BuildGizmo points=
    (
        
        local unselectedColor = [1,1,0] 
        local selectedColor = [1,1,0]
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    
    on updateGizmos do
    (
        this.clearGizmos()

        BuildGizmo #([0,-4,0], [5,0,0], [0,4,0], [0,-4,0], [0,0,10],[0,4,0] )
        BuildGizmo #([0,0,10],[5,0,0])
        
    )
    
)

