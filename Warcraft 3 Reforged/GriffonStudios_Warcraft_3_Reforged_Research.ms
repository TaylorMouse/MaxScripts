
-- https://www.hiveworkshop.com/threads/mdx-specifications.240487/
struct Warcraft3_Reforged_TAG
    ( Name, Offset, Size )

struct Warcraft3_Reforged_MODL
    ( Name, PointA, PointB, Unk1 )

struct Warcraft3_Reforged_GEO
    ( VRTX, NRMS, PTYP, PCNT, PVTX, GNDX, MTGC, MATS, TANG, SKIN, UVS, meshRef ) 

struct Warcraft3_Reforged_MATS
    ( ID, LOD, Name, Matrices )

struct Warcraft3_Reforged_BONE
    ( Id, Name, ParentBoneId, boneRef, KGTR, KGRT, KGSC, offset )

struct Warcraft3_Reforged_ATCH
    ( Id, Name, ParentBoneId, Offset, Size, KGTR, KGRT, KGSC, KATV)

struct Warcraft3_Reforged_SEQS
    ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity )
	
struct Warcraft3_Reforged_KG
	( Time, Point, inTan, outTan, LineType )

struct Warcraft3_Reforged_CLID
    ( Id, Name, Offset, Size, OffsetBounding, BoundingType, KGTR, KGRT, KGSC, Pos, Radius, Height )

struct Warcraft3_Reforged_TEXS
    ( Id, replacableId, fileNameOnly, path,  extension, flags )

struct Warcraft3_Reforged_MTLS
    ( Id, materialRef, ShaderName,  LAYS )

struct Warcraft3_Reforged_LAYS
    ( Id, filterMode, shadingFlags, TextureId, KMTA, KMTE )

struct Warcraft3_Reforged_BPOS
    ( Id, Matrix )

struct Warcraft3_Reforged_Weights
    ( VertexId, BoneIds, Weights )

struct Warcraft3_Reforged_GEOA
    ( Id, GeoId, KGAO )

