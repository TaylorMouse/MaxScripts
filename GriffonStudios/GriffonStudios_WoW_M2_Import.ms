/*

Version History
---------------
3.6 - April 7th 2020 (Taylor Mouse)
- Support for HD models

3.5 - Dec 16th 2021 (Taylor Mouse)
- Bugfixes

3.2 - Dec 12th 2021 (Taylor Mouse)
- Added base importing of attachmentpoints

3.1 - Sept 11th 2017 (Taylor Mouse)
- Removed error on texture lookup for new model format
- Upgraded code to support MD21 model
- Removed the double quotes around the animation names
- Fixed the issue with importing SC2 controls
- Still an error on the character models

0.304 - July 25th 2010 (Nintox)
- Converted activeX controls to dotnet for 64-bit OS compatibility


0.303 - July 24th 2010 (Nintox)
- Revamped original script to work with new model format
- Vastly improved UI for importing geometry and animations
- Animations no longer suffer from gimbal lock
- Added Import as M3 option
- Vertex normals are now applied semi-properly
- Added basic conversion principles for converting M2 properties to M3
- Added basic error catching


Description:
- Works with 3.* and above World of Warcraft models as of 22-07-2010

Currently imports:
 - Geometry
 - Materials
 - Skin/Bones
 - Animation
 - Attachments
 - Particle Emitters
 - Ribon Emitters
 - Visibility, Parameter Animations
 - Global Animations
 - Billboarding

Special thanks to:
- ufoZ                
- WoWModelViewer team 
- sc2mapster.com      
- Blizzard's art team 


*/
--
-- GLOBALS AND STRUCTURES
--
global WOW2_DBCPath	= "Locate DBC Path"
global AnimDataDBC = "AnimationData.dbc"
global m2impini = ((GetDir #plugcfg)+"\\m2import.ini")
global WOW2_Dialog
global WOW2_ModelUI
global WOW2_ImportMode = #Sc2ArtTools --Can be #NeoDex, #Sc2ArtTools
global WOW2_ImportAsM3 		= true
global WOW2_doVertexNormals = true
global WOW2_useFPS 			= 30	-- fps to rescale animations to
global WOW2_flipuv_y 		= true  -- change this if textures appear upside down
global WOW2_Model_Scale     = 25.0
global M2_V2                = 260  
global WOW2_sc2vers         = 0.4
global filename
global sknFile
global dbcFile
global mdata
global skndata
global dbcdata
global m2bones
global mstream
global sknstream
global step
global ref_index = 0

-- LOOKUP TABLE INFORMATION
-- Attachment String Table
global WOW2_attachid = #("Left wrist (shield) / Mount", "Right Palm", "Left Palm", "Right Elbow", "Left Elbow", -- 0 - 4
					"Right Shoulder", "Left Shoulder", "Right Knee", "Left Knee", "Right Hip", -- 5 - 9
					"Left Hip", "Helmet", "Back", "Right Shoulder Horizontal", "Left Shoulder Horizontal", -- 10 - 14
					"Front Hit Region", "Rear Hit Region", "Mouth", "Head Region", "Base", -- 15 - 19
					"Above", "Pre-Cast 1 L", "Pre-Cast 1 R", "Pre-Cast 2 L", "Pre-Cast 2 R", -- 20 - 24
					"Pre-Cast 3", "Upper Back Sheath R", "Upper Back Sheath L", "Middle Back Sheath", "Belly", -- 25 - 29
					"Reverse Back, Up Back L", "Right Back", "Left Hip Sheath", "Right Hip Sheath", "Spell Impact", -- 30 - 34
					"Right Palm (Unk1)", "Right Palm (Unk2)") -- 35 - 36
	

-- Block F - Bone lookup table.	(Reference taken from the .exe, help from Model Viewer also)	
global WOW2_keyboneid = #(
							"ArmL",				-- 0, Left upper arm
							"ArmR",				-- 1, Right upper arm
							"ShoulderL",		-- 2, Left Shoulder / deltoid area
							"ShoulderR",		-- 3, Right Shoulder / deltoid area
							"SpineLow",			-- 4, (upper?) abdomen
							"Waist",			-- 5, (lower abdomen?) waist
							"Head",				-- 6, head
							"Jaw",				-- 7, jaw/mouth
							"IndexFingerR",	    -- 8, (Trolls have 3 "fingers", this points to the 2nd one.
							"MiddleFingerR",	-- 9, center finger - only used by dwarfs.. don't know why
							"PinkyFingerR",		-- 10, (Trolls have 3 "fingers", this points to the 3rd one.
							"RingFingerR",		-- 11, Right fingers -- this is -1 for trolls, they have no fingers, only the 3 thumb like thingys
							"ThumbR",			-- 12, Right Thumb
							"IndexFingerL",	    -- 13, (Trolls have 3 "fingers", this points to the 2nd one.
							"MiddleFingerL",	-- 14, Center finger - only used by dwarfs.
							"PinkyFingerL",		-- 15, (Trolls have 3 "fingers", this points to the 3rd one.
							"RingFingerL",		-- 16, Left fingers
							"ThumbL",			-- 17, Left Thumb
							"$BTH",				-- 18, Upper-Mouth
							"$CSR",				-- 19, ? Mouth2? Right Palm on characters??
							"$CSL",				-- 20, ? Above Character? Right Palm again on characters??
							"_Breath",			-- 21, ? Mouth on characters (seems like a sound origin?)
							"_Name",			-- 22, Above Character (Not linked to other bones)
							"_NameMount",	    -- 23, Infront of chest (Not linked) 
							"$CHD",				-- 24, Conn to Central Head Bone, used by Event $CHD (Character Head)
							"$CCH",				-- 25, Conn to Upper Chest bone, used by Event $CCH (Character Chest)
							"Root",				-- 26, The "Root" bone,  this controls rotations, transformations, etc of the whole model and all subsequent bones.
							"Wheel1",			-- 27.
							"Wheel2",			-- 28.
							"Wheel3",			-- 29.
							"Wheel4",			-- 30.
							"Wheel5",			-- 31.
							"Wheel6",			-- 32.
							"Wheel7",			-- 33.
							"Wheel8"			-- 34.
						)				
					
global meshTypes = 	#(
									"Mesh", "Facial1", "Facial2", "Facial3", "Braces", "Boots", "Mesh", "Ears",
									"Wristbands", "Kneepads", "Pants", "Pants", "Tabard", "Trousers", "Mesh", "Cape",
									"Mesh", "Eyeglows", "Belt", "Hairstyles"
								)



                                
if ( DisplayWoWAttachments != undefined ) then 
	UnregisterRedrawViewsCallback DisplayWoWAttachments
	
function DisplayWoWAttachments=
(
    gw.setTransform ( matrix3 1 )
    for obj in objects where 
        ( classof obj == Point and obj.ishidden == false and obj.isfrozen == false and (filterstring obj.name " ")[(filterstring obj.name " ").count] == "Ref") 
    do
    (
        gw.text ( obj.pos + [0, 0, 2] ) ( obj.name as string ) color:Yellow
    )
    gw.updateScreen()
    
)
RegisterRedrawViewsCallback DisplayWoWAttachments
                                

function WOW2_RenameBones=
(
    function ReplaceString baseString old new=
    (
        local parts = filterString baseString old
        local newString = ""
        for p=1 to parts.count - 1 do
            newString = newString + parts[p] + new
        
        newString = newString + parts[parts.count]
        
        newString
    )
    local points = #()
    for obj in objects where classof obj == Point and obj.parent != undefined do append points obj
        
    for obj in points do
    (
        if ( findString obj.parent.name "any" != undefined ) then
        (
            local refPos = (findstring obj.name " Ref" ) - 1
            if refPos == undefined then refPos = -1
            local newName = substring obj.name 1 refPos
            local newBoneName = "bone_" + ( ReplaceString newName " " "_" )
            obj.parent.name = newBoneName
        )
    )
    
)

fn WOW2_toUpper str =
(
   if str == undefined do return undefined

   upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   lower = "abcdefghijklmnopqrstuvwxyz"

   outstr = copy str

   for i = 1 to outstr.count do
   (
      j = findString lower outstr[i]
      if j != undefined do outstr[i] = upper[j]
   )
   return outstr
)
                                
fn uiOpenFile ftypes &fname =
(
	local ret = getOpenFileName types:ftypes filename:fname
	if ret != undefined then fname = ret
)
                                

fn sortSpreadsheet data dataField type =
(
	fn sortStrings s1 s2 =
	(
		local ups1 = WOW2_toUpper s1[1]
		local ups2 = WOW2_toUpper s2[1]
		
		case of
		(
			(ups1 < ups2): return -1
			(ups1 > ups2): return 1
			default: return 0
		)
	)
	
	fn sortValues v1 v2 =
	(
		case of
		(
			(v1[1] < v2[1]): return -1
			(v1[1] > v2[1]): return 1
			default: return 0
		)
	)
	
	local dataOrder = #()
    if ( data.count ==0 ) then return undefined
	dataOrder[data.count] = 0
	for i = 1 to data.count do
	(
		dataOrder[i] = data[i].order
	)
	
	local newOrder = #()
	newOrder[data.count] = 0
	for i = 1 to data.count do
	(
		local val
		case dataField of
		(
			#name: val = data[i].name
			#uiIndex: val = data[i].uiIndex
			#verts: val = data[i].nverts
			#faces: val = data[i].nfaces
			#bones: val = data[i].nbones
			#frames: val = data[i].frames
			#rarity: val = data[i].rarity
			#moveSpeed: val = data[i].moveSpeed
		)
		newOrder[i] = #(val, dataOrder[i])
	)
	
	case type of
	(
		#string: qsort newOrder sortStrings
		#value: qsort newOrder sortValues
	)
	
	for i = 1 to newOrder.count do
	(
		local dind = findItem dataOrder newOrder[i][2]
		data[dind].order = i
	)
)                                
                                
-- INI Control
--
-- Check INI setting
fn ReadINI INIFile flag Directory Setting globSett =
(
	-- flag (read as): 1-string 2-bool 3-integer 4-float
	local c = getINISetting (INIFile) (Directory) (Setting)
	
	if (c != "undefined" and c != "") then
	(
		case flag of
		(
			#string: return c
			#bool: return c as booleanClass
			#int: return c as integer
			#float: return c as float
		)
	)
	else
	(
		format "Setting % \\ % not found! Using default setting...\n" Directory Setting
		return globSett
	)
)

-- Read
global ini_section = #("Settings", "Paths")
if (doesFileExist m2impini) then
(
	-- Options
	WOW2_useBones_Points = ReadINI m2impini #bool ini_section[1] "BONES"	WOW2_useBones_Points
	WOW2_useFPS	= ReadINI m2impini #int ini_section[1] "FPS"				WOW2_useFPS
	WOW2_flipuv_y	= ReadINI m2impini #bool ini_section[1] "FlipUV_Y"		WOW2_flipuv_y
	WOW2_doVertexNormals = ReadINI m2impini #bool ini_section[1] "VertexNormals"	WOW2_doVertexNormals
	WOW2_Model_Scale = ReadINI m2impini #float ini_section[1] "M3Scale" WOW2_Model_Scale
	
	-- Paths
	WOW2_DBCPath	= ReadINI m2impini #string ini_section[2] "DBC"			WOW2_DBCPath
)
else
(
	format "% not found! Using default settings...\n" m2impini
)

-- INI Write Function
fn WriteINI INIFile =
(
	--Default Settings
	setINISetting (INIFile)	ini_section[1] ("BONES")			(WOW2_useBones_Points as string)
	setINISetting (INIFile) 	ini_section[1] ("FPS")				(WOW2_useFPS as string)
	setINISetting (INIFile)	ini_section[1] ("FlipUV_Y")			(WOW2_flipuv_y as string)
	setINISetting (INIFile)	ini_section[1] ("VertexNormals")	(WOW2_doVertexNormals as string)
	setINISetting (INIFile)	ini_section[1] ("M3Scale")			(WOW2_Model_Scale as string)
	
	--Path Settings
	setINISetting (INIFile) 	ini_section[2]	("DBC")				(WOW2_DBCPath)
)
-- INI control end!

-- *******************************************
-- **			M2 Reading Code				**
-- *******************************************
--

fn WOW2_Convert_Time t =
(
	t / (1000 / WOW2_useFPS)
)

fn WOW2_Reset_Globals =
(
	-- RESET GLOBALS
	mdata = skndata = dbcdata = m2bones = mstream = sknstream = step = undefined
	gc()
)

--
-- HELPERS
fn echo msg =
(
	format "%\n" (msg) to:listener
)


--Layers
fn WOW2_Setup_Layer name =
(
	local layer = LayerManager.getLayerFromName name
	if layer == undefined then
		layer = LayerManager.newLayerFromName name
	layer
)

fn ReadFixedString bitStream fixedLen =
(
	local str = ""
	for i = 1 to fixedLen do
	(
		str += bit.intAsChar (ReadByte bitStream #unsigned)
	)
	return str
)

fn WOW2_ShortToFloat val = -- Short to Float func
(
	if (val == undefined) then return 0.0
	if (val > 0) then (val -= 32767) else (val += 32768)
	val /= 32767.0
	val
)

fn WOW2_ReadVec bitStream flag array:0 =
(
	local va = #()
	local vec = [0,0,0]
	
	-- Check if array of vectors or single vector
	if array == 0 then 
	(
		count = 1
	)
	else 
	(
		count = array
		-- Initialize array
		va[count] = 0
	)
	
	for i = 1 to count do
	(
		case flag of
		(
			#v2dshort:(vec = [0,0]; vec.x = ReadShort bitStream #unsigned; vec.y = ReadShort bitStream #unsigned)
			#v2dlong:(vec = [0,0]; vec.x = ReadLong bitStream #unsigned; vec.y = ReadLong bitStream #unsigned)
			#v2d:(vec = [0,0]; vec.x = ReadFloat bitStream; vec.y = ReadFloat bitStream)
			#v3dshort: (vec.x = ReadShort bitStream #unsigned; vec.y = ReadShort bitStream #unsigned; vec.z = ReadShort bitStream #unsigned;)
			#v3dlong: (vec.x = ReadLong bitStream #unsigned; vec.y = ReadLong bitStream #unsigned; vec.z = ReadLong bitStream #unsigned;)
			#v3dbyte: (vec.x = ReadByte bitStream #unsigned; vec.y = ReadByte bitStream #unsigned; vec.z = ReadByte bitStream #unsigned;)
			#quat: (vec = quat 0 0 0 1; vec.x = ReadFloat bitStream; vec.y = ReadFloat bitStream; vec.z = ReadFloat bitStream; vec.w = ReadFloat bitStream;)
			#quatShort: 
			(
				vec = quat 1
				vec.x = WOW2_ShortToFloat (ReadShort bitStream #signed)
				vec.y = WOW2_ShortToFloat (ReadShort bitStream #signed)
				vec.z = WOW2_ShortToFloat (ReadShort bitStream #signed)
				vec.w = WOW2_ShortToFloat (ReadShort bitStream #signed)
			)
			#v4dshort: (vec = [0,0,0,0]; vec.x = ReadShort bitStream #signed; vec.y = ReadShort bitStream #signed; vec.z = ReadShort bitStream #signed; vec.w = ReadShort bitStream #signed;)
			#v4dbyte: (vec = [0,0,0,0]; vec.x = ReadByte bitStream; vec.y = ReadByte bitStream; vec.z = ReadByte bitStream; vec.w = ReadByte bitStream;)
			#v3d: (vec = [0.0,0.0,0.0]; vec.x = ReadFloat bitStream; vec.y = ReadFloat bitStream; vec.z = ReadFloat bitStream;)
			#matrix: 
			(
				vma = #()
				vma[4] = 0
				for j = 1 to 4 do
				(
					local vm = [0,0,0,0]
					vm.x = ReadFloat bitStream; vm.y = ReadFloat bitStream; vm.z = ReadFloat bitStream; vm.w = ReadFloat bitStream;
					vma[j] = vm
				)
				vec = matrix3 vma[1] vma[2] vma[3] vma[4]
			)
		)
		if (array != 0) then (va[i] = vec) else (va = vec)
	)
	
	return va
)

fn SkipBytes bitStream count =
(
	local unknown
	case count of
	(
		2: unknown = ReadShort bitStream #unsigned
		4: unknown = ReadLong bitStream #unsigned
		default:
		(
			for i = 1 to count do
			(
				unknown = ReadByte bitStream #unsigned
			)
		)
	)
)
	
fn WOW2_CompareStructs struct1 struct2 =
(
	local structClasses = #(classOf struct1 as string, classOf struct2 as string)
	if (structClasses[1] != structClasses[2]) then return false

	local structProps = getPropNames struct1
	local propCount = structProps.count
	for i = 1 to propCount do
	(
		local propClass = classOf (getProperty struct1 structProps[i]) as string
		if (propClass != "MAXScriptFunction") then
		(
			if ((getProperty struct1 structProps[i]) != (getProperty struct2 structProps[i])) then 
			(
				return false
			)
		)
	)
	
	return true
)

fn WOW2_convert_Position p =
(
	local x = p.x
	p.x = p.y
	p.y = -x
	p.z = p.z
	--p
    local resized = p * [30,30,30]
    
    return resized
)

fn WOW2_convert_Rotation q =
(
	local x = q.x
	q.x = q.y
	q.y = -x
	q
)

fn WOW2_convert_Normal p =
(
	local x = p.x
	p.x = p.y
	p.y = -x
	p
)

fn WOW2_map_array &arr &func =
(
	for a in arr do (func a)
)
--
-- WOW M2 FUNCTIONS

-- ****************************************
-- **			DBC Reading Code			**
-- ****************************************
--
struct WOW2_DBC
(
	head, records
)

struct WOW2_DBC_Header
(
	fileID, nRecords, nFields, recordSize, stringBlockSize,
	
	fn Read bitStream =
	(
		local head = WOW2_DBC_Header()
		head.fileID = ReadFixedString bitStream 4
		head.nRecords = ReadLong bitStream #unsigned
		head.nFields = ReadLong bitStream #unsigned
		head.recordSize = ReadLong bitStream #unsigned
		head.stringBlockSize = ReadLong bitStream #unsigned
		
		return head
	)
)

struct WOW2_DBC_AnimField
(
	animID, name, WeaponState, flags, d1, parentAnimID, realID, aGroup,
	
	fn Read bitStream head =
	(
		local dbcrecords = #()
		dbcrecords[head.nRecords] = 0
		str_ofs = (head.recordSize * head.nRecords) + 20 --header size
		for i = 1 to head.nRecords do
		(
			local af = WOW2_DBC_AnimField()
			af.animID = ReadLong bitStream #unsigned
			af.name = ReadLong bitStream #unsigned
			af.WeaponState = ReadLong bitStream #unsigned
			af.flags = ReadLong bitStream #unsigned
			--af.d1 = ReadLong bitStream #unsigned
			af.parentAnimID = ReadLong bitStream #unsigned
			af.realID = ReadLong bitStream #unsigned
			--af.aGroup = ReadLong bitStream #unsigned
			
			local bm = ftell bitStream
			local nameOfs = (str_ofs + af.name)
			fseek bitStream nameOfs #seek_set 
			af.name	= ReadString bitStream
			fseek bitStream bm #seek_set

			dbcrecords[i] 	= af
		)
		
		return dbcrecords		
	)
)

fn WOW2_DBC_AnimDBC dbcfile =
(
	local dbcstream
	try
	(
		dbcstream = fopen dbcfile "rb"
		if dbcstream==undefined then 
		(
			echo (dbcfile + " not found!")
			return undefined
		)
		
		local adbc = WOW2_DBC()
		adbc.head = WOW2_DBC_Header.Read dbcstream
		if (adbc.head.fileID != "WDBC") then
		(
			echo (dbcfile + " invalid DBC file!")
			if (dbcstream != undefined) then fclose dbcstream
			return undefined
		)
		adbc.records = WOW2_DBC_AnimField.Read dbcstream adbc.head
		
		if (dbcstream != undefined) then fclose dbcstream
		
		return adbc
	)
	catch
	(
		echo (dbcfile + " unreadable! DBC file not used")
		if dbcstream != undefined then fclose dbcstream
		return undefined
	)
)

fn WOW2_FillMeditorWithVisible =
(
	macros.run "Medit Tools" "clear_medit_slots"
	local visibleGeo = for g in geometry where not g.isHiddenInVpt collect g
	local usedMat = #()
	for g in visibleGeo do
	(
		local curMat = g.material
		if curMat != undefined and finditem usedMat curMat == 0 do append usedMat curMat
	)
	for n in 1 to usedMat.count do
	(
		if n <= meditMaterials.count do medit.PutMtlToMtlEditor usedMat[n] n
	)
)

-- ****************************************
-- **			Model Reading Code			**
-- ****************************************
--

struct WOW2_Sphere
(
	vmin, vmax, rad,
	
	fn Read bitStream =
	(
		local s = WOW2_Sphere()
		s.vmin = WOW2_ReadVec bitStream #v3d -- +12 
		s.vmax = WOW2_ReadVec bitStream #v3d -- +12
		s.rad = ReadFloat bitStream -- +4
		
		return s
	)
)

struct WOW2_Entry
(
	nEntry, ofsEntry,
	
	fn Read bitStream =
	(
		local entry = WOW2_Entry()
		entry.nEntry = ReadLong bitStream #unsigned
		entry.ofsEntry = ReadLong bitStream #unsigned
		
		return entry
	),
	fn Setup bitStream entry =
	(
        
        fseek bitStream 0 #seek_set
        local ver = ReadFixedString bitStream 4
        
        local versionoffset = 0

        if (ver =="MD21" ) then versionOffset = 8 -- Added by TM
        
		local earray = #()
		if (entry.nEntry > 0) then
		(
			earray[entry.nEntry] = 0
			fseek bitStream (entry.ofsEntry + versionOffset) #seek_set
		)
		
		return earray
	)
)

fn WOW2_ReadData bitStream entry type =
(
	local darray
	local bm = ftell bitStream
	if (type != #string) then
	(
		darray = WOW2_Entry.Setup bitStream entry
	)
	else
	(
		darray = ""
        
        fseek bitStream 0 #seek_set
        local ver = ReadFixedString bitStream 4
        local versionoffset = 0
        if (ver =="MD21" ) then versionOffset = 8 -- Added by TM
        
		fseek bitStream ( entry.ofsEntry + versionOffset ) #seek_set
	)
	
	for i = 1 to entry.nEntry do
	(
		case type of
		(
			#string:
			(
                
				darray += bit.intAsChar (ReadByte bitStream #unsigned)
			)
			#vertProps:
			(
				local vprops = #()
				for j = 1 to 4 do
				(
					local vp = ReadByte bitStream #unsigned
					
					append vprops vp
				)
				darray[i] = vprops
			)
			#boolean: darray[i] = ReadByte bitStream #unsigned
			#int16: darray[i] = ReadShort bitStream #signed
			#uint16: darray[i] = ReadShort bitStream #unsigned
			#uint32: darray[i] = ReadLong bitStream #unsigned
			#float: darray[i] = ReadFloat bitStream
			#frames: darray[i] = WOW2_Convert_Time (ReadLong bitStream #unsigned)
			#v3d: darray[i] = WOW2_ReadVec bitStream #v3d
			#quat: darray[i] = WOW2_ReadVec bitStream #quatShort
		)
	)
	
	fseek bitStream bm #seek_set
	
	return darray
)

global WOW2_Materials

struct WOW2_Header
(
	fileID, version,
	name,
	type,
	GlobalSequences,
	anims, animsLU,
	Bones, KeyBones,
	Verts,
	nViews,
	GeoAnims, Textures, Trans,
	TexAnims, TexReplace,
	RenderFlags,
	BonesLU,
	TexLU, TexUnitsLU, TransLU, TexAnimsLU,
	collisionSphere, boundSphere,
	BoundTris, BoundVerts, BoundNorms,
	Attachs, AttachsLU,
	Events,
	Lights,
	Cameras, CamerasLU,
	Ribbons,
	Particles,
	
	fn Read bitStream =
	(
		local header = WOW2_Header()
		local versionOffset = 0
        
		header.fileID = (ReadFixedString bitStream 4)
        
        if (header.fileID == "MD21" )  then 
        (
            local fileSize = ReadLong bitStream
            local md20 = ReadFixedString bitStream 4
        )
        
        
		header.version = ReadLong bitStream #unsigned -- 272 => old model new format, 274 => new model new format
		header.name = WOW2_Entry.Read bitStream
		header.type = ReadLong bitStream #unsigned
		header.GlobalSequences = WOW2_Entry.Read bitStream
		header.anims = WOW2_Entry.Read bitStream
		header.animsLU = WOW2_Entry.Read bitStream
		header.Bones = WOW2_Entry.Read bitStream
		header.KeyBones = WOW2_Entry.Read bitStream
		header.Verts = WOW2_Entry.Read bitStream
        
		header.nViews = ReadLong bitStream #unsigned
		header.GeoAnims = WOW2_Entry.Read bitStream
		header.Textures = WOW2_Entry.Read bitStream
		header.Trans = WOW2_Entry.Read bitStream
		header.TexAnims = WOW2_Entry.Read bitStream
		header.TexReplace = WOW2_Entry.Read bitStream
		header.RenderFlags = WOW2_Entry.Read bitStream
		header.BonesLU = WOW2_Entry.Read bitStream
		header.TexLU = WOW2_Entry.Read bitStream
		header.TexUnitsLU = WOW2_Entry.Read bitStream
		header.TransLU = WOW2_Entry.Read bitStream
		header.TexAnimsLU = WOW2_Entry.Read bitStream
		header.collisionSphere = WOW2_Sphere.Read bitStream
		header.boundSphere = WOW2_Sphere.Read bitStream
		header.boundTris = WOW2_Entry.Read bitStream
		header.boundVerts = WOW2_Entry.Read bitStream
		header.boundNorms = WOW2_Entry.Read bitStream
		header.Attachs = WOW2_Entry.Read bitStream
		header.AttachsLU = WOW2_Entry.Read bitStream
		header.Events = WOW2_Entry.Read bitStream
		header.Lights = WOW2_Entry.Read bitStream
		header.Cameras = WOW2_Entry.Read bitStream
		header.CamerasLU = WOW2_Entry.Read bitStream
		header.Ribbons = WOW2_Entry.Read bitStream
		header.Particles = WOW2_Entry.Read bitStream
		
        ClearListener()
        
        --print header
        
        
		return header
	)
)

struct WOW2_Bezier
(
	pos = [0,0,0], inTan = [0,0,0], outTan = [0,0,0]
)

struct WOW2_Vertex
(
	pos,bw = #(),bi = #(),normal,uv,n2floats,
	
	fn Read bitStream entry =
	(
		local varray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local vert = WOW2_Vertex()
			vert.pos = WOW2_ReadVec bitStream #v3d
			
			-- Weights
			m2weights = #()
			for j = 1 to 4 do 
			(
				local bWeight = ReadByte bitStream #unsigned
				append m2weights bWeight
			)
			
			-- Bone Indices
			m2bindices = #()
			for j = 1 to 4 do 
			(
				local bIndice = ReadByte bitStream #unsigned
				bIndice = bIndice
				append m2bindices bIndice
			)
			
			-- Build true weights/bone indices
			vert.bi = #()
			vert.bw = #()
			for j = 1 to 4 do
			(
				local weight = m2weights[j]
				local bind = m2bindices[j]
				if (weight > 0) then
				(
					local w = weight / 255.0
					local b = bind + 1 -- maxscript arrays are 1-based
					
					append vert.bw w
					append vert.bi b
				)
			)
			
			vert.normal = WOW2_ReadVec bitStream #v3d
			
			-- UV coordinates
			-- must be point3 when building mesh
			vert.uv = [0,0,0]
			for j = 1 to 2 do
			(
				local uv = ReadFloat bitStream
				if (j == 2 and WOW2_flipuv_y == true) then uv = 1 - uv
				vert.uv[j] = uv
			)
			
			vert.n2floats = #()
			for j = 1 to 2 do
			(
				local f = ReadFloat bitStream
				append vert.n2floats f
			)
			
			varray[i] = vert
		)
		
		return varray
	)
)

struct WOW2_SC2_SEQS
(
	name, cstart, cend, moveSpeed, looping, rarity, priority
)

struct WOW2_Animation
(
	animID, subanimID, frames, 
	moveSpeed, flags, rarity, playSpeed, 
	boundSphere, animLink, index,
	name, cstart, cend, animFile, process = true,
	uiIndex, order, loops,
	
	fn Read bitStream entry =
	(
		local animArray = WOW2_Entry.Setup bitStream entry
        

        
		for i = 1 to animArray.count do
		(
			local anim = WOW2_Animation()
			
			anim.animID = ReadShort bitStream #unsigned -- 2
			anim.subanimID = ReadShort bitStream #unsigned -- 4
			local frames = ReadLong bitStream #unsigned -- 8
			anim.frames = WOW2_Convert_Time frames
			anim.moveSpeed = ReadFloat bitStream --12
			anim.flags = ReadLong bitStream #unsigned -- 16
			local rarity = ReadShort bitStream #unsigned -- 18
			rarity = (rarity / 32767.0) * 100
			anim.rarity = rarity as integer
			SkipBytes bitStream 10 -- 28
			anim.playSpeed = ReadLong bitStream #unsigned -- 32
			anim.boundSphere = WOW2_Sphere.Read bitStream -- 60
			anim.animLink = ReadShort bitStream #signed -- +2
			anim.index = ReadShort bitStream #unsigned -- +2
			anim.loops = bit.get anim.flags 6 
			anim.uiIndex = i - 1
			anim.order = i
			
			animArray[i] = anim
		)
		
		return animArray
	)
)

global WOW2_GlobalSequences

-- Necessary for Sc2
struct WOW2_GlobalSequence
(
	id, start, end, numObjects = 0,
	objects = #(), properties = #(), animBlocks = #(), 
	funcs = #(), funcUsesProperty = #(), anim,
	fn register obj animBlock func isUsed property =
	(
		local index = findItem animBlocks animBlock
		if index == 0 then
		(
			numObjects = numObjects + 1
			objects[numObjects] = #(obj)
			animBlocks[numObjects] = animBlock
			properties[numObjects] = property
			funcs[numObjects] = func
			funcUsesProperty[numObjects] = isUsed
		)
		else
			append objects[index] obj
	)
)

fn WOW2_Generate_GlobalSequences gbEntry mstream =
(
	local lengthes = WOW2_ReadData mstream gbEntry #frames
	local n = lengthes.count
	local result = #()
	if (n > 0) then result[n] = undefined
	for i = 1 to n do
	(
		result[i] = WOW2_GlobalSequence ()
		result[i].id = i
		result[i].start = 0
		result[i].end = lengthes[i]
	)
	WOW2_GlobalSequences = result
	result
)

struct WOW2_AnimBlock
(
	type, seq, times, keys,
	
	fn Read bitStream =
	(
		local ab = WOW2_AnimBlock()
		
		ab.type = ReadShort bitStream #unsigned
		ab.seq = ReadShort bitStream #signed
		ab.times = WOW2_Entry.Read bitStream
		ab.keys = WOW2_Entry.Read bitStream
		
		return ab
	),
	fn GetData bitStream anims abdata flags =
	(
		tarray = #()
		if (abdata.nEntry > 0) then
		(
			tarray = WOW2_Entry.Setup bitStream abdata
			-- Grab entries
			for i = 1 to tarray.count do
			(
				tarray[i] = WOW2_Entry.Read bitStream
			)
			
			-- Fill data from entries
			for i = 1 to tarray.count do
			(
				local anim = anims[i]
				local ent = tarray[i]
				
				if (ent.nEntry > 0 and anim.process == true) then
				(
					local dataStream
					if anim.animFile != undefined then
					(
						if (getFileSize anim.animFile > ent.ofsEntry) then dataStream = fopen anim.animFile "rb"
						if (dataStream != undefined) then tarray[i] = WOW2_ReadData dataStream tarray[i] flags
					)
					
					if (dataStream == undefined) then
					(
						tarray[i] = WOW2_ReadData bitStream tarray[i] flags
					)
					else
					(
						fclose dataStream
					)
				)
				else
				(
					tarray[i] = #()
				)
			)
		)
		return tarray
	),
	fn Fill bitStream anims ablock flags =
	(
		-- do time entries first
		ablock.times = WOW2_AnimBlock.GetData bitStream anims ablock.times #frames
		ablock.keys = WOW2_AnimBlock.GetData bitStream anims ablock.keys flags
	)
)

struct WOW2_Parameter
(
	animated = false,
	val = undefined,
	type = undefined,
	fn Fill bitStream param anims dataType isNotVisibility:true =
	(
		local result = WOW2_Parameter ()
		result.type = dataType
		if param.type == 0 and isNotVisibility then
		(
			local tarray = WOW2_Entry.Setup bitStream param.keys
			tarray[1] = WOW2_Entry.Read bitStream
			result.val = WOW2_ReadData bitStream tarray[1] dataType
			result.val = result.val[1]
		)
		else
		(
			result.animated = true
			WOW2_AnimBlock.Fill bitStream anims param dataType
			result.val = param
		)
		result
	)
)

struct WOW2_FakeAnimBlock
(
	times, keys,
	
	fn Read bitStream &readfn =
	(
		local ab = WOW2_FakeAnimBlock()
		ab.times = #()
		ab.keys = #()
		local size = readLong bitStream #unsigned
		local place = readLong bitStream #unsigned
		if size > 0 then
		(
			ab.times[size] = undefined
			local rem = ftell bitStream
			fseek bitStream place #seek_set
			for i = 1 to size do
				ab.times[i] = readFloat bitStream
			fseek bitStream rem #seek_set
		)
		size = readLong bitStream #unsigned
		place = readLong bitStream #unsigned
		if size > 0 then
		(
			ab.keys[size] = undefined
			rem = ftell bitStream
			fseek bitStream place #seek_set
			for i = 1 to size do
				ab.keys[i] = readfn bitStream
			fseek bitStream rem #seek_set
		)
		ab
	)
)

fn WOW2_convertAnimBlock val &func =
(
	for k in val.keys do
	(
		for i = 1 to k.count do
		(
			k[i] = func k[i] 
		)
	)
)

fn WOW2_convertParam param &func =
(
	if param.animated then
		WOW2_convertAnimBlock param.val func
	else
		param.val = func param.val
)

fn WOW2_qdot q1 q2 = return ((q1.x*q2.x) + (q1.y*q2.y) + (q1.z*q2.z) + (q1.w*q2.w))

--From my NeoDex Importer
fn WOW2_writeKeys ablock controller =
(
	local keys = ablock.keys
	local times = ablock.times
	for i = 1 to keys.count do
	(
		
		local key = addNewKey controller times[i]
		key.value = keys[i]
	)
)

fn WOW2_fixQuaternions keys =
(
	for i = 2 to keys.count do
	(
		local q1 = keys[i], q2 = keys[i-1]
		if (WOW2_qdot q1 q2) < 0 then keys[i] = -q1
	)
)

struct WOW2_UVAnimation
(
	translation, rotation, scale,
	U_offset, V_offset,
	U_angle, V_angle, W_angle,
	U_tile, V_tile,
	fn Read bitStream entry =
	(
		local barray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local m2uv = WOW2_UVAnimation()
			m2uv.translation = WOW2_AnimBlock.Read bitStream
			m2uv.rotation = WOW2_AnimBlock.Read bitStream
			m2uv.scale = WOW2_AnimBlock.Read bitStream
			barray[i] = m2uv
		)
		return barray
	),
	fn getAnimBlockCopy ablock =
	(
		local nablock = copy ablock
		nablock.times = copy ablock.times #nomap
		nablock.keys = undefined
		nablock
	),
	fn splitKeys keys func param =
	(
		local result = #()
		local n = keys.count
		if (n > 0) then result[n] = undefined
		for i = 1 to n do
			result[i] = func keys[i] param
		result
	),
	fn split =
	(
		fn func1 p index = p[index]
		fn func2 ea index =
		(
			case index of
			(
				1: ea.x
				2: ea.y
				3: ea.z
				default:undefined
			)
		)
		U_offset = getAnimBlockCopy translation
		U_offset.keys = splitKeys translation.keys func1 1
		V_offset = getAnimBlockCopy translation
		V_offset.keys = splitKeys translation.keys func1 2
		U_angle = getAnimBlockCopy rotation
		U_angle.keys = splitKeys rotation.keys func2 1
		V_angle = getAnimBlockCopy rotation
		V_angle.keys = splitKeys rotation.keys func2 2
		W_angle = getAnimBlockCopy rotation
		W_angle.keys = splitKeys rotation.keys func2 3
		U_tile = getAnimBlockCopy scale
		U_tile.keys = splitKeys scale.keys func1 1
		V_tile = getAnimBlockCopy scale
		V_tile.keys = splitKeys scale.keys func1 2
		translation = undefined
		rotation = undefined
		scale = undefined
	)
)

struct WOW2_GeosetAnimation
(
	color, alpha,
	fn Read bitStream entry =
	(
		local barray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local m2geoAnim = WOW2_GeosetAnimation()
			m2geoAnim.color = WOW2_AnimBlock.Read bitStream
			m2geoAnim.alpha = WOW2_AnimBlock.Read bitStream
			barray[i] = m2geoAnim
		)
		return barray
	)
)

struct WOW2_Bone
(
	keyIndex, flags, parent, s1, abtrans, abrot, abscale, pivot,
	maxObj, visibility,
	
	fn Read bitStream entry =
	(
		local barray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local m2bone = WOW2_Bone()
			
			m2bone.keyIndex = (ReadLong bitStream #signed) + 1
			m2bone.flags = ReadLong bitStream #unsigned
			m2bone.parent = (ReadShort bitStream #signed) + 1
			local s1a = #()
			for j = 1 to 3 do append s1a (ReadShort bitStream #unsigned)
			m2bone.s1 = s1a
			m2bone.abtrans = WOW2_AnimBlock.Read bitStream
			m2bone.abrot = WOW2_AnimBlock.Read bitStream
			m2bone.abscale = WOW2_AnimBlock.Read bitStream
			m2bone.pivot = WOW2_ReadVec bitStream #v3d
			barray[i] = m2bone
		)
		return barray
	)
)

struct WOW2_Light
(
	id,type, parent, position, ambientColor, ambientIntensity,
	diffuseColor, diffuseIntensity, attenuationStart, attenuationEnd,
	visibility, maxObj,
	fn show l =
	(
-- 		print ("Light " + (l.id as string) + ": ")
-- 		print l.type
-- 		print l.parent
-- 		print l.position
-- 		print l.ambientColor
-- 		print l.ambientIntensity
-- 		print l.diffuseColor
-- 		print l.diffuseIntensity
-- 		print l.attenuationStart
-- 		print l.attenuationEnd
-- 		print l.visibility
	),
	fn Read bitStream entry =
	(
		local barray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local m2light = WOW2_Light()
			m2light.id = i
			m2light.type = ReadShort bitStream #unsigned
			m2light.parent = (ReadShort bitStream #signed) + 1
			m2light.position = WOW2_ReadVec bitStream #v3d
			m2light.ambientColor = WOW2_AnimBlock.Read bitStream
			m2light.ambientIntensity = WOW2_AnimBlock.Read bitStream
			m2light.diffuseColor = WOW2_AnimBlock.Read bitStream
			m2light.diffuseIntensity = WOW2_AnimBlock.Read bitStream
			m2light.attenuationStart = WOW2_AnimBlock.Read bitStream
			m2light.attenuationEnd = WOW2_AnimBlock.Read bitStream
			m2light.visibility = WOW2_AnimBlock.Read bitStream
			barray[i] = m2light
		)
		barray
	)
)

struct WOW2_RibbonEmitter
(
	id, parent, position, textures, blends,
	color, opacity, above, below,
	edgeEmission, lifeSpan, emissionAngle, 
	renderFlags, textureSlot, visibility, unknown,
	maxObj,
	fn show r =
	(
-- 		print ("RibbonEmitter " + (r.id as string) + ": ")
-- 		print r.parent
-- 		print r.position
-- 		print r.textures
-- 		print r.blends
-- 		print r.color
-- 		print r.opacity
-- 		print r.above
-- 		print r.below
-- 		print r.edgeEmission
-- 		print r.lifeSpan
-- 		print r.emissionAngle
-- 		print r.renderFlags
-- 		print r.textureSlot
-- 		print r.visibility
-- 		print r.unknown
	),
	fn Read bitStream entry =
	(
		local barray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local m2ribbon = WOW2_RibbonEmitter()
			
			m2ribbon.id = ReadLong bitStream #unsigned
			m2ribbon.id = i
			m2ribbon.parent = (ReadLong bitStream #signed) + 1
			m2ribbon.position = WOW2_ReadVec bitStream #v3d
			--textures
			local nTextures = ReadLong bitStream #unsigned
			local offsetTextures = ReadLong bitStream #unsigned
			local rem = ftell bitStream
			fseek bitStream offsetTextures #seek_set
			local textures = #()
			textures[nTextures] = undefined
			for i = 1 to nTextures do
				textures[i] = ReadShort bitStream #unsigned
			fseek bitStream rem #seek_set
			m2ribbon.textures = textures
			--blends
			local nBlends= ReadLong bitStream #unsigned
			local offsetBlends = ReadLong bitStream #unsigned
			rem = ftell bitStream
			fseek bitStream offsetBlends #seek_set
			local blends = #()
			blends[nBlends] = undefined
			for i = 1 to nBlends do
				blends[i] = ReadShort bitStream #unsigned
			fseek bitStream rem #seek_set
			m2ribbon.blends = blends
			-- go on
			m2ribbon.color = WOW2_AnimBlock.Read bitStream
			m2ribbon.opacity = WOW2_AnimBlock.Read bitStream
			m2ribbon.above = WOW2_AnimBlock.Read bitStream
			m2ribbon.below = WOW2_AnimBlock.Read bitStream
			m2ribbon.edgeEmission = ReadFloat bitStream
			m2ribbon.lifeSpan = ReadFloat bitStream
			m2ribbon.emissionAngle = ReadFloat bitStream
			m2ribbon.renderFlags = readLong bitStream #unsigned
			m2ribbon.textureSlot = WOW2_AnimBlock.Read bitStream
			m2ribbon.visibility = WOW2_AnimBlock.Read bitStream
			m2ribbon.unknown = readLong bitStream #unsigned
			barray[i] = m2ribbon
		)
		barray
	)
)

struct WOW2_ParticleEmitter
(
	id,
	flags,
	position,
	bone,
	texture,
	nModelName,
	ofsModelName,
	nParticleFileName,
	ofsParticleFileName,
	blend,
	Emitter_type,
	colorSet,
	ParticleType,
	HeadorTail,
	Texturerot,
	rows,
	cols,
	emissionspeed,
	Speed_var,
	Vertical_range,
	Horizontal_range,
	Gravity,
	Lifespan,
	paddingoO,
	Emissionrate,
	paddingoO2,
	Emissionarea_length,
	Emissionarea_width,
	Gravity_strong,
	Colors,
	UOpacity,
	Vec2DScale,
	d,
	Uensity,
	Uunk2,
	unk,
	scale,
	slowdown,
	unks1,
	rotation,
	unks2,
	Rot1,
	Rot2,
	Trans,
	f2,
	unknown3,
	ofsUnknownReferenc,
	visibility,
	unknown4,
	maxObj,
	fn showFlags flags =
	(
		--print (bit.intAsHex flags)
		for i = 1 to 32 do
		(
			--print ("Flag " + (i as string) + ": " + ((bit.get flags i) as string))
		)
	),
	fn show m2particle =
	(
-- 		print ("Particle Emitter " + (m2particle.id as string) + ": ")
-- 		print m2particle.id
-- 		print "Flags: "
		WOW2_ParticleEmitter.showFlags m2particle.flags
-- 		print m2particle.position
-- 		print m2particle.bone
-- 		print m2particle.texture
-- 		print m2particle.nModelName
-- 		print m2particle.ofsModelName
-- 		print m2particle.nParticleFileName
-- 		print m2particle.ofsParticleFileName
-- 		print m2particle.blend
-- 		print m2particle.Emitter_type
-- 		print m2particle.colorSet
-- 		print m2particle.ParticleType
-- 		print m2particle.HeadorTail
-- 		print m2particle.Texturerot
-- 		print m2particle.rows
-- 		print m2particle.cols
-- 		print m2particle.emissionspeed
-- 		print m2particle.Speed_var
-- 		print m2particle.Vertical_range
-- 		print m2particle.Horizontal_range
-- 		print m2particle.Gravity
-- 		print m2particle.Lifespan
-- 		print m2particle.paddingoO
-- 		print m2particle.Emissionrate
-- 		print m2particle.paddingoO2
-- 		print m2particle.Emissionarea_length
-- 		print m2particle.Emissionarea_width
-- 		print m2particle.Gravity_strong
-- 		print m2particle.Colors
-- 		print m2particle.UOpacity
-- 		print m2particle.Vec2DScale
-- 		print m2particle.d
-- 		print m2particle.Uensity
-- 		print m2particle.Uunk2
-- 		print m2particle.unk
-- 		print m2particle.scale
-- 		print m2particle.slowdown
-- 		print m2particle.unks1
-- 		print m2particle.rotation
-- 		print m2particle.unks2
-- 		print m2particle.Rot1
-- 		print m2particle.Rot2
-- 		print m2particle.Trans
-- 		print m2particle.f2
-- 		print m2particle.unknown3
-- 		print m2particle.ofsUnknownReferenc
-- 		print m2particle.visibility
-- 		print m2particle.unknown4
	),
	fn Read bitStream entry =
	(
		local barray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local m2particle = WOW2_ParticleEmitter()
			m2particle.id = ReadLong bitStream #signed
			m2particle.id = i
			m2particle.flags = ReadLong bitStream #unsigned
			m2particle.position = WOW2_ReadVec bitStream #v3d
			m2particle.bone = ReadShort bitStream #unsigned
			m2particle.texture = ReadShort bitStream #unsigned
			m2particle.nModelName = ReadLong bitStream #unsigned
			m2particle.ofsModelName = ReadLong bitStream #unsigned
			m2particle.nParticleFileName = ReadLong bitStream #unsigned
			m2particle.ofsParticleFileName = ReadLong bitStream #unsigned
			m2particle.blend = ReadByte bitStream #unsigned
			m2particle.Emitter_type = ReadByte bitStream #unsigned
			m2particle.colorSet = ReadShort bitStream #unsigned
			m2particle.ParticleType = ReadByte bitStream #unsigned
			m2particle.HeadorTail = ReadByte bitStream #unsigned
			m2particle.Texturerot = ReadShort bitStream #signed
			m2particle.rows = ReadShort bitStream #unsigned
			m2particle.cols = ReadShort bitStream #unsigned
			m2particle.emissionspeed = WOW2_AnimBlock.Read bitStream
			m2particle.Speed_var = WOW2_AnimBlock.Read bitStream
			m2particle.Vertical_range = WOW2_AnimBlock.Read bitStream
			m2particle.Horizontal_range = WOW2_AnimBlock.Read bitStream
			m2particle.Gravity = WOW2_AnimBlock.Read bitStream
			m2particle.Lifespan = WOW2_AnimBlock.Read bitStream
			m2particle.paddingoO = ReadLong bitStream #unsigned
			m2particle.Emissionrate = WOW2_AnimBlock.Read bitStream
			m2particle.paddingoO2 = ReadLong bitStream #unsigned
			m2particle.Emissionarea_length = WOW2_AnimBlock.Read bitStream
			m2particle.Emissionarea_width = WOW2_AnimBlock.Read bitStream
			m2particle.Gravity_strong = WOW2_AnimBlock.Read bitStream
			local readVec3f = fn tmp1 bs =
			(
				local p = [0,0,0]
				p.x = readFloat bs
				p.y = readFloat bs
				p.z = readFloat bs
				p
			)
			local readVec2f = fn tmp2 bs =
			(
				local p = [0,0]
				p.x = readFloat bs
				p.y = readFloat bs
				p
			)
			local readUshort = fn tmp3 bs =
			(
				readShort bs #unsigned
			)
			m2particle.Colors = WOW2_FakeAnimBlock.Read bitStream readVec3f
			m2particle.UOpacity = WOW2_FakeAnimBlock.Read bitStream readUshort
			m2particle.Vec2DScale = WOW2_FakeAnimBlock.Read bitStream readVec2f
			m2particle.d = WOW2_ReadVec bitStream #v2dlong
			m2particle.Uensity = WOW2_FakeAnimBlock.Read bitStream readUshort
			m2particle.Uunk2 = WOW2_FakeAnimBlock.Read bitStream readUshort
			m2particle.unk = WOW2_ReadVec bitStream #v3d
			m2particle.scale = WOW2_ReadVec bitStream #v3d
			m2particle.slowdown = ReadFloat bitStream
			m2particle.unks1 = WOW2_ReadVec bitStream #v2d
			m2particle.rotation = ReadFloat bitStream
			m2particle.unks2 = WOW2_ReadVec bitStream #v2d
			m2particle.Rot1 = WOW2_ReadVec bitStream #v3d
			m2particle.Rot2 = WOW2_ReadVec bitStream #v3d
			m2particle.Trans = WOW2_ReadVec bitStream #v3d
			local a = #()
			for i = 1 to 4 do a[i] = ReadFloat bitStream
			m2particle.f2 = a
			m2particle.unknown3 = ReadLong bitStream #signed
			m2particle.ofsUnknownReferenc = ReadLong bitStream #signed
			m2particle.visibility = WOW2_AnimBlock.Read bitStream
			a = #()
			for i = 1 to 4 do a[i] = ReadLong bitStream #unsigned
			m2particle.unknown4 = a
			barray[i] = m2particle
		)
		barray
	)
)

struct WOW2_Submesh
(
	id, 
    show = false, --> for MAX only by TM
    indverts, nverts, indfaces, nfaces,
	nbones, indbones,
	s1,b1,
	boundSphere,
	geoAnim = undefined,
	m2verts = #(), maxMesh, process = true,
	name, uiIndex, order, -- for UI only
	
	fn Read bitStream entry =
	(
		local smarray = WOW2_Entry.Setup bitStream entry
		for i = 1 to entry.nEntry do
		(
			local submesh = WOW2_Submesh()
			
			submesh.id = ReadLong bitStream #unsigned
			submesh.indverts = ReadShort bitStream #unsigned
			submesh.nverts = ReadShort bitStream #unsigned
			submesh.indfaces = ReadShort bitStream #unsigned
			submesh.nfaces = ReadShort bitStream #unsigned
			submesh.nbones = ReadShort bitStream #unsigned
			submesh.indbones = ReadShort bitStream #unsigned
			submesh.s1 = ReadShort bitStream #unsigned
			submesh.b1 = ReadShort bitStream #unsigned
			submesh.boundSphere = WOW2_Sphere.Read bitStream
			submesh.uiIndex = i - 1
			submesh.order = i
			
			local subid = submesh.id / 100
			if (subid == 0) then
			(
				-- Hairstyles
				if ((mod subid 100) > 0) then subid = 21 else subid += 1 
			)
			else
			(
				subid += 1
			)
			submesh.name = meshTypes[subid]
			if submesh.id < 2 then submesh.name = "Main"
            if submesh.id > 1 and submesh.id < 100  then submesh.name = "Hairstyle"
            if submesh.id > 67000 and submesh.id < 67500  then submesh.name = "BigBelt"
            if submesh.id > 67500 then submesh.name = "Body"
                
            
            if ( i > 1 and smarray[i-1].name != submesh.name ) then submesh.show = true
            if submesh.id < 2  then submesh.show = true
            
			smarray[i] = submesh
            --print submesh
		)
		
		return smarray
	)
)
	
struct WOW2_TexUnit
(
	id, texFlags, shaderFlags,
	SubInd, SubInd2,
	ColourInd, renderFlagsInd,
	TexUnitInd, Mode, TexInd, TexUnitInd2,
	TransInd, TexAnimInd,
	maxMaterial,
	
	fn Read bitStream entry =
	(
		local tuarray = WOW2_Entry.Setup bitStream entry
		
		for i = 1 to entry.nEntry do
		(
			local TexUnit = WOW2_TexUnit()
			TexUnit.id = i
			TexUnit.texFlags = ReadShort bitStream #unsigned
			TexUnit.shaderFlags = ReadShort bitStream #unsigned
			TexUnit.SubInd = (ReadShort bitStream #unsigned) + 1
			TexUnit.SubInd2 = (ReadShort bitStream #unsigned) + 1
			TexUnit.ColourInd = (ReadShort bitStream #signed) + 1
			TexUnit.renderFlagsInd = (ReadShort bitStream #unsigned) + 1
			TexUnit.TexUnitInd = (ReadShort bitStream #unsigned) + 1
			TexUnit.Mode = ReadShort bitStream #unsigned
			TexUnit.TexInd = (ReadShort bitStream #unsigned) + 1
			TexUnit.TexUnitInd2 = (ReadShort bitStream #unsigned) + 1
			TexUnit.TransInd = (ReadShort bitStream #unsigned) + 1
			TexUnit.TexAnimInd = (ReadShort bitStream #unsigned) + 1
			
			tuarray[i] = TexUnit
		)
		
		return tuarray
	)
)

struct WOW2_SkinHeader 
(
	fileID, 
	Indices, Faces, VertInds,
	Submeshes, TexUnits,
	nSkinnedBones,
	
	fn Read bitStream =
	(
		local shead = WOW2_SkinHeader()
		
		shead.fileID = (ReadFixedString bitStream 4)
		if (shead.fileID != "SKIN") then throw "Invalid SKIN file!"
		shead.Indices = WOW2_Entry.Read bitStream
		shead.Faces = WOW2_Entry.Read bitStream
		shead.VertInds = WOW2_Entry.Read bitStream
		shead.Submeshes = WOW2_Entry.Read bitStream
		shead.TexUnits = WOW2_Entry.Read bitStream
		shead.nSkinnedBones = ReadLong bitStream #unsigned
		
		return shead
	),
	fn Fill bitStream skinData =
	(
		skinData.Indices = WOW2_ReadData bitStream skinData.Indices #uint16
		skinData.Faces = WOW2_ReadData bitStream skinData.Faces #uint16
		skinData.VertInds = WOW2_ReadData bitStream skinData.VertInds #vertProps
		skinData.Submeshes = WOW2_Submesh.Read bitStream skinData.Submeshes
		skinData.TexUnits = WOW2_TexUnit.Read bitStream skinData.TexUnits
	)
)

struct WOW2_Texture
(
	-- type:
	--0  Texture given in filename
	--1  Body + clothes
	--2  Cape
	--6  Hair, beard
	--8  Tauren fur
	--11  Skin for creatures
	--12  Skin for creatures #2
	--13  Skin for creatures #3

	type, flags, texFile,
	filename, convfilename,
	
	fn Read bitStream entry =
	(
		local texArray = WOW2_Entry.Setup bitStream entry
		
		for i = 1 to entry.nEntry do
		(
			local tex = WOW2_Texture()
			
			tex.type = ReadLong bitStream #unsigned
			tex.flags = ReadLong bitStream #unsigned
			tex.texFile = WOW2_Entry.Read bitStream
			tex.texFile = WOW2_ReadData mstream tex.texFile #string
			
			texArray[i] = tex
		)
		
		return texArray
	)
)

struct WOW2_Attachment
(
	id, bone, flags, pos, vis, -- vis = Animation Block for visibility, assuming (Short Keys: 0 = off, 1 = on)
	maxObj,
	name, uiIndex, order,
	
	fn Read bitStream entry =
	(
		local attarray = WOW2_Entry.Setup bitStream entry
		
		for i = 1 to entry.nEntry do
		(
			local mattach = WOW2_Attachment()
			mattach.id = (ReadLong bitStream #unsigned) + 1
			mattach.bone = ReadShort bitStream #unsigned
			mattach.flags = ReadShort bitStream #unsigned
			mattach.pos = WOW2_ReadVec bitStream #v3d
			mattach.vis = WOW2_AnimBlock.Read bitStream
			
			try
			(
				if (mattach.id < WOW2_attachid.count) then
				(
					mattach.name = WOW2_attachid[mattach.id]
				)
				else
				(
					mattach.name = ("Attachment" + ((i - 1) as string))
				)
			)
			catch
			(
				mattach.name = ("Attachment" + ((i - 1) as string))
			)
			
			attarray[i] = mattach
		)
		
		return attarray
	)
)

struct WOW2_RenderFlags
(
	flags, blendmode,
	
	fn Read bitStream entry =
	(
		local rfarray = WOW2_Entry.Setup bitStream entry
		
		for i = 1 to entry.nEntry do
		(
			local rf = WOW2_RenderFlags()
			
			rf.flags = ReadShort bitStream #unsigned
			rf.blendmode = ReadShort bitStream #unsigned
			
			rfarray[i] = rf
		)
		
		return rfarray
	)
)

fn WOW2_Read_Transparencies bitStream entry =
(
	local barray = WOW2_Entry.Setup bitStream entry
	for i = 1 to entry.nEntry do
		barray[i] = WOW2_AnimBlock.Read bitStream
	barray
)

fn WOW2_Open fname =
(
	step = "Accessing File"
	-- check to see if this is a real path
	
	local fileBStream = fopen fname "rb"
	if fileBStream==undefined then 
	(
		echo "File not found!"
		throw "File not found"
	)
	
	return fileBStream
)

fn WOW2_Close bitStream =
(
	if (bitStream != undefined) then fclose bitStream
)

-- ****************************************
-- **			Max Scene Code			      **
-- ****************************************
--

fn WOW2_SetVertexNormals mesh verts =
(
	max modify mode
	addmodifier mesh (edit_normals name:"vnorms")
	en = mesh.modifiers[#vnorms]
	modPanel.setCurrentObject en

	en.displaylength = 0.05
	
	-- speeds up processing
	en_SetExplicit = en.SetNormalExplicit
	en_SetNormal = en.SetNormal
	en_SetNormalID = en.SetNormalID
	en_ConvVert	= en.ConvertVertexSelection
	en_SetSelection = en.SetSelection
	en_Unify = en.unify
	en_Move = en.move
	
	-- Method: 1
	for i = 1 to verts.count do
	(
		my_vert = #{i}
		my_norm = #{}
		en_ConvVert &my_vert &my_norm
		en_SetSelection my_norm node:mesh
		en_Unify node:mesh
		en_Move verts[i].normal
	)


	/*
	-- Method 2:
	-- way too slow...but sets normal ID to vertex ID's
	for i = 1 to en.GetNumFaces() do
	(
		for j = 1 to 3 do
		(
			vind = en.getVertexID i j
			en_SetNormalID i j vind
			en_SetExplicit vind
			en_SetNormal vind verts[vind].normal
		)
	)
	en.RebuildNormals()
	*/

	local nNormals = en.getNumNormals node:mesh
	en.select #{1..nNormals} node:mesh -- select all normals
	en.MakeExplicit node:mesh -- make them explicit
	en.select #{1..nNormals} node:mesh invert:true -- deselect them

	
	-- collapse edit_normal modifier
	collapseStack mesh
)

fn WOW2_Create_Submesh smesh skinIndices skinFaces mVerts smName =
(
	local faceList = #()
	local vertList = #()
	local tvertList = #()
	
	-- Building the Submeshes
	-- build faces by submesh
	--echo ("sm_"+s as string+".nfaces: "+smesh.nfaces as string +" indfaces:" + sm.indfaces as string)

	local nFaces = smesh.nfaces
	if ((mod (nFaces) 3) != 0.0 ) then echo "#ERROR sm.tris not a multiple of 3!"
	--else echo "#INFO sm.tris check passed!"
	
	--echo ("Creating Submesh_" + s as string)
	for i = 1 to nFaces by 3 do
	(
		local face = [0,0,0]
		for j = 1 to 3 do
		(
			local k = smesh.indfaces + i + j - 1
			face[j] = skinFaces[k] - smesh.indverts + 1
		)
		
		append faceList face
	)
	
	for i = 1 to smesh.nverts do
	(
		local Ind = smesh.indverts + i
		local vertInd = skinIndices[Ind] + 1
		local m2vert = mVerts[vertInd]
        local vpos = WOW2_convert_Position m2vert.pos
		m2vert.normal =  WOW2_convert_Normal m2vert.normal
		--local vpos = m2vert.pos
		local vuv = m2vert.uv

		append smesh.m2verts m2vert
		append vertList vpos
		append tvertList vuv
	)
	
	local msh = mesh vertices:vertList faces:faceList name:smName 
	msh.WireColor = Color (random 0 128) (random 64 192) (random 0 128)

    if smesh.show == false then hide msh
	
	Update msh
	redrawViews()
	
	-- tvert faces
	if vertList.count != 0 then
	(
		-- setup map channels
		meshOp.setMapSupport msh 1 true
		meshOp.defaultMapFaces msh 1 
		
		-- setup uv coords for each channel
		for t = 1 to tvertList.count do
		(
			local tv = tvertList[t]
			
			meshop.setMapVert msh 1 t tv
		)
	)
	Update msh

	smesh.maxMesh = msh
)

global WOW2_useBones_Points = true

fn WOW2_Create_Bones mbones =
(
	step = "Create Bones"
	echo "Creating bones..."
	local boneLayer = WOW2_Setup_Layer "Bones"
	for i = 1 to mbones.count do
	(
		local b = mbones[i]
		local cb
		if WOW2_useBones_Points then
		(
			cb = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0.1]
			cb.width 		= 0
			cb.height		= 0
			cb.showLinks	= true
			cb.boneScaleType = #none
		)
		else
			cb = Point wireColor:green
		local bname = "Bone_"
        
       
		if (b.keyIndex) > 0 and (b.keyIndex) < 36 then 
			bname = bname + WOW2_keyboneid[b.keyIndex] + "_"
		else
			bname = bname + "Any_"
        
		if (i / 10 == 0) then
			bname = bname + "0" + ((i - 1) as string)
		else
			bname = bname + ((i - 1) as string)
            
        
            
		--WOW2_convert_Position b.pivot
		cb.name 		= bname
		cb.position		= WOW2_convert_Position b.pivot --b.pivot
		cb.rotation.controller = Linear_Rotation()
		b.maxObj = cb -- assign max bone
		-- update original array
		mbones[i] = b
		boneLayer.addNode cb
	)
	max views redraw
	
	echo "Setting up bone hierarchy"
	for i=1 to mbones.count do
	(
		b = mbones[i]
		if b.parent!=0 then
		(
			-- echo ("Setting parent of " + i as string + " to " + (bones_read[i].par+1) as string)
			b.maxObj.parent = mbones[b.parent].maxObj
		)
	)
	max views redraw
)

fn WOW2_fixUpVisibility vis =
(
	local keys = vis.keys
	local times = vis.times
	for i = 1 to keys.count do
	if (keys[i] > 0) then
		keys[i] = 1.0
	else
		keys[i] = 0.0
	for i = keys.count to 2 by -1 do
		if keys[i] == keys[i-1] then
		(
			deleteItem keys i
			deleteItem times i
		)
)

fn WOW2_preProcessBlock animBlock anims defaultValue =
(
	fn NonGlobalProcess animBlock anims defaultValue =
	(
		local n = animBlock.times.count
		local newTimes = #()
		local newKeys = #()
		if (n > 0) then
		(
			newTimes = #(0)
			newKeys = #((copy defaultValue))
		)
		for i = 1 to n where anims[i].process do
		(
			local loops = anims[i].loops
			local start = anims[i].cstart
			local end = anims[i].cend
			local times = animBlock.times[i]
			if (times.count != 0) then
			(
				local animLength = end - start
				local keys = animBlock.keys[i]
				if times[1] != 0 then
				(
					append newTimes start
					--append newKeys (copy defaultValue)
					append newKeys (copy keys[1])
				)
				for j = 1 to times.count do times[j] = times[j] + start
				join newTimes times
				join newKeys keys
				if times[times.count] != animLength then
				(
					append newTimes end
					if not loops then
						append newKeys (copy keys[keys.count])
					else
						append newKeys (copy keys[1])
				)
			)
			else
			(
				append newTimes start
				append newKeys (copy defaultValue)
				append newTimes end
				append newKeys (copy defaultValue)
			)
		)
		if (n > 0) then
		(
			append newTimes (newTimes[newTimes.count] + 5)
			append newKeys (copy defaultValue)
		)
		animBlock.times = newTimes
		animBlock.keys = newKeys
	)
	fn GlobalProcess animBlock defaultValue =
	(
		local n = animBlock.times.count
		local newTimes = #()
		local newKeys = #()
		for i = 1 to n do
		(
			local times = animBlock.times[i]
			if (times.count != 0) then
			(
				local keys = animBlock.keys[i]
				if times[1] != 0 then
				(
					append newTimes 0
					append newKeys (copy defaultValue)
				)
				join newTimes times
				join newKeys keys
			)
		)
		animBlock.times = newTimes
		animBlock.keys = newKeys
	)
	if animBlock.seq == (-1) then
	(
		NonGlobalProcess animBlock anims defaultValue
		animBlock.seq = undefined
	)
	else
	(
		GlobalProcess animBlock defaultValue
		animBlock.seq = WOW2_GlobalSequences[animBlock.seq + 1]
	)
)

global WOW2_PreProcess_Bone
fn WOW2_PreProcess_Bone anims mbone =
(
	fn flipXY p =
	(
		local x = p.x
		p.x = p.y
		p.y = x
		p
	)
	WOW2_convertAnimBlock mbone.abtrans WOW2_convert_Position
	WOW2_convertAnimBlock mbone.abrot WOW2_convert_Rotation
	WOW2_convertAnimBlock mbone.abscale flipXY
	WOW2_preprocessBlock mbone.abtrans anims [0,0,0]
	WOW2_preprocessBlock mbone.abrot anims (quat 0 0 0 1)
	WOW2_preprocessBlock mbone.abscale anims [1.0,1.0,1.0]
	WOW2_fixQuaternions mbone.abrot.keys
)

fn WOW2_Fill_Bones bitStream anims mbones =
(
	for i = 1 to mbones.count do
	(
		local mbone = mbones[i]
		
		WOW2_AnimBlock.Fill bitStream anims mbone.abtrans #v3d
		WOW2_AnimBlock.Fill bitStream anims mbone.abrot #quat
		WOW2_AnimBlock.Fill bitStream anims mbone.abscale #v3d
		WOW2_PreProcess_Bone anims mbone
	)
)

fn WOW2_Fill_Objects bitStream anims mdata =
(
-- 	for uv in mdata.TexAnims do
-- 	(
-- 		WOW2_AnimBlock.Fill bitStream anims uv.translation #v3d
-- 		WOW2_AnimBlock.Fill bitStream anims uv.rotation #quat
-- 		WOW2_convertAnimBlock uv.rotation (fn tmp q = q as EulerAngles)
-- 		WOW2_AnimBlock.Fill bitStream anims uv.scale #v3d
-- 		
-- 		WOW2_preprocessBlock uv.translation anims [0,0,0]
-- 		WOW2_preprocessBlock uv.rotation anims (EulerAngles 0 0 0)
-- 		WOW2_preprocessBlock uv.scale anims [1.0,1.0,1.0]
-- 		uv.split ()
-- 	)
	for l in mdata.Lights do
	(
		l.ambientColor = WOW2_Parameter.Fill bitStream l.ambientColor anims #v3d
		l.ambientIntensity = WOW2_Parameter.Fill bitStream l.ambientIntensity anims #float
		l.diffuseColor = WOW2_Parameter.Fill bitStream l.diffuseColor anims #v3d
		l.diffuseIntensity = WOW2_Parameter.Fill bitStream l.diffuseIntensity anims #float
		l.attenuationStart = WOW2_Parameter.Fill bitStream l.attenuationStart anims #float
		l.attenuationEnd = WOW2_Parameter.Fill bitStream l.attenuationEnd anims #float
		l.visibility = WOW2_Parameter.Fill bitStream l.visibility anims #boolean isNotVisibility:false
		if l.visibility.animated then
		(
			local ablock = l.visibility.val
			WOW2_preprocessBlock ablock anims 1
			WOW2_fixUpVisibility ablock
		)
		WOW2_Light.show l
	)
	for r in mdata.Ribbons do
	(
		r.color = WOW2_Parameter.Fill bitStream r.color anims #v3d
		r.opacity = WOW2_Parameter.Fill bitStream r.opacity anims #uint16
		r.above = WOW2_Parameter.Fill bitStream r.above anims #float
		r.below = WOW2_Parameter.Fill bitStream r.below anims #float
		r.textureSlot = WOW2_Parameter.Fill bitStream r.textureSlot anims #uint16
		r.visibility = WOW2_Parameter.Fill bitStream r.visibility anims #boolean isNotVisibility:false
		if r.visibility.animated then
		(
			local ablock = r.visibility.val
			WOW2_preprocessBlock ablock anims 1
			WOW2_fixUpVisibility ablock
		)
		WOW2_RibbonEmitter.show r
	)
	for p in mdata.Particles do
	(
		p.emissionspeed = WOW2_Parameter.Fill bitStream p.emissionspeed anims #float
		p.Speed_var = WOW2_Parameter.Fill bitStream p.Speed_var anims #float
		p.Vertical_range = WOW2_Parameter.Fill bitStream p.Vertical_range anims #float
		p.Horizontal_range = WOW2_Parameter.Fill bitStream p.Horizontal_range anims #float
		p.Gravity = WOW2_Parameter.Fill bitStream p.Gravity anims #float
		p.Lifespan = WOW2_Parameter.Fill bitStream p.Lifespan anims #float
		p.Emissionrate = WOW2_Parameter.Fill bitStream p.Emissionrate anims #float
		p.Emissionarea_length = WOW2_Parameter.Fill bitStream p.Emissionarea_length anims #float
		p.Emissionarea_width = WOW2_Parameter.Fill bitStream p.Emissionarea_width anims #float
		p.Gravity_strong = WOW2_Parameter.Fill bitStream p.Gravity_strong anims #float
		p.visibility = WOW2_Parameter.Fill bitStream p.visibility anims #boolean isNotVisibility:false
		if p.visibility.animated then
		(
			local ablock = p.visibility.val
			WOW2_preprocessBlock ablock anims 1
			WOW2_fixUpVisibility ablock
		)
		WOW2_ParticleEmitter.show p
	)
)

-- Scene data funcs
fn WOW2_SeqsToStringStream seqs =
(
	local ss = stringStream ""
	format "%\r\n" seqs.name to:ss
	format "rarity = %\r\n" seqs.rarity to:ss
	format "moveSpeed = %\r\n" seqs.moveSpeed to:ss
	format "nonLoop = %\r\n" seqs.looping to:ss
	format "default_Anim = false\r\n" to:ss
	format "sub_anim = false\r\n" to:ss
	if seqs.priority != undefined then
		format "defaultPriority = %\r\n" seqs.priority to:ss
	else
		format "defaultPriority = 0\r\n" to:ss
	return (ss as string)
)

fn WOW2_SeqsToStringStreamNeodex seqs =
(
	local ss = stringStream ""
	format "%\r\n" seqs.name to:ss
	local rarity = ((((100 - seqs.rarity)/100.0)*10) as integer)
	if rarity > 0 then
		format "Rarity %\r\n" rarity to:ss
	local movespeed = ((seqs.moveSpeed*50) as integer)
	if movespeed > 0 then
		format "MoveSpeed %\r\n" movespeed to:ss
	if seqs.looping then
		format "NonLooping\r\n" to:ss
	return (ss as string)
)

fn WOW2_Integer_to_String int buffer =
(
	local strResult = ""
	for i = 1 to buffer do
	(
		strResult += "0"
	)		
	strint = int as string
	if (strint.count < buffer) then
	(
		for i = 1 to strint.count do
		(
			local strInd = i - 1
			strResult[strResult.count-strInd] = strint[strint.count-strInd]
		)
	)
	return strResult
)

global g_anims = undefined

fn WOW2_Get_Anims anims =
(
   g_anims = anims
	for i = 1 to anims.count do
	(
                
		local anim = anims[i]

		if (dbcdata != undefined and anim.animID + 1 <= dbcdata.records.count and dbcdata.records[anim.animID + 1].name != undefined) then
			anim.name = (dbcdata.records[anim.animID + 1].name)
		else
        (
			--anim.name = "Animation_" + ((i - 1) as string)
            anim.name = "Animation_" + (anim.animID as string)
		
        )
		-- update original array
		anims[i] = anim
	)
)

fn WOW2_write_SC2_Anims Sequences deleteOld:true =
(
	local NT
	if deleteOld then
	(
		while( numNoteTracks rootNode != 0 ) do deleteNoteTrack rootNode (getNoteTrack rootNode 1)
		NT = notetrack "animations"
		addNoteTrack rootNode NT
	) else NT = getNoteTrack rootNode 1
	for s in Sequences do
	(
		local val = WOW2_SeqsToStringStream s
		local key1 = addNewNoteKey NT.keys s.cstart
		local key2 = addNewNoteKey NT.keys s.cend
		key1.value = val
		key2.value = val
		local tag1 = FrameTagManager.CreateNewTag (s.name + " Start") s.cstart
		local id = FrameTagManager.GetTagID tag1
		local tag2 = FrameTagManager.CreateNewTag (s.name + " End") s.cend lockID:id
	)
)

fn WOW2_write_Wc3_Anims Sequences deleteOld:true =
(
	local NT
	if deleteOld then
	(
		while( numNoteTracks rootNode != 0 ) do deleteNoteTrack rootNode (getNoteTrack rootNode 1)
		NT = notetrack "animations"
		addNoteTrack rootNode NT
	) else NT = getNoteTrack rootNode 1
	for s in Sequences do
	(
		local val = WOW2_SeqsToStringStreamNeodex s
		local key1 = addNewNoteKey NT.keys s.cstart
		local key2 = addNewNoteKey NT.keys s.cend
		key1.value = val
		key2.value = val
		local tag1 = FrameTagManager.CreateNewTag (s.name + " Start") s.cstart
		local id = FrameTagManager.GetTagID tag1
		local tag2 = FrameTagManager.CreateNewTag (s.name + " End") s.cend lockID:id
	)
)

fn WOW2_Set_Anims anims =
(	
	local sc2seqList = #()
	local sc2seqCounter = #()
	local sc2seqNameList = #()
	-- Start time
	local astart = 10
	local abuffer = WOW2_Convert_Time 1000
	
	local animList = #()
	for i = 1 to anims.count do
	(
		local anim = anims[i]
		
		if (anim.process == true) then
		(
			--update old array
			anim.cstart = astart
			anim.cend = astart + anim.frames
			
			astart = anim.cend + abuffer
			
			-- Check for external .anim files in same directory
			-- convert animID to four digit string
			local strAnimID = WOW2_Integer_to_String anim.animID 4
			local strSubID = WOW2_Integer_to_String anim.subanimID 2
			
			local mpath = getFilenamePath filename
			local mfile = getFilenameFile filename
			afile = mpath + mfile + strAnimID + "-" + strSubID + ".anim"
			
			-- find external .anim files, check by three criteria
			if ((doesFileExist afile) == true) then 
			(
				anim.animFile = afile
			)
			else if (dbcdata != undefined) then
			(
				local newanimID = dbcdata.records[anim.animID + 1].parentAnimID
				strAnimID = WOW2_Integer_to_String newanimID 4
				afile = mpath + mfile + strAnimID + "-" + strSubID + ".anim"
				if ((doesFileExist afile) == true) then 
				(
					anim.animFile = afile
				)
				else
				(
					if (anim.index != (i - 1)) then
					(
						local aind = anim.index + 1
						if (anims[aind].animFile != undefined) then anim.animFile = anims[aind].animFile
					)
				)
			)
			
			if (WOW2_ImportAsM3) then
			(
				local sc2seq = WOW2_SC2_SEQS()
				-- asterix eliminates spaces interfering with string matching
				-- fix attack names
				local apatArray = #("Attack", "EmoteDance", "Run", "Walk", "Ready")
				local aname
				
				-- grab loop switch so we can check if it's on for attack sequence
				sc2seq.looping = bit.get anim.flags 6
				
				for a = 1 to apatArray.count do
				(
					local apat = "*" + apatArray[a] + "*"
					if ((matchPattern anim.name pattern:apat) == true) then 
					(
						case apatArray[a] of
						(
							"Attack": 
							(
								-- flip looping switch if attack animation
								aname = "Attack"
								if (sc2seq.looping == true) then sc2seq.looping = false
							)
							"EmoteDance": 
							(
								aname = "Stand Dance"
								if (sc2seq.looping == false) then sc2seq.looping = true
							)
							"Run":
							(
								aname = "Walk"
							)
							"Walk":
							(
								aname = "Walk Slow"
							)
							"Ready":
							(
								aname = "Ready"
							)
						)
					)
				)
				sc2seq.looping = not sc2seq.looping
				if aname == undefined then aname = anim.name
				
				-- Add index numbers to sequences
				local aInd = findItem sc2seqNameList aname
				if (aInd > 0) then
				(
					local counter = sc2seqCounter[aInd]
					if (counter / 10 == 0) then 
					(
						aname = aname + " 0" + (counter as string)
					)
					else
					(
						aname = aname + " " + (counter as string)
					)
					
					sc2seqCounter[aInd] += 1
				)
				else
				(
					append sc2seqNameList aname
					append sc2seqCounter 1
				)
				
				sc2seq.name = aname
				sc2seq.cstart = anim.cstart
				sc2seq.cend = anim.cend
				sc2seq.rarity = anim.rarity
				sc2seq.moveSpeed = anim.moveSpeed
				append sc2seqList sc2seq
			)
			
			anims[i] = anim
			append animList anim
		)
	)
	case WOW2_ImportMode of
	(
		#Sc2ArtTools: WOW2_write_SC2_Anims sc2seqList
		default: WOW2_write_Wc3_Anims sc2seqList
	)
	frameRate = WOW2_useFPS
)

fn WOW2_Bone_Depth mbones b =
(
	if b.parent == 0 then return 0
	else return ( 1 + WOW2_Bone_Depth mbones mbones[b.parent] )
)

fn WOW2_Sort_Bones mbones =
(
	local ba = #()
	for i = 1 to mbones.count do
	(
		bonerec = [(WOW2_Bone_Depth mbones mbones[i]), i]
		append ba bonerec
	)
	fn compfn a b = (if a.x<b.x then return 1; if a.x>b.x then return -1; return 0;)
	qsort ba compfn
	return ba
)

fn WOW2_setNodeWorldRotation theNode theRot = 
( 
	local tmat = transmatrix theNode.transform.pos
	in coordsys tmat (theNode.rotation = theRot)
)

fn WOW2_Apply_Rotation mbone ablock =
(
	if ablock.keys.count != 0 then
	(
		if ablock.seq == undefined then
		(
			mbone.rotation.controller = linear_rotation ()
			local c = mbone.rotation.controller
			WOW2_writeKeys ablock c
			c
		)
		else
			ablock.seq.register mbone ablock WOW2_Apply_Rotation false #rotation
	)
)

fn WOW2_Apply_Translation mbone ablock =
(
	if ablock.keys.count != 0 then
	(
		if ablock.seq == undefined then
		(
			local obj = mbone
			local subPos
			in coordsys parent subPos = obj.pos
			for i = 1 to ablock.keys.count do
				ablock.keys[i] = ablock.keys[i] + subPos
			obj.pos.controller = linear_position ()
			local c = obj.pos.controller
			WOW2_writeKeys ablock c
			c
		)
		else
			ablock.seq.register mbone ablock WOW2_Apply_Translation false #position
	)
)

fn WOW2_Apply_Scale mbone ablock =
(
	if ablock.keys.count != 0 then
	(
		if ablock.seq == undefined then
		(
			local obj = mbone
			local subScale
			in coordsys parent subScale = obj.scale
			for i = 1 to ablock.keys.count do
				ablock.keys[i] = ablock.keys[i]/subScale
			obj.scale.controller = linear_scale ()
			local c = obj.scale.controller
			WOW2_writeKeys ablock c
			c
		)
		else
			ablock.seq.register mbone ablock WOW2_Apply_Scale false #scale
	)
)

fn WOW2_Apply_FloatParam obj ablock param =
(
	if ablock.keys.count != 0 then
	(
		if ablock.seq == undefined then
		(
			local controller = linear_float ()
			WOW2_writeKeys ablock controller
			setPropertyController obj param controller
			controller
		)
		else
			ablock.seq.register obj ablock WOW2_Apply_FloatParam true param
	)
)

fn WOW2_Apply_Visibility obj ablock =
(
	if ablock.keys.count != 0 then
	(
		obj.visibility = On_Off ()
		obj.visibility.controller = On_Off ()
		local c = obj.visibility.controller
		local keys = ablock.keys
		if keys[1] > 0.1 then
			addNewKey c 0f
		deleteItem ablock.times 1
		for t in ablock.times do
			addNewKey c t
		c
	)
)

fn WOW2_Animate_Bones mbones =
(
	local bd = WOW2_Sort_Bones mbones

	for i = 1 to mbones.count do
	(
		local mbone = mbones[i]
		
		-- Rotation
		WOW2_Apply_Rotation  mbone.maxObj mbone.abrot
		-- Translation
		WOW2_Apply_Translation mbone.maxObj mbone.abtrans
		-- Scale
		WOW2_Apply_Scale mbone.maxObj mbone.abscale
	)
)

fn WOW2_Assign_Map texMap add:"" =
(
	local filePath = getFilenamePath filename
	local fName = getFilenameFile texMap
	local extCheck = #(".dds", ".tga", ".png", ".jpg")
	for j = 1 to extCheck.count do
	(
		local chkFile = filePath + fName + add + extCheck[j]
		if ((doesFileExist chkFile) == true) then
		(
			return chkFile
		)
	)
	return undefined
)

fn WOW2_CreateSc2Attachment mattach =
(
	local m3attachStr = #("Ref_Center", "Ref_Damage", "Ref_Hardpoint", "Ref_Head", "Ref_Origin", "Ref_Overhead", "Ref_Target", "Ref_Weapon", "Ref_Weapon Left", "Ref_Weapon Right")
	local m3attachid = #(	undefined, "Ref_Weapon Right", "Ref_Weapon Left", undefined, undefined, -- 0 - 4
											undefined, undefined, undefined, undefined, undefined, -- 5 - 9
											undefined, undefined, undefined, undefined, undefined, -- 10 - 14
											"Ref_Target", "Ref_Target", undefined, "Ref_Overhead", "Ref_Origin", -- 15 - 19
											"Ref_Head"
										)
	
	local pos = WOW2_convert_Position mattach.pos
	---WOW2_convert_Position pos
	
	local sc2att
	if (mattach.id < m3attachid.count and m3attachid[mattach.id] != undefined) then
	(
		sc2att = SC2AttachPt pos:pos
		sc2att.name = m3attachid[mattach.id]
		mattach.maxObj = sc2att
		sc2att
	)
)

fn WOW2_Create_Attachments mattachs mbones =
(
    
    local attachmentLayer = WOW2_Setup_Layer "Attachments"
    
    for mattach in mattachs do
    (
        format "Creating attachment %\n" mattach.name
        try(
            mattach.maxObj = point box:On cross:Off size:5 centermarker:Off wirecolor:yellow
            mattach.maxObj.name =  mattach.name + " Ref"
            mattach.maxObj.pos = WOW2_convert_Position mattach.pos
            
            if( mattach.bone + 1 <= mbones.count ) then mattach.maxObj.parent = mbones[mattach.bone + 1].maxObj
            
            attachmentLayer.addNode mattach.maxObj
        )
        catch( format "#ERROR Unable to create attachment %\n" mattach.name )
    )

)

fn WOW2_setUpParameter obj param objParam anims =
(
	if param.animated then
	(
		case param.type of
		(
			#float: 
			(
				WOW2_preprocessBlock param.val anims 0.0
				WOW2_Apply_FloatParam obj param.val objParam
			)
			#color: 
			(
				WOW2_preprocessBlock param.val anims (color 255 255 255)
			)
			default: 
			(
				WOW2_preprocessBlock param.val anims 0
				WOW2_Apply_FloatParam obj param.val objParam
			)
		)
		
	)
	else
	(
		if param.val != undefined then setProperty obj objParam param.val
	)
)

fn WOW2_getStaticParameter obj objParam param =
(
	if not param.animated then
		if param.val != undefined then setProperty obj objParam param.val
)

fn WOW2_SC2_Mas_Mask m =
(
	m.MatSubType = 3
	m.DiffuseEnable = on
	m.DecalEnable = off
	m.GlossEnable = on
	m.GlossExpEnable = on
	m.Emissive1Enable = on
	m.Emissive2Enable = off
	m.EnvironmentEnable = on
	m.EnvironmentMaskEnable = on
	m.AlphaMaskEnable = on
	m.AlphaMaskEnable2 = on
	m.NormalEnable = on
	m.AmbientOcclusionEnable = on
	m.HeightmapEnable = on
)

fn WOW2_Create_Particle_Material particle texture flipbookOn =
(
	local mat = SC2_Standard_Material ()
	local blendMode = 0
	local isBlend = false
	case (particle.blend) of
	(
		0: blendMode = 0
		1: (blendMode = 0; isBlend = true)
		2: (blendMode = 4; isBlend = true)
		3: (blendMode = 4; isBlend = true)
		4: (blendMode = 1; isBlend = true)
		5: blendMode = 2
		6: blendMode = 3
		default: blendMode = 1
	)
	mat.name = ("ParticleMaterial 0" + (particle.id as string))
	
	if isBlend then
		WOW2_SC2_Mas_Mask mat
	local ang
	case (particle.Texturerot) of
	(
		1: ang = 90.0
		0: ang = 0.0
		(-1): ang = -90.0
		default: ang = 0.0
	)
	mat.BlendOp = blendMode
	mat.RecvShadows = off
	mat.castShadows = off
	mat.hitTest = off
	mat.DisableSoftBlend = on
	mat.Unlit = on
	mat.DepthFog = bit.get particle.flags 4
	local texName = getFilenameFile texture.texFile 
	local sc2diffuseMap = SC2_Bitmap name:(texName + "_Diffuse")
	local bitmapChk
	if (texture.type == 0) then
	(
		bitmapChk = WOW2_Assign_Map texName add:""
		if (bitmapChk != undefined) then
		(
			try (sc2diffusemap.Bitmap = openBitmap bitmapChk) catch ()
		)
		sc2diffusemap.WAngle = ang
	)
	sc2diffuseMap.ColorChannels = 0
	if flipbookOn then sc2diffuseMap.EnableFlipbook = on
	mat.diffuse = sc2diffuseMap
	if isBlend then
	(
		WOW2_SC2_Mas_Mask mat
		local sc2alphaMap = SC2_Bitmap name:(texName + "_Mask")
		try (sc2alphaMap.Bitmap = openBitmap bitmapChk) catch ()
		sc2alphaMap.ColorChannels = 2
		if flipbookOn then sc2alphaMap.EnableFlipbook = on
		mat.AlphaMask = sc2alphaMap
		mat.AlphaTestThreshold = 10
		sc2alphaMap.WAngle = ang
	)
	mat
)

fn WOW2_CreateWc3ParticleEmitter  p texture anims =
(
    function parseValue particle =
    (
        try (
            if particle.val == undefined then return 0
            if particle.animated == false then return particle.val
            if particle.animated == true then return particle.val.keys[1][1]
            ) catch ( return 0.0 )
    )
    
    print p
	local pos = WOW2_convert_Position p.position
	local enableFlipbook = (bit.or p.rows p.cols) > 1

	local part = WC3RefEmitter pos:pos --> references the new Warcraft 3 Reforged Particle emitter

	part.name = "BlizzPart0" + (p.id as string)

	local texName = getFilenameFile texture.texFile 
	part.texture = ""--WOW2_Assign_Map texName add:""

	part.particleType = p.HeadorTail + 1
	part.rowCount = p.rows
	part.colCount = p.cols
	part.Unshaded = on
    part.emissionRate = parseValue p.Emissionrate
    part.speed = parseValue p.emissionspeed
    part.gravity = parseValue p.gravity
    part.lifespan = parseValue p.lifespan
    
    part.length = (parseValue p.Emissionarea_length) * WOW2_Model_Scale
    part.width = (parseValue p.Emissionarea_width)  * WOW2_Model_Scale
    
    if part.length <=1.0 then part.length = WOW2_Model_Scale
    if part.width <=1.0 then part.width = WOW2_Model_Scale
        
    if (bit.get p.flags 13) then part.XYQuads = true
    
    local colors = p.Colors.keys
	part.StartColor = colors[1]
	part.MidColor = colors[2]
	part.EndColor = colors[3]
    
    local opacity = p.UOpacity.keys
	part.StartAlpha = opacity[1]
	part.MidAlpha = opacity[2]
	part.EndAlpha = opacity[3]
    
    
    fn getScale sxy sa =
	(
		local result = #(0.0,0.0,0.0)
		for i = 1 to 3 do
			result[i] =(sa[i]*(sxy[i].x + sxy[i].y)*0.5)*WOW2_Model_Scale
		result
	)
	local sc = getScale p.Vec2DScale.keys p.scale
	part.startSize = sc[1]
	part.midSize = sc[2]
	part.endSize = sc[3]
    
    local fb = p.rows*p.cols
	part.endLifespanUVAnim = fb/2
	part.endTailUVAnim= fb/2
    part.startDecayUVAnim = fb/2
	part.endDecayUVAnim = fb
    part.startTailDecayUVAnim = fb/2
	part.endTailDecayUVAnim = fb
    
    part.PARTICLE_USE_MODEL_SPACE = (not (bit.get p.flags 7))
    
    part.coneAngle = parseValue p.Vertical_range

	p.maxObj = part
	part
)

fn WOW2_CreateSc2ParticleEmitter  p texture anims =
(
	local pos = WOW2_convert_Position p.position
	local enableFlipbook = (bit.or p.rows p.cols) > 1
	--WOW2_convert_Position pos
	local part = SC2Particles ParticleRibbonLink:"NONE" pos:pos
	part.name = "BlizzPart0" + (p.id as string)
	part.material = WOW2_Create_Particle_Material p texture enableFlipbook
	part.EmitterType = p.Emitter_type
	if p.Emitter_type == 2 then
		part.EmitterType = 0
	if (p.HeadorTail == 1) then
		part.ParticleInstanceType = 1
	if enableFlipbook then
	(
		part.FlipbookRows = p.rows
		part.FlipbookColumns = p.cols
		part.FlipbookEnd = p.rows*p.cols
	)
	if (bit.get p.flags 13) then --XY Quads, face emitter direction
		part.ParticleInstanceType = 7
	if (bit.get p.flags 11) then -- Pinned particles
		part.ParticleInstanceType = 9
	part.WorldSpaceParticles = (not (bit.get p.flags 7))
	part.AutoCalculateMaxParticleCount = off
	local resizeFunc = fn tmp2 a = a*WOW2_Model_Scale
	WOW2_convertParam p.emissionspeed resizeFunc
	WOW2_setUpParameter part p.emissionspeed #InitialVelocitySpeedMin anims
	WOW2_convertParam p.Vertical_range radToDeg
	WOW2_convertParam p.Horizontal_range radToDeg
	WOW2_setUpParameter part p.Vertical_range #InitialVelocityVertSpread anims
	if p.Emitter_type == 2 then
		WOW2_setUpParameter part p.Horizontal_range #InitialVelocityHorzSpread anims
	else
	(
		WOW2_convertParam p.Vertical_range (fn tmp a = a*2.0)
		WOW2_setUpParameter part p.Vertical_range #InitialVelocityHorzSpread anims
	)
	WOW2_convertParam p.Gravity resizeFunc
	WOW2_setUpParameter part p.Gravity #gravity anims
	WOW2_setUpParameter part p.Lifespan #LifeTimeMin anims
	WOW2_setUpParameter part p.Emissionrate #emissionRate anims
	WOW2_convertParam p.Emissionarea_length resizeFunc
	WOW2_convertParam p.Emissionarea_width resizeFunc
	WOW2_setUpParameter part p.Emissionarea_length #OuterLength anims
	WOW2_setUpParameter part p.Emissionarea_width #OuterWidth anims
	local colors = p.Colors.keys
	local useMid = colors.count > 2
	part.ColorUseMid = useMid 
	part.ColorMinBegin = colors[1]
	if (useMid ) then
	(
		part.ColorMinMid = colors[2]
		part.ColorMinEnd = colors[3]
	) else
		part.ColorMinEnd = colors[2]
	local opacity = p.UOpacity.keys
	useMid = opacity.count > 2
	part.AlphaUseMid = useMid
	part.AlphaMinBegin = opacity[1]
	if (useMid ) then
	(
		part.AlphaMinMid = opacity[2]
		part.AlphaMinEnd = opacity[3]
	) else
		part.AlphaMinEnd = opacity[2]
	fn getScale sxy sa  i =
	(
		local result = #(0.0,0.0,0.0)
		for i = 1 to i do
			result[i] =(sa[i]*(sxy[i].x + sxy[i].y))*WOW2_Model_Scale
		result
	)
	useMid = p.Vec2DScale.keys.count > 2
	local sc = getScale p.Vec2DScale.keys p.scale (if useMid then 3 else 2)
	part.SizeUseMid = on
	part.SizeMinBegin = sc[1]
	if (useMid ) then
	(
		part.SizeMinMid = sc[2]
		part.SizeMinEnd = sc[3]
	) else
		part.SizeMinEnd = sc[2]
	part.Drag = p.slowdown
	WOW2_Apply_Visibility part p.visibility.val
	p.maxObj = part
	part.AutoCalculateMaxParticleCount = on
	part
)

fn WOW2_Create_Ribbon_Material ribbon renderBlends textures =
(
	local mat = SC2_Standard_Material ()
	local renderFlags = renderBlends[ribbon.blends[1] + 1]
	local isBlend = false
	local blendMode = 0
	case (renderFlags.blendmode) of
	(
		0: blendMode = 0
		1: (blendMode = 0; isBlend = true)
		2: (blendMode = 4; isBlend = true)
		3: (blendMode = 4; isBlend = true)
		4: (blendMode = 1; isBlend = true)
		5: blendMode = 2
		6: blendMode = 3
		default: blendMode = 1
	)
	mat.name = ("RibbonMaterial 0" + (ribbon.id as string))
	
	if isBlend then
		WOW2_SC2_Mas_Mask mat
	local ang
	mat.BlendOp = blendMode
	mat.RecvShadows = off
	mat.castShadows = off
	mat.hitTest = off
	mat.Unlit = off
	mat.DepthFog = off
	mat.twoSided = on
	local texture = textures[ribbon.textures[1]+1]
	local texName = getFilenameFile texture.texFile 
	local sc2diffuseMap = SC2_Bitmap name:(texName + "_Diffuse")
	local bitmapChk
	if (texture.type == 0) then
	(
		bitmapChk = WOW2_Assign_Map texName add:""
		if (bitmapChk != undefined) then
		(
			try (sc2diffusemap.Bitmap = openBitmap bitmapChk) catch ()
		)
	)
	sc2diffuseMap.ColorChannels = 0
	mat.diffuse = sc2diffuseMap
	if isBlend then
	(
		WOW2_SC2_Mas_Mask mat
		local sc2alphaMap = SC2_Bitmap name:(texName + "_Mask")
		try (sc2alphaMap.Bitmap = openBitmap bitmapChk) catch ()
		sc2alphaMap.ColorChannels = 2
		mat.AlphaMask = sc2alphaMap
		mat.AlphaTestThreshold = 10
	)
	mat
)

fn WOW2_Create_Ribbon_Wc3_Material ribbon renderBlends textures =
(
	local mat = Warcraft3 ()
	local renderFlags = renderBlends[ribbon.blends[1] + 1]
	case (renderFlags.blendmode) of
	(
		0: blendMode = 1
		1: blendMode = 2
		2: blendMode = 3
		3: blendMode = 6
		4: blendMode = 4
		5: blendMode = 4
		6: blendMode = 5
		default: blendMode = 1
	)
	mat.name = ("RibbonMaterial 0" + (ribbon.id as string))
	mat.filtermode = blendMode
	mat.unshaded = bit.get renderFlags.flags 1
	mat.unfogged = bit.get renderFlags.flags 2
	mat.twosides = bit.get renderFlags.flags 3
	local texture = textures[ribbon.textures[1]+1]
	local texName = getFilenameFile texture.texFile 
	local wc3diffuseMap = BitmapTexture name:(texName + "_Diffuse")
	local bitmapChk
	if (texture.type == 0) then
	(
		bitmapChk = WOW2_Assign_Map texName add:""
		if (bitmapChk != undefined) then
		(
			try (wc3diffuseMap.Bitmap = openBitmap bitmapChk) catch ()
		)
	)
	mat.texture = wc3diffuseMap
	mat
)

fn WOW2_CreateSc2RibbonEmitter  r renderBlends textures =
(
	local pos = WOW2_convert_Position r.position
	---WOW2_convert_Position pos
	local rib = SC2Ribbon pos:pos
	rib.name = "BlizzRibbon0" + (r.id as string)
	rib.material = WOW2_Create_Ribbon_Material r renderBlends textures
	rib.shapeType = 1
	local emissionAngle = radToDeg r.emissionAngle
	rib.MaxElemsPerSec = r.edgeEmission
	rib.InitialVelocityYaw = emissionAngle
	rib.LifeTimeMin = r.lifeSpan
	rib.InitialVelocitySpeedMin = 0.0
	WOW2_convertParam r.color (fn tmp a = a*255)
	WOW2_getStaticParameter rib #ColorMinBegin r.color
	WOW2_getStaticParameter rib #ColorMinEnd r.color
	WOW2_getStaticParameter rib #AlphaMinBegin r.opacity
	WOW2_getStaticParameter rib #AlphaMinEnd r.opacity
	local size = 0.0
	if not r.above.animated then
		if r.above.val != undefined then size = size + r.above.val
	if not r.below.animated then
		if r.below.val != undefined then size = size + r.below.val
	size = size*WOW2_Model_Scale
	rib.SizeMinBegin = size
	rib.SizeMinEnd = size
	WOW2_Apply_Visibility rib r.visibility.val
	r.maxObj = rib
	rib
)

fn WOW2_CreateWc3RibbonEmitter  r renderBlends textures =
(
	local pos = WOW2_convert_Position r.position
	--WOW2_convert_Position pos
	local rib = BlizRibbon pos:pos
	rib.name = "BlizzRibbon0" + (r.id as string)
	rib.rmaterial = WOW2_Create_Ribbon_Wc3_Material r renderBlends textures
	rib.emission = r.edgeEmission
	rib.life = r.lifeSpan
	WOW2_convertParam r.color (fn tmp a = a*255)
	WOW2_setUpParameter rib  r.color #VertexColor anims
	WOW2_convertParam r.opacity (fn tmp a = a/65535.0)
	WOW2_setUpParameter rib  r.opacity #alpha anims
	local resizeFunc = fn tmp2 a = a*WOW2_Model_Scale
	WOW2_convertParam r.above resizeFunc
	WOW2_convertParam r.below resizeFunc
	WOW2_setUpParameter rib  r.above #above anims
	WOW2_setUpParameter rib  r.below #below anims
	WOW2_Apply_Visibility rib r.visibility.val
	r.maxObj = rib
	rib
)

fn WOW2_CreateSc2Light  l anims =
(
	local pos = WOW2_convert_Position  r.position
	--WOW2_convert_Position pos
	local lit
	case (l.type) of
	(
		1: lit = SC2OmniLight pos:pos
		2: lit = SC2SpotLight pos:pos
		default: lit = SC2OmniLight pos:pos
	)
	lit.name = "BlizzLight0" + (l.id as string)
	WOW2_setUpParameter lit l.diffuseColor #diffuseColor anims
	WOW2_setUpParameter lit l.diffuseIntensity #intensity anims
	WOW2_setUpParameter lit l.attenuationStart #attenStart anims
	WOW2_setUpParameter lit l.attenuationEnd #decay anims
	l.maxObj = lit
	lit
)

fn WOW2_CreateStandardLight  l anims =
(
	local pos = WOW2_convert_Position r.position
	--WOW2_convert_Position pos
	local lit
	case (l.type) of
	(
		1: lit = OmniLight pos:pos
		2: lit = freeSpot pos:pos
		default: lit = OmniLight pos:pos
	)
	lit.name = "BlizzLight0" + (l.id as string)
	WOW2_setUpParameter lit l.diffuseColor #rgb anims
	WOW2_setUpParameter lit l.diffuseIntensity #multiplier anims
	WOW2_setUpParameter lit l.attenuationStart #nearAttenStart anims
	WOW2_setUpParameter lit l.attenuationEnd #nearAttenEnd  anims
	l.maxObj = lit
	lit
)


fn WOW2_Create_ParticleEmitters mdata mbones =
(
	local createFunc
	case WOW2_ImportMode of
	(
		#NeoDex: createFunc = WOW2_CreateWc3ParticleEmitter
		#Sc2ArtTools: createFunc = WOW2_CreateWc3ParticleEmitter --WOW2_CreateSc2ParticleEmitter
		#WoW: createFunc = WOW2_CreateWc3ParticleEmitter --(fn tmp a b c = undefined)
		default: createFunc = WOW2_CreateWc3ParticleEmitter
	)
	local anims = mdata.anims
	local particleLayer = WOW2_Setup_Layer "Particle Emitters"
	for p in mdata.Particles do
	(
        
		local b = mbones[p.bone + 1].maxObj
		local texture = mdata.Textures[p.texture+1]
		local part = createFunc p texture anims
		part.parent = b
		particleLayer.addNode part
	)
)

fn WOW2_Create_RibbonEmitters mdata mbones =
(
	local createFunc
	case WOW2_ImportMode of
	(
		#NeoDex: createFunc = WOW2_CreateWc3RibbonEmitter
		#Sc2ArtTools: createFunc = WOW2_CreateSc2RibbonEmitter
		#WoW: createFunc = (fn tmp a b c = undefined)
		default: createFunc = undefined
	)
	local anims = mdata.anims
	local ribbonLayer = WOW2_Setup_Layer "RibbonEmitters"
	for r in mdata.Ribbons do
	(
		local b = mbones[r.parent].maxObj
		local rib = createFunc r mdata.RenderFlags mdata.Textures
		rib.parent = b
		ribbonLayer.addNode rib
	)
)


fn WOW2_Create_Lights mdata mbones =
(
	local createFunc
	case WOW2_ImportMode of
	(
		#NeoDex: createFunc = WOW2_CreateStandardLight
		#Sc2ArtTools: createFunc = WOW2_CreateSc2Light
		#WoW: createFunc = WOW2_CreateStandardLight
		default: createFunc = undefined
	)
	local anims = mdata.anims
	local lightLayer = WOW2_Setup_Layer "Lights"
	for l in mdata.Lights do
	(
		local b = mbones[r.parent].maxObj
		local lit = createFunc l anims
		lit.parent = b
		lightLayer.addNode lit
	)
)

fn WOW2_AddBehavior behaviorType newName: unsupplied =
(
    if ( startools == undefined ) then return undefined
	if startools.behaviors.targetNode == undefined do								
		startools.behaviors.targetNode = SC2BehaviorHolder()
	local newBehaviorCustAttribute = (startools.behaviors.AddBehavior startools.behaviors.targetNode behaviorType newName:newName)
	if newBehaviorCustAttribute != undefined do
		startools.behaviors.lastBehaviorSelected	= newBehaviorCustAttribute
	newBehaviorCustAttribute
)

fn WOW2_SetBillboardedSc2 billboarded =
(
	--local behavior = WOW2_AddBehavior #Billboard_Behavior
	--behavior.addBones billboarded
)

mapped fn WOW2_SetBillboardedWc3 bone=
(
	setUserProp bone "Billboard" 2
)

fn WOW2_SetBillboarded mbones =
(
	local billboarded = #()
	for b in mbones where (bit.get b.flags 4) do
		append billboarded b.maxObj
	if billboarded.count != 0 then
	(
		case WOW2_ImportMode of
		(
			#NeoDex: WOW2_SetBillboardedWc3 billboarded
			#Sc2ArtTools: WOW2_SetBillboardedSc2  billboarded
			#WoW: OK
			default: OK
		)
	)
)

fn WOW2_Apply_TextureAnimation texMap texAnim =
(
	WOW2_Apply_FloatParam texMap texAnim.U_offset #U_offset
	WOW2_Apply_FloatParam texMap texAnim.V_offset #V_offset
	
	WOW2_Apply_FloatParam texMap texAnim.U_angle #U_angle
	WOW2_Apply_FloatParam texMap texAnim.V_angle #V_angle
	WOW2_Apply_FloatParam texMap texAnim.W_angle #W_angle
)

fn WOW2_SC2_Apply mat texture usesAlpha TexAnim:undefined =
(
	local texName = getFilenameFile texture.texFile
	local bitmapChk
	local mainBitmap
	bitmapChk = WOW2_Assign_Map texName
	if (bitmapChk == undefined) then
		bitmapChk = WOW2_Assign_Map texName add:"_Diffuse"
	local sc2diffuseMap = SC2_Bitmap name:(texName + "_Diffuse")
	if (bitmapChk != undefined) then
	(
		try (sc2diffusemap.Bitmap = openBitmap bitmapChk) catch ()
		mainBitmap = sc2diffusemap.Bitmap
	)
	if TexAnim != undefined then
		WOW2_Apply_TextureAnimation sc2diffuseMap TexAnim
	sc2diffuseMap.ColorChannels = 0
	mat.diffuse = sc2diffuseMap
	bitmapChk = WOW2_Assign_Map texName add:"_Normal"
	if (bitmapChk != undefined) then
	(
		local sc2normalMap = SC2_Bitmap name:(texName + "_Normal")
		try (sc2normalMap.Bitmap = openBitmap bitmapChk) catch ()
		if TexAnim != undefined then
			WOW2_Apply_TextureAnimation sc2normalMap TexAnim
		mat.NormalMap = sc2normalMap
	)
	bitmapChk = WOW2_Assign_Map texName add:"_Specular"
	if (bitmapChk != undefined) then
	(
		local sc2specularMap = SC2_Bitmap name:(texName + "_Specular")
		try (sc2specularMap.Bitmap = openBitmap bitmapChk) catch ()
		sc2specularMap.ColorChannels = 3
		if TexAnim != undefined then
			WOW2_Apply_TextureAnimation sc2specularMap TexAnim
		mat.gloss = sc2specularMap
	)
	if (usesAlpha) then
	(
		WOW2_SC2_Mas_Mask mat
		local sc2alphaMap = SC2_Bitmap name:(texName + "_Mask")
		if mainBitmap != undefined then
			sc2alphaMap.Bitmap = mainBitmap
		sc2alphaMap.ColorChannels = 2
		if TexAnim != undefined then
			WOW2_Apply_TextureAnimation sc2alphaMap TexAnim
		mat.AlphaMask = sc2alphaMap
		mat.AlphaTestThreshold = 10
	)
)

fn CreateSc2SubMaterial mat matName =
(
	local renderFlags = mat.renderFlagsInd
	local texture = mat.TexInd
	local TexAnim = mat.TexAnimInd
	subMaterial = SC2_Standard_Material name:matName
	local blendMode
	case renderFlags.blendmode of
	(
		0: blendMode = 0
		1: blendMode = 0
		2: blendMode = 4
		3: blendMode = 4
		4: blendMode = 1
		5: blendMode = 2
		6: blendMode = 3
		default: blendMode = 1
	)
	subMaterial.BlendOp = blendMode
	subMaterial.castShadows = blendMode == 0
	subMaterial.RecvShadows = blendMode == 0
	subMaterial.hitTest = blendMode == 0
	-- Render Flags
	subMaterial.Unlit = bit.get renderFlags.flags 1
	subMaterial.DepthFog = bit.get renderFlags.flags 2
	subMaterial.twoSided = bit.get renderFlags.flags 3
	subMaterial.DepthWrite = bit.get renderFlags.flags 4
	WOW2_SC2_Apply subMaterial texture (renderFlags.blendmode == 1) TexAnim:TexAnim
	if subMaterial.diffuse != undefined then 
		showTextureMap subMaterial subMaterial.diffuse on
	subMaterial
)

fn CreateWc3SubMaterial mat matName =
(
	local renderFlags = mat.renderFlagsInd
	local TexAnim = mat.TexAnimInd
	local texture = mat.TexInd
	subMaterial = Warcraft3 name:matName
	local bmode
	case renderFlags.blendmode of
	(
		0: bmode = 1
		1: bmode = 2
		2: bmode = 3
		3: bmode = 5
		4: bmode = 4
		5: bmode = 6
		default: bmode = 1
	)
	subMaterial.filtermode = bmode
	-- Render Flags
	subMaterial.unshaded = bit.get renderFlags.flags 1
	subMaterial.unfogged = bit.get renderFlags.flags 2
	subMaterial.twosides = bit.get renderFlags.flags 3
	subMaterial.NoDephSet = bit.get renderFlags.flags 4
	local texName = getFilenameFile texture.texFile
	local bitmapChk
	local mainBitmap
	bitmapChk = WOW2_Assign_Map texName
	if (bitmapChk == undefined) then
		bitmapChk = WOW2_Assign_Map texName add:"_Diffuse"
	local wc3diffuseMap = BitmapTexture name:(texName)
	if (bitmapChk != undefined) then
		try (wc3diffuseMap.Bitmap = openBitmap bitmapChk) catch ()
	if TexAnim != undefined then
		WOW2_Apply_TextureAnimation wc3diffuseMap.coords TexAnim
	subMaterial.texture = wc3diffuseMap
	wc3diffuseMap.coords.U_Tile = bit.get texture.flags 1
	wc3diffuseMap.coords.V_Tile = bit.get texture.flags 2
	showTextureMap subMaterial on
	subMaterial
)

fn CreateSc2Materials mats index =
(
	local materialName = mdata.name + "Mat_" + (index as string)
	local result
	if mats.count == 1 then
		result = CreateSc2SubMaterial mats[1] materialName
	else
	(
		result = SC2_Composite_Material ()
		for i = 1 to mats.count do
		(
			result.SubMaterials[i] = CreateSc2SubMaterial mats[i] (materialName + "_" + (i as string))
			result.SubMatEnables[i] = true
		)
	)
	result
)

fn CreateWc3Materials mats index =
(
	local materialName = mdata.name + "Mat_" + (index as string)
	local result
	if mats.count == 1 then
		result = CreateWc3SubMaterial mats[1] materialName
	else
	(
		result = CompositeMaterial ()
		for i = 1 to mats.count do
		(
			result.materialList[i] = CreateWc3SubMaterial mats[i] (materialName + "_" + (i as string))
			result.mapEnables[i] = true
		)
	)
	result
)

fn WOW2_Create_Materials =
(
    if ( WOW2_Materials == undefined) then return undefined
    
	local submeshes = skndata.Submeshes
	local materials = WOW2_Materials
	for i = 1 to materials.count do
	(
		local mat
		case WOW2_ImportMode of
		(
			#NeoDex: mat = CreateWc3Materials materials[i] i
			#Sc2ArtTools: mat = CreateSc2Materials materials[i] i
			#WoW: mat = undefined
			default: mat = undefined
		)
		local submeshes = materials[i][1].SubInd
		for j = 1 to submeshes.count do
		(
			local submesh = skndata.Submeshes[submeshes[j]]
			if (submesh.process == true and submesh.maxMesh != undefined) then
				submesh.maxMesh.material = mat
		)
	)
)

fn WOW2_ProcessTextureUnits skindata =
(
	local result = #()
	result[skindata.submeshes.count] = undefined
	for t in skindata.TexUnits do
	(
		local a = result[t.SubInd]
		if a == undefined then
		(
			a = #()
			result[t.SubInd] = a
		)
		append a t
	)
	result
)


fn WOW2_compareLayers v1 v2 =
(
	local b = true
	b = b and (v1.texFlags == v2.texFlags)
	b = b and (v1.shaderFlags == v2.shaderFlags)
	b = b and (v1.renderFlagsInd.flags == v2.renderFlagsInd.flags)
	b = b and (v1.renderFlagsInd.blendmode == v2.renderFlagsInd.blendmode )
	b = b and (v1.Mode == v2.Mode)
	b = b and (v1.TexInd == v2.TexInd)
	b = b and (v1.TexAnimInd == v2.TexAnimInd)
	b
)

fn WOW2_LinkMaterials mat mdata skndata =
(
	fn compareLayersOrder v1 v2 =
	(
		local d = v1.TexUnitInd-v2.TexUnitInd
		case of
		(
			(d < 0.): -1
			(d > 0.): 1
			default: 0
		)
	)
	fn compareMaterials v1 v2 =
	(
		if (v1.count == v2.count) then
		(
			local n = v1.count
			local b = true
			for i = 1 to n where b do
				b = b and (WOW2_compareLayers v1[i] v2[i])
			b
		)
		else
			false
	)
	for m in mat do
	(
		for t in m do
		(
			t.texInd = mdata.Textures[mdata.TexLU[t.texInd]+1]
			t.renderFlagsInd = mdata.RenderFlags[t.renderFlagsInd]
			t.TransInd = mdata.TransLU[t.TransInd]
			t.TexAnimInd = mdata.TexAnimsLU[t.TexAnimInd]
			if t.TexAnimInd == (-1) then
				t.TexAnimInd = undefined
			else
				t.TexAnimInd = mdata.TexAnims[t.TexAnimInd+1]
			t.SubInd = #(t.SubInd)
		)
		qsort m compareLayersOrder
		local b = true
		local t = m[1].ColourInd
		for ms in m do
			b = b and (t == ms.ColourInd)
		if b then
			skndata.submeshes[m[1].subInd[1]].geoAnim = t
	)
	local result = #()
	for m in mat do
	(
		local b = undefined
		for r in result where compareMaterials m r do
			b = r
		if (b != undefined) then
			b[1].SubInd = join b[1].SubInd m[1].SubInd
		else
			append result m
	)
	result
)

fn WOW2_Create_Mesh =
(
	step = "Create Mesh"

    -- fix the indFaces, as the new character models have some issues with this.
    for i=1 to skndata.Submeshes.count do (
        if i> 1 then (
             skndata.Submeshes[i].indfaces = skndata.Submeshes[i-1].indfaces + skndata.Submeshes[i-1].NFaces
         )
        --format "TM INFO: %\n" skndata.Submeshes[i]
       
    )
        
	echo "Creating submeshes..."
	local submeshes = skndata.submeshes
	local meshesLayer = WOW2_Setup_Layer "Meshes"
	cmesh = #()
	for s = 1 to submeshes.count do
	(
		local smesh = submeshes[s]
		
		if (smesh.process == true) then
		(
			local smtype = smesh.id / 100
			if (smtype == 0) then
			(
				if ((mod smtype 100) > 0) then smtype = 21 else smtype = 1
			)
			else
			(
				smtype += 1
			)
			local smname = (mdata.name + ((s - 1) as string) + "_" + smesh.name)
			format "Creating submesh %..." smname to:listener
			WOW2_Create_Submesh smesh skndata.Indices skndata.faces mdata.verts smname
			echo ("done!")
			meshesLayer.addNode smesh.maxMesh
		)
	)

	step = "Create Mesh Done"
	echo "Submeshes done\n"
)

fn WOW2_AddGeosetAnims bitStream anims =
(
	local submeshes = skndata.submeshes
	for s = 1 to submeshes.count do
	(
		local smesh = submeshes[s]
		
		if (smesh.process == true) then
		(
-- 			if smesh.geoAnim != undefined != 0 then
-- 			(
-- 				--back
-- 				local visblock = mdata.geoAnims[smesh.geoAnim].alpha
-- 				WOW2_AnimBlock.Fill bitStream anims visblock #uint16
-- 				WOW2_preprocessBlock visblock anims 1
-- 				WOW2_fixUpVisibility visblock
-- 				WOW2_Apply_Visibility smesh.maxMesh visblock
-- 			)
		)
	)
)

fn WOW2_Apply_Skin mesh mbones skinBones verts =
(
	select mesh
	max modify mode
	-- #Skin
	sk = Skin name:"Skin"
	addModifier mesh sk
	modPanel.setCurrentObject sk
	local sknopsaddbone = skinOps.addBone
	-- add bones to skin
	for i = 1 to skinBones.count do
	(
		sknopsaddbone sk skinBones[i].maxObj 0
	)
	update mesh
	max views redraw
	--disableSceneRedraw() -- speeds up weight assignment
	try
	(
		local sknRepVerWeights = skinOps.ReplaceVertexWeights
		-- 4. Set vertex weights
		for i = 1 to verts.count do
		(
			local vert = verts[i]
			
			-- Fix weight bone reference to locally skinned bones index
			for w = 1 to vert.bw.count do
			(
				if (vert.bw[w] > 0.0) then
				(
					local vBone = vert.bi[w]
					local bIndex = findItem skinBones mbones[vBone]
					if (bIndex > 0) then vert.bi[w] = bIndex else vert.bi[w] = 0
				)
			)
			sknRepVerWeights sk i vert.bi vert.bw
		)
	)
	Catch
	(
		echo "#ERROR Vertex Weighting failed"
	)
	--enableSceneRedraw()
	max create mode
	--redrawViews()
)

fn WOW2_Create_Skin submeshes mbones mbonesLU =
(
	echo "Creating skin..."
	for i = 1 to submeshes.count do
	(
		local smesh = submeshes[i]
		
		if (smesh.process == true) then
		(
			-- Gather skinned bones
			local boneList = #()
			for i = 1 to smesh.nbones do
			(
				local bListInd = smesh.indbones + i
				local bInd = mbonesLU[bListInd] + 1
				local sbone = mbones[bInd]
				append boneList sbone
			)
			
			WOW2_Apply_Skin smesh.maxMesh mbones boneList smesh.m2verts
		)
	)
)



fn WOW2_TrackSet_Register_BoneProperty ts index prop =
(
	fn WOW2_Property_Mapper prop =
	(
		case prop of
		(
			#u_offset: #uvOffset
			#v_offset: #uvOffset
			#u_tile: #uvTiling
			#v_tile: #uvTiling
			#U_Angle: #uvwAngle
			#V_Angle: #uvwAngle
			#W_Angle: #uvwAngle
			default: prop
		)
	)
	local newProp = WOW2_Property_Mapper prop
	local index2 = findItem ts.ActiveBoneSubanim_Subanims newProp
	if index2 != 0 then
	(
		local index3 = ts.ActiveBoneSubanim_Pointers[index2]
		if index3 == index then
			return OK
	)
	append ts.ActiveBoneSubanim_Pointers index
	append ts.ActiveBoneSubanim_Subanims (newProp as string)
)

fn WOW2_TrackSet_Register_TexmapProperty ts index prop =
(
	fn WOW2_Property_Mapper prop =
	(
		case prop of
		(
			#u_offset: #uvOffset
			#v_offset: #uvOffset
			#u_tile: #uvTiling
			#v_tile: #uvTiling
			#U_Angle: #uvwAngle
			#V_Angle: #uvwAngle
			#W_Angle: #uvwAngle
			default: prop
		)
	)
	local newProp = WOW2_Property_Mapper prop
	local index2 = findItem ts.ActiveTexmapSubanim_Subanims newProp
	if index2 != 0 then
	(
		local index3 = ts.ActiveTexmapSubanim_Pointers[index2]
		if index3 == index then
			return OK
	)
	append ts.ActiveTexmapSubanim_Pointers index
	append ts.ActiveTexmapSubanim_Subanims (newProp as string)
)

fn WOW2_TrackSet_Register_MaterialProperty ts index prop =
(
	fn WOW2_Property_Mapper prop =
	(
		case prop of
		(
			#u_offset: #uvOffset
			#v_offset: #uvOffset
			#u_tile: #uvTiling
			#v_tile: #uvTiling
			#U_Angle: #uvwAngle
			#V_Angle: #uvwAngle
			#W_Angle: #uvwAngle
			default: prop
		)
	)
	local newProp = WOW2_Property_Mapper prop
	local index2 = findItem ts.ActiveMatSubanim_Subanims newProp
	if index2 != 0 then
	(
		local index3 = ts.ActiveMatSubanim_Pointers[index2]
		if index3 == index then
			return OK
	)
	append ts.ActiveMatSubanim_Pointers index
	append ts.ActiveMatSubanim_Subanims (newProp as string)
)

fn WOW2_TrackSet_AddObject ts obj property =
(
	case (classof obj) of
	(
		Sc2_Bitmap:
		(
			local index = findItem ts.texmaplist obj
			if index == 0 then
			(
				ts.AddTexmap obj
				index = ts.texmaplist.count
			)
			WOW2_TrackSet_Register_TexmapProperty ts index property
		)
		Sc2_Standard_Material:
		(
			local index = findItem ts.matlist obj
			if index == 0 then
			(
				ts.AddMat obj
				index = ts.matlist.count
			)
			WOW2_TrackSet_Register_MaterialProperty ts index property
		)
		default:
		(
			local index = findItem ts.boneList obj
			if index == 0 then
			(
				ts.AddBones #(obj) addTransfromsTracks:false
				index = ts.boneList.count
			)
			WOW2_TrackSet_Register_BoneProperty ts index property
		)
	)
)

fn WOW2_SimplifyGlobalSequences gb =
(
	for i = gb.count to 1 by -1 where gb[i].numObjects == 0 do
		deleteItem gb i
	for i = 1 to gb.count do
		gb[i].id = i
)

global GLArr = #(
			"A","B","C","D","E","F","G","H","I","J","K","L","M",
			"N","O","P","Q","R","S","T","U","V","X","Y","Z"
		)

function GetLastKeyFrame =
(
    local lastKeyFrame = 0
    for obj in objects do 
    (
        try(
            if obj.pos.controller != undefined and obj.pos.controller.keys != undefined then 
            (
                local lastKey = obj.pos.controller.keys.count
                local keyFrame = obj.pos.controller.keys[lastKey].time
                if ( keyFrame > lastKeyFrame ) then 
                    lastKeyFrame = keyFrame
            )
            if obj.rotation.controller != undefined and obj.rotation.controller.keys != undefined then 
            (
                local lastKey = obj.rotation.controller.keys.count
                local keyFrame = obj.rotation.controller.keys[lastKey].time
                if ( keyFrame > lastKeyFrame ) then 
                    lastKeyFrame = keyFrame
            )
        )catch()
    )
    lastKeyFrame as integer / TicksPerFrame
)
        
fn WOW2_Create_GlobalLoopAnimationsSc2 gb anims =
(
	fn getStartTime anims =
	(
		local start = undefined
        try (
            local n = anims.count
            while ((not anims[n].process) and n > 0) do n = n - 1
            if n > 0 then
            (
                start = anims[n].cend + 20f
            ) else start = 0
        ) catch ()
		start
	)
	fn getNewAnimation g =
	(
		local newAnim = WOW2_SC2_SEQS ()
		newAnim.cstart = g.start
		newAnim.cend = g.end
		newAnim.moveSpeed = 0.0
		newAnim.name = "GLstand "+ GLArr [g.id]
		newAnim.rarity = 100.0
		newAnim.looping = false
		newAnim.priority = 12
		newAnim
	)
	fn setupGlobalAnimation g =
	(
		fn applyAnimation obj func ablock usesProperty:false property:undefined =
		(
			if usesProperty then
				func obj ablock property
			else
				func obj ablock
		)
		local num = g.numObjects
		local ts = WOW2_AddBehavior #TrackSet
        if ( ts == undefined ) then return undefined
		ts.AddAnimation g.anim.name
		ts.name = ("TrackSet Global " + GLArr[g.id])
		--ts.globalLoop = true -- I think it crashes Star Tools
		ts.ValidateAllAnims ()
		ts.priority[1]= 12
		for i = 1 to num do
		(
			local property = g.properties[i]
			-- SetUp
			local ablock = g.animBlocks[i]
			for i = 1 to ablock.times.count do 
				ablock.times[i] = g.start + ablock.times[i]
			insertItem 0 ablock.times 1
			local k = copy ablock.keys[1]
			insertItem k ablock.keys 1
			ablock.seq = undefined
			if property == #rotation then
				WOW2_fixQuaternions ablock.keys
			-- End Ablock SetUp
			local func = g.funcs[i]
			local objs = g.objects[i]
			local usesProperty = g.funcUsesProperty[i]
			
			for o in objs do
			(
				applyAnimation o func ablock usesProperty:usesProperty property:property
				WOW2_TrackSet_AddObject ts o property
			)
		)
	)
	local Sequences = #()
	if gb.count > 0 then Sequences[gb.count] = undefined
	local start = getStartTime anims
    if start == undefined then 
        start = GetLastKeyFrame() + 10
	for g in gb do
	(
		g.start = g.start + start
		g.end = g.end + start
		start = g.end + 20
		Sequences[g.id] = getNewAnimation g
		g.anim = Sequences[g.id]
	)
	WOW2_write_SC2_Anims Sequences deleteOld:false
	for g in gb do
		setupGlobalAnimation g
)

fn WOW2_Create_GlobalLoopAnimationsWc3 gb anims =
(
	fn setupGlobalAnimation g =
	(
		fn applyAnimation obj func ablock usesProperty:false property:undefined =
		(
			if usesProperty then
				func obj ablock property
			else
				func obj ablock
		)
		local num = g.numObjects
		for i = 1 to num do
		(
			local property = g.properties[i]
			-- SetUp
			local ablock = g.animBlocks[i]
			if (ablock.times[1] != 0) then
			(
				insertItem 0 ablock.times 1
				local k = copy ablock.keys[1]
				insertItem k ablock.keys 1
			)
			ablock.seq = undefined
			if property == #rotation then
				WOW2_fixQuaternions ablock.keys
			-- End Ablock SetUp
			local func = g.funcs[i]
			local objs = g.objects[i]
			local usesProperty = g.funcUsesProperty[i]
			for o in objs do
			(
				local c = applyAnimation o func ablock usesProperty:usesProperty property:property
				setAfterORT c #cycle
				enableORTs c true
			)
		)
	)
	for g in gb do
		setupGlobalAnimation g
)

fn WOW2_Create_GlobalLoopAnimations gb anims =
(
	WOW2_SimplifyGlobalSequences gb
	case WOW2_ImportMode of
	(
		#Sc2ArtTools: WOW2_Create_GlobalLoopAnimationsSc2 gb anims
		default: WOW2_Create_GlobalLoopAnimationsWc3 gb anims
	)
)

-- ****************************************
-- **				Main Code			    		**
-- ****************************************
--

fn WOW2_PreStart =
(
	mdata = WOW2_Header.Read mstream

    local versionOffset = 0

	if (mdata.fileID != "MD20" and mdata.fileID != "MD21") then throw ("Invalid model file!")
    if (mdata.version < 263) then throw ("Old model format detected. 3.* models and above supported only")
	
    skndata = WOW2_SkinHeader.Read sknstream
    
    if (skndata.fileID != "SKIN") then throw ("Invalid SKIN file!")
	if (mdata.verts.nEntry != skndata.indices.nEntry) then 
		echo ("#WARNING Indices in SKIN file do not match model vertices!")
	
	WOW2_SkinHeader.Fill sknstream skndata
    
	mdata.name = WOW2_ReadData mstream mdata.name #string
    
	mdata.anims = WOW2_Animation.Read mstream mdata.anims
	WOW2_Get_Anims mdata.anims
    
	mdata.GlobalSequences = WOW2_Generate_GlobalSequences mdata.GlobalSequences mstream
	mdata.verts = WOW2_Vertex.Read mstream mdata.verts
	m2bones = WOW2_Bone.Read mstream mdata.bones
	mdata.bonesLU = WOW2_ReadData mstream mdata.bonesLU #uint16

-- 	-- Materials
 	mdata.Textures = WOW2_Texture.Read mstream mdata.Textures
 	mdata.RenderFlags = WOW2_RenderFlags.Read mstream mdata.RenderFlags
 	mdata.TexAnims = WOW2_UVAnimation.Read mstream mdata.TexAnims
 	mdata.Trans = WOW2_Read_Transparencies mstream mdata.Trans
 	mdata.GeoAnims = WOW2_GeosetAnimation.Read mstream mdata.GeoAnims

-- 	-- Texture lookups
-- 	mdata.TexLU = WOW2_ReadData mstream mdata.TexLU #uint16
-- 	mdata.TexUnitsLU = WOW2_ReadData mstream mdata.TexUnitsLU #int16
-- 	
-- 	mdata.TransLU = WOW2_ReadData mstream mdata.TransLU #uint16
-- 	mdata.TexAnimsLU = WOW2_ReadData mstream mdata.TexAnimsLU #int16
-- 	
-- 	-- Objects
 	mdata.Attachs = WOW2_Attachment.Read mstream mdata.attachs
 	mdata.Lights = WOW2_RibbonEmitter.Read mstream mdata.Lights
 	mdata.Particles = WOW2_ParticleEmitter.Read mstream mdata.Particles
 	mdata.Ribbons = WOW2_RibbonEmitter.Read mstream mdata.Ribbons
-- 	
-- 	WOW2_Materials = WOW2_ProcessTextureUnits skndata
-- 	WOW2_Materials = WOW2_LinkMaterials WOW2_Materials mdata skndata
)

fn WOW2_ScriptTime start end =
(
	local totTime = (end - start) / 1000.0
	local totMinutes = (totTime / 60) as integer
	if (totMinutes > 0) then 
	(
		local strMinutes
		if (totMinutes > 1) then strMinutes = " minutes" else strMinutes = " minute"
		local totRemainder = mod totTime 60.0
		totTime = (totMinutes as string) + strMinutes + " " + (totRemainder as string) + " seconds"
	)
	else
	(
		totTime = (totTime as string) + " seconds"
	)
	
	return totTime
)

global ParticleDebug

fn WOW2_Start =
(
	local scrStart = TimeStamp()
	
	echo ("Model Name: "+mdata.name)
	WOW2_Create_Bones m2bones
	
    local executingStep = ""
	try
	(
        executingStep = "Setting up animation data..."
		echo (executingStep )
		WOW2_Set_Anims mdata.anims
        executingStep = "Getting bone animation data..."
		echo (executingStep )
		WOW2_Fill_Bones mstream mdata.anims m2bones 
        executingStep = "Getting object animation data..."
		echo (executingStep )
		WOW2_Fill_Objects mstream  mdata.anims mdata
	)
	catch
	(
		echo ("#ERROR Creating bones failed!: " + executingStep  + " - " +  (getCurrentException()))
	)
	
	WOW2_Create_Mesh ()
	WOW2_AddGeosetAnims mstream mdata.anims
	
	try 
	(
		echo ("Creating Materials...")
		WOW2_Create_Materials()
	)
	catch
	(
		echo "#ERROR Creating materials failed!"
	)
	
 	try
	(
        echo ("Creating attachment helpers...")
        WOW2_Create_Attachments mdata.Attachs m2bones
     
	)
	catch
	(
		echo "#ERROR Creating attachments failed!"
	)
	
	try
	(
		echo ("Creating lights...")
		WOW2_Create_Lights mdata m2bones
	)
	catch
	(
		echo ("#ERROR Creating Lights failed!" + (getCurrentException()))
	)
	
-- 	try
-- 	(
-- 		echo ("Creating Particle Emitters...")
-- 		WOW2_Create_ParticleEmitters mdata m2bones
-- 	)
-- 	catch
-- 	(
-- 		echo ("#ERROR Creating Particle Emitters failed!" + (getCurrentException()))
-- 	)
	
	try
	(
		echo ("Creating Ribbon Emitters...")
		WOW2_Create_RibbonEmitters mdata m2bones
	)
	catch
	(
		echo ("#ERROR Creating Ribbon Emitters failed!" + (getCurrentException()))
	)
	
	try
	(
		echo ("Creating submesh skins...")
		WOW2_Create_Skin skndata.submeshes m2bones mdata.bonesLU
	)
	catch
	(
		echo "#ERROR Creating submesh skins failed!"
	)
	
	try
	(
		echo ("Animating bones...")
		WOW2_Animate_Bones m2bones
	)
	catch
	(
		echo ("#ERROR Animating bones failed!: " + (getCurrentException()))
	)
	
	WOW2_SetBillboarded m2bones
	WOW2_Create_GlobalLoopAnimations mdata.GlobalSequences mdata.anims

    WOW2_RenameBones()
	
	ParticleDebug = #()
	local pflags = #()
	local n = mdata.Particles.count
	if n > 0 then pflags[n] = undefined
	for i in 1 to n do
		pflags[i] = mdata.Particles[i].flags
	local tmp = #()
	local tmp2 = #()
	for i in 1 to n do
	(
		local f = pflags[i]
		local index = (findItem tmp f)
		if index == 0 then
		(
			local arr = #()
			append tmp2 arr
			append tmp f
		)
		else
			append tmp2[index] i
	)
	n = tmp.count
	if n > 0 then ParticleDebug[n] = undefined
	for i in 1 to n do
	(
		local r = copy tmp #nomap
		deleteItem r i
		ParticleDebug[i] = #(tmp2[i],tmp[i],r)
	)

	local scrEnd = TimeStamp()
	local scrTime = WOW2_ScriptTime scrStart scrEnd
	format "Import took %\n" scrTime
	messageBox ("Import successful\nImport took "+scrTime)
	
	max select all
	
	-- Only once doesn't do a proper zoom
	for i = 1 to 3 do
	(
		max zoomext sel all
	)
	
	max views redraw
	ClearSelection()
	
	format "======== Done ========\n" to:listener
)

-- Import
fn WOW2_PreMain =
(	
	WOW2_Reset_Globals()
	if (dbcFile != undefined) then
	(
		if ((doesFileExist dbcFile) == true) then dbcdata = WOW2_DBC_AnimDBC dbcFile
	)
	mstream = WOW2_Open filename
	sknstream = WOW2_Open sknFile
	WOW2_PreStart()
	WOW2_Close bstream
)

fn WOW2_Main =
(
	WOW2_Reset_Globals()
	dbcdata = WOW2_DBC_AnimDBC dbcFile
	mstream = WOW2_Open filename
	sknstream = WOW2_Open sknFile
	WOW2_Start()
	WOW2_Close bstream
)

-- ************************************
-- **		User Interface Code			**
-- ************************************
--

rollout WOW2_AnimUI "M2 Animation" width:480 height:500
(
	fn initListView lv =
	(
		lv.gridLines = true  
		lv.View = (dotNetClass "System.Windows.Forms.View").Details
		lv.fullRowSelect = true 
		lv.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").None
		lv.Checkboxes = true

		layout_def = #(#("Import", 50), #("Animation", 120), #("Frames", 60), #("Rarity", 60), #("Move Speed", 80))

		for i in layout_def do
		(
			lv.Columns.add i[1] i[2] --add column with name and optional width
		)
	)

	fn fillInSpreadSheet lv anims =
	(
		local animOrder = #()
        if ( anims.count ==0 ) then return undefined
		animOrder[anims.count] = 0
		for i = 1 to anims.count do
		(
			animOrder[i] = anims[i].order
		)
		
		lv.Items.Clear()
		theRange = #() -- array to collect the list items
		
		for i = 1 to anims.count do
		(
			local aind = findItem animOrder i
			local anim = anims[aind]
			
			li = dotNetObject "System.Windows.Forms.ListViewItem" (anim.uiIndex as string)
			li.checked = anim.process
			
			sub_li = li.SubItems.add anim.name
			sub_li = li.SubItems.add (anim.frames as string)
			sub_li = li.SubItems.add (anim.rarity as string)
			sub_li = li.SubItems.add (anim.moveSpeed as string)
			
			append theRange li
		)
		
		lv.Items.AddRange theRange -- when done, we populate the ListView
	)
	
	fn checkAllSpreadSheet lv bool =
	(
		for i = 0 to (lv.Items.count - 1) do
		(
			lv.Items.Item[i].checked = bool
		)
	)
	
	fn checkSelected lv bool =
	(
		for i = 0 to (lv.Items.count - 1) do
		(
			local listItem = lv.Items.Item[i]
			if (listItem.selected == true) then
			(
				lv.Items.Item[i].checked = bool
			)
		)
	)
	
	fn SaveAnim lv animdata =
	(
		for i = 0 to (lv.Items.count - 1) do
		(
			local listItem = lv.Items.Item[i]
			local aind = (listItem.text as integer) + 1
			animdata[aind].process = listItem.checked
		)
	)

	-- activeXControl lvAnimation "MSComctlLib.ListViewCtrl" width:430 height:380 align:#center
	dotNetControl lvAnimation "System.Windows.Forms.ListView" width:430 height:380 align:#center
	local selNums = #(), checkStates = #()
	
	button btnCheckAll "Check All" across:4 align:#left
	button btnCheckNone "Uncheck All" align:#left
	button btnCheckSelected "Check Selected" align:#left
	button btnUncheckSelected "Uncheck Selected" align:#left
	
	on WOW2_AnimUI open do 
	(
		-- List view init
		initListView lvAnimation
		
		if (dbcdata != undefined) then
		(
			sortSpreadsheet mdata.anims #name #string
		)
		else
		(
			sortSpreadsheet mdata.anims #uiIndex #value
		)
		
		fillInSpreadSheet lvAnimation mdata.anims
	)
	on WOW2_AnimUI close do
	(
		-- save into animations
		SaveAnim lvAnimation mdata.anims
	)
	-- code borrowed from Jon-Huhn of CGTalk, fixes a bug with the dotnet listview control
	on lvAnimation MouseUp e do 
	(
		for x = 1 to selNums.count do lvAnimation.items.item[selNums[x]].checked=checkStates[x] -- correct the checkboxes
		selNums=#(); checkStates=#() -- clear the record
	)
	on lvAnimation ItemSelectionChanged e do 
	(
		-- record the states of the checkboxes so we can correct them at MouseUp	
		selNums=for x=0 to lvAnimation.selectedIndices.count-1 collect lvAnimation.selectedIndices.item[x]
		checkStates=for x=1 to selNums.count collect lvAnimation.items.item[selNums[x]].checked	
	)
	on lvAnimation ColumnClick arg val do
	(
		SaveAnim lvAnimation mdata.anims
		case (val.column as integer) of
		(
			0: sortSpreadsheet mdata.anims #uiIndex #value
			1: sortSpreadsheet mdata.anims #name #string
			2: sortSpreadsheet mdata.anims #frames #value
			3: sortSpreadsheet mdata.anims #rarity #value
			4: sortSpreadsheet mdata.anims #moveSpeed #value
		)
		
		-- update list
		fillInSpreadSheet lvAnimation mdata.anims
	)
	on btnCheckAll pressed do
	(
		checkAllSpreadSheet lvAnimation true
	)
	on btnCheckNone pressed do
	(
		checkAllSpreadSheet lvAnimation false
	)
	on btnCheckSelected pressed do
	(
		checkSelected lvAnimation true
	)
	on btnUncheckSelected pressed do
	(
		checkSelected lvAnimation false
	)
)


rollout WOW2_GeoUI "M2 Geometry" width:480 height:500
(
	fn initListView lv =
	(
		lv.gridLines = true  
		lv.View = (dotNetClass "System.Windows.Forms.View").Details
		lv.fullRowSelect = true 
		lv.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").None
		lv.Checkboxes = true

		layout_def = #(#("Import", 50), #("Submesh Type", 110), #("Verts", 60), #("Faces", 60), #("Skinned Bones", 90))

		for i in layout_def do
		(
			lv.Columns.add i[1] i[2] --add column with name and optional width
		)
	)

	fn fillInSpreadSheet lv submeshes =
	(
		local smOrder = #()
		smOrder[submeshes.count] = 0
		for i = 1 to submeshes.count do
		(
			smOrder[i] = submeshes[i].order
		)
		
		lv.Items.Clear()
		theRange = #() -- array to collect the list items
		for i = 1 to submeshes.count do
		(
			local smind = findItem smOrder i
			local submesh = submeshes[smind]
			li = dotNetObject "System.Windows.Forms.ListViewItem" (submesh.uiIndex as string)
			li.checked = submesh.process
			
            if ( submesh.name == undefined ) then submesh.name = "Unknown"
            
			sub_li = li.SubItems.add submesh.name
			sub_li = li.SubItems.add (submesh.nverts as string)
			sub_li = li.SubItems.add (submesh.nfaces as string)
			sub_li = li.SubItems.add (submesh.nbones as string)
			
			append theRange li -- we add the list item to the array
		)
		lv.Items.AddRange theRange -- when done, we populate the ListView
	)
	
	fn checkAllSpreadSheet lv bool =
	(
		for i = 0 to (lv.Items.count - 1) do
		(
			lv.Items.Item[i].checked = bool
		)
	)
	
	fn checkSelected lv bool =
	(
		for i = 0 to (lv.Items.count - 1) do
		(
			local listItem = lv.Items.Item[i]
			if (listItem.selected == true) then
			(
				lv.Items.Item[i].checked = bool
			)
		)
	)
	
	fn SaveGeo lv smdata =
	(
		for i = 0 to (lv.Items.count - 1) do
		(
			local listItem = lv.Items.Item[i]
			local smind = (listItem.text as integer) + 1
			smdata[smind].process = listItem.checked
		)
	)
	
	--activeXControl lvGeometry "MSComctlLib.ListViewCtrl" width:430 height:380 align:#center
	dotNetControl lvGeometry "System.Windows.Forms.ListView" width:430 height:380 align:#center
	local selNums = #(), checkStates = #()
	
	button btnCheckAll "Check All" across:4 align:#left
	button btnCheckNone "Uncheck All" align:#left
	button btnCheckSelected "Check Selected" align:#left
	button btnUncheckSelected "Uncheck Selected" align:#left
	
	on WOW2_GeoUI open do 
	(
		-- List view init
		initListView lvGeometry
		fillInSpreadSheet lvGeometry skndata.submeshes
	)
	on WOW2_GeoUI close do
	(
		-- save into geometry
		SaveGeo lvGeometry skndata.submeshes
	)
	-- code borrowed from Jon-Huhn of CGTalk, fixes a bug with the dotnet listview control
	on lvGeometry MouseUp e do 
	(
		for x = 1 to selNums.count do lvGeometry.items.item[selNums[x]].checked=checkStates[x] -- correct the checkboxes
		selNums=#(); checkStates=#() -- clear the record
	)
	on lvGeometry ItemSelectionChanged e do 
	(
		-- record the states of the checkboxes so we can correct them at MouseUp	
		selNums=for x=0 to lvGeometry.selectedIndices.count-1 collect lvGeometry.selectedIndices.item[x]
		checkStates=for x=1 to selNums.count collect lvGeometry.items.item[selNums[x]].checked	
	)
	on lvGeometry ColumnClick arg val do
	(
		SaveGeo lvGeometry skndata.submeshes
		case (val.column as integer) of
		(
			0: sortSpreadsheet skndata.submeshes #uiIndex #value
			1: sortSpreadsheet skndata.submeshes #name #string
			2: sortSpreadsheet skndata.submeshes #verts #value
			3: sortSpreadsheet skndata.submeshes #faces #value
			4: sortSpreadsheet skndata.submeshes #bones #value
		)
		
		-- update spreadsheet
		fillInSpreadSheet lvGeometry skndata.submeshes
	)
	on btnCheckAll pressed do
	(
		checkAllSpreadSheet lvGeometry true
	)
	on btnCheckNone pressed do
	(
		checkAllSpreadSheet lvGeometry false
	)
	on btnCheckSelected pressed do
	(
		checkSelected lvGeometry true
	)
	on btnUncheckSelected pressed do
	(
		checkSelected lvGeometry false
	)
)

rollout WOW2_ModelUI "M2 Model Overview" width:500 height:550
(	
	-- activeXControl tbsMain "MSComctlLib.TabStrip.2" height:20 align:#left visible:true
	dotNetControl tabMain "System.Windows.Forms.TabControl" height:20 width:200 align:#left
	Subrollout subWindow width:450 height:450 align:#center
	button btnImport "Import" align:#center height:35 width:75 across:2 offset:[45,10]
	button btnCancel "Cancel" align:#center height:35 width:75 offset:[-45,10]
	
	fn initTabs tab labels:#() =
	(
		--Clear any existing tabs incase we do an update of them at some point. 
		tab.tabPages.clear()
		--Set the size mode so that we can control their width. 
		tab.sizeMode=tab.sizeMode.fixed
		--Set the width of every tab.
		tab.itemSize=dotnetObject "System.Drawing.Size" ((tab.width/labels.count)-2) 25
		
		--Loop through all the labels that we pass to the function and add a tab by the same name. 
 		for x in labels do tab.tabPages.add x
	)
	
	fn addTabRollout subRoll index =
	(
		--Remove any existing rollouts first. 
 		for x in subRoll.rollouts do removeSubRollout subRoll x
		
		case index of
		(
			0:
			(
				addSubRollout subRoll WOW2_GeoUI
			)
			1:
			(
				addSubRollout subRoll WOW2_AnimUI
			)
		)
	)
	
	on WOW2_ModelUI open do 
	(
		-- Tab init
		initTabs tabMain labels:#("Geometry", "Animation")
		
		-- Geometry view init
		addSubRollout subWindow WOW2_GeoUI
	)
	on WOW2_ModelUI close do
	(
		removeSubRollout subWindow subWindow.rollouts[1]
		WOW2_Reset_Globals()
		try (destroyDialog WOW2_Dialog) catch()
	)
	on tabMain MouseUp senderArg arg do
	(
		addTabRollout subWindow senderArg.SelectedIndex
	)
	on btnImport pressed do
	(
		subWindow.rollouts[1].close()
		WOW2_Start()
		try (destroyDialog WOW2_ModelUI) catch()
	)
	on btnCancel pressed do
	(
		destroyDialog WOW2_ModelUI
	)
)

rollout WOW2_Dialog_Settings "M2 Model Import Settings" width:400 height:350
(
	group "Paths"
	(
		label			lSettDBCPath "DBFilesClient Path: " align:#left
		edittext	tDBCPath width:360 text:WOW2_DBCPath align:#left
		button		bDBCPath "Browse..." tooltip:"Locate your DBC files path" align:#center
	)
	
	group "Settings"
	(
		checkbox chkMaxBonePoint "Use Maxbones or points" checked:(WOW2_useBones_Points) align:#left across:2
		spinner spnM3Scale "Scale:" range:[0,1e8,WOW2_Model_Scale] align:#right width:75
		checkbox chkFlipUV_Y "Flip UV Y-Coord" checked:(WOW2_flipuv_y) align:#left across:2
		spinner spnUseFPS "FPS:" range:[0,1e8,WOW2_UseFPS] type:#integer align:#right width:75
		checkbox chkVertexNormals "Import Vertex Normals" checked:(WOW2_doVertexNormals) align:#left
	)
	
	label		lblSettINIFile "Config File Location (Saves M2 Import settings): " align:#center offset:[0,20]
	edittext	tINIFile align:#center text:(m2impini) readOnly:true width:360
	label		lblINIFileStatus "" align:#center
	
	button bSettSave "Save" align:#center height:30 width:70 tooltip:"Save your settings" across:2 offset:[40,10]
	button bSettCancel "Cancel" align:#center height:30 width:70 tooltip:"Close the settings options without saving" offset:[-40,10]
	
	-- Option Functions
	fn CheckSett inifile = 
	(
		if (doesFileExist inifile) then
		(
			lblINIFileStatus.text = ""
		)
		else
		(
			lblINIFileStatus.text = "Settings file not found! Please save a new one"
		)
	)
	
	on WOW2_Dialog_Settings open do
	(
		CheckSett tINIFile.text
	)
	on bDBCPath pressed do
	(
		local ret = getSavePath initialDir:WOW2_DBCPath
		if ret != undefined then 
		(
			if (ret[ret.count] != "\\") then ret += "\\"
			tDBCPath.text = ret
		)
	)
	on bSettSave pressed do
	(
		local saveGo = true
		local strDBCPath = tDBCPath.text
		if (strDBCPath[strDBCPath.count] != "\\") then strDBCPath += "\\"
		
		local strQuery
		
		if ((matchPattern strDBCPath pattern:"*:\\*") == true) then 
		(
			local adfile = strDBCPath + AnimDataDBC
			if ((doesFileExist adfile) == false) then
			(
				local strQuery = AnimDataDBC + " not found in " + strDBCPath + "\nAnimations won't be named. Continue?"
				saveGo = queryBox strQuery title:(AnimDataDBC + " error")
			)
		)
		else
		(
			local strQuery = "An invalid DBC path has been supplied. \nDBC files won't be loaded. Continue?"
			saveGo = queryBox strQuery title:"DBC path error"
		)
		
		if (saveGo == true) then
		(
			-- assign to Globals
			-- Options
			
			-- Paths
			WOW2_DBCPath				= tDBCPath.text
			WOW2_flipuv_y				= chkFlipUV_Y.checked
			WOW2_UseFPS				= spnUseFPS.value
			WOW2_doVertexNormals	= chkVertexNormals.checked
			WOW2_Model_Scale				= spnM3Scale.value
			WOW2_useBones_Points  = chkMaxBonePoint.checked
			--Write Settings to INIFile
			WriteINI tINIFile.text
			
			DestroyDialog WOW2_Dialog_Settings
		)
	)
	on bSettCancel pressed do
	(
		DestroyDialog WOW2_Dialog_Settings
	)
)

rollout WOW2_Dialog "M2 Model Import v 3.6" width:400 height:370
(
    label lbl1 "Character models in experimental import mode!"
    
	
	GroupBox grp1 "Model and Skin" pos:[4,17] width:392 height:172
	edittext tFileName "Model Filename:" pos:[13,36] width:374 height:20 labelOnTop:true
	button bOpenFile "Browse..." pos:[170,86] width:60 height:21 toolTip:"Locate a M2 file"
	edittext tSkinFileName "Skin Filename:" pos:[13,112] width:374 height:20 labelOnTop:true
	button bSkinOpenFile "Browse..." pos:[170,162] width:60 height:21 toolTip:"Locate a Skin file"

	button bSettings "Paths/Settings..." pos:[127,274] width:120 height:25 toolTip:"Configure your M2 Importer settings"

	button bOK "Open" pos:[52,315] width:75 height:35 toolTip:"Open an M2" across:2
	button bCancel "Cancel" pos:[281,316] width:75 height:35 toolTip:"Close M2 Importer"
	GroupBox grp4 "Formating" pos:[4,193] width:390 height:65
	radiobuttons rdoMode "Toolset:" pos:[43,210] width:245 height:30 enabled:true labels:#("Normal", "Warcraft III", "Sc2ArtTools") default:2 columns:3
	
    on WOW2_Dialog close do
	(
		try
		(
			DestroyDialog WOW2_Dialog
			DestroyDialog WOW2_Dialog_Settings
			DestroyDialog WOW2_ModelUI
		)
		catch()
	)
	on bOpenFile pressed do
	(
		uiOpenFile "M2 model (*.m2)|*.m2|All Files|*.*|" &tFileName.text
	)
	on bSkinOpenFile pressed do
	(
		uiOpenFile "Skin file (*.skin)|*.skin|All Files|*.*|" &tSkinFileName.text
	)
	on bSettings pressed do
	(
		CreateDialog WOW2_Dialog_Settings
	)
	on bOK pressed do
	(
		if (tFileName.text == "" or tFileName.text == undefined) then
		(
			Messagebox "Please open a valid M2 file"
		)
		else if (tSkinFileName.text == "" or tSkinFileName.text == undefined) then
		(
			Messagebox "Please open a valid SKIN file"
		)
		else
		(
			local dbcCheck = WOW2_DBCPath + AnimDataDBC
			if ((doesFileExist dbcCheck) == true) then dbcFile = dbcCheck
			filename = tFileName.text
			sknFile = tSkinFileName.text
			WOW2_PreMain()
			createDialog WOW2_ModelUI
		)
	)
	on bCancel pressed do
	(
		DestroyDialog WOW2_Dialog
	)
	
)
	
fn WOW2_UI_Main =
(
	if WOW2_Dialog != undefined do
	(
		try (closerolloutfloater WOW2_Dialog) catch()
	)		

	CreateDialog WOW2_Dialog style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
	WOW2_Dialog.placement = #normal
)

utility m2impexp "WoW M2 Import v3.6"
(
	button 	bImport "Import" height:30 width:75
		
	on bImport pressed do
	(
		WOW2_UI_Main()
	)
	
)

macroscript GriffonStudios_ImportWorldOfWarcraft
    category:"Griffon Studios"
    internalcategory:"Griffon Studios"
    buttonText:"Import WoW Model"
    toolTip:"Import World of Warcraft Model(.m2)"
	icon:#("GriffonStudios",7)
(
    on execute do
    (
        WOW2_UI_Main()
    )
)
