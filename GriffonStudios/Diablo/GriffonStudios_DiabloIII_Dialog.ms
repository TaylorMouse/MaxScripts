/* 
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Import Blizzards Diablo III app models and animations dialog

*/
fileIn "GriffonStudios_DiabloIII_ImportModel.ms"
fileIn "GriffonStudios_DiabloIII_ImportAnimation.ms"
fileIn "GriffonStudios_HelperScripts.ms"

rollout GriffonStudios_DiabloIIIModel_Rollout "Import Diablo III Model" height:200 width:400 
(
    local selectedFile = ""
    local applySkin = true
    local isScenery = false
    
    /* Layout */
    label lblInfo "\xa9 2018 Importer by Taylor Mouse"
    
    
    group "Options"
    (
        CheckBox cbApplySkin "Apply Skin"
		CheckBox cbIsScenery "Scenery"
        CheckBox cbUseSC2ArtTools "Use SC2 Art Tools"
    )

    group "Select Diablo III model file (.app)"
    (
        edittext txtSelectedFile "" fieldWidth:320 align:#left height:20
        button   btnSelectFile "..." align:#right offset:[0,-26]
    )

    button btnImport "Import..." width:300 height:35
    
    /* on open */
    On GriffonStudios_DiabloIIIModel_Rollout Open do
	(
		cbApplySkin.Checked = true
		cbIsScenery.Checked = false
        cbUseSC2ArtTools.enabled = STARCRAFT_II_ARTTOOLS_INSTALLED
        cbUseSC2ArtTools.checked = STARCRAFT_II_ARTTOOLS_INSTALLED
	)
    
    /* actions */
    on btnSelectFile pressed do
    (
        file = getOpenFileName \
			caption:"Diablo 3 Appearance File" \
			types:"Diablo 3 Model File(*.app)|*.app" \
			historyCategory:"Diablo3ObjectPresets"
        
		if(file!=undefined ) then 
        (
            txtSelectedFile.Text = file
            selectedFile = file 
        )
    )
    
    on btnImport pressed do
    (
        if ( selectedFile != undefined and selectedFile != "") then
        (
            if( doesFileExist selectedFile ) then
                GriffonStudios_DiabloIII_ImportAppFile selectedFile applySkin isScenery STARCRAFT_II_ARTTOOLS_INSTALLED
        )
    )
)

rollout GriffonStudios_DiabloIIIAnimation_Rollout "Import Diablo III Animation" height:220  width:400
(
    
    
    
    local selectedFile = ""
    
    /* Layout */
    label lblInfo "\xa9 2018 Importer by Taylor Mouse"
    
    group "Options"
    (
       label lblFrameStart "Start at frame :" align:#left fieldWidth:100 height:20
       edittext txtFrameNbr "" align:#left fieldWidth:100 height:20 offset:[100,-28]
    )
    
    group "Select Diablo III animation file (.ani)"
    (
        edittext txtSelectedFile "" fieldWidth:320 align:#left height:20
        button   btnSelectFile "..." align:#right offset:[0,-26]
    )

    group "Name of the animation"
    (
        edittext txtAnimName "" fieldWidth:320 align:#left height:20
        
    )
    
    button btnImport "Start Import..." width:300 height:35
    
    /* actions */
    on GriffonStudios_DiabloIIIAnimation_Rollout open do
    (
        local nextStartFrame = GetNextStartFrame()

        txtFrameNbr.Text = nextStartFrame as string 
        
    )
    
    on btnSelectFile pressed do
    (
        local file = getOpenFileName \
                        caption:"Diablo 3 Animation File" \
                        types:"Diablo 3 Animation File(*.ani)|*.ani" \
                        historyCategory:"Diablo3ObjectPresets"
        
		if(file!=undefined ) then 
        (
            txtSelectedFile.Text = file
            selectedFile = file 
        )
    )
    
    on btnImport pressed do
    (
        
        local frameStartsAt = txtFrameNbr.Text as integer
        
        if ( selectedFile != undefined and selectedFile != "") then
        (
            if( doesFileExist selectedFile ) then
            (
                GriffonStudios_DiabloIII_ImportAnimation selectedFile frameStartsAt animName
                local nextStartFrame = GetNextStartFrame()

                txtFrameNbr.Text = nextStartFrame as string 
            )
        
        )
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