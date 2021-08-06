/*
    .SYNOPSIS
    | Importer for Warcraft III mdx (old version = version 800 )
    
    .COPYRIGHT
    | �2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 1.1 - Added Shared Folder selection and usage support, for team glow, gutz, ...
    | 1.0 - Added KMTA support
    | 0.9 - Added TXAN support
    | 0.8 - Added LITE support
    | 0.7 - Cleanup based on my understanding during export code
    | 0.6 - Added Global Sequence behavior
    | 0.5 - Added Particle Emitter reading v1
    | 0.4 - Added plugins: Attachment, Material, Event and Ribbon
    | 0.3 - Clean up for usage
    | 0.2 - Applied correct skinning ( after re-reading nintoxicated's script )
    | 0.1 - Initial setup

*/


/* Required plugins */
fileIn "GriffonStudios_Warcraft_III_Plugins_ParticleEmitter.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Attachment.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Material.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Event.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Ribbon.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Behavior.ms"

/* Helper methods */
fileIn "GriffonStudios_Warcraft_III_Helpers.ms"
fileIn "GriffonStudios_Helpers.ms"

GLOBAL WC3_MDX800_DEBUG = false
GLOBAL WC3_READONLY = false
GLOBAL WC3_DEBUG = false
GLOBAL WC3_MDX = undefined

