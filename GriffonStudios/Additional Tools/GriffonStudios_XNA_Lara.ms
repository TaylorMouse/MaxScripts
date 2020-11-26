STRUCT _XNA_LARA
(
    function StripComment val=
    (
        print val
        
        pos = (findString val "#")
        
        x = val
        
        if(pos != undefined and pos > 0) then
            x = substring val 1 (pos-1)
        
        nbrChars = x.count
        
        if( x[nbrChars] == " ") then 
            x = substring x 1 ( nbrChars - 1 )
        
        return x
    ),

    function ReadInt stream=
    (
        a = StripComment( readline stream ) as integer
        return a
        
    ),
    
    function Import=
    (
        fileName = getOpenFileName \
                    caption:"mesh.ascii" \
                    types:"Xna Lara(.mesh.ascii)|*.mesh.ascii|All Files|*.*" \
                    historyCategory:"XnaPresetFolder"

        if(fileName ==undefined ) then return undefined

        filePath = getFilenamePath fileName

        file = openFile fileName
        setWaitCursor()

        struct boneStructure ( name, parentIndex, position, theBone )
        /* 
            BONES
        */
        nbrBones =  ReadInt file
        allBones = #()

        boneLayer = CreateLayer "Bones"

        for b=1 to nbrBones do
        (
            b = boneStructure()
            b.name = readline file
            b.parentIndex = (StripComment( readline file ) as integer ) + 1
            
            x = ( readValue file ) * 50
            z = ( readValue file ) * 50
            y = ( readValue file ) * - 50
            
            b.position = [ x,y,z ]
            
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
            aBone.Name = b.name
            aBone.ShowLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.position = b.position
            
            b.theBone = aBone
            append allBones b
            
            
            boneLayer.AddNode aBone
        )
        boneLayer.IsHidden = true

        -- Build the hiearchy
        for b=1 to nbrBones do
        (
            
            if( allBones[b].parentIndex != 0) then
            (
                allBones[b].theBone.parent = allBones[allBones[b].parentIndex].theBone
            )
        )

        /*
            MESHES
        */
        nbrMeshes   = ReadInt file

        for m=1 to nbrMeshes do
        (
            local meshName    = ReadLine file
            local nbrUVLayers = ReadInt file
            local nbrTextures = ReadInt file

            print meshName
            
            for t=1 to nbrTextures do
            (
                local textureName = readline file
                print textureName
                
                theTexture = filePath + textureName
                
                if (t == 1 ) then 
                (   meditMaterials[m] = Standard()
                    meditMaterials[m].name = meshName
                    meditMaterials[m].diffuseMapEnable = on
                    meditMaterials[m].diffuseMap = Bitmaptexture fileName:theTexture
                    meditMaterials[m].opacitymap = Bitmaptexture fileName:theTexture
                    meditMaterials[m].opacitymap.monooutput = 1
                    showTextureMap meditMaterials[m] true
                )
                
                local uvIndex = ReadInt file
            )
            
            Vertices = #()
            Normals = #()
            UVWs = #()
            Faces = #()
            
            for l=1 to nbrUVLayers do
            (
                
                local nbrVertices = ReadInt file

                print nbrVertices
                
               
                
                for v=1 to nbrVertices do
                (
                    x = ( readValue file ) * 50
                    z = ( readValue file ) * 50
                    y = ( readValue file ) * - 50
                                
                    append Vertices [x, y, z]
                    
                    nx =  readValue file 
                    nz =  readValue file 
                    ny =  readValue file 
                    
                    append Normals [nx, ny, nz]
                    
                    
                    ReadLine file
                    
                    u = readValue file
                    v = 1 - readValue file
                    
                    append UVWs [u, v, 0]
                    
                    ReadLine file
                    ReadLine file

                )
                
                local nbrFaces = ReadInt file
                
                print nbrFaces
                
                for f=1 to nbrFaces do
                (
                    a = ( readvalue file ) + 1
                    c = ( readvalue file ) + 1
                    b = ( readvalue file ) + 1
                    
                    append Faces [a, b, c]
                    
                )
                

                
            )

            theMesh = MESH NAME:meshName VERTICES:Vertices FACES:Faces TVERTS:UVWs NORMALS:Normals
            theMesh.WireColor = Color (random 128 255) (random 0 255) (random 0 128)
            meshOp.setMapSupport theMesh 1 true
            for t = 1 to Vertices.count do
                meshop.setMapVert theMesh 1 t UVWs[t]
                    
            theMesh.material = meditMaterials[m]
            update theMesh
            

            
        )
        close file 
        setArrowCursor()
        clearSelection()
        max zoomext sel all
    )
)