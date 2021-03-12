struct Warcraft_3_Tools_Read
(
    function ReadFloatAnim stream=
    (
        struct WC3_ANIM ( numPts, LineType, ParentId, KG )  
        struct WC3_KG   ( Time, Point, inTan, outTan, LineType ) 
        
        local anim = WC3_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3_KG()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
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
        struct WC3_ANIM ( numPts, LineType, ParentId, KG )  
        struct WC3_KG   ( Time, Point, inTan, outTan, LineType ) 
        
        local anim = WC3_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3_KG()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
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
        struct WC3_ANIM ( numPts, LineType, ParentId, KG )  
        struct WC3_KG   ( Time, Point, inTan, outTan, LineType ) 
        
        local anim = WC3_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.parentId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3_KG()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
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
    function ReadTAGS stream streamLen=
    (
        local tags = #() 
        local mainTag = Warcraft3_Reforged_TAG()

        mainTag.Name = _helper.ReadFixedString stream 4
        mainTag.Offset = 0
        mainTag.Size = 0
        
        local currentStreamPos = ftell stream
        local streamLen = _helper.GetStreamLength stream
        
        while (currentStreamPos < streamLen ) do
        (
            local tag = Warcraft3_Reforged_TAG()
            
            tag.Offset = ftell stream + 8 -- the +8 indicates where the data starts
            tag.Name = _helper.ReadFixedString stream 4
            tag.Size = ReadLong stream
            
            _helper.SkipBytes stream tag.Size

            currentStreamPos = ftell stream
            
            --if ( _debug_read ) then print tag
            append tags tag
        )
        return tags
    ),
    function ReadVERS stream tag=
    (
        fseek stream tag.Offset #seek_set
        local version = readLong stream
        if _debug_read then Format " - %\n" version
            
        if version != 800 then throw format "Unsupported version found, % should be 800\n" version
        return version
        
    ),
    function ReadMODL stream tag=
    (
        fseek stream tag.offset #seek_set
        local name = _helper.ReadFixedString stream 80
        if _debug_read then Format " - %\n" name
        return name
    ),
    function ReadSEQS stream tag=
    (
        struct WC3_SEQS
            ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity, Priority, Default, BBox )
        
        fseek stream tag.offset #seek_set
        
        local nbrSeqs = tag.size / 132
        local seqs = #()
        
        for i=1 to nbrSeqs do
        (
            local seq = WC3_SEQS()
            seq.Name = _helper.ReadFixedString stream 80
            
            local originalStartFrame = readLong stream
            local originalEndFrame = readLong stream

            seq.StartFrame    = ( _helper.RoundToFrame ( originalStartFrame ) ) + 10
            seq.EndFrame      = ( _helper.RoundToFrame ( originalEndFrame ) ) + 10
            seq.MovementSpeed = readFloat stream
            seq.NoLoop        = readLong stream
            seq.Rarity        = readFloat stream
            seq.Default       = readlong stream
            seq.Priority      = readFloat stream
            
            seq.BBox = #([readfloat stream,readfloat stream,readfloat stream], [readfloat stream,readfloat stream,readfloat stream] )

            if _debug_read then format " -  %\n" seq
            append seqs seq
        )

        return seqs
        
    ),
    function ReadGLBS stream tag=
    (
        fseek stream tag.offset #seek_set
        local gbls = #()
        
        local nbr = tag.Size / 4
        
        for i=1 to nbr do 
        (
            local endFrame = (_helper.RoundToFrame (readLong stream)) + 10
            
            if _debug_read then Format " - %\n" endFrame
            append gbls endFrame
        )
        return gbls
        
    ),
    function ReadMTLS stream tag=
    (
        fseek stream tag.offset #seek_set
        local totalSize = tag.size
        local id = 1
        local layers = #()
        
        struct WC3_MTLS
            ( Id, ParentId, TextureId, filterMode, shadingFlags,  KMTA, KMTE, CoordId,alpha, emissive_multiplier, fresnelR, fresnelG, fresnelB, fresnel_multiplier, team_color_multiplier )

        
        while ( totalSize > 0 ) do
        (
            local lay = WC3_MTLS()
            lay.Id = id
            local lays_size     = readLong stream
            local priorityPlane = readLong stream
            local flags         = readLong stream
            local lays          = _helper.ReadFixedString stream 4
            local nLays         = readLong stream
            
            for i=1 to nLays do
            (
                local layerSize   = readLong stream
                lay.filterMode    = readLong stream
                lay.shadingFlags  = readLong stream
                lay.textureId     = readLong stream
                lay.parentId      = readLong stream
                lay.CoordId       = readLong stream
                lay.alpha         = readfloat stream
             
                if (layerSize > 28 ) then
                (
                    for x=1 to 2 do
                    (
                        local km = _helper.ReadFixedString stream 4
                        if ( km == "KMTA" ) then lay.KMTA = _wc3.ReadFloatAnim stream
                        if ( km == "KMTE" ) then lay.KMTE = _wc3.ReadFloatAnim stream
                        
                    )
                    if ( lay.KMTA == undefined ) then fseek stream -4 #seek_cur
                    if ( lay.KMTE == undefined ) then fseek stream -4 #seek_cur
                )
            )
            totalSize -= lays_size
            
            id +=1
            if _debug_read then Format " - %\n" lay
            append layers lay
        )
        
    ),
    function ReadTEXS stream tag=
    (
        struct WC3_TEXS
            ( Id, ReplacableId, FileNameOnly, Path, Extension, Flags )
        
        fseek stream tag.offset #seek_set
        
        local texs = #()
        local numTexs = tag.Size / 268
        
        for i=1 to numTexs do
        (
            local t = WC3_TEXS()
            t.Id = i
            
            t.replacableId = readLong stream -- 0 or 1 for now ??
            local name = _helper.ReadFixedString stream 260
            t.path          = getFilenamePath name
            t.fileNameOnly  = getFilenameFile name
            t.extension     = getFilenameType name 
            t.flags         = readLong stream
            
            if _debug_read then Format " - %\n" t
            
            append texs t
        )
        return texs
        
    ),
    function ReadGEOS stream tag modl=
    (
        struct WC3_GEO
            ( UniqueName, VRTX = #(), NRMS = #(), PTYP = #(), PCNT = #(), PVTX = #(), GNDX = #(), MTGC = #(), MATS = #(), TANG = #(), SKIN = #(), UVS = #(), meshRef ) 

        struct WC3_MATS
            ( ID, Matrices )
        
        fseek stream tag.offset #seek_set
        
        local id = 1
        local total_size = tag.size
        local geos = #()
        while ( total_size > 0 ) do
        (
            local geo = WC3_GEO() 
            
            geo.UniqueName = modl + "_" + (id as string )
            id +=1
            local chunk_size = readLong stream
            local offset = ( ftell stream )
            
            for h=1 to 9 do
            (
                local header = _helper.ReadFixedString stream 4
                
                if header == "VRTX" then 
                    for v=1 to (readLong stream) do append geo.vrtx (_helper.ReadVector3 stream)

                if header == "NRMS" then 
                    for v=1 to (readLong stream) do append geo.nrms (_helper.ReadVector3 stream)

                if header == "PTYP" then 
                    for v=1 to (readLong stream) do append geo.ptyp (readLong stream)
                
                if header == "PCNT" then 
                    for v=1 to (readLong stream) do append geo.pcnt (readLong stream)
                
                if header == "PVTX" then 
                    for v=1 to (readLong stream)/3 do append geo.pvtx (_helper.ReadTris stream)
                
                if header == "GNDX" then
                    for v=1 to (readLong stream) do append geo.gndx (readbyte stream + 1)
                
                if header == "MTGC" then 
                    for v=1 to (readLong stream) do append geo.mtgc (readLong stream)
                
                if header == "MATS" then 
                (
                    local mats = WC3_MATS()
                    
                    mats.matrices = #()
                    for v=1 to (readLong stream) do append mats.matrices (readLong stream)
                    
                    mats.Id = readlong stream
                    _helper.SkipBytes stream 8
                    for i=1 to 7 do readfloat stream
                    
                    local unk = readLong stream
                    for i=1 to unk do _helper.SkipBytes stream 28
                    
                )
              
                if header == "UVAS" then 
                (
                    for i=1 to (readLong stream) do
                    (
                        local uvs = #()
                        local uvbs = _helper.ReadFixedString stream 4
                        local nUvbs = readLong stream

                        for u=1 to nUvbs do
                            append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )

                        append geo.UVS uvs
                    )
                )
            )

            if _debug_read then Format " - %\n" geo
            
            append geos geo
            fseek stream offset #seek_set
            _helper.SkipBytes stream (chunk_size - 4)

            total_size -= chunk_size
        )
        
        return geos
        
    ),
    function ReadGEOA stream tag=
    (
        struct WC3_GEOA ( GeoId, KGAO )  
        
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.Size
        local geoa = #()
        
        while ( totalSize > 0 ) do
        (
            local ga = WC3_GEOA()
            
            local miniSize = readLong stream
            totalSize -= miniSize
            
            for i=1 to 5 do readFloat stream
            
            ga.GeoId = readLong stream + 1
            
            local kgao = _helper.ReadFixedString stream 4
            
            if ( kgao == "KGAO" ) then
                ga.KGAO = _wc3.ReadFloatAnim stream
            else
                fseek stream -4 #seek_cur
            
            if _debug_read then Format " - %\n" ga
            
            append geoa ga
        )
    
        return geoa
    ),
    function ReadBONE stream tag=
    (
        struct WC3_BONE ( Id, Name, ParentBoneId, Flags, boneRef, KGTR, KGRT, KGSC, offset, geosetId, geosetAnimationId )
        
        fseek stream tag.offset #seek_set
                
        local boneList = #()

        /* read the bone chunks*/
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local b = WC3_BONE()
            
            local size = readLong stream
        
            b.Name = _helper.ReadFixedString stream 80
            b.Id = readLong stream + 1
            b.ParentBoneId = readLong stream + 1
            
            b.Flags = readLong stream
            b.offset = ftell stream
            
            _helper.SkipBytes stream ( size - 80 - 16 )
            
            b.geosetId =  readlong stream
            b.geosetAnimationId =  readlong stream

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
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = _wc3.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = _wc3.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = _wc3.ReadVector3Anim stream -- Key Global Scale
            )
            
            b.KGTR = kgtr
            b.KGRT = kgrt
            b.KGSC = kgsc
            
            if _debug_read then Format " - %\n" b
            
        )
        
        return boneList
    ),
    function ReadHELP stream tag=
    (
        struct wc3_help ( Id, Name, ParentId, Flags, kgtr, kgrt, kgsc )
        
        local totalSize = tag.Size
        local wc3_helpers = #()
        local offset = tag.offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream offset #seek_set        
            local h = wc3_help()
            
            size = readLong stream
            h.name = _helper.ReadFixedString stream 80
            h.id = readLong stream + 1 
            h.parentId = readLong stream + 1 
            h.flags = readLong stream
            
            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = _wc3.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = _wc3.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = _wc3.ReadVector3Anim stream -- Key Global Scale
            )
            249304
            h.KGTR = kgtr
            h.KGRT = kgrt
            h.KGSC = kgsc
            
            totalSize -= size
            offset += size
            if ( _debug_read ) then format " - %\n" h
            append wc3_helpers h
        )
        
        
    ),
    function ReadATCH stream tag=
    (
        struct WC3_ATCH ( Id, Name, ParentId, Flags, KGTR, KGRT, KGSC, KATV, offset, size )
        
        fseek stream tag.Offset #seek_set
        
        local totalSize = tag.Size
        local atchs = #()

        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local att = WC3_ATCH()
            
            local size       = readLong stream
            local headerSize = readLong stream --> 96 bytes consisting of name, id, parentId and flagid and headerSize

            att.name     = _helper.ReadFixedString stream 80
            att.Id       = readLong stream + 1
            att.ParentId = readLong stream + 1
            att.flags    = readLong stream
            att.Offset = ftell stream
            att.Size = size - 4 - 4 - 80 - 8 - 4
            
            _helper.SkipBytes stream att.Size
        
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
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = _wc3.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = _wc3.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = _wc3.ReadVector3Anim stream -- Key Global Scale
            )
            
            att.KGTR = kgtr
            att.KGRT = kgrt
            att.KGSC = kgsc
            local correction = 0
            if ( kgtr == undefined ) then correction = correction + 4
            if ( kgrt == undefined ) then correction = correction + 4
            if ( kgsc == undefined ) then correction = correction + 4
           
            _helper.SkipBytes stream ( 264 - correction)

            local katv = _helper.ReadFixedString stream 4
            
            if( katv == "KATV") then att.katv = _wc3.ReadFloatAnim stream -- visibility track ?

            if ( _debug_read ) then format " - %\n" att
            
        )
        
        return atchs
        
    ),
    function ReadPIVT stream tag=
    (
        struct WC3_PIVT ( Id, Position )
        fseek stream tag.offset #seek_set
        local nbr = tag.Size / 12.0
        local pivts = #()
        for n=1 to nbr do
        (
            local p = WC3_PIVT()
            p.Id = n
            p.Position = [readfloat stream, readfloat stream, readfloat stream]
            append pivts p
            
            if ( _debug_read ) then format " - %\n" p
        )
        return pivts
        
    ),
    function ReadCAMS stream tag=
    (
        struct WC3_CAMS ( Name, Pos,  FOV, FarClip, NearClip, TargetPos, KCTR, KTTR, KCRL, objRef )
        
        fseek stream tag.Offset #seek_set
        
        local cams = #()
        local totalSize = tag.size
        
        while ( totalSize > 0) do
        (
            local size = readLong stream
            local cam = WC3_CAMS()

            cam.Name = _helper.ReadFixedString stream 80
            cam.Pos = [readFloat stream,readFloat stream,readFloat stream]
            cam.FOV = radToDeg ( readFloat stream )
            cam.FarClip = readFloat stream
            cam.NearClip = readFloat stream
            cam.TargetPos = [readFloat stream,readFloat stream,readFloat stream]

            for i=1 to 3 do
            (
                local anim = _helper.ReadFixedString stream 4
                if ( anim == "KCTR" ) then cam.KCTR = _wc3.ReadVector3Anim stream
                if ( anim == "KTTR" ) then cam.KTTR = _wc3.ReadVector3Anim stream
                if ( anim == "KCRL" ) then cam.KCRL = _wc3.ReadQuatAnim stream
            )
            
            if ( cam.KCTR == undefined ) then fseek stream -4 #seek_cur
            if ( cam.KTTR == undefined ) then fseek stream -4 #seek_cur
            if ( cam.KCRL == undefined ) then fseek stream -4 #seek_cur
            
            if ( _debug_read ) then format " - %\n" cam
            append cams cam

            totalSize -= size
        )
        
        return cams
    ),
    function ReadEVTS stream tag=
    (   
        struct WC3_EVTS ( Id, Name, ParentId, Flags, KEVT, objRef )
        
        fseek stream tag.Offset #seek_set
        local evts = #()
        local total_size = tag.size
        while ( total_size > 0 ) do
        (
            local evt = WC3_EVTS()
            local size = readLong stream
            
            evt.name = _helper.ReadFixedString stream 80
            evt.id          = readLong stream + 1
            evt.parentId    = readLong stream + 1
            evt.flags       = readLong stream
            local kevt      = _helper.ReadFixedString stream 4
            
            if ( kevt == "KEVT" ) then
            (
                size += 12
                local keys = #()
                local nbr       = readLong stream
                local parentId  = readLong stream + 1
                size += 4 * nbr
                for i=1 to nbr do 
                (
                    local key =  ( _helper.RoundToFrame ( readLong stream ) ) + 10
                    append keys key
                )
                evt.KEVT = keys
            )
            else
                fseek stream -4 #seek_cur
            
            if ( _debug_read ) then format " - %\n" evt
            append evts evt
            
           total_size -= size
        )
        
        return evts
    ),
    function ReadCLID stream tag=
    (
        struct WC3_CLID ( id, Name, ParentId, BoundingType, Flags, Pos, PosAlt,  Radius, objRef )
        /*
          0: cube
          1: plane
          2: sphere
          3: cylinder
        */
        
        fseek stream tag.offset #seek_set

        local clid = #()
        local total_size = tag.size

        while ( total_size > 0 ) do
        (
            local cl = WC3_CLID()
            local size = readLong stream
            
            cl.name = _helper.ReadFixedString stream 80
            cl.Id       = readLong stream + 1
            cl.parentId = readLong stream + 1
            cl.flags    = readLong stream
            
            size += 16
            cl.BoundingType = readLong stream
            cl.pos = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( cl.BoundingType != 2 ) then 
            (
                cl.posAlt = [readFloat stream, readFloat stream, readFloat stream]
                size += 12
            )
            
            if ( cl.BoundingType == 2 or cl.BoundingType == 3 ) then 
            (
                cl.radius = readFloat stream
                size += 4
            )

            if ( _debug_read ) then format " - %\n" cl
            
            append clid cl

            total_size -= size
        )
        
        return clid
        
    )
)