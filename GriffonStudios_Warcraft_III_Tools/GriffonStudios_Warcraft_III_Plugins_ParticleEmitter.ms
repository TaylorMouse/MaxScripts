/*
    .SYNOPSIS
    | Particle Emitterfor Warcraft III
    
    .COPYRIGHT
    | © 2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

plugin simpleManipulator WarcraftIII_ParticleEmitter
    name: "Particles"
    classID:#(0x5b19689e, 0x58d0d273)
    category:"Warcraft III"
(
    
    parameters main rollout:wc3particleemitter
    (
        -- emitter options
        speed         type:#float  ui:spn_speed
        variation     type:#float  ui:spn_variation animatable:false
        coneAngle     type:#float ui:spn_coneAngle animatable:false
        
        -- timing options
        life          type:#float ui:spn_lifespan animatable:false
        partsSec      type:#float ui:spn_emissionrate
        squirt        type:#boolean  ui:ckb_squirt animatable:false

        -- size options
        width         type:#float ui:spn_width      animatable:false
        length        type:#float ui:spn_length     animatable:false
        lineEmitter   type:#boolean default:false animatable:false  ui:chk_LINE_EMITTER 
        
        -- texture options
        blendMode     type:#integer   ui:ddl_blendMode 
        texture       type:#string    ui:et_TextureName
        rowCount      type:#integer ui:spn_rowCount
        colCount      type:#integer ui:spn_colCount
        unshaded      type:#boolean default:false animatable:false  ui:chk_UNSHADED
        sort_z        type:#boolean default:false animatable:false  ui:chk_SORT_PRIMITIVES_FAR_Z
        unfogged      type:#boolean default:false animatable:false  ui:chk_PARTICLE_UNFOGGED
        replacableTextureId   type:#integer   ui:ddl_replacableTexture
        
        -- particle options
        particleType  type:#integer ui:ddl_particleType -- > head tail both
        tailLength    type:#float ui:spn_tailLength
        midTime       type:#float ui:spn_midtime
        
        startColor    type:#color ui:cp_colorStart
        midColor      type:#color ui:cp_colorMid
        endColor      type:#color ui:cp_colorEnd
        
        startAlpha    type:#integer ui:spn_AlphaStart
        midAlpha      type:#integer ui:spn_AlphaMid
        endAlpha      type:#integer ui:spn_AlphaEnd
        
        startSize     type:#float ui:spn_sizeStart
        midSize       type:#float ui:spn_sizeMid
        endSize       type:#float ui:spn_sizeEnd
        
        -- head
        startLifespanUVAnim   type:#integer ui:spn_startLifespanUVAnim
        midLifespanUVAnim     type:#integer ui:spn_midLifespanUVAnim
        endLifespanUVAnim     type:#integer ui:spn_endLifespanUVAnim

        startDecayUVAnim      type:#integer ui:spn_startDecayUVAnim
        midDecayUVAnim        type:#integer ui:spn_midDecayUVAnim
        endDecayUVAnim        type:#integer ui:spn_endDecayUVAnim
        
        -- tail
        startTailUVAnim       type:#integer ui:spn_startTailUVAnim
        midTailUVAnim         type:#integer ui:spn_midTailUVAnim
        endTailUVAnim         type:#integer ui:spn_endTailUVAnim
        
        startTailDecayUVAnim  type:#integer ui:spn_startTailDecayUVAnim
        midTailDecayUVAnim    type:#integer ui:spn_midTailDecayUVAnim
        endTailDecayUVAnim    type:#integer ui:spn_endTailDecayUVAnim
        
        priorityPlane         type:#integer   ui:spn_priorityPlane
        particlesInModelSpace type:#boolean default:false animatable:false  ui:chk_PARTICLE_USE_MODEL_SPACE
        xyQuads               type:#boolean default:false animatable:false  ui:chk_PARTICLE_XYQUADS
        
    )
    
    rollout wc3particleemitter "Particle Parameters"
    (
        /* Emitter options */
        spinner spn_speed     "Speed:"      range:[0,10000,25.0] align:#right offset:[0,15]
        spinner spn_variation "Variation:"  range:[0,10000,25.0] align:#right offset:[0,0]
        spinner spn_coneAngle "Spread:"     range:[0,179,25.0]   align:#right offset:[0,0]
        
        groupbox grp01 "Emitter Options" height:90 width:155 pos:[3,5]
        
        /* Timing options */
        spinner spn_lifespan     "Life (sec):"      range:[0,100,1.0] align:#right offset:[0,15]
        spinner spn_emissionrate "Parts/Sec:"       range:[0,500,50.0] align:#right offset:[0,0]
        checkbox ckb_squirt      "Squirt"           align:#left offset:[0,0]
        
        groupbox grp02 "Timing Options" height:90 width:155 pos:[3,100]
        
        /* Size options */
        spinner spn_width  "Width:"    range:[0,10000,25.0]   align:#right offset:[0,15]
        spinner spn_length "Length:"   range:[0,10000,25.0]   align:#right offset:[0,0]
        checkbox chk_LINE_EMITTER "Line Emitter" align:#left offset:[0,0]
         
        groupbox grp03 "Size Options" height:90 width:155 pos:[3,195]
        
        /* Texture options */
        label lblbmode "Blend mode:" align:#left offset:[0,15]
            dropdownlist ddl_blendMode "" items:#("Blend", "Add", "Mod", "Modx2", "Alpha Key")  offset:[0,0] 
        
        label lblTextN "Flipbook texture:" align:#left offset:[0,0]
            editText et_TextureName "" offset:[0,0] width:120 align:#left height:18 style_sunkenedge:false 
            button btn_texture "..." align:#right offset:[5,-22] width:20 height:15
        
        spinner spn_rowCount "Rows:"    range:[1,128,1] align:#right offset:[0,0] type:#integer
        spinner spn_colCount "Columns:" range:[1,128,1] align:#right offset:[0,0]  type:#integer
        
        checkbox chk_UNSHADED          				 "Unshaded" align:#left offset:[0,0] tooltip:"The particles do not use lighting and are always full bright."
        checkbox chk_SORT_PRIMITIVES_FAR_Z   		 "Sort Z" align:#left offset:[0,0]   tooltip:"Particles are sorted in the Z depth"
        checkbox chk_PARTICLE_UNFOGGED       		 "Unfogged" align:#left offset:[0,0] tooltip:"Particles ignore distance fog"
        
        label lblrepText "Replacable Texture:" align:#left offset:[0,0]
            dropdownlist ddl_replacableTexture "" items:#("None", "Team Color", "Team Glow") offset:[0,0] 

        groupbox grp04 "Texture Options" height:250 width:155 pos:[3,290]
        
        /* Particle Options */
        label lblType "Type:" align:#left offset:[0,20]
            dropdownlist ddl_particleType "" items:#("Head", "Tail", "Both")  offset:[0,-20] width:100 align:#right default:2
        
        spinner spn_tailLength "Tail length:" align:#right offset:[0,0]
        
        label lblParametricTime "Time (Parametric):" align:#left offset:[0,0] tooltip:"The relative time of the middle key to the life."
            spinner spn_midtime "Mid Time: " range:[0,1.0,0.5] align:#left offset:[0,0] width:80 offset:[0,0]
        
        label lblColorPicker "Color"
            label lblColorStart "Start"  align:#left   offset:[7,0]
            label lblColorMid "Mid"      align:#center offset:[0,-17]
            label lblColorEnd "End"      align:#right  offset:[-10,-18]
            colorpicker cp_colorStart "" align:#left   offset:[-5,0]   
            colorpicker cp_colorMid ""   align:#center offset:[-2,-25] 
            colorpicker cp_colorEnd ""   align:#right  offset:[0,-25]  
        
        label lblAlphaPicker "Alpha" tooltip:"Three alpha values for the particle. Zero is transparent"
            label lblAlphaStart "Start" align:#left   offset:[7,0]
            label lblAlphaMid "Mid"     align:#center offset:[0,-17]
            label lblAlphaEnd "End"     align:#right  offset:[-10,-18]
            spinner spn_AlphaStart ""   align:#left   range:[0,255,255]  offset:[0,0]  width:40 type:#integer
            spinner spn_AlphaMid ""     align:#center range:[0,255,255]  offset:[0,-20] width:40 type:#integer
            spinner spn_AlphaEnd ""     align:#right  range:[0,255,255]  offset:[0,-20] width:40 type:#integer
        
        label lblScalePicker "Scale"
            label lblSizeStart "Start"  align:#left   offset:[7,0]
            label lblSizeMid "Mid"      align:#center offset:[0,-17]
            label lblSizeEnd "End"      align:#right  offset:[-10,-18]
            spinner spn_sizeStart ""    align:#left   range:[0,10000,25.0] offset:[-8,0]  width:50
            spinner spn_sizeMid ""      align:#center range:[0,10000,25.0] offset:[0,-20] width:50
            spinner spn_sizeEnd ""      align:#right  range:[0,10000,25.0] offset:[7,-20] width:50

        label lbl101 "Lifespan Head UV" tooltip:"Starting and ending cell number for animating texture sequence of the first half of the Head particle�s life. Repeat will cause this animating texture to cycle"
            label lbl001 "Start"   align:#left   offset:[7,0]
            label lbl002 "Mid"     align:#center offset:[0,-17]
            label lbl003 "End"     align:#right  offset:[-10,-18]
            spinner spn_startLifespanUVAnim   "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
            spinner spn_midLifespanUVAnim     "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
            spinner spn_endLifespanUVAnim     "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        
        label lbl102 "Decay Head UV" tooltip:"Starting and ending cell number for animating texture sequence of the second half of the Head particle�s life. Repeat will cause this animating texture to cycle"
            label lbl004 "Start" align:#left   offset:[7,0]
            label lbl005 "Mid"     align:#center offset:[0,-17]
            label lbl006 "End"     align:#right  offset:[-10,-18]
            spinner spn_startDecayUVAnim     "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
            spinner spn_midDecayUVAnim       "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
            spinner spn_endDecayUVAnim       "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer

        label lbl103 "Lifespan Tail UV" tooltip:"Starting and ending cell number for animating texture sequence of the first half of the Tail particle�s life. Repeat will cause this animating texture to cycle."
            label lbl007 "Start"   align:#left   offset:[7,0]
            label lbl008 "Mid"     align:#center offset:[0,-17]
            label lbl009 "End"     align:#right  offset:[-10,-18]
            spinner spn_startTailUVAnim      "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
            spinner spn_midTailUVAnim        "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
            spinner spn_endTailUVAnim        "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        
        label lbl104 "Decay Tail UV" tooltip:"Starting and ending cell number for animating texture sequence of the second half of the Tail particle�s life. Repeat will cause this animating texture to cycle"
            label lbl010 "Start" align:#left   offset:[7,0]
            label lbl011 "Mid"     align:#center offset:[0,-17]
            label lbl012 "End"     align:#right  offset:[-10,-18]
            spinner spn_startTailDecayUVAnim "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
            spinner spn_midTailDecayUVAnim   "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
            spinner spn_endTailDecayUVAnim   "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
            
        
        groupbox grp05 "Particle Options" height:530 width:155 pos:[3,545]
        
        /* Other options */
        spinner spn_priorityPlane "Priority Plane:" type:#integer range:[0,100,0] offset:[0,20] tooltip:"When you are using blend mode, the Priority Plane option can cause particles to draw in a specific order with other blend objects in the same model. The lower the number, the earlier the particles will draw."
        checkbox chk_PARTICLE_USE_MODEL_SPACE 		 "Particles in Model Space" align:#left offset:[0,0] tooltip:"Causes animation of the particle emitter to be carried over to the particles."
        checkbox chk_PARTICLE_XYQUADS            	 "XY Quads" align:#left offset:[0,0] tooltip:"Causes the particles to be a type of tail that orients to the XY grid"

        groupbox grp06 "Other Options" height:90 width:155 pos:[3,1080]
        
        on btn_texture pressed do
        (
            local file = getOpenFileName \
         			caption:"Warcraft 3 Reforged" \
         			types:"Supported Files|*.TGA|Targa Image(*.TGA)|*.TGA|All Files|*.*" \
         			historyCategory:"WarcraftIIIPreset"
            
            if ( file != undefined ) then 
                this.texture = file
            
        )
        on wc3particleemitter open do
        (
            if length == 0 then length = 10
            if width == 0 then width = 10
            if particleType == 0 then particleType  = 2
            if blendMode == 0 then blendMode = 1
            if replacableTextureId == 0 then replacableTextureId = 1
                
            
            startColor = color 255 255 255
            midColor  = color 255 255 255
            endColor  = color 255 255 255
            
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
                         #stop
                      )
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
    
    on updateGizmos do
    (
        this.clearGizmos()
        -- size of the emitter
        BuildGizmo #([-width/2,-length/2,0], [-width/2,length/2,0], [width/2,length/2,0], [width/2,-length/2,0],[-width/2,-length/2,0])
        
        -- draw the 3D Arrow
        BuildGizmo #([-2,-2,0],[2,-2,0],[2,2,0],[-2,2,0],[-2,-2,0],[-2,-2,8],[2,-2,8],[2,2,8],[-2,2,8],[-2,-2,8])
        BuildGizmo #([-2,2,0],[-2,2,8])
        BuildGizmo #([2,-2,0],[2,-2,8])
        BuildGizmo #([2,2,0],[2,2,8])
        BuildGizmo #([-4,-4,8],[-4,4,8],[4,4,8],[4,-4,8],[-4,-4,8],[0,0,12],[4,4,8])
        BuildGizmo #([-4,4,8],[0,0,12],[4,-4,8])
        
        -- cone
        local half = coneAngle / 2.0
        
        local A = 25 / cos half

        local B = sqrt ( A*A - 25*25 )
               
        local p1 = [-B,B,25]
        local p2 = [-B,-B,25]
        local p3 = [B,-B,25]
        local p4 = [B,B,25]
        BuildGizmo #(p1, p2, p3, p4, P1)
        BuildGizmo #([0,0,0],p1)
        BuildGizmo #([0,0,0],p2)
        BuildGizmo #([0,0,0],p3)
        BuildGizmo #([0,0,0],p4)
    )
    
)


