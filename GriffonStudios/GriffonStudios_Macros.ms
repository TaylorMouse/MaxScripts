fileIn "Diablo/GriffonStudios_DiabloIII_Dialog.ms"
fileIn "GriffonStudios_WorldOfWarcraft_Dialog.ms"
fileIn "GriffonStudios_XNA_Lara.ms"
fileIn "GriffonStudios_AnimationProperties.ms"

macroscript GriffonStudios_AnimationSelection
category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Animation Selection Tool"
    toolTip:"Animation Selection"
(
    on execute do (
        
        if ( GriffonStudios_AnimationProperties != undefined ) then destroydialog GriffonStudios_AnimationProperties
        createDialog GriffonStudios_AnimationProperties
        
	)
    
)
    
macroscript GriffonStudios_About
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"About"
    toolTip:"About Griffon Studios"
(
    function ShowMessageBox message title=
    (
        local msgbox = dotnetclass "System.Windows.Forms.MessageBox"
        local msgboxbuttons = dotnetclass "System.Windows.Forms.MessageBoxButtons"
        local msgboxicons = dotnetclass "System.Windows.Forms.MessageBoxIcon"
        
        /* possible icons:
            None
            Asterisk
            Error
            Exclamation
            Hand
            Information
            Question
            Stop
            Warning
        */
        
        msgbox.show message title msgboxbuttons.OK msgboxicons.none
    )
    
	on execute do
	(
		ShowMessageBox "\xa9 2009~2020  Griffon Studios.\nCreated by Taylor Mouse" "About Griffon Studios\xae"
	)
)

macroscript GriffonStudios_WoWSettings
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Set up nConvert"
    toolTip:"Use nConvert to convert WoW .blp files to .png"
(
	on execute do
	(
        local wowSettings = _WorldOfWarcraft_ImportTool()
        wowSettings.ShowSettings()
	)
)

macroScript GriffonStudios_ImportWmoModel
	category:"Griffon Studios"
	internalcategory:"Griffon Studios"
	buttonText:"Import WMO Model"
(
	on execute do (
		local wowUI = _WorldOfWarcraft_ImportTool()
		wowUI.ShowMain()
	)

)

macroScript GriffonStudios_ImportM2StaticModel
	category:"Griffon Studios"
	internalcategory:"Griffon Studios"
	buttonText:"Import M2 Static Models"
(
	on execute do (
                
        local m2tool = _WorldOfWarcraft_ImportTool()
        m2tool.ShowImportM2()
	)

)

macroscript GriffonStudios_ImportM3Model
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Import Model/Animation"
    toolTip:"Import Heroes of the Storm - Starcraft II  model"
(
    on execute do(
        
        createDialog GriffonStudios_M3_Rollout
    )
)

macroscript GriffonStudios_SolidBackGroundColor
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Solid Color BackGround"
    toolTip:"Set a Solid BackGround Color "
    icon:#("EditMesh", 4)
(
    on execute do 
    ( 
        actionMan.executeAction 0 "618" -- solid background
        actionMan.executeAction 0 "550" -- Shaded
    )
)


macroscript GriffonStudios_OpenMaxScriptHelp
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Open MaxScript(2020) Help"
    toolTip:"Open Max Script Help File for 3D Studio Max 2020"
(
    /* download from https://www.autodesk.com/developer-network/platform-technologies/me-sdk-docs-2019 */
    on execute do (
        
        maxScriptHelpFile = @"F:\Programs\Autodesk\MaxScriptHelpFiles\maxscript-2020-help.chm"
        iniFile = pathConfig.getCurrentProjectFolder() + "\\MySettings.properties"
        
        if ( doesFileExist iniFile == true ) then
        (
            maxScriptHelpFile = getIniSetting iniFile "3DSMAXHELP" "MaxScriptHelpFile"
        )
        else
        (
            setIniSetting iniFile "3DSMAXHELP" "MaxScriptHelpFile" ""
        )
        
        -- check if the file is there, if not prompt
        if ( doesFileExist maxScriptHelpFile == false) then
        (
            maxScriptHelpFile = getOpenFileName \
                caption:"Max Help File" \
                types:"Max Help File|*.chm|3D Studio Max Help File(*.chm)|*.chm|All Files|*.*" \
                historyCategory:"MaxHelpFile"
            
            if ( maxScriptHelpFile != undefined) then
            (
                setIniSetting iniFile "3DSMAXHELP" "MaxScriptHelpFile" maxScriptHelpFile
            )
        )
        
        shellLaunch maxScriptHelpFile ""
    )
)