/* TAGS
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
    GLBS // global sequences
    TXAN // texture animations
    CAMS // camera
    LITE // lites
    FAFX // facial effects
    PREM // particle emitters
*/
/* Animation Tags
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

global Warcraft3_AssetFolder = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\"

struct Warcraft3_Reforged
(
    /* Helper functions 
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
            
            k.Time = (ReadLong stream * 30 / 1000.0 ) as integer
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
            
            k.Time = ReadLong stream  * 30 / 1000.0 as integer
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
            
            k.Time = ReadLong stream  * 30 / 1000.0 as integer
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = lineType
            if( lineType > 1)  then
            (
                format "Linetype: %" lineType
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
            local groups = #()
            for g=1 to nGndx do append groups ( readByte stream + 1 )
            geo.GNDX = groups
            
            /* Matrix Groups or bone groups */
            local matrixGroups = #()
            local mtgc = Warcraft3_Reforged.ReadFixedString stream 4
            local nMtgc = readLong stream
            for m=1 to nMtgc do append matrixGroups (readLong stream)
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
            
            for s=1 to nSkn / 8 do
            (
                local w = Warcraft3_Reforged_Weights()
                w.VertexId = s
                w.BoneIds = #()
                w.Weights = #()
                local b1 = (readByte stream #unsigned + 1)
                local b2 = (readByte stream #unsigned + 1)
                local b3 = (readByte stream #unsigned + 1)
                local b4 = (readByte stream #unsigned + 1)

                local w1 = ((readByte stream #unsigned) / 255.0)
                local w2 = ((readByte stream #unsigned) / 255.0)
                local w3 = ((readByte stream #unsigned) / 255.0)
                local w4 = ((readByte stream #unsigned) / 255.0)



                    append w.BoneIds b1
                    
                    append w.Weights w1
                    
                    
                    if (w2 > 0.0 ) then 
                    (
                        append w.BoneIds b2
                        append w.Weights w2
                    )
                    if (w3 > 0.0 ) then 
                    (
                        append w.BoneIds b3
                        append w.Weights w3
                    )
                    
                    if (w4 > 0.0 ) then
                    (
                        append w.BoneIds b4
                        append w.Weights w4
                    )

                append skins w
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
                local kmte
                
                if ( bytes > 32 ) then
                (
                    local km = Warcraft3_Reforged.ReadFixedString stream 4
                    if ( km == "KMTA" ) then kmta = Warcraft3_Reforged.ReadFloatAnim stream
                    
                    local currentpos = ftell stream
                    km = Warcraft3_Reforged.ReadFixedString stream 4
                    if ( km == "KMTE" ) then 
                        kmte = Warcraft3_Reforged.ReadFloatAnim stream
                    else
                        fseek stream currentPos #seek_set
                        
                    
                    
                        
                )
                lay.KMTA = kmta
                lay.KMTE = kmte
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
            seq.StartFrame = (readLong stream  * 30 / 1000.0 as integer )+ 10
            seq.EndFrame = (readLong stream * 30 / 1000.0 as integer) + 10
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
    function ReadGEOA stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local geoa = #()
        
        local len = readLong stream
        Warcraft3_Reforged.SkipBytes stream (len - 4)
        local len = readLong stream
        Warcraft3_Reforged.SkipBytes stream (len - 4)
        local baseLen= 0
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local ga = Warcraft3_Reforged_GEOA()
            
            local len = readLong stream -- total chunk size
            
            Warcraft3_Reforged.SkipBytes stream 20
            ga.GeoId = readLong stream + 1
            local backup = ftell stream
            local kgao = Warcraft3_Reforged.ReadFixedString stream 4
            
            if ( kgao == "KGAO" ) then
                ga.KGAO = Warcraft3_Reforged.ReadFloatAnim stream
            else
                fseek stream backup #seek_set
            
            if ( ga.KGAO != undefined ) then append geoa ga
        )

        return geoa
    ),
    /* BUILD
    
    */
    function BuildGEOS geos modl mtls=
    (
        local wireColor = color 128 128 128
        for geo in geos do
        (
            --if (geo.MATS.LOD != 0) then continue
            --format "[NOTE] Only LOD 0 is build !!\n"
            
            format "Building %\n" geo.MATS.Name
            
            local layerName = modl.name + " - LOD " + (geo.MATS.LOD as string)
            local layer = Warcraft3_Reforged.CreateLayer layerName
            
            if (geo.MATS.LOD != 0 ) then layer.isHidden = true
            
            if (geo.MATS.LOD == 0) then wireColor = color 190 190 100
            if (geo.MATS.LOD == 1) then wireColor = color 64 164 64
            if (geo.MATS.LOD == 2) then wireColor = color 64 164 164
            if (geo.MATS.LOD == 3) then wireColor = color 0 128 255
            
            
            local mat = mtls[geo.MATS.ID].MaterialRef
            
            try (
                
                local v = geo.VRTX
                local n = geo.NRMS
                local f = geo.PVTX
                local uv = geo.UVS[1]
                local meshName = geo.MATS.Name
                
                local theMesh = mesh vertices:v vnorms:n name:meshName faces:f tverts:uv 

                theMesh.WireColor = wireColor

                theMesh.Material = mat
                
                buildTVFaces theMesh false
                for i = 1 to f.count do
                ( setTVFace theMesh i f[i] )
            
                layer.AddNode theMesh
                
                update theMesh
                geo.meshRef = theMesh
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
                            at time ( anim.Time + 10 )
                            (
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
        if ( atch == undefined ) then return undefined
        
        
        local layer = Warcraft3_Reforged.CreateLayer "Attachments"
     
        sliderTime = 0f
        
        for a in atch do 
        (
            local pnt = Point name:a.name box:off cross:on centermarker:off axistripod:off size:12
            pnt.wirecolor = color 255 255 0
            pnt.pos = bpos[a.id].matrix.row4
            
            layer.AddNode pnt
            if( a.parentBoneId>0) then 
            (
                local parentBone = boneList[a.parentBoneId].boneRef
                if( parentBone == undefined) then
                    parentBone = getnodebyname boneList[a.parentBoneId].name
                
                pnt.parent = parentBone
            )
            -- KGTR, KGRT, KGSC, KATV
            if ( a.KGRT != undefined ) then 
            (
                pnt.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = pnt.rotation.controller
                local q0 = dr.transform
                
                for anim in a.KGRT do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                            
                        )
                )
                with animate on pnt.rotation.controller = copy dr.rotation.controller
                
                delete dr
            )
            if ( a.KGTR != undefined ) then
            (
                pnt.assumeSkinPose()
                
                local dp = dummy name:"DummyPositionController" 
                dp.position.controller = pnt.position.controller
                local p0 = dp.transform
                
                for anim in a.KGTR do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 dp.position = p 
                        )
                )
                with animate on pnt.position.controller = copy dp.position.controller
                
                delete dp
            )
            if ( a.KGSC != undefined ) then
            (
                b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = pnt.scale.controller
                local p0 = ds.transform
                
                for anim in a.KGTR do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.position = p 
                        )
                )
                with animate on pnt.scale.controller = copy ds.scale.controller
                
                delete ds
            )
                    
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
                        with animate on at time ( anim.Time + 10 )
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
        local layer = Warcraft3_Reforged.CreateLayer "Bones"
        
        -- create the bones
        for b in boneList do
        (
            
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
			aBone.Width = 0.05
			aBone.Height = 0.05
            b.boneRef = aBone
            layer.AddNode aBone

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
        
        -- apply bind pos
        for obj in boneList do
        (
            local b = obj.boneRef
           
            b.pos = bpos[obj.id].matrix.row4
        )

        -- apply bone animation
        for obj in boneList do
        (
                        local b = obj.boneRef
            
            if ( obj.KGRT != undefined ) then 
            (
                b.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                
                for anim in obj.KGRT do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                            
                            
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr
                

                
            )
            
            if ( obj.KGTR != undefined ) then
            (
               
               
                    b.assumeSkinPose()
                    
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = b.position.controller
                    local p0 = dp.transform
                    
                    for anim in obj.KGTR do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point
                        
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on b.position.controller = copy dp.position.controller
                    
                    delete dp
                
            )
            
            if ( obj.KGSC != undefined ) then
            (
                b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                
                for anim in obj.KGSC do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )
            
        )
    ),
    function BuildSKIN geos boneList=
    (
       
        try(
            for geo in geos do
            (

                local msh = geo
                local obj = geo.meshRef

                if ( obj == undefined ) then continue
                
                local mshSkin = skin name:"Skin"

                max modify mode
                addmodifier obj mshSkin

                modPanel.setCurrentObject mshSkin

                for i=1 to boneList.count do
                (
                    local b = boneList[i].boneRef
                    skinOps.addBone mshSkin b 0
                )

                update obj
                max views redraw

                for v=1 to geo.VRTX.count do
                (
                    local boneIds = geo.SKIN[v].BoneIds
                    local weights = geo.SKIN[v].Weights
                    skinOps.ReplaceVertexWeights mshSkin v boneIds weights

                )

                update obj
            )
        )
        catch()
        redrawViews()

    ),
    function BuildSEQS seqs=
    (
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
                                    
        for seq in seqs do
        (
            local startNote = AddNewNoteKey starAnimTrack seq.startFrame
            local endNote = AddNewNoteKey starAnimTrack seq.endFrame
            local val = seq.name + "\r\n"
                  val += "rarity = " 	 + (seq.Rarity as string)    + "\r\n"
                  val += "moveSpeed = "  + (seq.MovementSpeed as string) + "\r\n"
                  val += "nonLoop = " 	 + (seq.Noloop as string)    + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = 0"

            startNote.Value = val
            endNote.Value = val

            format "Animation added: %  %-%\n" seq.name seq.startFrame seq.endFrame
			
        )
    ),
    function BuildCLID clid boneList bpos=
    (
        if (clid == undefined ) then return undefined
        local layer = Warcraft3_Reforged.CreateLayer "Collision Objects"
        for cl in clid do
        (
            local cap = undefined
            
            if cl.BoundingType == 0 then cap = capsule name:cl.name radius:cl.radius height:cl.height
            if cap == undefined then 
            (
                format "[WARNING] This bounding type is not implemented (Bounding type = %)\n" cl.BoundingType
                cap = capsule name:cl.name radius:cl.radius height:cl.height
            )

            rotate cap (angleaxis 180 [0,1,0])
            cap.boxmode = on
            cap.renderable = off
            cap.showFrozenInGray = off
            cap.wirecolor = color 100 200 250
            freeze cap
            resetXform cap
            
            layer.AddNode cap
            cap.assumeSkinPose()
            
            local mtrx = bpos[cl.id].matrix
            
            if ( cl.KGRT != undefined ) then 
            (
                -- initial pose
                 with animate on at time 0 in coordsys mtrx cap.rotation = cl.KGRT[1].point
                
                for anim in cl.KGRT do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx cap.rotation = q
                )
                    
            )
            
            if ( cl.KGTR != undefined ) then 
            (
                -- initial pose
                 with animate on at time 0 in coordsys mtrx cap.pos = cl.KGTR[1].point
                     
                for anim in cl.KGTR do
                (
                    local t = anim.time + 10
                    local p = anim.Point
                    
                    with animate on at time t in coordsys mtrx cap.pos = p
                )
                    
            )
          
            
            
            
        )          
    ),
    function BuildGEOA geoa geos=
    (
        
        for a in geoa do
        (
            local theMesh = geos[a.GeoId].meshRef
            if ( theMesh == undefined ) then continue
            local isVisibilityTrackRequired = false -- by default evertythng is 1
                
            for anim in a.KGAO do
            (
                if ( anim.point == 0) then isVisibilityTrackRequired = true
            )
            
            if ( isVisibilityTrackRequired == true ) then
            (
                theMesh.Visibility = undefined 
                theMesh.Visibility = on
                theMesh.Visibility.controller = on_off()

                for anim in a.KGAO do 
                    with animate on at time ( anim.Time + 10 )
                        if (anim.point == 1) then 
                            theMesh.Visibility = on
                        else
                            theMesh.Visibility = off
            )
            
        )
        
    ),
    /*
        MAIN IMPORT
    */
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
        local geoa -- geometry animation
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
            -- GEOA // geoset animation
            if( tag.Name == "GEOA" ) then geoa = Warcraft3_Reforged.ReadGEOA stream tag

            -- PIVT // pivots
            -- PRE2 // particle emitter
            -- EVTS // events
            -- CORN // conrners ??
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
         Warcraft3_Reforged.BuildSKIN geos boneList
         Warcraft3_Reforged.BuildSEQS seqs
         Warcraft3_Reforged.BuildCLID clid boneList bpos
         Warcraft3_Reforged.BuildGEOA geoa geos

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
        gc()
    )
)

ClearListener()
file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\units\creeps\azuredragon\azuredragon.mdx"
--file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\units\critters\frog\frog.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\doodads\ashenvale\plants\ashenbush0\ashenbush0.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\units\orc\battroll\battroll.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\units\demon\chaosgrunt\chaosgrunt.mdx"
-- file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\units\creeps\wendigo\wendigo.mdx"
--file = @"F:\Blizzard\Warcraft - Reforged\Exported\assets\units\human\herohalahk\herohalahk.mdx"

--file = @"F:\Blizzard\Warcraft - Reforged\Casc\war3.w3mod\_hd.w3mod\units\demon\chaospeon\chaospeon.mdx"
-- file = getOpenFileName \
-- 			caption:"Heroes of the Storm" \
-- 			types:"Supported Files|*.mdx|Warcraft 3 Reforged(*.mdx)|*.mdx|All Files|*.*" \
-- 			historyCategory:"ReforgedPreset"


Warcraft3_Reforged.Import file
