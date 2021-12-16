/*
    ©2014 ~ 2021 Script by Taylor Mouse
	Starcraft II & Heroes of the Storm model import (.m3 & .m3a)
	Starcraft and Heroes of the Storm are reigistered trademarks of Blizzard Entertainment

*/

/*	Release notes
    v3.3.5 Fixed a scale factor for the UV and the positioning of hit test fuzzy and vol targets
    v3.3.4 Added a global scale factor since the initial * 100 was too much for some objects
    v3.3.3 Added FixGLsequences function
    v3.3.2 Fixed a bug in the naming conventions for animations
    v3.3.1 Fixed the uv coordination corrections, it no longer uses the basic 2048 conversion (works for 90%)


v3.3 Release to community
    
    v3.2.7 added support for the latest release (HotS v2.33)
           fixed issues with the hittesttight types, it now supports all 8 types
           support for non SC2 art tools has been reviewed
           displaying materials in viewport has been beautified
    v3.2.6 Clean up the scene has been extended to prevent .net error
    v3.2.5 Bug Fix, Particle effects were incorrectly parented and positioned
    v3.2.4 Added & removed dropdown for UV corrections 1, 4, 8, 16, 32,64, 128 (still unknown how to fix this correctly )
    v3.2.3 Added support for Decals and second uv map layer
    v3.2.2 Added support for Hit Test Tight

v3.2 Bugfixes, camera creation does no longer require Art Tools
v3.1 Bugfixes, update to Nova Missions 1,2 and 3

v3.0 Release to community
    v2.3 Support for EX3
    v2.2 Added particle effects - no animation yet
    v2.1 Bug Fix, memory leak and material support for MAX 2012 and up

v2.0 Release to community
    v1.9 Support for latest release
    v1.8 Corrected Material setting for emissive and spcular multiplier
    v1.7 Extented Material Support
    v1.6 Added Camera import

v1.5 Release to Community
    v1.4 merged SC2 Art Tools stuff and No SC2 Art Stuff together
    v1.3 Fixed the weird animations
    v1.2 NO Art Tools required ( is a different script )
    v1.1 Bug Fixing added ReadBytes ( renamed it to SkipBytes)

v1.0 Released to Community
    v0.4 Added STC as animations
    v0.3 Corrected skinning
    v0.2 Making it usable and adding comments
    v0.1 Covering the basics

*/

/* GLOBALS */
GLOBAL ASSETS_FOLDER = @""

GLOBAL TAGS      = #()
GLOBAL SEQS_LIST = #()
GLOBAL STG_LIST  = #()
GLOBAL STS_LIST  = #()
GLOBAL STC_LIST  = #()
GLOBAL BONE_LIST = #()
GLOBAL IREF_LIST = #()
GLOBAL INDICES_LIST 	 = #()
GLOBAL VERTEX_LIST 		 = #()
GLOBAL NORMALS_LIST 	 = #()
GLOBAL UVW_LIST 		 = #()
GLOBAL UVW_LIST2 		 = #()
GLOBAL SUBMESH_LIST 	 = #()
GLOBAL MESHMAT_LIST 	 = #()
GLOBAL MATM_LIST		 = #()
GLOBAL ATVL_LIST		 = #()
GLOBAL ATT_LIST			 = #()
GLOBAL MAT_LIST          = #()
GLOBAL SSGS_LIST		 = #()
GLOBAL WEIGHTBONE_LIST   = #()
GLOBAL CAM_LIST          = #()
GLOBAL PARTICLE_SYSTEMS  = #()

GLOBAL BONE_LOOKUP
GLOBAL gMODL
GLOBAL gFILETYPE
GLOBAL gHitTestTight
GLOBAL nbrValidSTCs = 0

GLOBAL bUseSC2ArtTools = true
GLOBAL bBuildBones = true
GLOBAL bBuildHitTest = true
GLOBAL bBuildAtt = true
GLOBAL bBuildAnim = true
GLOBAL bBuildMat = true
GLOBAL bBuildVolTarget = true
GLOBAL bBuildSkin = true
GLOBAL bBuildParticles = true

GLOBAL gResizeUvs = 1.0
GLOBAL gUnwrapOffsetU = 0.0
GLOBAL gUnwrapOffsetV = 0.0

GLOBAL gScaleFactor = 25.0

/* STRUCTS */
struct HEROES_TAG 		( Name, Offset, NbrItems, Flag, TagData ) /* 16 bytes */
struct HEROES_BoundBox 	( MinValue, MaxValue, Radius )
struct HEROES_LAYR   	( Id, TextureRefId )
struct HEROES_SEQS 		( Name, StartFrame, endFrame, MovementSpeed, Flags, NonLooping, Frequency, ReplayStart, ReplayEnd )
struct HEROES_STG		( Name, STC_ids )
struct HEROES_STS		( AnimationsIds )
struct HEROES_STC       ( Name, stsIndex, AnimationIds, AnimationRefs, runsConcurrent, priority, SDEV_data, SD2V_data, SD3V_data, SD4Q_data, SDCC_data, SDR3_data, SDS6_data, SDU6_data, SDU3_data, SDFG_data, SDMB_data, SEQ_refId, FirstFrame, LastFrame, NonLooping = false, Frequency = 100, MovementSpeed = 0 )
struct HEROES_AnimData  ( FrameList, Flags, EndFrame, Keys )
struct HEROES_AnimRef   ( sd, sdindx )
struct HEROES_BONE		( Id, Name, ParentBoneId, Position, Rotation, Scale,AnimRef,BillBoard1=false, billboard2=false, twoDProjection = false, InheritTranslation=false, InheritScale=false, InheritRotation=false, IsAnimated=false, InverseKinematics=false, Skinned=false, Real=false,  AnimRefPosition, AnimRefRotation, AnimRefScale, AnimRefAnim, TheBone )
struct HEROES_BoneAnimRef ( InterpolationType, animFlags, AnimId )
struct HEROES_IREF      ( Matrix )
struct HEROES_Submesh   ( Name, firstVertex, nVerts, firstIndex, nIndices, nBones,firstBoneLookup,nBoneLookup, nBoneWeightPairs, RootBoneId, TheMesh, 
                          uvCorrection1, uvCorrection2, uvCorrection3, UvScale )
struct HEROES_MeshMat	( MeshId, MatId)
struct HEROES_MATM		( materialIndex, materialType )
struct HEROES_VOLTARGET ( type, size0, size1, size2,bone0, bone1,bone2, matrix )
struct HEROES_HITTEST   ( type, size0, size1, size2,boneId, matrix )
struct HEROES_ATT		( Name, ParentId )

struct HEROES_MODL	 	( Name, VerticesTAG, nSkinBones )
struct HEROES_WEIGHTBONE ( Weights, BoneIndexes )
struct HEROES_CAMERA    ( CamRef, BoneRefId )
struct MAX_ANIMATION ( FrameList, KeyList )

struct HEROES_NONSC2_MAT ( Name, Diff_Map, Norm_Map, Height_Map, Decal_Map, Spec_Map, Emis_Map, Emis2_Map, Env_Map, Envio_Map, Alpha_Map, Alpha2_Map, Light_Map, MaterialRef )

struct HEROES_Particles ( parentBoneIndex, particleSystem )

struct HEROES_HitTestTight ( parentBoneId, hitTestModel )

/*********************************************************************************************************************

	HELPER FUNCTIONS

*********************************************************************************************************************/
fn ResetGlobals=
(
	/* When reselectin a file, reset these so no data of previous files is retained */
    TAGS      = UNDEFINED
	TAGS      = #()
	SEQS_LIST = #()
	STG_LIST  = #()
	STS_LIST  = #()
	STC_LIST  = #()
	BONE_LIST = #()
	IREF_LIST = #()
	INDICES_LIST  	= #()
	VERTEX_LIST 	= #()
	NORMALS_LIST 	= #()
	UVW_LIST 		= #()
	UVW_LIST2 		= #()
	SUBMESH_LIST 	= #()
	MESHMAT_LIST 	= #()
	MATM_LIST		= #()
	ATVL_LIST		= #()
	ATT_LIST 		= #()
	MAT_LIST        = #()
	SSGS_LIST		= #()
	WEIGHTBONE_LIST   = #()
    CAM_LIST  =#()
    PARTICLE_SYSTEMS = #()
	
    if( gFILETYPE ==".m3" ) then --> don't reset if this is a m3a (animation) file, it doesn't help :)
	(
		for m=1 to 24 do
		(
			meditMaterials[m] = Standardmaterial()
		)
	)
)


fn CreateAttachmentPt aName=
(
    theName = "SC2AttachPt001"

    ss = SplineShape pos:[0,0,0]
    ss.renderable = off
    ss.name = theName
    if( aName != undefined ) then ss.name = aName

    addNewSpline ss
    addKnot ss 1 #corner #curve [0,0,10]
    addKnot ss 1 #corner #curve [0,-4,0]
    close ss 1
    addNewSpline ss
    addKnot ss 2 #corner #curve [-4,0,0]
    addKnot ss 2 #corner #curve [4,0,0]
    addKnot ss 2 #corner #curve [0,0,10]
    close ss 2
    addNewSpline ss
    addKnot ss 3 #corner #curve [-4,0,0]
    addKnot ss 3 #corner #curve [0,-4,0]
    addKnot ss 3 #corner #curve [4,0,0]
    close ss 3
    ss.WireColor = yellow
    updateShape ss
    return ss
)

--unRegisterRedrawViewsCallback ShowAttachmentPtLabels
fn ShowAttachmentPtLabels=
(
--     gw.setTransform(Matrix3 1)
--     for o in objects where not o.isHidden and (classof o == SplineShape )  do
--     (
--         gw.text o.pos ("N: " + o.name) color:yellow

--     )
--     gw.enlargeUpdateRect #whole
--     gw.updateScreen()

)
--registerRedrawViewsCallback ShowAttachmentPtLabels


fn ReadFourCC stream =
(
	/* Read 4 bytes (chars) backwards -> this is the way Blizzards stores their TAGS */
	ret = ""
	for i=1 to 4 do ret = (bit.IntAsChar(ReadByte stream)) + ret
	return ret
)

fn SkipBytes stream nBytesToSkip=
(
	/* Skip n-bytes without reading them into memory */
	fseek stream nBytesToSkip #seek_cur
)

fn ReadFixedString stream val =
(
	/* Read n-length string */
	local str = ""

	for i=1 to val do
	(
		s= bit.IntAsChar(ReadByte stream)

		if ( s !="\0") then str+=s
	)
	return str

)

fn CreateLayer layerName =
(
	/* Create layer in MAX, if it exists, just return a reference to that layer */

	layer = LayerManager.GetLayerFromName layerName
	if(layer == undefined) then
	(
		layer = LayerManager.NewLayerFromName layerName
	)
	return layer
)

fn ReplaceAll str source destination =
(
	/* Look for 'source' in as string and replace it, I use this to replace forward slashes with backslaches in a path */
	while ( findstring str source !=undefined ) do
	(
		local pos = findstring str source
		local len = source.count
		str = replace str pos len destination
	)
	return str
)

fn ValidateTexture texture=
(
	/*
		If a model comes from Blizzard, it stores a reletive path to the texture, so I need to add the folder,
		if it is an exported model from max, it has an explicit path, so not folder needs to be added
	*/

	if(texture == undefined ) then return undefined
	if(texture == "" ) then return undefined

	--print ( replaceAll texture "/" "\\" )
    
	if(doesFileExist (ASSETS_FOLDER + texture) ) then return (ASSETS_FOLDER + texture)

	--print HEROES_ASSETS_FOLDER

	if(ASSETS_FOLDER == undefined) then ASSETS_FOLDER = ""

	local t = replaceAll (ASSETS_FOLDER + texture) "/" "\\"
	print ("[INFO] Looking for " + t )

	if(doesFileExist t) then return t

	t = replaceAll t "\\BAS_" "\\storm_"
	print t
	if(doesFileExist t) then return t

	print ("[WARNING] Texture was not found ! (" + t + ")")

	return undefined
)

fn Read4x4Matrix stream=
(
	/* Reads a 4x4 matrix, but Max only knows a 3x4 matrix, if it is called a matrix3, so skip the fourth float */

	-- reads 16 * 4 bytes = 64bytes
	row1 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
	 ReadFloat stream
	row2 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
	 ReadFloat stream
	row3 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
	 ReadFloat stream
	row4 = [ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor] -- Position
    
	 ReadFloat stream
	return ( inverse ( matrix3 row1 row2 row3 row4 ) )
)

fn ReadReference stream=
(
	/* This allow for easy coding, instead of typing these 3 lines each time, moves the stream forward by 12 bytes */
	local entries = ReadLong stream
	local tagIdx  = Readlong stream + 1
	local flag    = ReadLong stream

	return tagIdx
)

fn ReadCharTag stream tag=
(
	/* A char tag contains a set of characters that form a name, like a bone name */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local theName = ReadFixedString stream tag.NbrItems

	fSeek stream streamPosition #seek_set

	--print theName

	return theName
)

fn ReadLAYRTag stream tag=
(
	/* Reads a Layer tag, layer tags contain a reference to a texture */
	/* 464 bytes */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local size = 464
	local layr = HEROES_Layr()

	layr.Id = readLong stream
	readLong stream
	layr.TextureRefId = readLong stream

	readLong stream


	fSeek stream streamPosition #seek_set
	return layr
)

fn ReadU16_Tag stream tag=
(
	/* Read a set of unsigned shorts of 2 bytes */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values (ReadShort stream #unsigned)

	)
	fSeek stream streamPosition #seek_set

	return values
)

fn ReadI16_Tag stream tag=
(
	/* Read a set of Signed shorts of 2 bytes */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values (ReadShort stream #signed)

	)
	fSeek stream streamPosition #seek_set

	return values
)

fn ReadU32_Tag stream tag=
(
	/* Reads a set of unsigned integers (or longs) of 4 bytes each*/
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values (ReadLong stream #unsigned)

	)
	fSeek stream streamPosition #seek_set

	return values
)

