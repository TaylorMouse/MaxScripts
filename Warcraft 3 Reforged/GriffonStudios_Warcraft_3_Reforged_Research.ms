
-- https://www.hiveworkshop.com/threads/mdx-specifications.240487/
struct Warcraft3_Reforged_TAG
    ( Name, Offset, Size )

struct Warcraft3_Reforged_MODL
    ( Name, PointA, PointB, Unk1 )

struct Warcraft3_Reforged_GEO
    ( VRTX, NRMS, PTYP, PCNT, PVTX, GNDX, MTGC, MATS, TANG, SKIN, UVS ) 

struct Warcraft3_Reforged_MATS
    ( ID, LOD, Name, Matrices )

struct Warcraft3_Reforged_BONE
    ( Id, Name, ParentBoneId, boneRef, KGTR, KGRT, KGSC, offset )

struct Warcraft3_Reforged_ATCH
    ( Id, Name, ParentBoneId, Offset, Size, KGTR, KGRT, KGSC, KATV)

struct Warcraft3_Reforged_SEQS
    ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity )
	
struct Warcraft3_Reforged_KG
	( Time, Point, inTan, outTan )

struct Warcraft3_Reforged_CLID
    ( Id, Name, Offset, Size, OffsetBounding, BoundingType, KGTR, KGRT, KGSC, Pos, Radius, Height )

struct Warcraft3_Reforged_TEXS
    ( Id, replacableId, fileNameOnly, path,  extension, flags )

struct Warcraft3_Reforged_MTLS
    ( Id, materialRef, ShaderName,  LAYS )

struct Warcraft3_Reforged_LAYS
    ( Id, filterMode, shadingFlags, TextureId, KMTA )

struct Warcraft3_Reforged_BPOS
    ( Id, Matrix )

/*

TAGS FOUND
    VERS // version
    MODL // model
    SEQS // animation sequences
    TEXS // texture names
    PIVT // pivots
    PRE2 // particle emitter
    EVTS // events
    BPOS // binding position
    CORN // conrners ??
    MTLS // materials
    GEOS // geosets
    GEOA // geoset animation
    BONE // bones
    ATCH // attachments
    CLID // colission 
    RIBB // ribbon emitters
    GLBS // globals
    TXAN // texture animations
    CAMS // camera
    LITE // lites
    FAFX // facial effects
    PREM // particle emitters
    
    // Node
    KGTR: float[3] translation
    KGRT: float[4] rotation
    KGSC: float[3] scaling
    // Layer
    KMTF: uint32 textureId
    KMTA: float alpha
    // Texture animation
    KTAT: float[3] translation
    KTAR: float[4] rotation
    KTAS: float[3] scaling
    //Geoset animation
    KGAO: float alpha
    KGAC: float[3] color
    // Light
    KLAS: uint32 attenuationStart
    KLAE: uint32 attenuationStartEnd
    KLAC: float[3] color
    KLAI: float intensity
    KLBI: float ambientIntensity
    KLBC: float[3] ambientColor
    KLAV: float visibility
    // Attachment
    KATV: float visibility
    // Particle emitter
    KPEE: float emissionRate
    KPEG: float gravity
    KPLN: float longitude
    KPLT: float latitude
    KPEL: float lifespan
    KPES: float speed
    KPEV: float visibility
    // Particle emitter 2
    KP2E: float emissionRate
    KP2G: float gravity
    KP2L: float latitude
    KP2S: float speed
    KP2V: float visibility
    KP2R: float variation
    KP2N: float length
    KP2W: float width
    // Ribbon emitter
    KRVS: float visibility
    KRHA: float heightAbove
    KRHB: float heightBelow
    KRAL: float alpha
    KRCO: float[3] color
    KRTX: uint32 textureSlot
    // Camera
    KCTR: float[3] translation
    KCRL: uint32 rotation
    KTTR: float[3] targetTranslation


*/
global Warcraft3_AssetFolder = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\"