macroscript GriffonStudios_ImportDiabloIIIModel
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Import Model"
    toolTip:"Import Diablo III appearance model"
(
    on execute do(
        
        createDialog GriffonStudios_DiabloIIIModel_Rollout
    )
)

macroscript GriffonStudios_ImportDiabloIIIAnimation
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Import Animation"
    toolTip:"Import Diablo III animation"
(
    on execute do(

        createDialog GriffonStudios_DiabloIIIAnimation_Rollout
    )
)

macroScript GriffonStudios_RemapAndCopyTextures
category:"Griffon Studios"
internalcategory:"Griffon Studios"
ButtonText:"Remap and copy textures"
tooltip:"Get the texture files from the different locations and put them with the max file, remap the material textures"
(
	on execute do 
    (
               
        for obj in objects do
        (
            
            
            if( obj.material != undefined ) then
            (
                
                local mat = obj.material
                
                format "Remapping %\n" mat
                
                if ( classof obj.material == SC2_Standard_Material ) then 
                (
                    CopyAndMapSC2MaterialFileName mat.Diffuse
                    CopyAndMapSC2MaterialFileName mat.Decal
                    CopyAndMapSC2MaterialFileName mat.Gloss
                    CopyAndMapSC2MaterialFileName mat.Emissive1
                    CopyAndMapSC2MaterialFileName mat.Emissive2
                    CopyAndMapSC2MaterialFileName mat.Environment
                    CopyAndMapSC2MaterialFileName mat.EnvironmentMask
                    CopyAndMapSC2MaterialFileName mat.AlphaMask
                    CopyAndMapSC2MaterialFileName mat.NormalMap
                    CopyAndMapSC2MaterialFileName mat.Heightmap
                    CopyAndMapSC2MaterialFileName mat.Lightmap
                    CopyAndMapSC2MaterialFileName mat.AmbientOcclusion
                    CopyAndMapSC2MaterialFileName mat.AlphaMask2
                    CopyAndMapSC2MaterialFileName mat.GlossExp
                )
				
                if( classof obj.material == WC3RefMaterial )  then
                (
                    local mat = obj.material

                    CopyAndMapSC2MaterialFileName mat.diffuse_map   
                    CopyAndMapSC2MaterialFileName mat.normal_map    
                    CopyAndMapSC2MaterialFileName mat.orm_map       
                    CopyAndMapSC2MaterialFileName mat.teamcolor_map 
                    CopyAndMapSC2MaterialFileName mat.emissive_map  
                    CopyAndMapSC2MaterialFileName mat.alphamask_map 
                    CopyAndMapSC2MaterialFileName mat.reflection_map
                    CopyAndMapSC2MaterialFileName mat.replacable_map

                    
                )

            )
        )
    )
)

macroScript GriffonStudios_FillMeditorWithVisible
	category:"Griffon Studios"
	internalcategory:"Griffon Studios"
	ButtonText:"Fill Meditor With Visible"
	tooltip:"Clean up material editor and fill it with materials from all visible geometry"
	icon:#("Griffon_Studios",1)
(
	on execute do 
    (
        for m=1 to 24 do
        (
            meditMaterials[m] = Standardmaterial()
        )

        
        uniqueMaterials = #()
        
        for obj in objects do
        (
           
            if( obj.material != undefined ) then 
            (
                appendifunique uniqueMaterials obj.material
            )
        )
        
        
        matIndex = 1
        for mat in uniqueMaterials do
        (

                meditmaterials[matIndex] = mat
                matIndex += 1
        )
        
    )
)

macroscript GriffonStudios_VisibilityTrackShow
    category:"Griffon Studios"
    toolTip:"Add Visibility Track and start showing from the selected frame"
    icon:#("Griffon_Studios",3)
(

    -- add  visibility ON_OFF() track to each obj in the selection
    ClearListener()

    for obj in selection do
    (
        print obj.name
        
        
        obj.Visibility = undefined 
        obj.Visibility = on
        obj.Visibility.controller = on_off()

           with animate on
                 at time -1
                     obj.Visibility = off
                 
           with animate on
                 at time sliderTime
                     obj.Visibility = on
        
        
    )
)

macroscript GriffonStudios_VisibilityTrackHide
    category:"Griffon Studios"
    toolTip:"Add Visibility Track and start hiding from the selected frame"
    icon:#("Griffon_Studios",2)
