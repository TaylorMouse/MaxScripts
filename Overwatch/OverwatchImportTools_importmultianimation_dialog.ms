fileIn "OverwatchImportTools_importanimation.ms"

rollout OverwatchImportMultiAnimDialog "Overwatch Import Multi Animation" height:150 width:300 
(
	local animation_path = ""
    local start_frame = 10


	function EnableAndCheck chkBox=
	(
		chkBox.enabled = true
		chkBox.checked = true
	)

	function DisableAndUncheck chkBox=
	(
		chkBox.enabled = false
		chkBox.checked = false
	)
   
    function ImportAllOverwatchAnimation =
    (
        
        struct animation_item ( name, start_frame, end_frame)

        /* clear all existing animation nodes */
        ClearAllAnimationKeysForAllBones()
        
        local files = getfiles (animation_path + "\\*.006")
        local animation_list = #()
        local anim_id = 1
        
        for f in files do
        (
           
            local stream = fOpen f "rb"
            local flag = readLong stream
            local duration    = readFloat stream -- nbr seconds
            local fps         = readFloat stream -- usually 30.0
            
            fclose stream
            
            format "Importing animation file %\n" (getfilenamefile f)
            format " - Start frame % \n" start_frame
            format " - End frame % \n" (start_frame + ( duration * fps ))
                
            ImportOverwatchAnimation_v18 f start_frame anim_id

            format "\n\n"
                
            local correction = 10 - ( mod (start_frame + ( duration * fps )) 10 )
            start_frame = start_frame + ( duration * fps ) + 10 + correction--> next start frame
                
            anim_id +=1
        )
        
        
    )
    
	
	group "Animation Properties"
	(
		edittext txt_startframe "Please select a starting frame" fieldwidth:50 align:#left
	)
	
	group "Select a folder "
	(
		edittext txt_selectedFolder "" fieldWidth:235 align:#left
		button btn_selectFolder "..." align:#right offset:[0,-26]

		on btn_selectFolder pressed do
		(
			
			local iniFile = (getfilenamepath ( getMAXIniFile() )) + "overwatch.ini"
            local initDir = ""
            
            if( doesFileExist iniFile ) then
                initDir = getIniSetting iniFile "Animation" "PreviousDirectory"
                
            animation_path = getSavePath caption:"Overwatch Animations" initialDir:initDir
           
            if animation_path == undefined then return undefined
            
            setIniSetting iniFile "Animation" "PreviousDirectory" animation_path
            
            txt_selectedFolder.text = animation_path
		)
	)
	
	button btn_import "Start importing" height:50 width:250
	
	on btn_import pressed do 
	(

		if(txt_startframe.text == "") then 
			start_frame = 10
		else
			start_frame = ( txt_startframe.text as integer)
		
		
		if (txt_selectedFolder.text != "") then
		(
		    animation_path = txt_selectedFolder.text
            
			setWaitCursor()
			try
			(
				local startedOn = timestamp()
				
				ImportAllOverwatchAnimation()
				
				local endedOn = timestamp()
				
				setArrowCursor()
				messageBox ("Import successful!\nImport took " + ((endedOn-startedOn)/1000) as string + " seconds.") title:"Overwatch Model Import"
				
			)
			catch
			(
				setArrowCursor()
				messagebox ( "[Error] \n" + (getCurrentException()) )\
					 title:"Overwatch Import Error"
	
			)
			
			setArrowCursor()
		)
	)
   
	on OverwatchImportMultiAnimDialog open do
	(
		txt_startframe.text = "10"
	)
)