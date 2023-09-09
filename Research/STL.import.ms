/*
    .SYNOPSIS
    | Import stl 
    
    .DESCRIPTION
    | Original import of stl takes waty too much time 
    
    .AUTHOR
    | Taylor Mouse
    
    .DATE
    | 25.06.2023

*/

STRUCT STL
(
    function Import=
    (
        local file = getOpenFileName \
                    caption:"stl" \
                    types:"Supported Files|*.stl|steriolith(*.stl)|*.Mesh|All Files|*.*" \
                    historyCategory:"stlPreset"
        
        gc()
        clearlistener()
        
        if ( heapSize < 1024 * 1024 * 1024 ) then
        (
            heapSize += 1024 * 1024 * 1024 
        )
        format "Available Memory % MB\n" (heapSize / 1024 / 1024 as integer )
        
        local content = openFile file

        local meshName = getfilenamefile file
        
        local binaryFormatCheck = false
        local binaryFormat = false
        local vertices = #()
        local faces = #()
        local index = 0
        
        
        
        while not eof content do
        (
            local l = readLine content
            
            if ( binaryFormatCheck == false ) then 
            (
                if ( findstring l "solid" == undefined ) then 
                (
                    binaryFormat = true
                    close content
                    free content
                    exit
                )
                    
                binaryFormatCheck = true
                format "Ascii format\n"
            )
            
            if ( findstring l "vertex" != undefined ) then 
            (
                local data = filterString l " "
                
                local vertex = [ data[2] as float, data[3] as float, data[4] as float ]
                append vertices vertex
                
            )
            
            if ( findstring l "endfacet" != undefined ) then 
            (
                local face = [index + 1, index + 2, index + 3]
                index += 3
                
                append faces face
                
            )
            
            
            
        )
        if ( binaryFormat == false ) then 
        (
            close content
            free content
        )
        
        
        -- Build the mesh
        local theMesh = mesh name:meshName vertices:vertices faces:faces
        
        -- weld the vertices
        meshop.weldVertsByThreshold theMesh theMesh.verts 0.001

        -- split the elements of this mesh
        convertToPoly theMesh
            
		local MasterObj = theMesh 
		local faceCount = MasterObj.getnumfaces()
		
		local FaceTest = ((MasterObj.getnumfaces()) != 0)
		
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
            convertToMesh NewObj
			FaceTest = ((MasterObj.getnumfaces()) != 0)
		)
		delete MasterObj	
        
        gc()
    )
)


STL.Import()