(

    -- add  visibility ON_OFF() track to each obj in the selection
    ClearListener()

    for obj in selection do
    (
        print obj.name
        
        
        obj.Visibility = undefined 
        obj.Visibility = on
        obj.Visibility.controller = on_off()

           with animate on
                 at time -1
                     obj.Visibility = on
                 
           with animate on
                 at time sliderTime
                     obj.Visibility = off        
        
    )
)

macroscript GriffonStudios_HideAllLayers
    category:"Griffon Studios"
    toolTip:"Hide All visible layers"
    icon:#("ViewportNavigationControls",8)
(
    ClearListener()
    
    for i=1 to LayerManager.Count do
    (
        l = LayerManager.getLayer i
        
        if(l == undefined) then continue
        
        if(l.IsHidden == false) then
        (
            l.IsHidden = true
        
            format "Layer '%' was hidden\n" l.name
        )
    )
    format "% layers have been hidden\n" LayerManager.Count
)

macroScript GriffonStudios_UnhideAllShortCut
	category:"Griffon Studios"
	toolTip:"Unhide all shortcut"
    icon:#("ViewportNavigationControls",6)
(
	actionMan.executeAction 0 "277"  -- Tools: Unhide All
	unhide objects
)

macroScript GriffonStudios_RemoveDoubleQuotes
    category:"Griffon Studios"
    toolTip:"Remove double quotes in animation names"
    icon: #("enss_maintoolbar",1)
(

    fn ReplaceAll str source destination =
    (
        /* Look for 'source' in as string and replace it, I use this to replace forward slashes with backslaches in a path */
        while ( findstring str source !=undefined ) do
        (
            local pos = findstring str source
            local len = source.count
            str = replace str pos len destination
        )
        return str
    )

    track = getNoteTrack rootnode 1

    noteKeys = track.keys

    for i=1 to noteKeys.count do
    (
        noteKeys[i].Value = (ReplaceAll noteKeys[i].Value "\"" "" )

    )
)

macroScript GriffonStudios_ResetMatLib
    category:"Griffon Studios"
    toolTip:"Reset Material Library"
    icon:#("Material_Modifiers",6)
(
	for m=1 to 24 do
	(
		meditMaterials[m] = Standardmaterial()
	)
)

macroScript GriffonStudios_ResetObject
    category:"Griffon Studios"
    toolTip:"Reset Selected Object to pos 0,0,0"
    icon:#("bip_curve",18)
(
	$.pos = [0,0,0]
)

macroscript GriffonStudios_RenameBones
    category:"Griffon Studios"
    tooltip:"Rename the mirrored bones from L to R"
    icon:#("Radiosity",4)
(
    strMirrored = "(mirrored)"  --> length 10
    lenMirrored = strMirrored.count

    strLeft = "_l" --> length 6
    lenLeft = strLeft.count
    strRight = "_R"  --> length 7

    for obj in selection do
    (
        --print obj.name
        lenName = obj.name.count
        pos = findstring obj.name strMirrored

        if( pos != undefined ) then
        (

            newName = substring obj.name 1 (lenName - lenMirrored )

            --print newName

            posLeft = findstring obj.name strLeft
            if( posLeft != undefined) then
            (
                newName = replace newName posLeft lenLeft strRight

                obj.name = newName
                --print newName
            )
        )

    )
)

macroScript GriffonStudios_CreateBonesForMeshes
    category:"Griffon Studios"
    toolTip:"Create bones for individual meshes: used for death animations"
    icon:#("Reactor",16)
(
    if(selection.count==0) then
    (
        messagebox "Please select at least one mesh, bone will be applied to selected objects only!"
        return undefined
    )



    for obj in selection do
    (
        obj.pivot = obj.center
    )

    for obj in selection do
    (

        b = bonesys.createbone [0,0,0] [0,0,0] [0,0,1]
        b.showlinks = true
        b.width = 0.05
        b.height = 0.05
        b.pos = obj.pos
        obj.parent = b
        b.name = "bone_" + obj.name
    )

)

macroScript GriffonStudios_CreateMistParticle
    category:"Griffon Studios"
    toolTip:"Create a Star2 Particle Emittor with mist effect"
    icon:#("Particles",5) 
