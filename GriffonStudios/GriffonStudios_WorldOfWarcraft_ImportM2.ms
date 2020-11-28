/************************************************************************************************
©2018 by Taylor Mouse 

Description:
    Import World Of Warcraft - M2 Files Static only
    
Versions:
v 0.9 - 10.2018 
    Complete rewrite after the release of Battle For Azeroth 


************************************************************************************************/

STRUCT _M2_Ref 
( 
    nbr, ofs,
   
    function Read stream versionOfs=
    (
        local ref = _m2_ref()
        ref.nbr = readLong stream
        ref.ofs = (readLong stream) + versionOfs
        return ref
    )
)
STRUCT _M2_Bounding
(
    vector3Min,
    vector3Max,
    radius,
    function ReadSphere stream=
    (
        local b = _M2_Bounding()
        
        b.vector3Min = [readFloat stream, readFloat stream, readFloat stream]
        b.vector3Max = [readFloat stream, readFloat stream, readFloat stream]
        b.radius = readFloat stream
        
        return b
    )
    
)
STRUCT _M2_Header
(
    fileId,     -- MD21
    fileSize,   -- only when fileId = MD21
    modelId,    -- MD20
    modelVer,   -- 274
    versionOffset, -- is 8 as of version 274, else 4
    nameRef,
    flags,
    globalSeqRef,
    animRef,
    animLookUpRef,
    boneRef,
    boneKeysRef,
    vertsRef,
    nViews,
    geoAnimsRef,
    texturesRef,
    transRef,
    texAnimsRef,
    texReplaceRef,
    renderFlagsRef,
    boneLookUpRef,
    texLookUpRef,
    texUnitsLookUpRef,
    transLookUpRef,
    texAnimsLookUpRef,
    collisionSphereRef,
    boundSphereRef,
    boundTrisRef,
    boundVertsRef,
    boundNormsRef,
    attachsRef,
    attachsLookUpRef,
    eventsRef,
    lightsRef,
    camerasRef,
    camerasLookUpRef,
    ribbonsRef,
    particlesRef,
    
    function Read stream= 
    (
        local header = _M2_Header()
        local fHelper = _Helper_Functions()
        

        header.fileId           = fHelper.ReadFixedString stream 4
        header.fileSize         = readLong stream
        header.modelId          = fHelper.ReadFixedString stream 4
        header.modelVer         = readLong stream
        header.versionOffset    = 4
        if( header.modelVer = 272 ) then header.versionOffset = 8
        if( header.modelVer >= 274 ) then header.versionOffset = 8
        
        local versionOffset = header.versionOffset
        
        header.nameRef          = _m2_ref.Read stream versionOffset
        header.flags            = readLong stream
        header.globalSeqRef     = _m2_ref.Read stream versionOffset
        header.animRef          = _m2_ref.Read stream versionOffset
        header.animLookUpRef    = _m2_ref.Read stream versionOffset
        header.boneRef          = _m2_ref.Read stream versionOffset
        header.boneKeysRef      = _m2_ref.Read stream versionOffset
        header.vertsRef         = _m2_ref.Read stream versionOffset
        header.nViews           = ReadLong stream #unsigned
        header.geoAnimsRef      = _m2_ref.Read stream versionOffset
        header.texturesRef      = _m2_ref.Read stream versionOffset
        header.transRef         = _m2_ref.Read stream versionOffset
        header.texAnimsRef      = _m2_ref.Read stream versionOffset
        header.texReplaceRef    =_m2_ref.Read stream versionOffset
        header.renderFlagsRef   = _m2_ref.Read stream versionOffset
        header.boneLookUpRef    = _m2_ref.Read stream versionOffset
        header.texLookUpRef     = _m2_ref.Read stream versionOffset
        header.texUnitsLookUpRef  = _m2_ref.Read stream versionOffset
        header.transLookUpRef     = _m2_ref.Read stream versionOffset
        header.texAnimsLookUpRef  = _m2_ref.Read stream versionOffset
        
        header.collisionSphereRef = _M2_Bounding.ReadSphere stream
        header.boundSphereRef   = _M2_Bounding.ReadSphere stream
        
        header.boundTrisRef     = _m2_ref.Read stream versionOffset
        header.boundVertsRef    = _m2_ref.Read stream versionOffset
        header.boundNormsRef    = _m2_ref.Read stream versionOffset
        header.attachsRef       = _m2_ref.Read stream versionOffset
        header.attachsLookUpRef = _m2_ref.Read stream versionOffset
        header.eventsRef        = _m2_ref.Read stream versionOffset
        header.lightsRef        = _m2_ref.Read stream versionOffset
        header.camerasRef       = _m2_ref.Read stream versionOffset
        header.camerasLookUpRef = _m2_ref.Read stream versionOffset
        header.ribbonsRef       = _m2_ref.Read stream versionOffset
        header.particlesRef     = _m2_ref.Read stream versionOffset
        
        
        
        return header
    )
    
)
STRUCT _M2_Submesh
(
	Id, 
    startVertex, 
    nVerts, 
    startIndex, 
    nIndices,
    indBones,
    nBones, 
	s1,
    b1,
	boundSphere,
    materialRef,
    
    function Read stream ref =
	(
        fseek stream ref.ofs #seek_set
        local submeshes = #()
		for i = 1 to ref.nbr do
		(
			local submesh = _M2_Submesh()
			
			submesh.Id       = ReadLong stream #unsigned
			submesh.startVertex = ReadShort stream #unsigned
			submesh.nverts      = ReadShort stream #unsigned
			submesh.startIndex  = ReadShort stream #unsigned 
			submesh.nIndices    = ReadShort stream #unsigned
			submesh.nbones   = ReadShort stream #unsigned
			submesh.indbones = ReadShort stream #unsigned
			submesh.s1       = ReadShort stream #unsigned
			submesh.b1       = ReadShort stream #unsigned
			submesh.boundSphere = _M2_Bounding.ReadSphere stream

			append submeshes submesh
		)
		
		return submeshes
	)
)
STRUCT _M2_Material
(
	id, 
    texFlags, 
    shaderFlags,
	SubInd, 
    SubInd2,
	ColourInd, 
    renderFlagsInd,
	TexUnitInd, 
    Mode, 
    TexInd, 
    TexUnitInd2,
	TransInd, 
    TexAnimInd,
	
	function Read stream ref =
	(
        

		fseek stream ref.ofs #seek_set
		local materials = #()
        
		for i = 1 to ref.nbr do
		(
			local TexUnit = _M2_Material()
			TexUnit.id = i
			TexUnit.texFlags = ReadShort stream #unsigned
			TexUnit.shaderFlags = ReadShort stream #unsigned
			TexUnit.SubInd = (ReadShort stream #unsigned) + 1
			TexUnit.SubInd2 = (ReadShort stream #unsigned) + 1
			TexUnit.ColourInd = (ReadShort stream #signed) + 1
			TexUnit.renderFlagsInd = (ReadShort stream #unsigned) + 1
			TexUnit.TexUnitInd = (ReadShort stream #unsigned) + 1
			TexUnit.Mode = ReadShort stream #unsigned
			TexUnit.TexInd = (ReadShort stream #unsigned) + 1
			TexUnit.TexUnitInd2 = (ReadShort stream #unsigned) + 1
			TexUnit.TransInd = (ReadShort stream #unsigned) + 1
			TexUnit.TexAnimInd = (ReadShort stream #unsigned) + 1
			
			append materials TexUnit
		)
		
		return materials
	)
)
STRUCT _M2_Header_Skin
(
    fileId, -- SKIN
    indicesRef, indices,
    facesRef, faces,
    vertIndsRef, vertInds,
	submeshesRef, submeshes,
    materialRef, materials,
	nbrSkinnedBones,
    
    function Read stream=
    (
        local fHelper = _Helper_Functions()
        local header = _M2_Header_Skin()
        
        header.fileId = fHelper.ReadFixedString stream 4
        if( header.fileId != "SKIN" ) then
        (
            throw "File is not in the correct format"
            return undefined
        )
        header.indicesRef = _M2_Ref.Read stream 0
        header.facesRef = _M2_Ref.Read stream 0
        header.vertIndsRef = _M2_Ref.Read stream 0
        header.submeshesRef = _M2_Ref.Read stream 0
        header.materialRef = _M2_Ref.Read stream 0
        header.nbrSkinnedBones = readLong stream #unsigned
        
        fseek stream header.indicesRef.ofs #seek_set
        header.indices = #()
        for i=1 to header.indicesRef.nbr do
        (
            local index = readshort stream #unsigned
            append header.indices ( index + 1 )
        )
        
        fseek stream header.facesRef.ofs #seek_set
        header.faces = #()
        for i=1 to header.facesRef.nbr do
        (
            local face = readshort stream #unsigned
            append header.faces ( face + 1 )
        )
        
        fseek stream header.vertIndsRef.ofs #seek_set
        header.vertInds = #()
        for i=1 to header.vertIndsRef.nbr do
        (
            local vprops = #()
			for j = 1 to 4 do
			(
				local vp = ReadByte stream #unsigned
				append vprops vp
			)
            append header.vertInds vprops
        )
        
        header.submeshes = _M2_Submesh.Read stream header.submeshesRef
        
        header.materials = _M2_Material.Read stream header.materialRef
        
        return header
    )
    
    
)
STRUCT _M2_Helper
(
    function ReadData ref stream type=
    (
        fSeek stream ref.ofs #seek_set
        
        if(type == #string) then
        (
            return _Helper_Functions.ReadFixedString stream ref.nbr
        )
        
    )
)
STRUCT _M2_Verts
(
    pos,
    boneWeights = #(),
    boneIndices = #(),
    normal,
    uv,
    n2float,
    
    function Read ref stream=
    (
        fSeek stream ref.ofs #seek_set
        
        local verts = #()
        
        for i=1 to ref.nbr do
        (
            local v = _M2_Verts()
            
            v.pos = [readFloat stream, readFloat stream, readFloat stream]
            
            for w=1 to 4 do
                append v.boneWeights ((readByte stream #unsigned) / 255.0 )
            
            for b=1 to 4 do
                append v.boneIndices ((readByte stream #unsigned) + 1 )
            
            v.normal = [readFloat stream, readFloat stream, readFloat stream]
            v.uv = [readFloat stream, 1- (readfloat stream), 0.0]
            v.n2float = [readFloat stream, readFloat stream]
                
            append verts v
        )
        
        return verts
    )
    
)
STRUCT _M2_Textures
(
    Id, type, flag, ref, fileName, 
    
    function Read ref stream versionOfs=
    (
        fSeek stream ref.ofs #seek_set
        local textures = #()
        local m2Helper = _M2_Helper()
        
        for t=1 to ref.nbr do
        (
            local texture = _M2_Textures()
            texture.Id = t
            texture.type = readLong stream #unsigned
            texture.flag = readLong stream #unsigned
            texture.ref = _M2_Ref.Read stream versionOfs
            
            append textures texture 
        )
        
        for texture in textures do
        (
            texture.fileName = m2Helper.ReadData texture.ref stream #string  
        )
        
        return textures
    ),
    function ConvertBlpTextures textures m2File= 
    (
        for texture in textures do
        (
           local pngFile = _Helper_Functions.FindBlpFile m2File texture.fileName
            
            texture.fileName = pngFile
        )
    ),
    function ReadLookUp ref stream=
    (
        fSeek stream ref.ofs #seek_set
        local lookup = #()
        for l=1 to ref.nbr do
        (
            append lookup  ((readShort stream #signed)+1)
        )
        return lookup
    ),
    function ReadUnitsLookUp ref stream=
    (
        fSeek stream ref.ofs #seek_set
        local lookup = #()
        for l=1 to ref.nbr do
        (
            append lookup  ((readlong stream #signed)+1)
        )
        return lookup
    )
        
)

STRUCT _WorldOfWarcraft_m2
(
    function FindSkinFile file = 
    (
        -- find the matching skin file
        local fileNameOnly = getFilenamefile file
        local filePath = getFileNamePath file
        local skinToFind = filePath + fileNameOnly + "*.skin"
        local possibleFiles = getfiles skinToFind
        local skinFile = undefined
        
        if(possibleFiles.count > 0) then 
            skinFile = possibleFiles[1]
        else
            return undefined
        
    ),
    function Import file refObj=
    (
        local skinFile = FindSkinFile file
        
        if(skinFile == undefined ) then 
        (
            format "Skin file not found for %\n" file
            return undefined
        )

        local m2 = fOpen file "rb"
       
        -- read the header
        local m2Header = _M2_Header.Read m2

        -- read the object name
        local objName = _M2_Helper.ReadData m2Header.nameRef m2 #string

        -- read the vertices
        local vertexList = _M2_Verts.Read m2Header.vertsRef m2
        
        -- get the textures blp files and convert them
        local textures = _M2_Textures.Read m2Header.texturesRef m2 m2Header.versionOffset
        _M2_Textures.ConvertBlpTextures textures file

        local textLookups = _M2_Textures.ReadLookUp m2Header.texLookUpRef m2 
        local textUnitsLookups = _M2_Textures.ReadUnitsLookUp m2Header.texUnitsLookUpRef m2

        fClose m2
        
        
        -- Read the skin file
        local skin2 = fOpen skinFile "rb"
        local skinContent = _M2_Header_Skin.Read skin2

        fClose skin2
        local debugMode = false
        local texInd = 0

        -- build the materials
        for m=1 to skinContent.Submeshes.Count do
        (
            for m2mat in skinContent.materials do
            (
                if ( m == m2mat.SubInd ) then
                (
                    try(
                        local textureFileName = textures[textLookups[m2mat.TexInd]].filename
                        
                        local mat = StandardMaterial()
                        mat.Name = getFilenamefile textureFileName
                        mat.diffuseMap = BitmapTexture fileName:textureFileName
                        
                        if ( m2mat.shaderFlags == 16 ) then 
                        (
                            mat.opacityMap = BitmapTexture fileName:textureFileName
                            mat.rgbOutput = 1
                            
                        )
                        
                        showTextureMap mat true
                        
                        skinContent.Submeshes[m].materialRef = mat
                        
                        exit
                    )
                    catch( exit )
                )
            )
        )
            

        
        if ( debugMode == false ) then (
            -- build the meshes
            local parentObj = refObj
            
            if (refObj == undefined ) then
            (
                local dummyName = objName + "-parent"
                parentObj = dummy name:dummyName pos:[0,0,0] 
            )
            for m=1 to skinContent.Submeshes.Count do
            (
               
                
                local batchColor = Color (random 0 180) (random 64 128) (random 0 180)
                local submesh = skinContent.Submeshes[m]
                local startVertex = submesh.startVertex
                local startIndex = submesh.startIndex
                local verts = #()
                local norms = #()
                local uvs = #()
                local faces = #()
                
                for v=1 to submesh.nVerts do
                (
                    append verts vertexList[startVertex + v].pos
                    append norms vertexList[startVertex + v].normal
                    append uvs vertexList[startVertex + v].uv
                )
                for i=1 to submesh.nIndices by 3 do
                (
                    local idx = i + startIndex
                    a = skinContent.faces[ idx ]  - startVertex
                    b = skinContent.faces[ idx+1 ] - startVertex
                    c = skinContent.faces[ idx+2 ] - startVertex

                    append faces [a,b,c]
                )
                
                local meshName = objName + " - " + (m as String)
                
                local theMesh = mesh name:meshName vertices:verts faces:faces vnorms:norms tverts:uvs
                    
                theMesh.WireColor = batchColor

                meshOp.setMapSupport theMesh 1 true
                for t = 1 to theMesh.numverts  do meshop.setMapVert theMesh 1 t uvs[t]

                update theMesh
                theMesh.Transform = parentObj.Transform
                theMesh.parent = parentObj
                theMesh.Material = skinContent.Submeshes[m].materialRef
                update theMesh
            )
            
            

        )
        
    )
)

--clearlistener()

-- m2Tool = _WorldOfWarcraft_m2()

-- wm2FileName = @"F:\Blizzard\World Of Warcraft\World Of Warcraft - Battle for Azeroth\WORLD\AZEROTH\DUSKWOOD\PASSIVEDOODADS\WEBS\WEBDANGLE01.m2"
-- refObj = $
-- m2Tool.Import m2FileName refObj
