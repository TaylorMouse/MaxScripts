/*
    .SYNOPSIS
    | Attachment Point for Warcraft III
    
    .COPYRIGHT
    | ©2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

if ( DisplayWarcraftIIIAttachments != undefined ) then 
	UnregisterRedrawViewsCallback DisplayWarcraftIIIAttachments
	
function DisplayWarcraftIIIAttachments=
(
            
    gw.setTransform ( matrix3 1 )
    for obj in objects where 
        ( classof obj == WarcraftIII_Attachment and obj.ishidden == false and obj.isfrozen == false ) do
    (
        gw.text ( obj.pos + [0, 0, 10] ) ( obj.name as string ) color:Yellow
    )
    gw.updateScreen()
    
)
RegisterRedrawViewsCallback DisplayWarcraftIIIAttachments


plugin simpleManipulator WarcraftIII_Attachment
    name: "Attachment"
    classID:#(0x56444562, 0x2ab75821)
    category:"Warcraft III"
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

        BuildGizmo #([-4,0,0], [0,-5,0], [4,0,0], [-4,0,0], [0,0,10],[4,0,0] )
        BuildGizmo #([0,0,10],[0,-5,0])
        
    )
    
)