(
    local p = SC2Particles()
    p.name = "Star2Particle_mist"
    p.EmitterType = 2
    p.MaxParticles = 56
    p.EmissionRate = 0.0
    p.SquirtQuantity = 10
    p.LifeTimeMin = 1.0
    p.LifeTimeMax = 2.8
    p.AutoCalculateMaxParticleCount = true
    p.LifetimeRange = true
    p.KillSphereEnable = false
    p.KillSphereRadius = 0.1
    p.localTime = false
    p.SimulateOnInit = false
    p.InitialVelocityType = 0
    p.InitialVelocityYaw = 0.0
    p.YawFunctionOverlay = 0
    p.YawFunctionAmplitude = 0.0
    p.YawFunctionFrequency = 0.0
    p.InitialVelocityPitch = 0.0
    p.PitchFunctionOverlay = 0
    p.PitchFunctionAmplitude = 0.0
    p.PitchFunctionFrequency = 0.0
    p.InitialVelocityHorzSpread = 111.0
    p.HorzSpreadFunctionOverlay = 0
    p.HorzSpreadFunctionAmplitude = 0.0
    p.HorzSpreadFunctionFrequency = 0.0
    p.InitialVelocityVertSpread = 111.0
    p.VertSpreadFunctionOverlay = 0
    p.VertSpreadFunctionAmplitude = 0.0
    p.VertSpreadFunctionFrequency = 0.0
    p.InitialVelocitySpeedMin = 121.0
    p.InitialVelocitySpeedMax = 344.0
    p.InitialVelocitySpeedRange = true
    p.InheritParentVelocityCheck = false
    p.InheritParentVelocityPercent = 0.0
    p.ParticleVelocityXYOnlyCheck = false
    p.modelName = #()
    p.useModel = false
    p.SwapYZOnLinkedModels = false
    p.RandomRotationAxisOnLinkedModels = false
    p.SpeedFunctionOverlay = 0
    p.SpeedFunctionAmplitude = 0.0
    p.SpeedFunctionFrequency = 0.0
    p.ColorMidTime = 0.5
    p.AlphaMidTime = 0.71
    p.SizeMidTime = 0.5
    p.RotationMidTime = 0.1
    p.colorMidTimeLock = true
    p.alphaMidTimeLock = false
    p.sizeMidTimeLock = true
    p.rotationMidTimeLock = true
    p.ColorMinBegin = (color 255 255 255)
    p.ColorMaxBegin = (color 255 255 255)
    p.ColorMinMid = (color 255 255 255)
    p.ColorMaxMid = (color 255 255 255)
    p.ColorMinEnd = (color 255 255 255)
    p.ColorMaxEnd = (color 255 255 255)
    p.AlphaMinBegin = 108
    p.AlphaMaxBegin = 223
    p.AlphaMinMid = 255
    p.AlphaMaxMid = 206
    p.AlphaMinEnd = 0
    p.AlphaMaxEnd = 0
    p.AlphaFunctionOverlay = 0
    p.AlphaFunctionAmplitude = 0.0
    p.AlphaFunctionFrequency = 0.0
    p.SizeMinBegin = 130.0
    p.SizeMaxBegin = 187.0
    p.SizeMinMid = 27.0
    p.SizeMaxMid = 40.0
    p.SizeMinEnd = 300.0
    p.SizeMaxEnd = 300.0
    p.SizeFunctionOverlay = 0
    p.SizeFunctionAmplitude = 0.0
    p.SizeFunctionFrequency = 0.0
    p.RotationMinBegin = -77.0
    p.RotationMaxBegin = 102.0
    p.RotationMinMid = -57.9999
    p.RotationMaxMid = 60.0
    p.RotationMinEnd = -88.0
    p.RotationMaxEnd = 88.0
    p.RotationFunctionOverlay = 0
    p.RotationFunctionAmplitude = 0.0
    p.RotationFunctionFrequency = 0.0
    p.ColorRange = false
    p.AlphaRange = false
    p.SizeRange = true
    p.RotationRange = true
    p.SmoothSizeInterpolation = 0
    p.SmoothRotationInterpolation = 0
    p.SmoothColorInterpolation = 0
    p.IndependentTimings = true
    p.MassMin = 1.0
    p.MassMax = 4.0
    p.MassRange = false
    p.MassSizeMultiplier = 0.0
    p.gravity = 0.0
    p.MultiplyByMapGravity = false
    p.Drag = 1.0
    p.GlobalWindScalar = 0.0
    p.WorldSpaceParticles = true
    p.LitParticles = false
    p.ScaleTimeByParent = false
    p.ForceCPUSimulation = false
    p.LODReduction = 0
    p.UV2RandomOffset = false
    p.LODCut = 2
    p.ParticleGroup = 1
    p.InnerLength = 5.0
    p.InnerWidth = 5.0
    p.InnerHeight = 5.0
    p.OuterLength = 15.0
    p.OuterWidth = 15.0
    p.OuterHeight = 182.4
    p.UseInnerShape = false
    p.InnerRadius = 2.0
    p.OuterRadius = 56.0
    p.FlipbookMidTime = 0.5
    p.flipbookMidTimeLock = true
    p.FlipbookBegin = 1
    p.FlipbookMid = 1
    p.FlipbookEnd = 1
    p.FlipbookRows = 1
    p.FlipbookColumns = 1
    p.FlipBookRandomStart = false
    p.ColorUseMid = false
    p.AlphaUseMid = false
    p.SizeUseMid = false
    p.RotationUseMid = false
    p.FlipbookUseMid = false
    p.ColorUseEnd = true
    p.AlphaUseEnd = true
    p.SizeUseEnd = true
    p.RotationUseEnd = true
    p.FlipbookUseEnd = true
    p.ClampedTailLength = false
    p.FixedTailLength = false
    p.EnableSorting = false
    p.SortOnZHeight = false
    p.ReverseParticleItr = false
    p.TrailPercentChance = 0.0
    p.TrailEmissionRate = 0.0
    p.ParticleInheritScaleOnSpawning = false
    p.NoiseFrequency = 0.0
    p.NoiseAmplitude = 0.0
    p.NoiseSpeed = 0.0
    p.NoiseFallOff = 0.1
    p.EnableTerrainCollision = false
    p.EnableObjectCollision = false
    p.EnableIndependentOnBounce = false
    p.ParticleInheritScaleOnSpawning = false
    p.SpawnOnBounceChance = 0.0
    p.ParticleFriction = 0.0
    p.ParticleBounceAmount = 0.0
    p.ParticleBounceSpawnEnergy = 0.0
    p.ParticleSpawnBounceMin = 0
    p.ParticleSpawnBounceMax = 0
    p.ParticleDieOnBounce = 0
    p.SplineShapeLowerBound = 0.0
    p.SplineShapeUpperBound = 1.0
    p.SpawnRibbonOnBounceChance = 0.0
    p.SpawnSplatOnBounceChance = 0.0
    p.ParticleInstanceType = 0
    p.ParticleInstanceTailLength = 1.0
    p.ParticleInstanceYaw = 0.0
    p.ParticleInstancePitch = 0.0
    p.ParticleInstanceOffset = 1.0
    p.ColorMidHoldTime = 0.0
    p.AlphaMidHoldTime = 0.0
    p.SizeMidHoldTime = 0.0
    p.RotationMidHoldTime = 0.0
    p.ScreenSpace = false
    p.ScreenSpaceMapped = false
    p.uTiling = 1.0
    p.vTiling = 1.0
    p.uoffset = 0.0
    p.voffset = 0.0
    p.uAngle = 0.0
    p.vAngle = 0.0
    p.wAngle = 0.0
    p.AlphaThreshold = 192.0
    p.RotationRelative = true
    p.OverlayOffset = 0.0

    local mat = SC2_Standard_Material ()

    mat.MatSubType = 3
    mat.BlendOp = 4
    mat.DepthTest = true
    mat.DepthWrite = false
    mat.TranslucencyDepthWrite = false
    mat.DisableSoftBlend = false
    mat.ForceDoubleLambertShading = false
    mat.AcceptSplats = false
    mat.OnlyAcceptSplats = false
    mat.DepthFog = false
    mat.twoSided = false
    mat.Unlit = true
    mat.castShadows = false
    mat.RecvShadows = false
    mat.hitTest = false
    mat.HDRSpecularMul = 1.0
    mat.HDREmissiveMul = 1.0
    mat.Diffuse = SC2_Bitmap()
    mat.Diffuse.filename = @"F:\Blizzard\StarCraft II Exported\My Starcraft 2 MOD\Shared\bloodLit.png"
    mat.Diffuse.ColorChannels = 0
    mat.AlphaMask = SC2_Bitmap()
    mat.AlphaMask.filename = @"F:\Blizzard\StarCraft II Exported\My Starcraft 2 MOD\Shared\smokeLit.png"
    mat.AlphaMask.ColorChannels = 2
    mat.VertexBasedAmbientOcclusion = false
    mat.DiffuseEnable = true
    mat.DecalEnable = false
    mat.GlossEnable = true
    mat.Emissive1Enable = true
    mat.Emissive2Enable = false
    mat.EnvironmentEnable = true
    mat.EnvironmentMaskEnable = true
    mat.AlphaMaskEnable = true
    mat.NormalEnable = true
    mat.HeightmapEnable = true
    mat.AmbientOcclusionEnable = false
    mat.Priority = 1
    mat.AlphaTestThreshold = 0

    -- meditMaterials[17] = mat

    p.material = mat

    select p
)

