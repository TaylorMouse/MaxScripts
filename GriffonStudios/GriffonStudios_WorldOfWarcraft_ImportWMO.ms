/************************************************************************************************
(c) 2018 by Taylor Mouse 

Description:
    Import World Of Warcraft - WMO Files
    
Versions:
v 0.10 - 07.2020 
    Corrected for versions 17
    
v 0.9 - 10.2018 
    Complete rewrite after the release of Battle For Azeroth 


************************************************************************************************/
GLOBAL WMO_VERSION, MODN_OFFSET, IMPORTBOUNDINGBOX

struct _wmo_chunk    
        ( header, size, offset )
struct _wmo_header   
        ( nTextures, nGroups, nPortals, nLights, nDooaddNames, nDooaddDefs, nDooaddSets, baseAmbientColor, wmoID, padding, bboxL, bboxR, flags, numLOD )
struct _wmo_material 
        ( diffuseMap, environmentMap, otherMap, flags, shader, blendmode, diffuseMapIndex, emissiveColor, emissiveMultiplier, environmentMapIndex, diffuseColor, groupType, otherTextureIndex, color2, flags2, materialRef )
struct _wmo_key_value  
        ( index, name ) 
struct _wmo_group_info 
        ( flags, bboxL, bboxR, nameIndex, groupName )
struct _wmo_dooadd_set 
        ( name, startIndex, count, pad )
struct _wmo_dooadd_definition 
        ( nameIndex, name, pos, rot, scale, color, nameOffset )
struct _wmo_mogp       
        ( groupNameIndex, groupName, descriptiveGroupNameIndex, flags, bboxL, bboxR, sub_chunks, indices, vertices, normals, textureCoordinateSets, batches)
struct _wmo_batch
        ( index, startIndex, nIndices, startVertex, endVertex, matListId, materialRef )

