/*
    .COPYRIGHT
    |   (c) 2020-2021 Griffon Studios
    |   Warcraft and Warcraft III Reforged are properties of Blizzard Entertainment
    
    .AUTHOR
    |   Taylor Mouse
    
    .DESCRIPTION
    |   Warcraft III Reforged Import model
    
*/
global gBpos
global gBones
global gModel
global gCollisions

global wc3_debug = false
global wc3_debug_build = true
global Warcraft3_ImportAllLOD = false
global wc3_version = 1000

struct Warcraft3_Reforged_TAG
    ( Name, Offset, Size )

struct Warcraft3_Reforged_MODL
    ( Name, bbBox, Always150 )

struct Warcraft3_Reforged_GEO
    ( uniqueName, VRTX = #(), NRMS = #(), PTYP = #(), PCNT = #(), PVTX = #(), GNDX = #(), MTGC = #(), MATS = #(), TANG = #(), SKIN = #(), UVS = #(), meshRef ) 

struct Warcraft3_Reforged_MATS
    ( ID, LOD, Name, Matrices )

struct Warcraft3_Reforged_BONE
    ( Id, Name, ParentBoneId, Flags, boneRef, KGTR, KGRT, KGSC, offset, geosetId, geosetAnimationId )

struct Warcraft3_Reforged_ATCH
    ( Id, Name, ParentBoneId, Flags, Offset, Size, KGTR, KGRT, KGSC, KATV)

struct Warcraft3_Reforged_SEQS
    ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity,Priority,Default, BBox )
	
struct Warcraft3_Reforged_KG
	( Time, Point, inTan, outTan, LineType )

struct Warcraft3_Reforged_CLID
    ( Id, Name, ParentId, Pos, posAlt, Radius, Height, objRef, Flags, Offset, Size, OffsetBounding, BoundingType, KGTR, KGRT, KGSC )

struct Warcraft3_Reforged_TEXS
    ( Id, replacableId, fileNameOnly, path,  extension, flags )

struct Warcraft3_Reforged_MTLS
    ( Id, ShaderName, priorityPlane, flags, ConstantColor=off , TwoSided=off,  SortPrimsFarZ=off, FullResolution=off, materialRef, LAYS )

struct Warcraft3_Reforged_LAYS
    ( Id, ParentId, TextureId, filterMode, shadingFlags,  KMTA, KMTE, CoordId,alpha, emissive_multiplier, fresnelR, fresnelG, fresnelB, fresnel_multiplier, team_color_multiplier )

struct Warcraft3_Reforged_BPOS
    ( Id, Matrix )

struct Warcraft3_Reforged_Weights
    ( VertexId, BoneIds, Weights )

struct Warcraft3_Reforged_GEOA
    ( Id, GeoId, KGAO )

struct Warcraft3_Reforged_EVTS
    ( Id, Name, ParentId, Flags, KEVT, objRef )

struct Warcraft3_Reforged_PIVT
    ( Id, PivotPoint, objRef )

struct Warcraft3_Reforged_FAFX
    ( Id, Name, ExternalFileName, objRef )

struct Warcraft3_Reforged_CAMS
    ( Id, Name, Pos,  FOV, FarClip, NearClip, TargetPos, KCTR, KTTR, KCRL, objRef )

struct Warcraft3_Reforged_CORN
    ( Id, Name, FileName, Properties, ParentId, Flags, KPPA, KPPV,KPPE, KGSC, KGTR, KGRT )

struct Warcraft3_Reforged_LITE
    ( Id, ParentId, Name, Flags, Type, FarAttenStart, FarAttenEnd, rgbColor, rgbIntensity, ambColor, ambIntensity, KGSC, KGTR, KGRT )

struct Warcraft3_Reforged_ANIM
    ( numPts, LineType, ParentId, KG )

struct Warcraft3_Reforged_TXAN
    ( KTAT, KTAR, KTAS ) 

struct Warcraft3_Reforged_RIBB
    ( Id, Name, ParentBoneId, Flags, KGRT, KGTR, KGSC, staticHeightAbove, staticHeightBelow, staticAlpha, staticColor, lifeSpan, textureId, emissionRate, flipbookRows, flipbookColumns, mtlsId, gravity, KRHA, KRHB, KRAL, KRCO, KRTX, KRVS )

struct Warcraft3_Reforged_PRE2_FLAGS
    ( DONT_INHERIT_TRANSLATION ,DONT_INHERIT_SCALING ,DONT_INHERIT_ROTATION,BILLBOARDED,BILLBOARD_LOCK_X,BILLBOARD_LOCK_Y,BILLBOARD_LOCK_Z,GENOBJECT_MDLBONESECTION,GENOBJECT_MDLLIGHTSECTION, GENOBJECT_MDLEVENTSECTION,GENOBJECT_MDLATTACHMENTSECTION,GENOBJECT_MDLPARTICLEEMITTER2,GENOBJECT_MDLHITTESTSHAPE,GENOBJECT_MDLRIBBONEMITTER,PROJECT,UNSHADED,SORT_PRIMITIVES_FAR_Z,LINE_EMITTER,PARTICLE_UNFOGGED,PARTICLE_USE_MODEL_SPACE, PARTICLE_INHERIT_SCALE,PARTICLE_INSTANT_VELOCITY_LIN,PARTICLE_0XKILL,PARTICLE_Z_VELOCITY_ONLY,PARTICLE_TUMBLER,PARTICLE_TAIL_GROWS,PARTICLE_EXTRUDE,PARTICLE_XYQUADS,PARTICLE_PROJECT,PARTICLE_FOLLOW )

struct Warcraft3_Reforged_PRE2
    ( Id, name, ParentId, KGRT, KGTR, KGSC, KP2V, KP2E, Flags, 
        speed , 
        variation, 
        coneAngle , 
        gravity, 
        lifespan, 
        emissionrate, 
        length, 
        width , 
        emitterType, --> line emitter or not
        rowCount, 
        colCount, 
        particleType,
        tailLength, 
        midTime, 
        startColor, 
        midColor, 
        endColor, 
        startAlpha, 
        midAlpha, 
        endAlpha, 
        startSize, 
        midSize, 
        endSize, 
        startLifespanUVAnim, 
        midLifespanUVAnim, 
        endLifespanUVAnim, 
        startDecayUVAnim, 
        midDecayUVAnim, 
        endDecayUVAnim, 
        startTailUVAnim, 
        midTailUVAnim, 
        endTailUVAnim, 
        startTailDecayUVAnim, 
        midTailDecayUVAnim, 
        endTailDecayUVAnim, 
        blendMode, 
        textureId, 
        priorityPlane, 
        replacableTextureId  
    )

GLOBAL mdxFileVersion = 0
GLOBAL mdx = undefined   
GLOBAL mdxConvertToSC2AnimationNames = false
GLOBAL mdxFilterMode = #("none","transparent","blend","additive","add alpha","modulate","modulate 2x","fallback" )    
GLOBAL mdxShadingFlag = # ("Unshaded","Sphere environment map","Wrap Width","Wrap Hieght","Two sided","Unfogged","No depth test","No depth set","Fallback" )

fileIn "GriffonStudios_Helpers.ms"
    
struct StarTools_Helpers
(
    function RenameSEQS seqs=
    (
        for seq in seqs do
        (
            local parts = filterstring seq.name " "
            
           if ( parts[parts.count] == "1" ) then parts[parts.count] = "" 
            for x=2 to 26 do
                if ( parts[parts.count] == (x as string ) ) then parts[parts.count] = ( bit.intAsChar ( x + 64 ) )    
            
            local newName = ""
            for p=1 to parts.count do 
            (
                newName +=parts[p]
                if ( p < parts.count ) then newName += " "
            )
            seq.name = trimRight newName
        )
        
    ),
    function ConvertAttachmentPoints=
    (
        try ( 
            test = SC2_Standard_Material() 
            STARCRAFT_II_ARTTOOLS_INSTALLED = true
        ) catch()
        
        if ( STARCRAFT_II_ARTTOOLS_INSTALLED == true ) then
        (
            for obj in objects do 
            (
                if ( classof obj == WC3RefAttachment ) then
                (
                    local pt = SC2AttachPt()
                    local parts = filterstring obj.name " "
                    local newName = "Ref_"
                    for p in parts do 
                    (
                        if ( p != "Ref" ) then newName +=p
                    )
                    
                    pt.Name = newName
                    pt.Pos = obj.pos
                    pt.Rotation = obj.rotation
                    rotate pt ( eulerangles 0 0 90 )
                    pt.parent = obj.parent
                )
            )
            
            for obj in objects do
            (
                if ( classof obj == WC3RefAttachment ) then 
                    delete obj
            )
        )
        else
        (
            MessageBox "Starcraft II Art Tools not found"
            
        )
    ),
    function ConvertHitTestBoxes=
    (
        local index = 1
        for obj in objects do
        (
            
            if obj.isfrozen then 
            (    
                if obj.name == "B_KGS_Root" then 
                    obj.name = "HitTestTight"
                else
                if ( substring obj.name 1 6 ) == "B_KGS_" then
                (
                    
                    obj.name = "HitTestFuzzy" + ( substring ( (1000 + index)  as string ) 2 3  )
                    
                    index +=1
                    
                )
            
            )
        )
        
    ),
    function GetBoundingBox=
    (
        local bbPoints = #()
        local bbMax = [0,0,0]
        local bbMin = [0,0,0]
        
        for obj in objects do
        (
            if ( classof obj == Editable_mesh ) then
            (
                --> TODO loop over every frame 
                
                if ( obj.Max.X > bbMax.X) then bbMax.X = obj.Max.X
                if ( obj.Max.Y > bbMax.Y) then bbMax.Y = obj.Max.Y
                if ( obj.Max.Z > bbMax.Z) then bbMax.Z = obj.Max.Z
                if ( obj.Min.X < bbMin.X) then bbMin.X = obj.Min.X
                if ( obj.Min.Y < bbMin.Y) then bbMin.Y = obj.Min.Y
                if ( obj.Min.Z < bbMin.Z) then bbMin.Z = obj.Min.Z
                
            )
        )
        append bbPoints bbMin 
        append bbPoints bbMax
        return bbPoints
    ),
    function ConvertToBoundingSphere theBox name=
    (
        if (theBox != undefined) then
        (
            local radius = ( distance theBox.max theBox.min ) / 2.0
            local pos = theBox.center
            
            theSphere = sphere name:name pos:pos radius:radius segs:32
            
            theSphere.parent = theBox.Parent
            theSphere.wirecolor = color 255 0 0
            theSphere.boxmode = on
            theSphere.renderable = off
            freeze theSphere
            
            
            
            delete theBox
            
            return theSphere
        )
    ),
    function ConvertMaterials=
    (
        print "TODO: Not implemented yet"
        
    )
)


