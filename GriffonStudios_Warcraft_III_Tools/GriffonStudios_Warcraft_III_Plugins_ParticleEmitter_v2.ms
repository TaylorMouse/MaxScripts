/*
    .SYNOPSIS
    | Particle Emitter v2 for Warcraft III
    
    .COPYRIGHT
    | © 2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

plugin simpleManipulator WarcraftIII_ParticleEmitterv2
    name: "Particles v2"
    classID:#(0x5d3e79d, 0x6b2d02de)
    category:"Warcraft III"
(
    
    parameters main rollout:params1
    (
        length  type:#float ui:spn_length animatable:false
        width   type:#float ui:spn_width animatable:false
        
        speed         type:#float  ui:spn_speed
        variation     type:#float  ui:spn_variation
        coneAngle      type:#float ui:spn_coneAngle
        gravity       type:#float  ui:spn_gravity
        
        lifespan      type:#float ui:spn_lifespan
        emissionrate  type:#float ui:spn_emissionrate
        emitterType   type:#integer ui:ddl_emitterType
        rowCount      type:#integer ui:spn_rowCount
        colCount      type:#integer ui:spn_colCount

        
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
        
        particleType  type:#integer ui:ddl_particleType
        tailLength    type:#float ui:spn_tailLength
        
        startLifespanUVAnim   type:#integer ui:spn_startLifespanUVAnim
        midLifespanUVAnim     type:#integer ui:spn_midLifespanUVAnim
        endLifespanUVAnim     type:#integer ui:spn_endLifespanUVAnim
        startDecayUVAnim      type:#integer ui:spn_startDecayUVAnim
        midDecayUVAnim        type:#integer ui:spn_midDecayUVAnim
        endDecayUVAnim        type:#integer ui:spn_endDecayUVAnim
        startTailUVAnim       type:#integer ui:spn_startTailUVAnim
        midTailUVAnim         type:#integer ui:spn_midTailUVAnim
        endTailUVAnim         type:#integer ui:spn_endTailUVAnim
        startTailDecayUVAnim  type:#integer ui:spn_startTailDecayUVAnim
        midTailDecayUVAnim    type:#integer ui:spn_midTailDecayUVAnim
        endTailDecayUVAnim    type:#integer ui:spn_endTailDecayUVAnim
        
        blendMode             type:#integer   ui:ddl_blendMode  
        texture               type:#string    ui:et_TextureName
        priorityPlane         type:#integer   ui:spn_priorityPlane
        replacableTextureId   type:#integer   ui:ddl_replacableTexture
        
        /* Flags */
        DONT_INHERIT_TRANSLATION type:#boolean default:false animatable:false  ui:chk_INHERIT_TRANSLATION
        DONT_INHERIT_SCALING type:#boolean default:false animatable:false  ui:chk_INHERIT_SCALING
        DONT_INHERIT_ROTATION type:#boolean default:false animatable:false  ui:chk_INHERIT_ROTATION  
        BILLBOARDED type:#boolean default:false animatable:false ui:chk_BILLBOARDED    
        BILLBOARD_LOCK_X type:#boolean default:false animatable:false ui:chk_BILLBOARD_LOCK_X    
        BILLBOARD_LOCK_Y type:#boolean default:false animatable:false  ui:chk_BILLBOARD_LOCK_Y   
        BILLBOARD_LOCK_Z type:#boolean default:false animatable:false  ui:chk_BILLBOARD_LOCK_Z
        GENOBJECT_MDLBONESECTION type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLBONESECTION
        GENOBJECT_MDLLIGHTSECTION type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLLIGHTSECTION
        GENOBJECT_MDLEVENTSECTION type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLEVENTSECTION 
        GENOBJECT_MDLATTACHMENTSECTION type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLATTACHMENTSECTION
        GENOBJECT_MDLPARTICLEEMITTER2 type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLPARTICLEEMITTER2
        GENOBJECT_MDLHITTESTSHAPE type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLHITTESTSHAPE
        GENOBJECT_MDLRIBBONEMITTER type:#boolean default:false animatable:false  ui:chk_GENOBJECT_MDLRIBBONEMITTER
        PROJECT type:#boolean default:false animatable:false  ui:chk_PROJECT  
        UNSHADED type:#boolean default:false animatable:false  ui:chk_UNSHADED
        SORT_PRIMITIVES_FAR_Z type:#boolean default:false animatable:false  ui:chk_SORT_PRIMITIVES_FAR_Z
        LINE_EMITTER type:#boolean default:false animatable:false  ui:chk_LINE_EMITTER 
        PARTICLE_UNFOGGED type:#boolean default:false animatable:false  ui:chk_PARTICLE_UNFOGGED
        PARTICLE_USE_MODEL_SPACE type:#boolean default:false animatable:false  ui:chk_PARTICLE_USE_MODEL_SPACE
        PARTICLE_INHERIT_SCALE type:#boolean default:false animatable:false  ui:chk_PARTICLE_INHERIT_SCALE
        PARTICLE_INSTANT_VELOCITY_LIN type:#boolean default:false animatable:false   ui:chk_PARTICLE_INSTANT_VELOCITY_LIN 
        PARTICLE_0XKILL type:#boolean default:false animatable:false  ui:chk_PARTICLE_0XKILL  
        PARTICLE_Z_VELOCITY_ONLY type:#boolean default:false animatable:false  ui:chk_PARTICLE_Z_VELOCITY_ONLY 
        PARTICLE_TUMBLER type:#boolean default:false animatable:false  ui:chk_PARTICLE_TUMBLER    
        PARTICLE_TAIL_GROWS type:#boolean default:false animatable:false  ui:chk_PARTICLE_TAIL_GROWS    
        PARTICLE_EXTRUDE type:#boolean default:false animatable:false  ui:chk_PARTICLE_EXTRUDE   
        PARTICLE_XYQUADS type:#boolean default:false animatable:false  ui:chk_PARTICLE_XYQUADS  
        PARTICLE_PROJECT type:#boolean default:false animatable:false  ui:chk_PARTICLE_PROJECT  
        PARTICLE_FOLLOW type:#boolean default:false animatable:false  ui:chk_PARTICLE_FOLLOW  
        
        
    )
    
    rollout params1 "Particle Parameters"
    (
        /* SHAPE */
        spinner spn_length "Height:"   range:[0,10000,25.0]   align:#right offset:[0,15]
        spinner spn_width  "Width:"    range:[0,10000,25.0]   align:#right offset:[0,0]
        groupbox group1 "Shape"       height:65 width:155 pos:[3,5]
        
        /* COLOR */
        label lblColorStart "Start"  align:#left   offset:[7,15]
        label lblColorMid "Mid"      align:#center offset:[0,-17]
        label lblColorEnd "End"      align:#right  offset:[-10,-18]
        colorpicker cp_colorStart "" align:#left   offset:[-5,0]
        colorpicker cp_colorMid ""   align:#center offset:[-2,-25]
        colorpicker cp_colorEnd ""   align:#right  offset:[0,-25]
        spinner spn_midtime "Mid Time: " range:[0,1.0,0.5] align:#left offset:[0,0] width:80 offset:[0,0]
        groupbox group2 "Color" height:90 width:155 pos:[3,75]
        
        /* SIZE */
        label lblSizeStart "Start"  align:#left   offset:[7,15]
        label lblSizeMid "Mid"      align:#center offset:[0,-17]
        label lblSizeEnd "End"      align:#right  offset:[-10,-18]
        spinner spn_sizeStart ""    align:#left   range:[0,10000,25.0] offset:[-8,0]  width:50
        spinner spn_sizeMid ""      align:#center range:[0,10000,25.0] offset:[0,-20] width:50
        spinner spn_sizeEnd ""      align:#right  range:[0,10000,25.0] offset:[7,-20] width:50
        groupbox group3 "Size" height:65 width:155 pos:[3,170]
        
        /* ALPHA */
        label lblAlphaStart "Start" align:#left   offset:[7,15]
        label lblAlphaMid "Mid"     align:#center offset:[0,-17]
        label lblAlphaEnd "End"     align:#right  offset:[-10,-18]
        spinner spn_AlphaStart ""   align:#left   range:[0,255,255]  offset:[0,0]  width:40 type:#integer
        spinner spn_AlphaMid ""     align:#center range:[0,255,255]  offset:[0,-20] width:40 type:#integer
        spinner spn_AlphaEnd ""     align:#right  range:[0,255,255]  offset:[0,-20] width:40 type:#integer
        groupbox group4 "Alpha" height:60 width:155 pos:[3,240]
        
        /* VELOCITY */
        spinner spn_speed     "Speed:"      range:[0,10000,25.0] align:#right offset:[0,15]
        spinner spn_variation "Variation:"  range:[0,10000,25.0] align:#right offset:[0,0]
        spinner spn_coneAngle "Spread:"     range:[0,179,25.0]   align:#right offset:[0,0]
        spinner spn_gravity   "Gravity:"    range:[0,179,25.0]   align:#right offset:[0,0]
        groupbox group5 "Velocity" height:105 width:155 pos:[3,305]
        
        /* EMISSION */
        spinner spn_lifespan     "Lifetime:"      range:[0,1000,25.0] align:#right offset:[0,15]
        spinner spn_emissionrate "Emission rate:" range:[0,1000,25.0] align:#right offset:[0,0]
        dropdownlist ddl_emitterType "Emitter Type" items:#("Normal", "Line")
        groupbox group6 "Emission" height:105 width:155 pos:[3,415]

        /* FLIPBOOK*/
        spinner spn_rowCount "Rows:"    range:[1,128,1] align:#right offset:[0,15] type:#integer
        spinner spn_colCount "Columns:" range:[1,128,1] align:#right offset:[0,0]  type:#integer
        groupbox group7 "Flip book" height:60 width:155 pos:[3,525]

        /* PARTICLE OPTIONS */
        label lblType "Type:" align:#left offset:[0,20]
        dropdownlist ddl_particleType "" items:#("Head", "Tail", "Both")  offset:[0,-20] width:100 align:#right default:2
        spinner spn_tailLength "Tail length:" align:#right offset:[0,0]
        groupbox group8 "Particle Options" height:80 width:155 pos:[3,590]

        /* TEXTURE OPTIONS */
        editText et_TextureName "" offset:[0,20] width:120 align:#left height:18 style_sunkenedge:false 
        button btn_texture "..." align:#right offset:[5,-22] width:20 height:15
        label lblbmode "Blend mode:" align:#left offset:[0,0]
        dropdownlist ddl_blendMode "" items:#("Opaque", "Add", "Mod", "Modx2", "Blend", "BlendAdd")  offset:[0,0] 
        label lblrepText "Replacable Texture:" align:#left offset:[0,0]
        dropdownlist ddl_replacableTexture "" items:#("None", "Team Color", "Team Glow") offset:[0,0] 
        spinner spn_priorityPlane "Priority:" type:#integer range:[0,100,0]
        groupbox group9 "Texture Options" height:180 width:155 pos:[3,675]

        /* Lifespan Head UV */
        label lbl001 "Start"   align:#left   offset:[7,15]
        label lbl002 "Mid"     align:#center offset:[0,-17]
        label lbl003 "End"     align:#right  offset:[-10,-18]
        spinner spn_startLifespanUVAnim   "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
        spinner spn_midLifespanUVAnim     "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        spinner spn_endLifespanUVAnim     "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        groupbox group10 "Lifespan Head UV" height:70 width:155 pos:[3,860]

        /* Decay Head UV */
        label lbl004 "Start" align:#left   offset:[7,15]
        label lbl005 "Mid"     align:#center offset:[0,-17]
        label lbl006 "End"     align:#right  offset:[-10,-18]
        spinner spn_startDecayUVAnim     "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
        spinner spn_midDecayUVAnim       "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        spinner spn_endDecayUVAnim       "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        groupbox group11 "Decay Head UV" height:70 width:155 pos:[3,935]

        /* Lifespan Tail UV */
        label lbl007 "Start"   align:#left   offset:[7,15]
        label lbl008 "Mid"     align:#center offset:[0,-17]
        label lbl009 "End"     align:#right  offset:[-10,-18]
        spinner spn_startTailUVAnim      "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
        spinner spn_midTailUVAnim        "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        spinner spn_endTailUVAnim        "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        groupbox group12 "Lifespan Tail UV" height:70 width:155 pos:[3,1010]

        /* Decay Tail UV*/
        label lbl010 "Start" align:#left   offset:[7,15]
        label lbl011 "Mid"     align:#center offset:[0,-17]
        label lbl012 "End"     align:#right  offset:[-10,-18]
        spinner spn_startTailDecayUVAnim "" align:#left   range:[0,1024,0]  offset:[0,0]  width:40 type:#integer
        spinner spn_midTailDecayUVAnim   "" align:#center range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        spinner spn_endTailDecayUVAnim   "" align:#right  range:[0,1024,0]  offset:[0,-20]  width:40 type:#integer
        groupbox group13 "Decay Tail UV" height:70 width:155 pos:[3,1085]

        checkbox chk_INHERIT_TRANSLATION             "Inherit Translation" align:#left offset:[0,20] 
        checkbox chk_INHERIT_SCALING                 "Inherit Scaling" align:#left offset:[0,0]
        checkbox chk_INHERIT_ROTATION                "Inherit Rotation" align:#left offset:[0,0]
        checkbox chk_BILLBOARDED            	     "Billboard" align:#left offset:[0,0]
        checkbox chk_BILLBOARD_LOCK_X                "Lock X" align:#left offset:[0,0]
        checkbox chk_BILLBOARD_LOCK_Y                "Lock Y" align:#left offset:[0,0]
        checkbox chk_BILLBOARD_LOCK_Z                "Lock Z" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLBONESECTION        "Bone Section" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLLIGHTSECTION       "Light Section" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLEVENTSECTION       "Event Section" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLATTACHMENTSECTION  "Attachment Section" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLPARTICLEEMITTER2   "Particle Section" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLHITTESTSHAPE       "Hit Test Section" align:#left offset:[0,0]
        checkbox chk_GENOBJECT_MDLRIBBONEMITTER      "Ribbon Section" align:#left offset:[0,0]
        checkbox chk_PROJECT           				 "Project" align:#left offset:[0,0]
        checkbox chk_UNSHADED          				 "Unshaded" align:#left offset:[0,0]
        checkbox chk_SORT_PRIMITIVES_FAR_Z   		 "Sort Z" align:#left offset:[0,0]
        checkbox chk_LINE_EMITTER            		 "Line Emitter" align:#left offset:[0,0]
        checkbox chk_PARTICLE_UNFOGGED       		 "Unfogged" align:#left offset:[0,0]
        checkbox chk_PARTICLE_USE_MODEL_SPACE 		 "Use Model Space" align:#left offset:[0,0]
        checkbox chk_PARTICLE_INSTANT_VELOCITY_LIN   "Instant Velocity Line" align:#left offset:[0,0]
        checkbox chk_PARTICLE_0XKILL            	 "0 x kill" align:#left offset:[0,0]
        checkbox chk_PARTICLE_Z_VELOCITY_ONLY        "Z Direction Only" align:#left offset:[0,0]
        checkbox chk_PARTICLE_TUMBLER            	 "Tumbler" align:#left offset:[0,0]
        checkbox chk_PARTICLE_TAIL_GROWS             "Tail Grows" align:#left offset:[0,0]
        checkbox chk_PARTICLE_INHERIT_SCALE          "Inherit Particle Scale" align:#left offset:[0,0]
        checkbox chk_PARTICLE_EXTRUDE            	 "Extrude" align:#left offset:[0,0]
        checkbox chk_PARTICLE_XYQUADS            	 "XY Quads" align:#left offset:[0,0]
        checkbox chk_PARTICLE_PROJECT            	 "Particel Projection" align:#left offset:[0,0]
        checkbox chk_PARTICLE_FOLLOW                 "Follow" align:#left offset:[0,0]

         groupbox group14 "Flags " height:630 width:155 pos:[3,1160]
        
        on btn_texture pressed do
        (
            local file = getOpenFileName \
         			caption:"Warcraft 3 Reforged" \
         			types:"Supported Files|*.dds|Direct Draw Surface(*.dds)|*.dds|All Files|*.*" \
         			historyCategory:"ReforgedDDSPreset"
            
            if ( file != undefined ) then 
                this.texture = file
            
        )
        on params1 open do
        (
            if length == 0 then length = 10
            if width == 0 then width = 10
            if emittertype == 0 then emittertype = 1
            if particleType == 0 then particleType  = 2
            if blendMode == 0 then blendMode = 1
            if replacableTextureId == 0 then replacableTextureId = 1
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


