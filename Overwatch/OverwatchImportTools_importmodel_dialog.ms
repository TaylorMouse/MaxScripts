fileIn "OverwatchImportTools_importmodel.ms"

rollout OverwatchImportModelDialog "Overwatch Import Model" height:400 width:300 
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
	group "Build Properties"
	(
		checkbox chk_buildMesh "Meshes" checked:true
		checkbox chk_buildBones "Bones"  checked:true
		checkbox chk_buildHardPoints "Hardpoints"  checked:true
		checkbox chk_buildRagdoll  "Ragdoll"  enabled:false checked:false
		checkbox chk_buildColission  "Collision"  enabled:false checked:false
		checkbox chk_buildCloth  "Cloth" enabled:false checked:false
		checkbox chk_buildEmitters  "Emitters" enabled:false checked:false
		
	)
	
	group "Available LOD's"
	(
		checkbox chk_lod_255 "LOD 0" enabled:false
		checkbox chk_lod_1 "LOD 1" enabled:false
		checkbox chk_lod_2 "LOD 2" enabled:false
		checkbox chk_lod_4 "LOD 4" enabled:false
		checkbox chk_lod_8 "LOD 8" enabled:false

	)
	
	group "Select a model file"
	(
		edittext txt_selectedFile "" fieldWidth:235 align:#left
		   
		button btn_selectFile "..." align:#right offset:[0,-26]

		on btn_selectFile pressed do
		(
			DisableAndUncheck chk_lod_1
			DisableAndUncheck chk_lod_2
			DisableAndUncheck chk_lod_4
			DisableAndUncheck chk_lod_8
			DisableAndUncheck chk_lod_255
			
			local file = getOpenFileName \
				caption:"Overwatch Model File" \
				types:"Overwatch Model Supported Files|*.007;*.00C|Overwatch Model File (*.00C)|*.00C|Overwatch Skeleton Files (*.007)|*.007|All Files (*.*)|*.*" \
				historyCategory:"OverwatchRawModelImportPreset"
			
			if(file !=undefined) then 
			(
				txt_selectedFile.text = file
				selectedFile = file
				
				local availableLODs = ReadLODs selectedFile
				
				if(availableLODs != undefined ) then
				(
					for availableLOD in availableLODs do
					(
						if availableLOD == 1 then EnableAndCheck chk_lod_1
						if availableLOD == 2 then EnableAndCheck chk_lod_2
						if availableLOD == 4 then EnableAndCheck chk_lod_4
						if availableLOD == 8 then EnableAndCheck chk_lod_8
						if availableLOD == 255 then EnableAndCheck chk_lod_255
					)
				)
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
		if (selectedFile != "") then
		(
			local buildMesh = chk_buildMesh.checked
			local buildBones = chk_buildBones.checked
			local buildHardPoints = chk_buildHardPoints.checked
			local buildColission = chk_buildColission.checked
			local buildCloth = chk_buildCloth.checked
			local buildEmitters = chk_buildEmitters.checked
			
			local LODs = #()
			
			if( chk_lod_255.checked) then append LODs 255
			if( chk_lod_1.checked) then append LODs 1
			if( chk_lod_2.checked) then append LODs 2
			if( chk_lod_4.checked) then append LODs 4
			if( chk_lod_8.checked) then append LODs 8
			
			print LODs
			setWaitCursor()
			try
			(
				local startedOn = timestamp()
				
				Import_Overwatch_00C selectedFile buildMesh buildHardPoints buildBones LODs
				
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
   
)