struct Warcraft3_Reforged
(

    /*
        FLAGS ( from prev documentation)
        // 0x0: helper
        // 0x1: dont inherit translation
        // 0x2: dont inherit rotation
        // 0x4: dont inherit scaling
        // 0x8: billboarded
        // 0x10: billboarded lock x
        // 0x20: billboarded lock y
        // 0x40: billboarded lock z
        // 0x80: camera anchored
        // 0x100: bone
        // 0x200: light
        // 0x400 event object
        // 0x800: attachment
        // 0x1000 particle emitter
        // 0x2000: collision shape
        // 0x4000: ribbon emitter
        // 0x8000: if particle emitter: emitter uses mdl, if particle emitter 2: unshaded
        // 0x10000: if particle emitter: emitter uses tga, if particle emitter 2: sort primitives far z
        // 0x20000: line emitter
        // 0x40000: unfogged
        // 0x80000: model space
        // 0x100000: xy quad
    
    */

    /* Warcraft 3 Reforged READ
    */
    function ReadVector3 stream=
    (
        local vector3 = [readFloat stream, readFloat stream, readFloat stream]
        return vector3
    ),
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    ),
    function ReadTAGS stream streamLen=
    (
        local tags = #() 
        local mainTag = Warcraft3_Reforged_TAG()

        mainTag.Name = GriffonStudios_Helpers.ReadFixedString stream 4
        mainTag.Offset = 0
        mainTag.Size = 0
        
        local currentStreamPos = ftell stream

        while (currentStreamPos < streamLen ) do
        (
            local tag = Warcraft3_Reforged_TAG()
            
            tag.Offset = ftell stream + 8 -- the +8 indicates where the data starts
            tag.Name = GriffonStudios_Helpers.ReadFixedString stream 4
            tag.Size = ReadLong stream
            
            GriffonStudios_Helpers.SkipBytes stream tag.Size

            currentStreamPos = ftell stream
            
            append tags tag
            --print tag
        )
        return tags
    ),
    function ReadColor stream=
    (
        local r = (readFloat stream * 255.0) as integer
        local g = (readFloat stream * 255.0) as integer
        local b = (readFloat stream * 255.0) as integer
        return ( color r g b )
    ),
    function ReadColorAnim stream=
    (
        local anim = Warcraft3_Reforged_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = Warcraft3_Reforged.ReadColor stream -- always 1, indicating it starts or ends

            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadLongAnim stream=
    (
        local anim = Warcraft3_Reforged_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readLong stream -- always 1, indicating it starts or ends

            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
        
    ),
    function ReadFloatAnim stream=
    (
        
        -- Key Attachment visibility
        /* presumably the visibility of the object, the lineType will indicate the trasition tangent */
        
        local anim = Warcraft3_Reforged_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readFloat stream -- always 1, indicating it starts or ends

            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadVector3Anim stream=
    (
        local anim = Warcraft3_Reforged_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = [readFloat stream, readFloat stream, readFloat stream]

            if( anim.lineType > 1)  then
            (
                k.inTan = [readFloat stream, readFloat stream, readFloat stream]
                k.outTan = [readFloat stream, readFloat stream, readFloat stream]
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadQuatAnim stream=
    (
        local anim = Warcraft3_Reforged_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = Warcraft3_Reforged_KG()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = lineType
            if( anim.lineType > 1)  then
            (
                --format "Linetype: %\n" lineType
                k.inTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
                k.outTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadMODL stream tag=
    (
        local modl = Warcraft3_Reforged_MODL()
        fseek stream tag.offset #seek_set
        
        modl.name = GriffonStudios_Helpers.ReadFixedString stream 80
        GriffonStudios_Helpers.SkipBytes stream (tag.size - 80 - 28)
        
        modl.bbBox = #()
        
        append modl.bbBox [readFloat stream, readFloat stream, readFloat stream]
        append modl.bbBox [readFloat stream, readFloat stream, readFloat stream]
        modl.Always150 = readLong stream
        
        return modl
        
    ),
    function ReadVERS stream tag=
    (
        fseek stream tag.Offset #seek_set
        local version = readLong stream
        mdxFileVersion = version
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
            local name = GriffonStudios_Helpers.ReadFixedString stream 260
            t.path = getFilenamePath name
            t.fileNameOnly = getFilenameFile name
            t.extension = getFilenameType name 
            t.flags = readLong stream
            
            --format "Texture: % %\n" i name
            
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
            local geosize = readLong stream
            currentRelativePosition = currentRelativePosition + geosize 
            if(currentRelativePosition > tag.Size ) then exit
            
            local geo = Warcraft3_Reforged_GEO()   
            
            local verts = #()
            local norms = #()
            local types = #()
            local primitives = #()
            local indices = #()
            local groups = #()
            local matrixGroups = #()
            local matrices = #()
            local tangents = #()
            local skins = #()
            
            geoSize -= 4 
            
            for c=1 to 11 do
            (
                local currentPos = ftell stream
                local chnk = GriffonStudios_Helpers.ReadFixedString stream 4
               
                /* Vertices */
                if ( chnk == "VRTX" ) then 
                (
                    local nVerts = readLong stream
                    for v=1 to nVerts do 
                    (
                        local vert = [readFloat stream, readFloat stream, readFloat stream]
                        
                        append verts vert
                    )
                    geo.VRTX = verts
                    
                )
                /* Normals */
                if ( chnk == "NRMS" ) then 
                (
                    local nNorms = readLong stream
                    for n=1 to nNorms do 
                    (
                        local nrm = [readFloat stream, readFloat stream, readFloat stream]
                        append norms nrm
                    )
                    geo.NRMS = norms
                )
                /* Types */
                if ( chnk == "PTYP" ) then 
                (
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
                )
                /* Primitives */
                if ( chnk == "PCNT" ) then 
                (
                    local nPcnt = readLong stream
                    for p=1 to nPcnt do 
                    (
                        local cn = readLong stream
                        append primitives cn
                    )
                    geo.PCNT = primitives
                )
                /* Indices */  
                if ( chnk == "PVTX" ) then 
                (
                    local nPvtx = readLong stream
                    for i=1 to nPvtx/3 do
                    (
                        local idx = [readShort stream +1, readShort stream +1, readShort stream +1]
                        append indices idx
                    )
                    geo.PVTX = indices
                )
                /* Groups */
                if ( chnk == "GNDX" ) then 
                (
                    local nGndx = readLong stream
                    
                    for g=1 to nGndx do append groups ( readByte stream + 1 )
                    geo.GNDX = groups
                )
                /* Matrix Groups or bone groups */
                if ( chnk == "MTGC" ) then 
                (
                    local nMtgc = readLong stream
                    for m=1 to nMtgc do append matrixGroups (readLong stream)
                    geo.MTGC = matrixGroups
                )
                /* Matrices */
                if ( chnk == "MATS" ) then 
                (
                    local gMats = Warcraft3_Reforged_MATS()
                    local nMats = readLong stream
                    for m=1 to nMats do
                    (
                        append matrices (readLong stream )
                    )
                    gMats.Matrices = matrices
                    gMats.ID = readLong stream + 1 --> reference to the MAT ID in MTLS
                    
                    GriffonStudios_Helpers.SkipBytes stream 8
                    gMats.LOD = readLong stream
                    gMats.Name = GriffonStudios_Helpers.ReadFixedString stream 80 
                    if gMats.Name == "" then gMats.Name = mdx.modl.name
                    
                    for i=1 to 7 do readfloat stream
                        
                    local unk = readLong stream
                    
                    for i=1 to unk do GriffonStudios_Helpers.SkipBytes stream 28
                    
                    geo.MATS = gMats

                )
                /* Tangents */
                if ( chnk == "TANG" ) then 
                (
                    local nTang = readLong stream
                    for t=1 to nTang do
                        append tangents [readFloat stream, readFloat stream, readFloat stream, readFloat stream]
                    geo.TANG = tangents
                )
                /* SKIN */
                if ( chnk == "SKIN" ) then 
                (
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
                )
                /* Nbr of UV Maps */
                if ( chnk == "UVAS" ) then 
                (
                    local nUvas = readLong stream --> nbr of uv coordinates
                    /* UV Coordinates */
                    geo.UVS = #()
                    for i=1 to nUvas do
                    (
                        local uvs = #()
                        local uvbs = GriffonStudios_Helpers.ReadFixedString stream 4
                        local nUvbs = readLong stream

                        for u=1 to nUvbs do
                        (
                            append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )
                        )
                        append geo.UVS uvs
                    )
                )

                geoSize -= (ftell stream) - currentPos
                if geoSize <= 0 then exit
            )
            append geos geo
        )
        
        
        return geos
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
        
            b.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            b.Id = readLong stream + 1
            b.ParentBoneId = readLong stream + 1
            
            b.Flags = readLong stream
            b.offset = ftell stream
            
            GriffonStudios_Helpers.SkipBytes stream ( size - 80 - 16 )
            
            b.geosetId =  readlong stream
            b.geosetAnimationId =  readlong stream

            --format "geosetId: % geosetAnimationId: %\n" b.geosetId b.geosetAnimationId
            
            --if ( b.geosetId != -1 ) then format "Strange geoset id % \n" b.geosetId
            --if ( b.geosetAnimationId != -1 ) then format "Strange geoset Animation Id % \n" b.geosetAnimationId
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
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

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
    function ReadLayer stream=
    (
        /* filterMode
                 0x0: none          -> Opaque
                 0x1: transparent   -> Mask
                 0x2: blend         -> Blend
                 0x3: additive      -> Add
                 0x4: add alpha     -> Blend Add
                 0x5: modulate      -> Mod
                 0x6: modulate 2x   -> Mod 2x
                 0x7: fallback      -> not supported
                */
        
        /* ShadingFlag
                 0x1: unshaded       -> Unlit
                 0x2: sphere env map -> Spherical Reflection Map
                 0x4: Wrap Width     -> Tile Horizontally
                 0x8: Wrap Height    -> Tile Vertically
                 0x10: two sided     -> Show backface culling
                 0x20: unfogged      -> Draw Z Depth
                 0x40: no depth test -> 
                 0x80: no depth set               
                 0x100: Fallback
                */
                
        local currentPos = ftell stream
        local layer = Warcraft3_Reforged_LAYS()
        local layerSize = readLong stream  --> without any specific animations, the layer is 52 bytes

        layer.filterMode = readLong stream + 1
        layer.shadingFlags = readLong stream + 1
        layer.textureId = readLong stream + 1
        layer.parentId = readLong stream + 1
        
        layer.CoordId = readLong stream
        layer.alpha = readfloat stream
        layer.emissive_multiplier = readfloat stream --> ?
        layer.fresnelR = readfloat stream
        layer.fresnelG = readfloat stream
        layer.fresnelB = readfloat stream
        layer.fresnel_multiplier = readfloat stream
        layer.team_color_multiplier = readfloat stream

        --GriffonStudios_Helpers.SkipBytes stream ( 52 - 20 )
        
        if ( layerSize > 52 ) then (
            for i=1 to 2 do
            (
                local km = GriffonStudios_Helpers.ReadFixedString stream 4
                
                if ( km != "KMTA" and km.count == 4  ) then print km
                
                if ( km == "KMTA" ) then layer.KMTA = Warcraft3_Reforged.ReadFloatAnim stream
                if ( km == "KMTE" ) then layer.KMTE = Warcraft3_Reforged.ReadFloatAnim stream
            )
            if ( layer.KMTA == undefined ) then fseek stream -4 #seek_cur
            if ( layer.KMTE == undefined ) then fseek stream -4 #seek_cur
        )   
        
        fseek stream ( currentPos + layerSize ) #seek_set
               
        return layer
        
    ),
    function ReadMTLS stream tag=
    (
 
        local mtls = #()
        local mtlsId = 1
        local mtlsSize = tag.Size
        local offset = tag.offset
        
        /* read multiple shaders */
        for i=1 to 10 do -- for safety purposes make it ending
        (
            fseek stream offset #seek_set
            
            
            local shaderSize = readLong stream
            mtlsSize = mtlsSize - shaderSize
            offset = offset + shaderSize
            
            local mtl = Warcraft3_Reforged_MTLS()
            mtl.Id = mtlsId
            
            mtl.priorityPlane = readLong stream
            mtl.flags = readLong stream
            
            /*
                0x1 ConstantColor -> unlit
                0x10 SortPrimsFarZ -> Sort in Far Z 
                0x20 FullResolution -> no mipmaps
                0x02 TwoSided 
            */

            if ( bit.and mtl.flags 0x01 > 0 ) then mtl.ConstantColor = on
            if ( bit.and mtl.flags 0x02 > 0 ) then mtl.TwoSided  = on
            if ( bit.and mtl.flags 0x10 > 0 ) then mtl.SortPrimsFarZ = on
            if ( bit.and mtl.flags 0x20 > 0 ) then mtl.FullResolution = on
            
            mtl.shaderName = GriffonStudios_Helpers.ReadFixedString stream 80    
            
            local lays = GriffonStudios_Helpers.ReadFixedString stream 4
            local nLays = readLong stream
            --format "Layers: %\n" nLays
            
            mtl.LAYS = #()
            
            for l=1 to nLays do
            (
                local layer = Warcraft3_Reforged.ReadLayer stream
                layer.id = l
                append mtl.LAYS layer
            )

            mtlsId += 1
            append mtls mtl
            if mtlsSize <= 0 then exit
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
            local headerSize = readLong stream --> 96 bytes consisting of name, id, parentId and flagid and headerSize

            

            att.name = GriffonStudios_Helpers.ReadFixedString stream 80
            att.Id = readLong stream + 1
            att.ParentBoneId = readLong stream + 1
            att.flags = readLong stream
            
            --format "Flag Value %\n" att.flags
            
            att.Offset = ftell stream
            att.Size = size - 4 - 4 - 80 - 8 - 4
            
            GriffonStudios_Helpers.SkipBytes stream att.Size
        
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
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

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
           
            GriffonStudios_Helpers.SkipBytes stream ( 264 - correction)

            local katv = GriffonStudios_Helpers.ReadFixedString stream 4
            
            if( katv == "KATV") then att.katv = Warcraft3_Reforged.ReadFloatAnim stream -- visibility track ?

        )
        
        return atchs
        
    ),
    function ReadSEQS stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local nbrSeqs = tag.size / 132
        --print nbrSeqs
        
        local seqs = #()
        
        for i=1 to nbrSeqs do
        (
            local seq = Warcraft3_Reforged_SEQS()
            seq.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            
            local originalStartFrame = readLong stream
            local originalEndFrame = readLong stream
            
            --format "Original sequence: % (%-%)\n" seq.Name originalStartFrame originalEndFrame
            
            seq.StartFrame = ( GriffonStudios_Helpers.RoundToFrame ( originalStartFrame ) ) + 10
            seq.EndFrame = ( GriffonStudios_Helpers.RoundToFrame ( originalEndFrame ) ) + 10
            seq.MovementSpeed = readFloat stream
            seq.NoLoop = readLong stream
            seq.Rarity = readFloat stream
            seq.Default = readlong stream
            seq.Priority = readFloat stream
            
            seq.BBox = #([readfloat stream,readfloat stream,readfloat stream], [readfloat stream,readfloat stream,readfloat stream] )

            append seqs seq
        )

        if (mdxConvertToSC2AnimationNames == true ) then 
            StarTools_Helpers.RenameSEQS seqs

        return seqs
        
    ),
    function ReadCLID stream tag=
    (
        fseek stream tag.offset #seek_set
        
        /*
            0: cube
            1: plane
            2: sphere
            3: cylinder
        */
        
        local clid = #()
        local i=1 -- failsafe
        local prevId = 0
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local cl = Warcraft3_Reforged_CLID()
            
            local size = readLong stream
            cl.name = GriffonStudios_Helpers.ReadFixedString stream 80
            cl.Id = readLong stream + 1
            if (prevId == 0) then 
                prevId = cl.Id
            else
                if ( prevId + 1 != cl.Id ) then 
                    exit 
                else
                    prevId = cl.Id
            
            cl.parentId = readLong stream + 1
            cl.flags = readLong stream
            
            cl.Offset = ftell stream
            cl.Size = size - 80 - 16
            
            GriffonStudios_Helpers.SkipBytes stream cl.Size --> read in the next part
            cl.OffsetBounding = ftell stream 
            
            GriffonStudios_Helpers.SkipBytes stream 28 --> read in the next part
            
            append clid cl
            
            if (i==50) then exit
            i +=1
        )
        
        for cl in clid do
        (
            fseek stream cl.offset #seek_set
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                
                if ( kg == "KGTR" ) then cl.KGTR = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then cl.KGRT = Warcraft3_Reforged.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then cl.KGSC = Warcraft3_Reforged.ReadVector3Anim stream -- Key Global Scale

            )

            fseek stream cl.OffsetBounding #seek_set
            
            cl.BoundingType = readLong stream
            /*
              0: cube
              1: plane
              2: sphere
              3: cylinder
            */
            cl.pos = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( cl.BoundingType != 2 ) then cl.posAlt = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( cl.BoundingType == 2 or cl.BoundingType == 3 ) then cl.radius = readFloat stream
            
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
            append bpos b
            
        )
        
        return bpos
    ),
    function ReadGEOA stream tag=
    (
        
        ---> CHECK THE SPECS, REDO THIS PART !!
        
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.Size
        
        local geoa = #()
        
        while ( totalSize > 0 ) do
        (
            local ga = Warcraft3_Reforged_GEOA()
            
            local miniSize = readLong stream
            totalSize -= miniSize
            
            for i=1 to 5 do readFloat stream
            
            ga.GeoId = readLong stream + 1
            
            local kgao = GriffonStudios_Helpers.ReadFixedString stream 4
            
            if ( kgao == "KGAO" ) then
                ga.KGAO = Warcraft3_Reforged.ReadFloatAnim stream
            else
                fseek stream -4 #seek_cur
            
            append geoa ga
        )
    
        return geoa
    ),
    function ReadEVTS stream tag=
    (
        /*
            for a full understanding what these sounds are, see the official Warcraft III Art Tools documentation
            Footprints      FPTxyyyy
            Blood Splats    SPLxyyyy
            Uber Splat      UBRxyyyy
            Sound Events    SNDxyyyy
            Spawn Objects   SPNxyyyy
            
        */
        
        
        fseek stream tag.Offset #seek_set
        local evts = #()
              
        
        while ( ftell stream < (tag.offset + tag.size)) do
        (
            local evt = Warcraft3_Reforged_EVTS()
            local size = readLong stream
            
            evt.name = GriffonStudios_Helpers.ReadFixedString stream 80
            evt.id  = readLong stream + 1
            evt.parentId = readLong stream + 1
            evt.flags = readLong stream
            local kevt = GriffonStudios_Helpers.ReadFixedString stream 4
            if ( kevt == "KEVT" ) then
            (
                local keys = #()
                local nbr = readLong stream
                local parentId = readLong stream + 1
                for i=1 to nbr do 
                (
                    local key =  ( GriffonStudios_Helpers.RoundToFrame ( readLong stream ) ) + 10
                    append keys key
                )
                evt.KEVT = keys
            )
            else
            (
                format "Animation not implemented in ReadEVTS (%)"  evts
            )
            append evts evt
            
           
        )
        
        return evts
    ),
    function ReadPIVT stream tag=
    (
        
        fseek stream tag.offset #seek_set
        local nbr = tag.Size / 12.0
        local pivts = #()
        for n=1 to nbr do
        (
            local p = Warcraft3_Reforged_PIVT()
            p.Id = n
            p.PivotPoint = [readfloat stream, readfloat stream, readfloat stream]
            append pivts p
        )
        return pivts
        
    ),
    function ReadFAFX stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local nbr = tag.size / 340
        
        local fafx = #()
        
        for i=1 to nbr do
        (
            local f = Warcraft3_Reforged_FAFX()
            f.Id = i
            f.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            f.ExternalFileName = GriffonStudios_Helpers.ReadFixedString stream 260
            
            append fafx f
        )
        
        return fafx
        
    ),
    function ReadCAMS stream tag=
    (
        fseek stream tag.Offset #seek_set
        local total_size
        local cams = #()
        
        while ( total_size > 0 ) do
        (
            local size = readLong stream
            local cam = Warcraft3_Reforged_CAMS()

            cam.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            cam.Pos = [readFloat stream,readFloat stream,readFloat stream]
            cam.FOV = radToDeg ( readFloat stream )
            cam.FarClip = readFloat stream
            cam.NearClip = readFloat stream
            cam.TargetPos = [readFloat stream,readFloat stream,readFloat stream]

            for i=1 to 3 do
            (
                local anim = GriffonStudios_Helpers.ReadFixedString stream 4
                if ( anim == "KCTR" ) then cam.KCTR = Warcraft3_Reforged.ReadVector3Anim stream
                if ( anim == "KTTR" ) then cam.KTTR = Warcraft3_Reforged.ReadVector3Anim stream
                if ( anim == "KCRL" ) then cam.KCRL = Warcraft3_Reforged.ReadQuatAnim stream
            )
            
            if ( cam.KCTR == undefined ) then fseek stream -4 #seek_cur
            if ( cam.KTTR == undefined ) then fseek stream -4 #seek_cur
            if ( cam.KCRL == undefined ) then fseek stream -4 #seek_cur
            append cams cam
            total_size -= size
        )
        
        return cams
    ),
    function ReadCORN stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.Size
        local corn = #()
        
        while (totalSize > 0 ) do
        (
            local cor = Warcraft3_Reforged_CORN()
            
            local chunkSize = readLong stream
            totalSize -= chunkSize
            
            local miniSize = readLong stream
            cor.name = GriffonStudios_Helpers.ReadFixedString stream 80
            cor.id = readLong stream + 1
            cor.parentId = readLong stream + 1
            cor.flags = readLong stream

            --format "Corn flag %\n" cor.flags
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KGSC" ) then cor.KGSC = Warcraft3_Reforged.ReadVector3Anim stream
                if( kg == "KGTR" ) then cor.KGTR = Warcraft3_Reforged.ReadVector3Anim stream
                if( kg == "KGRT" ) then cor.KGRT = Warcraft3_Reforged.ReadQuatAnim stream
            )
            if( cor.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( cor.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( cor.KGRT == undefined ) then fseek stream -4 #seek_cur
            
            for i=1 to 8 do 
                local f = readFloat stream
            
            cor.filename = GriffonStudios_Helpers.ReadFixedString stream 260
            local props = GriffonStudios_Helpers.ReadFixedString stream 260
            
            cor.properties = filterString props ", "
            
            for i=1 to 3 do
            (
                local anim = GriffonStudios_Helpers.ReadFixedString stream 4
                if (anim == "KPPE") then cor.kppe = Warcraft3_Reforged.ReadFloatAnim stream
                if (anim == "KPPA") then cor.kppa = Warcraft3_Reforged.ReadFloatAnim stream -- alpha
                if (anim == "KPPV") then cor.kppv = Warcraft3_Reforged.ReadFloatAnim stream -- visibility
            )
            if( cor.kppe == undefined ) then fseek stream -4 #seek_cur
            if( cor.kppa == undefined ) then fseek stream -4 #seek_cur
            if( cor.kppv == undefined ) then fseek stream -4 #seek_cur

--             print cor
            append corn cor
        )

        return corn
    ),
    function ReadLITE stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.Size
        local lites = #()
        /*
            0x0: Omni
            0x1: Directional
            0x2: Ambient
            0x3: Default
        */

        while (totalSize > 0 ) do
        (
            local size = readLong stream
            totalSize -= size
            
            local l = Warcraft3_Reforged_LITE()
            
            local ninetySix = readLong stream -- usually 96 appears before a name ???
            l.name = GriffonStudios_Helpers.ReadFixedString stream 80
            l.Id = readLong stream + 1
            l.ParentId = readLong stream + 1
            l.Flags = readLong stream 
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KGSC" ) then l.KGSC = Warcraft3_Reforged.ReadVector3Anim stream
                if( kg == "KGTR" ) then l.KGTR = Warcraft3_Reforged.ReadVector3Anim stream
                if( kg == "KGRT" ) then l.KGRT = Warcraft3_Reforged.ReadQuatAnim stream
            )
            if( l.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( l.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( l.KGRT == undefined ) then fseek stream -4 #seek_cur
            
            l.Type = readLong stream 
            l.FarAttenStart = readFloat stream
            l.FarAttenEnd = readFloat stream
            l.rgbColor = Warcraft3_Reforged.readColor stream
            l.rgbIntensity = readFloat stream
            l.ambColor = Warcraft3_Reforged.readColor stream
            l.ambIntensity = readFloat stream

            append lites l
        )
        return lites
    ),
    function ReadGLBS stream tag=
    (
        fseek stream tag.offset #seek_set
        local gbls = #()
        
        local nbr = tag.Size / 4
        
        for i=1 to nbr do 
        (
            local endFrame = (GriffonStudios_Helpers.RoundToFrame (readLong stream)) + 10
            append gbls endFrame
        )
        return gbls
        
    ),
    function ReadTXAN stream tag=
    (
        fseek stream tag.offset #seek_set
        local txans = #()
        local totalSize = tag.Size
        
        while ( totalSize > 0 ) do
        (
            local size = readLong stream
            totalSize -= size
            local txan = Warcraft3_Reforged_TXAN()
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KTAT" ) then txan.KTAT = Warcraft3_Reforged.ReadVector3Anim stream
                if( kg == "KTAR" ) then txan.KTAR = Warcraft3_Reforged.ReadQuatAnim stream
                if( kg == "KTAS" ) then txan.KTAS = Warcraft3_Reforged.ReadVector3Anim stream
            )
            if ( txan.KTAT == undefined ) then fseek stream -4 #seek_cur
            if ( txan.KTAR == undefined ) then fseek stream -4 #seek_cur
            if ( txan.KTAS == undefined ) then fseek stream -4 #seek_cur
            
            append txans txan
        )
        
        return txans
    ),
    function ReadRIBB stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.size
        local ribbs = #()
        
        while (totalSize > 0 ) do
        (
            local ribb = Warcraft3_Reforged_RIBB()
            
            local size = readLong stream
            totalSize -=size
            local unk = readLong stream
            ribb.name = GriffonStudios_Helpers.ReadFixedString stream 80
            ribb.id = readLong stream + 1
            ribb.parentBoneId = readLong stream + 1
            ribb.flags = readLong stream
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KGTR" ) then ribb.KGTR = Warcraft3_Reforged.ReadVector3Anim stream
                if( kg == "KGRT" ) then ribb.KGRT = Warcraft3_Reforged.ReadQuatAnim stream
                if( kg == "KGSC" ) then ribb.KGSC = Warcraft3_Reforged.ReadVector3Anim stream
            )
            
            if( ribb.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KGRT == undefined ) then fseek stream -4 #seek_cur
            
            ribb.staticHeightAbove = readFloat stream
            ribb.staticHeightBelow = readFloat stream
            ribb.staticAlpha = readFloat stream
            ribb.staticColor = Warcraft3_Reforged.ReadColor stream
            ribb.lifeSpan = readFloat stream
            ribb.textureId = readLong stream + 1
            ribb.emissionRate = readLong stream
            ribb.flipbookRows = readLong stream
            ribb.flipbookColumns = readLong stream
            ribb.mtlsId = readLong stream + 1
            ribb.gravity= readFloat stream
            
            for i=1 to 6 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KRHA" ) then ribb.KRHA = Warcraft3_Reforged.ReadFloatAnim stream -- heightAbove
                if( kg == "KRHB" ) then ribb.KRHB = Warcraft3_Reforged.ReadFloatAnim stream  -- heightBelow
                if( kg == "KRAL" ) then ribb.KRAL = Warcraft3_Reforged.ReadFloatAnim stream -- alpha
                if( kg == "KRCO" ) then ribb.KRCO = Warcraft3_Reforged.ReadColorAnim stream -- color
                if( kg == "KRTX" ) then ribb.KRTX = Warcraft3_Reforged.ReadLongAnim stream  -- texture
                if( kg == "KRVS" ) then ribb.KRVS = Warcraft3_Reforged.ReadFloatAnim stream -- visibility
            )
            if( ribb.KRHA == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRHB == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRAL == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRCO == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRTX == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRVS == undefined ) then fseek stream -4 #seek_cur
            
            append ribbs ribb
        )
        return ribbs
    ),
    function ReadPRE2 stream tag=
    (
        fseek stream tag.offset #seek_set
       
        local pre2s = #()
        local totalSize = tag.Size
        
        try (
                   
            while (totalSize > 0 ) do
            (
                local size = readLong stream
                local testPos = ftell stream
                
                totalSize -= size
                
                size -=4
                
                local pe = Warcraft3_Reforged_PRE2()
                local headerSize    = readLong stream -- always 96
                pe.name      = GriffonStudios_Helpers.ReadFixedString stream 80
                pe.id        = readLong stream + 1
                pe.parentId  = readLong stream + 1
                local flags     = readLong stream
                
                local flagSettings = Warcraft3_Reforged_PRE2_FLAGS()
                if (flags > 0) then 
                (
                    if ( (bit.and flags 0x00000001) > 0 ) then flagSettings.DONT_INHERIT_TRANSLATION = true
                    if ( (bit.and flags 0x00000002) > 0 ) then flagSettings.DONT_INHERIT_SCALING = true
                    if ( (bit.and flags 0x00000004) > 0 ) then flagSettings.DONT_INHERIT_ROTATION = true
                    if ( (bit.and flags 0x00000008) > 0 ) then flagSettings.BILLBOARDED = true
                    if ( (bit.and flags 0x00000010) > 0 ) then flagSettings.BILLBOARD_LOCK_X = true
                    if ( (bit.and flags 0x00000020) > 0 ) then flagSettings.BILLBOARD_LOCK_Y = true
                    if ( (bit.and flags 0x00000040) > 0 ) then flagSettings.BILLBOARD_LOCK_Z = true
                    if ( (bit.and flags 0x00000080) > 0 ) then flagSettings.GENOBJECT_MDLBONESECTION = true
                    if ( (bit.and flags 0x00000100) > 0 ) then flagSettings.GENOBJECT_MDLLIGHTSECTION = true
                    if ( (bit.and flags 0x00000200) > 0 ) then flagSettings.GENOBJECT_MDLEVENTSECTION = true
                    if ( (bit.and flags 0x00000400) > 0 ) then flagSettings.GENOBJECT_MDLATTACHMENTSECTION = true
                    if ( (bit.and flags 0x00000800) > 0 ) then flagSettings.GENOBJECT_MDLPARTICLEEMITTER2 = true
                    if ( (bit.and flags 0x00001000) > 0 ) then flagSettings.GENOBJECT_MDLHITTESTSHAPE = true
                    if ( (bit.and flags 0x00002000) > 0 ) then flagSettings.GENOBJECT_MDLRIBBONEMITTER = true
                    if ( (bit.and flags 0x00004000) > 0 ) then flagSettings.PROJECT = true
                    if ( (bit.and flags 0x00008000) > 0 ) then flagSettings.UNSHADED = true
                    if ( (bit.and flags 0x00010000) > 0 ) then flagSettings.SORT_PRIMITIVES_FAR_Z = true
                    if ( (bit.and flags 0x00020000) > 0 ) then flagSettings.LINE_EMITTER = true
                    if ( (bit.and flags 0x00040000) > 0 ) then flagSettings.PARTICLE_UNFOGGED = true
                    if ( (bit.and flags 0x00080000) > 0 ) then flagSettings.PARTICLE_USE_MODEL_SPACE = true
                    if ( (bit.and flags 0x00100000) > 0 ) then flagSettings.PARTICLE_INHERIT_SCALE = true
                    if ( (bit.and flags 0x00200000) > 0 ) then flagSettings.PARTICLE_INSTANT_VELOCITY_LIN = true
                    if ( (bit.and flags 0x00400000) > 0 ) then flagSettings.PARTICLE_0XKILL = true
                    if ( (bit.and flags 0x00800000) > 0 ) then flagSettings.PARTICLE_Z_VELOCITY_ONLY = true
                    if ( (bit.and flags 0x01000000) > 0 ) then flagSettings.PARTICLE_TUMBLER = true
                    if ( (bit.and flags 0x02000000) > 0 ) then flagSettings.PARTICLE_TAIL_GROWS = true
                    if ( (bit.and flags 0x04000000) > 0 ) then flagSettings.PARTICLE_EXTRUDE = true
                    if ( (bit.and flags 0x08000000) > 0 ) then flagSettings.PARTICLE_XYQUADS = true
                    if ( (bit.and flags 0x10000000) > 0 ) then flagSettings.PARTICLE_PROJECT = true
                    if ( (bit.and flags 0x20000000) > 0 ) then flagSettings.PARTICLE_FOLLOW = true
                )
                pe.flags = flagSettings
                
                for i=1 to 3 do
                (
                    local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                    if( kg == "KGTR" ) then pe.KGTR = Warcraft3_Reforged.ReadVector3Anim stream
                    if( kg == "KGRT" ) then pe.KGRT = Warcraft3_Reforged.ReadQuatAnim stream
                    if( kg == "KGSC" ) then pe.KGSC = Warcraft3_Reforged.ReadVector3Anim stream
                )
                
                if( pe.KGSC == undefined ) then fseek stream -4 #seek_cur
                if( pe.KGTR == undefined ) then fseek stream -4 #seek_cur
                if( pe.KGRT == undefined ) then fseek stream -4 #seek_cur

                pe.speed         = readFloat stream
                pe.variation     = readFloat stream
                pe.coneAngle      = readFloat stream
                pe.gravity       = readFloat stream

                pe.lifespan      = readFloat stream
                pe.emissionrate  = readFloat stream
               
                pe.length        = readFloat stream
                pe.width         = readFloat stream
                
                pe.emitterType   = readLong stream
                pe.rowCount      = readLong stream
                pe.colCount      = readLong stream
                pe.particleType  = readLong stream
                
                pe.tailLength    = readFloat stream
                pe.midTime       = readFloat stream
                
                local r = ( readFloat stream * 255 ) as integer
                local g = ( readFloat stream * 255 ) as integer
                local b = ( readFloat stream * 255 ) as integer
                
                pe.startColor    = color r g b
                
                local r = ( readFloat stream * 255 ) as integer
                local g = ( readFloat stream * 255 ) as integer
                local b = ( readFloat stream * 255 ) as integer
                
                pe.midColor      = color r g b
                
                local r = ( readFloat stream * 255 ) as integer
                local g = ( readFloat stream * 255 ) as integer
                local b = ( readFloat stream * 255 ) as integer
                
                pe.endColor      = color r g b
                
                pe.startAlpha    = readByte stream
                pe.midAlpha      = readByte stream
                pe.endAlpha      = readByte stream 

                pe.startSize    = readFloat stream
                pe.midSize      = readFloat stream
                pe.endSize      = readFloat stream

                pe.startLifespanUVAnim   = readLong stream
                pe.midLifespanUVAnim     = readLong stream
                pe.endLifespanUVAnim     = readLong stream
                pe.startDecayUVAnim      = readLong stream
                pe.midDecayUVAnim        = readLong stream
                pe.endDecayUVAnim        = readLong stream
                pe.startTailUVAnim       = readLong stream
                pe.midTailUVAnim         = readLong stream
                pe.endTailUVAnim         = readLong stream
                pe.startTailDecayUVAnim  = readLong stream
                pe.midTailDecayUVAnim    = readLong stream
                pe.endTailDecayUVAnim    = readLong stream
                pe.blendMode             = readLong stream
                pe.textureId             = readLong stream
                pe.replacableTextureId   = readLong stream 
                pe.priorityPlane         = readLong stream
                  
                /*
                    BASE = 0x0,
                    PLANE = 0x1,
                    SPHERE = 0x2,
                    SPLINE = 0x3,
                */

                for i=1 to 2 do
                (
                    local anim = GriffonStudios_Helpers.ReadFixedString stream 4
                    
                    if (anim == "KP2V" ) then pe.kp2v = Warcraft3_Reforged.ReadFloatAnim stream -- visibility
                    if (anim == "KP2E" ) then pe.kp2e = Warcraft3_Reforged.ReadFloatAnim stream -- emission
                    
                )
                if( pe.kp2v == undefined ) then fseek stream -4 #seek_cur
                if( pe.kp2e == undefined ) then fseek stream -4 #seek_cur
                
                local skip = size - ( (ftell stream )- testPos )
                
                Warcraft3_Reforged.SkipBytes stream skip
                
                append pre2s pe
            )
        )
        catch
        (
            /* old models fail on this... I don't care */
        )
        return pre2s
    ),
        
    /* BUILD
    
    */
    function BuildMODL=
    (
        local modl = mdx.modl
        --print modl
        local obj = GriffonStudios_Helpers.BuildBoundingBox modl.bbBox
        obj.name = modl.name
        
        freeze obj
        --hide obj
        return obj
    ),
   
    function BuildGEOS=
    (
        local geos = mdx.geos
        local modl = mdx.modl
        if (geos == undefined ) then return undefined
        
        local wireColor = color 128 128 128
        local uniqueId = 1
        for geo in geos do
        (
            
            if (Warcraft3_ImportAllLOD == false and geo.MATS.LOD != 0) then continue

            format "Building %\n" geo.MATS.Name
            
            local layerName = modl.name + " - LOD " + (geo.MATS.LOD as string)
            local layer = GriffonStudios_Helpers.CreateLayer layerName
            
            if (geo.MATS.LOD != 0 ) then layer.isHidden = true
            
            if (geo.MATS.LOD == 0) then wireColor = color 190 190 100
            if (geo.MATS.LOD == 1) then wireColor = color 64 164 64
            if (geo.MATS.LOD == 2) then wireColor = color 64 164 164
            if (geo.MATS.LOD == 3) then wireColor = color 0 128 255
            
            try (
                
                local v = geo.VRTX
                local n = geo.NRMS
                local f = geo.PVTX
                local uv = geo.UVS[1]
                local meshName = ( uniqueId as string ) + "_" + geo.MATS.Name
                geo.uniqueName = meshName
                local theMesh = mesh vertices:v vnorms:n name:meshName faces:f tverts:uv 

                theMesh.WireColor = wireColor
                
                buildTVFaces theMesh false
                for i = 1 to f.count do
                ( setTVFace theMesh i f[i] )
            
                layer.AddNode theMesh
                
                update theMesh
                resetXform theMesh
                
                maxOps.CollapseNodeTo theMesh 1 off
                
                geo.meshRef = theMesh
            )
            catch (
                print "ERROR occured in"
                print geo
                )
            uniqueId +=1
        )
    ),
    function BuildMTLS=
    (
        local mtls = mdx.mtls
        local texs = mdx.texs
        local modlName = mdx.modl.name
        local geos = mdx.geos
        
        if ( mtls == undefined ) then return undefined
        if ( Warcraft3_AssetFolder == undefined or Warcraft3_AssetFolder == "" ) then 
        (   
            format "[WARNING] Assets folder is not defined !\n"
            Warcraft3_AssetFolder = ""
        )
        format "Building Materials\n"

        for mtl in mtls do
        (
            local possibleName = modlName 
            for geo in geos do
            (
                if geo.MATS.LOD == 0 then
                (
                    
                    if geo.MATS.Id == mtl.Id then 
                    (
                        local parts = filterString geo.MATS.name ":"
                        
                        possibleName = parts[parts.count]
                        
                    )
                    
                )
            )
            local mat = WC3RefMaterial()
            mat.Name = possibleName + "_MAT_" + (mtl.id as string )
            
            if (mtl.lays.count > 0) then mat.filtermode = mtl.lays[1].filterMode
            
            mat.twoSided = mtl.twoSided
            mat.Unlit = mtl.ConstantColor
            /* TODO
                mat.envMap = off 
                mat.wrapwidth = off
                mat.wrapheight = off
                mat.nofog = off
            */
            mat.nodepthtest = mtl.SortPrimsFarZ
            mat.nodepthset = mtl.FullResolution

            
            for layer in mtl.lays do
            (
               -- print layer
                local textureId = layer.TextureId
                local parts = filterString texs[textureId].path @"\"
                local textureFile = Warcraft3_AssetFolder + texs[textureId].path + texs[textureId].fileNameOnly + ".dds"

                
                --print textureFile
                --if ( texs[textureId].fileNameOnly == "" or texs[textureId].fileNameOnly == undefined ) then continue

                case of 
                (
                    (layer.id == 1): ( 
                        mat.diffuse_map = Bitmaptexture fileName:textureFile
                        mat.alphamask_map = Bitmaptexture fileName:textureFile
                    )
                    (layer.id == 2): ( 
                        mat.normal_map = Bitmaptexture fileName:textureFile
                    )
                    (layer.id == 3): ( 
                        mat.orm_map = Bitmaptexture fileName:textureFile
                        mat.teamcolor_map = Bitmaptexture fileName:textureFile
                    )
                    (layer.id == 4): ( -- black ?? maybe emission ?
                        mat.emissive_map = Bitmaptexture fileName:textureFile
                        mat.emissive_alpha = layer.alpha * 100.0
                    )
                    (layer.id == 5): 
                    (
                        mat.replacable_map = Bitmaptexture fileName:textureFile
                    )
                    (layer.id == 6): ( -- refelection
                        mat.reflection_map = Bitmaptexture fileName:textureFile
                    )
                )
                
                
                showTextureMap mat true
                
                /* animated texture */
                if ( layer.KMTA != undefined ) then
                (
                    for anim in layer.KMTA.KG do
                    (
                        with animate on (
                            at time ( anim.Time + 10 )
                            (
                                mat.material_alpha = anim.Point * 100.0 --> max expects a percentage
                            )
                        )
                    )
                )
                
                /* animated texture */
                if ( layer.KMTE != undefined ) then
                (
                    for anim in layer.KMTE.KG do
                    (
                        with animate on (
                            at time ( anim.Time + 10 )
                            (
                                mat.emissive_alpha = anim.Point 
                            )
                        )
                    )
                )
                   
            )
            if( mtl.id < 25 ) then meditMaterials[mtl.id] = mat
            
            mtl.materialRef = mat
        )
        --return mtls
    ),
    function BuildATCH=
    (
        local atch  = mdx.atch
        local bpos  = mdx.bpos
        local boneList = mdx.bone
        
        if ( atch == undefined ) then return undefined
        format "Building Attachments\n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Attachments"
     
        sliderTime = 0f
        
        for a in atch do 
        (
            --local pnt = Point name:a.name box:off cross:on centermarker:off axistripod:off size:12
            local pnt = WC3RefAttachment name:a.name
            pnt.pos = bpos[a.id].matrix.row4
            
            layer.AddNode pnt
            if( a.parentBoneId>0) then 
            (
                local parentBone = boneList[a.parentBoneId].boneRef
                if( parentBone == undefined) then
                    parentBone = getnodebyname boneList[a.parentBoneId].name
                pnt.transform = parentbone.transform
                pnt.parent = parentBone
            )
            -- KGTR, KGRT, KGSC, KATV
            if ( a.KGRT != undefined ) then 
            (
                pnt.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = pnt.rotation.controller
                local q0 = dr.transform
                
                for anim in a.KGRT.KG do
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
                
                for anim in a.KGTR.KG do
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
                pnt.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = pnt.scale.controller
                local p0 = ds.transform
                
                for anim in a.KGSC.KG do
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
                
                for anim in a.KATV.KG do
                (
                    if ( anim.point == 0) then isVisibilityTrackRequired = true
                )
                
                if ( isVisibilityTrackRequired == true ) then
                (
                    pnt.Visibility = on
                    pnt.Visibility.controller = on_off()

                    for anim in a.KATV.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                pnt.Visibility = on
                            else
                                pnt.Visibility = off
                )
                
            )
        )
        
        
    ),
    function BuildBONE2=
    (
        if( mdx.bone == undefined ) then return undefined
        local boneList = mdx.bone
        local bpos = mdx.bpos
        local boneLayer = GriffonStudios_Helpers.CreateLayer "Bones"
        
        format "Building Bones\n"
        -- create the bones
        for b in boneList do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.setBoneEnable false 0
            
            b.boneRef = aBone
            
            boneLayer.AddNode aBone
        )
        
        for obj in boneList do
        (
            local b = obj.boneRef

            if bpos != undefined then 
            (
            
                local mtrx = bpos[obj.id].matrix
                
                --b.transform = mtrx
                
                b.pos = mtrx.translationpart
                
            )
        )
        
        -- build the hierarchy
        for b in boneList do
        (
            if ( b.ParentBoneId > 0 and b.ParentBoneId <= boneList.count ) then 
            (
                local parentBone = boneList[b.ParentBoneId].boneRef
                b.boneRef.parent = parentBone
            )
        )

        for objX in objects do
            addNewKey objX.controller 0
        
       -- apply bone animation
        local applyBoneAnim = true
        if applyBoneAnim == true then 
        for obj in boneList do
        (
            local b = obj.boneRef
            
            b.assumeSkinPose()

            if ( obj.KGRT != undefined ) then 
            (
               -- b.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                local prevTime = 0
                
                for anim in obj.KGRT.KG do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
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
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = b.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in obj.KGTR.KG do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point

                        if ( prevTime == t ) then continue else prevTime = t
                        
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
               -- b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in obj.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    
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
    function BuildSKIN =
    (
        local geos = mdx.geos
        local boneList = mdx.bone
        if ( geos == undefined or boneList == undefined ) then return undefined
        
        try(
            for geo in geos do
            (

                local msh = geo
                local obj = geo.meshRef

                format "Applying Skin modifier to %\n" obj.name
                
                if ( obj == undefined ) then continue
                
                local mshSkin = skin name:"Skin"
                mshSkin.bone_Limit = 4
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
    function BuildSEQS=
    (
        struct animTrackObj ( track, animFound )
        local seqs = mdx.seqs
        
        if ( seqs == undefined ) then return undefined
        format "Setting Animation Sequences\n"
        
        local animTracks = #()
        local nNoteTracks = numNoteTracks rootNode
        
        if ( Warcraft3_ConvertToSC2 == true ) then StarTools_Helpers.RenameSEQS seqs
        

        if(  nNoteTracks > 0 ) then
        (
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode (getNoteTrack rootNode 1)
        )
        
       
        if( numNoteTracks rootNode == 0 ) then
        (
            
            local animTrack1 = notetrack "AnimTrack1"
            local t = animTrackObj track:animTrack1 animFound:false
            addNoteTrack rootNode animTrack1
            append animTracks t
            
        )
        
        local prevEndFrame = 0                       
        
        for t=1 to seqs.count do
        (
            local seq = seqs[t]
            local theAnimTrack = animTracks[1].track --> always pick first one
            
            
            --- check if the startframe already existed on a track, if it does, create a new one
            if t>1 then
            (
                for trackObj in animTracks do
                (
                    trackObj.animFound = false
                    local keys = trackObj.track.keys
                    
                    for key in keys do
                    (
                        if ( key.Time == seq.startFrame ) then 
                        (
                            trackObj.animFound = true
                        )
                    )
                )
            )
            local newTrackRequired = true
            for trackObj in animTracks do
            (
                if ( trackObj.animFound == false ) then 
                (
                    newTrackRequired = false
                    theAnimTrack = trackObj.track
                    exit
                )
            )
            if newTrackRequired == true then (
                local animTrackName = "animTrack" + ( (animTracks.count + 1 ) as string)
                local newTrack = notetrack animTrackName
                addNoteTrack rootNode newTrack
                theAnimTrack = newTrack
                local t = animTrackObj track:newTrack animFound:false
                append animTracks t
            )
        
            
            local startNote = AddNewNoteKey theAnimTrack seq.startFrame
            local endNote = AddNewNoteKey theAnimTrack seq.endFrame
            
            local val = seq.name + "\r\n"
                  val += "rarity = " 	 + (seq.Rarity as string)    + "\r\n"
                  val += "moveSpeed = "  + (seq.MovementSpeed as string) + "\r\n"
                  val += "nonLoop = " 	 + (seq.Noloop as string)    + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + (seq.Priority as string)

           
            startNote.Value = val
            endNote.Value = val

            format "Anim track:%   Anim:% (%-%)\n" theAnimTrack.name seq.name seq.startFrame seq.endFrame
			
        )
    ),
    function BuildCLID2=
    (
        local clid = mdx.clid
        local bpos = mdx.bpos
        local layer = GriffonStudios_Helpers.CreateLayer "Collision Objects"
        
        for cl in clid do
        (
            if cl.boundingtype == 0 then
            (
                local p1 = cl.pos
                local p2 = [cl.radius, cl.height, cl.something]
                local mtrx = bpos[cl.id].matrix
                local capsul = GriffonStudios_Helpers.drawLineBetweenTwoPoints p1 p2
                centerpivot capsul
                capsul.name = cl.name
                --capsul.pos = mtrx.row4
                capsul.transform = mtrx
                capsul.boxmode = true
                
                
                if ( cl.KGRT != undefined ) then 
                (
                    
                    for anim in cl.KGRT.KG do
                    (
                        local t = anim.time + 10
                        local q = anim.Point
                        
                        with animate on at time t in coordsys mtrx capsul.rotation = q
                    )
                        
                )
                
                if ( cl.KGTR != undefined ) then 
                (

                    local prevTime = 0
                    for anim in cl.KGTR.KG do
                    (
                        local t = anim.time + 10
                        local p = anim.Point
                        
                        if ( prevTime == t ) then continue else prevTime = t
                        
                        with animate on at time t in coordsys mtrx capsul.pos = p
                    )
                        
                )
                
                freeze capsul
                layer.addnode capsul
            )
            
        )  
    ),
    function BuildCLID=
    (
        local clid = mdx.clid
        local bpos = mdx.bpos
        
        if (clid == undefined ) then return undefined
        format "Buidling Collision Objects\n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Collision Objects"
        for cl in clid do
        (
            local mtrx = bpos[cl.id].matrix
        
            local height = cl.height
            local radius = cl.radius / 2.0
            
            
            --format "BoundingType (%) : % \n" cl.name cl.boundingType
            
            local capsul = capsule name:cl.name length:height radius:radius boxmode:on 
            capsul.wirecolor = color 0 64 255
            capsul.renderable = off
            capsul.castShadows = off
            capsul.receiveshadows = off
            capsul.ApplyAtmospherics = off
            capsul.inheritVisibility = off
            capsul.primaryVisibility = off
            capsul.secondaryVisibility = off

            if (cl.boundingType == 0 ) then
            (
                local isDone = false
                if (cl.name == "B_KGS_Root"  ) then 
                (
                    capsul.height = height * 4.0 - ( radius * 2.0 )
                    capsul.radius = radius * 2.0
                    centerpivot capsul
                    capsul.wirecolor = color 255 64 0
                    isDone = true
                )
                if ( cl.name == "B_KGS_Head" ) then 
                (
                    centerpivot capsul
                    isDone = true
                ) 
                
                if ( isDone == false ) then
                (
                    rotate capsul (angleaxis 180 [0,1,0])
                    resetXform capsul
                    maxOps.CollapseNodeTo capsul 1 off
                )
            
            )
            if (cl.boundingType == 2 ) then
            (
                centerpivot capsul
                
            )

                
            capsul.transform = mtrx
            
            
            if ( cl.KGRT != undefined ) then 
            (
                
                for anim in cl.KGRT.KG do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx capsul.rotation = q
                )
                    
            )
            
            if ( cl.KGTR != undefined ) then 
            (

                local prevTime = 0
                for anim in cl.KGTR.KG do
                (
                    local t = anim.time + 10
                    local p = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on at time t in coordsys mtrx capsul.pos = p
                )
                    
            )
            
            freeze capsul
            layer.addnode capsul
        )
    ),
    function BuildGEOA=
    (
        local geoa = mdx.geoa
        local geos = mdx.geos
        
        if( geoa == undefined ) then return undefined 
        format "Applying Mesh Alpha Animations \n"
        for a in geoa do
        (
            local theMesh = geos[a.GeoId].meshRef
            if ( theMesh == undefined ) then continue
            local isVisibilityTrackRequired = false -- by default evertythng is 1
            
            if a.KGAO == undefined then continue
            
            for anim in a.KGAO.KG do
            (
                if ( anim.point == 0) then isVisibilityTrackRequired = true
            )
            
            if ( isVisibilityTrackRequired == true ) then
            (
                theMesh.Visibility = on
                theMesh.Visibility.controller = on_off()

                for anim in a.KGAO.KG do 
                    with animate on at time ( anim.Time + 10 )
                        if (anim.point == 1) then 
                            theMesh.Visibility = on
                        else
                            theMesh.Visibility = off
            )
            
        )
        
    ),
    function BuildEVTS=
    (
        local evts = mdx.evts
        
        format "Building Events\n"
        if (evts == undefined ) then return undefined
        local layer = GriffonStudios_Helpers.CreateLayer "Events"
        
        for evt in evts do
        (
            local pnt = WC3RefEvent()  -- point name:evt.Name
            
            pnt.Name = evt.name

            for key in evt.KEVT do
                pnt.AddKey key
            
            evt.objRef = pnt
            layer.AddNode pnt
        )
        
    ),
    function BuildPIVT=
    (
        local pivts = mdx.pivt
        local boneList = mdx.bone
        local atch = mdx.atch
        local evts = mdx.evts
        local clid = mdx.clid
        local lite = mdx.lite
        local corn = mdx.corn
        local ribb = mdx.ribb
        
        format "Building Pivots \n"
        if ( pivts == undefined ) then return undefined
        
        local layerBones = GriffonStudios_Helpers.CreateLayer "PIVT - Bones"
        local layerAttachments = GriffonStudios_Helpers.CreateLayer "PIVT - Attachments"
        local layerEvents = GriffonStudios_Helpers.CreateLayer "PIVT - Events"
        local layerCol = GriffonStudios_Helpers.CreateLayer "PIVT - Collision Objects"
        local layerCorn = GriffonStudios_Helpers.CreateLayer "PIVT - Popcorn Effects"
        local layerRibb = GriffonStudios_Helpers.CreateLayer "PIVT - Ribbon Emitters"
        
        for pivt in pivts do
        (
            local pName = "Unknown " + ((pivt.id as integer) as string )
            local p = point name:pName pos:pivt.pivotPoint size:5
            
            pivt.objRef = p
            setUserProp p "Type" "PIVOT" 
            p.wirecolor = gray
            
            if ( boneList != undefined ) then
            for b in boneList do 
                if ( b.Id == pivt.Id ) then 
                ( 
                    p.Name = "PIVOT - " + b.name
                    layerBones.AddNode p
                    -- if ( b.boneRef != undefined ) then with animate on at time 0 b.boneRef.Pos = pivt.pivotPoint
                )
                
            if ( atch != undefined ) then
            for a in atch do 
                if ( a.Id == pivt.Id ) then 
                ( 
                    p.Name = "PIVOT - " + a.name
                    layerAttachments.AddNode p
                )
                
            if ( evts != undefined ) then
            for ev in evts do 
                if ( ev.Id == pivt.Id ) then 
                ( 
                    p.Name = "PIVOT - " + ev.name
                    layerEvents.AddNode p
                    if ( ev.objRef != undefined ) then ev.objRef.Pos = pivt.pivotPoint
                )
            
            if ( clid != undefined ) then
            for c in clid do 
                if ( c.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + c.name
                    layerCol.AddNode p
                    if ( c.objRef != undefined ) then with animate on at time 0 c.objRef.Pos = pivt.pivotPoint
                )
            
            if ( lite != undefined ) then 
            for l in lite do
                if ( l.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + l.name
                    layerCol.AddNode p
                )
            
            if ( corn != undefined ) then 
            for c in corn do
                if ( c.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + c.name
                    layerCorn.AddNode p
                )
            
            if ( ribb != undefined ) then
            for r in ribb do 
                if ( r.Id == pivt.Id ) then 
                (
                    p.Name = "PIVOT - " + r.name
                    layerRibb.AddNode p
                )
                
            if ( substring p.Name 1 7 == "Unknown" ) then format "[Warning] Object with Id = % not found \n" ( pivt.id as integer)
        )
        
        layerBones.IsHidden = true
        layerAttachments.IsHidden = true
        layerEvents.IsHidden = true
        layerCol.IsHidden = true
        layerRibb.IsHidden = true
        layerCorn.IsHidden = true
    ),
    function BuildFAFX=
    (
        local fafx = mdx.fafx
        format "Building Facial Effects\n"
        if ( fafx == undefined ) then return undefined
        local layer = GriffonStudios_Helpers.CreateLayer "Facial Effects"
 
        for f=1 to fafx.Count do
        (
            local fafxObj = WC3RefFaceFX()   
            
            fafxObj.Name = fafx[f].Name
            fafxObj.fileName = fafx[f].ExternalFileName
            
            layer.AddNode fafxObj
        )
        
        
    ),
    function BuildCAMS=
    (
        local cams = mdx.cams
        format "Building Cameras \n"
        if (cams == undefined ) then return undefined
        
        local layer = GriffonStudios_Helpers.CreateLayer "Cameras"
        for i=1 to cams.count do
        (   
            local c = cams[i]
            local targetName = c.name + ".Target." + ( i as string)
            local camName = c.name + ( i as string)
            local target = Targetobject pos:c.targetPos name:targetName wirecolor:red 
            local cam = Targetcamera fov:c.FOV farclip:c.farClip nearclip:c.nearClip pos:c.pos name:camName wirecolor:yellow target:target
            layer.AddNode target
            layer.AddNode cam
            local prevPos = c.pos
            local prevTPos = c.targetPos
            
            if( c.KCTR != undefined) then 
                for anim in c.KCTR.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                        cam.pos = prevPos + anim.Point

                )

            if( c.KTTR != undefined ) then 
                for anim in c.KTTR.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                        target.pos = prevTPos + anim.Point
                )

            if( c.KCRL != undefined ) then 
                for anim in c.KCRL.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                    (
                        target.rotation = anim.Point
                        cam.rotation = anim.point
                    )
                )

                
        )
        
        
    ),
    function BuildLITE=
    (
        local lites = mdx.lite
        local pivots = mdx.pivt
        format "Building Lights \n"
        if ( lites == undefined ) then return undefined
        
        for lite in lites do
        (
            /*
                0x0: Omni
                0x1: Directional
                0x2: Ambient
                0x3: Default
            */
            local l = undefined
            
            local layer = GriffonStudios_Helpers.CreateLayer "Lights"
            
            if ( lite.Type == 0 ) then 
                l = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd

            if ( lite.Type == 1 ) then 
                l = DirectionalLight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( lite.Type == 2 ) then
            (
                ambientcolor = lite.ambColor
                lightLevel = lite.ambIntensity
            )

            if ( lite.Type > 2 ) then 
                l = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( l != undefined ) then 
            (
                layer.addnode l
                
                if( lite.KGRT != undefined ) then 
                    for anim in lite.KGRT.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) in coordsys world
                            l.rotation = anim.Point
                    )
                
                for p in pivots do
                    if( p.Id == lite.Id ) then 
                    (
                        l.pos = p.PivotPoint
                        exit
                    )
                local prevPos = l.pos  
                if( lite.KGTR != undefined) then 
                    for anim in lite.KGTR.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) 
                            l.pos =  prevPos + anim.Point

                    )

                if( lite.KGSC != undefined ) then 
                    for anim in lite.KGSC.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) 
                            l.scale = anim.Point
                    )

            )
        )
    ),
    function BuildRIBB=
    (
        local ribb = mdx.ribb
        local boneList = mdx.bone
        local mtls = mdx.mtls
        
        if (ribb == undefined ) then return undefined
        
        format "Building ribbons\n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Ribbons"
        
        for r in ribb do
        (
            local ribbon = undefined
            try ( ribbon = WC3RefRibbon() )
            catch ( format "WC3ReforgedRibbon plugin not found\n"; exit )

            layer.addNode ribbon
            
            ribbon.name = r.name
            if ( boneList != undefined ) then 
            (
                if ( r.ParentBoneId > 0 ) then (
                    ribbon.transform = boneList[r.parentBoneId].boneRef.transform
                    ribbon.parent = boneList[r.parentBoneId].boneref
                )
            )
            ribbon.staticHeightAbove = r.staticHeightAbove
            ribbon.staticHeightBelow = r.staticHeightBelow
            ribbon.staticAlpha = r.staticAlpha
            ribbon.staticColor = r.staticColor
            ribbon.lifeSpan = r.lifeSpan
            ribbon.emissionRate = r.emissionRate
            ribbon.flipbookRows = r.flipbookRows
            ribbon.flipbookColumns = r.flipbookColumns
            ribbon.gravity = r.gravity
            if ( mtls != undefined) then ribbon.mtlsId = mtls[r.mtlsId].materialRef
            
            -- animation time !
            -- heightAbove
            if ( r.KRHA != undefined ) then
            for anim in r.KRHA.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticHeightAbove = p
            )
            -- heightBelow
            if ( r.KRHB != undefined ) then
            for anim in r.KRHB.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticHeightBelow = p
            )
            -- alpha
            if ( r.KRAL != undefined ) then
            for anim in r.KRAL.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticAlpha = p
            )
            -- color
            if ( r.KRCO != undefined ) then
            for anim in r.KRCO.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticColor = p
            )
            -- texture
            if ( r.KRTX != undefined ) then
            for anim in r.KRTX.KG do
            (
                local t = anim.time + 10
                local p = anim.point + 1
                with animate on at time t ribbon.mtlsId = mtls[p].materialRef
            )
            -- visibility
            if ( r.KRVS != undefined ) then
            (
                local isVisibilityTrackRequired = false
                for anim in r.KRVS.KG do
                (
                    if ( anim.point == 0) then isVisibilityTrackRequired = true
                )
                if ( isVisibilityTrackRequired == true ) then
                (
                    ribbon.Visibility = on
                    ribbon.Visibility.controller = on_off()

                    for anim in r.KRVS.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                ribbon.Visibility = on
                            else
                                ribbon.Visibility = off
                )
            )
            
            
        )
    
        
    ),
    function BuildPRE2=
    (
        local particleEmitters = mdx.pre2
        local boneList = mdx.bone
        local textures = mdx.texs
        format "Building Particle Emitters \n"
        if( particleEmitters == undefined ) then return undefined
        
        local layer = GriffonStudios_Helpers.CreateLayer "Emitters"
        
        for pe in particleEmitters do
        (
            local emitter = WC3RefEmitter()
            layer.addNode emitter
            emitter.name =  pe.name
            if ( boneList != undefined ) then 
            (
                if pe.ParentId > 0 then 
                (
                    emitter.transform = boneList[pe.ParentId].boneRef.transform
                    emitter.parent = boneList[pe.ParentId].boneRef
                )
            )
            if (pe.Flags != undefined ) then
            (
                emitter.DONT_INHERIT_TRANSLATION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.DONT_INHERIT_TRANSLATION
                emitter.DONT_INHERIT_SCALING = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.DONT_INHERIT_SCALING
                emitter.DONT_INHERIT_ROTATION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.DONT_INHERIT_ROTATION
                emitter.BILLBOARDED = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARDED
                emitter.BILLBOARD_LOCK_X = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_X
                emitter.BILLBOARD_LOCK_Y = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_Y
                emitter.BILLBOARD_LOCK_Z = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_Z
                emitter.GENOBJECT_MDLBONESECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLBONESECTION
                emitter.GENOBJECT_MDLLIGHTSECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLLIGHTSECTION
                emitter.GENOBJECT_MDLEVENTSECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLEVENTSECTION
                emitter.GENOBJECT_MDLATTACHMENTSECTION = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLATTACHMENTSECTION
                emitter.GENOBJECT_MDLPARTICLEEMITTER2 = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLPARTICLEEMITTER2
                emitter.GENOBJECT_MDLHITTESTSHAPE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLHITTESTSHAPE
                emitter.GENOBJECT_MDLRIBBONEMITTER = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLRIBBONEMITTER
                emitter.PROJECT = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PROJECT
                emitter.UNSHADED = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.UNSHADED
                emitter.SORT_PRIMITIVES_FAR_Z = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.SORT_PRIMITIVES_FAR_Z
                emitter.LINE_EMITTER = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.LINE_EMITTER
                emitter.PARTICLE_UNFOGGED = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_UNFOGGED
                emitter.PARTICLE_USE_MODEL_SPACE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_USE_MODEL_SPACE
                emitter.PARTICLE_INHERIT_SCALE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_INHERIT_SCALE
                emitter.PARTICLE_INSTANT_VELOCITY_LIN = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_INSTANT_VELOCITY_LIN
                emitter.PARTICLE_0XKILL = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_0XKILL
                emitter.PARTICLE_Z_VELOCITY_ONLY = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_Z_VELOCITY_ONLY
                emitter.PARTICLE_TUMBLER = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_TUMBLER
                emitter.PARTICLE_TAIL_GROWS = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_TAIL_GROWS
                emitter.PARTICLE_EXTRUDE = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_EXTRUDE
                emitter.PARTICLE_XYQUADS = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_XYQUADS
                emitter.PARTICLE_PROJECT = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_PROJECT
                emitter.PARTICLE_FOLLOW = GriffonStudios_Helpers.IsUndefinedBoolean pe.Flags.PARTICLE_FOLLOW

            )
            emitter.speed = pe.speed  
            emitter.variation = pe.variation 
            emitter.coneAngle = pe.coneAngle / 2.0 
            emitter.gravity = pe.gravity 
            emitter.lifespan = pe.lifespan 
            emitter.emissionRate = pe.emissionrate 
            emitter.length = pe.length 
            emitter.width = pe.width  
            emitter.emitterType = pe.emitterType 
            emitter.rowCount = pe.rowCount 
            emitter.colCount = pe.colCount 
            emitter.particleType = pe.particleType + 1
            emitter.tailLength = pe.tailLength 
            emitter.midTime = pe.midTime 
            emitter.startColor  = pe.startColor 
            emitter.midColor  = pe.midColor 
            emitter.endColor  = pe.endColor 
            emitter.startAlpha  = pe.startAlpha 
            emitter.midAlpha  = pe.midAlpha 
            emitter.endAlpha  = pe.endAlpha 
            emitter.startSize  = pe.startSize 
            emitter.midSize  = pe.midSize 
            emitter.endSize  = pe.endSize 
            emitter.startLifespanUVAnim  = pe.startLifespanUVAnim 
            emitter.midLifespanUVAnim  = pe.midLifespanUVAnim 
            emitter.endLifespanUVAnim  = pe.endLifespanUVAnim 
            emitter.startDecayUVAnim  = pe.startDecayUVAnim 
            emitter.midDecayUVAnim  = pe.midDecayUVAnim 
            emitter.endDecayUVAnim  = pe.endDecayUVAnim 
            emitter.startTailUVAnim  = pe.startTailUVAnim 
            emitter.midTailUVAnim  = pe.midTailUVAnim 
            emitter.endTailUVAnim  = pe.endTailUVAnim 
            emitter.startTailDecayUVAnim = pe.startTailDecayUVAnim 
            emitter.midTailDecayUVAnim  = pe.midTailDecayUVAnim 
            emitter.endTailDecayUVAnim  = pe.endTailDecayUVAnim 
            emitter.blendMode  = pe.blendMode 
            emitter.priorityPlane  = pe.priorityPlane 
            emitter.replacableTextureId  = pe.replacableTextureId  + 1
            emitter.texture = textures[pe.TextureId + 1].path  + textures[pe.TextureId + 1].fileNameOnly + ".dds"


            if( pe.KP2E != undefined) then
                for anim in pe.KP2E do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.emissionRate = anim.Point

            if( pe.KGRT != undefined) then 
                for anim in pe.KGRT.KG do
                    with animate on at time ( anim.Time + 10 )  in coordsys parent 
                        emitter.rotation = anim.Point

            local prevPos = [0,0,0]
            if(emitter.parent != undefined ) then prevPos = emitter.parent.pos
            if( pe.KGTR != undefined) then 
                for anim in c.KGTR.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.pos = prevPos + anim.Point
            
           
            if( pe.KGSC != undefined) then 
                for anim in pe.KGSC.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.scale = anim.Point
            
            if( pe.KP2V != undefined) then
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in pe.KP2V.KG do
                    if ( anim.point == 0) then isVisibilityTrackRequired = true

                if ( isVisibilityTrackRequired == true ) then
                (
                    emitter.Visibility = on
                    emitter.Visibility.controller = on_off()

                    for anim in pe.KP2V.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                emitter.Visibility = on
                            else
                                emitter.Visibility = off
                ) 
            )



        )
        
    ),
    function BuildCORN=
    (
        local corn = mdx.corn
        local boneList = mdx.bone
        
        format "Building PopCorn \n"
        if( corn == undefined ) then return undefined
        
        local layer = GriffonStudios_Helpers.CreateLayer "Popcorn"
        
        for c in corn do
        (
            local cObj = WC3RefPopCorn()
            layer.addnode cObj
            cObj.Name = c.Name
            
            local path = getFilenamePath c.FileName
            local fileNameOnly = getfilenamefile c.fileName
            
            cObj.FileName = path + fileNameOnly + ".pkb"
            
            for prop in c.Properties do
            (
                local parts = filterString prop "="
                
                if (parts[1] == "Always" and parts[2] == "On" )  then cObj.Always = true
                if (parts[1] == "Death" and parts[2] == "On" )  then cObj.Death = true
                if (parts[1] == "Dissipate" and parts[2] == "On" )  then cObj.Dissipate = true
                if (parts[1] == "Portrait" and parts[2] == "On" )  then cObj.Portrait = true
            )
    
            if ( c.ParentId > 0 ) then
                if ( boneList != undefined) then
                    if ( boneList[c.ParentId].boneRef != undefined ) then cObj.Parent = boneList[c.ParentId].boneRef

            if( c.KGRT != undefined) then 
                for anim in c.KGRT.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.rotation = anim.Point

            if( c.KGTR != undefined) then 
                for anim in c.KGTR.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.pos = anim.Point
            
            if( c.KGSC != undefined) then 
                for anim in c.KGSC.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.scale = anim.Point
            
            if( c.KPPV != undefined) then
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in c.KPPV.KG do
                    if ( anim.point == 0) then isVisibilityTrackRequired = true

                if ( isVisibilityTrackRequired == true ) then
                (
                    cObj.Visibility = on
                    cObj.Visibility.controller = on_off()

                    for anim in c.KPPV.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                cObj.Visibility = on
                            else
                                cObj.Visibility = off
                ) 
            )
                    
                
        )
        
        
    ),
    function AssignMTLS=
    (
        try
        (
            local geos = mdx.geos
            local mtls = mdx.mtls
            for item in geos do
            (
                local m = item.meshRef
                if m !=undefined then 
                    if mtls != undefined then 
                    (
                        m.material = mtls[item.MATS.ID].MaterialRef
                        showtexturemap m.material true
                    )
            )  
        )catch()
    ),
    /*
        MAIN IMPORT
    */
    function Import file=
    (
        fileIn "GriffonStudios_Helpers.ms"
        struct wc3_reforged_mdx ( TAGS, VERS, MODL, SEQS, MTLS, TEXS, GEOS, BONE, ATCH, CLID, BPOS, GEOA, EVTS, PIVT, FAFX, CAMS, CORN, LITE, GLBS, TXAN, RIBB, PRE2)

        mdx = wc3_reforged_mdx()
        
        local workingDir = getdir #temp
        local iniFile = workingDir + "\\wc3ref.config"
        local assetFolder = getinisetting iniFile "Warcraft3Reforged" "AssetFolder"
        Warcraft3_AssetFolder = assetFolder   
        
        
        ClearListener()
        print file
        
        local startedAt = timestamp()
        
        if ( file == undefined ) then  return undefined 
        if ( doesFileExist file == false ) then ( throw("File does not exist!"); return undefined )
        
        SetWaitCursor()
        
        local stream = fOpen file "rb"
        local streamLen = GriffonStudios_Helpers.GetStreamLength stream
        if (wc3_debug) then print streamLen
        mdx.tags = Warcraft3_Reforged.ReadTags stream streamLen
        
        if (wc3_debug) then for t in mdx.tags do print t
        
        -- VERS // version
        for tag in mdx.tags do 
        (
            if( tag.Name == "VERS" ) then 
            (
                mdx.vers = Warcraft3_Reforged.ReadVERS stream tag
                if ( mdx.vers < 900 ) then 
                (
                    throw( "Incorrect version, found " + (mdx.vers as string) + ", should be at least 900")
                )
            )
        )
        -- read tag by tag
        for tag in mdx.tags do
        (
            format "Processing %\n" tag.name
            -- MODL // model
            if( tag.Name == "MODL" ) then mdx.modl = Warcraft3_Reforged.ReadMODL stream tag
            -- SEQS // animation sequences
            if( tag.Name == "SEQS" ) then mdx.seqs = Warcraft3_Reforged.ReadSEQS stream tag
            -- MTLS // materials
            if( tag.Name == "MTLS" ) then mdx.mtls = Warcraft3_Reforged.ReadMTLS stream tag                
            -- TEXS // texture names
            if( tag.Name == "TEXS" ) then mdx.texs = Warcraft3_Reforged.ReadTEXS stream tag
            -- GEOS // geosets
            if( tag.Name == "GEOS" ) then mdx.geos = Warcraft3_Reforged.ReadGEOS stream tag
            -- BONE // bones
            if( tag.Name == "BONE" ) then mdx.bone = Warcraft3_Reforged.ReadBONE stream tag
            -- ATCH // attachments
            if( tag.Name == "ATCH" ) then mdx.atch = Warcraft3_Reforged.ReadATCH stream tag 
            -- CLID // colission 
            if( tag.Name == "CLID" ) then mdx.clid = Warcraft3_Reforged.ReadCLID stream tag
            -- BPOS // binding position
            if( tag.Name == "BPOS" ) then mdx.bpos = Warcraft3_Reforged.ReadBPOS stream tag
            -- GEOA // geoset animation
            if( tag.Name == "GEOA" ) then mdx.geoa = Warcraft3_Reforged.ReadGEOA stream tag
            -- EVTS // events
            if( tag.Name == "EVTS" ) then mdx.evts = Warcraft3_Reforged.ReadEVTS stream tag
            -- PIVT // pivots
            if( tag.Name == "PIVT" ) then mdx.pivt = Warcraft3_Reforged.ReadPIVT stream tag
            -- FAFX // facial effects
            if( tag.Name == "FAFX" ) then mdx.fafx = Warcraft3_Reforged.ReadFAFX stream tag
            -- CAMS // camera
            if( tag.Name == "CAMS" ) then mdx.cams = Warcraft3_Reforged.ReadCAMS stream tag
            -- CORN // external particle effects
           if( tag.Name == "CORN" ) then mdx.corn = Warcraft3_Reforged.ReadCORN stream tag
            -- LITE // lights
            if( tag.Name == "LITE" ) then mdx.lite = Warcraft3_Reforged.ReadLITE stream tag
            -- GLBS // globals
            if( tag.Name == "GLBS" ) then mdx.glbs = Warcraft3_Reforged.ReadGLBS stream tag
            -- TXAN // texture animations
            if( tag.Name == "TXAN" ) then mdx.txan = Warcraft3_Reforged.ReadTXAN stream tag
            -- RIBB // ribbon emitters
            if( tag.Name == "RIBB" ) then mdx.ribb = Warcraft3_Reforged.ReadRIBB stream tag
            -- PRE2 // particle emitter
            if( tag.Name == "PRE2" ) then mdx.pre2 = Warcraft3_Reforged.ReadPRE2 stream tag
            
            -- TODO PREM // particle emitters    
            
        )
        
        if ( wc3_debug ) then (
            gModel      = mdx.geos
            gCollisions = mdx.clid
            gBpos       = mdx.bpos
            gBones      = mdx.bone

        )

        if ( wc3_debug_build ) then
        (
                Warcraft3_Reforged.BuildMODL()  --> build global bounding box
                Warcraft3_Reforged.BuildBONE2() --> build bones, bone structure and animation
                Warcraft3_Reforged.BuildGEOS()
                Warcraft3_Reforged.BuildSKIN()  --> apply vertex weights
                Warcraft3_Reforged.BuildSEQS()  --> build animation sequences so we can select them in the animation selector
                Warcraft3_Reforged.BuildATCH()  --> build attachment points
                Warcraft3_Reforged.BuildCLID2()  --> build collision objects
                Warcraft3_Reforged.BuildMTLS()  --> build the materials based on the textures
                Warcraft3_Reforged.AssignMTLS() --> assign the materials to the correct meshes
                Warcraft3_Reforged.BuildGEOA()  --> build alpha animation of the mesh
                Warcraft3_Reforged.BuildEVTS()  --> build events
                Warcraft3_Reforged.BuildFAFX()  --> build facial effects
                Warcraft3_Reforged.BuildCAMS()  --> build cameras
                Warcraft3_Reforged.BuildLITE()  --> build lites
                -- Warcraft3_Reforged.BuildPIVT()  --> build pivots
                Warcraft3_Reforged.BuildRIBB()  --> build ribbon emitters
                Warcraft3_Reforged.BuildPRE2()  --> build particle emitters
                Warcraft3_Reforged.BuildCORN()  --> build popcorn emitters
        )
        fclose stream

        if (mdxConvertToSC2AnimationNames == true ) then
        (
            StarTools_Helpers.ConvertAttachmentPoints()
            StarTools_Helpers.ConvertHitTestBoxes()
            StarTools_Helpers.ConvertToBoundingSphere collBox "Vol_Shield"
            
        )

        mdx = undefined
        gc()
        local endedAt = timestamp()
        setArrowCursor() 
        txt = "DONE (import took " + (((endedAt - startedAt) / 1000.0 as integer ) as string ) + " seconds )" 
        messagebox txt
        
        clearSelection()
        
    )
)

/*

*/
if ( ViewPortAttachmentPointDisplay != undefined ) then 
	UnregisterRedrawViewsCallback ViewPortAttachmentPointDisplay
	
function ViewPortAttachmentPointDisplay=
(
            
    gw.setTransform ( matrix3 1 )
    for obj in objects where 
        ( classof obj == WC3RefAttachment and obj.ishidden == false and obj.isfrozen == false ) do
    (
        gw.text ( obj.pos + [0, 0, 10] ) ( obj.name as string ) color:Yellow
    )
    gw.updateScreen()
    
)
RegisterRedrawViewsCallback ViewPortAttachmentPointDisplay

--ClearListener()
--wc3_debug = true
--wc3_debug_build = true
-- file = @"F:\Blizzard\Warcraft - Reforged\Extracted\Assets\units\human\peasant\peasant.mdx"
--Warcraft3_Reforged.Import file 