macroScript GriffonStudios_ImportXnaLaraFile
    category:"Griffon Studios"
    toolTip:"Import Xna Lara mesh.ascii file"
    
(
    local xna = _XNA_LARA()
    xna.Import()

)

macroScript GriffonStudios_ConvertSelectedObjectsToSC2AttachmentPoints
    category:"Griffon Studios"
    toolTip:"Convert selected objects to SC2AttachmentPoints"
    icon:#("BlizzExport", 3)
(
    local list = #()
    
    for obj in $selection do
    (
        append list obj
    )
    
    for obj in list do
    (
        if(classof(obj)  != BoneGeometry ) then
        (
            print obj.name
           -- print (classof(obj) )
        
            /*
            SC2AttachPt 
                lockXYZ:on 
                solid:on 
                xScale:10 
                displayLabel:off 
                nonScalingDisplay:off 
                colorAxis:off 
                displayParentName:off 
                displayLinkLine:off 
                mixWireColor:off 
                displayCenterPoint:off 
                nullShape:6 
                displayName:on 
                transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [4.94016,-4.67166e-006,106.875]) 
                isSelected:on
            */

            attachPt = SC2AttachPt name:obj.Name displayName:on xScale:10 solid:on 
            --attachPt.scale = obj.scale
            attachPt.rotation = obj.rotation
            attachPt.pos = obj.pos
            attachPt.parent = obj.parent
            
            
           delete obj
        
        )    
    )
)

