/*
    .COPYRIGHT
    |   (c) 2020-2021 Griffon Studios
    |   Warcraft and Warcraft III Reforged are properties of Blizzard Entertainment
    
    .AUTHOR
    |   Taylor Mouse
    
    .DESCRIPTION
    |   Warcraft III Import model
    
    .RELEASE NOTES
    | 0.03 Most of the tags have been read todo, light(LITE), texture animation (TXAN), ribbons (RIBB) a particles (PREM & PRE2)
    | 0.02 Reading all the tags
    | 0.01 Initial setup
    
    .FLAGS
        0x0: helper
        0x1: dont inherit translation
        0x2: dont inherit rotation
        0x4: dont inherit scaling
        0x8: billboarded
        0x10: billboarded lock x
        0x20: billboarded lock y
        0x40: billboarded lock z
        0x80: camera anchored
        0x100: bone
        0x200: light
        0x400 event object
        0x800: attachment
        0x1000 particle emitter
        0x2000: collision shape
        0x4000: ribbon emitter
        0x8000: if particle emitter: emitter uses mdl, if particle emitter 2: unshaded
        0x10000: if particle emitter: emitter uses tga, if particle emitter 2: sort primitives far z
        0x20000: line emitter
        0x40000: unfogged
        0x80000: model space
        0x100000: xy quad
        
*/

global _helper  = undefined
global _wc3     = undefined
global _debug_read   = false
global _debug_build  = true
global gMDX = undefined