fn ReadI32_Tag stream tag=
(
	/* Reads a set of signed integers (or longs) of 4 bytes each */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values (ReadLong stream #signed)
	)

	fSeek stream streamPosition #seek_set

	return values

)

fn ReadVEC2_Tag stream tag=
(
	/* Reads a set of 2 floats, resulting in a Vector 2 -> 2 floats per vector */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values [ReadFloat stream, ReadFloat stream]
	)

	fSeek stream streamPosition #seek_set

	return values
)

fn ReadVEC3_Tag stream tag=
(
	/* Reads a set of 3 floats, resulting in a Vector 3 -> 3 floats per vector, like position, rotation,  etc */

	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values ([ReadFloat stream, ReadFloat stream, ReadFloat stream])
	)

	fSeek stream streamPosition #seek_set

	return values
)

fn ReadREAL_Tag stream tag=
(
	/* Reads a set of floats, 1 floats per read, scale, etc */

	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values (ReadFloat stream)
	)

	fSeek stream streamPosition #seek_set

	return values
)

fn ReadQUAT_Tag stream tag=
(
	/* Reads a set of 4 floats, resulting in a Quaternian -> 4 floats per Quaternian, like rotation */

	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(
		append values ( quat (ReadFloat stream) (ReadFloat stream) (ReadFloat stream) (ReadFloat stream) )
	)

	fSeek stream streamPosition #seek_set

	return values
)

fn ReadSD_Tag stream tag=
(
	/* Read Sequence Definitions */
	/* 32 bytes per sd3v */

	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()

	for i=1 to tag.nbrItems do
	(
		local sd = HEROES_AnimData()
		local entries  = ReadLong stream
		local indx     = Readlong stream + 1
		local flag     = ReadLong stream

		sd.FrameList = TAGS[indx]
		sd.Flags = ReadLong stream
		sd.EndFrame = ReadLong stream

		entries  = ReadLong stream
		indx     = Readlong stream + 1
		flag     = ReadLong stream

		sd.Keys = TAGS[indx] --> this is a vec3 so this is probably the animated keys for the position?

		append values sd
	)
	fSeek stream streamPosition #seek_set

	return values
)

fn ReadBNDS_Tag stream tag=
(
	/* Read bounding boxes */
	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()
	for i=1 to tag.nbrItems do
	(

		local bb = HEROES_BoundBox()

		bb.MinValue = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
		bb.MaxValue = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
		bb.Radius   = ReadFloat stream

		append values bb
	)

	fSeek stream streamPosition #seek_set

	return values
)

/* 	SEQS - Animation sequences */
fn Read_SEQS stream idx=
(
	if( idx==0) then
	(
		return undefined
	)

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set
	size = 0
	if(tag.Flag == 1) then size = 96
	if(tag.Flag == 2) then size = 92

	startFrame = 50

    format "Animation sequences\n"
    
	for i=1 to tag.NbrItems do
	(

		local seqs = HEROES_SEQS()

		SkipBytes stream 8 --> FF FF FF FF  FF FF FF FF

		local tagIdx  = ReadReference stream
		seqs.Name = "Not Found " + i as string
		if(tagIdx <= TAGS.Count) then
		(
			if(TAGS[tagIdx].TagData != undefined) then seqs.Name = TAGS[tagIdx].TagData
		)
		seqs.StartFrame    = ReadLong stream --/ ( 1000.0 / framerate ) as integer
		seqs.endFrame 	   = ReadLong stream --/ ( 1000.0 / framerate ) as integer
		seqs.MovementSpeed = ReadLong stream
		seqs.Flags 		   = ReadLong stream
		seqs.NonLooping    = false

		if( (bit.and seqs.Flags 0x1) > 0 ) then seqs.NonLooping = True

		seqs.Frequency	   = ReadLong stream
		seqs.ReplayStart   = ReadLong stream
		seqs.ReplayEnd	   = ReadLong stream

		append SEQS_LIST seqs

		SkipBytes stream (size - 20 - 16 - 12 )

        format " - % ( frames: % - %)\n" seqs.Name seqs.StartFrame seqs.endFrame

    )

	--print SEQS_LIST
)

/* STG - Sequence transformation group */
fn Read_STG stream idx=
(
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	for i=1 to tag.NbrItems do
	(
		local stg = HEROES_STG()

		local tagIdx  = ReadReference stream
		stg.Name  = TAGS[tagIdx].TagData

		tagIdx  = ReadReference stream
		stg.STC_ids = TAGS[tagIdx].TagData --> zero based, so +1 is required!!

		append STG_LIST stg
	)

	--print STG_LIST

)
/* Read STS */
fn Read_STS stream idx=
(
	if( idx==0) then
	(
		return undefined
	)

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	for i=1 to tag.NbrItems do
	(
		local sts = HEROES_STS()

		local tagIdx  = ReadReference stream
		sts.AnimationsIds = TAGS[tagIdx].TagData

		SkipBytes stream (28 - 12 )

		append STS_LIST sts
	)
	--print STS_LIST
)

/* Read animation reference for Sequence Definitions */
fn ReadAnimRef stream tag=
(

	local streamPosition = fTell stream
	fSeek stream tag.Offset #seek_set

	local values = #()

	for i=1 to tag.nbrItems do
	(
		local ref = HEROES_AnimRef()
		ref.sd  = ReadShort stream #unsigned  +1
		ref.sdindx = ReadShort stream #unsigned  +1

		append values ref
	)
	fSeek stream streamPosition #seek_set

	return values

)

/* READ STC */
fn Read_STC stream idx=
(
	if( idx==0) then
	(
		return undefined
	)

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set
	size = 0
	if(tag.Flag == 4 ) then size = 204

	for i=1 to tag.NbrItems do
	(
		local stc = HEROES_STC()

		local tagIdx  = ReadReference stream
		stc.Name = TAGS[tagIdx].TagData

		stc.runsConcurrent = ReadShort stream
		stc.priority = ReadShort stream
		stc.stsIndex = ReadShort stream
		stsIndex = ReadShort stream

		local tagIdx  = ReadReference stream
		stc.AnimationIds = TAGS[tagIdx].TagData

		local tagIdx  = ReadReference stream

		stc.AnimationRefs = ReadAnimRef stream TAGS[tagIdx]

		SkipBytes stream 4

		stc.SDEV_data = TAGS[(ReadReference stream)].TagData
		stc.SD2V_data = TAGS[(ReadReference stream)].TagData
		stc.SD3V_data = TAGS[(ReadReference stream)].TagData
		stc.SD4Q_data = TAGS[(ReadReference stream)].TagData
		stc.SDCC_data = TAGS[(ReadReference stream)].TagData
		stc.SDR3_data = TAGS[(ReadReference stream)].TagData
		SkipBytes stream 12
		stc.SDS6_data = TAGS[(ReadReference stream)].TagData
		stc.SDU6_data = TAGS[(ReadReference stream)].TagData
		SkipBytes stream 12
		stc.SDU3_data = TAGS[(ReadReference stream)].TagData
		stc.SDFG_data = TAGS[(ReadReference stream)].TagData
		stc.SDMB_data = TAGS[(ReadReference stream)].TagData


		append STC_LIST stc
	)
	--print STC_List
)

/* READ MODEL */
fn Read_MODL stream idx=
(
	/*
		I only use this to get the correct index to the Vertices tag, since some models seem to have multiple tags for this...
		And for getting the list of skinned bones in the correct sequence
	*/

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	local modl = HEROES_MODL()

	modl.Name 	 = TAGS[ ReadReference stream].TagData --> MODL
    
    format "Original Max File Name: % \n" modl.Name
    
	flags 		 = ReadLong stream
	sequences    = TAGS[ ReadReference stream] 	--> SEQS
	seqTransColl = TAGS[ ReadReference stream] 	--> STC
	seqTransGrp  = TAGS[ ReadReference stream] 	--> STG

	SkipBytes stream 16
    
	seqTransSt   = TAGS[ ReadReference stream] 	--> STS
	bonestag	 = TAGS[ ReadReference stream]
	modl.nSkinBones 	 = ReadLong stream
	vFlags 		 = ReadLong stream
	modl.VerticesTAG = TAGS[ ReadReference stream]

	divisions	 = TAGS[ ReadReference stream]

	tmp = TAGS[ ReadReference stream]

	skinnedBonesZeroBased  = tmp.TagData

	local skinnedBones = #()
	try(


        if( skinnedBonesZeroBased != undefined ) then
        (
            for i=1 to skinnedBonesZeroBased.count do
            (
                local sb = skinnedBonesZeroBased[i] + 1
                append skinnedBones sb
            )

            BONE_LOOKUP = skinnedBones
        )
    )catch()

	SkipBytes stream (16 * 4 + 12)

    
	gMODL = modl

    /* hit test tight */
    if (bBuildHitTest == true ) then 
    (
        fseek stream 656 #seek_set
        local hitTestType = readLong stream
        skipBytes stream 4
        local hitTestParentBone = readLong stream --> points to the bone with the name HitTestTight
        
        gHitTestTight = HEROES_HitTestTight()
        gHitTestTight.parentBoneId = hitTestParentBone + 1
        
        /*
            0 = box
            1 = sphere
            2 = capsule
            ... = sphere + capsule -> only using capsule
        */
        
        format "Hit Test Type: % \nHit Test Parent Bone : %\n" hitTestType gHitTestTight.parentBoneId
        
        fseek stream 752 #seek_set
        
        local cap = undefined

        if ( hitTestType == 0 ) then /* BOX */
        (
            local width  = ( readFloat stream ) 
            local len    = ( readFloat stream ) 
            local height = ( readFloat stream ) 
            
            --format " - Box width:% len:% height:% " width len height 
            
            if( width < 0.0 and len > 0.0 and height > 0.0 ) then 
            (
                --print "Option 1"
                cap = capsule name:"HitTestTight2"
                cap.heighttype = 0

                cap.radius = len * gScaleFactor / 2.0
                cap.height = ( len + height * 2 ) * gScaleFactor / 2.0
            )

            if( width == 0.0 and len > 0.0 and height > 0.0 ) then 
            (
               -- print "Option 2"
                local hitTestRadius = len * gScaleFactor
                local hitTestHeight = height * gScaleFactor / 2.0
                cap = capsule radius:hitTestRadius height:hitTestHeight name:"HitTestTight"
                CenterPivot cap
            )
            
            
            if( width > 0.0 and len > 0.0 and height > 0.0 ) then 
            (
               -- print "Option 3"
                
                len = len * gScaleFactor * 2
                width = width * gScaleFactor * 2
                height = height * gScaleFactor * 2
                
                cap = box length:len width:width height:height name:"HitTestTight"
            )
        )
        
        if ( hitTestType == 1 ) then /* SPHERE */
        (
            local radius = ( readFloat stream ) * gScaleFactor
            
            if( radius > 0.0 ) then 
            (
                cap = sphere radius:radius name:"HitTestTight"
            )
        )
        
        if ( hitTestType == 2 ) then  /* CAPSULE */
        (
            
            local hitTestRadius = ( readFloat stream ) * gScaleFactor
            local hitTestHeight = ( readFloat stream ) * gScaleFactor  + 2 * hitTestRadius

            if hitTestRadius > 0.0 then 
            (
                cap = capsule radius:hitTestRadius height:hitTestHeight name:"HitTestTight"
            )
        )
        
        if ( hitTestType == 4 ) then  /* SPHERE + CAPSULE only in HOTS ??? */
        (
            fseek stream 788 #seek_set
            
            local r = readFloat stream 
            local h = readFloat stream 
            
            local hitTestRadius = r * gScaleFactor
            local hitTestHeight = ( h + r ) * gScaleFactor * 2

           if hitTestRadius > 0.0 then 
            (
                cap = capsule radius:hitTestRadius height:hitTestHeight name:"HitTestTight"
            )
        )
        
        if ( hitTestType == 8 ) then  
        (
            fseek stream 788 #seek_set
            
            local r = readFloat stream 
            local h = readFloat stream 
            
            local hitTestRadius = r * gScaleFactor
            local hitTestHeight = ( h + r ) * gScaleFactor

           if hitTestRadius > 0.0 then 
            (
                cap = capsule radius:hitTestRadius height:hitTestHeight name:"HitTestTight"
            )
        )
        
        /* make it Blizzard worthy */
        if( cap != undefined ) then
        (
            
            local hittestlayer = CreateLayer "HitTestTight"
            
            hittestlayer.AddNode cap
            
            cap.boxmode = on
            cap.renderable = off
            cap.showFrozenInGray = off
            cap.wirecolor = color 100 200 250
            freeze cap
        )
        

        
        gHitTestTight.hitTestModel = cap
        
    )
)

