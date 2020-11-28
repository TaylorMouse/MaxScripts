-- Updated by Taylor Mouse to 2.0.5

-- Updated by NiNtoxicated (madyavic@gmail.com) to v2.0.4
-- Originally created by Philip Laing. All credits for the original source go to him!
-- Thanks to BlinkBoy from The Hive Workshop for help with animations
--
-- Version History:

/* 2.0.5 - 3rd March 2018
    - Fixed the SC2AttachPt class
    - Fixed the Naming algorithm for Attachment Points
    - Added layers for different object classes
    - Fixed the scaling for SC2 Mod
    - Added collision spheres and animation
    - Changed the color of meshes to be random for easy access
    - Fixed the notetrack for animation selection
    - Fixed animation frames to support 30 FPS correctly
    
*/
/* 2.0.4 - 15th July 2010
    - Fixed crash caused be incorrectly read animated geoset chunks
    - Added basic attachment conversion to proper M3 attachment ID's
    - Added basic sequence name conversion to proper M3 format
    - Fixed bad interpolations between animation sequences
    - Fixed attachment M3 objects being scaled improperly
*/
/* 2.0.3 - 28th June 2010 
    - Now works with later versions of 3ds Max
    - Fixed a bug that crashed the script due to not refreshing the viewports after adding bones to skin modifier
    - Updated animation code, now imports animations correctly
    - Updated the vertex normal code so that the correct vertex normals are now being applied
    - Added import as M3 option for importing attachments/animations as M3 objects/structures if correct sc2objects.ms is loaded
*/
ClearListener()

