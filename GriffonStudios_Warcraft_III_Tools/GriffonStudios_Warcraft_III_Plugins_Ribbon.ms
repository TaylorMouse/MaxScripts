/*
    .SYNOPSIS
    | Ribbon Emitter for Warcraft III
    
    .COPYRIGHT
    | © 2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

plugin simpleManipulator WarcraftIII_Ribbon
    name: "Ribbon"
    classID:#(0x17a92fa0, 0x1f3612d1)
    category:"Warcraft III"
(
    local heightA = [0,0,0]
    local heightB = [0,0,0]
    
    parameters main rollout:params
    (
        staticHeightAbove   type:#float     default:8.0     animatable:true  ui:spn_staticHeightAbove
        staticHeightBelow   type:#float     default:8.0     animatable:true  ui:spn_staticHeightBelow
        staticAlpha         type:#float     default:1.0     animatable:true  ui:spn_staticAlpha
        staticColor         type:#color     default:[0,0,0] animatable:true  ui:col_staticColor
        lifeSpan            type:#float     default:2.0     animatable:true  ui:spn_lifeSpan
        emissionRate        type:#integer   default:10      animatable:true  ui:spn_emissionRate
        flipbookRows        type:#integer   default:1       animatable:false ui:spn_flipbookRows
        flipbookColumns     type:#integer   default:1       animatable:false ui:spn_flipbookColumns
        flipbookSlot        type:#integer   default:0       animatable:true  ui:spn_flipbookSlot
        gravity             type:#float     default:0.0     animatable:true  ui:spn_gravity
        mtlsId              type:#material                  animatable:false ui:mat_mtlsId
        
        on staticHeightAbove set val do 
        (
            if (val <0) then this.staticHeightAbove =0
            heightA.y = staticHeightAbove
        )
        on staticHeightBelow set val do 
        (
            if (val <0) then this.staticHeightBelow =0
            heightB.y = staticHeightBelow
        )


        
    )
    rollout params "Ribbon Parameters"
    (
        local y = 10
        local step = 30
        label lbl1 "Above:" align:#left offset:[0,20]
        spinner spn_staticHeightAbove ""    range:[0,10000,25]  align:#right offset:[0,-20]
        
        label lbl2 "Below:" align:#left offset:[0,0]
        spinner spn_staticHeightBelow ""    range:[0,10000,25]  align:#right offset:[0,-20]

        
        label lbl6 "Edges/Sec:" align:#left offset:[0,0]
        spinner spn_emissionRate      "" range:[0,10000,25]  align:#right offset:[0,-20]
        
        label lbl5 "Edges Life:" align:#left offset:[0,0]
        spinner spn_lifeSpan          "" range:[0,10000,25]  align:#right offset:[0,-20]
        
        label lbl7 "Gravity:" align:#left offset:[0,0]
        spinner spn_gravity           ""  range:[0,10000,25]  align:#right offset:[0,-20]
        
        label lbl3 "Vertex Alpha:" align:#left offset:[0,0]
        spinner spn_staticAlpha       ""    range:[0,1.0,1.0]  align:#right offset:[0,-20]
        
        label lbl4 "Vertex Color:" align:#left offset:[0,0]
        colorpicker col_staticColor   ""    color:(color 0 0 0) align:#right offset:[0,-20]

        groupbox group1 "Common:" height:160 width:155 pos:[3,5]

        label lbl8 "Rows:" align:#left offset:[0,20]
        spinner spn_flipbookRows      "" range:[0,64,1]   align:#right offset:[0,-20]

        label lbl9 "Columns:" align:#left offset:[0,0]
        spinner spn_flipbookColumns   "" range:[0,64,1] align:#right offset:[0,-20]  
        
        label lbl10 "Slot:" align:#left offset:[0,0]
        spinner spn_flipbookSlot   "" range:[0,64,0] align:#right offset:[0,-20]  
        
        groupbox group2 "Flip Book:" height:90 width:155 pos:[3,170]


        materialButton mat_mtlsId "(none)" align:#center offset:[0,15] width:150 height:30
        groupbox group3 "Material:" height:60 width:155 pos:[3,265]
        
    )
    
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
        local unselectedColor = [1,0.25,0]
        local hoverColor = [1,1,0] 
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor hoverColor
    )
    
    on updateGizmos do
    (
        this.clearGizmos()
        
        -- the box
        BuildGizmo #([0,-2,0],[0,-2,8])
        BuildGizmo #([0,2,0],[0,2,8])
        BuildGizmo #([0,-4,8],[0,0,12],[0,4,8],[0,-4,8])
        
        -- the cross
        BuildGizmo #(heightB * -1,[0,0,0])
        BuildGizmo #([0,0,0],heightA)
        --BuildGizmo #([0,-8,0],[0,8,0])
        BuildGizmo #([0,0,-8],[0,0,24])
    )
    
)