/* READ BONES */
fn Read_BONE stream idx=
(
	/*
		THis is probably the most importent set of data, except for the meshes
		This also contains the reference to the names of lights, vol_target, hit test, meshes etc..

	TODO:
		1. make use of all the properties of the bones
		2. figure out how the (sub)mesh links to the bone that holds the name of the mesh

	*/
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	nBones = tag.NbrItems
	size = 0
	if( tag.Flag == 1) then size = 160

	for i=1 to nBones do
	(
		local b = HEROES_BONE()

		SkipBytes stream 4
		b.Id = i
		b.Name=  TAGS[ ReadReference stream ].TagData

              
        if b.Name == "HitTestTight" then b.Name = "HitTestTight_bone"
        
		/* Only using 2 properties, isAnimated & Skinned */
		local flags = ReadLong stream
		if( bit.and flags 0x1 > 0 ) 	then b.InheritTranslation = true
		if( bit.and flags 0x2 > 0 ) 	then b.InheritScale = true
		if( bit.and flags 0x4 > 0 ) 	then b.InheritRotation = true
		if( bit.and flags 0x10 > 0 ) 	then b.Billboard1 = true
		if( bit.and flags 0x40 > 0 ) 	then b.Billboard2 = true
		if( bit.and flags 0x100 > 0 ) 	then b.twoDProjection = true
		if( bit.and flags 0x200 > 0 ) 	then b.IsAnimated = true
		if( bit.and flags 0x400 > 0 ) 	then b.InverseKinematics = true
		if( bit.and flags 0x800 > 0 ) 	then b.Skinned = true
		if( bit.and flags 0x2000 > 0 ) 	then b.Real = true

		b.ParentBoneId = (ReadShort stream #signed) + 1

		SkipBytes stream 2

		local posAnimRef = HEROES_BoneAnimRef()
		posAnimRef.InterpolationType =  ReadShort stream #signed
		posAnimRef.animFlags =  ReadShort stream #signed
		posAnimRef.AnimId =  ReadLong stream #signed

		b.AnimRefPosition = posAnimRef

		b.Position 	= [ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor]
        nullPos 	= [ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor]
       
		SkipBytes stream 4

		local rotAnimRef = HEROES_BoneAnimRef()
		rotAnimRef.InterpolationType =  ReadShort stream #signed
		rotAnimRef.animFlags =  ReadShort stream #signed
		rotAnimRef.AnimId =  ReadLong stream #signed

		b.AnimRefRotation = rotAnimRef

		b.Rotation 		= quat (ReadFloat stream) (ReadFloat stream) (ReadFloat stream) (ReadFloat stream)
		nullRotation 	= quat (ReadFloat stream) (ReadFloat stream) (ReadFloat stream) (ReadFloat stream)

		SkipBytes stream 4

		local scaleAnimRef = HEROES_BoneAnimRef()
		scaleAnimRef.InterpolationType =  ReadShort stream #signed
		scaleAnimRef.animFlags =  ReadShort stream #signed
		scaleAnimRef.AnimId =  ReadLong stream #signed

		b.AnimRefScale = scaleAnimRef

		b.Scale 		= [(ReadFloat stream) , (ReadFloat stream) , (ReadFloat stream)]
		nullScale 	    = [(ReadFloat stream) , (ReadFloat stream) , (ReadFloat stream)]

		SkipBytes stream 4

		local animRef = HEROES_BoneAnimRef()
		animRef.InterpolationType =  ReadShort stream #signed
		animRef.animFlags =  ReadShort stream #signed
		animRef.AnimId =  ReadLong stream #signed

		b.AnimRefAnim = animRef

		b.AnimRef 	  = ReadLong stream #unsigned
		NullAnimRef   = ReadLong stream #unsigned

		SkipBytes stream 4

		append BONE_LIST b
	)
	--print BONE_LIST
)

/* READ IREF */
fn Read_IREF stream idx=
(
	/*
		This contains the binding position of the bones and the mesh, this can be differenct from the original bone pose,
		if this is the case, it is nearly impossible to skin the model, so we need this binding pose
	*/
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	for b=1 to tag.NbrItems do
	(
		local iref = HEROES_IREF()

		row1 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
		SkipBytes stream 4

		row2 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
		SkipBytes stream 4

		row3 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
		SkipBytes stream 4

		row4 = [ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor, ReadFloat stream * gScaleFactor] -- Position
		SkipBytes stream 4

		iref.Matrix = inverse ( matrix3 row1 row2 row3 row4 )

		append IREF_LIST iref

	)
	--print IREF_LIST


)

/* Read Indices */
fn Read_DIV stream idx=
(
	/* List of triangle definitions */
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	if(tag.flag == 2) then size = 52

	for i=1 to tag.NbrItems do
	(
		local faces = TAGS[ ReadReference stream ].TagData
		if(faces == undefined) then return undefined
		for f=1 to faces.Count do
		(

			append INDICES_LIST ( faces[f] + 1 )

		)
		SkipBytes stream (size - 12)
	)
	--print INDICES_LIST
)

/* Read Vertices, weights, normals and uvs*/
fn Read_VERT stream idx=
(
	/*
		Noticed that some models where not unwrapped, which is wrong, they are just unwrapped in a different uv channel,
		some type of models use only the second uv set, these are marked with useUVSet2, but the list is far from correct
		if a model is ever not correctly unwrapped, this probably means that the flag needs to be added or changed to use the 2nd set of uv mapping
	*/
	if( idx==0) then ( return undefined	)

	local tag = gMODL.VerticesTAG
	--print tag
	fseek stream 128 #seek_set

	flag = 0
	chunkSize = 32
	flag = ReadLong stream #unsigned
	useUVSet2 = false

    /* calculate full chunkSize */
    -- bit 10
    if ( bit.and flag 0x200 ) > 0 then 
    ( 
        chunkSize = chunkSize + 4     
        useUVSet2 = true        
    )
    -- bit 19
    if ( bit.and flag 0x40000 ) > 0 then  chunkSize = chunkSize + 4 
    -- bit 20
    if ( bit.and flag 0x80000 ) > 0 then  chunkSize = chunkSize + 4 
    -- bit 21
    if ( bit.and flag 0x100000 ) > 0 then  chunkSize = chunkSize + 4 
    -- bit 22
    if ( bit.and flag 0x200000 ) > 0 then  chunkSize = chunkSize + 4 
    -- bit 23
    if ( bit.and flag 0x400000 ) > 0 then  chunkSize = chunkSize + 4 
    -- bit 31
    if ( bit.and flag 0x40000000 ) > 0 then chunkSize = chunkSize + 4 
    
    nVerts = tag.nbrItems / chunkSize

	fSeek stream tag.OffSet #seek_set

    --format "Reading uvw data\n- flag: %\n- chunksize: %\n- uvcorrection: %\n" flag chunkSize uvCorrection
    local maxU = 0
    local maxV = 0
    local minU = 0
    local minV = 0
    
	for v=1 to nVerts do
	(
		x1 = ReadFloat stream * gScaleFactor
		y1 = ReadFloat stream * gScaleFactor
		z1 = ReadFloat stream * gScaleFactor

		append VERTEX_LIST [ x1, y1, z1 ]

		-- BoneWeights 4b
		tmpWeights  =  [Readbyte stream  #unsigned, Readbyte stream  #unsigned, Readbyte stream  #unsigned, Readbyte stream  #unsigned]
		tmpBoneIndexes =  [Readbyte stream  #unsigned, Readbyte stream  #unsigned, Readbyte stream  #unsigned, Readbyte stream  #unsigned]

		local wb = HEROES_WEIGHTBONE()
		wb.Weights = #()
		wb.BoneIndexes = #()

		for w=1 to 4 do
		(
			local lWeight = tmpWeights[w]
			local lBoneIndex = tmpBoneIndexes[w]

			if( lWeight > 0 ) then
			(
				local decompressedWeight = lWeight / 255.0
				local correctedBoneId = (lBoneIndex + 1) as integer

				append wb.Weights decompressedWeight
				append wb.BoneIndexes correctedBoneId
			)

		)
		append WEIGHTBONE_LIST wb

		-- Vertex Normals 3b
		x4 = (((ReadByte stream #unsigned ) /255.0) * 2 ) - 1
		y4 = (((ReadByte stream #unsigned ) /255.0) * 2 ) - 1
		z4 = (((ReadByte stream #unsigned ) /255.0) * 2 ) - 1

		append NORMALS_LIST [ x4, y4, z4]

		ReadByte stream #unsigned --1b

        uShort = ReadShort stream #signed
        vShort = ReadShort stream #signed
        	
		append UVW_LIST [uShort,vShort,0.0] 

		if( chunkSize >=36) then
		(
			u6 = (ReadShort stream #signed ) 
			v6 = (ReadShort stream #signed ) 
			                        
			append UVW_LIST2 [ u6,v6,0.0] 

			SkipBytes stream (chunkSize - 32)
		)
		else
		(
            SkipBytes stream (chunkSize - 28)
		)

	)
    
	if(useUVSet2) then
	(
        local dummyUVW = UVW_LIST
        
		UVW_LIST = UVW_LIST2
		
        UVW_LIST2 = dummyUVW
        print "[WARNING] Swapped to UV set 2!!"
	)
    

    
)

/* Read Submeshes*/
fn Read_REGN stream idx=
(
	/*
		Very weird that the new version has an addition 4 bytes to be skipped since they are not used :/
	*/

	if( idx==0) then ( return undefined	)

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set
	subMeshSize = 0

	nSubmeshes = tag.NbrItems

	if( tag.Flag == 3 ) then subMeshSize = 36
	if( tag.Flag == 4 ) then subMeshSize = 40
    if( tag.Flag == 5 ) then subMeshSize = 48 --> bugfix as of beta release 35360

	--print tag.Flag

	for s=1 to nSubmeshes do
	(
		local submesh = HEROES_SUBMESH()
		local skip = subMeshSize

		SkipBytes stream 4
        
		skip -=4

		if( TAGS[1].name == "MD34") then --> MD34
		(
            print(ftell stream)
			SkipBytes stream 4
            
            submesh.firstVertex = (ReadLong stream #unsigned) as integer
			submesh.nVerts = (ReadLong stream #unsigned) as integer
			skip -=12
		)
		else --> MD33
		(
			submesh.firstVertex = (ReadShort stream #unsigned) as integer
			submesh.nVerts = (ReadShort stream #unsigned) as integer
			skip -=8
		)

		submesh.firstIndex = (ReadLong stream #unsigned) as integer
		submesh.nIndices = (ReadLong stream #unsigned) as integer
		skip -=8
		subMesh.nBones = (ReadShort stream #unsigned) as integer
		skip -=2
		subMesh.firstBoneLookup =  ((ReadShort stream #unsigned) as integer )
		subMesh.nBoneLookup =  ((ReadShort stream #unsigned) as integer )
		skip -=4
		submesh.UvScale = ReadShort stream        
        skip -=2
		subMesh.nBoneWeightPairs = ReadByte stream #unsigned
		Readbyte stream
        subMesh.RootBoneId = ReadShort stream
		skip -=4
        
        SkipBytes stream skip
        
        -- format "Skipping %\n" skip
        
        format "UV Scale ? % \n" submesh.UvScale

        local submeshname = "Mesh "
        
        if( gMODL.name != undefined ) then 
            submeshname = (getfilenamefile gMODL.name) + " "
        
		submesh.Name = submeshname + (s as string)

		append SUBMESH_LIST submesh
	)
	--print SUBMESH_LIST
	--print BONE_LIST
)


/* Read mesh matching material */
fn Read_BAT stream idx=
(
	/*
		List of the meshes with the reference to their material
	*/
	if( idx==0) then ( return undefined	)

	local tag = TAGS[idx]

	fseek stream tag.Offset #seek_set

	for b=1 to tag.nbrItems do
	(
		local mshMat = HEROES_MESHMAT()
		SkipBytes stream 4
		mshMat.MeshId = ReadShort stream +1
		SkipBytes stream 4
		mshMat.MatId = ReadShort stream +1
		SkipBytes stream 2
		append MESHMAT_LIST mshMat
	)
	--print MESHMAT_LIST

)

/* READ Material */
fn Read_MATM stream idx=
(
	/*
		Simple list that tells us what type of material is used, currently I only support standard materials (SC2Standard)
	*/

	if( idx==0) then ( return undefined	)

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	/*
		1	standard
		2	displacement
		3	composite
		4	terrain
		5	volume
		6   NOT USED
		7	creep
		8	noise
		9	splat
	*/

	for i=1 to tag.NbrItems do
	(
		local matm = HEROES_MATM()
		matm.materialType = ReadLong stream
		matm.materialIndex = ReadLong stream +1

		append MATM_LIST matm

	)
	--print MATM_LIST
)


/* Read and build the lights */
fn Read_LITE stream idx=
(
    if (bUseSC2ArtTools == false) then return undefined
    
	/*
		Wild guess on importing lights, this is done on the fly, why, because StarTools already has a light structure,
		no need to re-declare it, just use the SC2OmniLight struct or the SC2SpotLight struct
	*/
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set
	--print tag
	lightLayer = CreateLayer "Lights"

	if( tag.flag == 7 ) then size = 224
	skip = 0
	try
	(
		for i=1 to tag.NbrItems do
		(
			local l = undefined
			local lightType = ReadShort stream
			if( lightType == 1 ) then l = SC2OmniLight()
			if( lightType == 2 ) then
			(
				l = SC2SpotLight()
				l.target = Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
			)

			local boneIndex = ReadShort stream + 1
			l.name = BONE_LIST[boneIndex].Name
			l.pos = BONE_LIST[boneIndex].Position
			--l.rotation = BONE_LIST[boneIndex].Rotation

			l.Parent = BONE_LIST[boneIndex].TheBone


			local flags = ReadLong stream

			if( bit.and flags 0x1 > 0) then l.shadowCast = on
			if( bit.and flags 0x2 > 0) then l.Specular = on
			if( bit.and flags 0x4 > 0) then l.affectedByAO = on
			if( bit.and flags 0x8 > 0) then l.lightOpaqueObjects = on

			SkipBytes stream 8
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			r = ReadFloat stream * 255
			g = ReadFloat stream * 255
			b = ReadFloat stream * 255
			l.diffuseColor = color r g b

			SkipBytes stream 16
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			l.intensity = ReadFloat stream --> multiplier
			SkipBytes stream 8
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			r = ReadFloat stream * 255
			g = ReadFloat stream * 255
			b = ReadFloat stream * 255
			l.specularcolor = color r g b

			SkipBytes stream 16
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			l.specularMultiplier = ReadFloat stream

			SkipBytes stream 8
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			l.decay = ReadFloat stream * gScaleFactor as integer

			SkipBytes stream 12
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			l.attenStart = ReadFloat stream * gScaleFactor as integer

			SkipBytes stream 8
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			if( lightType == 2 ) then l.hotspot = readfloat stream * 57.2958

			SkipBytes stream 8
			SkipBytes stream 8 --> interpolation animation stuff, skip for now

			if( lightType == 2 ) then l.falloff = readfloat stream * 57.2958

			lightLayer.AddNode l

			SkipBytes stream 20

			BONE_LIST[boneIndex].TheBone.name = BONE_LIST[boneIndex].name + "_BoneRef"
			--print l
		)
	) catch()

)

/* Read Volume Target */
fn Read_ATVL stream idx=
(
	/*
		Vol_Target creation, weird use, probably the sizes are set from the center,
		this will eventually be colored red, frozen and displayed as a box,
		exactly as the SC2ArtTools menu does when clicking the Display -> collapse helpers
	*/

	if( idx==0) then ( return undefined	)

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	multiplierLength = gScaleFactor
	for v=1 to tag.NbrItems do
	(
		local volTarget = HEROES_VOLTARGET()

		volTarget.bone0 = ReadLong stream + 1
		volTarget.bone1 = ReadLong stream
		volTarget.type =  ReadLong stream --> 0 Cube, 1 Sphere, 2 Capsule
		volTarget.bone2 = ReadLong stream
		-- 16bytes

		volTarget.matrix = Read4x4Matrix stream --> 64 bytes --> transformation matrix

		SkipBytes stream 24

		if(volTarget.type == 0 )/* Cube */ then multiplierLength = 200

		volTarget.size0 = ReadFloat stream * multiplierLength --> Radius or X size
		volTarget.size1 = ReadFloat stream * multiplierLength --> Height or Y size
		volTarget.size2 = ReadFloat stream * multiplierLength --> unused or Z size
		-- 12 bytes



		append ATVL_LIST volTarget
	)
	--print ATVL_LIST
)

/* Read Hit Test */
fn Read_SSGS stream idx=
(
	/*
		HitTestFuzzy is defined here, name comes from the bone list reference,
		this will eventually be colored blue, frozen and set to display as a box,
		exactly like the SC2ArtTools menu does -> display -> collapse helpers
	*/

	if( idx == 0 ) then ( return undefined )

	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	multiplierLength = gScaleFactor

	for v=1 to tag.NbrItems do
	(
		local hitTest = HEROES_HITTEST()

		hitTest.type   = ReadLong stream --> 0 Cube, 1 Sphere, 2 Capsule, 3 Cylinder
		hitTest.boneId = ReadShort stream #signed +1

		SkipBytes stream 2
		-- 8bytes

		hitTest.matrix = Read4x4Matrix stream --> 64 bytes --> transformation matrix

		SkipBytes stream 24

		hitTest.size0 = ReadFloat stream * multiplierLength --> Radius or X size
		hitTest.size1 = ReadFloat stream * multiplierLength --> Height or Y size
		hitTest.size2 = ReadFloat stream * multiplierLength --> unused or Z size
		-- 12 bytes

		append SSGS_LIST hitTest
	)
	--print SSGS_LIST
)

/* Read the attachments */
fn Read_ATT stream idx=
(
	/* 20 bytes */
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.Offset #seek_set

	for i=1 to tag.NbrItems do
	(
		local att = HEROES_ATT()
		SkipBytes stream 4
		att.Name = TAGS[ReadReference stream].TagData
		att.ParentId = ReadLong stream +1 --> link it to the appropriate bone


		append ATT_LIST att
	)
	--print ATT_LIST


)
fn Read_MAT_NONSC2 stream idx=
(
	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.OffSet #seek_set

	local size = 280
	/*
		15 size=268
		16 size=280
		17 size=280
		18 size=280
		19 size= 340 --> new since beta
	*/

	if( tag.Flag == 15) then size = 268
	if( tag.Flag == 19) then size = 340
    if( tag.Flag == 20) then size = 352 
    
	nbrMaterials = tag.NbrItems

	for m=1 to nbrMaterials do
	(
		local mat = HEROES_NONSC2_MAT() -- HEROES_Mat()

		local len = readlong stream
		local idx = readlong stream +1
		local flg = readlong stream

		mat.Name = tags[idx].TagData

        local flagA = readlong stream
        local flagB = readlong stream
        
        local blendMode = readlong stream
        local prio = readlong stream
        local useRTTChannels = readlong stream
        local specularity = readlong stream
        local depthBlendFallOff = readlong stream
        depthBlendFallOff = 0.0
        local cutOutTreshold = readlong stream
        local specMultiplier = readfloat stream
        local emisMultiplier = readfloat stream

        /* Assign the texture to the material */
        local Diff_Map     = undefined
        local Norm_Map     = undefined
        local Height_Map   = undefined
        local Decal_Map    = undefined
        local Spec_Map     = undefined
        local Emis_Map     = undefined
        local Emis2_Map    = undefined
        local Env_Map      = undefined
        local Envio_Map    = undefined
        local Alpha_Map    = undefined
        local Alpha2_Map   = undefined
        local Light_Map    = undefined


        if(tag.Flag == 20) then SkipBytes stream 12

        for l=1 to 13 do
		(
			len = readlong stream
			ind = readlong stream +1
			flg = readlong stream

            if(tags[ind].TagData.TextureRefId > 0) then
			(
				textureIdx = tags[ind].TagData.TextureRefId + 1

                if (l==1)  then Diff_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==11) then Norm_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==12) then Height_Map  = ValidateTexture tags[textureIdx].TagData
                if (l==2)  then Decal_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==3)  then Spec_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==4)  then Glos_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==5)  then Emis_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==6)  then Emis2_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==7)  then Env_Map     = ValidateTexture tags[textureIdx].TagData
                if (l==8)  then Envio_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==9)  then Alpha_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==10) then Alpha2_Map  = ValidateTexture tags[textureIdx].TagData
                if (l==13) then Light_Map   = ValidateTexture tags[textureIdx].TagData

            )
		)


        if( Diff_Map    != undefined ) then  mat.Diff_Map       =   Diff_Map
        if( Norm_Map    != undefined ) then  mat.Norm_Map       =   Norm_Map
        if( Height_Map  != undefined ) then  mat.Height_Map 	=   Height_Map
        if( Decal_Map   != undefined ) then  mat.Decal_Map 		=   Decal_Map
        if( Spec_Map    != undefined ) then  mat.Spec_Map 		=   Spec_Map
        if( Emis_Map    != undefined ) then  mat.Emis_Map 	    =   Emis_Map
        if( Emis2_Map   != undefined ) then  mat.Emis2_Map 	    =   Emis2_Map
        if( Env_Map     != undefined ) then  mat.Env_Map 		=   Env_Map
        if( Envio_Map   != undefined ) then  mat.Envio_Map 	    =   Envio_Map
        if( Alpha_Map   != undefined ) then  mat.Alpha_Map	    =   Alpha_Map
        if( Alpha2_Map  != undefined ) then  mat.Alpha2_Map 	=   Alpha2_Map
        if( Light_Map   != undefined ) then  mat.Light_Map		=   Light_Map

		if( tag.Flag == 20 ) then 
            SkipBytes stream ( size - 220 )
        else
            SkipBytes stream ( size - 208 )

		append MAT_LIST mat

	)

	 print MAT_LIST




)

/* Read the Materials */
fn Read_MAT stream idx=
(
	/*
		Read the material properties
		TODO:
           USE if ( bUseSC2ArtTools == true ) then
	*/

    if (gFILETYPE == ".m3a") then return undefined
    
    if( bUseSC2ArtTools == false ) then
    (
        Read_MAT_NONSC2 stream idx
        return undefined

    )

	if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.OffSet #seek_set

	local size = 280
	/*
		15 size=268
		16 size=280
		17 size=280
		18 size=280
		19 size=340 --> new since beta
        20 size=352 --> new since EX3
	*/

	if( tag.Flag == 15) then size = 268
	if( tag.Flag == 19) then size = 340
    if( tag.Flag == 20) then size = 352    
    
	nbrMaterials = tag.NbrItems

    format "Reading Starcraft II materials\n"
    
	for m=1 to nbrMaterials do
	(
		local mat = SC2_Standard_Material() -- HEROES_Mat()

		local len = readlong stream
		local idx = readlong stream +1
		local flg = readlong stream

		mat.Name = tags[idx].TagData

        local flagA = readlong stream
        local flagB = readlong stream

        /* Passes */
        if( bit.get flagB 32 == false )  then mat.MainPass = on --> Draw Geometry -- never set this off, it is just weird
        if( bit.get flagB 15 == false )  then mat.CastTransparentShadows = on
        if( bit.get flagB 6 )   then mat.castShadows = off
        if( bit.get flagB 9 )   then mat.TranslucencyDepthWrite = on --> Z Fill Pass

        /* Material Basic Parameters*/
        if( bit.get flagB 1 )  then (
            mat.VtxColor = on
            mat.ExpVtxRGBA = on
        )
        if( bit.get flagB 2 ) then (
            mat.VtxAlpha = on
            mat.ExpVtxRGBA = on
        )
        if( bit.get flagB 4 )  then mat.twoSided = on
        if( bit.get flagB 5 )  then mat.Unlit = on
        if( bit.get flagB 14 ) then mat.DepthFog = on
        if( bit.get flagB 19 ) then mat.DisableSoftBlend = on
        if( bit.get flagB 20 ) then mat.ForceDoubleLambertShading = on
        if( bit.get flagB 22 ) then mat.AcceptSplats = on
        if( bit.get flagB 26 ) then mat.OnlyAcceptSplats = on

        /* Misc */
        if( bit.get flagB 16 ) then mat.DecalLighting = on
        if( bit.get flagB 17 ) then mat.TransaprencyAffectsDOF = on
        if( bit.get flagB 18 ) then mat.TransparencyLocalLights = on
        if( bit.get flagB 21 ) then mat.HairSorting = on
        if( bit.get flagB 30 ) then mat.NoHighlights = on
        if( bit.get flagB 27 ) then mat.BackgroundObject = on
        if( bit.get flagB 31 ) then mat.ClampOutput = on

        /* Compatibility */
        if( bit.get flagB 23 ) then mat.RequiresDecal = on
        if( bit.get flagB 24 ) then mat.RequiresEmissive = on
        if( bit.get flagB 25 ) then mat.RequiresSpecular = on
        if( bit.get flagB 29 ) then mat.RequiresZFill = on


        local blendMode = readlong stream
        local prio = readlong stream
        local useRTTChannels = readlong stream
        local specularity = readlong stream
        local depthBlendFallOff = readlong stream
        local cutOutTreshold = readlong stream
        local specMultiplier = readfloat stream
        local emisMultiplier = readfloat stream

        mat.Priority = prio
        mat.depthBlendFallOff = depthBlendFallOff
        mat.HDRSpecularMul = specMultiplier
        mat.HDREmissiveMul = emisMultiplier



		--SkipBytes stream 20
		/*
			1. Diffuse
			2. Decal
			3. Specular
			4. Gloss
			5. Emissive
			6. Emissive 2
			7. Environment
			8. EnvioMap
			9. Alpha Mask
			10. Alpha Mask 2
			11. Normal Map
			12. Height Map
			13. Light Map
		*/


        /* Assign the texture to the material */
        local Diff_Map     = undefined
        local Norm_Map     = undefined
        local Height_Map   = undefined
        local Decal_Map    = undefined
        local Spec_Map     = undefined
        local Emis_Map     = undefined
        local Emis2_Map    = undefined
        local Env_Map      = undefined
        local Envio_Map    = undefined
        local Alpha_Map    = undefined
        local Alpha2_Map   = undefined
        local Light_Map    = undefined


        if(tag.Flag == 20) then SkipBytes stream 12

        for l=1 to 13 do
		(
			len = readlong stream
			ind = readlong stream +1
			flg = readlong stream

            if(tags[ind].TagData.TextureRefId > 0) then
			(
				textureIdx = tags[ind].TagData.TextureRefId + 1

                if (l==1)  then Diff_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==11) then Norm_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==12) then Height_Map  = ValidateTexture tags[textureIdx].TagData
                if (l==2)  then Decal_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==3)  then Spec_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==4)  then Glos_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==5)  then Emis_Map    = ValidateTexture tags[textureIdx].TagData
                if (l==6)  then Emis2_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==7)  then Env_Map     = ValidateTexture tags[textureIdx].TagData
                if (l==8)  then Envio_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==9)  then Alpha_Map   = ValidateTexture tags[textureIdx].TagData
                if (l==10) then Alpha2_Map  = ValidateTexture tags[textureIdx].TagData
                if (l==13) then Light_Map   = ValidateTexture tags[textureIdx].TagData

            )
            format "Diff_Map   %\n" Diff_Map    
            format "Norm_Map   %\n" Norm_Map    
            format "Height_Map %\n" Height_Map  
            format "Decal_Map  %\n" Decal_Map   
            format "Spec_Map   %\n" Spec_Map    
            format "Emis_Map   %\n" Emis_Map    
            format "Emis2_Map  %\n" Emis2_Map   
            format "Env_Map    %\n" Env_Map     
            format "Envio_Map  %\n" Envio_Map   
            format "Alpha_Map  %\n" Alpha_Map   
            format "Alpha2_Map %\n" Alpha2_Map  
            format "Light_Map  %\n" Light_Map   
		)


        if( Diff_Map    != undefined ) then  
        (
            mat.Diffuse.fileName         	=   Diff_Map
            mat.Diffuse.ColorChannels = 0 --> set to USE RGB
        )
        if( Norm_Map    != undefined ) then  mat.NormalMap.fileName       	=   Norm_Map
        if( Height_Map  != undefined ) then  mat.HeightMap.fileName 	    =   Height_Map
        if( Decal_Map   != undefined ) then  mat.Decal.fileName 		    =   Decal_Map
        if( Spec_Map    != undefined ) then  
        (
            mat.Gloss.fileName 		    =   Spec_Map
            mat.Gloss.ColorChannels = 0 --> set to USE RGB
        )
        if( Emis_Map    != undefined ) then  mat.Emissive1.fileName 	    =   Emis_Map
        if( Emis2_Map   != undefined ) then  mat.Emissive2.fileName 	    =   Emis2_Map
        if( Env_Map     != undefined ) then 
        (
            mat.Environment.fileName 		=   Env_Map
            mat.Environment.ColorChannels = 0
            mat.Environment.UVMapping = 2
            
        )
        if( Envio_Map   != undefined ) then  
        (
--             format "Envio map:%\n" Envio_Map
--             format "mat: %\n" mat
--             format "env mask :%\n" mat.EnvironmentMask
            mat.EnvironmentMask.fileName 	=   Envio_Map
            mat.EnvironmentMask.ColorChannels = 2
            --mat.EnvironmentMask.alphasource = 0
            --mat.EnvironmentMask.rgbOutput = 1   
        )
        if( Alpha_Map   != undefined ) then  mat.AlphaMask.fileName 	    =   Alpha_Map
        if( Alpha2_Map  != undefined ) then  mat.AlphaMask2.fileName 	    =   Alpha2_Map
        if( Light_Map   != undefined ) then  mat.Lightmap.fileName			=   Light_Map

        if( Decal_Map   != undefined ) then
        (
            mat.Decal.ColorChannels = 3 --> R channel
            mat.Decal.UVMapping = 1  --> Explicit UV 2
            
        )
        

        if( Envio_Map != undefined ) then
        (
            mat.MatSubType = 2 --> Environment
            mat.Environment.UVMapping = 6
        )

        if( Alpha_Map != undefined ) then
        (
            mat.MatSubType = 3 --> Mask
            mat.AlphaTestThreshold = 16

            if( Emis_Map != undefined ) then
            (
                mat.EmissiveBlendOp1 = 3
            )
        )

        if( tag.Flag == 20 ) then 
            SkipBytes stream ( size - 220 )
        else
            SkipBytes stream ( size - 208 )

		append MAT_LIST mat

        -- format "- %\n" mat.Name
        
        if( m <25 ) then meditMaterials[m] = mat
        try(
            if( mat.Diffuse.fileName != "") then 
            (
                showTextureMap mat mat.Diffuse true
            )
            if( mat.Diffuse.fileName == "" ) then
            (
                if (mat.AlphaMask.fileName != undefined ) then showTextureMap mat mat.AlphaMask true
            )
        ) catch ()


	)

)


fn Read_CAM stream idx=
(
    if( idx==0) then
	(
		return undefined
	)
	local tag = TAGS[idx]
	fseek stream tag.OffSet #seek_set
    local camLayer = CreateLayer "Camera"

    /* 180 bytes for 1 camera */
    for c=1 to tag.nbrItems do
    (

        local boneIndex = ReadLong stream + 1
        local cam = undefined
        
        if(bUseSC2ArtTools ) then 
            cam = SC2Camera()
        else
            cam = FreeCamera()

        cam.name = BONE_LIST[boneIndex].Name
        BONE_LIST[boneIndex].Name = BONE_LIST[boneIndex].Name + "_boneRef"
        cam.rotation = BONE_LIST[boneIndex].Rotation
        cam.position = BONE_LIST[boneIndex].Position

        i = ReadReference stream

        SkipBytes stream 8
        cam.fov = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 8
        useVertFOV = readlong stream
        if(bUseSC2ArtTools ) then
            if( useVertFOV == 1 ) then cam.useVertFOV = on else cam.useVertFOV = off
        SkipBytes stream 8
        cam.farclip = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 16
        cam.nearClip = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 16
        if(bUseSC2ArtTools ) then cam.shadowClipDistance = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 16
        if(bUseSC2ArtTools ) then cam.focusDistance = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 16
        if(bUseSC2ArtTools ) then cam.fullFocusRange = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 16
        if(bUseSC2ArtTools ) then cam.noFocusRange = ( readfloat stream ) * gScaleFactor
        SkipBytes stream 16
        if(bUseSC2ArtTools ) then cam.dofAmount = ( readfloat stream )
        SkipBytes stream 8

        camLayer.AddNode cam

        ref = HEROES_CAMERA()
        ref.CamRef = cam
        ref.BoneRefId = boneIndex

        append CAM_LIST ref

    )
   -- print CAM_LIST
)


/**************************************************************************************************************************/
/*  BUILD THE STUFF */
/**************************************************************************************************************************/
fn Build_Camera =
(
    for i=1 to CAM_LIST.Count do
    (
        print BONE_LIST[CAM_LIST[i].BoneRefId].theBone

        CAM_LIST[i].CamRef.Rotation = BONE_LIST[CAM_LIST[i].BoneRefId].theBone.Rotation
        CAM_LIST[i].CamRef.Position = BONE_LIST[CAM_LIST[i].BoneRefId].theBone.Position
    )
)

/* BUILD BONES */
fn Build_Bones =
(
	/*
		Build the bone structure and the bind pose, supports the creation of bones from m3a files
	*/

	format "BUILDING BONES...\n"

	if(BONE_LIST == undefined) then return undefined
	nBones = BONE_LIST.count
	/* Put the bones in a layer */
	boneLayer = CreateLayer "Bones"
	animBoneLayer = CreateLayer "Animated Bones"

	/* Create the bones */
	for b=1 to nBones do
	(
		/* Check if the bone already exist */
		local boneExists = false
		for obj in objects do
		(
			if(classof obj == BoneGeometry and obj.Name == BONE_LIST[b].Name ) then
			(
				BONE_LIST[b].TheBone = obj
				boneExists = true
				--print ("Bone found : " + obj.Name )
			)

		)
		if(boneExists == false ) then
		(

			local aBone = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
			aBone.Name = BONE_LIST[b].Name
			
			aBone.ShowLinks = true

			aBone.Width = 0.05
			aBone.Height = 0.05

			BONE_LIST[b].TheBone = aBone

			boneLayer.AddNode aBone
		)

	)
	if(BONE_LOOKUP != undefined) then
	(
		for b=1 to BONE_LOOKUP.count do
		(
			if( BONE_LOOKUP[b] <= BONE_LIST.Count) then
			(
				local aBone = BONE_LIST[BONE_LOOKUP[b]].TheBone
                if( aBone != undefined) then animBoneLayer.AddNode aBone
			)
		)
	)

	/* Build the bone Hierarchy */
	if( gFILETYPE == ".m3") then
	(
		for b=1 to nBones do
		(


			if(BONE_LIST[b].ParentBoneId != 0) then
			(
				parentBone = BONE_LIST[ BONE_LIST[b].ParentBoneId ].TheBone
				if(parentBone != undefined and BONE_LIST[b].TheBone != undefined ) then
				(
                    try (
                        if( BONE_LIST[b].TheBone.Parent != parentBone ) then 
                            BONE_LIST[b].TheBone.Parent = parentBone
                    )
                    catch
                    (
                        format "*** % ***\n" (getCurrentException())

                    )
				)
			)
		)
	)

  
    
	with animate on
	(
		at time 0
		(
			for b = 1 to nbones do
			(

				aBone = BONE_LIST[b].TheBone
				if( aBone != undefined) then
				(
					iref = IREF_LIST[b].Matrix
					aBone.Transform = iref
				)
			)
		)
	)

	with animate on
	(
		at time 10
		(
			in coordsys parent
			(
				for b=1 to nbones do
				(

					aBone = BONE_LIST[b].TheBone
					if(aBone != undefined ) then
					(
						aBone.Rotation = BONE_LIST[b].Rotation
						aBone.Position = BONE_LIST[b].Position
						--aBone.Scale = BONE_LIST[b].Scale

						aBone.SetSkinPose()
					)
				)
			)
		)
	)

)

/* BUILD THE MESHES */
fn Build_Meshes =
(
	format "BUILDING MESHES...\n"

	/*
		Create the meshes/submeshes
		Assign a random color to the mesh if there is no materials imported
		Applies the correct uv coordinates
		Apply normals

	*/

	nMeshes = SUBMESH_LIST.count
	nFirstFace = 0

	/* Create the meshes */
	for m=1 to nMeshes do
	(
		submesh = SUBMESH_LIST[m]
		--print submesh

		local v = #()
		local n = #()
		local uv = #()
        local uv2 = #()

        if submesh.nVerts == undefined then continue
        
		for x=1 to submesh.nVerts do
		(
			append v VERTEX_LIST[submesh.firstVertex + x]
			append n NORMALS_LIST[submesh.firstVertex + x]
			
            if (UVW_LIST.count > 0 ) then 
                append uv UVW_LIST[submesh.firstVertex + x]
            
            if (UVW_LIST2.count > 0 ) then 
                append uv2 UVW_LIST2[submesh.firstVertex + x]
            
            
		)
        
        
        /* RESEARCH START *****************************************************/
        local possibleCorrection = 1.0
        local maxU = 0.0
        local maxV = 0.0
        local minU = 0.0
        local minV = 0.0
        local uvCorrection = 1.0
        local offsetUV = 0.0
        
        
        for i=1 to uv.count do
        (
            local uShort = uv[i].x
            local vShort = uv[i].y
            
            if ( maxU < uShort ) then maxU = uShort
            if ( maxV < vShort ) then maxV = vShort
            if ( minU > uShort ) then minU = uShort
            if ( minV > vShort ) then minV = vShort
            
        )
        
        format "For mesh %\n" m
        format "- Max U = %\n- Min U = %\n- MaxV = %\n- Min V = %\n" maxU minU maxV minV

        if (maxV > 2000 and maxV < 2100 ) then maxV = 2048
        
        local biggestOne = 0
       -- if( biggestOne < (abs minU)) then biggestOne = (abs minU)
       -- if( biggestOne < (abs maxU)) then biggestOne = (abs maxU)
        if( biggestOne < (abs minV)) then biggestOne = (abs minV)
        if( biggestOne < (abs maxV)) then biggestOne = (abs maxV)
        
           
        format "Biggest one = %\n" biggestOne

        biggestOne = abs maxV + abs minV
        
        /* calculate the uv correction, its a power of 2 */
        for i=2 to 20 do
        (
            if (biggestOne <= (2^i) and biggestOne > (2^(i-1)) ) then
                possibleCorrection = (2^i)
        )
        
        -- if( possibleCorrection < 2048.0 ) then possibleCorrection = 2048.0
        
        /* some old none compressed uv mapping */
        if( biggestOne <= 1.0 ) then possibleCorrection = 0.5 
        
        /* lets give it a try */
        local uvRatio = (maxU - minU) / (maxV - minV)
             
        format " - Possible correction = % \n" possibleCorrection
        format " - Possible uv ratio = % \n" uvRatio
        
         uvCorrection = possibleCorrection  
         offsetUV = uvRatio / 2.0 --1.0 / ( 2.0 / uvRatio )
        
        if ( possibleCorrection == 0.5 )  then uvCorrection = 0.5
        if ( possibleCorrection == 2048 ) then offsetUV = 0.0
        if ( possibleCorrection == 32 )   then uvCorrection = 2048.0
        if ( possibleCorrection == 65536) then uvCorrection = 32768.0
        if ( possibleCorrection == 65536 and (uvRatio as integer) == 1) then uvCorrection = 65536.0
        
        /* recalculate the uv mapping coordinates */
        for i=1 to uv.count do
        (
            uv[i].x = uv[i].x / uvCorrection + offsetUV
            uv[i].y = (1.0 - uv[i].y / uvCorrection) - offsetUV
            
            if( biggestOne <= 1.0 ) then
            (   
                uv[i].x = uv[i].x / uvRatio
                uv[i].y = 1.0- ( uv[i].y / uvRatio )
                
            )
             
        )

        /* RESEARCH END *****************************************************/
        
		local f = #()

		for x=1 to submesh.nIndices by 3 do
		(
			local face = [0,0,0]

			for j=1 to 3 do
			(
				local k = submesh.firstIndex + x + j - 1
				face[j] = INDICES_LIST[k]
			)
			append f face
		)

		nFirstFace = lastx

        local theMesh = mesh vertices:v vnorms:n name:submesh.Name faces:f tverts:uv 

		unitLayer = CreateLayer "Unit"
		theMesh.WireColor = Color (random 0 128) (random 0 255) (random 0 128)

        buildTVFaces theMesh false
		for i = 1 to f.count do
		( setTVFace theMesh i f[i] )

        
		update theMesh
		unitLayer.AddNode theMesh
		SUBMESH_LIST[m].TheMesh = theMesh
        
	)

)

/* BUILD VOL TARGET */
fn Build_VolTarget=
(
	/*
		Weird stuff when setting the center to the refering bone, this does not always work...
	*/

	--> 0 Cube, 1 Sphere, 2 Capsule

	for i=1 to ATVL_LIST.Count do
	(
		local volTarget = ATVL_LIST[i]

        local boneIndex = 0
        local objName = BONE_LIST[volTarget.Bone0].name

        if( volTarget.Bone2 > 0 ) then boneIndex = volTarget.Bone2        
        if( volTarget.Bone1 > 0 ) then boneIndex = volTarget.Bone1
        if( volTarget.Bone0 > 0 ) then boneIndex = volTarget.Bone0
        

		local refBone = BONE_LIST[boneIndex].theBone
		local obj = undefined

		if( volTarget.type == 0) then /* CUBE */
		(
			obj = box name:objName height:volTarget.size2 width:volTarget.size0 length:volTarget.size1
		)
		if( volTarget.type == 1) then /* SPHERE */
		(
			obj = sphere name:objName radius:volTarget.size0
            obj.pivot = obj.center
            
		)
		if( volTarget.type == 2) then /* CAPSULE */
		(
			local heigth = volTarget.size0 + volTarget.size1
			obj = capsule name:objName sides:12 radius:volTarget.size0 height:heigth heighttype:0
		)
		if( volTarget.type == 3) then /* CYLINDER */
		(
			obj = Cylinder name:objName sides:12 radius:volTarget.size0 height:volTarget.size1
            obj.pivot = obj.center
		)

		if(obj != undefined ) then
		(
            obj.transform = refBone.transform
            -- For shield only
            if (objName == "Vol_Shield") then
            (
                if (obj.pos.z == 0) then
                (
                    bbox = nodeLocalBoundingBox obj
                    obj.pos.z = abs bbox[1].Z
                )
            )
			local layer = CreateLayer "Vol_Target"
			layer.AddNode obj
			layer.AddNode refBone
			obj.parent = refBone
			obj.wirecolor = color 255 0 0
			obj.boxmode = on
			obj.renderable = off
			freeze obj
			Hide refBone
		)
		BONE_LIST[boneIndex].theBone.name = objName + "_BoneRef"
	)


)

/* BUILD HIT TEST */
fn Build_HitTestFuzzy=
(
	--> 0 Cube, 1 Sphere, 2 Capsule

	for i=1 to SSGS_LIST.Count do
	(
		local hitTest = SSGS_LIST[i]
		local refBone = BONE_LIST[hitTest.BoneId].theBone

		local obj = undefined

		if( hitTest.type == 0) then /* CUBE */
		(
			obj = box name:refBone.Name height:hitTest.size2 width:hitTest.size0 length:hitTest.size1

			obj.rotation = refBone.Rotation
			obj.pos = refBone.position

		)
		if( hitTest.type == 1) then /* SPHERE */
		(
			obj = sphere name:refBone.Name radius:hitTest.size0
			obj.pivot = obj.center
            obj.transform = refBone.transform
            
		)

		if( hitTest.type == 2) then /* CAPSULE */
		(
			local height = hitTest.size0 * 2 + hitTest.size1
			obj = capsule name:refBone.Name sides:12 radius:hitTest.size0  height:height heighttype:0

			obj.transform = refBone.transform
		)

		if( hitTest.type == 3) then /* CYLINDER */
		(

			obj = Cylinder name:refBone.Name sides:12 radius:hitTest.size0 height:hitTest.size1

			obj.transform = refBone.transform

		)



		if(obj !=undefined ) then
		(
			local layer = CreateLayer "HitTestFuzzy"
			layer.AddNode obj
			layer.AddNode refBone
			obj.parent = refBone
			obj.wirecolor = color 0 0 255
			obj.boxmode = on
			obj.renderable = off
			freeze obj
			hide refBone
		)
		BONE_LIST[hitTest.BoneId].theBone.name = BONE_LIST[hitTest.BoneId].name + "_BoneRef"

	)


)

/* BUILD HIT TEST TIGHT*/
fn Build_HitTestTight=
(
    if ( BONE_LIST == undefined ) then return undefined
    if ( gHitTestTight == undefined ) then return undefined
    if ( gHitTestTight.hitTestModel == undefined ) then return undefined
    if ( gHitTestTight.parentBoneId == undefined ) then return undefined
    if ( bBuildHitTest == false ) then return undefined
    if ( gHitTestTight.parentBoneId > BONE_LIST.count ) then return undefined
    

    local parentBone = BONE_LIST[gHitTestTight.parentBoneId].TheBone

    if( parentBone != undefined ) then 
    (
        --gHitTestTight.hitTestModel.rotation = parentBone.rotation
        --gHitTestTight.hitTestModel.position = parentBone.position
        gHitTestTight.hitTestModel.parent = parentBone

    )
)

/* BUILD ATT POINTS */
fn Build_Attachments=
(
	/*
		since the export of the model refers to double naming of object
		-> because the bone name is most of the time the actual attachment,
		I renamed these bones with the suffix _boneRef
	*/
	if ( bUseSC2ArtTools == true ) then
	(
		for i=1 to ATT_LIST.Count do
		(
			local attLayer = CreateLayer "Attachment Points"

			local att = ATT_LIST[i]

			local refBone = BONE_LIST[att.ParentId].theBone

			local obj = undefined

            
			obj = SC2AttachPt name:att.Name scale:[0.5,0.5,0.5]
            --obj = point name:att.Name wirecolor:yellow

			obj.Rotation = refBone.Rotation
			obj.pos = refBone.Pos
			obj.Parent = refBone

			attLayer.AddNode obj
			attLayer.AddNode refBone
			--hide refBone
			--freeze obj
			BONE_LIST[att.ParentId].theBone.name = BONE_LIST[att.ParentId].name + "_BoneAtt"
		)
	)

	if ( bUseSC2ArtTools == false ) then
	(
		for i=1 to ATT_LIST.Count do
		(
			local attLayer = CreateLayer "Attachment Points"

			local att = ATT_LIST[i]

			local refBone = BONE_LIST[att.ParentId].theBone

			local obj = undefined

			obj = CreateAttachmentPt att.Name --SC2AttachPt name:att.Name scale:[0.5,0.5,0.5]
			obj.Rotation = refBone.Rotation
			obj.pos = refBone.Pos
			obj.Parent = refBone

			attLayer.AddNode obj
			attLayer.AddNode refBone
			hide refBone
			freeze obj
			BONE_LIST[att.ParentId].theBone.name = BONE_LIST[att.ParentId].name + "_BoneRef"
		)

	)

)

/* IMPORT TEXTURES */
fn Build_Materials =
(
	
	if ( bUseSC2ArtTools == false ) then
	(
        Format "IMPORTING NON SC2 TEXTURES...\n"
        
		for i=1 to MAT_LIST.count do
		(
			try
			(
				mat = MAT_LIST[i]

				SC2Mat =  Standardmaterial () -- SC2_Standard_Material()
				SC2Mat.Name 		= mat.Name

				if( mat.Diff_Map    !=undefined) then
				(
					--SC2Mat.Diffuse.fileName         =   mat.Diff_Map
					SC2Mat.diffuseMapEnable = on
					SC2Mat.diffuseMap = Bitmaptexture fileName:mat.Diff_Map
					SC2Mat.ambient = color 0 0 0
					SC2Mat.Diffuse = color 0 0 0
					showTextureMap SC2Mat SC2Mat.diffuseMap true
					SC2Mat.adLock = off --> applies a team color
					SC2Mat.Diffuse = color 255 0 0
				)
				if( mat.Norm_Map    !=undefined) then
				(
					SC2Mat.bumpMapEnable = on
					SC2Mat.bumpMap = Normal_Bump ()
					SC2Mat.bumpMap.normal_map = Bitmaptexture fileName:mat.Norm_Map
					SC2Mat.bumpMap.flipred = on
					SC2Mat.bumpMapAmount = 20

				)

				if( mat.Spec_Map    !=undefined) then
				(
					SC2Mat.specularMapEnable = on
					SC2Mat.specularMap = Bitmaptexture fileName:mat.Spec_Map
					SC2Mat.specularLevel = 50
					SC2Mat.glossiness = 30

				)
				if( mat.Emis_Map    !=undefined) then
				(

					SC2Mat.selfillumMapEnable = on
					SC2Mat.useSelfIllumColor = on
					SC2Mat.selfillumMap = Bitmaptexture fileName:mat.Emis_Map
				)


				if( mat.Alpha_Map   !=undefined) then
				(
					SC2Mat.opacityMapEnable = on
					SC2Mat.opacityMap = Bitmaptexture fileName:mat.Alpha_Map
					SC2Mat.opacityMap.monooutput = 1
				)

				meditMaterials[i] = SC2Mat

				MAT_LIST[i].MaterialRef = SC2Mat
			)
			catch
			(
				PRINT "[ERROR]"
				PRINT (getCurrentException())

			)
		)

	)


)

/* APPLY MATERIALS TO MESHES */
fn ApplyMaterials =
(
	format "APPLYING MATERIALS\n"

    Build_Materials()

	for i= 1 to MESHMAT_LIST.Count do
	(
        try
        (
		local msh
		local mat

		if(SUBMESH_LIST[MESHMAT_LIST[i].MeshId] != undefined ) then msh = SUBMESH_LIST[MESHMAT_LIST[i].MeshId].TheMesh
		if(MAT_LIST[MESHMAT_LIST[i].matID] != undefined ) then
        (
            mat = MAT_LIST[MESHMAT_LIST[i].matID]
            if ( bUseSC2ArtTools == false ) then mat = MAT_LIST[MESHMAT_LIST[i].matID].MaterialRef
        )

		if(msh!=undefined and mat!=undefined ) then msh.Material = mat
        )
        catch()
	)

)

/* SKIN THE MODEL */
fn Apply_Skin=
(
	/*
		Most annoying part in the whole script, didn't have this much issues with my D3 import script :/

		Until now, still not 100% correct, sometimes this misses the vertex weighting completly.. :'(

		TODO:
			Figure out the correct way to apply these arrays of 4 weights and 4 bone indexes to the mesh
			Spent too much time on this already and probably will do more, but sometimes it is just faster to do this manually !!

	*/
	for m=1 to SUBMESH_LIST.Count do
	(

		local msh = SUBMESH_LIST[m]
		local obj = SUBMESH_LIST[m].theMesh
		local mshSkin = skin name:"Skin"

		max modify mode
		addmodifier obj mshSkin

		modPanel.setCurrentObject mshSkin


		for i=1 to msh.nBones do
		(

			local b = BONE_LIST[BONE_LOOKUP[msh.firstBoneLookup + i]].theBone

			skinOps.addBone mshSkin b 0
		)

		update obj
		max views redraw

		--disableSceneRedraw()


		for v=1 to msh.nVerts do
		(


			skinOps.ReplaceVertexWeights mshSkin v WEIGHTBONE_LIST[msh.firstVertex + v].BoneIndexes  WEIGHTBONE_LIST[msh.firstVertex + v].Weights

		)



		update obj
		--enableSceneRedraw()
		redrawViews()
	)

)

/* create StarCraft 2 AnimProps */
fn SetAnimProps=
(
	/*
		check if there is a note track called "starAnimTrack"-> this is where Blizzard stores its animations

		NOTE: if you already have a animation track, be aware this will be deleted !!!

	*/
	local starAnimTrack = undefined
	local nNoteTracks = numNoteTracks rootNode
	if(  nNoteTracks > 0 ) then
	(
		for n=1 to nNoteTracks do deleteNoteTrack rootNode (getNoteTrack rootNode n)
	)

	if( numNoteTracks rootNode == 0 ) then
	(
		starAnimTrack = notetrack "starAnimTrack"
		addNoteTrack rootNode starAnimTrack
	)
	animPropsList = STC_LIST
    
	for i=1 to nbrValidSTCs do
	(
		local props = animPropsList[i]
		local underscorePos = findstring props.Name "_full"

		if( underscorePos != undefined) then
		(
			props.Name = substring props.Name 1 (underscorePos-1)
		)

        local underscorePos2 = findstring props.Name "_"

		if( underscorePos2 != undefined) then
		(
			props.Name = substring props.Name 1 (underscorePos2-1) + " " + (bit.intaschar (64 + i))
		)
        
		local noteExists = getNoteKeyIndex starAnimTrack props.firstFrame
		if( noteExists == undefined) then
		(
			local startNote = AddNewNoteKey starAnimTrack props.firstFrame -- props.startFrame
			local endFrame = props.LastFrame -- props.startFrame + (( props.endFrame * 30 / 1000.0) as integer)
			local endNote = AddNewNoteKey starAnimTrack endFrame

			if( props.MovementSpeed > 1000) then props.MovementSpeed = 450 --> don't know but for heroes this is an issue on the hero models

			local val = props.Name + "\r\n"
				  val += "rarity = " 	 + props.frequency as string + "\r\n"
				  val += "moveSpeed = "  + props.MovementSpeed as string + "\r\n"
				  val += "nonLoop = " 	 + props.NonLooping as string + "\r\n"
				  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = 0"

			startNote.Value = val
			endNote.Value = val

			format  "- Animation '%' { start:%, end:% }\n" props.Name props.firstFrame props.LastFrame 
		)
	)
    
    

    
    
)

/* fix the GLStand animation sequences to use behaviours */
function FixGLsequences=
(
    if animPropsList == undefined then return undefined
    
    /*
        BehaviorHolder
        - Behavior
    */
    local items_array =#("Default Track Set")
    
    -- check if there is already a behavior node 
    local targetNode = Startools.Behaviors.TargetNode
	if ( targetNode == undefined ) then targetNode = SC2BehaviorHolder()
    
    local defaultTrackSet = (startools.behaviors.AddBehavior targetNode #TrackSet)
    
    -- animProp = animPropsList[5]
    for animProp in animPropsList do
    (
        local GLboneList = #()
        if( findstring animProp.name "GLstand" != undefined ) then
        (
            format "Checking GL anim '%' (%-%)\n" animProp.name  animProp.firstFrame animProp.lastFrame

            local newTrackSet = (startools.behaviors.AddBehavior targetNode #TrackSet)
            newTrackSet.name = "TrackSet " + animProp.name
            
            if newTrackSet != undefined then startools.behaviors.lastBehaviorSelected = newTrackSet

            append items_array newTrackSet.name
            
            /* get a list of bones that has animation keys during this animation sequence*/
            for obj in objects do
            (
                if ( classof obj == BoneGeometry ) then 
                (
                    for k=1 to obj.pos.controller.keys.count do
                    (
                        -- check if the bone has animation keys in the animation sequence
                        if ( obj.pos.controller.keys[k].time >= animProp.firstFrame and obj.pos.controller.keys[k].time <= animProp.lastFrame) then
                        (
                           appendIfUnique GLboneList obj
                        )
                    )
                    for k=1 to obj.rotation.controller.keys.count do
                    (
                        -- check if the bone has animation keys in the animation sequence
                        if ( obj.rotation.controller.keys[k].time >= animProp.firstFrame and obj.rotation.controller.keys[k].time <= animProp.lastFrame) then
                        (
                           appendIfUnique GLboneList obj
                        )
                    )
                )
            )
            if( GLboneList.Count > 0 ) then
            (
                newTrackSet.AddBones GLboneList

            )
            -- this is from the reversed hacked official code:
            -- add the new track set to the animation
            newTrackSet.AddAnimation animProp.name
            newTrackSet.Animations
            
            -- set it to prio 1
			newTrackSet.SetPriorityForAnim animProp.name (starTools.AnimProps.GetDefaultPriority animProp.name)

            
        )
    )
    
)

/* APPLY THE ANIMATION*/
fn ApplyAnimation=
(
	format "APPLYING ANIMATION... (this can take some time)\n"

	/*
		frame used for binding position, all animations must start after frame 10 !

	*/

	-- find matching SEQ_refId
	nbrValidSTCs = 0
	for g=1 to STG_LIST.Count do
	(
		for x=1 to STG_LIST[g].STC_ids.Count do
		(
			local stcId = STG_LIST[g].STC_ids[x] +1
			STC_LIST[stcId].SEQ_refId = g

			if( stcId > nbrValidSTCs ) then nbrValidSTCs = stcId
		)

	)

	-- build the stc animations
	local firstFrame = 50

	for i=1 to nbrValidSTCs do
	(
        
        STC_LIST.count

		local seqsId = STC_LIST[i].SEQ_refId
		local nbrFrames = (SEQS_LIST[seqsId].endFrame * 30 / 1000.0 ) as integer  --> end frame is actually wrong, this is the number of seconds the animation takes

		STC_LIST[i].FirstFrame = firstFrame
		STC_LIST[i].LastFrame = firstFrame + nbrFrames
		STC_LIST[i].NonLooping = SEQS_LIST[seqsId].NonLooping
		STC_LIST[i].Frequency = SEQS_LIST[seqsId].Frequency
		STC_LIST[i].MovementSpeed = SEQS_LIST[seqsId].MovementSpeed
		firstFrame += (nbrFrames + 100) as integer

		if( i> 1) then
		(
			lowerBody = FindString ( toLower STC_LIST[i-1].name ) "_lowerbody"
			if( lowerBody !=undefined) then
			(
				STC_LIST[i].FirstFrame = STC_LIST[i-1].FirstFrame
				STC_LIST[i].LastFrame = STC_LIST[i-1].LastFrame
			)
		)
	)

	/* Start animating the bones */
	for i=1 to BONE_LIST.count do
	(
		if(BONE_LIST[i].isAnimated) then --> only animated bones
		(
			local b = BONE_LIST[i].theBone
			if( b == undefined ) do continue
			local boneRotId = BONE_LIST[i].AnimRefRotation.animID
			local bonePosId = BONE_LIST[i].AnimRefPosition.animID
			local boneSclId = BONE_LIST[i].AnimRefScale.animID

			local boneRotationAnimation = undefined
			local bonePositionAnimation = undefined

			local rotFrameList = undefined
			local posFrameList = undefined

			local rotKeyList = undefined
			local posKeyList = undefined

			for c=1 to nbrValidSTCs do
			(
				local rotAnimations = #()
				local posAnimations = #()
				local rot_sd = undefined
				local pos_sd = undefined

				firstFrame = STC_LIST[c].FirstFrame

				for a=1 to STC_LIST[c].AnimationIds.count do
				(
					if( STC_LIST[c].AnimationIds[a] == boneRotId) then
					(
						rot_sd = STC_LIST[c].AnimationRefs[a].sd
						local sdindx = STC_LIST[c].AnimationRefs[a].sdindx --> should be 4

						boneRotationAnimation = STC_LIST[c].SD4Q_data --> refers to 4

						local anim = MAX_ANIMATION()

						anim.FrameList = boneRotationAnimation[rot_sd].FrameList.TagData
						anim.KeyList = boneRotationAnimation[rot_sd].Keys.TagData

						append rotAnimations anim
					)

					if( STC_LIST[c].AnimationIds[a] == bonePosId) then
					(
						pos_sd = STC_LIST[c].AnimationRefs[a].sd
						local sdindx = STC_LIST[c].AnimationRefs[a].sdindx --> should be 3

						bonePositionAnimation = STC_LIST[c].SD3V_data

						local anim = MAX_ANIMATION()

						anim.FrameList = bonePositionAnimation[pos_sd].FrameList.TagData
						anim.KeyList = bonePositionAnimation[pos_sd].Keys.TagData

						for k=1 to anim.KeyList.count do anim.KeyList[k] *= gScaleFactor --100.0   --> TO CHECK

						append posAnimations anim
					)

				) --> end animationIds


					-- APPLY ROTATION --> always first apply rotation since this is done using a quaternian transformation matrix
				local prevTime = undefined

				for r=1 to rotAnimations.count do
				(
					for frame=1 to rotAnimations[r].FrameList.Count do
					(

						local t = firstFrame + (rotAnimations[r].FrameList[frame] * 30  / 1000.0 ) as integer

						if( prevTime != t) then
						(
							prevTime = t --> this is to prevent multiple transformations on the same time frame
							local q = rotAnimations[r].KeyList[frame]

							--print ( t as string + ":" + q as string )

							with animate on
							(
								at time t (

									b.assumeskinpose()
									local mtrx = matrix3 1
									rotate mtrx (inverse q)
                                    
                                    deleteKey b.rotation.controller (numKeys b.rotation.controller)
                                    
									if (b.parent != undefined) then
									(
											mtrx = mtrx * b.parent.transform --> check if this is necessary!!
									)
									b.transform = mtrx
									deleteKey b.position.controller (numKeys b.position.controller)
									deleteKey b.scale.controller (numKeys b.scale.controller)


								)
							)

						)
					)
				)

				-- APPLY POSITION
				local prevTime = undefined

				for p=1 to posAnimations.count do
				(

					for frame=1 to posAnimations[p].FrameList.count do
					(

						local t = firstFrame + (posAnimations[p].FrameList[frame] * 30  / 1000.0 ) as integer

						if( prevTime != t) then
						(
							prevTime = t --> this is to prevent multiple transformations on the same time frame
							local pos = posAnimations[p].KeyList[frame]

							--print ( t as string + ":" + q as string )
							with animate on
								at time t
									in coordsys parent b.position = pos

						)
					)
				)




			) --> end STC_LIST


		)
	)

	--print SEQS_LIST
    if ( STC_LIST.count > 0 ) then
    (
        SetAnimProps()
        FixGLsequences()
    )
)


/*
    particle system
*/
function READ_PAR stream idx=
(
    --clearlistener()
    if( bBuildParticles == false ) then return undefined
    if( bUseSC2ArtTools == false ) then return undefined
    if( idx==0) then return undefined
    
    local sc2_particle_emitterType = #("Point", "Plane", "Sphere", "Box", "Cylinder", "Disk", "Spline", "Mesh" )
    
    PARTICLE_SYSTEMS  = #()

    local tag = TAGS[idx]
    local tagSize = 0
    local particleLayer = CreateLayer "Particles"

    format "Tag %" tag
    
    local offsetcorrection = 0
    
    if tag.flag == 24 then 
    (        
        tagSize = 1496
        offsetcorrection = 4
    )
    
    for p=1 to tag.nbrItems do
    (
        -- > TODO - change this to work with non sc2 art tools
        local parSystem =  HEROES_Particles()
        local offsetX = tag.OffSet + ( (p-1) * tagSize )
        local particles = SC2Particles()
        
        particleLayer.AddNode particles
        
        fseek stream offsetX #seek_set

        parSystem.parentBoneIndex = ReadLong stream + 1

        local matId = ReadLong stream + 1
        
        particles.material = MAT_LIST[matId]
        
        -- Emitter Shape
        fseek stream ( tag.OffSet + 420 + offsetcorrection ) #seek_set
        local emitterType = ReadLong stream #unsigned
        
        if(emitterType < 0 ) then 
        (
            Format "Emittertype % not supported, changing to point" emitterType
            
            emitterType = 0
        )
        format "EmitterType %(%)\n"  sc2_particle_emitterType[emitterType+1] emitterType
        particles.EmitterType = emitterType

        -- Outer Shape
        fseek stream ( tag.OffSet + 432 + offsetcorrection ) #seek_set
        particles.OuterLength = ( ReadFloat stream ) * gScaleFactor
        particles.OuterWidth  = ( ReadFloat stream ) * gScaleFactor
        particles.OuterHeight = ( ReadFloat stream ) * gScaleFactor
        
        fseek stream ( tag.OffSet + 504 + offsetcorrection ) #seek_set

        particles.OuterRadius = ( ReadFloat stream ) * gScaleFactor

        -- Inner Shape
        fseek stream ( tag.OffSet + 1228 ) #seek_set
        local useInnerShape = ReadByte stream
        if( useInnerShape == 16 ) then particles.UseInnerShape = on
        fseek stream ( tag.OffSet + 468  ) #seek_set
        particles.InnerWidth  = ( ReadFloat stream ) 
        particles.InnerLength = ( ReadFloat stream ) 
        particles.InnerHeight = ( ReadFloat stream ) 
        fseek stream ( tag.OffSet + 524 ) #seek_set
        particles.InnerRadius = ( ReadFloat stream ) 


        -- LifeSpan
        -- NOTE: AutoCalc is not saved in the m3 file, it is a UI feature only
        fseek stream ( tag.OffSet + 396  ) #seek_set
        particles.MaxParticles = ReadLong stream #unsigned
        skipBytes stream 8
        particles.EmissionRate = ReadFloat stream
        fseek stream ( tag.OffSet + 708  ) #seek_set
        particles.SquirtQuantity = ReadLong stream #unsigned
        fseek stream ( tag.OffSet + 140  ) #seek_set
        particles.LifeTimeMin = ReadFloat stream 
        skipBytes stream 16
        particles.LifeTimeMax = ReadFloat stream 
        fseek stream ( tag.OffSet + 172  ) #seek_set
        particles.KillSphereRadius = SQRT ( (ReadFloat stream) * gScaleFactor )
        fseek stream ( tag.OffSet + 1231  ) #seek_set
        local localTimeOn = ReadByte stream
        if( localTimeOn == 2 ) then particles.localTime = on
        if( localTimeOn == 4 ) then particles.SimulateOnInit = on
        if( localTimeOn == 6 ) then
        (
            particles.localTime = on
            particles.SimulateOnInit = on
        )

        /*
            Initial Velocity
            00 Constant
            01 Radial
            02 Z - Axis
            03 Random
            04 Mesh Normal
        */
        fseek stream ( tag.OffSet + 548  ) #seek_set
        particles.InitialVelocityType = ReadByte stream

        fseek stream ( tag.OffSet + 60  ) #seek_set
        particles.InitialVelocityYaw = ReadFloat stream
        skipBytes stream 16
        particles.InitialVelocityPitch = ReadFloat stream

        fseek stream ( tag.OffSet + 20  ) #seek_set
        particles.InitialVelocitySpeedMin = ( ReadFloat stream ) * 100.0
        skipBytes stream 16
        particles.InitialVelocitySpeedMax = ( ReadFloat stream ) * 100.0

        fseek stream ( tag.OffSet + 1232  ) #seek_set
        local xyOnly = ReadByte stream
        if( xyOnly == 14 ) then particles.ParticleVelocityXYOnlyCheck = on

        fseek stream ( tag.OffSet + 1228  ) #seek_set
        local inheritVelocity = ReadByte stream
        if( inheritVelocity == 64 ) then particles.InheritParentVelocityCheck = on

        fseek stream ( tag.OffSet + 1228  ) #seek_set
        particles.InheritParentVelocityPercent = ( ReadFloat stream ) * 100.0

        -- Per-Particle Parameters


        /* COLOR */
        fseek stream ( tag.OffSet + 300 + offsetcorrection ) #seek_set

        local b = readByte stream
        local g = readByte stream
        local r = readByte stream
        local a = readByte stream

        particles.ColorMinBegin = Color r g b a

        fseek stream ( tag.OffSet + 632 + offsetcorrection ) #seek_set
        if( (readbyte stream) == 1) then particles.ColorUseMid = on

        fseek stream ( tag.OffSet + 320 + offsetcorrection ) #seek_set

        local b2 = readByte stream
        local g2 = readByte stream
        local r2 = readByte stream
        local a2 = readByte stream

        particles.ColorMinMid = Color r2 g2 b2 a2

        fseek stream ( tag.OffSet + 340 + offsetcorrection ) #seek_set

        local b3 = readByte stream
        local g3 = readByte stream
        local r3 = readByte stream
        local a3 = readByte stream

        particles.ColorMinEnd = Color r3 g3 b3 a3

        fseek stream ( tag.OffSet + 192 + offsetcorrection ) #seek_set
        local midTime = readfloat stream

        if( midTime != 0.0) then
        (
            particles.ColorMidTime = midTime
            particles.AlphaMidTime = midTime
            particles.SizeMidTime = midTime
            particles.RotationMidTime = midTime
            particles.FlipbookMidTime = midTime
        )

        fseek stream ( tag.OffSet + 644 + offsetcorrection ) #seek_set
        local bm = readByte stream
        local gm = readByte stream
        local rm = readByte stream
        local am = readByte stream

        if( b == bm and g == gm and r == rm and a == am) then particles.ColorRange = on
        particles.ColorMaxBegin = Color rm gm bm am

        fseek stream ( tag.OffSet + 664 + offsetcorrection ) #seek_set

        local b2 = readByte stream
        local g2 = readByte stream
        local r2 = readByte stream
        local a2 = readByte stream

        particles.ColorMaxMid = Color r2 g2 b2 a2

        fseek stream ( tag.OffSet + 684 + offsetcorrection ) #seek_set

        local b3 = readByte stream
        local g3 = readByte stream
        local r3 = readByte stream
        local a3 = readByte stream

        particles.ColorMaxEnd = Color r3 g3 b3 a3

        fseek stream ( tag.OffSet + 1236 + offsetcorrection ) #seek_set
        particles.SmoothColorInterpolation = readByte stream

        /* Alpha & range */
        /* Size & range */
        /* Rotation & range  */
        /* Flip book */

        /* Physics */
        /* Collision */
        /* Misc */
        /* Noise */
        /* Force Field Selection */
        /* Screen Space */
        parSystem.particleSystem = particles
        append PARTICLE_SYSTEMS parSystem

    )
    

)


fn Build_Particles =
(
    -- particles are already build, just map them to the correct bone and name them
    if ( bUseSC2ArtTools == false ) then return undefined
    if ( BONE_LIST == undefined ) then return undefined
    for pS in PARTICLE_SYSTEMS do
    (
        
        local boneIndex = pS.parentBoneIndex
        local parSystem = pS.particleSystem
        
        if(BONE_LIST.Count >= boneIndex ) then
        (
            if(BONE_LIST[boneIndex].TheBone != undefined ) then
            (
                parSystem.Name = BONE_LIST[boneIndex].Name
                BONE_LIST[boneIndex].TheBone.Name = BONE_LIST[boneIndex].Name + "_boneRef"
                parSystem.Transform = BONE_LIST[boneIndex].TheBone.Transform
                parSystem.Parent = BONE_LIST[boneIndex].TheBone
            
            )
        )
    )
    
    
)

/**********************************************************************************************************************************/
/* START READING THE FILE */
/**********************************************************************************************************************************/

fn M3_Read file=
(
	if( doesFileExist file == false ) then return undefined

	--ClearListener()
	SetWaitCursor()

	ResetGlobals()

	local assetPos = findstring (ToUpper file) @"\ASSETS\"
	if(assetPos != undefined ) then ASSETS_FOLDER = substring file 1 assetPos
	if(assetPos == undefined ) then ASSETS_FOLDER = ""

    if( ASSETS_FOLDER == "") then 
        format "[WARNING] 'Assets' folder is incorrect, no materials will be applied"
    else
        format "Assets folder found in '%'\n" ASSETS_FOLDER
    
    
	/* START */

	modlIndex = 0

	vertexIndex = 0
	boneLookupIndex = 0
	indicesIndex = 0
	meshIndex = 0
	lightIndex = 0
	cameraIndex = 0
	particleIndex = 0
	particleCopyIndex = 0
	volTargetIndex = 0
	attachmentIndex = 0
	fuzzyHitIndex = 0
	seqIndex = 0
	stcIndex = 0
	stgIndex = 0
	stsIndex = 0
	seqEventIndex = 0
	seqVector2Index = 0
	seqVector3Index = 0
	seqRealIndex = 0
	seqColorIndex = 0
	seqShortIndex = 0
	seqUShortIndex = 0
	seqUByteIndex = 0
	seqQuatIndex = 0
	seqUByteIndex = 0
	seqBoundIndex = 0
	boneIndex = 0
	irefIndex = 0
	eventIndex = 0
	msecIndex = 0

	billboardIndex = 0
	projectionIndex = 0
	forcesIndex = 0
	warpIndex = 0
	rigidbodyIndex = 0
	ikIndex = 0
	turrentIndex = 0
	turrentIndex = 0

	materialIndex = 0
	standardMatIndex = 0
	meshMatIndex = 0
	displaceMatIndex = 0
	compositeMatIndex = 0
	terrainMatIndex = 0
	creepMatIndex = 0
	volumeMatIndex = 0
	noiseMatIndex = 0
	splatMatIndex = 0

	stream = fOpen file "rb"

	header = ReadFourCC stream
	ofsTags = ReadLong stream
	nTags = ReadLong stream

	--ClearListener()

	/* READ THE TAGS*/
    
    format "Reading TAGS...\n"
	fSeek stream ofsTags #seek_set
	for i=1 to nTags do
	(
		local tag = HEROES_TAG()

		tag.Name = ReadFourCC stream
		tag.Offset = ReadLong stream
		tag.NbrItems = ReadLong stream
		tag.Flag = ReadLong stream

		if(tag.name == "MODL") then modlIndex = i    		--> Root model

		if(tag.name == "U8__") then vertexIndex = i  		--> Vertices
		if(tag.name == "DIV_") then indicesIndex = i    	--> Indices

		if(tag.name == "REGN") then meshIndex = i    		--> Submeshes

		if(tag.name == "LITE") then lightIndex = i   		--> lights
		if(tag.name == "CAM_") then cameraIndex = i  		--> cameras
		if(tag.name == "PAR_") then particleIndex = i  		--> particles
		if(tag.name == "PARC") then particleCopyIndex = i  	--> particle copy
		if(tag.name == "ATVL") then volTargetIndex = i  	--> volume target
		if(tag.name == "ATT_") then attachmentIndex = i  	--> attachment points
		if(tag.name == "SSGS") then fuzzyHitIndex = i  		--> fuzzy hit test

		if(tag.name == "SEQS") then seqIndex = i     		--> Animation sequences
		if(tag.name == "STC_") then stcIndex = i     		--> Sequence transformation collections
		if(tag.name == "STG_") then stgIndex = i     		--> Sequence transformation groups
		if(tag.name == "STS_") then stsIndex = i     		--> Sequence transformation sets

		if(tag.name == "BONE") then boneIndex = i   		--> bones
		if(tag.name == "IREF") then irefIndex = i	 		--> initial pose
		if(tag.name == "EVNT") then eventIndex = i	 		--> animation events
		if(tag.name == "MSEC") then msecIndex = i	 		--> animation ...

		if(tag.name == "BBSC") then billboardIndex = i  	--> billboards
		if(tag.name == "PROJ") then projectionIndex = i  	--> projections
		if(tag.name == "FOR_") then forcesIndex = i  		--> forces
		if(tag.name == "WRP_") then warpIndex = i  			--> warps
		if(tag.name == "PHRB") then rigidbodyIndex = i  	--> physical rigid body
		if(tag.name == "IKJT") then ikIndex = i  			--> Inverse Kinematics joint
		if(tag.name == "PATU") then turrentIndex = i  		--> turret
		if(tag.name == "TRGD") then turrentIndex = i  		--> turret behavior

		if(tag.name == "MATM") then materialIndex = i     	--> materials
		if(tag.name == "MAT_") then standardMatIndex = i  	--> standard materials
		if(tag.name == "BAT_") then meshMatIndex = i  		--> mesh matching material
		if(tag.name == "DIS_") then displaceMatIndex = i  	--> displacement materials
		if(tag.name == "CMP_") then compositeMatIndex = i  	--> composite materials
		if(tag.name == "TER_") then terrainMatIndex = i  	--> terrain materials
		if(tag.name == "CREP") then creepMatIndex = i    	--> creap materials
		if(tag.name == "VOL_") then volumeMatIndex = i   	--> volume materials
		if(tag.name == "VON_") then noiseMatIndex = i    	--> noise materials
		if(tag.name == "STBM") then splatMatIndex = i    	--> splat materials


		if(tag.name == "CHAR") then tag.TagData = ReadCharTag stream tag
		if(tag.name == "LAYR") then tag.TagData = ReadLAYRTag stream tag
		if(tag.name == "U32_") then tag.TagData = ReadU32_Tag stream tag
		if(tag.name == "U16_") then tag.TagData = ReadU16_Tag stream tag
		if(tag.name == "I32_") then tag.TagData = ReadI32_Tag stream tag
		if(tag.name == "I16_") then tag.TagData = ReadI16_Tag stream tag
		if(tag.name == "VEC2") then tag.TagData = ReadVEC2_Tag stream tag
		if(tag.name == "VEC3") then tag.TagData = ReadVEC3_Tag stream tag
		if(tag.name == "REAL") then tag.TagData = ReadREAL_Tag stream tag
		if(tag.name == "BNDS") then tag.TagData = ReadBNDS_Tag stream tag
		if(tag.name == "QUAT") then tag.TagData = ReadQUAT_Tag stream tag

		append TAGS tag
	)
    
  --  print TAGS
    
--     for i=1 to TAGS.count do
--         print TAGS[i].offset
    
    
	/* READ THE ANIMATION DATA*/
	for i=1 to nTags do
	(
		local tag = TAGS[i]

		if(tag.name == "SDEV") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SD2V") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SD3V") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDR3") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDCC") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDS6") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDU6") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDU3") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SD4Q") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDFG") then tag.TagData = ReadSD_Tag stream tag
		if(tag.name == "SDMB") then tag.TagData = ReadSD_Tag stream tag
	)

	/* READ THE DATA */
	Read_MODL stream modlIndex
	Read_SEQS stream seqIndex
	Read_STG  stream stgIndex
	Read_STS  stream stsIndex
	Read_STC  stream stcIndex
	Read_BONE stream boneIndex
	Read_IREF stream irefIndex
	Read_DIV  stream indicesIndex
	Read_REGN stream meshIndex
    Read_VERT stream vertexIndex
	Read_BAT  stream meshMatIndex
	Read_MATM stream materialIndex  --> TODO should be directly creating the SC2Materials, is too much data for a struct!!
	Read_LITE stream lightIndex 	--> this will also build the lights
	Read_ATVL stream volTargetIndex
	Read_ATT  stream attachmentIndex
	Read_MAT  stream standardMatIndex
	Read_SSGS stream fuzzyHitIndex
    Read_CAM  stream cameraIndex

    /* v 2.2 */
    READ_PAR  stream particleIndex

	/*
		TODO
	*/
	-- Read_FOR
	-- Read_PHRB
	-- Read_PROJ
	-- Read_WARP
    -- Read_PHSH
	--> Find out where the HitTestTight capsule is stored

	fclose stream
	GC()

)


fn Main file=
(

	/* READ THE MODEL */
	M3_Read file

	/* -- BUILD THE MODEL */
	gFILETYPE = toLower (getfilenametype file)
	if( gFILETYPE == ".m3") then
	(

		Build_Meshes()

		if(bBuildBones) then
		(
			Build_Bones()

			if( bBuildVolTarget ) then Build_VolTarget()
			if( bBuildHitTest ) then Build_HitTestFuzzy()
			if( bBuildAtt ) then Build_Attachments()
			
            if( bBuildSkin ) then Apply_Skin()
			if( bBuildAnim ) then ApplyAnimation()
            if( bBuildParticles ) then Build_Particles()
            Build_Camera()
        )

		if( bBuildMat ) then
		(
			Build_Materials()
			ApplyMaterials()
		)
		Build_HitTestTight()
	)

	if( gFILETYPE == ".m3a") then
	(
		Build_Bones()
		ApplyAnimation()

	)


)

/**********************************************************************************************************************************
	CREATE THE UTILITY
**********************************************************************************************************************************/
UTILITY HeroesOfTheStormImport "M3 Import (v3.5)"
(
	Group "Model Import"
	(
        Label lbl30 "©2015~2019 by \n Taylor Mouse" height:32 align:#center offset:[30,0]

		CheckBox cbUseSC2ArtTools "Use SC2 Art Tools"

		EditText txtSelectedFile align:#left
		Button bSelectFile "select file ..." align:#right

		Label lbl100 "Import:" align:#left
		CheckBox cbBuildMat "Materials"
        
		CheckBox cbBuildBones "Bones" tooltip:"Unchecking this will uncheck all depending checkboxes aswell"
		CheckBox cbBuildVolTarget "Volume Targets"
		CheckBox cbBuildHitTest "Hit Tests"
		CheckBox cbBuildAtt "Attachments"
		CheckBox cbBuildAnim "Animations"
		CheckBox cbBuildSkin "Skin"
        CheckBox cbBuildParticles "Particles"
        spinner spinnerScale "Scale" range:[1,100,0] type:#integer align:#left

		Button bGo "Import..." height:35 width:100

	)
	on HeroesOfTheStormImport OPEN DO
	(
		cbBuildBones.Checked = true
		cbBuildVolTarget.Checked = true
		cbBuildHitTest.Checked = true
		cbBuildAtt.Checked = true
		cbBuildAnim.Checked = true
		cbBuildMat.Checked = true
		cbBuildSkin.Checked = true
		cbUseSC2ArtTools.Checked = true
        cbBuildParticles.Checked = true
        spinnerScale.value = gScaleFactor

	)

	on cbBuildBones CHANGED theState do
	(
		if(bBuildBones) then
		(
			bBuildBones = false
			bBuildHitTest = false
			bBuildAtt = false
			bBuildAnim = false
			bBuildVolTarget = false
			bBuildSkin = false
            bBuildParticles = false

			cbBuildVolTarget.Checked = false
			cbBuildHitTest.Checked = false
			cbBuildAtt.Checked = false
			cbBuildAnim.Checked = false
			cbBuildSkin.Checked = false
            cbBuildParticles.Checked = false
		)
		else
		(
			bBuildBones = true
		)

	)

	on cbUseSC2ArtTools CHANGED theState do
	(
		if ( bUseSC2ArtTools == true ) then
		(	bUseSC2ArtTools = false )
		else
		(	bUseSC2ArtTools = true )


	)
    on cbBuildParticles CHANGED theState do
    (
        if( bBuildParticles == true ) then
        ( bBuildParticles == false )
        else
        ( bBuildParticles == true )

    )

	on cbBuildSkin CHANGED theState do
	(
		if( bBuildBones == true ) then
		(
			if(bBuildSkin) then bBuildSkin = false else bBuildSkin = true
		)
		else
		( cbBuildSkin.Checked = false )
	)


	on cbBuildHitTest CHANGED theState do
	(
		if( bBuildBones == true ) then
		(
			if(bBuildHitTest) then bBuildHitTest = false else bBuildHitTest = true
		)
		else
		( cbBuildHitTest.Checked = false )
	)


	on cbBuildAtt CHANGED theState do
	(
		if( bBuildBones == true ) then
		(
			if(bBuildAtt) then bBuildAtt = false else bBuildAtt = true
		)
		else
		( cbBuildAtt.Checked = false )
	)

	on cbBuildAnim CHANGED theState do
	(
		if( bBuildBones == true ) then
		(
			if(bBuildAnim) then bBuildAnim = false else bBuildAnim = true
		)
		else
		( cbBuildAnim.Checked = false )
	)

	on cbBuildVolTarget CHANGED theState do
	(
		if( bBuildBones == true ) then
		(
			if(bBuildVolTarget) then bBuildVolTarget = false else bBuildVolTarget = true
		)
		else
		( cbBuildVolTarget.Checked = false )
	)

	ON bSelectFile PRESSED DO
	(

		file = getOpenFileName \
			caption:"Heroes of the Storm" \
			types:"Supported Files|*.m3;*.m3a|Starcraft 2 & Heroes of the Storm(*.m3)|*.m3|Animation Files(*.m3a)|*.m3a|All Files|*.*" \
			historyCategory:"HeroesPresetFolder"

        try
        (
            x = SC2_Standard_Material()
        )
        catch
        (
            bUseSC2ArtTools = false
            cbUseSC2ArtTools.Checked = false
        )


		if(file!=undefined ) then txtSelectedFile.Text = file
	)

	On bGo PRESSED do
	(
		setWaitCursor()
        
		if(txtSelectedFile.Text != undefined and (DoesFileExist txtSelectedFile.Text )) then
		(
            ClearListener()
            gScaleFactor = spinnerScale.value
            try
            (
                Main txtSelectedFile.Text
                PRINT "DONE"
            )
            catch (
                
                format "ERROR OCCURED \n"
                )
			enableSceneRedraw()
			redrawViews()
            
			
		)
		GC()
        enableSceneRedraw()
		RedrawViews()
		setArrowCursor()
        clearSelection()
        max zoomext sel all
        
	)

)