STRUCT _Helper_Functions
(
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
    function ReadColor stream=
    (
        -- reads RGBA color from 4 bytes
        local r = readByte stream #unsigned, 
              g = readByte stream #unsigned, 
              b = readByte stream #unsigned, 
              a = readByte stream #unsigned
        local col = color r g b a
        
        return col
    ),
    function SkipBytes stream nBytesToSkip=
    (
        fseek stream nBytesToSkip #seek_cur
    ),
    function GetLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if ( layer == undefined) then
            layer = LayerManager.NewLayerFromName layerName
        return layer
    ),
    function ClearEmptyLayers=
    (
        if( LayerManager.isDialogOpen() ) then LayerManager.closeDialog()

        layerCount = layerManager.count

         layerNames = #()

        for i = 0 to layerManager.count-1 do
        (
          layer = layerManager.getLayer i
          layerName = layer.name
            if(layerName != "0") do append layerNames layerName
        )

        for i=1 to layerNames.count do
        (
            layerObj = LayerManager.getLayerFromName layerNames[i]

            hasNodes =  layerObj.nodes &theNodes
            
            if(theNodes.Count == 0) then LayerManager.DeleteLayerByName layerNames[i]

        )
    ),
    function CreateBoundingBox bb1 bb2 name=
    (
        bbLayer = GetLayer "Bounding Boxes"
        /*
            bb1 and bb2 must both be a Vecto3 => [x,y,z]
        */
        if ( importBoundingBox == false) then return undefined

        bb = mesh vertices: #([bb1.x,bb1.y,bb1.z],[bb2.x,bb1.y,bb1.z],[bb1.x,bb2.y,bb1.z],[bb2.x,bb2.y,bb1.z], [bb1.x,bb1.y,bb2.z],[bb2.x,bb1.y,bb2.z],[bb1.x,bb2.y,bb2.z],[bb2.x,bb2.y,bb2.z] ) \
              faces: #([1,2,3],[4,3,2],[5,6,7],[8,7,6]) \
              name: name
        bb.wirecolor = color 30 30 180
        bb.boxmode = on
        bb.renderable = off
        freeze bb
        
        bbLayer.AddNode bb
        
        
        return bb
    ),
    function ReadFourCC stream=
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
    function ConvertToPng blpFile=
    ( -- World of Warcraft specific: convert the blp texture file to a png file
        try (
            local iniFile = (GetDir #userScripts) + @"\wow_wmo.ini"
            
            if ( doesfileExist iniFile == false ) then throw "wow_wmo.ini does not exist. nConvert was not found!!"
            
            local nConvertExe = getIniSetting iniFile "nConvertExe" "Value"
            
            if ( doesfileExist nConvertExe == false ) then throw "NO reference to the nConvert.exe file was found"

            local param = " -npcd 2 -org_depth -ctype rgba -corder inter -clevel 6 -out png "
            local pngFile = substring blpFile 1 (blpFile.Count - 4) + ".png"

            if ( DoesFileExist pngFile == false ) then 
                HiddenDosCommand (nConvertExe + param + "\"" + blpFile + "\"")
            
            return pngFile
        )
        catch
        (
            format "%\n" (getCurrentException())
        )
        return undefined
    ),
    function FindBlpFile wmoFile blpFile=
    ( -- World of Warcraft specific: find the blp file
        local listOfFolders = filterString wmoFile @"\"
        local fileFound = undefined
        local blpFileFound = undefined
        local convertedFile = undefined
        local folder = ""
        
        for i=1 to listOfFolders.count do
        (
            folder = folder + listOfFolders[i] + "\\" 

            local fileToFind = folder + blpFile

            if( doesFileExist fileToFind == true) then 
            (
                blpFileFound = fileToFind
                exit
            )
        )  
        if( blpFileFound != undefined  ) then
        (
            fileFound = ConvertToPng blpFileFound
            --format "\t%\n" ( filenameFromPath fileFound)
        )
        if(fileFound == undefined ) then 
            format "[WARNING] - Texture NOT found or unable to convert: %\n" blpFile
        return fileFound
    ),
    function FindM2File wmoFile m2File=
    ( -- World of Warcraft specific: find the m2 model file
        local listOfFolders = filterString wmoFile @"\"
        local m2FileFound = undefined
        local folder = ""
        
        
        local m2File = (getFilenamePath m2File) + (getFilenameFile m2File) + ".m2"
        
        
        for i=1 to listOfFolders.count do
        (
            folder = folder + listOfFolders[i] + "\\" 

            local fileToFind = folder + m2File

            if( doesFileExist fileToFind == true) then 
            (
                m2FileFound = fileToFind
                exit
            )
        )  
        
        if( m2FileFound == undefined) then 
            format "[WARNING] - M2 Model not found %\n" m2File
        
        return m2FileFound
    ),
    function ReadEndingString stream=
    (
        local str = ""
        local failsafe = 1000
        
        while(1==1) do
        (
            failsafe = failsafe - 1
            if ( failsafe == 0 ) then exit
            
            local b = ReadByte stream
            local s = bit.IntAsChar(b)
            if ( s !="") then 
                str = str + s
            else
                exit
        )
        return str
    )
)
STRUCT _WorldOfWarcraft_Chunks
(
    public wmoHelper = _Helper_Functions(),
    
    function ReadChunks stream=
    (
        local wmo_chunks = #()
        while (1==1) do
        (    
            local chnk = _wmo_chunk()
            
            chnk.header = wmoHelper.ReadFourCC stream
            chnk.size = readlong stream
            chnk.offset = ftell stream
            try ( fseek stream chnk.size #seek_cur )
            catch( exit )
            append wmo_chunks chnk
        )
        return wmo_chunks
    ),
    function ReadMVER chnk stream=
    (
        fseek stream chnk.offset #seek_set
        ver = readLong stream
        format "Reading Version (MVER) : %\n" ver
        return ver
    ),
    function ReadMOTX chnk stream=
    (
        format "Reading Textures (MOTX)\n"
        fseek stream chnk.offset #seek_set
        
        local texture = ""
        local textureList = #()
        for i=1 to chnk.size do
        (

            local b = ReadByte stream
            local s = bit.IntAsChar(b)
            
            if ( s !="") then 
            ( 
                texture = texture + s
            )
            else
            (
                if(texture !="") then 
                (
                    local t = _wmo_key_value()
                    t.name = texture
                    t.index = (ftell stream) - chnk.offset - texture.count - 1
                    print texture
                    append textureList t
                )
                texture = ""
            )
        )

        return textureList
        
    ),
    function ReadMOHD chnk stream=
    (
        format "Reading Header (MOHD)\n"
        /* header is 64 bytes */
        fseek stream chnk.offset #seek_set

        local header = _wmo_header()
        header.nTextures = readLong stream
        header.nGroups = readLong stream
        header.nPortals = readLong stream
        header.nLights = readLong stream
        header.nDooaddNames = readLong stream
        header.nDooaddDefs = readLong stream
        header.nDooaddSets = readLong stream
        header.baseAmbientColor = wmoHelper.readColor stream
        header.wmoID = readLong stream
        header.bboxL = [ ReadFloat stream,  ReadFloat stream,  ReadFloat stream ]
        header.bboxR = [ ReadFloat stream,  ReadFloat stream,  ReadFloat stream ]
        header.flags = readshort stream        
        header.numLOD = readshort stream

        wmoHelper.CreateBoundingBox header.bboxL header.bboxR "Main"
        
        return header
        
    ),
    function ReadMOMT chnk stream=
    (
        format "Reading Materials (MOMT)\n"
        /* material is 64 bytes */
        fseek stream chnk.offset #seek_set

        local nMat = chnk.Size / 64
        local matList = #()

        for i=1 to nMat do
        (
            local mat = _wmo_material()    
            
            mat.flags = readLong stream
            mat.shader = readLong stream
            mat.blendmode = readLong stream
            
            mat.diffuseMapIndex = readLong stream
            
            mat.emissiveColor = wmoHelper.ReadColor stream
            mat.emissiveMultiplier = readLong stream
            
            mat.environmentMapIndex = readLong stream
            
            
            mat.diffuseColor = wmoHelper.ReadColor stream
            mat.groupType = readLong stream
            mat.otherTextureIndex = readLong stream
            mat.color2 = wmoHelper.ReadColor stream
            mat.flags2 = readLong stream
            
            wmoHelper.SkipBytes stream 16 -- runtimeData
            
            append matList mat
        )
        
        return matList
        
        
    ),
    function ReadMOGN chnk stream=
    (
        format "Reading Group Names (MOGN)\n"
        fseek stream chnk.offset #seek_set
        
        local groupName = ""
        local mognList = #()
        
        for i=1 to chnk.size do
        (
            local b = ReadByte stream
            local s = bit.IntAsChar(b)
            
            if ( s !="") then 
            ( 
                groupName = groupName + s
            )
            else
            (
                if(groupName !="") then 
                (
                    local t = _wmo_key_value()
                    t.name = groupName
                    t.index = (ftell stream) - chnk.offset - groupName.count - 1
                    append mognList t
                )
                groupName = ""
            )
        )
        return mognList
        
    ),
    function ReadMOGI chnk stream=
    (
        format "Reading Group Information (MOGI)\n"
        fseek stream chnk.offset #seek_set
        
        /* 32 bytes */ 
        local nGroupInfos = chnk.Size / 32
        local grpInfos = #()
        
        for i=1 to nGroupInfos do
        (
            local grpInfo = _wmo_group_info()
            grpInfo.flags = readLong stream
            grpInfo.bboxL = [ ReadFloat stream,  ReadFloat stream,  ReadFloat stream ]
            grpInfo.bboxR = [ ReadFloat stream,  ReadFloat stream,  ReadFloat stream ]
            grpInfo.nameIndex = readLong stream
            
            append grpInfos grpInfo
        )
        
        return grpInfos
        
    ),
    function ReadMOPV chnk stream=
    (
        format "Reading Portal Vertices (MOPV)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadMOPT chnk stream=
    (
        format "Reading Portal Information (MOPT)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadMOPR chnk stream=
    (
        format "Reading Portal Reference (MOPR)\n"
        fseek stream chnk.offset #seek_set
        
    ),    
    function ReadMOSB chnk stream=
    (
        format "Reading Skybox (MOSB)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadMOVV chnk stream=
    (
        format "Reading Visible Vertices (MOVV)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadMOVB chnk stream=
    (
        format "Reading Visible Block (MOVB)\n"
        fseek stream chnk.offset #seek_set
        
    ),    
    function ReadMOUV chnk stream=
    (
        format "Reading Animatable UV's (MOUV)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadMOLT chnk stream=
    (
        format "Reading Light Info (MOLT)\n"
        fseek stream chnk.offset #seek_set
    ),
    function ReadMODS chnk stream=
    (
        
        format "Reading Dooadd set (MODS)\n"
        fseek stream chnk.offset #seek_set
        
        /* 32 bytes */
        local nDooadds = chnk.Size / 32
        local dooadds = #()
        
        for i=1 to nDooadds do
        (
            local da = _wmo_dooadd_set()
            
            da.name = wmoHelper.ReadFixedString stream 20
            da.startIndex = readLong stream #unsigned
            da.count = readLong stream
            da.pad = wmoHelper.ReadFixedString stream 4
            
            append dooadds da
        )
        
        return dooadds
        
    ),
    function ReadMODN chnk stream=
    (
        format "Reading Dooadd Names (MODN)\n"
        fseek stream chnk.offset #seek_set
        MODN_OFFSET = chnk.offset
        local dooaddName = ""
        local nameList = #()
        for n=1 to chnk.size do
        (
            local b = ReadByte stream
            local s = bit.IntAsChar(b)
            
            if ( s !="") then 
            ( 
                dooaddName = dooaddName + s
            )
            else
            (
                if(dooaddName !="") then 
                (
                    local t = _wmo_key_value()
                    t.name = dooaddName
                    t.index = (ftell stream) - chnk.offset - dooaddName.count - 1
                    append nameList t
                )
                dooaddName = ""
            )
            
        )
        return nameList
    ),
    function ReadMODI chnk stream=
    (
        format "Reading Dooadd Indexes (MODI)\n"
        fseek stream chnk.offset #seek_set
        
        local nameList = #()
        for n=1 to chnk.size do
        (
            append nameList (( readLong stream #unsigned ) as string )
        )
        return nameList
    ),
    function ReadMODD chnk stream=
    (
        
        format "Reading Dooadd Definitions (MODD)\n"
        fseek stream chnk.offset #seek_set
        local defList = #()
        for i=1 to chnk.Size / 40 do
        (
            local def = _wmo_dooadd_definition()
            local currentPos = ftell stream + 4
            
            if ( WMO_VERSION == 17 ) then 
            (
                def.nameOffset = readShort stream
                readShort stream
                local offset = def.nameOffset + MODN_OFFSET
                fseek stream offset #seek_set
                def.name = wmoHelper.ReadEndingString stream

            )
            else
                def.nameIndex = readLong stream
            
            fseek stream currentPos #seek_set
            
            def.pos  = [readfloat stream, readfloat stream, readfloat stream]
            def.rot  = quat (readfloat stream) (readfloat stream) (readfloat stream) (readfloat stream)
            def.scale     = readfloat stream
            def.color     = wmoHelper.readColor stream
            
            append defList def
        )
        
        return defList
    ),
    function ReadMFOG chnk stream=
    (
        format "Reading Fog Information (MFOG)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadGFID chnk stream=
    (
        format "Reading Group File Id (GFID)\n"
        fseek stream chnk.offset #seek_set
        
    ),
    function ReadMOGP chnk stream=
    (
        format "Reading Group File (MOGP)\n"
        fseek stream chnk.offset #seek_set
        
        local mogpChunk = _wmo_mogp() -- groupNameIndex, groupName, descriptiveGroupNameIndex, flags, bboxL, bboxR, sub_chunks
        
        mogpChunk.groupNameIndex = readLong stream
        mogpChunk.descriptiveGroupNameIndex = readLong stream
        mogpChunk.flags = readLong stream
        mogpChunk.bboxL = [readfloat stream, readfloat stream, readfloat stream]
        mogpChunk.bboxR = [readfloat stream, readfloat stream, readfloat stream]
        
        mogpChunk.sub_chunks = #()
        
        wmoHelper.SkipBytes stream 32
        
        while (1==1) do
        (    
            local chnk = _wmo_chunk()
            
            chnk.header = wmoHelper.ReadFourCC stream
            chnk.size = readlong stream
            chnk.offset = ftell stream
            try ( fseek stream chnk.size #seek_cur )
            catch( exit )
            append mogpChunk.sub_chunks chnk
        )
        return mogpChunk
        
    ),
    function ReadMOVI chnk stream=
    (
        --format "\tReading Indices (MOVI)\n"
        fseek stream chnk.offset #seek_set
        
        local nIndices = chnk.Size / 2
        local indices = #()
        
        for i=1 to nIndices do
        (
            local index = (readShort stream #unsigned) + 1 
            append indices index
        )
        return indices
        
    ),
    function ReadMOVT chnk stream=
    (
        
        --format "\tReading Vertices (MOVT)\n"
        fseek stream chnk.offset #seek_set
        
        local nVertices = (chnk.Size / 4) / 3 
        local vertices = #()
        
        for i=1 to nVertices do
        (
            append vertices [readFloat stream, readFloat stream, readFloat stream]
        )
        return vertices
        
    ),
    function ReadMONR chnk stream=
    (
        ----format "\tReading Normals (MONR)\n"
        fseek stream chnk.offset #seek_set
        
        local nNormals = (chnk.Size / 4) / 3 
        local normals = #()
        
        for i=1 to nNormals do
        (
            append normals [readFloat stream, readFloat stream, readFloat stream]
        )
        return normals
        
    ),
    function ReadMOTV chnk stream=
    (
        ----format "\tReading Texture Coordinates (MOTV)\n"
        fseek stream chnk.offset #seek_set
        
        local nTextCoord = (chnk.Size / 4) / 2 
        local textCoord = #()
        
        for i=1 to nTextCoord do
        (
            append textCoord [readFloat stream, 1 - readFloat stream, 0.0]
        )
        return textCoord
        
    ),
    function ReadMOBA chnk stream=
    (
        --format "\tReading Batches (MOBA)\n"
        fseek stream chnk.offset #seek_set

        local nBatches = chnk.Size / 24 -- 24 bytes each
        local batches = #()
        
        for i=1 to nBatches do
        (
            local batch = _wmo_batch()
            
            readLong stream
            readLong stream
            readShort stream
            batch.index         = readShort stream #unsigned
            batch.startIndex    = readLong stream #unsigned
            batch.nIndices      = ReadShort stream #unsigned
            batch.startVertex   = ReadShort stream #unsigned
            batch.endVertex     = ReadShort stream #unsigned
            batch.matListId     = ReadShort stream #unsigned
           
            append batches batch
        )
        
        return batches
    )
    
    
)
STRUCT _WorldOfWarcraft_Mapping
(
     function MapTexturesToMaterials textures materials=
    (
        for m=1 to materials.count do
        (
            local index1 = materials[m].diffuseMapIndex
            local index2 = materials[m].environmentMapIndex
            local index3 = materials[m].otherTextureIndex
            
            for i=1 to textures.count do
            (
                if(textures[i].index == index1 ) then materials[m].diffusemap = textures[i].name
                if(textures[i].index == index2 ) then materials[m].environmentMap = textures[i].name
                if(textures[i].index == index3 ) then materials[m].otherMap = textures[i].name
                
            )
        )
    ),
    function MapGroupNamesToGroupInfo groupNames groupInfos=
    (
        for i=1 to groupInfos.count do
        (
            if(groupInfos[i].nameIndex == -1 ) then 
                groupInfos[i].groupName = "No Name - " + (i as string )
            else
            (
                for n=1 to groupNames.count do
                (
                    if(groupNames[n].index == groupInfos[i].nameIndex ) then
                    (
                        groupInfos[i].groupName = groupNames[n].name
                        continue
                    )
                )
            )
        )
    ),
    function MapDooaddDefinitionToNames defList dooaddNames=
    (
        for d=1 to defList.Count do
        (
            for n=1 to dooaddNames.Count do
            (
                if ( defList[d].nameIndex == dooaddNames[n].Index ) then
                (
                    defList[d].name = dooaddNames[n].name
                    continue
                )
            )
        )
    ),
    function MapMOGPwithGroupName mogp groupNames=
    (
       
        for grpName in groupNames do
        (
            if( grpName.index == mogp.groupNameIndex) then
            (
                mogp.groupName = grpName.name
                format "\tGroup Name: %\n" grpName.name
                continue
            )
        )
      
        
    ),
    function MapBatchesWithMaterials batches materials=
    (
        for i=1 to batches.count do
        (
            try 
            (
                batches[i].materialRef = materials[batches[i].index+1].MaterialRef
            )
            catch()
        )    
    )
)
STRUCT _WorldOfWarcraft_Creation
(
    public WmoHelper = _Helper_Functions(),
    
    function CreateMaterials materials wmofile=
    (
        /* TODO : implement an option for create SC2Materials */
        /* create 3DS Max Materials */
        for i=1 to materials.count do
        (

            local matRef = StandardMaterial()
            
            showTextureMap matRef true
            
            matRef.adLock = off
            
            matRef.name = getfilenamefile materials[i].diffuseMap + "_material_" + (i as string)
            matRef.diffuseMapEnable = on
            
            local diffMap = materials[i].diffuseMap
            if( diffMap != undefined) then
            (
                local textureFile = WmoHelper.FindBlpFile wmofile diffMap
                if(textureFile != undefined) then matRef.diffuseMap = Bitmaptexture fileName:textureFile
                
                if(materials[i].blendmode == 1) then
                (   
                    matRef.opacityMap = matRef.diffuseMap
                    matRef.opacityMap.monooutput = 1
                )
                
            )
            
            local envMap = materials[i].environmentMap
            if( envMap != undefined) then
            (
                local textureFile  = WmoHelper.FindBlpFile wmofile envMap
                if(textureFile != undefined) then matRef.specularMap = Bitmaptexture fileName:textureFile
            )
            
            local glossMap = materials[i].otherMap
            if( glossMap != undefined) then
            (
                local textureFile  = WmoHelper.FindBlpFile wmofile glossMap
                if(textureFile != undefined) then matRef.glossinessMap = Bitmaptexture fileName:textureFile
            )
            
            matRef.diffuse         = materials[i].diffuseColor
            matRef.selfIllumAmount = materials[i].emissiveMultiplier
            matRef.selfIllumColor  = materials[i].emissiveColor
            if( matRef.SelfIllumAmount > 0 )  then mapRef.selfIllumMapEnable = true
            
            matRef.specular = materials[i].color2
            
            materials[i].materialRef = matRef
            
        )
    ),
    function CreateDooaddHelpers dooaddSets dooaddList wmoFile=
    (
        
        local layerName = "Global Dooadd Set"
        
        if( dooaddSets != undefined ) then
        (
            if(dooaddSets.Count > 0) then 
            (
                layerName = dooaddSets[1].name
                format "Number of props %\n" dooaddlist.Count
            )
        )
        
        local dooaddHelperLayer = WmoHelper.GetLayer layerName
        
        for i=1 to dooaddList.Count do
        (
            local dooadd = dooaddlist[i]
            if(dooadd.Name == undefined ) then dooadd.Name = "Unknown"
            local dhName = ( getfileNameFile dooadd.name ) + "_" + (i as string ) 
            local dh = dummy name:dhName pos:[0,0,0]
            dh.pos = dooadd.pos
            dh.rotation = dooadd.rot
            dh.scale = [dooadd.scale, dooadd.scale, dooadd.scale]
            
            local m2FullFileName = WmoHelper.FindM2File wmoFile dooadd.name
            
            setUserProp dh "m2filename" m2FullFileName
            
            dooaddHelperLayer.addnode dh
        )
    ),
    function CreateMOGPBoundingBox mogp=
    (
        
        WmoHelper.CreateBoundingBox mogp.bboxL mogp.bboxR mogp.groupName
        
    ),
    function CreateWmoMesh mogp=
    (
        local mainLayer = WmoHelper.GetLayer "wmo"
        
        local layer = WmoHelper.GetLayer mogp.groupName
        layer.setParent mainLayer
        local batchColor = Color (random 0 180) (random 64 128) (random 0 180)

        if(mogp.batches == undefined) then return undefined
        
        for x=1 to mogp.batches.Count do
        (
            local batch = mogp.batches[x]

            local batchVertices = #()
			local batchUVs = #()
			local batchNormals = #()
            local batchFaces = #()
            
            try
            (
                for v=batch.StartVertex to batch.EndVertex  do
                (
                    append batchVertices mogp.vertices[v+1]
                    append batchUVs mogp.textureCoordinateSets[1][v+1]
                    append batchNormals mogp.normals[v+1]
                )

                for i=1 to batch.nIndices by 3 do
                (
                    local idx = i + batch.startIndex
                    a = mogp.indices[ idx ]  - batch.StartVertex
                    b = mogp.indices[ idx+1 ] - batch.StartVertex
                    c = mogp.indices[ idx+2 ] - batch.StartVertex
                    
                    append batchFaces [a,b,c]
                )

                local meshName = mogp.groupName + "_" + (x as String)

                local theMesh = mesh name:meshName vertices:batchVertices faces:batchFaces vnorms:batchNormals tverts:batchUVs
                
                theMesh.WireColor = batchColor

                meshOp.setMapSupport theMesh 1 true
                for t = 1 to theMesh.numverts  do meshop.setMapVert theMesh 1 t batchUVs[t]

                if (batch.materialRef != undefined ) then 
                    theMesh.material = batch.materialRef

                update theMesh

                layer.AddNode theMesh
            )
            catch
            (
                time
                format "\nERROR in batch %\n%\n%\n" x batch (getCurrentException())
            )
        )
        
        
    )
)
STRUCT _WorldOfWarcraft_wmo
(
    public 
        --WMO_VERSION = 0,
        WmoHelper   = _Helper_Functions(),
        WmoChunks   = _WorldOfWarcraft_Chunks(),
        WmoMapping  = _WorldOfWarcraft_Mapping(),
        WmoCreation = _WorldOfWarcraft_Creation(),
    
    /* Main import */
    function Import file CREATE_DOOADDHELPERS=
    (
        heapSize +=250000000
        
        stream = fOpen file "rb"
        
        local wmo_header = undefined
        local wmo_chunks = #()
        local textureList = #()
        local materials = #()
        local groupNames = #()
        local groupInfos = #()
        local dooaddSets = #()
        local dooaddNames = #()
        local dooaddDefinitions = #()
        
        WmoHelper.ClearEmptyLayers()
        
        /* read the chunks */
        wmo_chunks = WmoChunks.ReadChunks stream
        
        /* loop over the chunks and read them */
        for chnk in wmo_chunks do
        (
            if( chnk.header == "MVER" ) then WMO_VERSION = WmoChunks.ReadMVER chnk stream
            if( chnk.header == "MOHD" ) then wmo_header = WmoChunks.ReadMOHD chnk stream
            if( chnk.header == "MOTX" ) then textureList = WmoChunks.ReadMOTX chnk stream
            if( chnk.header == "MOMT" ) then materials = WmoChunks.ReadMOMT chnk stream
            if( chnk.header == "MOGN" ) then groupNames = WmoChunks.ReadMOGN chnk stream
            if( chnk.header == "MOGI" ) then groupInfos = WmoChunks.ReadMOGI chnk stream
            if( chnk.header == "MOPV" ) then WmoChunks.ReadMOPV chnk stream
            if( chnk.header == "MOPT" ) then WmoChunks.ReadMOPT chnk stream
            if( chnk.header == "MOPR" ) then WmoChunks.ReadMOPR chnk stream
            if( chnk.header == "MOUV" ) then WmoChunks.ReadMOUV chnk stream
            if( chnk.header == "MOVV" ) then WmoChunks.ReadMOVV chnk stream
            if( chnk.header == "MOVB" ) then WmoChunks.ReadMOVB chnk stream
            if( chnk.header == "MOLT" ) then WmoChunks.ReadMOLT chnk stream
            if( chnk.header == "MOSB" ) then WmoChunks.ReadMOSB chnk stream
            if( chnk.header == "MODS" ) then dooaddSets = WmoChunks.ReadMODS chnk stream
            if( chnk.header == "MODN" ) then dooaddNames = WmoChunks.ReadMODN chnk stream
            if( chnk.header == "MODI" ) then dooaddNames2 = WmoChunks.ReadMODI chnk stream -- Battle for Azeroth
            if( chnk.header == "MODD" ) then dooaddDefinitions = WmoChunks.ReadMODD chnk stream
            if( chnk.header == "MFOG" ) then WmoChunks.ReadMFOG chnk stream
            if( chnk.header == "GFID" ) then WmoChunks.ReadGFID chnk stream
            
        )
        /* map the names to indexes in the lists */
        WmoMapping.MapTexturesToMaterials      textureList materials
        WmoMapping.MapGroupNamesToGroupInfo    groupNames groupInfos
        

        
        
        if( WMO_VERSION != 17 ) then
            WmoMapping.MapDooaddDefinitionToNames  dooaddDefinitions dooaddNames
        
        fClose stream
         
        /* create materials so that the batches can have their max materials */
        WmoCreation.CreateMaterials materials file
         
        /* Build dooadd helpers, add a custom property to the objects to be able to load them afterwards */
        if( CREATE_DOOADDHELPERS ) then WmoCreation.CreateDooaddHelpers dooaddSets dooaddDefinitions file
        
    
--         
--         format "Textures:\n" 
--         print textureList
--         format "Materials:\n" 
--         print materials
--         


        /* if the previous file was a group file, loop over the actual mesh files */
        if(wmo_header != undefined ) then 
        (
            for i=1 to wmo_header.nGroups do
            (
                local calc = substring (( 1000 + i - 1 ) as string) 2 -1
                local subfile = getFileNamePath file + ( getFileNameFile file ) + "_" + calc + ( getFileNameType file )
            
                format "\nProcessing %\n" subfile -- (( getFileNameFile file ) + "_" + calc)
                
                local wmo_subfile_chunks = undefined
                
                if ( doesFileExist subfile == false ) then
                (
                    format "[WARNING] '%' does not exists, this file will be skipped.\n" subfile
                )
                else
                (
                    subStream = fOpen subfile "rb"
                    wmo_subfile_chunks = WmoChunks.ReadChunks subStream
                    
                    for chnk in wmo_subfile_chunks do  
                    (
                        if( chnk.header == "MVER" ) then WmoChunks.ReadMVER chnk subStream
                        if( chnk.header == "MOGP" ) then 
                        (
                            local mogp = WmoChunks.ReadMOGP chnk substream
                            
                            if ( groupNames != undefined ) then  -- if the group subfile is read seperatly, there is no notion of groupnames
                            (
                                WmoMapping.MapMOGPwithGroupName mogp groupNames
                                WmoCreation.CreateMOGPBoundingBox mogp
                            )
                            
                            /* subchunks: 
                            
                                "MOPY" Material info -- ignored
                                "MOVI" Tris
                                "MOVT" Vertices
                                "MONR" Normals
                                "MOTV" UV Coord
                                "MOBA" render batches 
                                "MOBS" ??
                                "MOLP" light positions
                                "MODR" dooadd refs
                                "MOBN" collision
                                "MOBR" tris indices for nodes
                                "MOTV" ??
                                "MOCV" Vertex Colors
                                "MDAL" ??
                            */
                            local texCoordSet = #()
                            for chunk in mogp.sub_chunks do
                            (
                                if ( chunk.header == "MOVI" ) then mogp.indices = WmoChunks.ReadMOVI chunk substream
                                if ( chunk.header == "MOVT" ) then mogp.vertices = WmoChunks.ReadMOVT chunk substream
                                if ( chunk.header == "MONR" ) then mogp.normals = WmoChunks.ReadMONR chunk substream
                                if ( chunk.header == "MOTV" ) then append texCoordSet ( WmoChunks.ReadMOTV chunk substream )
                                if ( chunk.header == "MOBA" ) then mogp.batches = WmoChunks.ReadMOBA chunk substream
                                
                            )
                            mogp.textureCoordinateSets = texCoordSet
                            
                            
                            /* map the batches with the correct textures */
                             if ( materials != undefined and mogp.batches != undefined and materials.count > 0  ) then  -- if the group subfile is read seperatly, there is no notion of groupnames
                                WmoMapping.MapBatchesWithMaterials mogp.batches materials
                         
                            /* Build the meshes, create a layer based ont the mogp.groupName */
                            WmoCreation.CreateWmoMesh mogp
                        )
                    )
                    fClose subStream
                )
                
            )
        )
        

    )
)


-- clearlistener()
IMPORTBOUNDINGBOX = false

--file = @"E:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\world\wmo\zuldazar\desertzone\8des_snakespire.wmo"
--file = @"E:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\world\wmo\zuldazar\desertzone\8des_pyramid.wmo"
-- file = @"E:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\world\wmo\zuldazar\desertzone\8des_snaketemple01.wmo"
-- file = @"E:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\world\wmo\zuldazar\desertzone\8des_snakespire_000.wmo"
-- file = @"F:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\world\wmo\dungeon\kl_ahnqiraj\westernfrontlandscape.wmo"
-- wmo = _WorldOfWarcraft_wmo()
-- wmo.Import file true