macroScript GriffonStudios_SC2_CollapseAll
category:"Griffon Studios"
internalcategory:"Griffon Studios"
ButtonText:"Collaps SC2 Helpers"
toolTip:"Collaps SC2 Helpers"
(
	on execute do
	(
        local names = #("HitTestTight", "HitTestFuzzy", "Vol_Shield", "Vol_Target")

        for obj in objects do
        (
            for n in names do
            (
                if ( ( findString obj.name n ) != undefined ) then 
                (
                    obj.wirecolor = color 255 0 0
                    obj.boxmode = on
                    obj.renderable = off
                    freeze obj
                )
            
                if ( ( findString (tolower obj.name) "ref_" ) != undefined ) then 
                (
                    freeze obj
                )

                
            )
            
        )
        
        -- hide the names of the attachments
        startools.displaySettings.attachPtLabelState = false
        startools.displaySettings.SetDisplayattachPts()
    
        -- show them as points = 1, turtle = 7
        startools.displaySettings.attachPtDisShapeIndex = 1
        startools.displaySettings.SetDisplayattachPts()
    )
)

macroScript GriffonStudios_SC2_ExpandAll
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    ButtonText:"Expand SC2 Helpers"
    toolTip:"Expand SC2 Helpers"
(
	on execute do
	(
        local names = #("HitTestTight", "HitTestFuzzy", "Vol_Shield", "Vol_Target")

        for obj in objects do
        (
            for n in names do
            (
                if ( ( findString obj.name n ) != undefined ) then 
                (
                    obj.wirecolor = color 255 0 0
                    obj.boxmode = off
                    obj.renderable = on
                    unfreeze obj
                )
            
                if ( ( findString (tolower obj.name) "ref_" ) != undefined ) then 
                (
                    unfreeze obj
                )

                
            )
            
        )
        
        -- hide the names of the attachments
        startools.displaySettings.attachPtLabelState = true
        startools.displaySettings.SetDisplayattachPts()
    
        -- show them as points = 1, turtle = 7
        startools.displaySettings.attachPtDisShapeIndex = 7
        startools.displaySettings.SetDisplayattachPts()
    )
)

macroscript GriffonStudios_GradienMapTool
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    ButtonText:"Gradient Map Tool"
    toolTip:"Generate a gradient map from the uv texture coordinates"
    icon:#("VPort_layout", 1)
