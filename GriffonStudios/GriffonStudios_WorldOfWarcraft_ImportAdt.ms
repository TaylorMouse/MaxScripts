/* 
    .AUTHOR
        Taylor Mouse

    .COPYRIGHT
        (c)2010-2021 Griffon Studios
    
    .DESCRIPTION
        Import World Of Warcraft - ADT Files
    
    .VERSIONING
        v 0.3 : clean up after 5 years =D 07.2019 and support for Battle for Azeroth
        v 0.2 : Added full map load support and fixed the m2 import support
        v 0.1 : Initial tryout 12.2014

*/
UTILITY GriffonStudios_ADT_Importer "WoW .adt Import "
(	
    global importMDX = true
    global importWMO = true
    global importADT = true

    global WoWRootFolder = "" 
    global WoWAlternateTextureFolder = @"E:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\"
    global nConvertExe = "" 
    global iniFile = (GetDir #userScripts) + @"\wow_wmo.ini"
    global logMessages = #()

    struct MDX ( name, uniqueId, pos, rot, scale, flag, refObj )
    struct WMO ( name, uniqueId,  pos, rot, flag, refObj )
    struct M2SubMesh ( Id, indverts, nverts, indfaces, nfaces )
    struct M2Texture ( name, len, ofset, materialRef )
    struct WOW_CHUNK ( name, size, offset )
    struct WMOMaterial ( MaterialRef, flags, shader, blendmode, texture1, r1, g1, b1, a1, flag1, texture2, r2, g2, b2, a2, flag2, texture3, r3, g3, b3, a3, flag3)


    STRUCT HelperFunctions
    (
        function CleanUpLayers=
        (
            /*
                set the (default) layer as the current one and delete all empty layers
            */

            local nLayers = LayerManager.Count
            local defaultLayer = LayerManager.GetLayer(0)
            defaultLayer.current = true

            local layers = #()
            for i= 1 to nLayers do append layers (LayerManager.GetLayer(i-1))

            for layer in layers do
            (
                layer.nodes &nodes
                
                if ( layer.name != "0" and nodes.count == 0 ) then 
                    LayerManager.deleteLayerByName layer.name 
            )  
        ),
        
        function StreamSize stream=
        (
            local currentPos = ftell stream
            
            fSeek stream 0 #seek_end
            
            local size = ftell stream
            
            fSeek stream currentPos #seek_set
            
            return size
        ),
        
        function ResetMaterialsInMaterialEditor=
        (
            for i=1 to 24 do
                meditmaterials[i] = Standard()
        ),

        function Convert_blp_to_png textureFileName=
        (
            /* 
                NOTE : nConvert must be installed to convert blp to png
                Download here : http://www.xnview.com/en/nconvert/
            */
            
            if(DoesFileExist nConvertExe == false ) then
            (
                print ("nConvert must be installed to convert blp to png ")
                print "Download here : http://www.xnview.com/en/nconvert/"
                return textureFileName
            )
            
            
            if(DoesFileExist textureFileName == false ) then
            (
                /* switch to alternate mode */
                alternateFile = replace textureFileName 1 (WoWRootFolder.count) WoWAlternateTextureFolder
                
                if(  DoesFileExist alternateFile == true ) then 
                (
                    textureFileName = alternateFile
                )
                else
                (
                    append logMessages ("BLP Does not exist: " + textureFileName )
                    --print ("[WARNING] - Texture not found - " + textureFileName )
                    return textureFileName
                )
            )
            
            if ( DoesFileExist nConvertExe ) then
            (
                /*
                    interlaced and compression level 5 seems to be the closest to the original blp
                */
                param = " -npcd 2 -org_depth -ctype rgba -corder inter -clevel 5 -out png "
                blpFile = textureFileName
                pngFile = substring blpFile 1 (blpFile.Count - 4) + ".png"
                
                -- check if the file already exists
                if ( DoesFileExist pngFile) then 
                    return pngFile
                
                --print (nConvertExe + param + "\"" + blpFile + "\"")
                
                HiddenDosCommand (nConvertExe + param + "\"" + blpFile + "\"")
                
                -- the dos command will not throw an error so check if the file has been converted
                if ( DoesFileExist pngFile ) then 
                    return pngFile
                else
                (
                    --print ("[WARNING] - Texture not found - " + blpFile)
                    
                    append logMessages blpFile
                    
                    return undefined
                )
                
            )
            else
            (
                throw 50000 "nconvert.exe not found, file is required for converting blp to png, download it here: http://www.xnview.com/en/nconvert/"
                
            )
        ),

        function ReadFixedString stream val =
        (
            local str = ""
            
            for i=1 to val do
            (
                s= bit.IntAsChar(ReadByte stream)
                
                if ( s !="\0") then str+=s
            )
            return str
            
        ),

        function ReadFourCC stream =
        (
            local str = ""
            for i=1 to 4 do
            (
                b = ReadByte stream
                if ( b == undefined) then return str
                s= bit.IntAsChar(b)
                
                if ( s !="\0") then str = s + str
            )
            return str
        ),

        function GetLayer layerName = 
        (
            layer = LayerManager.GetLayerFromName layerName
            if ( layer == undefined) then 
                layer = LayerManager.NewLayerFromName layerName
            return layer
        ),

        function CreateBoundingBox bb1 bb2 name=
        (
            bbLayer = HelperFunctions.GetLayer "BoundingBoxes"
            /*
                bb1 and bb2 must both be a Vecto3 => [x,y,z]
            */
            if ( importBoundingBox == false) then return undefined
            
            bb = mesh vertices: #([bb1.x,bb1.y,bb1.z],[bb2.x,bb1.y,bb1.z],[bb1.x,bb2.y,bb1.z],[bb2.x,bb2.y,bb1.z], [bb1.x,bb1.y,bb2.z],[bb2.x,bb1.y,bb2.z],[bb1.x,bb2.y,bb2.z],[bb2.x,bb2.y,bb2.z] ) \
                  faces: #([1,2,3],[4,3,2],[5,6,7],[8,7,6]) \
                  name: name
            bb.wirecolor = color 26 200 200
            bb.boxmode = on
            bb.renderable = off
            bbLayer.AddNode bb
            
            return bb	
        ),

        function SkipBytes stream nBytesToSkip=
        (
            fseek stream nBytesToSkip #seek_cur
        ),

        function ShortToFloat val = 
        (
            if (val == undefined) then return 0.0
            if (val > 0) then (val -= 32767) else (val += 32768)
            val /= 32767.0
            val
        ),

        function CreateMaxMaterials materials=
        (

            -- note there are only 24 slots !!
            slot = 1
            for i=1 to materials.count do
            (
                tmpMaterial = Standard()
                tmpMaterial.name = getFileNameFile materials[i].texture1
                tmpMaterial.diffuseMapEnable = on
                tmpMaterial.diffuseMap  = Bitmaptexture fileName:materials[i].texture1
                showTextureMap tmpMaterial true
                
                if(materials[i].flags == 4 ) then 
                    tmpMaterial.twoSided = true
                
                if(materials[i].flags == 192 ) then 
                    tmpMaterial.diffuseMap.alphaSource = 2
                
                if(materials[i].flag2 == 10 ) then 
                    tmpMaterial.diffuseMap.alphaSource = 2
                
                if(materials[i].flag2 == 2 ) then 
                    tmpMaterial.diffuseMap.alphaSource = 2
                
                if(materials[i].blendmode == 1) then
                (
                    tmpMaterial.opacityMap = Bitmaptexture fileName:materials[i].texture1
                    tmpMaterial.opacityMap.monooutput = 1
                )
                
                materials[i].MaterialRef = tmpMaterial

               
            )
        ),
        
        function FindAndConvertPossibleM2Textures modelFile =
        (
            local modelPath = getFileNamePath modelFile
            local blpFiles = getFiles ( modelPath + "*.blp" )
            
            local pngFiles = #()
            
            for blpFile in blpFiles do
            (
                local pngFile = HelperFunctions.Convert_blp_to_png blpFile
                append pngFiles pngFile
            )
            return pngFiles
        ),
        
        function BuildMaterial matName texture applyAlpha=
        (
            local mat = standardmaterial name:matName diffuseMapEnable:on opacityMapEnable:on
                    
            mat.diffuseMap = BitmapTexture fileName:texture
            mat.diffuseMap.alphaSource = 2
            
            if applyAlpha then 
            (
                mat.opacityMap = Bitmaptexture fileName:texture
                mat.opacityMap.monooutput = 1
            )
            mat.twoSided = true
            mat.ambient = color 0 0 0
            mat.diffuse = color 0 0 0
            
            showTextureMap mat true
            
            return mat
        ),
        
        function FindTextureByModelName possibleTextures modelName=
        (
            
            local textureFound = undefined
            
            for texture in possibleTextures do
            (
                local texureFile = getfilenamefile texture
                local foundIt = findstring texureFile modelName

                if foundIt != undefined then 
                (
                    textureFound = texture
                   --format "Texture might be %\n" texureFile
                    exit
                )
            )
            
            if ( textureFound == undefined and possibleTextures.count > 0 ) then textureFound = possibleTextures[1]
                
            return textureFound
        )
        
    )

    STRUCT GriffonStudios_WOW_Importer
    (
        function BuildADTMesh=
        (

            /* 
                BUILD THE FACES 
            */
            faces =#()
            a=0
            for y=1 to 8 do
            (
                for x=1 to 8 do
                (
                    f = a + x
                    append faces [f, f+9, f +1]
                )
                a = a+17
            )

            a=17
            for y=1 to 8 do
            (
                for x=1 to 8 do
                (
                    f = a + x
                    append faces [f, f+1, f-8]
                )
                a = a+17
            )

            a=1
            for x=1 to 8 do
            (
                append faces [a, a+17, a+9]
                a=a+17
            )

            a=9
            for x=1 to 8 do
            (
                append faces [a, a+8, a+17]
                a=a+17
            )

            a=9
            for y=1 to 8 do
            (
                for x=1 to 7 do
                (
                    f = a + x
                    append faces [f, f+9, f +1]
                )
                a = a+17
            )

            a=1
            for y=1 to 8 do
            (
                for x=1 to 7 do
                (
                    f = a + x
                    append faces [f, f+8, f +9]
                )
                a = a+17
            )

            /*
                BUILD THE POSITIONS
            */
            verts = #()

            gap = 0
            y = 0
            z=0
            for j=1 to 17 do
            (
                for i = 0 to 8 do
                (
                    x = gap + ( i * 20 )
                    if(gap == 10 and i== 8 ) then exit

                    --x=x * 3.333333333
                    --y2=y * 3.333333333
                    x = -1 * x * 0.208333125
                    y2= y * 0.208333125
                    append verts [y2,x,z]
                    
                )
                y = y-10
                if(gap==0) then 
                    gap = 10
                else 
                    gap = 0
            )
            m = mesh vertices:verts faces:faces
            
            
            return m
        ),

        function ReadADTHeights stream meshName chunks=
        (
            
            wireColor = Color (random 128 255) (random 96 192) (random 1 128)
            
            layer = HelperFunctions.GetLayer meshName
            
             
            
            for chnk in chunks do
            (
                if(chnk.name == "MCNK") then 
                (
                    fseek stream chnk.offset #seek_set
                    /* MCNK */
                    HelperFunctions.SkipBytes stream 104
                    
                    meshPosition = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
                    
                    HelperFunctions.SkipBytes stream 12
                    
                    /* MCVT */
                    mcvt = HelperFunctions.ReadFourCC stream
                    mcvtLen = ReadLong stream
                    
                    local vHeights = #()
                    for v= 1 to 145  do
                    (	
                        append vHeights (ReadFloat stream)
                    )
                
                    /* MCNR */
                    mcnr = HelperFunctions.ReadFourCC stream
                    mcnrLen = ReadLong stream
                    
                    local norms = #()
                    for n = 1 to 145 do
                    (	
                        append norms [ReadByte stream / 127.0 as float , ReadByte stream / 127.0 as float , ReadByte stream / 127.0 as float ]
                    )
                    
                    m = GriffonStudios_WOW_Importer.BuildADTMesh()
                    m.name = meshName + "_" + i as string
                    for v=1 to m.vertices.count do
                    (
                        vert = getvert m v
                        norm = getNormal m v
                        
                        vert.z = vHeights[v]
                        norm = norms[v]
                        
                        setvert m v vert
                        setNormal m v norm
                    )
                    update m
                    m.pos = meshPosition
                    m.WireColor = wirecolor
                    layer.AddNode m
                )
                
            )
            
        ),

        function BuildMMDX stream chunks=
        (
            local mdxNameList = #()
            local mdxIdList = #()
            local mdxList = #()
            local mdxLayer = HelperFunctions.GetLayer "MDX Helpers"
            
            local wmoNameList = #()
            local wmoIdList = #()
            local wmoList = #()
            local wmoLayer = HelperFunctions.GetLayer "WMO Helpers"
            
            for chnk in chunks do
            (
                if(chnk.name == "MMDX") then (	

                    fseek stream chnk.offset #seek_set
                    
                    mdxName = ""
                    for n = 1 to chnk.size do
                    (
                        b = ReadByte stream #signed
                        char = bit.IntAsChar(b)
                        
                        if(b != 0 ) then 
                        (
                            mdxName = mdxName + char
                            --PRINT mdxName
                        )
                        else
                        (
                            --print mdxName
                            append mdxNameList mdxName
                            mdxName = ""
                        )
                    )
                )
                if(chnk.name == "MMID") then (
                    fseek stream chnk.offset #seek_set
                    nMID = chnk.size / 4
                    
                    for i=1 to nMID do
                    (
                        append mdxIdList (ReadLong stream)
                    )
                )
                if(chnk.name == "MWMO") then (
                    fseek stream chnk.offset #seek_set
                    wmoName = ""
                    for n = 1 to chnk.size do
                    (
                        b = ReadByte stream #signed
                        char = bit.IntAsChar(b)
                        
                        if(b != 0 ) then 
                        (
                            wmoName = wmoName + char
                        )
                        else
                        (
                            append wmoNameList wmoName
                            wmoName = ""
                        )
                    )
                )
                if(chnk.name == "MWID") then (	
                    fseek stream chnk.offset #seek_set
                     nWID = chnk.size / 4
            
                    for i=1 to nWID do
                    (
                        append wmoIdList (ReadLong stream)
                    )
                )
                if(chnk.name == "MDDF") then (	-- M2 models
                    fseek stream chnk.offset #seek_set
                    nMDX = mdxIdList.Count
                    for n=1 to nMDX do
                    (
                        local lmdx = MDX()
                        
                        id = (ReadLong stream) + 1
                        
                        nameId = mdxIdList[id]
                        
                        lmdx.name = mdxNameList[id]
                        
                        lmdx.uniqueid = ReadLong stream
                        Y =  ((ReadFloat stream)  - 17066 ) *-1-- pos X
                        Z = ReadFloat stream -- Height
                        X = ((ReadFloat stream) - 17066 ) *-1-- pos Z
                        
                        rotX = ReadFloat stream -- rot X
                        rotZ = 180 - (ReadFloat stream) -- rot Y
                        rotY = ReadFloat stream -- rot Z
                        euler = EulerAngles rotX rotY rotZ 
                            
                        lmdx.Pos = [x, y, z]
                        
                        lmdx.Rot = EulerToQuat euler
                        lmdx.Scale = ReadShort stream / 1024.0
                        lmdx.Flag = ReadShort stream
                            
                        importMDX = true

                        local checkMDX = getNodeByName lmdx.Name
                        
                        if(checkMDX != undefined ) then
                        (
                            if( checkMDX.rotation == lmdx.rot and checkMDX.pos == lmdx.pos ) then importMDX = false
                        )
                        
                        if(importMDX == true) then 
                        (
                            lmdx.refObj = Dummy name:lmdx.Name  
                            lmdx.refObj.rotation = lmdx.rot
                            lmdx.refObj.pos = lmdx.pos
                            lmdx.refObj.scale = [lmdx.Scale, lmdx.Scale, lmdx.Scale]
                            mdxLayer.AddNode lmdx.refObj
                            append mdxList lmdx
                        )
                        
                        
                    )
                )
                if(chnk.name == "MODF") then (	-- WMO positions 64 bytes per doodad
                    fseek stream chnk.offset #seek_set
                    nWMO = chnk.size / 64 
                    
                    for i= 1 to nWMO do
                    (
                        local wmoNameId = ReadLong stream -- doodad ref to wmo list
                        local wmoName = wmoNameList[wmoNameId + 1]
                        
                        scale = [2,2,2]
                        
                        ReadLong stream -- ddodad unique id
                        
                        Y =  ((ReadFloat stream)  - 17066 ) *-1-- pos X
                        Z = ReadFloat stream -- Height
                        X = ((ReadFloat stream) - 17066 ) *-1-- pos Z
                        pos = [X,Y,Z]
                        
                        rotX = ReadFloat stream -- rot X
                        rotZ = 180 - (ReadFloat stream) -- rot Y
                        rotY = ReadFloat stream -- rot Z
                        euler = EulerAngles rotX rotY rotZ 
                        
                        rot = EulerToQuat ( euler )
                        
                        local dummyCheck = getnodebyname wmoName /* wmo's are available multiple times when inmporting adt files */
                        importWMO = true
                        
                        if( dummyCheck != undefined) then
                        (
                            if( dummyCheck.Rotation == rot and dummyCheck.Pos == pos ) then importWMO = false
                        )
                        
                        if(importWMO) then 
                        (
                            local d = Dummy name:wmoName scale:scale
                            d.Rotation = rot
                            d.Pos = pos
                            append wmoList d
                            wmoLayer.AddNode d
                        )
                        
                        HelperFunctions.SkipBytes stream 32
                        
                    )
                    
                )
            )
            
            
            
        ),

        function ImportM2 modelFile skinFile refObj=
        (

            pos = refObj.Pos
            rot = refObj.Rotation
            scaling = refObj.Scale
            
            M2TextureList = #()
            M2TextureLookup = #()
            modelStream = fOpen modelFile "rb"

            mainVersion = HelperFunctions.ReadFixedString modelStream 4
            mainSize = ReadLong modelStream
            
            local additionalOffset = 0
            
            if( mainVersion == "MD21" ) then 
            (
                ver = HelperFunctions.ReadFixedString modelStream 4
                verId = ReadLong modelStream
                additionalOffset = 8
            )

            lenName         = ReadLong modelStream
            ofsName         = ReadLong modelStream + additionalOffset
            type            = ReadLong modelStream #unsigned
            lenGlobalSeq    = ReadLong modelStream
            ofsGlobalSeq    = ReadLong modelStream + additionalOffset
            lenAnims        = ReadLong modelStream
            ofsanims        = ReadLong modelStream + additionalOffset
            lenAnimLookup   = ReadLong modelStream
            ofsanimLookup   = ReadLong modelStream + additionalOffset
            lenBones        = ReadLong modelStream
            ofsBones        = ReadLong modelStream + additionalOffset
            lenKeyBones     = ReadLong modelStream
            ofsKeyBones     = ReadLong modelStream + additionalOffset
            nVertices       = ReadLong modelStream
            ofsVertices     = ReadLong modelStream + additionalOffset
            nViews          = ReadLong modelStream
            lenGeoAnims     = ReadLong modelStream
            ofsGeoAnims     = ReadLong modelStream + additionalOffset
            nTextures       = ReadLong modelStream
            ofsTextures     = ReadLong modelStream + additionalOffset
            lenTransforms   = ReadLong modelStream
            ofsTransforms   = ReadLong modelStream + additionalOffset
            lenTexAnims     = ReadLong modelStream
            ofsTexAnims     = ReadLong modelStream + additionalOffset
            lenTexReplace   = ReadLong modelStream
            ofsTexReplace   = ReadLong modelStream + additionalOffset
            lenRenderFlags  = ReadLong modelStream
            ofsRenderFlags  = ReadLong modelStream + additionalOffset
            lenBoneLookup   = ReadLong modelStream
            ofsBoneLookup   = ReadLong modelStream + additionalOffset
            nTextureLookups   = ReadLong modelStream
            ofsTextureLookups = ReadLong modelStream + additionalOffset
            nTextureUnitLookup = ReadLong modelStream
            ofsTextureUnitLookup = ReadLong modelStream + additionalOffset
            lenTransformLookup = ReadLong modelStream
            ofsTransformLookup = ReadLong modelStream + additionalOffset
            lenTexAnimLookup = ReadLong modelStream
            ofsTexAnimLookup = ReadLong modelStream + additionalOffset
            lenCollisionSphere = ReadLong modelStream
            ofsCollisionSphere = ReadLong modelStream + additionalOffset
            lenBoundSphere = ReadLong modelStream
            ofsBoundSphere = ReadLong modelStream + additionalOffset
            lenBoundTris = ReadLong modelStream
            ofsBoundTris = ReadLong modelStream + additionalOffset
            lenBoundVerts = ReadLong modelStream
            ofsBoundVers = ReadLong modelStream + additionalOffset
            lenBoundNorms = ReadLong modelStream
            ofsBoundNorms = ReadLong modelStream + additionalOffset
            lenAttachments  = ReadLong modelStream
            ofsAttachments = ReadLong modelStream + additionalOffset
            lenAttachmentLookups = ReadLong modelStream
            ofsAttachmentLookups = ReadLong modelStream + additionalOffset
            lenEvents = ReadLong modelStream
            ofsEvents = ReadLong modelStream + additionalOffset
            lenLights = ReadLong modelStream
            ofsLights = ReadLong modelStream + additionalOffset
            lenCamera = ReadLong modelStream
            ofsCamera = ReadLong modelStream + additionalOffset
            lenCameraLookup = ReadLong modelStream
            ofsCameraLookup = ReadLong modelStream + additionalOffset
            lenRibbons = ReadLong modelStream
            ofsRibbons = ReadLong modelStream + additionalOffset
            lenParticles = ReadLong modelStream
            ofsParticles = ReadLong modelStream + additionalOffset

            
            -- NAME
            fSeek modelStream ofsName #seek_set
            modelName = HelperFunctions.ReadFixedString modelStream lenName
            
            -- VERTICES
            fSeek modelStream ofsVertices #seek_set

            Verts = #()
            Norms = #()
            Texts = #()
            BoneWeights = #()
            BoneIndices = #()

            for v=1 to nVertices do -- 48 bytes
            (	
                append Verts [ReadFloat modelStream, ReadFloat modelStream, ReadFloat modelStream ]
                
                append BoneWeights [ ReadByte modelStream, ReadByte modelStream, ReadByte modelStream, ReadByte modelStream ]

                append BoneIndices [ ReadByte modelStream, ReadByte modelStream, ReadByte modelStream, ReadByte modelStream ]
                
                append Norms [ReadFloat modelStream, ReadFloat modelStream, ReadFloat modelStream ]
                
                append Texts [ReadFloat modelStream, 1 - ReadFloat modelStream, 0 ]
                
                ReadFloat modelStream
                ReadFloat modelStream
                
            )

            fClose modelStream


            
            /* 
                READ THE SKIN FILE 
            */
            
            skinStream  = fOpen skinFile "rb"

            ver = HelperFunctions.ReadFixedString skinStream 4

            nIndices = ReadLong skinStream
            ofsIndices = ReadLong skinStream

            nTriangles = ReadLong skinStream
            ofsTriangles = ReadLong skinStream

            nVertInds = ReadLong skinStream
            ofsVertInds = ReadLong skinStream
            
            nSubmeshes = ReadLong skinStream
            ofsSubmeshes = ReadLong skinStream

            nTextUnits = ReadLong skinStream
            ofsTextUnits = ReadLong skinStream
            
            nSkinnedBones = ReadLong skinStream
            
            Indices = #()
            Tris = #()
            Submeshes = #()

            fseek skinStream ofsIndices #seek_set
            for i=1 to nIndices do 
            (
                append Indices (ReadShort skinStream)
            )

            fseek skinStream ofsTriangles #seek_set
            for i=1 to nTriangles do 
            (
                append Tris  (ReadShort skinStream )
            )

            fseek skinStream ofsSubmeshes #seek_set
            for i=1 to nSubmeshes do
            (
                local submesh = m2SubMesh()
                
                submesh.Id = ReadLong skinStream #unsigned
                submesh.indverts = ReadShort skinStream #unsigned
                submesh.nverts = ReadShort skinStream #unsigned
                submesh.indfaces = ReadShort skinStream #unsigned
                submesh.nfaces = ReadShort skinStream #unsigned
                
                HelperFunctions.SkipBytes skinStream ( 48 - 12 )
                append Submeshes submesh
                
                
            )

            fClose skinStream

            /*
                Find some materials
            */
            local possibleTextures = HelperFunctions.FindAndConvertPossibleM2Textures modelFile
            local possibleTexturesString = ""
            for i=1 to possibleTextures.count do
                possibleTexturesString = possibleTexturesString + possibleTextures[i] + "\n"
            
            
            /*
             BUILD THE MESH 
            */
            doodadLayer = HelperFunctions.GetLayer "M2 Models"
            for s=1 to nSubmeshes do
            (
                        
                faceList = #()
                
                for i=1 to Submeshes[s].nfaces by 3 do
                (
                    local face = [0,0,0]	
                    
                    for j=1 to 3 do
                    (
                        local k = Submeshes[s].indfaces + i + j - 1
                        face[j] = Tris[k] - Submeshes[s].indverts + 1
                    )
                    append faceList face
                )
                
                vertexList = #()
                uvList = #()
                normalList = #()
                
                for i = 1 to Submeshes[s].nVerts do
                (
                    local ind = i + Submeshes[s].indverts
                    local vertInd = Indices[ind] + 1
                    local vPos = verts[vertInd]
                    local normal = norms[vertInd]
                    local uv = texts[vertInd]            
                    
                    append vertexList vpos
                    append uvList uv
                    append normalList normal
                )
                
                local meshName = modelName + "_" + s as String
                local matName = "MAT_" + meshName
                local theMesh = mesh name:meshName vertices:vertexList faces:faceList vnorms:normalList tverts:uvList
                theMesh.WireColor = Color (random 0 255) (random 64 128) (random 128 255)
                theMesh.Parent = refObj
                meshOp.setMapSupport theMesh 1 true
                for t = 1 to theMesh.numverts  do meshop.setMapVert theMesh 1 t uvList[t]
                
                -- Apply the texture
                -- matName = "test"
                if possibleTextures.count > 0 then 
                (
                    local smartTexture = HelperFunctions.FindTextureByModelName possibleTextures modelName
                    
                    -- format "Smart Texture found:%\n" smartTexture
                    
                    local mat = HelperFunctions.BuildMaterial matName smartTexture true
                    
                    /* use this to switch textures */
                    setUserPropBuffer theMesh possibleTexturesString
                    theMesh.material = mat
                )
                
                update theMesh
                
                --theMesh.scale = scaling
                theMesh.Rotation = rot
                theMesh.Pos = pos
                doodadLayer.AddNode theMesh
                
            )
        ),

        function ImportWMOModels file refObj=
        (
            SetWaitCursor()
            
            
            local parentBaseObjName = ( getFilenameFile file) + "_parent"
            
            local baseRefObj = dummy name:parentBaseObjName pos:[0,0,0]
            
            mainWmoRefObjLayer = HelperFunctions.GetLayer "WMO Parent Objects"
            wmoM2Helpers = HelperFunctions.GetLayer "WMO M2 Helpers"
            
            mainWmoRefObjLayer.addNode baseRefObj
            
            format "%\n" file
            
            stream = fOpen file "rb"

            --> MVER VERSION - 4 bytes
            mver = HelperFunctions.ReadFourCC stream
            size  = ReadLong stream
            ver  = ReadLong stream

            --> MOHD HEADER - if it is MOGP, it is a specific part of the model 64 bytes
            mohd = HelperFunctions.ReadFourCC stream
            size = ReadLong stream

            nTextures = ReadLong stream
            nGroups   = ReadLong stream  --> nbr of files are to be read with this one
            nPortals  = ReadLong stream
            nLights   = ReadLong stream
            nM2Models = ReadLong stream
            nDooadds  = ReadLong stream
            nSets     = ReadLong stream
            colR 	  = ReadByte stream
            colG 	  = ReadByte stream
            colB 	  = ReadByte stream
            colA 	  = ReadByte stream
            wmoId	  = ReadLong stream
            boundingBoxLL = [ ReadFloat stream,  ReadFloat stream,  ReadFloat stream ]
            boundingBoxUR = [ ReadFloat stream,  ReadFloat stream,  ReadFloat stream ]
            flags 	  = ReadLong stream

            isGroupFile = true

            if(nGroups > 0) then
            (

                --> MOTX TEXTURES
                --> texture names are looked up in the MOTM chunk
                motx = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                motxPos = ftell stream
                pos = motxPos + size
                fseek stream pos #seek_set

                --> MOMT MATERIALS 64 bytes
                momt = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                nMaterials = size / 64 --> could differ from the number of textures

                for i=1 to nMaterials do
                (
                    mat = WMOMaterial()
                    mat.flags = ReadLong stream
                    mat.shader = ReadLong stream
                    mat.blendMode = ReadLong stream --> 0 : OPAQUE   1: TRANSPARENT

                    texturePos = ReadLong stream + motxPos --> position of the texture in the MOTX chunk
                    thisPos = fTell stream
                    fseek stream texturePos #seek_set
                    texture = ReadString stream

                    mat.texture1 = HelperFunctions.Convert_blp_to_png ( WoWRootFolder + texture )

                    --print (mat.texture1)

                    fseek stream thisPos #seek_set

                    mat.r1 = ReadByte stream
                    mat.g1 = ReadByte stream
                    mat.b1 = ReadByte stream
                    mat.a1 = ReadByte stream
                    mat.flag1 = ReadLong stream

                    texturePos = ReadLong stream + motxPos --> position of the texture in the MOTX chunk
                    thisPos = fTell stream
                    fseek stream texturePos #seek_set
                    mat.texture2 = ReadString stream
                    fseek stream thisPos #seek_set

                    mat.r2 = ReadByte stream
                    mat.g2 = ReadByte stream
                    mat.b2 = ReadByte stream
                    mat.a2 = ReadByte stream
                    mat.flag2 = ReadLong stream

                    texturePos = ReadLong stream + motxPos --> position of the texture in the MOTX chunk
                    thisPos = fTell stream
                    fseek stream texturePos #seek_set
                    mat.texture3 = ReadString stream
                    fseek stream thisPos #seek_set

                    mat.r3 = ReadByte stream
                    mat.g3 = ReadByte stream
                    mat.b3 = ReadByte stream
                    mat.a3 = ReadByte stream

                    HelperFunctions.SkipBytes stream 20

                    append materialList mat
                )

                HelperFunctions.CreateMaxMaterials materialList

                --> MOGN GROUP NAME
                mogn = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                mognPos = ftell stream
                groupNames = HelperFunctions.ReadFixedString stream size

                --> MOGI GROUP INFORMATION
                mogi = HelperFunctions.ReadFourCC stream
                size = ReadLong stream

                for i=1 to nGroups do
                (
                    aGroup = WMOGroup()
                    aGroup.flags = readshort stream
                    readshort stream
                    aGroup.bb1   = [ readfloat stream, readfloat stream, readfloat stream ]
                    aGroup.bb2   = [ readfloat stream, readfloat stream, readfloat stream ]

                    groupPos = ReadLong stream + mognPos --> position of the texture in the MOTX chunk
                    thisPos  = fTell stream
                    fseek stream groupPos #seek_set
                    aGroup.groupName = ReadString stream
                    fseek stream thisPos #seek_set
                    append groupList aGroup
                )
                --> MOSB SKYBOX
                mosb = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size

                --> MOPV PORTAL VERTICES
                mopv = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size

                --> MOPT PORTAL INFO
                mopt = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size

                --> MOPR PORTAL REFERENCE
                mopr = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size

                --> MOVV VISIBLE VERTICES
                movv = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size

                --> MOVB VISIBLE BLOCK
                movb = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size


                --> MOLT LIGHT INFO
                molt = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                HelperFunctions.SkipBytes stream size

                --> MODS DOODADS
                mods = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                modsPos = ftell Stream

                modsname = HelperFunctions.ReadFixedString stream 20 --> make this a layer in max with all the doodads as helpers, so we can hide it
                firstInstanceIndex = ReadLong stream
                numDoodads = ReadLong stream
                unk = ReadLong stream

                fSeek stream (modsPos + size) #seek_set

                --> MODN DOODADS NAMES
                modn = HelperFunctions.ReadFourCC stream
                size = ReadLong stream
                modnPos = ftell stream
                HelperFunctions.SkipBytes stream size --> don't read it now, read it in the next chunk

                --> MODD DOOADS INFO
                modd = HelperFunctions.ReadFourCC stream
                size = ReadLong stream

                --print ( "Size " + size as string )
                nDoodads = size / 40

                format "Number of Dooadds: %\n" nDoodads

                for d=1 to nDoodads do
                (
                    doodad = WMODoodadd()

                    ofsNamePos = ReadLong stream
                    ofsName = ofsNamePos - 33554432 + modnPos
                    if(ofsName < 0) then ofsName = ofsNamePos + modnPos
                    doodadPos = ftell stream

                    fseek stream ofsName #seek_set
                    sName = ReadString stream
                    
                    if sName == undefined then sName = "Undefined"
                    
                    doodad.FullName = sName
                    doodad.sceneName = "Unknown"

                    --format "Dooadd name: %\n" sName
                    
                    
                    if(sname != undefined) then doodad.sceneName = GetFileNameFile sName --> extract just the name of the MDX file


                    fseek stream doodadPos #seek_set

                    doodad.pos = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
                    doodad.rot =  quat (ReadFloat stream) (ReadFloat stream) (ReadFloat stream) (ReadFloat stream)
                    doodad.scale = ReadFloat stream
                    doodad.color = color (ReadByte stream) (ReadByte stream) (ReadByte stream) (ReadByte stream)

                    --print doodad.rot

                    if(importDoodads == true) then
                    (

                            local someDummy = Dummy name:doodad.FullName scale:[0.25,0.25,0.25]  pos:[0,0,0]
                            
                            someDummy.rotation = doodad.rot
                            someDummy.pos = doodad.pos
                            someDummy.scale = someDummy.scale * doodad.scale
                        
                            if( refObj != undefined ) then someDummy.transform = someDummy.transform * refObj.transform
                            someDummy.Parent = baseRefObj
                            doodad.refObj = someDummy
                            
                            wmoM2Helpers.AddNode someDummy

                    )

                    append doodadList doodad

                )

                fClose file
            )
            else
            (
                -- this only happens when you do not select a MOHD file
                nGroups = 1
                isGroupFile = false
            )

            /*************************************************************************************************/
            /* READ THE GROUP FILES */
            /************************************************************************************************/

            for gp=1 to nGroups do
            (
                --Print ( "- Group " + gp as string )

                grpName = "_" +  ( substring (( 1000 + gp - 1 ) as string) 2 3 ) + ".wmo"
                fileName = ""

                if(isGroupFile) then
                    fileName = (Substring file 1 (file.Count - 4) ) + grpName
                else
                    fileName = file

                --Print ( "- WMO File : " + fileName )

                meshBaseName = GetFilenameFile fileName

                local Indices = #()
                local Triangles = #()
                local Vertices = #()
                local Normals = #()
                local UVs = #()
                local Batches = #()

                if( doesFileExist fileName) then
                (
                    local wmo = fOpen fileName "rb"

                    /* MVER */
                    mver = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo
                    version = ReadLong wmo

                    /* MOGP */
                    mogp = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo

                    ofsGroupName = ReadLong wmo
                    ofsDescription = ReadLong wmo
                    flags = ReadLong wmo
                    bb1 = [ReadFloat wmo, ReadFloat wmo, ReadFloat wmo]
                    bb2 = [ReadFloat wmo, ReadFloat wmo, ReadFloat wmo]

                    bBox = HelperFunctions.CreateBoundingBox bb1 bb2 ("BoundingBox_" + ( getFilenameFile file ) + gp as string )
                    bBox.Parent = baseRefObj
                    if( refObj != undefined ) then bBox.Transform = bBox.Transform * refObj.transform
                    
                    ofsMOPR = ReadShort wmo
                    nMOPR = ReadShort wmo
                    batchesA = ReadShort wmo
                    batchesB = ReadShort wmo
                    batchesC = ReadLong wmo
                    fogindices = ReadLong wmo
                    liquidType = ReadLong wmo
                    wmoGrpId = ReadLong wmo
                    unk = ReadLong wmo
                    unk = ReadLong wmo

                    /* MOPY */
                    mopy = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo
                    mopyPos = ftell wmo
                    fseek wmo (mopyPos + size) #seek_set

                    /* MOVI */
                    movi = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo
                    moviPos = ftell wmo
                    nIndices = size / 2

                    for i = 1 to nIndices do
                    (
                        append Indices (readshort wmo )
                    )
                    fseek wmo (moviPos + size) #seek_set

                    --print ("- Number of Indices : " + nIndices as string)

                    /* MOVT */
                    movt = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo
                    movtPos = ftell wmo

                    nVertices = ( size / 4 ) / 3
                    for i = 1 to nVertices do
                    (
                        append Vertices [ReadFloat wmo,ReadFloat wmo,ReadFloat wmo]
                    )

                    --print ("- Number of Vertices : " + nVertices as string)

                    /* MONR */
                    monr = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo
                    monrPos = ftell wmo

                    nNormals = ( size / 4 ) / 3
                    for i = 1 to nNormals do
                    (
                        append Normals [ ReadFloat wmo, ReadFloat wmo, ReadFloat wmo ]
                    )

                    --print ("- Number of Normals : " + nNormals as string)

                    /* MOVTX */
                    movtx = HelperFunctions.ReadFourCC wmo
                    if(movtx != "") then (
                    movtxSize = ReadLong wmo
                    movtxPos = ftell wmo

                    if( movtxSize != undefined ) then
                    (
                        nTextureCoordinates = ( movtxSize / 4 ) / 2
                        for i = 1 to nNormals do
                        (
                            append UVs [ReadFloat wmo,1 - ReadFloat wmo,0]
                        )

                        --print ("- Number of Texture Coordinates : " + nTextureCoordinates as string)
                    )
                    fseek wmo (movtxPos + movtxSize) #seek_set
                )
                    /* MOBA */
                    moba = HelperFunctions.ReadFourCC wmo
                    size = ReadLong wmo
                    motvPos = ftell wmo

                    nBatches = size / 24
                    for i = 1 to nBatches do
                    (
                        local batch = WMOBatch()

                        ReadLong wmo
                        ReadLong wmo
                        ReadLong wmo

                        batch.StartIndex = ReadLong wmo
                        batch.nIndices = ReadShort wmo
                        batch.StartVertex = ReadShort wmo
                        batch.EndVertex = ReadShort wmo

                        ReadByte wmo

                        batch.TextureId = ReadByte wmo + 1

                        append Batches batch
                    )

                    --print ("- Number of Batches : " + nBatches as string)
                    fClose fileName

                    /* BUILD THE MESHES */
                    wmoLayer = HelperFunctions.GetLayer "WMO Models"
                    for btch=1 to Batches.Count do
                    (
                        local batch =  Batches[btch]
                        local m = WMOMesh()

                        batchVertices = #()
                        batchUVs = #()
                        batchNormals = #()
                        batchFaces = #()
                        try
                        (
                            for v=batch.StartVertex to batch.EndVertex  do
                            (
                                append batchVertices Vertices[v+1]
                                append batchUVs UVs[v+1]
                                append batchNormals Normals[v+1]

                            )

                            for idx = batch.StartIndex to (batch.StartIndex + batch.nIndices - 3 ) by 3  do
                            (
                                a = Indices[ idx + 1 ] + 1 - batch.StartVertex
                                b = Indices[ idx + 2 ] + 1 - batch.StartVertex
                                c = Indices[ idx + 3 ] + 1 - batch.StartVertex

                                append batchFaces [a,b,c]

                            )

                            meshName = meshBaseName + "_" + btch as string


                            theMesh = mesh vertices: batchVertices faces: batchFaces name: meshName tverts: batchUVs vnorms:batchNormals
                            theMesh.WireColor = Color (random 0 128) (random 64 192) (random 0 128)

                            theMesh.material = materialList[batch.textureid].materialRef

                            meshOp.setMapSupport theMesh 1 true
                            for t = 1 to theMesh.numverts  do meshop.setMapVert theMesh 1 t batchUVs[t]
                            update theMesh

                            theMesh.Parent = bbox
                            
                            if(refObj != undefined) then
                            (
                                theMesh.Rotation = refObj.Rotation
                                theMesh.Position = refObj.Position
                            )

                            wmoLayer.AddNode theMesh
                        )
                        catch()

                    )
                )

            )
            setArrowCursor()
        ),

        function ImportSingleM2 m2File= 
        (
            if(toUpper( getFileNameType m2File ) != ".M2" ) then return undefined
            
            local len = m2File.count - 3
            local skinToFind = substring m2File 1 len
            skinToFind = skinToFind + "*.SKIN"
            local files  = getfiles skinToFind
            local name = (getfilenamefile m2file) + "_parent"
            local refObj = dummy name:name pos:[0,0,0] boxSize:[1,1,1]
            
            hide refObj
            
            if(files.count > 0) then 
            (
                format "Processing % \n" ( getFileNameFIle m2File )
                GriffonStudios_WOW_Importer.ImportM2 m2File files[1] refObj
                
            )
            
        ),
        
        function AdtImportM2Models=
        (
            SetWaitCursor()
            
            local m2Models = #()
            
            
            
            for obj in objects do 
            (
                local extension = toUpper( getFileNameType obj.Name )
                
                if( extension == ".MDX") then
                   obj.Name = (getFilenamePath obj.Name )+ (getFilenameFile obj.Name) + ".M2"   
                
                if(classof obj == Dummy and ( extension == ".M2" or extension == ".MDX" )) then 
                (
                    append m2Models obj
                )
            )
                
            format "Nbr of M2 models to process: %\n" m2Models.count
            
            for obj in m2Models do
            (
                modelFile = WoWRootFolder + obj.name
                
                if(DoesFileExist modelFile == false) then 
                (
                    print ( "File not found : " + modelFile )
                    continue --> get the next model
                    
                )
                local len = modelFile.count - 3
                local skinToFind = substring modelFile 1 len
                modelFile = skinToFind + ".M2"
                skinToFind = skinToFind + "*.SKIN"
            
                files = getfiles skinToFind	
                
                if(files.count > 0) then 
                (
                    format "Processing % \n" ( getFileNameFIle modelFile )

                    try 
                    (
                        GriffonStudios_WOW_Importer.ImportM2 modelFile files[1] obj
                    )
                    catch
                    (
                        format "[ERROR] - Unable to process %\n" modelFile
                    )
                )
            )
            setArrowCursor()
            
        ),

        function AdtImportWmoModels=
        (
            SetWaitCursor()
            
            local objToImport = #()
            
            for obj in objects do
            (
                if(classof obj == Dummy ) then 
                (
                    if(toUpper( getFileNameType obj.Name ) == ".WMO" ) then 
                    (
                        modelFile = WoWRootFolder + obj.Name
                        
                        if(DoesFileExist modelFile == false) then 
                        (
                            print ( "File not found : % \n" + modelFile )
                            continue --> get the next model
                        )
                        
                        GriffonStudios_WOW_Importer.ImportWMOModels modelFile obj
                        
                    )
                )
            )
            
            
            setArrowCursor()
            
            
        ),

        function CreateAdt fileName = 
        (
            local meshName = GetFileNameFile fileName
            
            local stream = fOpen fileName "rb"
                
            local mver  = HelperFunctions.ReadFourCC stream
            local major = readLong stream
            local minor = readLong stream
            
            local chunks = #()
            local totalSize = HelperFunctions.StreamSize stream
            local uniqueChunkNames = #()
            
            /* get a ref to the chunks */
            while (ftell stream < totalSize) do
            (
                local chnk = WOW_CHUNK()
                chnk.name = HelperFunctions.ReadFourCC stream
                chnk.size = readLong stream
                chnk.offSet = ftell stream
                
                HelperFunctions.SkipBytes stream chnk.size
                append chunks chnk
                appendIfUnique uniqueChunkNames chnk.Name
            )
            
            format "Processing % ...\n" (filenameFromPath fileName)
            --print uniqueChunkNames
            
            for chnk in chunks do
            (
                local type = chnk.name
                
                if(type == "MHDR") then --> Header with the heights of the map
                (
                    if ( importADT ) then GriffonStudios_WOW_Importer.ReadADTHeights stream meshName chunks
                )
                if(type == "MAMP") then --> Used Textures
                (
                    format " - TEXTURES - NOT IMPLEMENTED YET % \n" fileName
                )
                if(type == "MMDX") then --> M2 and WMO files
                (
                    GriffonStudios_WOW_Importer.BuildMMDX stream chunks
                )
            )
            
            --print "Clean up"
            fClose stream
        )
    )
    
    ROLLOUT GriffonStudios_M2_MaterialManager "WOW M2 Material Manager" width:600 height:420
    (
        label lbl1 "Info: Press the update button when you picked another object in the scene" 
        label lblPath "No Files Found" width:550 height:30 align:#left 
        
        listBox lb "List of other textures found for this model" width:550 height:20 
        
        checkbox chkApplyAlpha "Apply alpha" checked:true
        
        button btnRefresh "Update" height:35 width:100 across:5
        button btnApplyTexture "Apply"  height:35 width:100
        button btnApplyToAll "Apply to all"  height:35 width:100
        button btnReset "Reset"  height:35 width:100
        button btnClose "Close" height:35 width:100
        
        local selectedObj = undefined
        local initialMaterial = undefined 
        local applyAlpha = undefined
        
        function FillListBox= 
        (
            if $ == undefined then return undefined
            
            selectedObj = $
            initialMaterial = selectedObj.material
            local diffMap = initialMaterial.diffuseMap.FileName
            local buffer = getUserPropBuffer selectedObj

            lblPath.text = getfilenamepath diffMap
            
            lb.items = #() 
            
            if buffer != "" and buffer != undefined then 
            (
                local files = FilterString buffer "\n"
            
                local selectedItem = 1
                
                for i=1 to files.count do
                (
                    if files[i] == diffMap then 
                    (
                        selectedItem = i
                        exit
                    )
                )
                lb.items = (for o in files collect (filenameFromPath o))
                lb.selection = selectedItem
            )
        )

        on btnApplyToAll PRESSED do
        (
            if $ == undefined then return undefined

            selectedObj = $
            
            for obj in objects do
            
                if( obj.name == selectedObj.name ) then
                    obj.material = selectedObj.material 
            
        )
        
        on chkApplyAlpha changed theState do
        (
            if applyAlpha then applyAlpha = false else applyAlpha = true
        )
        
        on btnReset PRESSED do
        (
            selectedObj.material = initialMaterial
        )
        
        on btnApplyTexture PRESSED do
        (
            local selected = lblPath.Text + lb.selected
            local newMat = HelperFunctions.BuildMaterial initialMaterial.name selected applyAlpha
            selectedObj.material = newMat
        )
        
        on GriffonStudios_M2_MaterialManager OPEN do
        (
            applyAlpha = true
            FillListBox()
        )
        
        on btnRefresh PRESSED do
        (
            FillListBox()
        )
        
        on btnClose PRESSED do 
        (
            destroydialog GriffonStudios_M2_MaterialManager
        )
        
        
    )
    
    ROLLOUT GriffonStudios_WMO_Settings "WMO Settings" width:530 height:280
    (
        group "Settings"
        (
            label		lbl1 "Root Folder (location to look for M2 and blp files)" align:#left
            edittext	txtWoWRootFolder width:500 text:WoWRootFolder align:#left
            button		btnBrowsePath "Browse..." tooltip:"Locate root path" align:#center width:100 height:35

            label		lbl2 "nConvert Application (converts BLP to PNG automatically)" align:#left
            edittext	txtConvertApp width:500 text:nConvertExe align:#left
            button		btnBrowseExe "Browse..." tooltip:"Locate nConvert File" align:#center width:100 height:35
                
        )
        button btnSaveAndClose "Save & Close" align:#right width:100 height:35
        
        on WMO_Settings open do
        (
            if(DoesFileExist iniFile) then
            (
                WoWRootFolder = getIniSetting iniFile "RootPath" "Value"
                nConvertExe = getIniSetting iniFile "nConvertExe" "Value"
                
                txtWoWRootFolder.Text = WoWRootFolder
                txtConvertApp.Text = nConvertExe
            )
            else
            (
                txtWoWRootFolder.Text = "Please select a foldername"
                txtConvertApp.Text = "Please select the nConvert Application"
                texturePath = ""
            )
        )
        
        on btnBrowseExe PRESSED do
        (
            nConvertExe = getOpenFileName \ 
                caption: "nConvert Application" \
                types: "nConvert.exe|*.exe" \
                historyCategory: "nConvertApplication"
            if(nConvertExe!= undefined ) then txtConvertApp.Text = nConvertExe
        )
        
        on btnBrowsePath PRESSED do
        (
            initialDirectory = ""
            
            if(DoesFileExist iniFile) then initialDirectory = getIniSetting iniFile "RootPath" "Value"
            
            WoWRootFolder = ( getSavePath caption: "Select root folder" initialDir:initialDirectory ) + "\\"
            
            txtWoWRootFolder.Text = WoWRootFolder
                
        )
        
        on btnSaveAndClose PRESSED do
        (
            SetIniSetting iniFile "RootPath" "Value" txtWoWRootFolder.Text
            SetIniSetting iniFile "nConvertExe" "Value" nConvertExe
            DestroyDialog WMO_Settings 
        )
    )
    
	Group "Select Map File"
	(
		Label lbl4 "�2019 Griffon Studios"
		Label lbl3 "v1.0"
        
		CheckBox cbImportMDX "Import M2 (helpers)"
		CheckBox cbImportWMO "Import WMO (helpers)"
        CheckBox cbImportADT "Import ADT (terrain)"
        
		Label lbl1 "Select a folder that contains the adt files:" width:140 height:35  align:#center
		
		Button btnImportADT "Select Map and import" height: 35 width: 140 offset:[0,0]
		Button btnImportM2 "Import M2 Models" height: 35 width: 140
        Button btnImportWMO "Import WMO Models" height: 35 width: 140
			
	)
    Group "Settings"
    (
        Button bSettings "Config..." height: 35 width: 140
    )
    Group "Import WMO/M2"
    (
        Button btnImportOneWMO "Import single WMO..." height: 35 width: 140
        Button btnImportOneM2 "Import single M2..." height: 35 width: 140
    )
    Group "M2 Material Manager"
    (
        button btnMatManager "Open Material Manager" height:35 width:140
    )
    
	on GriffonStudios_ADT_Importer OPEN do
	(
		cbImportMDX.Checked = true
		cbImportWMO.Checked = true
        cbImportADT.Checked = true
		
		if(DoesFileExist iniFile) then
		(
			WoWRootFolder = getIniSetting iniFile "RootPath" "Value"
			nConvertExe = getIniSetting iniFile "nConvertExe" "Value"
			
		)
	)
	on btnMatManager PRESSED do
    (
        createdialog GriffonStudios_M2_MaterialManager
    )
    
    on btnImportOneWMO PRESSED do
    (
        local wmoFile = getOpenFileName \
                            caption: "Select .wmo file" \
                            types: "World of Warcraft models(*.wmo)|*.wmo|All files|*.*" \
                            historyCategory: "prevWmoFolder"
        
        if (  wmoFile != "" and  wmoFile != undefined ) then GriffonStudios_WOW_Importer.ImportWMOModels wmoFile undefined
        max views redraw
        ClearSelection()
    )
    
    on btnImportOneM2 PRESSED do
    (
        local m2File = getOpenFileName \
                            caption: "Select .wmo file" \
                            types: "World of Warcraft models(*.m2)|*.m2|All files|*.*" \
                            historyCategory: "prevWmoFolder"
        
        if (  m2File != "" and  m2File != undefined ) then GriffonStudios_WOW_Importer.ImportSingleM2 m2File
        
        max views redraw
        ClearSelection()
    )
    
	on btnImportM2 PRESSED do
	(
        GriffonStudios_WOW_Importer.AdtImportM2Models()
        max views redraw
        ClearSelection()
	)
	
    on btnImportWMO PRESSED do
	(
		GriffonStudios_WOW_Importer.AdtImportWmoModels()
        max views redraw
        ClearSelection()
		
	)
    
	on btnImportADT PRESSED do
	(
		adtFolder = getSavePath initialDir:(WoWRootFolder + "world\maps")
        
        if( adtFolder != undefined ) then 
        (
            local allFiles = getFiles (adtFolder + "\\*.*")
            
            for f in allFiles do GriffonStudios_WOW_Importer.CreateAdt f 

            max views redraw
            ClearSelection()
            GC()
        )

	)

    on cbImportADT CHANGED theState do
	(
		if(importADT) then
			importADT = false
		else
			importADT = true
	)
    
	on cbImportMDX CHANGED theState do
	(
		if(importMDX) then
			importMDX = false
		else
			importMDX = true
	)
	
	on cbImportWMO CHANGED theState do
	(
		if(importWMO) then
			importWMO = false
		else
			importWMO = true
	)
	
	on bSettings PRESSED do
	(
		createdialog WMO_Settings
	)
)
ClearListener()

/*

error in E:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\World\wmo\Dungeon\NeltharionsLair\7DU_NeltharionsLair_Waterslide.wmo

*/