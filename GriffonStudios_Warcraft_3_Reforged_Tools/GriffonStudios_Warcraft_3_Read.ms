struct Warcraft_3_Read
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
    
    function ReadMTLS2 stream tag=
    (
        fseek stream tag.offset #seek_set
        local totalSize = tag.size
        local offset = tag.offset
        
        struct WC3_MTLS ( tag, size, shaders = #() )
        
        local mtls = WC3_MTLS()
        mtls.tag = tag.name
        mtls.size = tag.size
        
        while ( totalSize > 0 ) do
        (
            local shdr = Warcraft_3_Read.ReadShader stream
            append mtls.shaders shdr
            
        )
        return mtls
    ),
    function ReadShader stream=
    (
        struct WC3_SCHADER ( Size, PriorityPlane, Flags, Name, Lays, NumberOfLayers, Layers = #() )
        
        local shdr = WC3_SCHADER()
        shdr.Size = readLong stream
        shdr.PriorityPlane = readLong stream
        shdr.Flags = readLong stream
        shdr.Name = _helper.ReadFixedString stream 80
        shdr.Lays = _helper.ReadFixedString stream 4
        shdr.NumberOfLayers = readLong stream
        
        
        local currentOffset = fTell stream
        
        for i=1 to shdr.NumberOfLayers do
        (
            fSeek stream currentOffset #seek_set
            local layer = Warcraft_3_Read.ReadLayer stream
            append shdr.Layers layer
            
            currentOffset = currentOffset + layer.Size
        )
        
        
        return shdr
    ),
    function ReadLayer stream=
    (
        struct WC3_LAYER ( Size, FilterMode, ShadingFlags, TextureId, ParentId, CoordId, Alpha, EmissiveMultiplier, FresnelR, FresnelG, FresnelB, FresnelMultiplier, TeamColorMultiplier, KMTA, KMTE ) 
        
        local lay = WC3_LAYER()
        
        lay.Size                = readLong stream
        lay.FilterMode          = readLong stream
        lay.ShadingFlags        = readLong stream
        lay.TextureId           = readLong stream
        lay.ParentId            = readLong stream
        lay.CoordId             = readLong stream
        lay.Alpha               = readfloat stream
        lay.EmissiveMultiplier  = readfloat stream
        lay.FresnelR            = readfloat stream
        lay.FresnelG            = readfloat stream
        lay.FresnelB            = readfloat stream
        lay.FresnelMultiplier   = readfloat stream
        lay.TeamColorMultiplier = readfloat stream
     
        if (lay.Size > 52 ) then
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
        if _debug_read then Format " - %\n" lay
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
            p.Id = n as integer
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
    )
)