struct Warcraft3_Reforged
(
    /* 
        Helper functions 
    */
    function CreateLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),
    function GetStreamLength stream =
    (
        local currentPos = ftell stream
        fseek stream 0 #seek_end
        local streamLen = ftell stream
        
        fseek stream currentPos #seek_set
        
        return streamLen
    ),
    function ReadFixedString stream val =
    (
        /* Read n-length string */
        local str = ""

        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if ( s !="\0") then str+=s
        )
        return str

    ),
    function SkipBytes stream nBytesToSkip=
    (
        /* Skip n-bytes without reading them into memory */
        fseek stream nBytesToSkip #seek_cur
    ),
    function ReadTAGS stream streamLen=
    (
        local tags = #() 
        local mainTag = Warcraft3_Reforged_TAG()

        mainTag.Name = Warcraft3_Reforged.ReadFixedString stream 4
        mainTag.Offset = 0
        mainTag.Size = 0
        
        local currentStreamPos = ftell stream

        while (currentStreamPos < streamLen ) do
        (
            local tag = Warcraft3_Reforged_TAG()
            
            tag.Offset = ftell stream + 8 -- the +8 indicates where the data starts
            tag.Name = Warcraft3_Reforged.ReadFixedString stream 4
            tag.Size = ReadLong stream
            
            Warcraft3_Reforged.SkipBytes stream tag.Size

            currentStreamPos = ftell stream
            
            append tags tag
        )
        return tags
    ),
    /* Warcraft 3 Reforged 
    
        READ
    */
    function ReadFloatAnim stream=
    (
        -- Key Attachment visibility
        /* presumably the visibility of the object, the lineType will indicate the trasition tangent */
        local anim = #()
        
        local numPts = readLong stream
        local lineType = readLong stream
        local ffff = readLong stream
        
        for i=1 to numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = ReadLong stream
            k.Point = readFloat stream -- always 1, indicating it starts or ends

            if( lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append anim k
        )
        
        return anim
    ),
    function ReadVector3Anim stream=
    (
        local anim = #()
        
        local numPts = readLong stream
        local lineType = readLong stream
        local ffff = readLong stream
        
        for i=1 to numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = ReadLong stream
            k.Point = [readFloat stream, readFloat stream, readFloat stream]

            if( lineType > 1)  then
            (
                k.inTan = [readFloat stream, readFloat stream, readFloat stream]
                k.outTan = [readFloat stream, readFloat stream, readFloat stream]
            )
            append anim k
        )
        
        return anim
    ),
    function ReadQuatAnim stream=
    (
        local anim = #()
        
        local numPts = readLong stream
        local lineType = readLong stream
        local ffff = readLong stream
        
        for i=1 to numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = ReadLong stream
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 

            if( lineType > 1)  then
            (
                k.inTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
                k.outTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            )
            append anim k
        )
        
        return anim
    ),
    function ReadMODL stream tag=
    (
        local modl = Warcraft3_Reforged_MODL()
        fseek stream tag.offset #seek_set
        
        modl.name = Warcraft3_Reforged.ReadFixedString stream 80
        Warcraft3_Reforged.SkipBytes stream (tag.size - 80 - 28)
        
        
        modl.PointA = [readFloat stream, readFloat stream, readFloat stream]
        modl.PointB = [readFloat stream, readFloat stream, readFloat stream]
        modl.Unk1 = readLong stream
        
        return modl
        
    ),
    function ReadVERS stream tag=
    (
        fseek stream tag.Offset #seek_set
        local version = readLong stream
        return version
        
    ),
    function ReadTEXS stream tag=
    (
        fseek stream tag.offset #seek_set
        local texs = #()
        
        local numTexs = tag.Size / 268
        
        for i=1 to numTexs do
        (
            local t = Warcraft3_Reforged_TEXS()
            t.Id = i
            
            t.replacableId = readLong stream -- 0 or 1 for now ??
            local name = Warcraft3_Reforged.ReadFixedString stream 260
            t.path = getFilenamePath name
            t.fileNameOnly = getFilenameFile name
            t.extension = getFilenameType name 
            t.flags = readLong stream
            
            
            
            append texs t
        )
        return texs
        
    ),
    function ReadGEOS stream tag=
    (
        fseek stream tag.Offset #seek_set
        
        local currentRelativePosition = 0
        local geos = #()
        
        while ( tag.Size > currentRelativePosition ) do
        (
            local size = readLong stream
            currentRelativePosition = currentRelativePosition + size 
            if(currentRelativePosition > tag.Size ) then exit
            
            local geo = Warcraft3_Reforged_GEO()   
            
            /* Vertices */
            local verts = #()
            local vrtx = Warcraft3_Reforged.ReadFixedString stream 4
            local nVerts = readLong stream
            for v=1 to nVerts do 
            (
                local vert = [readFloat stream, readFloat stream, readFloat stream]
                append verts vert
            )
            geo.VRTX = verts
            
            /* Normals */
            local norms = #()
            local nrms = Warcraft3_Reforged.ReadFixedString stream 4
            local nNorms = readLong stream
            for n=1 to nNorms do 
            (
                local nrm = [readFloat stream, readFloat stream, readFloat stream]
                append norms nrm
            )
            geo.NRMS = norms
            
            /* Types */
            local types = #()
            local ptyp = Warcraft3_Reforged.ReadFixedString stream 4
            local nPtyp = readLong stream
            for p=1 to nPtyp do 
            (
                /*
                0: points
                1: lines
                2: line loop
                3: line strip
                4: triangles
                5: triangle strip
                6: triangle fan
                7: quads
                8: quad strip
                9: polygons
               */ 
                local pt = readLong stream
                append types pt
            )
            geo.PTYP = types

            /* Corners */
            local corners = #()
            local pcnt = Warcraft3_Reforged.ReadFixedString stream 4
            local nPcnt = readLong stream
            for p=1 to nPcnt do 
            (
                local cn = readLong stream
                append corners cn
            )
            geo.PCNT = corners
            
            /* Indices */  
            local indices = #()
            local pvtx = Warcraft3_Reforged.ReadFixedString stream 4
            local nPvtx = readLong stream
            for i=1 to nPvtx/3 do
            (
                local idx = [readShort stream +1, readShort stream +1, readShort stream +1]
                append indices idx
            )
            geo.PVTX = indices
            
            /* Groups */
            local gndx = Warcraft3_Reforged.ReadFixedString stream 4
            local nGndx = readLong stream
            geo.GNDX = 0 --> currently always zero occurences so to prevent errors, skip the bytes for now
            Warcraft3_Reforged.SkipBytes stream (nGndx)
            
            /* Matrix Groups or bone groups */
            local matrixGroups = #()
            local mtgc = Warcraft3_Reforged.ReadFixedString stream 4
            local nMtgc = readLong stream
            for m=1 to nMtgc do
            (
                append matrixGroups (readLong stream)
            )
            geo.MTGC = matrixGroups

            /* Matrices */
            local gMats = Warcraft3_Reforged_MATS()
            local matrices = #()
            local mats = Warcraft3_Reforged.ReadFixedString stream 4
            local nMats = readLong stream
            for m=1 to nMats do
            (
                append matrices (readLong stream )
            )
            gMats.Matrices = matrices
            gMats.ID = readLong stream + 1 --> reference to the MAT ID in MTLS
            
            Warcraft3_Reforged.SkipBytes stream 8
            gMats.LOD = readLong stream
            gMats.Name = Warcraft3_Reforged.ReadFixedString stream 112
            geo.MATS = gMats
            
            -- print gMats
            
            /* Tangents */
            local tangents = #()
            local tang = Warcraft3_Reforged.ReadFixedString stream 4
            local nTang = readLong stream
            
            for t=1 to nTang do
            (
                append tangents [readFloat stream, readFloat stream, readFloat stream, readFloat stream]
            )
            geo.TANG = tangents
            
            /* SKIN */
            local skins = #()
            local skn = Warcraft3_Reforged.ReadFixedString stream 4
            local nSkn = readLong stream
            for s=1 to nSkn do
            (
                append skins (readByte stream #unsigned)
            )
            geo.SKIN = skins
            
            
            /* Nbr of UV Maps */
            local uvas = Warcraft3_Reforged.ReadFixedString stream 4
            local nUvas = readLong stream --> nbr of uv coordinates

            /* UV Coordinates */
            geo.UVS = #()
            for i=1 to nUvas do
            (
                local uvs = #()
                local uvbs = Warcraft3_Reforged.ReadFixedString stream 4
                local nUvbs = readLong stream

                for u=1 to nUvbs do
                (
                    append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )
                )
                append geo.UVS uvs
            )
            
            append geos geo
        )
        
    ),
    function ReadBONE stream tag=
    (
        fseek stream tag.offset #seek_set
                
        local boneList = #()

        /* read the bone chunks*/
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local b = Warcraft3_Reforged_BONE()
            
            local size = readLong stream
        
            b.Name = Warcraft3_Reforged.ReadFixedString stream 80
            b.Id = readLong stream + 1
            b.ParentBoneId = readLong stream + 1
            
            Warcraft3_Reforged.SkipBytes stream 4
            b.offset = ftell stream
            
            Warcraft3_Reforged.SkipBytes stream ( size - 80 - 12 )
            
            local ffff =  readlong stream

            append boneList b
        )
        /* read the animation frames */
        for b in boneList do
        (
            fseek stream b.offset #seek_set

            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = Warcraft3_Reforged.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = Warcraft3_Reforged.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Scale
            )
            
            b.KGTR = kgtr
            b.KGRT = kgrt
            b.KGSC = kgsc
            
        )
        
        return boneList
    ),
    function ReadMTLS stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local mtls = #()
        
        local mtlsId = 1
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local mtl = Warcraft3_Reforged_MTLS()
            mtl.Id = mtlsId
            local size = readLong stream -- size is usually 620 bytes
            local unk1 = readLong stream
            local unk2 = readLong stream
            mtl.shaderName = Warcraft3_Reforged.ReadFixedString stream 80
            local lays = Warcraft3_Reforged.ReadFixedString stream 4
            local nLays = readLong stream
            
            local laysList = #()
            
            for l=1 to nLays do
            (
                local lay = Warcraft3_Reforged_LAYS()
                lay.Id = l
                local bytes     = readLong stream
                lay.filterMode  = readLong stream
                /* filterMode
                  0: none
                 1: transparent
                 2: blend
                 3: additive
                 4: add alpha
                 5: modulate
                 6: modulate 2x
                */
                
                lay.shadingFlags   = readLong stream
                /* ShadingFlag
                 0x1: unshaded
                 0x2: sphere environment map
                 0x4: ?
                 0x8: ?
                 0x10: two sided
                 0x20: unfogged
                 0x30: no depth test
                 0x40: no depth set               
                */
                
                lay.textureId   = readLong stream + 1
                local ffff      = readLong stream
                
                local textureAnimationId = readLong stream
                local coordId = readFloat stream
                local alpha = readFloat stream
                
                local kmta
                if(bytes>32) then 
                (
                    local km = Warcraft3_Reforged.ReadFixedString stream 4
                    if ( km == "KMTA" ) then kmta = Warcraft3_Reforged.ReadFloatAnim stream 
                )
                lay.KMTA = kmta
                append laysList lay
            )
            mtl.LAYS = laysList
            
            mtlsId +=1
            
            append mtls mtl
        )
        
        return mtls
        
    ),
    function ReadATCH stream tag=
    (
        fseek stream tag.Offset #seek_set
        
        local atchs = #()

        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local att = Warcraft3_Reforged_ATCH()
            
            local size = readLong stream
            local unk1 = readLong stream
            
            att.name = Warcraft3_Reforged.ReadFixedString stream 80
            att.Id = readLong stream + 1
            att.ParentBoneId = readLong stream + 1
            
            local unk1 = readLong stream
            
            att.Offset = ftell stream
            att.Size = size - 4 - 4 - 80 - 8 - 4
            
            Warcraft3_Reforged.SkipBytes stream att.Size
        
            append atchs att
        )
        
        for att in atchs do
        (
            fseek stream att.offset #seek_set
            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = Warcraft3_Reforged.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = Warcraft3_Reforged.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Scale
            )
            
            att.KGTR = kgtr
            att.KGRT = kgrt
            att.KGSC = kgsc
            local correction = 0
            if ( kgtr == undefined ) then correction = correction + 4
            if ( kgrt == undefined ) then correction = correction + 4
            if ( kgsc == undefined ) then correction = correction + 4
           
            Warcraft3_Reforged.SkipBytes stream ( 264 - correction)

            local katv = Warcraft3_Reforged.ReadFixedString stream 4
            
            if( katv == "KATV") then att.katv = Warcraft3_Reforged.ReadFloatAnim stream -- visibility track ?

        )
        
        return atchs
        
    ),
    function ReadSEQS stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local nbrSeqs = tag.size / 132
        
        local seqs = #()
        
        for i=1 to nbrSeqs do
        (
            local seq = Warcraft3_Reforged_SEQS()
            seq.Name = Warcraft3_Reforged.ReadFixedString stream 80
            seq.StartFrame = readLong stream
            seq.EndFrame = readLong stream
            seq.MovementSpeed = readFloat stream
            seq.NoLoop = readLong stream
            seq.Rarity = readFloat stream
            Warcraft3_Reforged.SkipBytes stream (8*4)

            append seqs seq
        )
        
        return seqs
        
    ),
    function ReadCLID stream tag=
    (
        fseek stream tag.offset #seek_set
                
        local clid = #()
        local i=1 -- failsafe
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local cl = Warcraft3_Reforged_CLID()
            
            local size = readLong stream
            cl.name = Warcraft3_Reforged.ReadFixedString stream 80
            cl.Id = readLong stream + 1
            
            local ffff = readLong stream
            local unk1 = readLong stream
            
            cl.Offset = ftell stream
            cl.Size = size - 80 - 16
            
            Warcraft3_Reforged.SkipBytes stream cl.Size
            cl.OffsetBounding = ftell stream
            Warcraft3_Reforged.SkipBytes stream 28
            
            append clid cl
            
            if (i==50) then exit
            i +=1
        )
        
        for cl in clid do
        (
            fseek stream cl.offset #seek_set
            
            for i=1 to 3 do
            (
                local kg = Warcraft3_Reforged.ReadFixedString stream 4
                
                if ( kg == "KGTR" ) then cl.KGTR = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then cl.KGRT = Warcraft3_Reforged.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then cl.KGSC = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Scale

                )

            fseek stream cl.OffsetBounding #seek_set
            
            cl.BoundingType = readLong stream
            cl.pos = [readFloat stream, readFloat stream, readFloat stream]
            cl.radius = readFloat stream
            cl.height = readFloat stream
            local zero = readFloat stream
            
        )
        return clid
        
    ),
    function ReadBPOS stream tag=
    (
        local bpos = #()
        fseek stream tag.Offset #seek_set
        
        local nbrBpos = readLong stream
        
        for i=1 to nbrBpos do
        (
            local b = Warcraft3_Reforged_BPOS()
            
            b.Id = i
            
            local row1 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
            local row2 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
            local row3 = [ReadFloat stream, ReadFloat stream, ReadFloat stream]
            local row4 = [ReadFloat stream, ReadFloat stream, ReadFloat stream] 
         
            b.Matrix = matrix3 row1 row2 row3 row4
            
            -- local s = sphere radius:0.8
            -- s.transform = b.matrix
            
            append bpos b
        )
        return bpos
    ),
    /*
        BUILD
    */
    function BuildGEOS geos modl mtls=
    (
        for geo in geos do
        (
            local layerName = modl.name + " - LOD " + (geo.MATS.LOD as string)
            local layer = Warcraft3_Reforged.CreateLayer layerName
            
            if (geo.MATS.LOD != 0 ) then layer.isHidden = true
            
            local mat = mtls[geo.MATS.ID].MaterialRef
            
            try (
                
                local v = geo.VRTX
                local n = geo.NRMS
                local f = geo.PVTX
                local uv = geo.UVS[1]
                local meshName = geo.MATS.Name
                
                local theMesh = mesh vertices:v vnorms:n name:meshName faces:f tverts:uv 

                theMesh.WireColor = Color (random 0 128) (random 0 255) (random 0 128)

                theMesh.Material = mat
                
                buildTVFaces theMesh false
                for i = 1 to f.count do
                ( setTVFace theMesh i f[i] )
            
                layer.AddNode theMesh
                
                update theMesh
                
            )
            catch (
                print "ERROR occured in"
                print geo
                )

        )
    ),
    function BuildMTLS mtls texs modlName=
    (
        /*
            TODO: map this to SC2 or Warcraft 3 Materials.
        */
        for mtl in mtls do
        (

            local mat = standardMaterial()
            mat.Name = modlName + "_MAT_" + (mtl.id as string )
            if ( mtl.ShaderName == "Shader_HD_DefaultUnit" ) then mat.shaderType = 0
            
            for layer in mtl.lays do
            (
                local textureId = layer.TextureId
                local parts = filterString texs[textureId].path @"\"
                local textureFile = Warcraft3_AssetFolder + texs[textureId]. path + texs[textureId].fileNameOnly + ".dds"

                case of 
                (
                    (layer.id == 1): ( -- Diffuse or Albedo
                        mat.diffuseMap = Bitmaptexture fileName:textureFile
                        mat.opacityMap = Bitmaptexture fileName:textureFile
                        mat.opacityMapEnable = on
                        mat.opacityMap.monooutput = 1
                    )
                    (layer.id == 2): ( -- Bump Map or Normal map
                        mat.bumpMap = Bitmaptexture fileName:textureFile
                        mat.bumpMapEnable = on
                        mat.bumpMapAmount = 80
                    )
                    (layer.id == 3): ( -- ORM...Red = Occlusion, Green = Roughness, Blue = metalness
                        mat.specularLevelMap = Bitmaptexture fileName:textureFile
                        mat.Specular = color 128 128 128
                    )
                    (layer.id == 4): ( -- black ?? maybe emission ?
                        mat.selfIllumMap = Bitmaptexture fileName:textureFile
                        
                    )
                    (layer.id == 5): ( -- TeamColor
                        mat.glossinessMap = Bitmaptexture fileName:textureFile
                        
                    )
                    (layer.id == 6): ( -- refelection
                        mat.reflectionMap = Bitmaptexture fileName:textureFile
                        mat.reflectionMapEnable = on
                    )
                )
                
                
                showTextureMap mat mat.diffuseMap true
                
                /* animated texture */
                if ( layer.KMTA != undefined ) then
                (
                    for anim in layer.KMTA do
                    (
                        with animate on (
                            at time anim.Time (
                                mat.opacity = anim.Point * 100.0
                            )
                        )
                    )
                )
                
               
            )
            meditMaterials[mtl.id] = mat
            
            mtl.materialRef = mat
        )
        --return mtls
    ),
    function BuildATCH atch bpos boneList=
    (
        local layer = Warcraft3_Reforged.CreateLayer "Attachments"
     
        sliderTime = 0f
        
        for a in atch do 
        (
            local pnt = Point name:a.name box:off cross:on centermarker:off axistripod:off size:12
            pnt.wirecolor = color 255 255 0
            pnt.Transform = bpos[a.id].matrix 
            
            layer.AddNode pnt
            if( a.parentBoneId>0) then 
            (
                pnt.parent = boneList[a.parentBoneId].boneRef
            )
            -- KGTR, KGRT, KGSC, KATV
                    
            if ( a.KGRT != undefined ) then
                for anim in a.KGRT do
                    with animate on at time anim.Time 
                    (
                        local euler = quatToEuler anim.point
                        rotate pnt euler
                    )
                    
            if ( a.KGTR != undefined ) then
                for anim in a.KGTR do
                    with animate on at time anim.Time 
                        pnt.pos = anim.Point 
               
            if ( a.KGSC != undefined ) then
                for anim in a.KGTR do
                    with animate on at time anim.Time 
                        pnt.scale = anim.Point 
                    
            if ( a.KATV != undefined ) then 
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in a.KATV do
                (
                    if ( anim.point == 0) then isVisibilityTrackRequired = true
                )
                
                if ( isVisibilityTrackRequired == true ) then
                (
                    pnt.Visibility = undefined 
                    pnt.Visibility = on
                    pnt.Visibility.controller = on_off()

                    for anim in a.KATV do 
                        with animate on at time anim.Time 
                            if (anim.point == 1) then 
                                pnt.Visibility = on
                            else
                                pnt.Visibility = off
                )
                
            )
        )
        
        
    ),
    function BuildBONE boneList bpos=
    (
--         print boneList
--         print bpos
        
        local layer = Warcraft3_Reforged.CreateLayer "Bones"
        
        -- create the bones
        for b in boneList do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
            
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.05
			aBone.Height = 0.05
            
            b.boneRef = aBone
            layer.AddNode aBone
            aBone.transform = bpos[b.id].matrix
            
        )
        
        -- build bone hierarchy
        for b in boneList do
        (
            if ( b.ParentBoneId > 0 ) then 
            (
                local parentBone = boneList[b.ParentBoneId].boneRef
                b.boneRef.parent = parentBone
            )
        )
        
        -- apply bone animation
         for b in boneList do
         (
            local pnt = b.boneRef
             
            

--             if ( b.KGRT != undefined ) then
--             (
--                 local pnt = b.boneRef
--                 for anim in b.KGRT do
--                 (
--                     local q = anim.point
--                     
--                     with animate on
--                     (
--                         at time (anim.Time + 10) in coordsys parent 

--                              pnt.assumeskinpose()
--                             local mtrx = matrix3 1
--                             rotate mtrx (inverse q)
--                             
--                             local rKey = numKeys pnt.rotation.controller
--                             if rKey>0 then deleteKey  pnt.rotation.controller rKey
--                             
--                             if ( pnt.parent != undefined) then
--                             (
--                                     mtrx = mtrx *  pnt.parent.transform --> check if this is necessary!!
--                             )
--                              pnt.transform = mtrx
--                             local pKey = numKeys  pnt.position.controller
--                             local sKey = numKeys  pnt.scale.controller
--                             if pKey>0 then deleteKey  pnt.position.controller pkey
--                             if skey>0 then deleteKey  pnt.scale.controller skey


--                     )
--                 )    
--             )
            if ( b.KGTR != undefined ) then
            (
               for anim in b.KGTR do
               (
                    with animate on 
                       at time (anim.Time + 10)
                            in coordsys parent 
                                pnt.pos = anim.Point 
                )
            )
        
  
--             if ( b.KGSC != undefined ) then
--                 for anim in b.KGTR do
--                     with animate on at time anim.Time 
--                         pnt.scale = anim.Point 
        )
    ),
    function Import file=
    (
        if ( file == undefined ) then throw("Provide a correct value for the paramete file")
        if ( doesFileExist file == false ) then throw("File does not exist!")
        
        local stream = fOpen file "rb"
        local streamLen = Warcraft3_Reforged.GetStreamLength stream
        local tags = Warcraft3_Reforged.ReadTags stream streamLen
        
        local vers -- version
        local modl -- model specs
        local seqs -- animation sequences
        local texs -- texture files
        local mtls -- materials
        local geos -- geometry
        local boneList -- bones
        local atch -- attachments
        local clid -- collision spheres
        local bpos -- binding position
        
        -- VERS // version
        for tag in tags do 
            if( tag.Name == "VERS" ) then 
            (
                local version = Warcraft3_Reforged.ReadVERS stream tag
                if ( version != 900 ) then 
                (
                    throw( "Incorrect version, found " + (version as string) + ", should be 900")
                )
            )
        print tags
            
        -- read tag by tag
        for tag in tags do
        (
            -- MODL // model
            if( tag.Name == "MODL" ) then modl = Warcraft3_Reforged.ReadMODL stream tag
            -- SEQS // animation sequences
            if( tag.Name == "SEQS" ) then seqs = Warcraft3_Reforged.ReadSEQS stream tag
            -- MTLS // materials
            if( tag.Name == "MTLS" ) then mtls = Warcraft3_Reforged.ReadMTLS stream tag
            -- TEXS // texture names
            if( tag.Name == "TEXS" ) then texs = Warcraft3_Reforged.ReadTEXS stream tag
            -- GEOS // geosets
            if( tag.Name == "GEOS" ) then geos = Warcraft3_Reforged.ReadGEOS stream tag
            -- BONE // bones
            if( tag.Name == "BONE" ) then boneList = Warcraft3_Reforged.ReadBONE stream tag
            -- ATCH // attachments
            if( tag.Name == "ATCH" ) then atch = Warcraft3_Reforged.ReadATCH stream tag 
            -- CLID // colission 
            if( tag.Name == "CLID" ) then clid = Warcraft3_Reforged.ReadCLID stream tag
            -- BPOS // binding position
            if( tag.Name == "BPOS" ) then bpos = Warcraft3_Reforged.ReadBPOS stream tag
            -- PIVT // pivots
            -- PRE2 // particle emitter
            -- EVTS // events
            -- CORN // conrners ??
            -- GEOA // geoset animation
            -- RIBB // ribbon emitters
            -- GLBS // globals
            -- TXAN // texture animations
            -- CAMS // camera
            -- LITE // lites
            -- FAFX // facial effects
            -- PREM // particle emitters    
            
        )

        Warcraft3_Reforged.BuildBONE boneList bpos
        Warcraft3_Reforged.BuildMTLS mtls texs modl.name
        Warcraft3_Reforged.BuildGEOS geos modl mtls
        Warcraft3_Reforged.BuildATCH atch bpos boneList
     
--      print modl
--      print seqs
--      print mtls
--      print texs        
--      print geos
--      print boneList
--      print atch
--      print clid
--      print bpos
        

        
        fclose stream

    )
)

ClearListener()

-- file = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\doodads\ashenvale\plants\ashenbush0\ashenbush0.mdx"
--file = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\units\orc\battroll\battroll.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\units\demon\chaosgrunt\chaosgrunt.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\units\creeps\wendigo\wendigo.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\units\human\herohalahk\herohalahk.mdx"

file = getOpenFileName \
			caption:"Heroes of the Storm" \
			types:"Supported Files|*.mdx|Warcraft 3 Reforged(*.mdx)|*.mdx|All Files|*.*" \
			historyCategory:"ReforgedPreset"


Warcraft3_Reforged.Import file