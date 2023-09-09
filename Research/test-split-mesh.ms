(
   
	
	function DetachPolyElements SourceOBJ =
	(
        if ( classof sourceObj == editable_mesh ) then convertToPoly SourceOBJ
            
		MasterObj = SourceOBJ 
		faceCount = MasterObj.getnumfaces()
		
		FaceTest = ((MasterObj.getnumfaces()) != 0)
		
		for ii in 1 to faceCount while FaceTest do	
		(
			newName = (uniquename (MasterObj.name as string))
			
			MasterObj.EditablePoly.SetSelection #Face #{1}
			MasterObj.selectElement()
			TargetElement = polyop.getFaceSelection MasterObj
			polyop.detachFaces MasterObj TargetElement asNode:true name:newName
			
			NewObj = getnodebyname newName
			resetXForm NewObj 
			convertTo NewObj (Editable_Poly)
			ResetTransform NewObj 
			ResetScale NewObj 
			ResetPivot NewObj 
			centerpivot NewObj
			FaceTest = ((MasterObj.getnumfaces()) != 0)
		)
		delete MasterObj	
	)
    DetachPolyElements theMesh
)

