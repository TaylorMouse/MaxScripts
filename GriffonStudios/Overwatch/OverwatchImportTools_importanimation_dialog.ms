fileIn "OverwatchImportTools_importanimation.ms"

rollout OverwatchImportAnimDialog "Overwatch Import Animation" height:150 width:300 
(


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
	
	local selectedFile = ""
	group "Animation Properties"
	(
		edittext txt_startframe "Please select a starting frame" fieldwidth:50 align:#left
	)
	
	group "Select an animation file"
	(
		edittext txt_selectedFile "" fieldWidth:235 align:#left
		   
		button btn_selectFile "..." align:#right offset:[0,-26]

		on btn_selectFile pressed do
		(
			
			local file = getOpenFileName \
				caption:"OverwatchAnimation File" \
				types:"Overwatch Animation Files(*.006)|*.006|All Files (*.*)|*.*" \
				historyCategory:"OverwatchRawAnimationImportPreset"
			
			if(file !=undefined) then 
			(
				txt_selectedFile.text = file
				selectedFile = file
			)
			else
			(
				txt_selectedFile.text = ""
				selectedFile = ""
			)        
		)
	)
	
	button btn_import "Start importing" height:50 width:250
	
	on btn_import pressed do 
	(
		local start_frame = 0
		if(txt_startframe.text == "") then 
			start_frame = 10
		else
			start_frame = ( txt_startframe.text as integer)
		
		
		if (selectedFile != "") then
		(
		   
			setWaitCursor()
			try
			(
				local startedOn = timestamp()
				
				ImportOverwatchAnimation_v18 selectedFile start_frame undefined
				
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
   
	on OverwatchImportAnimDialog open do
	(
		txt_startframe.text = "10"
	)
)