utility ImpExpMDX "Warcraft 3 MDX Importer"
(
	----------
	-- Vars --
	----------
	local modelName
	local g_m3boneRoot
	local g_m3import = true
	local g_useFPS = 30
	local g_sc2vers = 0.05

	local impTypes

	local seqs			-- Sequences
	local mtls			-- Materials
	local geos			-- Geometry
	local objs			-- Bones, Helpers, Lights, Attachments
	local pivot

	local geobones

	local notes			-- Note Track

	----------------
	-- Structures --
	----------------

	struct trackPoint
	(
		time, point, inTan, outTan
	)

	struct gVert
	(
		no, verts = #(), nrmls = #(), txtrs = #(), group = #()
	)

	struct gPvtx
	(
		crns, faces = #()
	)

	struct Bone
	(
		type=#bone, name, parent, mesh, tr, rt, sc, id, aid, end, no = #()
	)

	struct Helper
	(
		type=#helper, name, parent, mesh, tr, rt, sc, no = #()
	)

	struct Light
	(
		type=#light, name, parent, mesh, vis, ltype, aStart, aEnd, col, int, ambCol, ambInt, no = #()
	)

	struct Attachment
	(
		type=#attach, name, parent, mesh, tr, rt, sc, vis, no = #()
	)

	struct PartEmitter
	(
		type=#pemit, name, parent, mesh, tr, rt, sc, vis,
		speed, variation, latitude, gravity, lifespan, emissionrate,
		length, width, rows, columns, taillength, time, segCol = #(), alpha,
		partSc, LifeSpanUVAnim, DecayUVAnim, TailUVAnim, TailDecayUVAnim,
		TextureID, no = #()
	)

	struct Geometry
	(
		pnts = gVert(), pvtx = gPvtx(), mesh,
		bRad, minExt, maxExt, name,
		groups = #(), bones = #(), bonegroups = #()
	)

	struct Sequence
	(
		name, intStart, intEnd, moveSpeed, noloop, rarity, long,
		bRad, minExt, maxExt
	)

	struct Material
	(
		bytes, layers = #()
	)

	struct Layer
	(
		fmode,shade,texture,alpha
	)
	
	struct MDX_M3SEQS
	(
		name, seqInd, cstart, cend, moveSpeed, looping, freq
	)

	struct File
	(
		pos, end, bstream,

		-- Helper function to init the top-level chunk rover
		fn Init stream=
		(
			bstream = stream
			pos = ftell bstream
			fseek bstream 0 #seek_end
			end = ftell bstream
		),

		fn fReadHead=
		(
			fseek bstream pos #seek_set
			local id = ReadLong bstream #unsigned
			local tag = File.GetName id
			pos += 4
			tag
		),

		fn fReadFloat=
		(
			local id
			local i = 0
			while (id == undefined) and (i < 10) do
			(
				fseek bstream pos #seek_set
				id = ReadFloat bstream
				i += 1
			)
			if i == 10 then
			(
				print ("problem: " + (pos as string))
			)
			pos += 4
			id
		),

		fn fReadLong=
		(
			fseek bstream pos #seek_set
			local id = ReadLong bstream
			pos += 4
			id
		),

		fn fReadShort=
		(
			fseek bstream pos #seek_set
			local id = ReadShort bstream
			pos += 2
			id
		),

		fn fReadByte=
		(
			fseek bstream pos #seek_set
			local id = ReadByte bstream
			pos += 1
			id
		),

		fn fReadString n=
		(
			fseek bstream pos #seek_set
			local id = ReadString bstream
			pos += n*80
			id
		),

		fn GetName id=
		(
			case id of
			(
				--MDLX HEAD
				0x584C444D: #MDLX

				0x53524556: #VERS
				0x4C444F4D: #MODL
				0x53514553: #SEQS

				0x53424C47: #GLBS

				--MATERIALS
				0x534C544D: #MTLS
				0x41544D4B: #KMTA
				0x53584554: #TEXS


				--GEOMETRY
				0x534F4547: #GEOS

				0x58545256: #VRTX
				0x534D524E: #NRMS
				0x50595450: #PTYP
				0x544E4350: #PCNT
				0x58545650: #PVTX
				0x58444E47: #GNDX
				0x4347544D: #MTGC
				0x5354414D: #MATS
				0x53415655: #UVAS
				0x53425655: #UVBS

				--GEOMETRY ANIMATION
				0x414F4547: #GEOA

				--BONE
				0x454E4F42: #BONE

				--LIGHT
				0x4554494C: #LITE

				--HELPER
				0x504C4548: #HELP

				--ATTACHMENT
				0x48435441: #ATCH

				--PIVOT
				0x54564950: #PIVT

				--PARTICLE EMITTER
				0x32455250: #PRE2

				--EVENT
				0x53545645: #EVTS
				0x5456454B: #KEVT

				--COLLISION
				0x44494C43: #CLID

				--KEYFRAME TRACK
				0x4F41474B: #KGAO

				0x5254474B: #KGTR
				0x5452474B: #KGRT
				0x4353474B: #KGSC

				0x56414C4B: #KLAV
				0x5654414B: #KATV
				0x5632504B: #KP2V

				0x5632504B: #KP2E

				--UNKNOWN
				default: #UNKNOWN
 			)
		)
	)

    function CreateLayer layerName =
    (
        /* Create layer in MAX, if it exists, just return a reference to that layer */
        /* fn by Taylor Mouse */
        local findlayer = LayerManager.GetLayerFromName layerName
        if(findlayer == undefined) then
        (
            findlayer = LayerManager.NewLayerFromName layerName
        )
        return findlayer
    )
	
    fn ReadFixedString stream val =
    (
        local str = ""
        
        if ( val != 0 ) then 
        (
        
            for i=1 to val do
            (
                s= bit.IntAsChar(ReadByte stream)
                if ( s !="\0") then str+=s
            )
        )
        return str
    )
    
    function BuildCollision mdxStream =
    (
        -- size = 116 bytes
        local collLayer = CreateLayer "HitTests"
        local streamPos = ftell mdxStream
        
        fseek mdxStream (streamPos - 4) #seek_set
        
        local totalSize = readLong mdxStream
        local nbrItems = totalSize / 116

        for i=1 to nbrItems do
        (
            
            local headerSize = readLong mdxStream -- 96 bytes
            local objName = ReadFixedString mdxStream 80 -- max 80 characters
            local unk3 = (readLong mdxStream ) + 1
            
            local FFFF = readLong mdxStream #signed -- FF FF FF FF
            
            local unk1 = readLong mdxStream
            local parentBoneId = readLong mdxStream +1
            
            local x = readFloat mdxStream
            local y = readFloat mdxStream
            local z = readFloat mdxStream
            
            local objPos = [y, -x, z]
            local radius = readFloat mdxStream
            
            local collObj = sphere name:objName pos:objPos radius:radius mapcoords:off segs:32
            
            -- rename to sc2
            if( g_m3import == true ) then
            (
                collObj.name = "HitTestFuzzy" + ( trimleft  ((1000 + i ) as string) "1" )
                collObj.wirecolor = color 0 0 255
                collObj.boxmode = on
                collObj.renderable = off
                freeze collObj
            )
           
            if ( parentBoneId <= objs.count ) then 
            (
                collObj.parent = objs[parentBoneId].mesh
            )
            collLayer.AddNode collObj
        )
        
        
    )
    
	fn pseqs mdx i=
	(
		seqs[i] = Sequence()

		seqs[i].name = mdx.fReadString 1
		seqs[i].intStart = mdx.fReadLong()
		seqs[i].intEnd = mdx.fReadLong()
		seqs[i].moveSpeed = mdx.fReadFloat()
		seqs[i].noloop = mdx.fReadLong()
		seqs[i].rarity = mdx.fReadFloat()
		seqs[i].long = mdx.fReadLong()
		mdx.pos += 28
		
		--animationRange = Interval 0 seqs[i].intEnd
	)

	fn pmtls mdx i=
	(
		mtls[i] = Material()

		local bytes = mdx.fReadLong()


		--long ???, ???
		mdx.pos += 8

		if mdx.fReadHead() == #LAYS then
		(
			local nlays = mdx.fReadLong()
			for j=1 to nlays do
			(
				mtls[i].layer[j] = Layer()

				local bytesi = mdx.fReadLong()

				local endpos = mdx.pos + bytesi - 4;

				mtls[i].layer[j].fmode = mdx.fReadLong()
				mtls[i].layer[j].shade = mdx.fReadLong()
				mtls[i].layer[j].texture = mdx.fReadLong()

				--0xFFFFFFFF, long ???
				mdx.pos += 8

				mtls[i].layer[j].alpha = mdx.fReadFloat()
				if mdx.pos == endpos then
				(
					--KMTA
					mdx.pos += 4
					local nunks = mdx.fReadLong()
					local ltype = mdx.fReadLong()
					--0xFFFFFFFF
					mdx.pos += 4
					for k=1 to nunks do
					(
						--keyframe, state
						mdx.pos += 8

						--intan,outtan
						if ltype > 1 then mdx.pos += 8
					)
				)
				if mdx.pos != endpos then
				(
					print mdx.pos
					print endpos
				)
			)
		)
	)
	
	fn MDX_SetVertexNormals mesh ncount pnts =
	(
		max modify mode
		addmodifier mesh (edit_normals name:"vnorms")
		en = mesh.modifiers[#vnorms]
		modPanel.setCurrentObject en

		en.displaylength = 0.05
		
		-- speeds up processing
		en_ConvVert	= en.ConvertVertexSelection
		en_SetSelection = en.SetSelection
		en_Unify = en.unify
		en_Move = en.move
		
		-- Method: 1
		for i = 1 to ncount do
		(
			my_vert = #{i}
			my_norm = #{}
			en_ConvVert &my_vert &my_norm
			en_SetSelection my_norm node:mesh
			en_Unify node:mesh
			en_Move pnts.nrmls[i]
		)
		
		local nNormals = en.getNumNormals node:mesh
		en.select #{1..nNormals} node:mesh -- select all normals
		en.MakeExplicit node:mesh -- make them explicit
		en.select #{1..nNormals} node:mesh invert:true -- deselect them
		
		-- collapse edit_normal modifier
		collapseStack mesh
	)


	fn pgeos mdx i=
	(
		geos[i] = Geometry()
        
        local unitLayer = CreateLayer "Unit"
        
		local pnts = gVert()
		local pvtx = gPvtx()

		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		local curChunk = mdx.fReadHead()

		local j = 0
		while (mdx.pos < endpos) and (curChunk != #GEOA) and (j < 1) do
		(
			--print curChunk
			--print mdx.pos
			case curChunk of
			(
				#VRTX:
				(
					geos[i].pnts.no = mdx.fReadLong()
					for k=1 to geos[i].pnts.no do
					(
						local x = mdx.fReadFloat()
						local y = mdx.fReadFloat()
						local z = mdx.fReadFloat()
						pnts.verts[k] = [y,-x,z]
					)
				)
				#NRMS:
				(
					geos[i].pnts.no = mdx.fReadLong()
					for k=1 to geos[i].pnts.no do
					(
						local x = mdx.fReadFloat()
						local y = mdx.fReadFloat()
						local z = mdx.fReadFloat()
						pnts.nrmls[k] = [y,-x,z]
					)
				)
				#PTYP:
				(
					mdx.pos += 8
				)
				#PCNT:
				(
					mdx.pos += 8
				)
				#PVTX:
				(
					geos[i].pvtx.crns = mdx.fReadLong()
					for k=1 to (geos[i].pvtx.crns/3) do
					(
						local x = 1 + mdx.fReadShort()
						local y = 1 + mdx.fReadShort()
						local z = 1 + mdx.fReadShort()
						pvtx.faces[k] = [x,y,z]
					)
				)
				#GNDX:
				(
					geos[i].pnts.no = mdx.fReadLong()
					for k=1 to geos[i].pnts.no do
					(
						geos[i].pnts.group[k] = (1 + mdx.fReadByte())
					)
				)
				#MTGC:
				(
					local num = mdx.fReadLong()
					for k=1 to num do
					(
						geos[i].bonegroups[k] = mdx.fReadLong()
					)
				)
				#MATS:
				(
					local num = mdx.fReadLong()
					local n = 0
					local o = 0
					for k=1 to num do
					(
						if (n == 0) or (o == geos[i].bonegroups[n]) then
						(
							n +=1
							o = 0
							geos[i].bones[n] = #()
						)
						o += 1
						geos[i].bones[n][o] = 1 + mdx.fReadLong()
						local bool = true
						for l=1 to geos[i].groups.count do
						(
							if geos[i].groups[l] == geos[i].bones[n][o] then
							(
								bool = false
								exit
							)
						)
						if bool == true then
						(
							local index = 1 + geos[i].groups.count
							geos[i].groups[index] = geos[i].bones[n][o]
						)
						sort geos[i].groups
					)
					mdx.pos += 12
				)
				#UVAS:
				(
					mdx.fReadLong()
				)
				#UVBS:
				(
					geos[i].pnts.no = mdx.fReadLong()
					for k=1 to geos[i].pnts.no do
					(
						local x = mdx.fReadFloat()
						local y = 1 - mdx.fReadFloat()
						pnts.txtrs[k] = [x,y,0]
					)
					j+=1
				)
				default:
				(
					local x
					local y
					local z
					mdx.pos -= 4;
					geos[i].bRad = mdx.fReadFloat()
					x = mdx.fReadFloat()
					y = mdx.fReadFloat()
					z = mdx.fReadFloat()
					geos[i].minExt = [y,-x,z]
					x = mdx.fReadFloat()
					y = mdx.fReadFloat()
					z = mdx.fReadFloat()
					geos[i].maxExt = [y,-x,z]
					local nanim = mdx.fReadLong()
					for j=1 to nanim do
					(
						mdx.pos += 28
					)
				)
			)
			curChunk = mdx.fReadHead()
		)
		geos[i].mesh = mesh vertices:pnts.verts faces:pvtx.faces

        geos[i].mesh.wirecolor = Color (random 0 255) (random 0 255) (random 0 128)
        
        unitLayer.AddNode geos[i].mesh
        
		setNumTVerts geos[i].mesh pnts.txtrs.count
		for k = 1 to pnts.txtrs.count do
		(
			setTVert geos[i].mesh k pnts.txtrs[k]
		)

		buildTVFaces geos[i].mesh

		for k = 1 to pvtx.faces.count do
		(
			setTVFace geos[i].mesh k pvtx.faces[k]
		)

		MDX_SetVertexNormals geos[i].mesh geos[i].pnts.no pnts

		geos[i].mesh.name = modelName + (i as string)

		geobones[i] = #()
	)

	fn pgeoa mdx i=
	(
		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		mdx.pos += 20

		local frame = #()
		local state = #()
		local num
		local ltype
		local j = 1 + mdx.fReadLong()
		
		if mdx.fReadHead() == #KGAO then
		(
			num = mdx.fReadLong()
			ltype = mdx.fReadLong()
			mdx.pos += 4
			for k=1 to num do
			(
				frame[k] = mdx.fReadLong()
				state[k] = mdx.fReadFloat()
			)
		)
		else
		(
			mdx.pos -= 4
		)
		
		mdx.pos = endpos

		animate on at time 0 geos[j].mesh.visibility = on

		local c = bezier_float()
		geos[j].mesh[1].controller = c
		for k=1 to seqs.count do
		(
			local d = addNewKey c seqs[k].intStart
			d.value = 1
			d.inTangentType = #step
			d.outTangentType = #step
		)
		for k=1 to frame.count do
		(
			local d = addNewKey c frame[k]
			d.value = state[k]
			d.inTangentType = #step
			d.outTangentType = #step
		)
	)

	fn fKG mdx head=
	(
		local x
		local y
		local z
		local w
		local pt
		local prev
		local time
		local array = #()
		local num = mdx.fReadLong()
		local LineType = mdx.fReadLong()
		mdx.pos += 4;
		if head == #KGRT then
		(
			prev = quat 0 0 0 1
		)

		for j = 1 to num do
		(
			array[j] = trackPoint()
			
            time = mdx.fReadLong() 
            
			array[j].time = time
			if head == #KGRT then
			(
				x = mdx.fReadFloat()
				y = mdx.fReadFloat()
				z = mdx.fReadFloat()
				w = mdx.fReadFloat()
				pt = quat y -x z w
				--prev = quat y -x z w
			)
			else
			(
				x = mdx.fReadFloat()
				y = mdx.fReadFloat()
				z = mdx.fReadFloat()
				if head == #KGSC then pt = [y,x,z]
				else pt = [y,-x,z]
			)
			array[j].point = pt
			if LineType > 1 then
			(
				x = mdx.fReadFloat()
				y = mdx.fReadFloat()
				z = mdx.fReadFloat()
				if head == #KGRT then
				(
					w = mdx.fReadFloat()
					pt = quat y -x z w
				)
				else pt = [y,-x,z]
				array[j].inTan = pt
				x = mdx.fReadFloat()
				y = mdx.fReadFloat()
				z = mdx.fReadFloat()
				if head == #KGRT then
				(
					w = mdx.fReadFloat()
					pt = quat y -x z w
				)
				else pt = [y,-x,z]
				array[j].outTan = pt
			)
		)
		return array
	)

	fn fKV mdx head=
	(
		local array = #()

		local num = mdx.fReadLong()
		local LineType = mdx.fReadLong()
		mdx.pos += 4;
		for j = 1 to num do
		(
			array[j] = trackPoint()
			mdx.pos += 4;
			array[j].point = mdx.fReadFloat()
			if LineType > 1 then
			(
				array[j].inTan = mdx.fReadFloat()
				array[j].outTan = mdx.fReadFloat()
			)
		)
		return array
	)

	fn pbone mdx=
	(
		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		local name = mdx.fReadString 1
		local i = 1 + mdx.fReadLong()

		objs[i] = Bone()

		objs[i].name = name

		objs[i].parent = 1 + mdx.fReadLong()
		mdx.pos += 4

		while mdx.pos < endpos do
		(
			local curChunk = mdx.fReadHead()
			case curChunk of
			(
				#KGTR:
				(
					objs[i].tr = fKG mdx curChunk
				)
				#KGRT:
				(
					objs[i].rt = fKG mdx curChunk
				)
				#KGSC:
				(
					objs[i].sc = fKG mdx curChunk
				)
			)
		)
		objs[i].id = 1 + mdx.fReadLong()
		objs[i].aid = 1 + mdx.fReadLong()
		if objs[i].id > 0 then geobones[objs[i].id][geobones[objs[i].id].count+1] = i
		else
		(
			for k=1 to geobones.count do
			(
				append geobones[k] i
			)
		)
	)

	fn plite mdx=
	(
		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		mdx.fReadLong()

		local name = mdx.fReadString 1

		local i = 1 + mdx.fReadLong()

		objs[i] = Light()

		objs[i].name = name

		objs[i].parent = 1 + mdx.fReadLong()
		mdx.pos += 4

		objs[i].ltype = mdx.fReadLong()
		objs[i].aStart = mdx.fReadFloat()
		objs[i].aEnd = mdx.fReadFloat()
		local r = mdx.fReadFloat()
		local g = mdx.fReadFloat()
		local b = mdx.fReadFloat()
		objs[i].col = [255*r,255*g,255*b]
		objs[i].int = mdx.fReadFloat()
		local r = mdx.fReadFloat()
		local g = mdx.fReadFloat()
		local b = mdx.fReadFloat()
		objs[i].ambCol = [255*r,255*g,255*b]
		objs[i].ambInt = mdx.fReadFloat()

		if mdx.fReadHead() == #KLAV then
			objs[i].vis = fKV mdx #KLAV
		else mdx.pos -= 4
	)

	fn phelp mdx=
	(
		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		local name = mdx.fReadString 1
		local i = 1 + mdx.fReadLong()

		objs[i] = Helper()

		objs[i].name = name

		objs[i].parent = 1 + mdx.fReadLong()
		mdx.pos += 4

		while mdx.pos < endpos do
		(
			local curChunk = mdx.fReadHead()
			case curChunk of
			(
				#KGTR:
				(
					objs[i].tr = fKG mdx curChunk
				)
				#KGRT:
				(
					objs[i].rt = fKG mdx curChunk
				)
				#KGSC:
				(
					objs[i].sc = fKG mdx curChunk
				)
			)
		)
	)

	fn patch mdx=
	(
		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		mdx.fReadLong()

		local name = mdx.fReadString 1

		local i = 1 + mdx.fReadLong()

		objs[i] = Attachment()

		objs[i].name = name

		objs[i].parent = 1 + mdx.fReadLong()
		mdx.pos += 4

		mdx.pos += 264

		while mdx.pos < endpos do
		(
			local curChunk = mdx.fReadHead()
			case curChunk of
			(
				#KGTR:
				(
					objs[i].tr = fKG mdx curChunk
				)
				#KGRT:
				(
					objs[i].rt = fKG mdx curChunk
				)
				#KGSC:
				(
					objs[i].sc = fKG mdx curChunk
				)
				#KATV:
				(
					objs[i].vis = fKV mdx curChunk
				)
			)
		)
	)

	fn ppre2 mdx=
	(
		local bytes = mdx.fReadLong()

		local endpos = mdx.pos + bytes - 4

		mdx.fReadLong()

		local name = mdx.fReadString 1

		local i = 1 + mdx.fReadLong()

		objs[i] = PartEmitter()

		objs[i].name = name

		objs[i].parent = 1 + mdx.fReadLong()
		mdx.pos += 4

		mdx.pos += 264

		while mdx.pos < endpos do
		(
			local curChunk = mdx.fReadHead()
			case curChunk of
			(
				#KGTR:
				(
					objs[i].tr = fKG mdx curChunk
				)
				#KGRT:
				(
					objs[i].rt = fKG mdx curChunk
				)
				#KGSC:
				(
					objs[i].sc = fKG mdx curChunk
				)
				#KP2E:
				(
					objs[i].emissionrate = fKV mdx #KP2E
				)
				#KP2V:
				(
					objs[i].vis = fKV mdx curChunk
				)
				default:
				(
					mdx.pos -= 4
					objs[i].speed = mdx.fReadFloat()
					objs[i].variation = mdx.fReadFloat()
					objs[i].latitude = mdx.fReadFloat()
					objs[i].gravity = mdx.fReadFloat()
					objs[i].lifespan = mdx.fReadFloat()
					objs[i].emissionrate = mdx.fReadFloat()
					objs[i].length = mdx.fReadFloat()
					objs[i].width = mdx.fReadFloat()
					mdx.pos += 4
					objs[i].rows = mdx.fReadLong()
					objs[i].columns = mdx.fReadLong()
					mdx.pos += 4
					objs[i].taillength = mdx.fReadFloat()
					objs[i].time = mdx.fReadFloat()
					objs[i].segCol[1] = [255*mdx.fReadFloat(),255*mdx.fReadFloat(),255*mdx.fReadFloat()]
					objs[i].segCol[2] = [255*mdx.fReadFloat(),255*mdx.fReadFloat(),255*mdx.fReadFloat()]
					objs[i].segCol[3] = [255*mdx.fReadFloat(),255*mdx.fReadFloat(),255*mdx.fReadFloat()]
					objs[i].alpha = [mdx.fReadByte(),mdx.fReadByte(),mdx.fReadByte()]
					objs[i].partSc = [mdx.fReadFloat(),mdx.fReadFloat(),mdx.fReadFloat()]
					objs[i].LifeSpanUVAnim = [mdx.fReadLong(),mdx.fReadLong(),mdx.fReadLong()]
					objs[i].DecayUVAnim = [mdx.fReadLong(),mdx.fReadLong(),mdx.fReadLong()]
					objs[i].TailUVAnim = [mdx.fReadLong(),mdx.fReadLong(),mdx.fReadLong()]
					objs[i].TailDecayUVAnim = [mdx.fReadLong(),mdx.fReadLong(),mdx.fReadLong()]
					objs[i].TextureID = mdx.fReadLong()
					mdx.pos += 12
				)
			)
		)
	)
	
	fn MDX_Bone_Depth b =
	(
		if b.parent == 0 then return 0
		else return ( 1 + MDX_Bone_Depth objs[b.parent] )
	)

	fn MDX_Sort_Bones objbones =
	(
		local ba = #()
		for i = 1 to objbones.count do
		(
			bonerec = [(MDX_Bone_Depth objbones[i]), i]
			append ba bonerec
		)
		fn compfn a b = (if a.x<b.x then return 1; if a.x>b.x then return -1; return 0;)
		qsort ba compfn
		return ba
	)
	
	fn MDX_setNodeWorldRotation theNode theRot = 
	( 
		in coordsys (transmatrix theNode.transform.pos) 
			theNode.rotation = theRot
	)
	
	fn MDX_qdot q1 q2 = return ((q1.x*q2.x) + (q1.y*q2.y) + (q1.z*q2.z) + (q1.w*q2.w))
	
	fn MDX_Bones_Bindpose mbones origFrame newFrame =
	(
		local bd = MDX_Sort_Bones mbones
		for i=1 to mbones.count do
		(
			local bind = bd[i].y
			local b = mbones[i]
			
			local origTrans
			set time origFrame 
			origTrans = copy b.mesh.transform
			with animate on
			(
				set time newFrame
				b.mesh.transform = origTrans
			)
		)
	)
	
	fn makeBones rotState =
	(
        local bonesLayer = CreateLayer "Bones"
        
        local attachmentLayer = CreateLayer "Attachments"
        
		local mdx_attachList = #("Head Ref", "Head - Ref", "Origin Ref", "Foot Right Ref", "Foot Left Ref", "Chest Ref", "Hand Right Ref", "Weapon Right Ref", "Hand Left Ref", "Weapon Left Ref", "Weapon Ref", "OverHead Ref")
		local m3_attachList = #("Ref_Head", "Ref_Head", "Ref_Origin", "Ref_Hardpoint 01", "Ref_Hardpoint 02", "Ref_Target", "Ref_Weapon Right", "Ref_Weapon Right", "Ref_Weapon Left", "Ref_Weapon Left", "Ref_Weapon", "Ref_Overhead")
        
		for i=1 to objs.count do
		(
			if (i == 1) then
			(
				-- create bone to be scaled down
				g_m3boneRoot = Bonesys.createBone [0,0,0] [0,0,0] [0,0,1]
                
                -- add the node to a nice layer - TM
                bonesLayer.AddNode  g_m3boneRoot
                
				g_m3boneRoot.width = 0
				g_m3boneRoot.height = 0
				g_m3boneRoot.name = "m3bone_root"
			)

			case objs[i].type of
			(
				#bone:
				(
					local cbone = BoneSys.createBone pivot[i] pivot[i] [0,0,1]
                    cBone.Width = 0.05
                    cBone.Height = 0.05
					cbone.name = objs[i].name
					cbone.boneScaleType = #none
					cbone.showLinks = true
					objs[i].mesh = cbone
                    bonesLayer.AddNode cbone
				)
				#helper:
				(
					--objs[i].mesh = point pos:pivot[i]
					--objs[i].mesh.name = objs[i].name
					local cbone = BoneSys.createBone pivot[i] pivot[i] [0,0,1]
                    cBone.Width = 0.05
                    cBone.Height = 0.05
					cbone.name = objs[i].name
					cbone.boneScaleType = #none
					cbone.showLinks = true
					objs[i].mesh = cbone
                    bonesLayer.AddNode cbone
				)
				#light:
				(
                    local lightsLayer = CreateLayer "Lights"
					objs[i].mesh = omniLight pos:pivot[i] rgb:objs[i].col multiplier:objs[i].int
					objs[i].mesh.name = objs[i].name
                    lightsLayer.AddNode objs[i].mesh
				)
				#attach:
				(
                    -- TM correcthe the SC2Attachment to SC2AttachPt cuz that is the new sc2 object class
					if (g_m3import == true and SC2AttachPt != undefined) then
					(
						local sc2att = SC2AttachPt pos:pivot[i]
						local aname = trimleft ( trimright objs[i].name )
						
                        
						for j = 1 to mdx_attachList.count do
						(
                            -- TM Changed algorithm to find the attachment point names for SC2 mod
							if ( mdx_attachList[j] == aname ) then 
                            (
                                aname = m3_attachList[j]
                                
                                exit
                            )
						)
						sc2att.name = aname
						 
						objs[i].mesh = sc2att
                        
                        
                        
					)
					else
					(
						objs[i].mesh = point pos:pivot[i]
                        objs[i].mesh.name = objs[i].name
					)
					
                    attachmentLayer.AddNode objs[i].mesh
				)
			)
		)
		
		max views redraw
		
		bd = MDX_Sort_Bones objs
		
		for i=1 to objs.count do
		(
			if objs[i].parent != 0 then
			(
				local par = objs[i].parent
				-- echo ("Setting parent of " + i as string + " to " + (bones_read[i].par+1) as string)
				objs[i].mesh.parent = objs[par].mesh
			)
			else
			(
				objs[i].mesh.parent = g_m3boneRoot
			)
		)
		
		max views redraw
		for i=1 to objs.count do
		(
			local h = bd[i].y
			objbone = objs[h]

			--if objbone.parent != 0 then
			--(
				--objbone.mesh.parent = objbone[objbone.parent].mesh
				--objbone.mesh.pivot = pivot[objbone.parent]
			--)
			local mdxBones = #()
			if (objbone.type == #bone) or (objbone.type == #helper) then
			(
				local cb = objbone.mesh
				append mdxBones objbone
				animate on
				(
					if objbone.tr != undefined then
					(
						set coordsys parent
						local opos
						at time 0 (opos = cb.pos)
						for j=1 to objbone.tr.count do
						(
                            -- changed time
							local frame = (objbone.tr[j].time * 30  / 1000.0)  as integer
							local pos = opos + objbone.tr[j].point
							
							at time frame
							(
								cb.position = pos
							)
						)
					)
					
					if objbone.sc != undefined then
					(
						set coordsys parent
						local oscale
						at time 0 (oscale = cb.scale)
						for j=1 to objbone.sc.count do
						(
                            -- changed time
							local frame = objbone.sc[j].time * 30  / 1000.0  as integer
							local bscale = objbone.sc[j].point
							
							at time frame
							(
								cb.scale = bscale
							)
						)
					)
					if (objbone.rt != undefined) and (rotState == true) then
					(
						local prevq = quat 1
						for j = 1 to objbone.rt.count do
						(
							local cb = objbone.mesh
                            -- changed time
							local frame = objbone.rt[j].time * 30  / 1000.0  as integer
							local key = objbone.rt[j].point

							local par = cb.parent
							local q
							if par != undefined then 
							(
								q = par.rotation * key 
							)
							else 
							(
								q = key
							)
							
							at time frame
							(
								MDX_setNodeWorldRotation cb q
								local newq = copy cb.rotation
								if (MDX_qdot newq prevq < 0 and j > 1) then cb.rotation = -newq
								prevq = cb.rotation
								--in coordsys parent cb.rotation = key
							)
						)
					)
				)
				
				-- setup bindposes between animations
				-- prevents funky interpolations between animations
				for i = 1 to seqs.count do
				(
					local seq = seqs[i]
					
					local aprev, anext
					aprev = seq.intStart - 1
					anext = seq.intEnd + 1
					
					poseFrames = #()
					if (aprev >= 0) then append poseFrames aprev
					append poseFrames anext
					
					for j = 1 to poseFrames.count do
					(
						MDX_Bones_Bindpose mdxBones seq.intStart poseFrames[j]
					)
				)			
			)
		)
	)
	fn skinning=
	(
		for i=1 to geos.count do
		(
			if geos[i].groups.count == 1 then
			(
				geos[i].mesh.parent = objs[geos[i].groups[1]].mesh
			)
			else
			(
				max modify mode
				select geos[i].mesh
				local gskin = skin()
				addModifier geos[i].mesh gskin
				local boneno = 0

				for k=1 to geos[i].groups.count do
				(
					local index = geos[i].groups[k]
					boneno += 1
					skinops.addBone gskin objs[index].mesh 0
					objs[index].no[i] = boneno
					local no = skinOps.getNumberCrossSections gskin boneno
					for l=1 to no do
					(
						skinOps.SetInnerRadius gskin boneno l 0
						skinOps.SetOuterRadius gskin boneno l 0
					)
				)
				completeRedraw()
				for j=1 to geos[i].pnts.no do
				(
					local index = geos[i].pnts.group[j]
					local n = geos[i].bones[index].count
					local bones_arr = #()
					local wghts_arr = #()
					for k=1 to n do
					(
						append bones_arr objs[geos[i].bones[index][k]].no[i]
						append wghts_arr ((1 as float)/n)
					)
					skinOps.SetVertexWeights gskin j bones_arr wghts_arr
				)
			)
		)
		
		-- scale down model by 1/100 if importing as M3
		--if (g_m3import == true) then at time 0 (g_m3boneRoot.scale *= 0.01)
	)

	fn fwriteString file string n=
	(
		arr = #(0x50,0x100,0x150)
		for i=1 to arr[n] do
		(
			if i <= string.count then writeByte file (bit.charAsInt string[i])
			else writeByte file 0
		)
	)

	fn fwriteHead file string=
	(
		for i=1 to 4 do
		(
			writeByte file (bit.charAsInt string[i])
		)
	)

	fn fileToPath file=
	(
		local array = filterString file "_"
		local string = array[1]
		for i=1 to array.count do
		(
			if i != 1 then
			(
				string += "\\" + array[i]
			)
		)
		string
	)


	--------------------
	-- User Interface --
	--------------------
	group "Import MDX"
	(
		radiobuttons geom "Animation:" labels:#("Static *","Object Visibility *", "No Skinning", "All") default:4 columns:1  align:#left
		checkbox rotateCheck "Bone Rotation" checked:true
		checkbox chkM3import "Import as M3" checked:g_m3import
		button importButton "Import MDX..."
		label asterisk1 "* Renderable objects only" align:#left
	)
	group "Export MDX"
	(
		button exportButton "Export Selected as MDX..."
	)
	group "About"
	(
		label test		"--Test Version--" align:#center
		label pr		"--for kdub & PR team--" align:#center
		label version	"MDX Importer/Exporter v2.0.4" align:#center
		label author	"Copyright \xa9 2002, Philip Laing" align:#center
		label updatedby "Updated by"
		label modauthor "NiNtoxicated \xa9 2010"
        label modauthor2 "Taylor Mouse \xa9 2018"
	)

	--------------------------
	-- Main Import Function --
	--------------------------

	on importButton pressed do
	(
		-- Show open file dialog box
		local objFileName = getOpenFileName caption:"Import MDX" types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|"

		impTypes = geom.state
		g_m3import = chkM3import.checked

		local isValid = true

		if objFileName != undefined then
		(
			-- If user made a selection, begin importing
			if doesFileExist objFileName then
			(
                --Framerate = g_useFPS
				seqs = #()
				mtls = #()
				geos = #()
				objs = #()
				pivot = #()
				geobones = #()
				-- currentPath = getFilenamePath objFileName

				-- Open up the file as a binary stream
				local bstream = fopen objFileName "rb"

				local mdx = File()
				mdx.Init bstream

				if mdx.fReadHead() == #MDLX then
				(
					--frameRate = 250
					mdx.pos += 12

					local curChunk = mdx.fReadHead()

					local bytes = 0;

					while (curChunk != undefined) and (mdx.pos < mdx.end) and (isValid) do
					(
						case curChunk of
						(
							#MODL:
							(
								--long	nbytes
								mdx.pos += 4

								--ASCII	Name (0x150 bytes)
								modelName = mdx.fReadString 3

								--long	???, ???
								mdx.pos += 8

								--float	MinExtx, MinExty, MinExtz;
								--float	MaxExtx, MaxExty, MaxExtz;
								--long	BlendTime;
								mdx.pos += 28
							)
							#SEQS:
							(
                                
								bytes = mdx.fReadLong()

								local nseqs = bytes/0x84

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
                                
								for i=1 to nseqs do
								(
									pseqs mdx i
								)
								
								-- Initiate Scene Object
								
								for i=1 to nseqs do
								(
                                    local startNote = AddNewNoteKey starAnimTrack ( seqs[i].intStart  * 30  / 1000.0  as integer )
                                    local endNote = AddNewNoteKey starAnimTrack ( seqs[i].intEnd * 30  / 1000.0  as integer )

                                    local val = seqs[i].name + "\r\n"
                                          val += "rarity = " 	 + (seqs[i].rarity as string)    + "\r\n"
                                          val += "moveSpeed = "  + (seqs[i].moveSpeed as string) + "\r\n"
                                          val += "nonLoop = " 	 + (seqs[i].noloop as string)    + "\r\n"
                                          val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = 0"

                                    startNote.Value = val
                                    endNote.Value = val

                                    format "Animation added: %  %-%\n" seqs[i].name seqs[i].intStart seqs[i].intEnd
								)
								
							)
							#GLBS:
							(
								bytes = mdx.fReadLong()

								local nglbs = bytes/4

								for i=1 to nglbs do
								(
									local duration = mdx.fReadLong()
								)
							)
							#MTLS:
							(
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								local i=1

								do
								(
									pmtls mdx i
									i+=1;
								) while mdx.pos < endpos
								
								global gmtls = mtls
							)
							#GEOS:
							(
								max views redraw
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								local i=1

								while mdx.pos < endpos do
								(
									pgeos mdx i
									mdx.pos -= 4
									i+=1;
								)
							)
							#GEOA:
							(
								max views redraw
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 1 then
								(
									local i=1

									while mdx.pos < endpos do
									(
										pgeoa mdx i
										i+=1;
									)
								)
								else
								(
									mdx.pos = endpos
								)
								max views redraw
							)
							#BONE:
							(
								max views redraw
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									while (mdx.pos < endpos) and isValid do
									(
										pbone mdx
									)
								)
								else
								(
									mdx.pos = endpos
								)
							)
							#LITE:
							(
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									while (mdx.pos < endpos) and isValid do
									(
										plite mdx
									)
								)
								else
								(
									mdx.pos = endpos
								)
							)
							#HELP:
							(
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									while (mdx.pos < endpos) and isValid do
									(
										phelp mdx
									)
								)
								else
								(
									mdx.pos = endpos
								)
							)
							#ATCH:
							(
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									while (mdx.pos < endpos) and isValid do
									(
										patch mdx
									)
								)
								else
								(
									mdx.pos = endpos
								)
							)
							#PIVT:
							(
								max views redraw
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									local i = 1;
									local x
									local y
									local z
									while mdx.pos < endpos do
									(
										x = mdx.fReadFloat()
										y = mdx.fReadFloat()
										z = mdx.fReadFloat()
										pivot[i] = [y,-x,z]
										i += 1
									)
									makeBones rotateCheck.state
									if impTypes > 3 then
									(
										skinning()
									)
								)
								else
								(
									mdx.pos = endpos
								)
							)
							#PRE2:
							(
								bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									while (mdx.pos < endpos) and isValid do
									(
										ppre2 mdx
										mdx.pos = endpos
									)
								)
								else
								(
									mdx.pos = endpos
								)
							)
                            #CLID:
                            (
                                bytes = mdx.fReadLong()

								local endpos = bytes + mdx.pos

								if impTypes > 2 then
								(
									while (mdx.pos < endpos) and isValid do
									(
										buildCollision bstream
										mdx.pos = endpos
									)
								)
								else
								(
									mdx.pos = endpos
								)
                            )
						)
						curChunk = mdx.fReadHead()
					)
				)
				else messagebox "not MDX File"

				if isValid == false then
					messagebox "Error meant bones did not load"

				fclose bstream

				max select all
				
				for i = 1 to 3 do
				(
					max zoomext sel all
				)
				
				max views redraw
				clearSelection()
			)
		)
	)

	on exportButton pressed do
	(
		if selection.count == 0  then
			messagebox "No objects selected" title:"Error"
		else
		(
			-- Show open file dialog box
			local objSaveFileName = getSaveFileName caption:"Import MDX" filename:(selection[1].name + ".mdx") types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|"

			-- If user made a selection, begin exporting
			if objSaveFileName != undefined then
			(
				seqs = #()
				mtls = #()
				geos = #()
				objs = #()
				pivot = #()
				geobones = #()
				local geoa = #()
				local geoInd = #()
				local gmatId = #()
				local mats = #()
				local maps = #()
				-- Open up the file as a binary stream
				local mdx = fopen objSaveFileName "wb"

				local ngeos = 0
				local ngeoa = 0
				local ngeoakeys = 0
				local nobjs = 0
				local mapOffset = 0
				local nblend = 0
				local bytes

				local error = ""		-- Notes & Errors in conversion

				if (numnotetracks trackviewNodes) > 0 then
				(
					local notes = getNoteTrack trackviewNodes 1
					for i=1 to (notes.keys.count/2) do
					(
						seqs[i] = Sequence()
						local value = filterString notes.keys[(i*2)-1].value "\n\r"
						seqs[i].name = value[1]
						seqs[i].moveSpeed =	if value[2] == undefined then 0
											else (value[2] as integer)
						seqs[i].noloop =	if value[3] == undefined then 0
											else (value[3] as integer)
						seqs[i].rarity =	if value[4] == undefined then 0
											else (value[4] as integer)
						local frame = (notes.keys[(i*2)-1].time as string)
						replace frame frame.count 1 ""
						seqs[i].intStart = frame as integer
						frame = (notes.keys[i*2].time as string)
						replace frame frame.count 1 ""
						seqs[i].intEnd = frame as integer
					)
				)
				else
				(
					error += "Sequences not found"
				)

				print "selection"

				for i=1 to selection.count do
				(
					case classOf selection[i] of
					(
						Omnilight:	--LITE
						(
						)
						targetSpot:	--CAMS
						(
						)
						Point:		--ATCH
						(
						)
						default:	--GEOS
						(
							ngeos += 1
							geoa[ngeos] = undefined
							local matId
							if ngeos > 1 then
							(
								for j=1 to mats.count do
								(
									if selection[i].material == selection[mats[j][1]].material then
									(
										matId = j-1
									)
								)
							)
							if matId == undefined then
							(
								local fmode = 0
								local shading = 0
								local mapId
								if selection[i].material != undefined then
								(
									if selection[i].material.opacityMap != undefined then
									(
										fmode = 1
									)
									else
									(
										if selection[i].material.diffuseMap != undefined then
										(
											if selection[i].material.diffuseMap.alphasource == 0 then
											(
												fmode = 2
												nblend += 1
											)
										)
									)
									if selection[i].material.twoSided == true then
									(
										shading += 16
									)
									if ngeos > 1 then
									(
										if selection[i].material.diffuseMap == undefined then
										(
											mapId = 0
											mapOffset = 1
										)
										else
										(
											for j=1 to maps.count do
											(
												if selection[i].material.diffuseMap.filename == maps[j] then
												(
													mapId = j
												)
											)
										)
									)
								)
								else
								(
									mapId = 0
									mapOffset = 1
								)
								if mapId == undefined then
								(
									mapId = maps.count + 1
									if selection[i].material.diffuseMap != undefined then
									(
										append maps selection[i].material.diffuseMap.filename
									)
								)
								matId = mats.count
								append mats #(ngeos,fmode,shading,mapId)
							)

							gmatId[ngeos] = matId

							if (selection[i][1].controller != undefined) and (selection[i][1].controller.keys.count > 1) then
							(
								local visKeys = #()
								local keyArr = selection[i][1].controller.keys
								for j=1 to keyArr.count do
								(
									if keyArr[j].value != 1 then
									(
										if geoa[ngeos] == undefined then
										(
											geoa[ngeos] = #()
											ngeoa += 1
										)
										for k=1 to seqs.count do
										(
											if (keyArr[j].time < seqs[k].intEnd) and
											(keyArr[j].time > seqs[k].intStart) then
											(
												if keyArr[j-1].time < seqs[k].intStart then
												(
													append geoa[ngeos] keyArr[j]
													geoa[ngeos][geoa[ngeos].count].time = seqs[k].intStart
													geoa[ngeos][geoa[ngeos].count].value = 1
												)
											)
										)
										append geoa[ngeos] keyArr[j]
										ngeoakeys += 1
									)
									else
									(
										local bool = true
										for k=1 to seqs.count do
										(
											if (keyArr[j].time == seqs[k].intStart) and
											((j == keyArr.count) or
											(keyArr[j+1].time > seqs[k].intEnd)) then
											(
												bool = false
											)
										)
										if keyArr[j].time == 0 then
										(
											bool = false
										)
										if bool == true then
										(
											if geoa[ngeos] == undefined then
											(
												geoa[ngeos] = #()
												ngeoa += 1
											)
											append geoa[ngeos] keyArr[j]
											ngeoakeys += 1
										)
									)
								)
							)
							geoInd[ngeos] = i
							geos[ngeos] = Geometry()
							geos[ngeos].pnts.no = selection[i].mesh.numverts
							geos[ngeos].pvtx.crns = 3*selection[i].mesh.numfaces
							geos[ngeos].minExt = #()
							geos[ngeos].maxExt = #()
							geos[ngeos].bRad = #()
							geos[ngeos].minExt[1] = selection[i].min
							geos[ngeos].maxExt[1] = selection[i].max
							geos[ngeos].bRad[1] = length selection[i].mesh.verts[1].pos
							for j=1 to selection[i].mesh.numverts do
							(
								if length selection[i].mesh.verts[j].pos > geos[ngeos].bRad[1] then
									geos[ngeos].bRad[1] = length selection[i].mesh.verts[j].pos
							)
							for j=1 to seqs.count do
							(
								geos[ngeos].minExt[j+1] = geos[ngeos].minExt[1]
								geos[ngeos].maxExt[j+1] = geos[ngeos].maxExt[1]
								geos[ngeos].bRad[j+1] = geos[ngeos].bRad[1]
								if 1 == 0 then --for k=seqs[j].intStart to seqs[j].intEnd do
								(
									geos[ngeos].bRad[j+1] = at time k length selection[i].mesh.verts[1].pos
									if at time k selection[i].min.x < geos[ngeos].minExt[j+1].x then
										geos[ngeos].minExt[j+1].x = at time k selection[i].min.x
									if at time k selection[i].min.y < geos[ngeos].minExt[j+1].y then
										geos[ngeos].minExt[j+1].y = at time k selection[i].min.y
									if at time k selection[i].min.z < geos[ngeos].minExt[j+1].z then
										geos[ngeos].minExt[j+1].z = at time k selection[i].min.z
									if at time k selection[i].max.x > geos[ngeos].maxExt[j+1].x then
										geos[ngeos].maxExt[j+1].x = at time k selection[i].max.x
									if at time k selection[i].max.y > geos[ngeos].maxExt[j+1].y then
										geos[ngeos].maxExt[j+1].y = at time k selection[i].max.y
									if at time k selection[i].max.z > geos[ngeos].maxExt[j+1].z then
										geos[ngeos].maxExt[j+1].z = at time k selection[i].max.z
									for l=2 to selection[i].mesh.numverts do
									(
										if at time k length selection[i].mesh.verts[l].pos > geos[ngeos].bRad[j+1] then
											geos[ngeos].bRad[j+1] = length selection[i].mesh.verts[l].pos
									)
								)
							)
						)
					)
				)

				for i=1 to seqs.count do
				(
					seqs[i].minExt = geos[1].minExt[i+1]
					seqs[i].maxExt = geos[1].maxExt[i+1]
					seqs[i].bRad = geos[1].bRad[i+1]
					for j=2 to geos.count do
					(
						if geos[j].minExt[i+1].x < seqs[i].minExt.x then
							seqs[i].minExt.x = geos[j].minExt[i+1].x
						if geos[j].minExt[i+1].y < seqs[i].minExt.y then
							seqs[i].minExt.y = geos[j].minExt[i+1].y
						if geos[j].minExt[i+1].z < seqs[i].minExt.z then
							seqs[i].minExt.z = geos[j].minExt[i+1].z
						if geos[j].maxExt[i+1].x > seqs[i].maxExt.x then
							seqs[i].maxExt.x = geos[j].maxExt[i+1].x
						if geos[j].maxExt[i+1].y > seqs[i].maxExt.y then
							seqs[i].maxExt.y = geos[j].maxExt[i+1].y
						if geos[j].maxExt[i+1].z > seqs[i].maxExt.z then
							seqs[i].maxExt.z = geos[j].maxExt[i+1].z
						if geos[j].bRad[i+1] > seqs[i].bRad then
							seqs[i].bRad = geos[j].bRad[i+1]
					)
				)

				-----------------
				-- MDX Writing --
				-----------------

				print "MDX Writing"

				-- MDLX: MDX Header
				fwriteHead mdx "MDLX"

				-- VERS: Version
				fwriteHead mdx "VERS"
				writeLong mdx 4								-- byte count
				writeLong mdx 800

				-- MODL: Model Info
				fwriteHead mdx "MODL"
				writeLong mdx 372							-- byte count
				--	Name
					local parse = filterString objSaveFileName "\/."
					name = parse[parse.count-1]
					fwriteString mdx name 3
				writeLong mdx 0								-- unknown (0)
				writeFloat mdx 0							-- Bounds Radius (0 for units)
				--	Minimum Extent
					writeFloat mdx (-selection.max.y)
					writeFloat mdx selection.min.x
					writeFloat mdx selection.min.z
				--	Maximum Extent
					writeFloat mdx (-selection.min.y)
					writeFloat mdx selection.max.x
					writeFloat mdx selection.max.z
				writeLong mdx 150							-- Blend Time (150)

				-- SEQS: Sequences
				fwriteHead mdx "SEQS"
				writeLong mdx (132*seqs.count)				-- byte count
				for i=1 to seqs.count do
				(
					fwriteString mdx seqs[i].name 1
					writeLong mdx seqs[i].intStart
					writeLong mdx seqs[i].intEnd
					writeFloat mdx seqs[i].moveSpeed
					writeLong mdx seqs[i].noloop
					writeFloat mdx seqs[i].rarity
					writeLong mdx 0							-- unknown (0)
					writeFloat mdx seqs[i].bRad				-- Bounds Radius
					--	Minimum Extent
						writeFloat mdx (-seqs[i].maxExt.y)
						writeFloat mdx seqs[i].minExt.x
						writeFloat mdx seqs[i].minExt.z
					--	Maximum Extent
						writeFloat mdx (-seqs[i].minExt.y)
						writeFloat mdx seqs[i].maxExt.x
						writeFloat mdx seqs[i].maxExt.z
				)

				-- GLBS: Globals
				-- 0x53424C47

				-- MTLS: Materials
				fwriteHead mdx "MTLS"
				writeLong mdx (48*mats.count + 28*nblend)	-- byte count
				for i=1 to mats.count do
				(
					if mats[i][2] > 1 then
					(
						writeLong mdx 76					-- byte count
						writeLong mdx 0
						writeLong mdx 0
						-- LAYS: Layers
						fwriteHead mdx "LAYS"
						writeLong mdx 2						-- Layers Count
						writeLong mdx 28					-- byte count (inclusive)
						-- FilterMode (0:none;1:trans;2:blend;3:add)
						writeLong mdx 0
						-- Shading (1:unshaded;+16:two sided;+32:unfogged)
						writeLong mdx 1
						writeLong mdx 0						-- TextureID
						writeLong mdx -1
						writeLong mdx 0
						writeFloat mdx 1
					)
					else
					(
						writeLong mdx 48					-- byte count
						writeLong mdx 0
						writeLong mdx 0
						-- LAYS: Layers
						fwriteHead mdx "LAYS"
						writeLong mdx 1						-- Layers Count
					)
					writeLong mdx 28						-- byte count (inclusive)
					-- FilterMode (0:none;1:trans;2:blend;3:add)
					writeLong mdx mats[i][2]
					-- Shading (1:unshaded;+16:two sided;+32:unfogged)
					writeLong mdx mats[i][3]
					writeLong mdx (mats[i][4]+mapOffset-1)	-- TextureID
					writeLong mdx -1
					writeLong mdx 0
					writeFloat mdx 1
					-- KMTA: Alpha
					-- 0x41544D4B
				)

				-- TEXS: Textures
				fwriteHead mdx "TEXS"
				writeLong mdx (268*(1+maps.count))-- byte count
					writeLong mdx 1
					fwriteString mdx "" 2
					writeLong mdx 0
					writeLong mdx 0
				if mapOffset == 10 then
				(
					writeLong mdx 0
					fwriteString mdx ("Textures\\"+name+".blp") 2
					writeLong mdx 0
					writeLong mdx 0
				)
				for i=1 to maps.count do
				(
					writeLong mdx 0
					local old_path = filterString maps[i] "\/."
					local blp_path = fileToPath old_path[old_path.count-1]
					fwriteString mdx (blp_path + ".blp") 2
					writeLong mdx 0
					writeLong mdx 0
				)

				max modify mode

				-- GEOS: Geometry Sets
				fwriteHead mdx "GEOS"
				local bytepos = ftell mdx
				local gbytes = #()
				bytes = 0
				for i=1 to geos.count do
				(
					gbytes[i] = 136+(33*geos[i].pnts.no)+(2*geos[i].pvtx.crns)+(28*seqs.count)
					bytes += gbytes[i]
				)
				writeLong mdx bytes							-- byte count
				for i=1 to geos.count do
				(
					local ibytepos = ftell mdx
					local texVerts = #()
					writeLong mdx gbytes[i]					-- byte count (inclusive)
					-- VRTX: Vertices
					fwriteHead mdx "VRTX"
					writeLong mdx geos[i].pnts.no
					for j=1 to geos[i].pnts.no do
					(
						local point = selection[geoInd[i]].mesh.verts[j].pos
						writeFloat mdx -point.y
						writeFloat mdx point.x
						writeFloat mdx point.z
					)
					-- NRMS: Normals
					fwriteHead mdx "NRMS"
					writeLong mdx geos[i].pnts.no
					for j=1 to geos[i].pnts.no do
					(
						local point = getNormal selection[geoInd[i]].mesh j
						writeFloat mdx -point.y
						writeFloat mdx point.x
						writeFloat mdx point.z
					)
					-- PTYP: Primitive Type
					fwriteHead mdx "PTYP"
					writeLong mdx 1							-- unknown (0)
					writeLong mdx 4							-- unknown (0)
					-- PCNT: Primitive Corners
					fwriteHead mdx "PCNT"
					writeLong mdx 1							-- unknown (0)
					writeLong mdx geos[i].pvtx.crns			-- No of Corners
					-- PVTX: Primitive Vertices
					fwriteHead mdx "PVTX"
					writeLong mdx geos[i].pvtx.crns			-- No of Corners
					for j=1 to (geos[i].pvtx.crns/3) do
					(
						local point = getFace selection[geoInd[i]].mesh j
						local texFace = getTVFace selection[geoInd[i]].mesh j
						texVerts[point.x] = texFace.x
						texVerts[point.y] = texFace.y
						texVerts[point.z] = texFace.z
						writeShort mdx (point.x-1)
						writeShort mdx (point.y-1)
						writeShort mdx (point.z-1)
					)
					-- GNDX: Vertex Groups
					fwriteHead mdx "GNDX"
					writeLong mdx geos[i].pnts.no
					local grouplist = #()
					local numgroups = 0
					local numbones = 0
					for j=1 to geos[i].pnts.no do
					(
						try
						(
							local nbones = skinOps.GetVertexWeightCount selection[geoInd[i]].skin j
							local ids = #()
							for k=1 to nbones do
							(
								if (skinOps.GetVertexWeight selection[geoInd[i]].skin j k) > (1/(2*nbones)) then
								(
									local boneid = skinOps.GetVertexWeightBoneID selection[geoInd[i]].skin j k
									local bonename = skinOps.GetBoneName selection[geoInd[i]].skin boneid 0
									if findItem geobones bonename == 0 do
									(
										append geobones bonename
									)
									append ids (findItem geobones bonename)
								)
							)
							sort ids
							local idstring = ""
							for id in ids do
							(
								idstring += (id as string) + ","
							)
							if findItem grouplist idstring == 0 do
							(
								append grouplist idstring
								numgroups += 1
								numbones += nbones
							)
							writeByte mdx (findItem grouplist idstring - 1) -- Group Byte
						)
						catch
						(
							numgroups = 1
							numbones = 1
							writeByte mdx 0 --geos[i].pnts.group[j]	-- Group Byte
							if (j == 1) then
							(
								if (selection[geoInd[i]].parent != undefined) then
								(
									if findItem geobones selection[geoInd[i]].parent.name == 0 then
									(
										append geobones selection[geoInd[i]].parent.name
									)
									append grouplist ((findItem geobones selection[geoInd[i]].parent.name) as string)
								)
								else
								(
									if findItem geobones "" == 0 do
									(
										append geobones ""
									)
									append grouplist ((findItem geobones "") as string)
								)
							)
						)
					)
					-- MTGC: Matrices Group Count
					fwriteHead mdx "MTGC"
					writeLong mdx numgroups					-- No of Matrices
					for matrix in grouplist do
					(
						local split = filterString matrix ","
						writeLong mdx split.count			-- No of Bones in Group
					)
					gbytes[i] += (numgroups * 4)
					bytes += (numgroups * 4)
					-- MATS: Matrices
					fwriteHead mdx "MATS"
					writeLong mdx numbones					-- No of Bones
					for matrix in grouplist do
					(
						local split = filterString matrix ","
						for part in split do
						(
							writeLong mdx ((part as integer)-1)	-- Bone No
						)
					)
					gbytes[i] += (numbones * 4)
					bytes += (numbones * 4)

					writeLong mdx gmatId[i]					-- MaterialID
					writeLong mdx 0
					writeLong mdx 0
					writeFloat mdx geos[i].bRad[1]			-- BoundsRadius
					--	Minimum Extent
						writeFloat mdx -geos[i].maxExt[1].y
						writeFloat mdx geos[i].minExt[1].x
						writeFloat mdx geos[i].minExt[1].z
					--	Maximum Extent
						writeFloat mdx -geos[i].minExt[1].y
						writeFloat mdx geos[i].maxExt[1].x
						writeFloat mdx geos[i].maxExt[1].z
					writeLong mdx seqs.count				-- Bone No
					for j=1 to seqs.count do
					(
						writeFloat mdx geos[i].bRad[j+1]	-- BoundsRadius
						--	Minimum Extent
							writeFloat mdx -geos[i].maxExt[j+1].y
							writeFloat mdx geos[i].minExt[j+1].x
							writeFloat mdx geos[i].minExt[j+1].z
						--	Maximum Extent
							writeFloat mdx -geos[i].minExt[j+1].y
							writeFloat mdx geos[i].maxExt[j+1].x
							writeFloat mdx geos[i].maxExt[j+1].z
					)
					-- UVAS: ???
					fwriteHead mdx "UVAS"
					writeLong mdx 1							-- unknown (0)
					-- UVBS: Texture Coordinates
					fwriteHead mdx "UVBS"
					writeLong mdx geos[i].pnts.no
					for j=1 to geos[i].pnts.no do
					(
						local point = getTVert selection[geoInd[i]].mesh texVerts[j]
						writeFloat mdx point.x
						writeFloat mdx (1 - point.y)
					)
					local cpos = ftell mdx
					fseek mdx ibytepos #seek_set
					writeLong mdx gbytes[i]
					fseek mdx cpos #seek_set
				)
				local cpos = ftell mdx
				fseek mdx bytepos #seek_set
				writeLong mdx bytes
				fseek mdx cpos #seek_set

				-- GEOA: Geometry Animation
				fwriteHead mdx "GEOA"
				writeLong mdx ((44*geos.count)+(8*ngeoakeys)+(8*(geos.count-ngeoa)))	-- byte count
				for i=1 to geos.count do
				(
					if geoa[i] != undefined then
					(
						writeLong mdx (44+(8*geoa[i].count))
						writeFloat mdx 1
						writeFloat mdx 0
						writeFloat mdx 1
						writeFloat mdx 1
						writeFloat mdx 1
						writeLong mdx (i-1)

						-- KGAO: Animated Opacity Track
						fwriteHead mdx "KGAO"
						writeLong mdx geoa[i].count
						writeLong mdx 0
						writeLong mdx -1
						for j=1 to geoa[i].count do
						(
							local frame = (geoa[i][j].time as string)
							replace frame frame.count 1 ""
							writeLong mdx (frame as integer)
							writeFloat mdx geoa[i][j].value
						)
					)
					else
					(
						writeLong mdx 52
						writeFloat mdx 1
						writeFloat mdx 0
						writeFloat mdx 1
						writeFloat mdx 1
						writeFloat mdx 1
						writeLong mdx (i-1)

						-- KGAO: Animated Opacity Track
						fwriteHead mdx "KGAO"
						writeLong mdx 1
						writeLong mdx 0
						writeLong mdx -1
						-- Single Key
						writeLong mdx 0
						writeFloat mdx 1
					)
				)

				-- BONE: Bones
				fwriteHead mdx "BONE"
				local xbytes = 0
				for bonename in geobones do
				(
					xbytes += 104
					if bonename != "" then
					(
						local cbone = getNodeByName bonename exact:true
						if cbone.pos.controller.keys.count != 0 then
						(
							xbytes += 16 + (16*cbone.pos.controller.keys.count)
						)
						if cbone.rotation.controller.keys.count != 0 then
						(
							xbytes += 16 + (20*cbone.rotation.controller.keys.count)
						)
						if cbone.scale.controller.keys.count != 0 then
						(
							xbytes += 16 + (16*cbone.scale.controller.keys.count)
						)
					)
				)
				writeLong mdx xbytes			-- byte count
				--	struct Bones
				local obID = 0
				for bonename in geobones do
				(
					local incbytes = 96
					if bonename == "" then
					(
						writeLong mdx incbytes			-- byte count (inclusive)
						fwriteString mdx "Default" 1	-- Name (0x50 bytes)
						writeLong mdx obID
						writeLong mdx -1
						writeLong mdx 256
					)
					else
					(
						local cbone = getNodeByName bonename exact:true
						if cbone.pos.controller.keys.count != 0 then
						(
							incbytes += 16 + (16*cbone.pos.controller.keys.count)
						)
						if cbone.rotation.controller.keys.count != 0 then
						(
							incbytes += 16 + (20*cbone.rotation.controller.keys.count)
						)
						if cbone.scale.controller.keys.count != 0 then
						(
							incbytes += 16 + (16*cbone.scale.controller.keys.count)
						)
						writeLong mdx incbytes				-- byte count (inclusive)
						fwriteString mdx cbone.name 1	-- Name (0x50 bytes)
						writeLong mdx obID
						writeLong mdx -1
						writeLong mdx 256
						-- KGTR: Translation Track
						if cbone.pos.controller.keys.count != 0 then
						(
							fwriteHead mdx "KGTR"
							writeLong mdx cbone.pos.controller.keys.count
							writeLong mdx 1
							writeLong mdx -1
							for key in cbone.pos.controller.keys do
							(
								local frame = (key.time as string)
								replace frame frame.count 1 ""
								writeLong mdx (frame as integer)
								writeFloat mdx (-key.value.y + cbone.pos.y)
								writeFloat mdx (key.value.x - cbone.pos.x)
								writeFloat mdx (key.value.z - cbone.pos.z)
							)
						)
						-- KGRT: Rotation Track
						if cbone.rotation.controller.keys.count != 0 then
						(
							fwriteHead mdx "KGRT"
							writeLong mdx cbone.rotation.controller.keys.count
							writeLong mdx 1
							writeLong mdx -1
							local prev = (quat 0 0 0 1)
							for key in cbone.rotation.controller.keys do
							(
								local frame = (key.time as string)
								replace frame frame.count 1 ""
								writeLong mdx (frame as integer)
								kquat = (key.value as quat) + prev
								writeFloat mdx -kquat.y
								writeFloat mdx kquat.x
								writeFloat mdx kquat.z
								writeFloat mdx kquat.w
								prev = kquat
							)
						)
						-- KGSC: Scale Track
						if cbone.scale.controller.keys.count != 0 then
						(
							fwriteHead mdx "KGSC"
							writeLong mdx cbone.scale.controller.keys.count
							writeLong mdx 1
							writeLong mdx -1
							for key in cbone.scale.controller.keys do
							(
								local frame = (key.time as string)
								replace frame frame.count 1 ""
								writeLong mdx (frame as integer)
								writeFloat mdx key.value.y
								writeFloat mdx key.value.x
								writeFloat mdx key.value.z
							)
						)
					)
					writeLong mdx -1
					writeLong mdx 0
					obID += 1
				)

				-- LITE: Lights
					-- KLAV: Visibility Track

				-- HELP: Helpers
					-- KGTR: Translation Track
					-- KGRT: Rotation Track
					-- KGSC: Scale Track

				-- ATCH: Attachments
					-- KATV: Visibility Track

				-- PIVT: Pivots
				fwriteHead mdx "PIVT"
				writeLong mdx (geobones.count*12)
				for bonename in geobones do
				(
					if bonename == "" then
					(
						writeFloat mdx 0	--writeFloat mdx pivot[i].x
						writeFloat mdx 0	--writeFloat mdx pivot[i].y
						writeFloat mdx 0	--writeFloat mdx pivot[i].z
					)
					else
					(
						local cbone = getNodeByName bonename exact:true
						writeFloat mdx -cbone.pos.y
						writeFloat mdx cbone.pos.x
						writeFloat mdx cbone.pos.z
					)
				)

				-- PRE2: Particle Emitters
					-- KGTR: Translation Track
					-- KGRT: Rotation Track
					-- KGSC: Scale Track
					-- KP2V: Visibility Track

				-- CAMS: Cameras

				-- EVTS: Events
					-- KEVT: Event Track

				-- CLID: Collision Shapes
					-- KGTR: Translation Track
					-- KGRT: Rotation Track
					-- KGSC: Scale Track

				messagebox "Model exported successfully!" title:"MDX Output" beep:false

				fclose mdx
			)
		)
	)
)

--getNodeByName <string> exact:<boolean>