struct Warcraft_3_Build
(
    function BuildGEOS mdx=
    (
        local geos = mdx.geos
        if (geos == undefined ) then return undefined
        
        local wireColor = color 128 128 128
        
        for geo in geos do
        (
            
            if _debug_build then format "Building %\n" geo.UniqueName
            
            local layer = _helper.CreateLayer "Unit"
            
            local v  = geo.VRTX
            local n  = geo.NRMS
            local f  = geo.PVTX
            local uv = geo.UVS[1]
            local theMesh = mesh vertices:v vnorms:n name:geo.UniqueName faces:f tverts:uv 

            theMesh.WireColor = wireColor
            
            buildTVFaces theMesh false
            for i = 1 to f.count do
            ( setTVFace theMesh i f[i] )
        
            layer.AddNode theMesh
            update theMesh
            geo.meshRef = theMesh

        )
    ),
    function BuildPIVT mdx=
    (
        
        if _debug_build then format "Building Pivots\n"
                    
        local layer = _helper.CreateLayer "PIVT"
        
        for i=1 to mdx.bone.count do
            local p = point name:mdx.bone[i].name pos:mdx.pivt[mdx.bone[i].id].position size:5
        
        for i=1 to mdx.help.count do
            local p = point name:mdx.help[i].name pos:mdx.pivt[mdx.help[i].id].position size:5
        
        for i=1 to mdx.atch.count do
            local p = point name:mdx.atch[i].name pos:mdx.pivt[mdx.atch[i].id].position size:5
        
        for i=1 to mdx.evts.count do
            local p = point name:mdx.evts[i].name pos:mdx.pivt[mdx.evts[i].id].position size:5
        
        for i=1 to mdx.clid.count do
            local p = point name:mdx.clid[i].name pos:mdx.pivt[mdx.clid[i].id].position size:5

    ),
    function BuildATCH=
    (
        local atch  = mdx.atch
        local bpos  = mdx.bpos
        local boneList = mdx.bone
        
        if ( atch == undefined ) then return undefined
        format "Building Attachments\n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Attachments"
     
        sliderTime = 0f
        
        for a in atch do 
        (
            --local pnt = Point name:a.name box:off cross:on centermarker:off axistripod:off size:12
            local pnt = WC3RefAttachment name:a.name
            pnt.pos = bpos[a.id].matrix.row4
            
            layer.AddNode pnt
            if( a.parentBoneId>0) then 
            (
                local parentBone = boneList[a.parentBoneId].boneRef
                if( parentBone == undefined) then
                    parentBone = getnodebyname boneList[a.parentBoneId].name
                pnt.transform = parentbone.transform
                pnt.parent = parentBone
            )
            -- KGTR, KGRT, KGSC, KATV
            if ( a.KGRT != undefined ) then 
            (
                pnt.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = pnt.rotation.controller
                local q0 = dr.transform
                
                for anim in a.KGRT.KG do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                            
                        )
                )
                with animate on pnt.rotation.controller = copy dr.rotation.controller
                
                delete dr
            )
            if ( a.KGTR != undefined ) then
            (
                pnt.assumeSkinPose()
                
                local dp = dummy name:"DummyPositionController" 
                dp.position.controller = pnt.position.controller
                local p0 = dp.transform
                
                for anim in a.KGTR.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 dp.position = p 
                        )
                )
                with animate on pnt.position.controller = copy dp.position.controller
                
                delete dp
            )
            if ( a.KGSC != undefined ) then
            (
                pnt.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = pnt.scale.controller
                local p0 = ds.transform
                
                for anim in a.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.position = p 
                        )
                )
                with animate on pnt.scale.controller = copy ds.scale.controller
                
                delete ds
            )
                    
            if ( a.KATV != undefined ) then 
            (
                
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in a.KATV.KG do
                (
                    if ( anim.point == 0) then isVisibilityTrackRequired = true
                )
                
                if ( isVisibilityTrackRequired == true ) then
                (
                    pnt.Visibility = on
                    pnt.Visibility.controller = on_off()

                    for anim in a.KATV.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                pnt.Visibility = on
                            else
                                pnt.Visibility = off
                )
                
            )
        )
        
        
    ),
    function BuildBONE2=
    (
        if( mdx.bone == undefined ) then return undefined
        local boneList = mdx.bone
        local bpos = mdx.bpos
        local boneLayer = GriffonStudios_Helpers.CreateLayer "Bones"
        
        format "Building Bones\n"
        -- create the bones
        for b in boneList do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.setBoneEnable false 0
            
            b.boneRef = aBone
            
            boneLayer.AddNode aBone
        )
        
        for obj in boneList do
        (
            local b = obj.boneRef

            if bpos != undefined then 
            (
            
                local mtrx = bpos[obj.id].matrix
                
                --b.transform = mtrx
                
                b.pos = mtrx.translationpart
                
            )
        )
        
        -- build the hierarchy
        for b in boneList do
        (
            if ( b.ParentBoneId > 0 and b.ParentBoneId <= boneList.count ) then 
            (
                local parentBone = boneList[b.ParentBoneId].boneRef
                b.boneRef.parent = parentBone
            )
        )

        for objX in objects do
            addNewKey objX.controller 0
        
       -- apply bone animation
        local applyBoneAnim = true
        if applyBoneAnim == true then 
        for obj in boneList do
        (
            local b = obj.boneRef
            
            b.assumeSkinPose()

            if ( obj.KGRT != undefined ) then 
            (
               -- b.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                local prevTime = 0
                
                for anim in obj.KGRT.KG do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            if ( obj.KGTR != undefined ) then
            (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = b.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in obj.KGTR.KG do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point

                        if ( prevTime == t ) then continue else prevTime = t
                        
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on b.position.controller = copy dp.position.controller
                    
                    delete dp
            )
            
            if ( obj.KGSC != undefined ) then
            (
               -- b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in obj.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )
            
        )
   
    ),
    function BuildSKIN =
    (
        local geos = mdx.geos
        local boneList = mdx.bone
        if ( geos == undefined or boneList == undefined ) then return undefined
        
        try(
            for geo in geos do
            (

                local msh = geo
                local obj = geo.meshRef

                format "Applying Skin modifier to %\n" obj.name
                
                if ( obj == undefined ) then continue
                
                local mshSkin = skin name:"Skin"
                mshSkin.bone_Limit = 4
                max modify mode
                addmodifier obj mshSkin

                modPanel.setCurrentObject mshSkin

                for i=1 to boneList.count do
                (
                    local b = boneList[i].boneRef
                    skinOps.addBone mshSkin b 0
                )

                update obj
                max views redraw

                for v=1 to geo.VRTX.count do
                (
                    local boneIds = geo.SKIN[v].BoneIds
                    local weights = geo.SKIN[v].Weights
                    skinOps.ReplaceVertexWeights mshSkin v boneIds weights
                )
                update obj
            )
        )
        catch()
        redrawViews()

    ),
    function BuildCollisionObject cl bpos=
    (
        /*
          0: cube
          1: plane
          2: sphere
          3: cylinder
        */
        
        /*
            cl.BoundingType = readLong stream
            
            cl.pos = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( cl.BoundingType != 2 ) then cl.posAlt = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( cl.BoundingType == 2 or cl.BoundingType == 3 ) then cl.radius = readFloat stream
        */
        local mtrx = bpos.matrix
        local obj = undefined 
        
        local x = abs ( cl.pos.x )
        local y = abs ( cl.pos.y )
        local z = abs ( cl.pos.z )
        
        
        if ( cl.posAlt != undefined ) then (
            x = abs ( cl.pos.x - cl.posAlt.x) / 2.0 * 1.5
            y = abs ( cl.pos.y - cl.posAlt.y) / 2.0 * 1.5
            z = abs ( cl.pos.z - cl.posAlt.z) / 2.0 * 1.5
        )
        
        if(cl.BoundingType == 0 ) then -- CUBE
        (
            obj = Box length:x width:y height:z
            obj.pivot = [0,0,z]
        )
        -- PLANE
        if(cl.BoundingType == 1) then obj = Plane length:x width:y 
            
        -- SPHERE
        if(cl.BoundingType == 2 ) then(
            obj = Sphere radius:cl.Radius name:cl.name pos:cl.pos
            
        )
        
        -- CYLINDER
        if(cl.BoundingType == 3 ) then 
        (
            format "Collistion object data : %\n" cl
            local height = distance [0, 0, cl.pos.z] [0, 0, cl.posAlt.z]
            obj = Cylinder height:height radius:cl.radius
        )
        

        obj.name = cl.name
        obj.transform = mtrx
        obj.boxmode = true
        obj.wirecolor = color 64 128 255
        obj.renderable = off
        obj.castShadows = off
        obj.receiveshadows = off
        obj.ApplyAtmospherics = off
        obj.inheritVisibility = off
        obj.primaryVisibility = off
        obj.secondaryVisibility = off
        
        
        
        return obj
    ),
    function BuildCLID2=
    (
        local clid = mdx.clid
        local bpos = mdx.bpos
        
        local layer = GriffonStudios_Helpers.CreateLayer "Collision Objects"
        
        format "Building Collision objects\n"
        
        for cl in clid do
        (
            local clObj = Warcraft3_Reforged.BuildCollisionObject cl bpos[cl.id]
            local mtrx = bpos[cl.id].matrix    
            
            if ( cl.KGRT != undefined ) then 
            (
                
                for anim in cl.KGRT.KG do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx clObj.rotation = q
                )
                    
            )
            
            if ( cl.KGTR != undefined ) then 
            (

                local prevTime = 0
                for anim in cl.KGTR.KG do
                (
                    local t = anim.time + 10
                    local p = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on at time t in coordsys mtrx clObj.pos = p
                )
                    
            )
                
            freeze clObj
            layer.addnode clObj
            
            
        )  
    ),
    function BuildCLID=
    (
        local clid = mdx.clid
        local bpos = mdx.bpos
        
        if (clid == undefined ) then return undefined
        format "Buidling Collision Objects\n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Collision Objects"
        for cl in clid do
        (
            local mtrx = bpos[cl.id].matrix
        
            local height = cl.height
            local radius = cl.radius / 2.0
            
            
            --format "BoundingType (%) : % \n" cl.name cl.boundingType
            
            local capsul = capsule name:cl.name length:height radius:radius boxmode:on 
            capsul.wirecolor = color 0 64 255
            capsul.renderable = off
            capsul.castShadows = off
            capsul.receiveshadows = off
            capsul.ApplyAtmospherics = off
            capsul.inheritVisibility = off
            capsul.primaryVisibility = off
            capsul.secondaryVisibility = off

            if (cl.boundingType == 0 ) then
            (
                local isDone = false
                if (cl.name == "B_KGS_Root"  ) then 
                (
                    capsul.height = height * 4.0 - ( radius * 2.0 )
                    capsul.radius = radius * 2.0
                    centerpivot capsul
                    capsul.wirecolor = color 255 64 0
                    isDone = true
                )
                if ( cl.name == "B_KGS_Head" ) then 
                (
                    centerpivot capsul
                    isDone = true
                ) 
                
                if ( isDone == false ) then
                (
                    rotate capsul (angleaxis 180 [0,1,0])
                    resetXform capsul
                    maxOps.CollapseNodeTo capsul 1 off
                )
            
            )
            if (cl.boundingType == 2 ) then
            (
                centerpivot capsul
                
            )

                
            capsul.transform = mtrx
            
            
            if ( cl.KGRT != undefined ) then 
            (
                
                for anim in cl.KGRT.KG do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx capsul.rotation = q
                )
                    
            )
            
            if ( cl.KGTR != undefined ) then 
            (

                local prevTime = 0
                for anim in cl.KGTR.KG do
                (
                    local t = anim.time + 10
                    local p = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on at time t in coordsys mtrx capsul.pos = p
                )
                    
            )
            
            freeze capsul
            layer.addnode capsul
        )
    ),
    function BuildGEOA=
    (
        local geoa = mdx.geoa
        local geos = mdx.geos
        
        if( geoa == undefined ) then return undefined 
        format "Applying Mesh Alpha Animations \n"
        for a in geoa do
        (
            local theMesh = geos[a.GeoId].meshRef
            if ( theMesh == undefined ) then continue
            local isVisibilityTrackRequired = false -- by default evertythng is 1
            
            if a.KGAO == undefined then continue
            
            for anim in a.KGAO.KG do
            (
                if ( anim.point == 0) then isVisibilityTrackRequired = true
            )
            
            if ( isVisibilityTrackRequired == true ) then
            (
                theMesh.Visibility = on
                theMesh.Visibility.controller = on_off()

                for anim in a.KGAO.KG do 
                    with animate on at time ( anim.Time + 10 )
                        if (anim.point == 1) then 
                            theMesh.Visibility = on
                        else
                            theMesh.Visibility = off
            )
            
        )
        
    ),
    function BuildEVTS=
    (
        local evts = mdx.evts
        
        format "Building Events\n"
        if (evts == undefined ) then return undefined
        local layer = GriffonStudios_Helpers.CreateLayer "Events"
        
        for evt in evts do
        (
            local pnt = WC3RefEvent()  -- point name:evt.Name
            
            pnt.Name = evt.name

            for key in evt.KEVT do
                pnt.AddKey key
            
            evt.objRef = pnt
            layer.AddNode pnt
        )
        
    ),
    function BuildPIVT=
    (
        local pivts = mdx.pivt
        local boneList = mdx.bone
        local atch = mdx.atch
        local evts = mdx.evts
        local clid = mdx.clid
        local lite = mdx.lite
        local corn = mdx.corn
        local ribb = mdx.ribb
        
        format "Building Pivots \n"
        if ( pivts == undefined ) then return undefined
        
        local layerBones = GriffonStudios_Helpers.CreateLayer "PIVT - Bones"
        local layerAttachments = GriffonStudios_Helpers.CreateLayer "PIVT - Attachments"
        local layerEvents = GriffonStudios_Helpers.CreateLayer "PIVT - Events"
        local layerCol = GriffonStudios_Helpers.CreateLayer "PIVT - Collision Objects"
        local layerCorn = GriffonStudios_Helpers.CreateLayer "PIVT - Popcorn Effects"
        local layerRibb = GriffonStudios_Helpers.CreateLayer "PIVT - Ribbon Emitters"
        
        for pivt in pivts do
        (
            local pName = "Unknown " + ((pivt.id as integer) as string )
            local p = point name:pName pos:pivt.pivotPoint size:5
            
            pivt.objRef = p
            setUserProp p "Type" "PIVOT" 
            p.wirecolor = gray
            
            if ( boneList != undefined ) then
            for b in boneList do 
                if ( b.Id == pivt.Id ) then 
                ( 
                    p.Name = "PIVOT - " + b.name
                    layerBones.AddNode p
                    -- if ( b.boneRef != undefined ) then with animate on at time 0 b.boneRef.Pos = pivt.pivotPoint
                )
                
            if ( atch != undefined ) then
            for a in atch do 
                if ( a.Id == pivt.Id ) then 
                ( 
                    p.Name = "PIVOT - " + a.name
                    layerAttachments.AddNode p
                )
                
            if ( evts != undefined ) then
            for ev in evts do 
                if ( ev.Id == pivt.Id ) then 
                ( 
                    p.Name = "PIVOT - " + ev.name
                    layerEvents.AddNode p
                    if ( ev.objRef != undefined ) then ev.objRef.Pos = pivt.pivotPoint
                )
            
            if ( clid != undefined ) then
            for c in clid do 
                if ( c.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + c.name
                    layerCol.AddNode p
                    if ( c.objRef != undefined ) then with animate on at time 0 c.objRef.Pos = pivt.pivotPoint
                )
            
            if ( lite != undefined ) then 
            for l in lite do
                if ( l.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + l.name
                    layerCol.AddNode p
                )
            
            if ( corn != undefined ) then 
            for c in corn do
                if ( c.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + c.name
                    layerCorn.AddNode p
                )
            
            if ( ribb != undefined ) then
            for r in ribb do 
                if ( r.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + r.name
                    layerRibb.AddNode p
                )
                
            if ( substring p.Name 1 7 == "Unknown" ) then format "[Warning] Object with Id = % not found \n" ( pivt.id as integer)
        )
        
        layerBones.IsHidden = true
        layerAttachments.IsHidden = true
        layerEvents.IsHidden = true
        layerCol.IsHidden = true
        layerRibb.IsHidden = true
        layerCorn.IsHidden = true
    ),
    function BuildFAFX=
    (
        local fafx = mdx.fafx
        format "Building Facial Effects\n"
        if ( fafx == undefined ) then return undefined
        local layer = GriffonStudios_Helpers.CreateLayer "Facial Effects"
 
        for f=1 to fafx.Count do
        (
            local fafxObj = WC3RefFaceFX()   
            
            fafxObj.Name = fafx[f].Name
            fafxObj.fileName = fafx[f].ExternalFileName
            
            layer.AddNode fafxObj
        )
        
        
    ),
    function BuildCAMS=
    (
        local cams = mdx.cams
        format "Building Cameras \n"
        if (cams == undefined ) then return undefined
        
        local layer = GriffonStudios_Helpers.CreateLayer "Cameras"
        for i=1 to cams.count do
        (   
            local c = cams[i]
            local targetName = c.name + ".Target." + ( i as string)
            local camName = c.name + ( i as string)
            local target = Targetobject pos:c.targetPos name:targetName wirecolor:red 
            local cam = Targetcamera fov:c.FOV farclip:c.farClip nearclip:c.nearClip pos:c.pos name:camName wirecolor:yellow target:target
            layer.AddNode target
            layer.AddNode cam
            local prevPos = c.pos
            local prevTPos = c.targetPos
            
            if( c.KCTR != undefined) then 
                for anim in c.KCTR.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                        cam.pos = prevPos + anim.Point

                )

            if( c.KTTR != undefined ) then 
                for anim in c.KTTR.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                        target.pos = prevTPos + anim.Point
                )

            if( c.KCRL != undefined ) then 
                for anim in c.KCRL.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                    (
                        target.rotation = anim.Point
                        cam.rotation = anim.point
                    )
                )

                
        )
        
        
    ),
    function BuildLITE=
    (
        local lites = mdx.lite
        local pivots = mdx.pivt
        format "Building Lights \n"
        if ( lites == undefined ) then return undefined
        
        for lite in lites do
        (
            /*
                0x0: Omni
                0x1: Directional
                0x2: Ambient
                0x3: Default
            */
            local l = undefined
            
            local layer = GriffonStudios_Helpers.CreateLayer "Lights"
            
            if ( lite.Type == 0 ) then 
                l = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd

            if ( lite.Type == 1 ) then 
                l = DirectionalLight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( lite.Type == 2 ) then
            (
                ambientcolor = lite.ambColor
                lightLevel = lite.ambIntensity
            )

            if ( lite.Type > 2 ) then 
                l = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( l != undefined ) then 
            (
                layer.addnode l
                
                if( lite.KGRT != undefined ) then 
                    for anim in lite.KGRT.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) in coordsys world
                            l.rotation = anim.Point
                    )
                
                for p in pivots do
                    if( p.Id == lite.Id ) then 
                    (
                        l.pos = p.PivotPoint
                        exit
                    )
                local prevPos = l.pos  
                if( lite.KGTR != undefined) then 
                    for anim in lite.KGTR.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) 
                            l.pos =  prevPos + anim.Point

                    )

                if( lite.KGSC != undefined ) then 
                    for anim in lite.KGSC.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) 
                            l.scale = anim.Point
                    )

            )
        )
    ),
    function BuildRIBB=
    (
        local ribb = mdx.ribb
        local boneList = mdx.bone
        local mtls = mdx.mtls
        
        if (ribb == undefined ) then return undefined
        
        format "Building ribbons\n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Ribbons"
        
        for r in ribb do
        (
            local ribbon = undefined
            try ( ribbon = WC3RefRibbon() )
            catch ( format "WC3ReforgedRibbon plugin not found\n"; exit )

            layer.addNode ribbon
            
            ribbon.name = r.name
            if ( boneList != undefined ) then 
            (
                if ( r.ParentBoneId > 0 ) then (
                    ribbon.transform = boneList[r.parentBoneId].boneRef.transform
                    ribbon.parent = boneList[r.parentBoneId].boneref
                )
            )
            ribbon.staticHeightAbove = r.staticHeightAbove
            ribbon.staticHeightBelow = r.staticHeightBelow
            ribbon.staticAlpha = r.staticAlpha
            ribbon.staticColor = r.staticColor
            ribbon.lifeSpan = r.lifeSpan
            ribbon.emissionRate = r.emissionRate
            ribbon.flipbookRows = r.flipbookRows
            ribbon.flipbookColumns = r.flipbookColumns
            ribbon.gravity = r.gravity
            if ( mtls != undefined) then ribbon.mtlsId = mtls[r.mtlsId].materialRef
            
            -- animation time !
            -- heightAbove
            if ( r.KRHA != undefined ) then
            for anim in r.KRHA.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticHeightAbove = p
            )
            -- heightBelow
            if ( r.KRHB != undefined ) then
            for anim in r.KRHB.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticHeightBelow = p
            )
            -- alpha
            if ( r.KRAL != undefined ) then
            for anim in r.KRAL.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticAlpha = p
            )
            -- color
            if ( r.KRCO != undefined ) then
            for anim in r.KRCO.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticColor = p
            )
            -- texture
            if ( r.KRTX != undefined ) then
            for anim in r.KRTX.KG do
            (
                local t = anim.time + 10
                local p = anim.point + 1
                with animate on at time t ribbon.mtlsId = mtls[p].materialRef
            )
            -- visibility
            if ( r.KRVS != undefined ) then
            (
                local isVisibilityTrackRequired = false
                for anim in r.KRVS.KG do
                (
                    if ( anim.point == 0) then isVisibilityTrackRequired = true
                )
                if ( isVisibilityTrackRequired == true ) then
                (
                    ribbon.Visibility = on
                    ribbon.Visibility.controller = on_off()

                    for anim in r.KRVS.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                ribbon.Visibility = on
                            else
                                ribbon.Visibility = off
                )
            )
            
            
        )
    
        
    ),
    function BuildPRE2=
    (
        local particleEmitters = mdx.pre2
        local boneList = mdx.bone
        local textures = mdx.texs
        format "Building Particle Emitters \n"
        if( particleEmitters == undefined ) then return undefined
        
        local layer = GriffonStudios_Helpers.CreateLayer "Emitters"
        
        for pe in particleEmitters do
        (
            local emitter = WC3RefEmitter()
            layer.addNode emitter
            emitter.name =  pe.name
            if ( boneList != undefined ) then 
            (
                if pe.ParentId > 0 then 
                (
                    emitter.transform = boneList[pe.ParentId].boneRef.transform
                    emitter.parent = boneList[pe.ParentId].boneRef
                )
            )
            if (pe.Flags != undefined ) then
            (
                emitter.DONT_INHERIT_TRANSLATION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.DONT_INHERIT_TRANSLATION
                emitter.DONT_INHERIT_SCALING = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.DONT_INHERIT_SCALING
                emitter.DONT_INHERIT_ROTATION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.DONT_INHERIT_ROTATION
                emitter.BILLBOARDED = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARDED
                emitter.BILLBOARD_LOCK_X = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_X
                emitter.BILLBOARD_LOCK_Y = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_Y
                emitter.BILLBOARD_LOCK_Z = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_Z
                emitter.GENOBJECT_MDLBONESECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLBONESECTION
                emitter.GENOBJECT_MDLLIGHTSECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLLIGHTSECTION
                emitter.GENOBJECT_MDLEVENTSECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLEVENTSECTION
                emitter.GENOBJECT_MDLATTACHMENTSECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLATTACHMENTSECTION
                emitter.GENOBJECT_MDLPARTICLEEMITTER2 = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLPARTICLEEMITTER2
                emitter.GENOBJECT_MDLHITTESTSHAPE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLHITTESTSHAPE
                emitter.GENOBJECT_MDLRIBBONEMITTER = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLRIBBONEMITTER
                emitter.PROJECT = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PROJECT
                emitter.UNSHADED = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.UNSHADED
                emitter.SORT_PRIMITIVES_FAR_Z = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.SORT_PRIMITIVES_FAR_Z
                emitter.LINE_EMITTER = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.LINE_EMITTER
                emitter.PARTICLE_UNFOGGED = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_UNFOGGED
                emitter.PARTICLE_USE_MODEL_SPACE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_USE_MODEL_SPACE
                emitter.PARTICLE_INHERIT_SCALE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_INHERIT_SCALE
                emitter.PARTICLE_INSTANT_VELOCITY_LIN = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_INSTANT_VELOCITY_LIN
                emitter.PARTICLE_0XKILL = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_0XKILL
                emitter.PARTICLE_Z_VELOCITY_ONLY = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_Z_VELOCITY_ONLY
                emitter.PARTICLE_TUMBLER = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_TUMBLER
                emitter.PARTICLE_TAIL_GROWS = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_TAIL_GROWS
                emitter.PARTICLE_EXTRUDE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_EXTRUDE
                emitter.PARTICLE_XYQUADS = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_XYQUADS
                emitter.PARTICLE_PROJECT = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_PROJECT
                emitter.PARTICLE_FOLLOW = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_FOLLOW

            )
            emitter.speed = pe.speed  
            emitter.variation = pe.variation 
            emitter.coneAngle = pe.coneAngle / 2.0 
            emitter.gravity = pe.gravity 
            emitter.lifespan = pe.lifespan 
            emitter.emissionRate = pe.emissionrate 
            emitter.length = pe.length 
            emitter.width = pe.width  
            emitter.emitterType = pe.emitterType 
            emitter.rowCount = pe.rowCount 
            emitter.colCount = pe.colCount 
            emitter.particleType = pe.particleType + 1
            emitter.tailLength = pe.tailLength 
            emitter.midTime = pe.midTime 
            emitter.startColor  = pe.startColor 
            emitter.midColor  = pe.midColor 
            emitter.endColor  = pe.endColor 
            emitter.startAlpha  = pe.startAlpha 
            emitter.midAlpha  = pe.midAlpha 
            emitter.endAlpha  = pe.endAlpha 
            emitter.startSize  = pe.startSize 
            emitter.midSize  = pe.midSize 
            emitter.endSize  = pe.endSize 
            emitter.startLifespanUVAnim  = pe.startLifespanUVAnim 
            emitter.midLifespanUVAnim  = pe.midLifespanUVAnim 
            emitter.endLifespanUVAnim  = pe.endLifespanUVAnim 
            emitter.startDecayUVAnim  = pe.startDecayUVAnim 
            emitter.midDecayUVAnim  = pe.midDecayUVAnim 
            emitter.endDecayUVAnim  = pe.endDecayUVAnim 
            emitter.startTailUVAnim  = pe.startTailUVAnim 
            emitter.midTailUVAnim  = pe.midTailUVAnim 
            emitter.endTailUVAnim  = pe.endTailUVAnim 
            emitter.startTailDecayUVAnim = pe.startTailDecayUVAnim 
            emitter.midTailDecayUVAnim  = pe.midTailDecayUVAnim 
            emitter.endTailDecayUVAnim  = pe.endTailDecayUVAnim 
            emitter.blendMode  = pe.blendMode 
            emitter.priorityPlane  = pe.priorityPlane 
            emitter.replacableTextureId  = pe.replacableTextureId  + 1
            emitter.texture = textures[pe.TextureId + 1].path  + textures[pe.TextureId + 1].fileNameOnly + ".dds"


            if( pe.KP2E != undefined) then
                for anim in pe.KP2E do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.emissionRate = anim.Point

            if( pe.KGRT != undefined) then 
                for anim in pe.KGRT.KG do
                    with animate on at time ( anim.Time + 10 )  in coordsys parent 
                        emitter.rotation = anim.Point

            local prevPos = [0,0,0]
            if(emitter.parent != undefined ) then prevPos = emitter.parent.pos
            if( pe.KGTR != undefined) then 
                for anim in c.KGTR.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.pos = prevPos + anim.Point
            
           
            if( pe.KGSC != undefined) then 
                for anim in pe.KGSC.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.scale = anim.Point
            
            if( pe.KP2V != undefined) then
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in pe.KP2V.KG do
                    if ( anim.point == 0) then isVisibilityTrackRequired = true

                if ( isVisibilityTrackRequired == true ) then
                (
                    emitter.Visibility = on
                    emitter.Visibility.controller = on_off()

                    for anim in pe.KP2V.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                emitter.Visibility = on
                            else
                                emitter.Visibility = off
                ) 
            )



        )
        
    ),
    function BuildCORN=
    (
        local corn = mdx.corn
        local boneList = mdx.bone
        
        format "Building PopCorn \n"
        if( corn == undefined ) then return undefined
        
        local layer = GriffonStudios_Helpers.CreateLayer "Popcorn"
        
        for c in corn do
        (
            local cObj = WC3RefPopCorn()
            layer.addnode cObj
            cObj.Name = c.Name
            
            local path = getFilenamePath c.FileName
            local fileNameOnly = getfilenamefile c.fileName
            
            cObj.FileName = path + fileNameOnly + ".pkb"
            
            for prop in c.Properties do
            (
                local parts = filterString prop "="
                
                if (parts[1] == "Always" and parts[2] == "On" )  then cObj.Always = true
                if (parts[1] == "Death" and parts[2] == "On" )  then cObj.Death = true
                if (parts[1] == "Dissipate" and parts[2] == "On" )  then cObj.Dissipate = true
                if (parts[1] == "Portrait" and parts[2] == "On" )  then cObj.Portrait = true
            )
    
            if ( c.ParentId > 0 ) then
                if ( boneList != undefined) then
                    if ( boneList[c.ParentId].boneRef != undefined ) then cObj.Parent = boneList[c.ParentId].boneRef

            if( c.KGRT != undefined) then 
                for anim in c.KGRT.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.rotation = anim.Point

            if( c.KGTR != undefined) then 
                for anim in c.KGTR.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.pos = anim.Point
            
            if( c.KGSC != undefined) then 
                for anim in c.KGSC.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.scale = anim.Point
            
            if( c.KPPV != undefined) then
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in c.KPPV.KG do
                    if ( anim.point == 0) then isVisibilityTrackRequired = true

                if ( isVisibilityTrackRequired == true ) then
                (
                    cObj.Visibility = on
                    cObj.Visibility.controller = on_off()

                    for anim in c.KPPV.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                cObj.Visibility = on
                            else
                                cObj.Visibility = off
                ) 
            )
                    
                
        )
        
        
    ),
    function AssignMTLS=
    (
        try
        (
            local geos = mdx.geos
            local mtls = mdx.mtls
            for item in geos do
            (
                local m = item.meshRef
                if m !=undefined then 
                    if mtls != undefined then 
                    (
                        m.material = mtls[item.MATS.ID].MaterialRef
                        showtexturemap m.material true
                    )
            )  
        )catch()
    )
)

