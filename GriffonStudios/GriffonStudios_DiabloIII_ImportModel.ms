/*
	Import Diablo III Reaper Of Souls App format
	by Taylor Mouse (c) 04.2014
*/

    global texturePath = ""
    global applySkin = true
    global isScene = false
    global useSC2ArtTools = true


    /************************************************************************************************
        STRUCTS
    ************************************************************************************************/
    struct AABB ( A, B )
    struct PRSTransform ( Rotation, Position, Scale )
    struct D3Bone ( ParID, ID, Name,  PRSTransform, TheBone )
    struct GeoSet ( Name, theMesh, Verts, VertexWeights, Normals, UVWs, Indices, nVerts, ofVerts, sizeVerts, ofVertexWeights, sizeWeights, nIndices, ofIndices, sizeIndices )
    struct VertexWeight ( BoneID1, Weight1, BoneID2, Weight2, BoneID3, Weight3)
    struct RefPoint ( Name, ParID, Position, Rotation, TheRefPoint )

    /************************************************************************************************
      HELPER FUNCTIONS
    ************************************************************************************************/
    function SkipBytes stream nBytesToSkip=
    (
        fseek stream nBytesToSkip #seek_cur
    )

    fn ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if(s!="\0") then str+=s
        )
        return str
    )

    fn GetTexture file textureName texturePath =
    (
        local tName = substring  textureName 3 -1 --> remove the 2 first letters and start from the 3rd until the end


        local searchPath = texturePath

        appPos = findstring texturePath "Appearance"

        if( appPos != undefined ) then
            searchPath = substring texturePath 1 (appPos - 1)

        --print searchPath

        -- check if this texture name holds normal_ or cloth_ in the name
        if ( tName.count > 7 ) then
        (
            if( ( substring tName 1 7 ) == "normal_" or ( substring tName 1 6 ) == "cloth_" ) then
            (
                --> use the name of the file as the reference to find the texture
                tName = GetFileNameFile file

                local lookingFor = searchPath + "\\Textures\\" + tName + "_diff.dds"
                print lookingFor
                files = GetFiles lookingFor
                if( files.count >= 1 ) then return files[1]

                local lookingFor = searchPath + "\\Textures\\x1_" + tName + "_diff.dds"
                print lookingFor
                files = GetFiles lookingFor
                if( files.count >= 1 ) then return files[1]

            )
        )

        -- looking for a more exact name
        local lookingFor = searchPath + "\\Textures\\" + tName + "*.dds"
        files = GetFiles lookingFor
        if( files.count >= 1 ) then return files[1]

        -- if at this point there is still no file , check if theres is a underscore present
        underscorePos = findstring (substring  textureName 3 -1) "_"

        print underscorePos

        if( underscorePos != undefined ) then
        (
            -- start with the most significant part first => last part
            tName = substring (substring  textureName 3 -1) ( underscorePos + 1) -1
            print tName

            -- first add the filename for a more precise naming
            local searchName = ( GetFileNameFile file ) + "_" + tName
            print searchName
            files = GetFiles (searchPath + "\\Textures\\*" + searchName + "*.dds")
            if( files.count >= 1 ) then return files[1]

            -- still not found ??
            files = GetFiles (searchPath + "\\Textures\\*" + tName + "*.dds")
            if( files.count >= 1 ) then return files[1]

        )

        return undefined
    )

    /***********************************************************************************************
        MAIN METHOD for Diablo III
    ***********************************************************************************************/
    function ReadAppFileVersion1 file stream =
    (
        -- Skip 36 bytes
        SkipBytes stream 30

        -- Bones
        nBones = ReadLong stream
        ofBones = ReadLong stream
        sizeBones = ReadLong stream

        -- Skip 120 bytes
        SkipBytes stream 120

        -- Subsets
        nSubset = ReadLong stream
        ofSubset = ReadLong stream
        sizeSubset = ReadLong stream

        -- Skip 36 bytes
        SkipBytes stream 36

        -- Collision Sphere
        sphereX = ReadFloat stream
        sphereY = ReadFloat stream
        sphereZ = ReadFloat stream
        sphereRad = ReadFloat stream

    -- 	sph = sphere  pos:[ReadFloat stream , ReadFloat stream , ReadFloat stream]  radius:(ReadFloat stream) name:"CollisionSphere"
    -- 	sph.xray = true
    -- 	hide sph

        -- Colission Capsules
        nCollCap = ReadLong stream
        offCollCap = ReadLong stream
        sizeCollCap = ReadLong stream

        -- Skip 12 bytes
        SkipBytes stream 12

        -- Reference Points
        nRefPoints = ReadLong stream
        offRefPoints = ReadLong stream
        sizeRefPoints = ReadLong stream

        -- Textures
    --     fseek stream 432 #seek_set

    --     id = readlong stream
    --     nbrTextures   = readlong stream
    --     offsetTexture = readlong stream
    --     sizeTexture   = readlong stream -- per texture 144 bytes, 128 as the name of the texture

    --     fseek stream ( offsetTexture + 16 ) #seek_set

    --     textures = #()
    --     for t=1 to nbrTextures do
    --     (
    --         textureName = ReadFixedString stream 128
    --         print textureName

    --         ReadBytes stream 16

    --         textureFileName = GetTexture file textureName texturePath

    --         mat = Standard()
    --         mat.name = textureName

    --         if( textureFileName != undefined ) then
    --         (
    --             mat.diffuseMap = Bitmaptexture fileName:textureFileName
    --             mat.opacityMap = Bitmaptexture fileName:textureFileName
    --             mat.opacityMap.monooutput = 1
    --         )
    --         meditMaterials[t] = mat
    --         meditMaterials[t].diffuseMapEnable = on
    --         showTextureMap meditMaterials[t] true

    --         Append textures mat
    --     )


        allBones = #()
        /* BONES */
        print "Building Bones"
        if(ofBones > 0 ) then
        (
            fSeek stream (ofBones + 16) #seek_set

            for b=1 to nBones do
            (
                local aBone = D3Bone()
                aBone.ID = b
                aBone.Name = ReadFixedString stream 64
                aBone.ParID = 0

                aBone.ParID = (ReadLong stream) + 1 --> 0 is the root

                -- Bounding Boxes
                ab = AABB()
                ab.A = [ReadFloat stream , ReadFloat stream , ReadFloat stream]
                ab.B = [ReadFloat stream , ReadFloat stream , ReadFloat stream]

                -- Bounding Spheres
                radius = ReadFloat stream
                position = [ReadFloat stream , ReadFloat stream , ReadFloat stream]

                -- PRSTransform
                boneTransforms = #()
                for t=1 to 3 do
                (
                    local tran = PRSTransform()
                    rotY = -(ReadFloat stream)
                    rotX = (ReadFloat stream)
                    rotZ = (ReadFloat stream)
                    rotW = (ReadFloat stream)
                    tran.Rotation = quat rotX rotY rotZ rotW

                    boneY = (ReadFloat stream) * -17.0
                    boneX = (ReadFloat stream) * 17.0
                    boneZ = (ReadFloat stream) * 17.0

                    tran.Position = Point3 boneX boneY boneZ

                    tran.Scale = readfloat stream

                    append boneTransforms tran
                )

                aBone.PRSTransform = boneTransforms
                append allBones aBone

                SkipBytes stream 32

            )

            /* Build the bones*/
            with redraw off
            for b=1 to nBones do
            (

                aBone = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
                aBone.Name = allBones[b].Name
                aBone.ShowLinks = true
                aBone.Width = 0.1
                aBone.Height = 0.1
                aBone.Rotation = allBones[b].PRSTransform[1].Rotation
                aBone.Position = allBones[b].PRSTransform[1].Position
                s = allBones[b].PRSTransform[1].Scale
                aBone.Scale = point3 s s s
                allBones[b].TheBone = aBone
            )
            --max views redraw

            /* Build the bone Hierarchy */
            for b=1 to nBones do
            (
                if(allBones[b].ParID != 0) then
                (
                    parentBone = allBones[ allBones[b].ParID ].TheBone
                    allBones[b].TheBone.Parent = parentBone
                )
            )
            --max views redraw

            /* Build Skin Pose for each bone */
            for b=1 to nbones do
            (
                allBones[b].TheBone.SetSkinPose()
            --	format "% % \n" allBones[b].Name allBones[b].TheBone.transform

            )

            bonesLayer = LayerManager.GetLayerFromName "Bones"
            if(bonesLayer == undefined) then
                bonesLayer = LayerManager.NewLayerFromName "Bones"

            for b=1 to nBones do
                bonesLayer.AddNode allBones[b].TheBone

            --max views redraw
        )

        /* REFERENCE POINTS */
        print "Building Ref Points"
        allRefPoints = #()
        if(nRefPoints > 0) then
        (
            fSeek stream (offRefPoints + 16) #seek_set
            -- Read the ref points
            for i=1 to nRefPoints do
            (

                rp = RefPoint()
                rp.Name = ReadFixedString stream 64
                rp.ParID = readlong stream #unsigned + 1
                ry = readfloat stream * -1
                rx = readfloat stream
                rz = readfloat stream
                rw = readfloat stream
                py = readfloat stream *-17
                px = readfloat stream *17
                pz = readfloat stream *17
                rp.Rotation = quat rx ry rz rw
                rp.Position = point3 px py pz

                append allRefPoints rp
            )

            -- Create
            hardPoints=#()
            for i=1 to nRefPoints do
            (
                local d = undefined

                if( useSC2ArtTools == false) then
                (
                    d = Dummy name:allRefPoints[i].Name Scale:[0.5,0.5,0.5] pos:allRefPoints[i].Position rot:allRefPoints[i].Rotation
                )
                else
                (
                    d = SC2AttachPt name:allRefPoints[i].Name scale:[0.5,0.5,0.5]
                    d.Rotation = allRefPoints[i].Rotation
                    d.pos = allRefPoints[i].Position
                )
                if (allRefPoints[i].ParID != 0) then d.parent = allBones[allRefPoints[i].ParID].TheBone
                append hardPoints d
            )

            hardPointLayer = LayerManager.GetLayerFromName "HardPoints"
            if(hardPointLayer == undefined) then
                hardPointLayer = LayerManager.NewLayerFromName "HardPoints"

            for i=1 to nRefPoints do
                hardPointLayer.AddNode hardPoints[i]

        )




        /* GEOSETS */
        print "Building meshes"
        fSeek stream (ofSubset + 16) #seek_set
        geosets= #()
        for	subset=1 to nSubset do
        (
            g = GeoSet()

            ReadLong stream -- ?
            g.nVerts = ReadLong stream
            g.ofVerts = ReadLong stream
            g.sizeVerts = ReadLong stream
            ReadLong stream -- ?
            g.ofVertexWeights = ReadLong stream
            g.sizeWeights = ReadLong stream
            ReadLong stream -- ?
            g.nIndices = ReadLong stream
            g.ofIndices = ReadLong stream
            g.sizeIndices = ReadLong stream

            SkipBytes stream 28

            g.name = ReadFixedString stream 128
            name2 = ReadFixedString stream 128

            SkipBytes stream 44

            append geosets g
        )

        /* GEO Data */
        for i=1 to nSubset do
        (
            verts = #()
            vertexWeights = #()
            normals = #()
            uvws = #()
            indices = #()

            /* Vertices, normals, texture coordinates */
            fSeek stream ( geosets[i].ofVerts + 16 ) #seek_set
            for v=1 to geosets[i].nVerts do
            (
                -- vertex
                vY = ReadFloat stream * -17
                vX = ReadFloat stream * 17
                vZ = ReadFloat stream * 17
    -- 			vX = ReadFloat stream
    -- 			vY = ReadFloat stream
    -- 			vZ = ReadFloat stream
                vert = [ vX, vY, vZ ]
                append verts vert

                -- normal
                nx = ReadByte stream
                ny = ReadByte stream
                nz = ReadByte stream
                SkipBytes stream 9

                rnx = (nx - 127.0)/127.0
                rny = (ny - 127.0)/127.0
                rnz = (nz - 127.0)/127.0

                normal = [rnx, rny, rnz]

                append normals normal

                -- Texture Coordinate
                texU = ReadShort stream #unsigned
                texV = ReadShort stream #unsigned
                SkipBytes stream 16

                tu = float
                tv = float
                tu = 32767.0 - texU
                tv = 32767.0 - texV
                tu /= 512.0
                tv /= 512.0
                tv +=1.0
                tu *=-1.0

                uv = [tu,  tv, 0.0]

                append uvws uv
            )

            /* Vertex Weights */
            fSeek stream ( geosets[i].ofVertexWeights + 16 ) #seek_set
            for v=1 to geosets[i].nVerts do
            (
                vw = VertexWeight()
                vw.BoneID1 = ReadLong stream
                vw.Weight1 = ReadFloat stream
                vw.BoneID2 = ReadLong stream
                vw.Weight2 = ReadFloat stream
                vw.BoneID3 = ReadLong stream
                vw.Weight3 = ReadFloat stream

                append vertexWeights vw
            )

            /* Indices */
            fSeek stream ( geosets[i].ofIndices + 16 ) #seek_set
            for f=1 to geosets[i].nIndices / 3  do
            (
                index = [ReadShort stream #unsigned +1 , ReadShort stream #unsigned + 1, ReadShort stream #unsigned + 1]

                append indices index
            )

            geosets[i].Verts = verts
            geosets[i].UVWs = uvws
            geosets[i].Normals = normals
            geosets[i].Indices = indices
            geosets[i].VertexWeights = vertexWeights
        )

        /* BUILD THE MESHES */
        --with redraw off
        for i=1 to nSubset do
        (
            -- Create the mesh
            theMesh = mesh vertices:geosets[i].Verts faces:geosets[i].Indices name:geosets[i].Name tverts:geosets[i].UVWs vnorms:geosets[i].Normals
            theMesh.WireColor = Color (random 0 128) (random 0 255) (random 0 128)
            meshOp.setMapSupport theMesh 1 true
            for t = 1 to geosets[i].Verts.count do
                meshop.setMapVert theMesh 1 t geosets[i].UVWs[t]
            update theMesh

            -- create the materials
    -- 		meditMaterials[i] = Standard()
    -- 		meditMaterials[i].name = geosets[i].Name
    -- 		meditMaterials[i].diffuseMapEnable = on
    --
    -- 		diffuseTexture =  FindDiffuseTexture file texturePath
    -- 		if(diffuseTexture!=undefined and diffuseTexture !="" ) then
    -- 		(
    -- 			meditMaterials[i].diffuseMap  = Bitmaptexture fileName:diffuseTexture
    -- 		)
    --
    -- 		showTextureMap meditMaterials[i] true
    -- 		theMesh.material = meditMaterials[i]
            update theMesh

            geosets[i].theMesh = theMesh
        )

        print "Creating the Layers"
        if(applySkin) then
        (
            unitLayer = LayerManager.GetLayerFromName "Unit"
            if(unitLayer == undefined) then
                unitLayer = LayerManager.NewLayerFromName "Unit"
        )
        else
        (
            local layerName = GetFileNameFile file
            unitLayer = LayerManager.GetLayerFromName layerName
            if(unitLayer == undefined) then
                unitLayer = LayerManager.NewLayerFromName layerName
        )

        for i=1 to nSubset do
                unitLayer.AddNode geosets[i].theMesh
        print "Applying Skin Modifier"
        if(applySkin) then
        (
            with redraw off
            for i=1 to nSubset do
            (
                msh = geosets[i].theMesh

                -- Apply skin modifier
                select msh
                max modify mode --> VERY IMPORTANT!!!
                modPanel.addModToSelection(skin())
                skinMod = msh.Modifiers["skin"]

                modPanel.setCurrentObject skinMod

                -- add all the bones
                for b=1 to nBones do
                (
                    skinOps.addBone skinMod allBones[b].TheBone 0
                )
                update msh

                -- Apply vertex weights
                select msh
                max modify mode

                bones_total_count = skinops.getnumberbones skinMod
                vertex_count = getNumverts msh

                for v = 1 to vertex_count do
                (
                    boneId1 = geosets[i].VertexWeights[v].BoneId1 + 1
                    weight1 = geosets[i].VertexWeights[v].Weight1
                    boneId2 = geosets[i].VertexWeights[v].BoneId2 + 1
                    weight2 = geosets[i].VertexWeights[v].Weight2
                    boneId3 = geosets[i].VertexWeights[v].BoneId3 + 1
                    weight3 = geosets[i].VertexWeights[v].Weight3

                    for b = 1 to bones_total_count do
                    (
                        if (b == boneId1) then
                            skinOps.ReplaceVertexWeights skinMod v boneId1 weight1
                        else if (b == boneId2) then
                            skinOps.SetVertexWeights skinMod v boneId2 weight2
                        else if (b == boneId3) then
                            skinOps.SetVertexWeights skinMod v boneId3 weight3
                    )

                    update msh
                )

                update msh

            )
        )

        redrawviews()
        fClose stream

        clearselection()
        max zoomext sel all
        print "Done"
    )

    /***********************************************************************************************
        MAIN METHOD for Diablo III - Reaper of Souls (Beta)
    ***********************************************************************************************/
    function ReadAppFileVersion2 file stream =
    (
        -- Skip 36 bytes
        SkipBytes stream 30

        -- Bones
        nBones = ReadLong stream
        ofBones = ReadLong stream
        sizeBones = ReadLong stream
        print nBones
        print ofBones
        print sizeBones

        -- Skip 120 bytes
        SkipBytes stream 120

        -- Subsets
        nSubset = ReadLong stream
        ofSubset = ReadLong stream
        sizeSubset = ReadLong stream

        -- Skip 36 bytes
        SkipBytes stream 36

        -- Collision Sphere
        sphereX = ReadFloat stream
        sphereY = ReadFloat stream
        sphereZ = ReadFloat stream
        sphereRad = ReadFloat stream

        -- Colission Capsules
        nCollCap = ReadLong stream
        offCollCap = ReadLong stream
        sizeCollCap = ReadLong stream

        -- Skip 12 bytes
        SkipBytes stream 12

        -- Reference Points
        nRefPoints = ReadLong stream
        offRefPoints = ReadLong stream
        sizeRefPoints = ReadLong stream

        -- Textures
        fseek stream 432 #seek_set

        id = readlong stream
        nbrTextures   = readlong stream
        offsetTexture = readlong stream
        sizeTexture   = readlong stream -- per texture 144 bytes, 128 as the name of the texture

        fseek stream ( offsetTexture + 16 ) #seek_set

        textures = #()
        for t=1 to nbrTextures do
        (
            textureName = ReadFixedString stream 128
            print textureName

            SkipBytes stream 16

            textureFileName = GetTexture file textureName texturePath

            mat = Standard()
            mat.name = textureName

            if( textureFileName != undefined ) then
            (
                mat.diffuseMap = Bitmaptexture fileName:textureFileName
                mat.opacityMap = Bitmaptexture fileName:textureFileName
                mat.opacityMap.monooutput = 1
            )
            meditMaterials[t] = mat
            meditMaterials[t].diffuseMapEnable = on
            showTextureMap meditMaterials[t] true

            Append textures mat
        )


        allBones = #()
        /* BONES */
        if(ofBones > 0 ) then
        (
            fSeek stream (ofBones + 16) #seek_set

            for b=1 to nBones do
            (
                unitSize = sizeBones / nBones

                local aBone = D3Bone()
                aBone.ID = b
                aBone.Name = ReadFixedString stream 64
                unitSize -= 64
                aBone.ParID = 0

                aBone.ParID = (ReadLong stream) + 1 --> 0 is the root
                unitSize -= 4
                -- Bounding Boxes
                ab = AABB()
                ab.A = [ReadFloat stream , ReadFloat stream , ReadFloat stream]
                ab.B = [ReadFloat stream , ReadFloat stream , ReadFloat stream]
                unitSize -= 24

                -- Bounding Spheres
                radius = ReadFloat stream
                position = [ReadFloat stream , ReadFloat stream , ReadFloat stream]
                unitSize -= 16

                -- PRSTransform
                boneTransforms = #()
                for t=1 to 3 do
                (
                    local tran = PRSTransform()
                    rotY = -(ReadFloat stream)
                    rotX = (ReadFloat stream)
                    rotZ = (ReadFloat stream)
                    rotW = (ReadFloat stream)
                    unitSize -= 16
                    tran.Rotation = quat rotX rotY rotZ rotW

                    boneY = (ReadFloat stream) * -17.0
                    boneX = (ReadFloat stream) * 17.0
                    boneZ = (ReadFloat stream) * 17.0
                    unitSize -= 12
                    tran.Position = Point3 boneX boneY boneZ

                    tran.Scale = readfloat stream
                    unitSize -= 4
                    append boneTransforms tran
                )

                aBone.PRSTransform = boneTransforms
                append allBones aBone

                SkipBytes stream unitSize
                --print ("Units left over: " + unitSize as string)
            )

            /* Build the bones*/
            with redraw off
            for b=1 to nBones do
            (
                aBone = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
                aBone.Name = allBones[b].Name
                aBone.ShowLinks = true
                aBone.Width = 0.1
                aBone.Height = 0.1
                aBone.Rotation = allBones[b].PRSTransform[1].Rotation
                aBone.Position = allBones[b].PRSTransform[1].Position
                s = allBones[b].PRSTransform[1].Scale
                aBone.Scale = point3 s s s
                allBones[b].TheBone = aBone
            )
            --max views redraw
            --print allBones
            /* Build the bone Hierarchy */
            for b=1 to nBones do
            (
                if(allBones[b].ParID != 0) then
                (
                    parentBone = allBones[ allBones[b].ParID ].TheBone
                    allBones[b].TheBone.Parent = parentBone
                )
            )
            --max views redraw

            /* Build Skin Pose for each bone */
            for b=1 to nbones do
            (
                allBones[b].TheBone.SetSkinPose()
            --	format "% % \n" allBones[b].Name allBones[b].TheBone.transform

            )

            bonesLayer = LayerManager.GetLayerFromName "Bones"
            if(bonesLayer == undefined) then
                bonesLayer = LayerManager.NewLayerFromName "Bones"

            for b=1 to nBones do
                bonesLayer.AddNode allBones[b].TheBone

            --max views redraw
        )

        /* REFERENCE POINTS */
        print "Ref Points"
        print nRefPoints
        allRefPoints = #()
        if(nRefPoints > 0) then
        (
            fSeek stream (offRefPoints + 16) #seek_set
            -- Read the ref points
            for i=1 to nRefPoints do
            (

                rp = RefPoint()
                rp.Name = ReadFixedString stream 64
                rp.ParID = readlong stream #unsigned + 1
                ry = readfloat stream * -1
                rx = readfloat stream
                rz = readfloat stream
                rw = readfloat stream
                py = readfloat stream *-17
                px = readfloat stream *17
                pz = readfloat stream *17
                rp.Rotation = quat rx ry rz rw
                rp.Position = point3 px py pz

                append allRefPoints rp
            )

            -- Create
            hardPoints=#()
            for i=1 to nRefPoints do
            (
                --d = Dummy name:allRefPoints[i].Name Scale:[0.5,0.5,0.5] pos:allRefPoints[i].Position rot:allRefPoints[i].Rotation

                local d = undefined

                if( useSC2ArtTools == false) then
                (
                    d = Dummy name:allRefPoints[i].Name Scale:[0.5,0.5,0.5] pos:allRefPoints[i].Position rot:allRefPoints[i].Rotation
                )
                else
                (
                    d = SC2AttachPt name:allRefPoints[i].Name scale:[0.5,0.5,0.5]
                    d.Rotation = allRefPoints[i].Rotation
                    d.pos = allRefPoints[i].Position
                )
                if (allRefPoints[i].ParID != 0) then d.parent = allBones[allRefPoints[i].ParID].TheBone
                append hardPoints d








                if (allRefPoints[i].ParID != 0) then d.parent = allBones[allRefPoints[i].ParID].TheBone
                append hardPoints d
            )

            hardPointLayer = LayerManager.GetLayerFromName "HardPoints"
            if(hardPointLayer == undefined) then
                hardPointLayer = LayerManager.NewLayerFromName "HardPoints"

            for i=1 to nRefPoints do
                hardPointLayer.AddNode hardPoints[i]

        )




        /* GEOSETS */
        fSeek stream (ofSubset + 16) #seek_set
        geosets= #()
        print "Number of subsets: "
        print nSubset



        for	subset=1 to nSubset do
        (
            g = GeoSet()
            unitSize = sizeSubset / nSubset

            type = ReadLong stream
            unitSize -=4

            g.nVerts = ReadLong stream
            g.ofVerts = ReadLong stream
            g.sizeVerts = ReadLong stream
            ReadLong stream -- ?
            ReadLong stream -- ?
            g.ofVertexWeights = ReadLong stream
            g.sizeWeights = ReadLong stream
            ReadLong stream -- ?
            ReadLong stream -- ?
            g.nIndices = ReadLong stream
            g.ofIndices = ReadLong stream
            g.sizeIndices = ReadLong stream
            unitSize -= 48

            SkipBytes stream 40
            unitSize -= 40

            g.name = ReadFixedString stream 128
            name2 = ReadFixedString stream 128
            unitSize -=256

            SkipBytes stream unitSize

            append geosets g
        )

        /* GEO Data */
        for i=1 to nSubset do
        (
            verts = #()
            vertexWeights = #()
            normals = #()
            uvws = #()
            indices = #()

            /* Vertices, normals, texture coordinates */
            fSeek stream ( geosets[i].ofVerts + 16 ) #seek_set
            for v=1 to geosets[i].nVerts do
            (
                -- vertex
                vY = ReadFloat stream * -17
                vX = ReadFloat stream * 17
                vZ = ReadFloat stream * 17
                vert = [ vX, vY, vZ ]
                append verts vert

                -- normal
                nx = ReadByte stream
                ny = ReadByte stream
                nz = ReadByte stream
                SkipBytes stream 9

                rnx = (nx - 127.0)/127.0
                rny = (ny - 127.0)/127.0
                rnz = (nz - 127.0)/127.0

                normal = [rnx, rny, rnz]

                append normals normal

                -- Texture Coordinate
                texU = ReadShort stream #unsigned
                texV = ReadShort stream #unsigned
                SkipBytes stream 16

                tu = float
                tv = float
                tu = 32767.0 - texU
                tv = 32767.0 - texV
                tu /= 512.0
                tv /= 512.0
                tv +=1.0
                tu *=-1.0

                uv = [tu,  tv, 0.0]

                append uvws uv
            )

            /* Vertex Weights */
            fSeek stream ( geosets[i].ofVertexWeights + 16 ) #seek_set
            for v=1 to geosets[i].nVerts do
            (
                vw = VertexWeight()
                vw.BoneID1 = ReadLong stream
                vw.Weight1 = ReadFloat stream
                vw.BoneID2 = ReadLong stream
                vw.Weight2 = ReadFloat stream
                vw.BoneID3 = ReadLong stream
                vw.Weight3 = ReadFloat stream

                append vertexWeights vw
            )

            /* Indices */
            fSeek stream ( geosets[i].ofIndices + 16 ) #seek_set
            for f=1 to geosets[i].nIndices / 3  do
            (
                index = [ReadShort stream #unsigned +1 , ReadShort stream #unsigned + 1, ReadShort stream #unsigned + 1]

                append indices index
            )

            geosets[i].Verts = verts
            geosets[i].UVWs = uvws
            geosets[i].Normals = normals
            geosets[i].Indices = indices
            geosets[i].VertexWeights = vertexWeights
        )

        /* BUILD THE MESHES */
        with redraw off
        for i=1 to nSubset do
        (
            -- Create the mesh
            theMesh = mesh vertices:geosets[i].Verts faces:geosets[i].Indices name:geosets[i].Name tverts:geosets[i].UVWs vnorms:geosets[i].Normals
            theMesh.WireColor = Color (random 0 128) (random 0 255) (random 0 128)
            meshOp.setMapSupport theMesh 1 true
            for t = 1 to geosets[i].Verts.count do
                meshop.setMapVert theMesh 1 t geosets[i].UVWs[t]
            update theMesh

            -- create the materials
    -- 		meditMaterials[i] = Standard()
    -- 		meditMaterials[i].name = geosets[i].Name
    -- 		meditMaterials[i].diffuseMapEnable = on
    --
    -- 		diffuseTexture =  FindDiffuseTexture file texturePath
    -- 		if(diffuseTexture!=undefined and diffuseTexture !="" ) then
    -- 		(
    -- 			meditMaterials[i].diffuseMap  = Bitmaptexture fileName:diffuseTexture
    -- 		)
    --
    -- 		showTextureMap meditMaterials[i] true
            if( textures[i] != undefined ) then theMesh.material = textures[i]
            update theMesh

            geosets[i].theMesh = theMesh
        )


        if(applySkin) then
        (
            unitLayer = LayerManager.GetLayerFromName "Unit"
            if(unitLayer == undefined) then
                unitLayer = LayerManager.NewLayerFromName "Unit"
        )
        else
        (
            unitLayer = LayerManager.GetLayerFromName "NoSkin"
            if(unitLayer == undefined) then
                unitLayer = LayerManager.NewLayerFromName "NoSkin"
        )

        for i=1 to nSubset do
                unitLayer.AddNode geosets[i].theMesh

        if(applySkin) then
        (
            with redraw off
            for i=1 to nSubset do
            (
                msh = geosets[i].theMesh

                -- Apply skin modifier
                select msh
                max modify mode --> VERY IMPORTANT!!!
                modPanel.addModToSelection(skin())
                skinMod = msh.Modifiers["skin"]

                modPanel.setCurrentObject skinMod

                -- add all the bones
                for b=1 to nBones do
                (
                    skinOps.addBone skinMod allBones[b].TheBone 0
                )
                update msh

                -- Apply vertex weights
                select msh
                max modify mode

                bones_total_count = skinops.getnumberbones skinMod
                vertex_count = getNumverts msh

                for v = 1 to vertex_count do
                (
                    boneId1 = geosets[i].VertexWeights[v].BoneId1 + 1
                    weight1 = geosets[i].VertexWeights[v].Weight1
                    boneId2 = geosets[i].VertexWeights[v].BoneId2 + 1
                    weight2 = geosets[i].VertexWeights[v].Weight2
                    boneId3 = geosets[i].VertexWeights[v].BoneId3 + 1
                    weight3 = geosets[i].VertexWeights[v].Weight3

                    for b = 1 to bones_total_count do
                    (
                        if (b == boneId1) then
                            skinOps.ReplaceVertexWeights skinMod v boneId1 weight1
                        else if (b == boneId2) then
                            skinOps.SetVertexWeights skinMod v boneId2 weight2
                        else if (b == boneId3) then
                            skinOps.SetVertexWeights skinMod v boneId3 weight3
                    )

                    update msh
                )

                update msh

            )
        )

        redrawviews()
        fClose stream

        clearselection()
        max zoomext sel all
    )

    function GriffonStudios_DiabloIII_ImportAppFile file apply_skin is_scene use_SC2ArtTools =
    (
        applySkin = apply_skin
        isScene = is_scene
        useSC2ArtTools = use_SC2ArtTools
        
        
        print ( "Processing " + file )
        texturePath = getFilenamePath file

        stream = fOpen file "rb"
        check = 0

        -- ReadBytes stream 4 -- DE AD BE AF
        magic = ReadLong stream #signed
        if( magic != -559038737) then
        (
            MessageBox("File is not the correct format!")
            return undefined
        )
        else
            print "Correct format!"

        version = ReadShort stream #unsigned
        print version

        if(version == 247) then
        (
            ReadAppFileVersion1 file stream
        )

        if(version == 260) then
        (
            ReadAppFileVersion2 file stream
        )


    )