clearlistener()
STRUCT WC3_MDX800
(   
    function ReadPREM800 stream tag=
    (
        format "Reading %\n" tag.name
        struct prem800 
            ( size, headerSize, name, id, parentId, mdlName, flags, emissionrate, gravity, longitude, latitude, lifeSpan, speed, KPEV )
        
        try (
        
            local totalSize = tag.size
            local currentOffset = tag.offset
            local prems = #()
            
            while (totalSize > 0 ) do
            (
                fseek stream currentOffset #seek_set
                
                local p = prem800()
                p.size = readLong stream
                p.headerSize   = readLong stream
                p.name         = GriffonStudios_Helpers.ReadFixedString stream 80
                p.id           = readLong stream + 1
                p.parentId     = readLong stream + 1
                p.flags        = readLong stream
                
                p.gravity      = readFloat stream
                p.emissionRate = readFloat stream
                p.longitude    = readFloat stream
                p.latitude     = readFloat stream
                
                p.mdlName = GriffonStudios_Helpers.ReadFixedString stream 260
                
                p.lifeSpan = readFloat stream
                p.speed = readFloat stream
                
                -- Keys for Particle Emitter Visibility
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KPEV" ) then p.KPEV = Warcraft_III_Helpers.ReadFloatAnim stream
                if( p.KPEV == undefined ) then fseek stream -4 #seek_cur

                totalSize -= p.size
                currentOffset += p.size
                append prems p
                if WC3_MDX800_DEBUG then print p
            )
            
            return prems
        )
        catch()
        


    ),
    function ReadRIBB800 stream tag=
    (
        format "Reading %\n" tag.name
        struct ribb800 
            ( size, headerSize, name, id, parentId, flags, above, below, edgesSec, edgesLife, gravity, vAlpha, vColor, flipbookRows, flipbookCols, flipBookSlot, mtlsId,
              KGTR, KGRT, KGSC, KRHA, KRHB, KRAL, KRCO, KRTX, KRVS
            )
        
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.size
        local ribbs = #()
        
        while (totalSize > 0 ) do
        (
            local ribb = ribb800()
            
            ribb.size         = readLong stream
            ribb.headerSize   = readLong stream
            ribb.name         = GriffonStudios_Helpers.ReadFixedString stream 80
            ribb.id           = readLong stream + 1
            ribb.parentId     = readLong stream + 1
            ribb.flags        = readLong stream
            
            totalSize        -= ribb.size
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KGTR" ) then ribb.KGTR = Warcraft_III_Helpers.ReadVector3Anim stream
                if( kg == "KGRT" ) then ribb.KGRT = Warcraft_III_Helpers.ReadQuatAnim stream
                if( kg == "KGSC" ) then ribb.KGSC = Warcraft_III_Helpers.ReadVector3Anim stream
            )
            
            if( ribb.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KGRT == undefined ) then fseek stream -4 #seek_cur
            
            ribb.above          = readFloat stream
            ribb.below          = readFloat stream
            ribb.valpha         = readFloat stream
            ribb.vcolor         = Warcraft_III_Helpers.ReadColor stream
            ribb.edgesLife      = readFloat stream
            ribb.flipBookSlot   = readLong stream
            ribb.edgesSec       = readLong stream
            ribb.flipbookRows   = readLong stream
            ribb.flipbookCols   = readLong stream
            ribb.mtlsId         = readLong stream + 1
            ribb.gravity        = readFloat stream
      
            for i=1 to 6 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                if( kg == "KRHA" ) then ribb.KRHA = Warcraft_III_Helpers.ReadFloatAnim stream -- heightAbove
                if( kg == "KRHB" ) then ribb.KRHB = Warcraft_III_Helpers.ReadFloatAnim stream  -- heightBelow
                if( kg == "KRAL" ) then ribb.KRAL = Warcraft_III_Helpers.ReadFloatAnim stream -- alpha
                if( kg == "KRCO" ) then ribb.KRCO = Warcraft_III_Helpers.ReadColorAnim stream -- color
                if( kg == "KRTX" ) then ribb.KRTX = Warcraft_III_Helpers.ReadLongAnim stream  -- texture
                if( kg == "KRVS" ) then ribb.KRVS = Warcraft_III_Helpers.ReadFloatAnim stream -- visibility
            )
            if( ribb.KRHA == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRHB == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRAL == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRCO == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRTX == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRVS == undefined ) then fseek stream -4 #seek_cur
            
            append ribbs ribb
            if WC3_MDX800_DEBUG then print ribb
        )
        
        if WC3_MDX800_DEBUG then print ribbs
        return ribbs
        
    ),
    function ReadCAMS800 stream tag=
    (
        format "Reading %\n" tag.name
        struct cam800 ( size, name, camPos, FOV, farClip, nearClip, targetPos )
        
        local cams = #()
        local totalSize = tag.size
        local currentOffset = tag.offset
        while (totalSize > 0) do
        (
            fseek stream currentOffset #seek_set
                
            local cam = cam800()
            
            cam.size = readLong stream
            cam.name = GriffonStudios_Helpers.ReadFixedString stream 80
            cam.camPos = [readFloat stream,readFloat stream,readFloat stream]
            cam.FOV = radToDeg ( readFloat stream )
            cam.FarClip = readFloat stream
            cam.NearClip = readFloat stream
            cam.targetPos = [readFloat stream,readFloat stream,readFloat stream]
            
            append cams cam
            totalSize -= cam.size
            currentOffset += cam.size
        )
        if WC3_MDX800_DEBUG then print cams
        return cams
    ),
    function ReadTAGS800 stream streamLen=
    (
        format "\nReading CHUNKS\n"
        struct tag800 ( Name, Offset, Size )     
        
        local tags = #() 
        local mainTag = tag800()

        mainTag.Name = GriffonStudios_Helpers.ReadFixedString stream 4
        mainTag.Offset = 0
        mainTag.Size = 0
        
        local currentStreamPos = ftell stream

        while (currentStreamPos < streamLen ) do
        (
            local tag = tag800()
            
            tag.Offset = ftell stream + 8 -- the +8 indicates where the data starts
            tag.Name = GriffonStudios_Helpers.ReadFixedString stream 4
            tag.Size = ReadLong stream
            
            GriffonStudios_Helpers.SkipBytes stream tag.Size

            currentStreamPos = ftell stream
            
            append tags tag
            if WC3_MDX800_DEBUG then Format " - %\n" tag
        )
        return tags
    ),
    function ReadEVTS800 stream tag=
    (
        format "Reading %\n" tag.name
        /*
            for a full understanding what these sounds are, see the official Warcraft III Art Tools documentation
            
        */
        
        struct evts800 ( Id, Name, ParentId, Flags, KEVT, objRef )
        fseek stream tag.Offset #seek_set
        local evts = #()
              
        
        while ( ftell stream < (tag.offset + tag.size)) do
        (
            local evt = evts800()
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
            if WC3_MDX800_DEBUG then print evt
           
        )
        
        return evts
    ),
    function ReadATCH800 stream tag=
    (
        format "Reading %\n" tag.name
        struct atch800 ( Size, HeaderSize, Id, ParentBoneId, Name, FullPath, Flags, Index, KGTR, KGRT, KGSC, KATV)
        
        
        
        local atchs = #()

        local totalSize = tag.Size
        local offSet = tag.Offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream offSet #seek_set
            
            local att = atch800()
            
            att.size = readLong stream
            att.headerSize = readLong stream --> 96 bytes consisting of name, id, parentId and flagid and headerSize

            att.name = GriffonStudios_Helpers.ReadFixedString stream 80
            att.Id = readLong stream + 1
            att.ParentBoneId = readLong stream + 1
            att.flags = readLong stream
            att.FullPath = GriffonStudios_Helpers.ReadFixedString stream 260
            att.Index = readLong stream

            totalSize -= att.Size
            offset += att.Size
            
            append atchs att
            if WC3_MDX800_DEBUG then print att
        )
        
        
        return atchs
        
    ),
    function ReadBONE800 stream tag=
    (
        format "Reading %\n" tag.name
        struct bone800 ( Id, Name, ParentBoneId, Flags, boneRef, KGTR, KGRT, KGSC, offset, geosetId, geosetAnimationId )
        
        fseek stream tag.offset #seek_set
                
        local boneList = #()

        /* read the bone chunks*/
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local b = bone800()
            
            local size = readLong stream
        
            b.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            b.Id = readLong stream + 1
            b.ParentBoneId = readLong stream + 1
            
            b.Flags = readLong stream
            b.offset = ftell stream
            
            GriffonStudios_Helpers.SkipBytes stream ( size - 80 - 16 )
            
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
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )
            
            b.KGTR = kgtr
            b.KGRT = kgrt
            b.KGSC = kgsc
            if WC3_MDX800_DEBUG then print b
        )
        
        return boneList
    ),
    function ReadCLID800 stream tag=
    (
        format "Reading %\n" tag.name
        /*
            0: cube
            1: plane
            2: sphere
            3: cylinder
        */
        
        struct clid800( size, name, id, parentid, flags, KGTR, KGRT, KGSC, CollisionType, StartPosition, EndPosition, Radius )
        local clidList = #()
        local totalSize = tag.size
        local currentOffset = tag.Offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local startPos = ftell stream
            
            local clid = clid800()
            
            clid.size = readLong stream
            clid.name = GriffonStudios_Helpers.ReadFixedString stream 80
            clid.Id = readLong stream + 1
            clid.parentId = readLong stream + 1
            clid.flags = readLong stream

            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then clid.KGTR = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then clid.KGRT = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then clid.KGSC = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )
            local currentPos = ftell stream
            
            if (clid.KGTR == undefined ) then currentPos -=4
            if (clid.KGRT == undefined ) then currentPos -=4
            if (clid.KGSC == undefined ) then currentPos -=4
            
            fseek stream currentPos #seek_set
            
            clid.CollisionType = readLong stream
            clid.StartPosition = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( clid.CollisionType != 2 ) then clid.EndPosition = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( clid.CollisionType == 2 or clid.CollisionType == 3 ) then clid.radius = readFloat stream
            
            currentOffset = ftell stream
            append clidList clid
            local size = currentOffset - startPos
            totalSize -= size
            if WC3_MDX800_DEBUG then print clid
        )
        --print clidList
        return clidList
    ),
    function ReadPIVT800 stream tag=
    (
        format "Reading %\n" tag.name
        fseek stream tag.offset #seek_set
        local nbr = tag.Size / 12.0
        local pivts = #()
        for n=1 to nbr do
        (
            local m  = matrix3 1
            m.row4 = [readfloat stream, readfloat stream, readfloat stream]
            append pivts m
            if WC3_MDX800_DEBUG then print m
        )
        --print pivts
        return pivts
    ),
    function ReadHELP800 stream tag=
    (
        format "Reading %\n" tag.name
        local totalSize = tag.Size
        local helperList = #()
        
        struct help800 ( size, name, id, parentId, flags, KGTR, KGRT, KGSC, helperRef )
        
        local currentOffset = tag.Offset
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local h = help800()
            h.size = readLong stream
            h.name = GriffonStudios_Helpers.ReadFixedString stream 80
            h.Id = readLong stream + 1
            h.parentId = readLong stream + 1
            h.flags = readLong stream
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then h.KGTR = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then h.KGRT = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then h.KGSC = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )

            
            totalSize -= h.size
            currentOffset = currentOffset + h.Size
            if WC3_MDX800_DEBUG then print h
            append helperList h
        )
        
       -- print helperList
        return helperList
    ),
    function ReadGEOA800 stream tag=
    (
        format "Reading %\n" tag.name
        local totalSize = tag.Size
        local currentOffset = tag.Offset
        local geoa = #()
        
        struct geoa800 (size, opacity, geoId, color, type, KGAO)
        
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local kgao = undefined --> weird memory leak ...
            local g = geoa800()
            g.size      = readLong stream
            g.opacity   = readFloat stream
            g.type      = readLong stream 
            g.color     = color (readFloat stream * 255.0) (readFloat stream * 255.0) (readFloat stream * 255.0) 1.0
            g.geoId     = readlong stream + 1
            
            if ( g.size > 28 ) then 
            local kgao = GriffonStudios_Helpers.ReadFixedString stream 4

            if ( kgao == "KGAO" ) then
                g.KGAO = Warcraft_III_Helpers.ReadFloatAnim stream
            else
                fseek stream -4 #seek_cur
            
            append geoa g
            if WC3_MDX800_DEBUG then print g
            totalSize -= g.Size
            currentOffset += g.Size
        )
    
        --print geoa
        return geoa
    ),
    function ReadVERS800 stream tag=
    (
        format "Reading %\n" tag.name
        fseek stream tag.Offset #seek_set
        local version = readLong stream
        if(version != 800 ) then 
            throw ("Version " +  (version as string) + " not supported !" )
        return version
    ),
    function ReadTEXS800 stream tag=
    (
        format "Reading %\n" tag.name
        struct texs800 ( replacableId, path, flags )
        fseek stream tag.offset #seek_set
        local texs = #()
        
        local numTexs = tag.Size / 268
        
        for i=1 to numTexs do
        (
            local t = texs800()
           
            t.replacableId = readLong stream 
            t.path = GriffonStudios_Helpers.ReadFixedString stream 260
            t.flags = readLong stream
            
            append texs t
            if WC3_MDX800_DEBUG then print t
        )
        --print texs
        return texs
    ),
    function ReadMTLS800 stream tag=
    (
        format "Reading %\n" tag.name
        struct layer800 ( name, size, priority, flags, nMaps, maps = #(), materialRef )
        struct map800 ( size, filterMode, shadingFlags, textureId, txanId, coordId, alpha, kmta, kmte, kmtf )
        
        -- FilterMode (0:none;1:trans;2:blend;3:add)
        -- ShadingFlags (1:unshaded;+16:two sided;+32:unfogged)
        
        fseek stream tag.offset #seek_set
        local totalSize = tag.size
        
        local mtls = #()
        local id = 1
        
        while ( totalSize > 0 ) do
        (
            local layer = layer800()
            
            layer.size     = readLong stream
            layer.priority = readLong stream
            layer.flags    = readLong stream
            layer.name     = GriffonStudios_Helpers.ReadFixedString stream 4
            layer.nMaps    = readLong stream
            
            for i=1 to layer.nMaps do
            (
                local map   = map800()
                map.size          = readLong stream --> 28 bytes
                map.filterMode    = readLong stream 
                map.shadingFlags  = readLong stream 
                map.textureId     = readLong stream 
                map.txanId        = readLong stream + 1 --> references a TXAN 
                map.CoordId       = readLong stream
                map.alpha         = readfloat stream
             
                if (map.size > 28 ) then
                (
                    for x=1 to 3 do
                    (
                        local km = GriffonStudios_Helpers.ReadFixedString stream 4
                        if ( km == "KMTA" ) then map.KMTA = Warcraft_III_Helpers.ReadFloatAnim stream --> alpha
                        if ( km == "KMTE" ) then map.KMTE = Warcraft_III_Helpers.ReadFloatAnim stream --> emissive
                        if ( km == "KMTF" ) then map.KMTF = Warcraft_III_Helpers.ReadLongAnim stream --> .FLI 
                        
                    )
                    if ( map.KMTA == undefined ) then fseek stream -4 #seek_cur
                    if ( map.KMTE == undefined ) then fseek stream -4 #seek_cur
                    if ( map.KMTF == undefined ) then fseek stream -4 #seek_cur
                )
                append layer.maps map
                
            )
            totalSize -= layer.size
            
            id +=1
           --print layer
            append mtls layer
            if WC3_MDX800_DEBUG then print layer
        )
        
        return mtls
        
    ),
    function ReadGEOS800 stream tag=
    (
        format "Reading %\n" tag.name
        struct geo800  
            (   uniqueName, VRTX = #(), NRMS = #(), PTYP = #(), PCNT = #(), PVTX = #(), GNDX = #(), MTGC = #(), MATS = #(), UVS = #(), meshRef, 
                bones = #(),  --> bones indexes for weighing the vertices, vertices are equally weighted -> 2 bones => so 1 vertex is 0.5
                uniqueBoneIds = #() --> the list of bones required for this whole mesh
            )
        struct mats800 ( nbrItems, name, matrices = #(), id, sectionGroupId, sectionGroupType, sevenFloats = #(), nbrFloats, floats = #() )
        local total_size = tag.size
        local offset = tag.offset
        
        local geos = #()
        while ( total_size > 0 ) do
        (
            fseek stream offset #seek_set
            
            local geo = geo800() 
            local chunk_size = readLong stream
            if WC3_MDX800_DEBUG then format " - chunkSize: %\n" chunk_size 
            for h=1 to 9 do
            (
                local header = GriffonStudios_Helpers.ReadFixedString stream 4
                --format "% \n" header
                if header == "VRTX" then 
                (
                    local amount = readLong stream
                    for v=1 to amount do append geo.vrtx (Warcraft_III_Helpers.ReadVector3 stream)
                    -- format "% %\n" header amount
                )
                if header == "NRMS" then 
                    for v=1 to (readLong stream) do append geo.nrms (Warcraft_III_Helpers.ReadVector3 stream)

                if header == "PTYP" then 
                    for v=1 to (readLong stream) do append geo.ptyp (readLong stream)
                
                if header == "PCNT" then 
                    for v=1 to (readLong stream) do append geo.pcnt (readLong stream)
                
                if header == "PVTX" then 
                    for v=1 to (readLong stream)/3 do append geo.pvtx (Warcraft_III_Helpers.ReadTris stream)
                
                if header == "GNDX" then -- groups
                (
                    local amount = readLong stream
                    local maxBoneIndex = 0
                    for v=1 to amount do 
                    (
                        local boneIdx = readbyte stream + 1
                        append geo.gndx boneIdx

                    )
                    --format "% %\n" header amount
                    
                )
                if header == "MTGC" then -- Matching Group Count
                (
                    local amount = readLong stream
                    for v=1 to amount do append geo.mtgc (readLong stream)
                    --format "Bonegroups: % %\n" header amount
                )
                if header == "MATS" then 
                (
                    
                    geo.mats = mats800()
                    
                    geo.mats.nbrItems = readLong stream
                    for v=1 to geo.mats.nbrItems do append geo.mats.matrices (readLong stream + 1) 
                    
                    geo.mats.Id = readlong stream
                    geo.mats.sectionGroupId = readlong stream
                    geo.mats.sectionGroupType = readlong stream --> if this is 4 it becomes unselectable.
                    
                    for i=1 to 7 do append geo.mats.sevenFloats (readfloat stream) -- bounding radius + bbox
                    
                    geo.mats.nbrFloats = readLong stream --> for each seqs
                    for i=1 to geo.mats.nbrFloats * 7 do append geo.mats.floats (readfloat stream ) -- bounding radius + bbox
                    
                )

                if header == "UVAS" then 
                (
                    local amount = readLong stream
                    for i=1 to amount do
                    (
                        local uvs = #()
                        local uvbs = GriffonStudios_Helpers.ReadFixedString stream 4
                        local nUvbs = readLong stream

                        for u=1 to nUvbs do
                            append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )
                        append geo.UVS uvs
                    )
                    --format "% %\n" header amount
                )
            )

            append geos geo
            
            offset += chunk_size
            total_size -= chunk_size
        )
        -- calculate the bones the need to be added per vertex
        for geo in geos do
        (
            index = 1
            for mtgc in geo.MTGC do
            (
                list = #()
                for i=1 to mtgc do
                (
                    append list geo.MATS.matrices[index]
                    index  +=1
                )
                append geo.bones list
            )
            for boneId in geo.mats.matrices do
                appendIfUnique geo.uniqueBoneIds boneId
            
            geo.uniqueBoneIds = sort geo.uniqueBoneIds
        )
        
        
        
        return geos
        
    ),
    function ReadMODL800 stream tag=
    (
        format "Reading %\n" tag.name
        struct modl800 ( name, path, radius, bbox, Always150 )
        local modl = modl800()
        fseek stream tag.offset #seek_set
        
        modl.name = GriffonStudios_Helpers.ReadFixedString stream 80
        modl.path = GriffonStudios_Helpers.ReadFixedString stream 260
        
        modl.bbox = #()
        modl.radius = readFloat stream / 4.0
        append modl.bbox [readFloat stream, readFloat stream, readFloat stream]
        append modl.bbox [readFloat stream, readFloat stream, readFloat stream]
        modl.Always150 = readLong stream

        return modl
    ),
    function ReadGLBS800 stream tag=
    (
        format "Reading %\n" tag.name
        fseek stream tag.offset #seek_set
        local glbs = #()
        
        local nbr = tag.Size / 4
        
        for i=1 to nbr do 
        (
            local endFrame = (GriffonStudios_Helpers.RoundToFrame (readLong stream)) + 10
            append glbs endFrame
        )
        if WC3_MDX800_DEBUG then print glbs
        return glbs
    ),
    function ReadSEQS800 stream tag=
    (
        format "Reading %\n" tag.name
        struct seqs800 ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity,Priority,Default, BBox )
        
        fseek stream tag.offset #seek_set
        
        local nbrSeqs = tag.size / 132
        local seqs = #()
        
        for i=1 to nbrSeqs do
        (
            local seq = seqs800()
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
            if WC3_MDX800_DEBUG then print seq
            
        )

        return seqs
        
    ),
    function ReadLITE800 stream tag=
    (
        format "Reading %\n" tag.name
        local totalSize = tag.Size
        local lightList = #()
        
        struct lite800 ( size, headerSize, name, id, parentId, flags, type, farAttenStart, farAttenEnd, rgbColor, rgbIntensity, ambColor, ambIntensity, KGTR, KGRT, KGSC, KLAV,  lightRef )
        
        local currentOffset = tag.Offset
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local l = lite800()
            
            l.size       = readLong stream
            l.headerSize = readLong stream
            l.name       = GriffonStudios_Helpers.ReadFixedString stream 80
            l.Id         = readLong stream + 1
            l.parentId   = readLong stream + 1
            l.flags      = readLong stream
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4
                
                if ( kg != "KGTR" and kg != "KGRT" and kg != "KGSC" ) then  
                (
                    fseek stream -4 #seek_cur
                    exit
                )
                
                if ( kg == "KGTR" ) then l.KGTR = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then l.KGRT = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then l.KGSC = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )
            
            l.Type         = readLong stream 
            l.farAttenStart   = readFloat stream
            l.farAttenEnd     = readFloat stream
            l.rgbColor     = Warcraft_III_Helpers.readColor stream
            l.rgbIntensity = readFloat stream
            l.ambColor     = Warcraft_III_Helpers.readColor stream
            l.ambIntensity = readFloat stream
            
            local kg = GriffonStudios_Helpers.ReadFixedString stream 4
            
            if ( kg == "KLAV" ) then l.KLAV = Warcraft_III_Helpers.ReadFloatAnim stream
            
            totalSize -= l.size
            currentOffset = currentOffset + l.Size
            
            if WC3_MDX800_DEBUG then print l
            
            append lightList l
            
        )
        return lightList
        
    ),
    function ReadTXAN800 stream tag=
    (
        format "Reading %\n" tag.name
        local totalSize = tag.Size
        local txanList = #()
        
        struct txan800 ( size, ktat )
        
        local currentOffset = tag.Offset
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            
            local t = txan800()
            t.size = readLong stream
            
            local kg = GriffonStudios_Helpers.ReadFixedString stream 4
            
            if ( kg == "KTAT" ) then t.KTAT = Warcraft_III_Helpers.ReadVector3Anim stream --> Keys for Texture Animation Track (UVW animation)
            
            totalSize -= t.size
            currentOffset = currentOffset + t.Size
            
            if WC3_MDX800_DEBUG then print t
            
            append txanList t
        )
    ),
    function BuildLITE800 mdx=
    (
        if mdx.LITE == undefined then return undefined
        
        format "Building the lights \n"
        local layer = GriffonStudios_Helpers.CreateLayer "Lights"
        
        for lite in mdx.LITE do
        (
            /*
                0x0: Omni
                0x1: Directional
                0x2: Ambient
                0x3: Default
            */
            local theLight = undefined
            local pos = mdx.PIVT[lite.Id].translationPart
            
            format "- %\n" lite.name
            
            if ( lite.Type == 0 ) then 
                theLight = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd pos:pos
            
            if ( lite.Type == 1 ) then 
                theLight = DirectionalLight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd pos:pos
            
            if ( lite.Type > 2 ) then --> or other
                theLight = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( lite.Type == 2 ) then --> note these are Max Settings !!!
            (
                ambientcolor = lite.ambColor
                lightLevel = lite.ambIntensity
            )
            lite.lightRef = theLight
            layer.addNode theLight
            append mdx.objs theLight
            
            theLight.showFarAtten = on
            theLight.useFarAtten = on
            
            if lite.parentID > 0 then theLight.parent = mdx.objs[theLight.parentId]
            
            if lite.KLAV == undefined then continue
                
            if lite.KLAV.numPts > 0 then
            (
                theLight.Visibility = on
                theLight.Visibility.controller = on_off()

                for anim in lite.KLAV.KG do 
                    with animate on at time ( anim.Time + 10 )
                        if (anim.point == 1) then 
                            theLight.Visibility = on
                        else
                            theLight.Visibility = off
                
            )
            
        )
        
    ),
    function BuildGEOS800 mdx=
    (
        if mdx.geos == undefined then return undefined
        format "Building Meshes \n"
        local layer = GriffonStudios_Helpers.CreateLayer "Unit"
        for i=1 to mdx.geos.count do 
         (
            local geo = mdx.geos[i]
            
            local c = random 10 100
            local wireColor = color c c c
            
            local v = geo.VRTX
            local n = geo.NRMS
            local f = geo.PVTX
            local uv = geo.UVS[1]
            
            geo.MATS.name = mdx.modl.name + "_" + ( i as string )
            
            local theMesh = mesh vertices:v vnorms:n name:geo.MATS.Name faces:f tverts:uv 

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
        
    ),
    function BuildSEQS800 mdx=
    (
        if mdx.seqs == undefined then return undefined
        format "Building Animation Sequences\n"
        local animTrack1 = undefined 
        local nNoteTracks = numNoteTracks rootNode
        if(  nNoteTracks > 0 ) then
        (
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode (getNoteTrack rootNode 1)
        )
        if( numNoteTracks rootNode == 0 ) then
        (
            animTrack1 = notetrack "AnimTrack1"
            addNoteTrack rootNode animTrack1
        )
        local prevEndFrame = 0                       
        
        for t=1 to mdx.seqs.count do
        (
            local seq = mdx.seqs[t]
            local theAnimTrack = animTrack1 --> always pick first one

            local startNote = AddNewNoteKey theAnimTrack seq.startFrame
            local endNote = AddNewNoteKey theAnimTrack seq.endFrame
            
            local val = seq.name + "\r\n"
                  val += "rarity = " 	 + (seq.Rarity as string)    + "\r\n"
                  val += "moveSpeed = "  + (seq.MovementSpeed as string) + "\r\n"
                  val += "nonLoop = " 	 + (seq.Noloop as string)    + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + (seq.Priority as string)

           
            startNote.Value = val
            endNote.Value = val

            if WC3_MDX800_DEBUG then 
                format "- Anim: % (%-%)\n" seq.name seq.startFrame seq.endFrame
			
        )
        
    ),
    function BuildAndAssignMaterials mdx=
    (
        if mdx.mtls == undefined then return undefined
        format "Building Materials\n"
        /*
            Replacable Id's
            0 - Diffuse map
            1 - Use teamcolor in the texture
            2 - Use team glow -> a radial texture with teamcolor ( hero glow )
        */
        
        WC3_MDX800.BuildMaterials800 mdx
        for geo in mdx.geos do
        (
            if geo.meshRef != undefined then 
                geo.meshRef.material = mdx.mtls[geo.mats.id+1].materialRef
        )

    ),
    function BuildMaterials800 mdx=
    (
        
        for x=1 to 24 do 
        (
            local matname = "Standard Material - " + (x as string)
            meditMaterials[x] = standard name:matname
        )
        
        
        local m = 0
        for mtl in mdx.mtls do
        (
            
            local map = mtl.maps[1]
            local mat = WC3_MDX800.CreateWC3Material mdx map m
            
            m = m + 1
            
            if( mtl.nMaps == 1 ) then 
            (
                mtl.materialRef = mat
                showTextureMap mtl.materialRef true
            )
            else
            (
                
                mtl.materialRef = compositematerial()
                mtl.materialRef.name = mdx.modl.name + "_COMPOSITE_" + ( m as string )
                
                for y=mtl.nMaps to 9 do mtl.materialRef.mapEnables[y] = off
                mtl.materialRef.baseMaterial = mat
                
                for i=2 to mtl.nMaps do 
                (
                    local map = mtl.maps[i]
                    m = m + 1
                    local submat = WC3_MDX800.CreateWC3Material mdx map m
                    
                    mtl.materialRef.materialList[i] = submat
                )
                
                for ml in mtl.materialref.materialList do
                (
                    if ( ml.diffuse_map.fileName != "") then (
                        showTextureMap ml true
                        exit
                    )
                )
                
            )
            
        )
        
        for i=1 to mdx.mtls.count do 
        (
            local mtl = mdx.mtls[i]
            if ( i <= 24 and mtl.materialRef != undefined ) then
                meditMaterials[i] = mtl.materialRef
        )
    ),
    function CreateWC3Material mdx map index=
    (
        -- get shared texture folder
        local configFile = (getdir #temp) + "\\wc3tools.config"
        local sharedFolder = getinisetting configFile "WarcraftIII" "SharedTextureFolder"
        
        local mat = WarcraftIII_Standard()
        mat.name = mdx.modl.name + "_MATERIAL_" + ( index as string )
        local tex = mdx.texs[map.textureId + 1]
        
        mat.ReplaceableTexture = tex.ReplacableId + 1
        mat.Alpha = map.alpha * 100.0
        mat.FilterMode = map.filtermode + 1
        
        if( bit.and map.shadingflags 0x01 > 0) then mat.unshaded = true
        if( bit.and map.shadingflags 0x10 > 0) then mat.twosided = true
        if( bit.and map.shadingflags 0x20 > 0) then mat.unfogged = true
        if( bit.and map.shadingflags 0x40 > 0) then mat.nodepthset = true
        if( bit.and map.shadingflags 0x80 > 0) then mat.nodepthtest = true
        if( bit.and map.shadingflags 0x100 > 0) then mat.unselectable = true

        if ( tex.path != "") then 
        (
            local file_path = getFileNamePath mdx.fileName
            local file_name = getFileNameFile tex.path
            local fileName = file_path + file_name + ".TGA"
            
            if( doesfileexist fileName != true ) then
                if ( sharedFolder != undefined ) then fileName = sharedFolder + file_name + ".TGA"

            mat.Diffuse_Map = Bitmaptexture fileName:fileName  
        )

        if ( tex.path == "" and tex.ReplacableId == 2 ) then --> team glow
        (
            if ( sharedFolder != undefined ) then 
            (
                fileName = sharedFolder + "TeamGlow00.TGA"
                mat.Diffuse_Map = Bitmaptexture fileName:fileName
            )
        )
        
        -- Apply KMTA or Alpha Animation
        if ( map.KMTA != undefined ) then
        (
            local isGlobalSequence = false
            if (map.KMTA.glbsId > 0 ) then isGlobalSequence = true
            local startFrame = 10
            if isGlobalSequence then startFrame = 0
            
            local controller = Bezier_Float()
            if map.KMTA.LineType == 1 then controller = Linear_Float()
            if map.KMTA.LineType == 2 then controller = TCB_Float()
            if map.KMTA.LineType == 2 then controller = Bezier_Float()            
            
            mat.Alpha.controller = controller
            
            at time 0 mat.Alpha = 100.0
            for kg in map.KMTA.KG do
            (
                with animate on 
                    at time ( kg.Time + startFrame ) 
                        mat.Alpha = (kg.Point * 100.0 )
            )
        )
        
        -- Apply UVW animation 
        if mdx.TXAN != undefined then
        (
            if ( map.txanId > 0 ) then 
            (

                txan = mdx.TXAN[map.txanId]
                
                if ( txan.KTAT != undefined ) then
                (
                    mat.LineType = txan.KTAT.LineType + 1
                    
                    if mat.LineType == 2 then 
                    ( mat.Diffuse_Map.coords.u_offset.controller = Linear_Float()
                      mat.Diffuse_Map.coords.v_offset.controller = Linear_Float() )
                    
                    if mat.LineType == 3 or val == 1 then 
                    ( mat.Diffuse_Map.coords.u_offset.controller = Bezier_Float()
                      mat.Diffuse_Map.coords.v_offset.controller = Bezier_Float() )
                    
                    if mat.LineType == 4 then 
                    ( mat.Diffuse_Map.coords.u_offset.controller = TCB_Float()
                      mat.Diffuse_Map.coords.v_offset.controller = TCB_Float() )
                    
                    local isGlobalSequence = false
                    if (txan.KTAT.glbsId > 0 ) then isGlobalSequence = true
                    local startFrame = 10
                    if isGlobalSequence then startFrame = 0
                      
                    for kg in txan.KTAT.kg do
                    (
                        with animate on
                            at time ( kg.time + startFrame )
                            (
                                mat.Diffuse_map.coords.U_Offset = kg.point.X
                                mat.Diffuse_map.coords.V_Offset = kg.point.Y
                            )
                    )
                )
                
                
            )
        )
        
        
        return mat
    ),
    function BuildBonesAndHelpers mdx=
    (
        
        local boneLayer = GriffonStudios_Helpers.CreateLayer "Bones"
        local helpLayer = GriffonStudios_Helpers.CreateLayer "Helpers"
        
        mdx.objs = #()
        
        if mdx.bone != undefined then
        for b in mdx.bone do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.setBoneEnable false 0
            
            b.boneRef = aBone
            b.boneRef.pos = mdx.pivt[b.id].translationpart
            boneLayer.AddNode aBone
            
            mdx.objs[b.Id] = aBone
        )
        if mdx.help != undefined then
        for h in mdx.help do
        (
            local d = dummy name:h.name
            d.showLinks = true
            d.wirecolor = color 0 255 0
            helpLayer.addNode d
            d.pos = mdx.pivt[h.id].translationpart
            h.helperRef = d
            mdx.objs[h.id] = d
        )
        
    ),
    function BuildBONE800 mdx=
    (
        if mdx.bone == undefined then return undefined
        format "Building Bones\n"
        local boneList = mdx.bone
        local bpos = mdx.pivt
        
        -- build the hierarchy
        for b in boneList do
            if ( b.ParentBoneId > 0 ) then b.boneRef.parent = mdx.objs[b.parentBoneId]

        for obj in boneList do
        (
            local b = obj.boneRef

            -- lock the animation
            addNewKey b.controller 0
            for seq in mdx.seqs do
            (
                addnewkey b.scale.controller seq.startFrame
                addnewkey b.scale.controller seq.endFrame 
            )

            Warcraft_III_Helpers.ApplyUserProperties obj.flags b
            
            b.assumeSkinPose()

            -- Rotation
            if ( obj.KGRT != undefined ) then 
            (

                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                if b.parent != undefined then q0 = b.parent.transform
                local prevTime = 0
                
                for anim in obj.KGRT.KG do
                (
                    local t = anim.Time + 10
                    if obj.KGRT.glbsId > 0 then t = anim.Time
                    
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t --> prevent from applying multiple times the same rotation
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            
            -- Translation
            if ( obj.KGTR != undefined ) then
            (
                local dp = dummy name:"DummyPositionController" 
                dp.position.controller = b.position.controller
                local p0 = dp.transform
                
                --if b.parent != undefined then p0 = b.parent.transform
                local prevTime = 0

                for anim in obj.KGTR.KG do
                (
                    local t = anim.Time + 10
                    if obj.KGTR.glbsId > 0 then t = anim.Time
                        
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
            
            -- Scale
            if ( obj.KGSC != undefined ) then
            (
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in obj.KGSC.KG do
                (
                    local t = anim.Time + 10
                    if obj.KGSC.glbsId > 0 then t = anim.Time
                        
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                             in coordsys p0 
                                ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )
            
        )
    ),
    function BuildHELP800 mdx=
    (
        if mdx.help == undefined then return undefined
        format "Building Helpers\n"
        for h in mdx.help do
        (
            local d = h.helperRef
            
            Warcraft_III_Helpers.ApplyUserProperties h.flags d
            
            if( h.parentId > 0 ) then 
                d.parent = mdx.objs[h.parentId]
            
            -- lock the animation
            addNewKey d.controller 0
            for seq in mdx.seqs do
            (
                addnewkey d.scale.controller seq.startFrame
                addnewkey d.scale.controller seq.endFrame 
            )
            
            d.assumeSkinPose()

            if ( h.KGRT != undefined ) then 
            (
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = d.rotation.controller
                local q0 = dr.transform
                if d.parent != undefined then q0 = d.parent.transform
                local prevTime = 0
                
                for anim in h.KGRT.KG do
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
                with animate on d.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            if ( h.KGTR != undefined ) then
            (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = d.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in h.KGTR.KG do
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
                    with animate on d.position.controller = copy dp.position.controller
                    
                    delete dp
            )
            
            if ( h.KGSC != undefined ) then
            (
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = d.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in h.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t

                    with animate on 
                        at time t
                        (
                            in coordsys p0 
                                ds.scale = p 
                        )
                )
                with animate on d.scale.controller = copy ds.scale.controller
                
                delete ds
            )
        )
        
    ),
    function BuildEVTS800 mdx=
    (
        if mdx.evts == undefined then return undefined
        format "Building Events\n"
        local evts = mdx.evts
        
        if (evts == undefined ) then return undefined
        local layer = GriffonStudios_Helpers.CreateLayer "Events"
        
        for evt in evts do
        (
            local pnt = WarcraftIII_Event()  -- point name:evt.Name
            
            pnt.Name = evt.name
            
            pnt.pos = mdx.pivt[evt.id].translationpart
            
            if ( evt.parentId > 0 ) then 
                pnt.pos = mdx.pivt[evt.parentId].translationpart
            
            for key in evt.KEVT do
                append pnt.keyList key
            
            evt.objRef = pnt
            layer.AddNode pnt
        )
        
    ),
    function BuildCLID800 mdx=
    (
        if mdx.clid == undefined then return undefined
        format "Building Collision Objects\n"
        local bpos = mdx.pivt
        local layer = GriffonStudios_Helpers.CreateLayer "Collision Objects"
        
        for cl in mdx.clid do
        (
            local clObj = undefined
            
            -- CUBE
            if(cl.CollisionType == 0 ) then 
            (
                local diameter = distance cl.startPosition cl.EndPosition
                local radius = diameter / 2.0 * 0.8
                clObj = Sphere radius:radius name:cl.name pos:cl.startPosition
            )
            
            -- PLANE
            if(cl.CollisionType == 1 ) then 
            (
                local x = distance [cl.startPosition.x,0,0] [cl.EndPosition.x,0,0]
                local y = distance [0,cl.startPosition.y,0] [0,cl.EndPosition.y,0]
                
                clObj = Plane length:x width:y name:cl.name pos:cl.startPosition
            )
            
            -- SPHERE
            if(cl.CollisionType == 2 ) then
            (
                clObj = Sphere radius:cl.Radius name:cl.name pos:cl.startPosition
            )
            
            -- Cylinder
            if(cl.CollisionType == 3 ) then
            (
                local height = distance [0, 0, cl.startPosition.z] [0, 0, cl.endPosition.z]
                clObj = Cylinder radius:cl.Radius name:cl.name pos:cl.startPosition height:height heightsegs:1 sides:12
            )
            
            
            if clObj == undefined then return undefined

            clObj.pos = mdx.pivt[cl.id].translationpart
            
            --print cl
            
            if cl.parentId > 0 then cl.parent = mdx.bone[cl.parentId].boneRef
            
            local mtrx = bpos[cl.id]    
            
            if ( cl.KGRT != undefined ) then 
            (
                
                for anim in cl.KGRT.KG do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx clObj.rotation = q
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
                    
                    with animate on at time t in coordsys mtrx clObj.pos = p
                )
                    
            )
            
            clObj.boxmode = true
            clObj.wirecolor = color 64 128 255
            clObj.renderable = off
            clObj.castShadows = off
            clObj.receiveshadows = off
            clObj.ApplyAtmospherics = off
            clObj.inheritVisibility = off
            clObj.primaryVisibility = off
            clObj.secondaryVisibility = off
            setUserProp clObj "COLLISION-OBJECT" true
            freeze clObj
            layer.addnode clObj
        )
    ),
    function BuildATCH800 mdx=
    (
        
        if mdx.atch == undefined then return undefined
        format "Building Attachments\n"
        local layer = GriffonStudios_Helpers.CreateLayer "Attachments"
        sliderTime = 0f
        
        for a in mdx.atch do
        (
        
            local pnt = WarcraftIII_Attachment name:a.name
            pnt.pos = mdx.pivt[a.id].translationpart
            layer.AddNode pnt
            
            if ( a.ParentBoneId > 0 ) then
                pnt.parent = mdx.objs[a.ParentBoneId]

        )
        
    ),
    function BuildMODL800 mdx=
    (
        format "Building base models\n"
        local layer = GriffonStudios_Helpers.CreateLayer "Bounding Box"
        
        local obj = GriffonStudios_Helpers.BuildBoundingBox mdx.modl.bbox
        obj.name = "MODL - " + mdx.modl.name
        freeze obj
        obj.boxmode = true
        obj.wirecolor = color 100 100 100
        layer.addNode obj
        
        if mdx.modl.radius > 0 then 
        (
            local pos = obj.max.z/2.0
            local obj2 = sphere name:"Selection_Sphere" radius:mdx.modl.radius pos:[0,0,pos]
        
            freeze obj2
            obj2.boxmode = true
            obj2.wirecolor = color 150 10 10
            obj2.castShadows = off
            obj2.receiveshadows = off
            layer.addNode obj2
        )
        
        
    ),
    function ApplySkinning mdx=
    (
        format "Apply Skinning (this may take some time )\n"
        completeRedraw()
        for geo in mdx.geos do
        (
            -- get a reference to the scene mesh
            local obj = geo.meshRef
            
            -- apply the skin modifier
            max modify mode
            mshSkin = skin()
            addmodifier obj mshSkin
            select obj
            modPanel.setCurrentObject mshSkin
        
            -- add the bones to the modifier
            for uniqueBoneId in geo.uniqueBoneIds do
            (
                local b = mdx.bone[uniqueBoneId].boneRef
                skinOps.addBone mshSkin b 0
            )
            update obj
            
            for v=1 to obj.verts.count do -- geo.VRTX.count do
            (
                local gndx = geo.GNDX[v]
                local boneRefIds = geo.bones[gndx]
                local boneIds = #()
                for boneRefId in boneRefIds do 
                (
                    for u=1 to geo.uniqueBoneIds.count do
                    (
                        local uniqueId = geo.uniqueBoneIds[u]
                        if uniqueId == boneRefId then append boneIds u
                    )
                )
                
                local weights = #()
                local weight = 1.0 / boneIds.count
                for i=1 to boneIds.count do
                    append weights weight
                
               -- skinOps.SetVertexWeights mshSkin v boneIds weights
                
                skinOps.ReplaceVertexWeights mshSkin v boneIds weights
                
            )
            update obj
        )
        completeRedraw()
        
    ),
    function BuildCAMS800 mdx=
    (
        if mdx.cams == undefined then return undefined  
        format "Building Cameras \n"
        local layer = GriffonStudios_Helpers.CreateLayer "Cameras"
        
        for i=1 to mdx.cams.count do
        (
            local c = mdx.cams[i]
            local targetName = c.name + ".Target." + ( i as string)
            local camName = c.name + ( i as string)
            local target = Targetobject pos:c.targetPos name:targetName wirecolor:red 
            local cam = Targetcamera fov:c.FOV farclip:c.farClip nearclip:c.nearClip pos:c.camPos name:camName wirecolor:yellow target:target
            layer.AddNode target
            layer.AddNode cam
        )
        
        
    ),
    function BuildGEOA800 mdx=
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
    function BuildRIBB800 mdx=
    (
        if mdx.ribb == undefined then return undefined  
        format "Building Ribbons \n"
        local layer = GriffonStudios_Helpers.CreateLayer "Ribbons"    
        
        for r in mdx.ribb do
        (    
            local ribbon = WarcraftIII_Ribbon()
            layer.addNode ribbon
            
            ribbon.name = r.name
            ribbon.pos  = mdx.pivt[r.id].translationPart
            
            ribbon.staticHeightAbove = r.above
            ribbon.staticHeightBelow = r.below
            ribbon.staticAlpha       = r.vAlpha
            ribbon.staticColor       = r.vColor
            ribbon.lifeSpan          = r.edgesLife
            ribbon.emissionRate      = r.edgesSec
            ribbon.flipbookRows      = r.flipbookRows
            ribbon.flipbookColumns   = r.flipbookCols
            ribbon.flipbookSlot      = r.flipBookSlot
            ribbon.gravity           = r.gravity
            
            if ( r.ParentId > 0 ) then ribbon.parent = mdx.objs[r.parentId]
            if ( mdx.mtls != undefined) then ribbon.mtlsId = mdx.mtls[r.mtlsId].materialRef
            
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
            -- slot
            if ( r.KRTX != undefined ) then
            for anim in r.KRTX.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.flipbookSlot = p
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
    function BuildGLBS800 mdx=
    (
        if mdx.glbs == undefined or mdx.glbs.count == 0 then return undefined
        format "Building Global Sequence Behaviors\n"
        
        /*
            The actual frame from the mdx is NOT used
            The global animation always starts at frame 0 and the last frame on the trackbar is used for export
        */
        local listOfObjects = #()
        
        for i=1 to mdx.BONE.count do
        (
            if (mdx.BONE[i].KGSC != undefined ) then
                if (mdx.BONE[i].KGSC.glbsId  > 0 ) then 
                    appendifUnique listOfObjects mdx.BONE[i].boneRef
            
            if (mdx.BONE[i].KGRT != undefined ) then
                if (mdx.BONE[i].KGRT.glbsId  > 0 ) then 
                    appendifUnique listOfObjects mdx.BONE[i].boneRef
            
            if (mdx.BONE[i].KGTR != undefined ) then
                if (mdx.BONE[i].KGTR.glbsId  > 0 ) then 
                    appendifUnique listOfObjects mdx.BONE[i].boneRef
            
        )
        
        for i=1 to mdx.MTLS.count do
        (
            for map in mdx.MTLS[i].maps do
            (
                if map.txanId > 0 then 
                (
                    for obj in objects do
                        if obj.material == mdx.MTLS[i].materialRef then appendifUnique listOfObjects obj
                    
                    
                )
            )

        )
        if WC3_MDX800_DEBUG then print listOfObjects
        
        if listOfObjects.count > 0 then
        (
            local layer = GriffonStudios_Helpers.CreateLayer "Global Sequence"  
            local behavior = WarcraftIII_Behavior()
            layer.addNode behavior
            behavior.listOfObjects = listOfObjects
        )
    ),
    function Import file=
    (
        clearlistener()
        SetWaitCursor()
        animationrange = interval 0 600
        slidertime = 0
        local stream = fOpen file "rb"
        if ( doesFileExist file != true or stream == undefined ) then return undefined
        local streamLen = GriffonStudios_Helpers.GetStreamLength stream
        
        format "Debug mode: %\n" WC3_MDX800_DEBUG
        format "Read only mode: %\n" WC3_READONLY
        
        struct mdx800 
            ( tags, fileName, vers, modl, seqs, glbs, mtls, texs, geos, geoa, 
              bone, help, atch, pivt, evts, clid, cams, ribb, pre2, prem, lite, txan,
              objs= #() )
        
        local mdx = mdx800()
        mdx.fileName = file
        mdx.tags = WC3_MDX800.ReadTAGS800 stream streamLen
        
        for tag in mdx.tags do 
        (
            if tag.name == "VERS" then mdx.vers = WC3_MDX800.ReadVERS800 stream tag --> Version number
            if tag.name == "MODL" then mdx.modl = WC3_MDX800.ReadMODL800 stream tag --> Model properties
            if tag.name == "SEQS" then mdx.seqs = WC3_MDX800.ReadSEQS800 stream tag --> Animation Sequences
            if tag.name == "GLBS" then mdx.glbs = WC3_MDX800.ReadGLBS800 stream tag --> Global Sequences
            if tag.name == "MTLS" then mdx.mtls = WC3_MDX800.ReadMTLS800 stream tag --> Materials
            if tag.name == "TEXS" then mdx.texs = WC3_MDX800.ReadTEXS800 stream tag --> Textures
            if tag.name == "TXAN" then mdx.txan = WC3_MDX800.ReadTXAN800 stream tag --> Texture Animations
            if tag.name == "GEOS" then mdx.geos = WC3_MDX800.ReadGEOS800 stream tag --> Geometry Sets
            if tag.name == "GEOA" then mdx.geoa = WC3_MDX800.ReadGEOA800 stream tag --> Geometry Animatons
            if tag.name == "BONE" then mdx.bone = WC3_MDX800.ReadBONE800 stream tag --> Bone structure
            if tag.name == "HELP" then mdx.help = WC3_MDX800.ReadHELP800 stream tag --> Animation Helpers
            if tag.name == "ATCH" then mdx.atch = WC3_MDX800.ReadATCH800 stream tag --> Attachment Points
            if tag.name == "PIVT" then mdx.pivt = WC3_MDX800.ReadPIVT800 stream tag --> Pivot Points
            if tag.name == "EVTS" then mdx.evts = WC3_MDX800.ReadEVTS800 stream tag --> Events
            if tag.name == "CLID" then mdx.clid = WC3_MDX800.ReadCLID800 stream tag --> Collision Definition
            if tag.name == "LITE" then mdx.lite = WC3_MDX800.ReadLITE800 stream tag --> Lights
            if tag.name == "CAMS" then mdx.cams = WC3_MDX800.ReadCAMS800 stream tag --> Cameras
            if tag.name == "RIBB" then mdx.ribb = WC3_MDX800.ReadRIBB800 stream tag --> Ribbon Emitters
            if tag.name == "PREM" then mdx.prem = WC3_MDX800.ReadPREM800 stream tag --> Particle Emitters
            

            /*
            TODO:
              PRE2
            */

        )
        
        fclose stream
        if WC3_MDX800_DEBUG then WC3_MDX = mdx
        if WC3_READONLY == false then 
        (
            WC3_MDX800.BuildMODL800 mdx
            WC3_MDX800.BuildGEOS800 mdx
            WC3_MDX800.BuildSEQS800 mdx
            WC3_MDX800.BuildAndAssignMaterials mdx --> Builds/uses MTLS & TEXS & TXAN
            WC3_MDX800.BuildBonesAndHelpers mdx
            WC3_MDX800.BuildHELP800 mdx
            WC3_MDX800.BuildBONE800 mdx
            WC3_MDX800.BuildEVTS800 mdx
            WC3_MDX800.BuildCLID800 mdx
            WC3_MDX800.ApplySkinning mdx
            WC3_MDX800.BuildATCH800 mdx
            WC3_MDX800.BuildCAMS800 mdx
            WC3_MDX800.BuildGEOA800 mdx
            WC3_MDX800.BuildRIBB800 mdx
            WC3_MDX800.BuildLITE800 mdx
            WC3_MDX800.BuildGLBS800 mdx
            /*
            TODO:
              PREM
              PRE2
            */
            
        )
        format "Done!\n"
        gc()
        clearSelection()
        max tool zoomextents all --> zoom out
        setArrowCursor() 
    )
)



-- Example RIBB : F:\Blizzard\Warcraft III\Extracted\Units\Undead\Shade\Shade.mdx

-- WC3_MDX800_DEBUG = false
-- WC3_READONLY = false
-- WC3_DEBUG = false
-- WC3_MDX = undefined

-- KMTA : 
--  WC3_MDX800.Import @"F:\Blizzard\Warcraft III\Extracted\Units\Undead\Necromancer\Necromancer.mdx"

-- KMTF :
-- WC3_MDX800.Import @"F:\Blizzard\Warcraft III\Extracted\Units\Creeps\SeaElemental\SeaElemental.mdx"



-- Tests --
-- WC3_MDX800.Import @"F:\Blizzard\Warcraft III\Extracted\Units\Creeps\LavaSpawn\LavaSpawn.mdx"
-- WC3_MDX800.Import @"F:\Blizzard\Warcraft III\Extracted\Doodads\Dungeon\Props\SewerVent\SewerVent1.mdx"
-- WC3_MDX800.Import @"F:\Blizzard\Warcraft III\Extracted\Units\Demon\Infernal\Infernal.mdx"
-- WC3_MDX800.Import @"F:\Blizzard\Warcraft III\Warcraft III Models\Abomination\Abomination.mdx"
--WC3_MDX800.Import @"F:\Blizzard\Warcraft - Reforged\Warcraft III\Spartan Warrior\Spartan Warrior\SpartanWarrior.mdx"
-- WC3_MDX800.Import @"F:\Blizzard\Warcraft - Reforged\Warcraft III\Paladin (Sword)\Paladin (Sword)\PaladinSword.mdx"