struct Warcraft_3_Main
(
    function Import file=
    (
        fileIn "GriffonStudios_Helpers.ms"
        fileIn "GriffonStudios_Warcraft_3_Read.ms"
        
        _helper = GriffonStudios_Helpers()
        clearlistener()
        
        if ( _helper.CheckFile file == undefined ) then return undefined

        print file
        
        struct wc3_mdx ( TAGS, VERS, MODL, SEQS, GLBS, MTLS, TEXS, GEOS, BONE, HELP, ATCH, CLID, GEOA, EVTS, PIVT, CAMS, LITE, TXAN, RIBB, PRE2)
        local mdx = wc3_mdx()
        
        /* Reading */
        _wc3 = Warcraft_3_Read()
        local stream = fOpen file "rb"
        mdx.tags = _wc3.ReadTags stream streamLen
        for tag in mdx.tags do
        (
            format "Processing %\n" tag

            if( tag.Name == "VERS" ) then mdx.vers = _wc3.ReadVERS stream tag
            if( tag.Name == "MODL" ) then mdx.modl = _wc3.ReadMODL stream tag
            if( tag.Name == "SEQS" ) then mdx.seqs = _wc3.ReadSEQS stream tag
            if( tag.Name == "GLBS" ) then mdx.glbs = _wc3.ReadGLBS stream tag
            if( tag.Name == "MTLS" ) then mdx.mtls = _wc3.ReadMTLS2 stream tag                
            if( tag.Name == "TEXS" ) then mdx.texs = _wc3.ReadTEXS stream tag
            if( tag.Name == "GEOS" ) then mdx.geos = _wc3.ReadGEOS stream tag mdx.modl
            if( tag.Name == "GEOA" ) then mdx.geoa = _wc3.ReadGEOA stream tag
            if( tag.Name == "BONE" ) then mdx.bone = _wc3.ReadBONE stream tag
            if( tag.Name == "HELP" ) then mdx.help = _wc3.ReadHELP stream tag
            if( tag.Name == "ATCH" ) then mdx.atch = _wc3.ReadATCH stream tag 
            if( tag.Name == "PIVT" ) then mdx.pivt = _wc3.ReadPIVT stream tag
            if( tag.Name == "CAMS" ) then mdx.cams = _wc3.ReadCAMS stream tag
            if( tag.Name == "EVTS" ) then mdx.evts = _wc3.ReadEVTS stream tag            
            if( tag.Name == "CLID" ) then mdx.clid = _wc3.ReadCLID stream tag
            if( tag.Name == "LITE" ) then mdx.lite = _wc3.ReadLITE stream tag
            if( tag.Name == "TXAN" ) then mdx.txan = _wc3.ReadTXAN stream tag
            if( tag.Name == "RIBB" ) then mdx.ribb = _wc3.ReadRIBB stream tag
            if( tag.Name == "PRE2" ) then mdx.pre2 = _wc3.ReadPRE2 stream tag
            
        )
        gMDX = mdx
        fclose stream
        _wc3 = undefined
        
        /* Building */
        _build = Warcraft_3_Build()
        _build.BuildGEOS mdx
        _build.BuildBONE mdx
        _build.BuildPIVT mdx
        _build.BuildATCH mdx
        _build = undefined
        
        
        _helper = undefined
        gc()
        
    )
    
)

--Warcraft_3_Main.Import @"F:\Blizzard\Warcraft - Reforged\Warcraft III\assets\units\creeps\darktroll\darktroll.mdx"