(

    function GriffonStudios_GradientTool=
    (
        rollout GriffonStudios_GradientRollout "Gradient Map Tool"
        (
            fn SaveControlSettings thisRol thisINI =
            (
                for c in thisRol.controls do
                (
                    case classof c of
                    (
                        SpinnerControl : setINISetting thisINI thisRol.name c.name (c.value as string)
                        EditTextControl : setINISetting thisINI thisRol.name c.name c.text
                        CheckboxControl : setINISetting thisINI thisRol.name c.name (c.checked as string)
                        ComboBoxControl : setINISetting thisINI thisRol.name c.name (c.selection as string)
                        ColorPickerControl : setINISetting thisINI thisRol.name c.name (c.color as string)
                    )
                )
            )

            --LOADS ALL CONTROLS FROM AN INI
            fn LoadControlSettings thisRol thisINI =
            (
                if doesFileExist thisINI do
                (
                    for c in thisRol.controls do
                    (
                        if classof c != GroupStartControl and classof c != GroupEndControl do
                        (
                            local controlValue = getINISetting thisINI thisRol.name c.name

                            if controlValue != "" and controlValue != undefined do
                            (
                                case classof c of
                                (
                                    SpinnerControl : c.value = controlValue as number
                                    EditTextControl : c.text = controlValue
                                    CheckboxControl : c.checked = controlValue as BooleanClass
                                    ComboBoxControl : c.selection = controlValue as number
                                    ColorPickerControl : c.color = execute (controlValue)
                                )
                            )
                        )
                    )
                )
            )

            group "Render Options"
            (
                spinner spnX "Width" range:[32,8192,1024] type:#integer align:#right
                spinner spnY "Height" range:[32,8192,1024] type:#integer align:#right
                spinner spnPadding "Padding" range:[0,32,4] type:#integer align:#right
                spinner spnChannel "UV Channel" range:[1,99,1] type:#integer align:#right
                colorPicker colBackground "Background" color:(color 0 0 0) align:#right
                checkbox chkHack "Use Wide Texture Hack?" checked:true align:#right
            )

            group "Gradient Colors"
            (
                colorPicker colGradient3 "Top" color:(color 255 255 255) align:#right
                colorPicker colGradient2 "Middle" color:(color 128 128 128) align:#right
                colorPicker colGradient1 "Bottom" color:(color 0 0 0) align:#right
                slider sldCol2Pos "" range:[0.0,1.0,0.5] type:#float orient:#vertical offset:[-40,-80]
            )

            group "Output"
            (
                checkbox chkDisplay "Open After Render?" checked:true align:#left
                label lblOutput "Output to..." align:#left
                editText edtOutputPath "" text:"$temp\\" readOnly:true width:148 align:#center
                button btnOutputPath "Browse..." width:65 align:#center across:2
                button btnOutputTemp "Reset" width:65 align:#center
            )

            button btnRender "Render Gradient Map" width:148 height:32

            on monsterGradientRollout open do
            (
                clearlistener()
                LoadControlSettings monsterGradientRollout "$temp/GriffonStudiosGradientRollout.properties"
            )
            
            on sldCol2Pos rightClick do
            (
                sldCol2Pos.value = 0.5
            )


            on monsterGradientRollout close do
            (
                SaveControlSettings monsterGradientRollout "$temp/GriffonStudiosGradientRollout.properties"
            )

            on btnOutputTemp pressed do
            (
                edtOutputPath.text = "$temp\\"
                chkHack.checked = true
                spnChannel.value = 1
                spnPadding.value = 4
                spnX.value = 1024
                spnY.value = 1024
                colBackground.color = (color 0 0 0)
                colGradient3.color = (color 255 255 255)
                colGradient2.color = (color 128 128 128)
                colGradient1.color = (color 0 0 0)
            )

            on btnOutputPath pressed do
            (
                outPath = getSavePath caption:"Render Files To..." initialDir:maxfilepath
                if outPath != undefined do
                (
                    edtOutputPath.text = outPath + "\\"
                )
            )

            on btnRender pressed do
            (
                proceed = true

                --COLLECT OBJECTS WITH NO UV CHANNELS ON THE TARGET CHANNEL
                noMapObjs = for obj in selection where (meshop.getNumMaps obj.mesh) - 1 < spnChannel.value collect obj.name

                --STOP THE PROCESS IF ANY INVALID CHANNELS ARE PRESENT
                if noMapObjs.count != 0 do
                (
                    proceed = false
                    str = "The specified mapping channel doesn't exist on objects:\n"

                    for o in noMapObjs do
                    (
                        str += (o + "\n")
                    )

                    messageBox str title:"No Mapping Channel"
                )

                --STOP THE PROCESS IF NOTHING IS SELECTED
                if selection.count == 0 do
                (
                    proceed = false
                )

                --CONTINUE WITH REDRAW OFF
                if proceed do with redraw off
                (
                    max create mode
                    max hold

                    clearlistener()

                    outPath = edtOutputPath.text

                    --SAVE THIS SETTING AND ENABLE IT TO ALLOW CANCELING
                    saveEscape = escapeEnable
                    escapeEnable = true

                    --SETUP THE SCENE
                    unhide objects dolayer:true
                    hide objects
                    unhide selection

                    --FIX POSSIBLE ERRORS
                    resetxform selection
                    collapsestack selection

                    selection.backfacecull = on

                    --CREATE A MATERIAL AND A GRADIENT ON IT'S DIFFUSE
                    newMaterial = StandardMaterial()
                    newMaterial.selfIllumAmount = 100

                    gradientMap = gradient()

                    newMaterial.diffuseMap = gradientMap

                    gradientMap.coords.U_angle = 90
                    gradientMap.coords.mappingType = 0
                    gradientMap.coords.mapping = 2
                    gradientMap.color1 = colGradient1.color
                    gradientMap.color2 = colGradient2.color
                    gradientMap.color3 = colGradient3.color
                    gradientMap.color2Pos = 1 - sldCol2Pos.value

                    --HACK TO FIX TEXTURES WIDE NOT RENDERING PROPERLY
                    if spnX.value > spnY.value and chkHack.checked do
                    (
                        tileAmount = spnX.value as float / spnY.value as float
                        vTile = (spnY.value as float / spnX.value as float)
                        vOffset =  vTile / 2.0

                        xFormMod = uvw_xform()
                        xFormMod.V_Tile = vTile
                        xFormMod.V_Offset = 1.0 - vTile
                        addModifier selection xFormMod
                    )

                    --APPLY MATERIAL TO SELECTION
                    selection.material = newMaterial

                    --SET UP THE RENDER
                    renderers.current = Default_Scanline_Renderer()
                    backgroundColor = colBackground.color
                    ambientColor = color 255 255 255


                    for obj in selection do
                    (
                        obj.removeAllBakeElements()

                        --DELETE THE FILE IF IT EXISTS
                        gMapName = (outPath + obj.name + "_gr.tga")
                        deleteFile gMapName

                        --CREATE THE DIFFUSE BAKE ELEMENT
                        difElement = DiffuseMap()
                        difElement.enabled = true
                        difElement.filenameUnique = false
                        difElement.fileType = gMapName
                        difElement.lightingOn = false
                        difElement.shadowsOn = false
                        difElement.filterOn = true
                        difElement.outputSzX = spnX.value
                        difElement.outputSzY = spnY.value


                        --SETUP THE OBJ FOR BAKING
                        bobj = obj.INodeBakeProperties
                        bobj.addBakeElement difElement
                        bobj.bakeEnabled = true
                        bobj.bakeChannel = spnChannel.value
                        bobj.nDilations = spnPadding.value

                        --TURN OFF PROJECTION MAPPING
                        obj.INodeBakeProjProperties.enabled = false
                    )

                    render renderType:#bakeSelected frame:#current vfb:off progressBar:true outputwidth:spnX.value outputheight:spnY.value outputSize:[spnX.value,spnY.value]

                    --COLLECT MAPS FOR DISPLAY
                    bmpList = for obj in selection collect obj.name


                    --RESTORE THE ESCAPE SETTING AND RELOAD THE FILE
                    escapeEnable = saveEscape
                    fetchmaxfile quiet:true

                    --DISPLAY ALL RENDERED MAPS
                    if chkDisplay.checked do
                    (
                        --TRY TO RELOAD THE TEXTURES FROM DISK
                        freescenebitmaps()
                        gc()

                        for obj in bmpList do
                        (
                            local bmpGradient = openbitmap (outPath + obj + "_gr.tga")
                            if bmpGradient != undefined do
                            (
                                --ROUND ABOUT WAY OF FORCING A RELOAD ON THE BMP
                                bmpTex = bitmaptexture bitmap:bmpGradient
                                bmpTex.reload()
                                display bmpGradient
                            )
                        )
                    )
                )

                forcecompleteredraw()

            )
        )

        createDialog GriffonStudios_GradientRollout 

    )

    on execute do
    (
        GriffonStudios_GradientTool()
        
    )
    
    
)

macroScript GriffonStudios_ShrinkUV2x
	category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    ButtonText:"Shrink UV"
    toolTip:"Shrink the UV Map by 50%"
    icon:#("UVWUnwrapModes", 5)
(
	obj = $

	if(obj != undefined ) then
	(
	    nVerts = getnumtverts obj

	    for i=1 to nVerts do
	    (
	        local uv = gettvert obj i
	        
	        local newUV = uv + 0.5
	        
	        settvert obj i newUV
	    )

	    update obj

	    for i=1 to nVerts do
	    (
	        local uv = gettvert obj i
	        
	        local newUV = uv / 2
	        
	        settvert obj i newUV
	    )

	    update obj
	)
)