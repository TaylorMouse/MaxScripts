clearlistener()

(
    function ReadMTLS800 stream tag=
    (
        fseek stream tag.offset #seek_set
        local totalSize = tag.size
        
        local id = 1
        
        local layers = #()
        
        while ( totalSize > 0 ) do
        (
            local lay = Warcraft3_Reforged_LAYS()
            
            local lays_size     = readLong stream
            local priorityPlane = readLong stream
            local flags         = readLong stream
            local lays          = GriffonStudios_Helpers.ReadFixedString stream 4
            local nLays         = readLong stream
            
            for i=1 to nLays do
            (
                local layerSize   = readLong stream --> 28 bytes
                lay.filterMode    = readLong stream + 1
                lay.shadingFlags  = readLong stream + 1
                lay.textureId     = readLong stream + 1
                lay.parentId      = readLong stream + 1
                lay.CoordId       = readLong stream
                lay.alpha         = readfloat stream
             
                if (layerSize > 28 ) then
                (
                    for x=1 to 2 do
                    (
                        local km = GriffonStudios_Helpers.ReadFixedString stream 4
                        if ( km == "KMTA" ) then lay.KMTA = Warcraft3_Reforged.ReadFloatAnim stream
                        if ( km == "KMTE" ) then lay.KMTE = Warcraft3_Reforged.ReadFloatAnim stream
                        
                    )
                    if ( lay.KMTA == undefined ) then fseek stream -4 #seek_cur
                    if ( lay.KMTE == undefined ) then fseek stream -4 #seek_cur
                )
            )
            totalSize -= lays_size
            
            id +=1
            
            append layers lay
        )
        
    )
    
    function ReadGEOS800 stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local total_size = tag.size
        local geos = #()
        while ( total_size > 0 ) do
        (
            local geo = Warcraft3_Reforged_GEO() 
            local chunk_size = readLong stream
            local offset = ( ftell stream )
            
            for h=1 to 11 do
            (
                local header = GriffonStudios_Helpers.ReadFixedString stream 4
                
                if header == "VRTX" then 
                    for v=1 to (readLong stream) do append geo.vrtx (Warcraft3_Reforged.ReadVector3 stream)

                if header == "NRMS" then 
                    for v=1 to (readLong stream) do append geo.nrms (Warcraft3_Reforged.ReadVector3 stream)

                if header == "PTYP" then 
                    for v=1 to (readLong stream) do append geo.ptyp (readLong stream)
                
                if header == "PCNT" then 
                    for v=1 to (readLong stream) do append geo.pcnt (readLong stream)
                
                if header == "PVTX" then 
                    for v=1 to (readLong stream)/3 do append geo.pvtx (Warcraft3_Reforged.ReadTris stream)
                
                if header == "GNDX" then
                    for v=1 to (readLong stream) do append geo.gndx (readbyte stream + 1)
                
                if header == "MTGC" then 
                    for v=1 to (readLong stream) do append geo.mtgc (readLong stream)
                
                if header == "MATS" then 
                (
                    local mats = Warcraft3_Reforged_MATS()
                    
                    mats.matrices = #()
                    for v=1 to (readLong stream) do append mats.matrices (readLong stream)
                    
                    mats.Id = readlong stream
                    GriffonStudios_Helpers.SkipBytes stream 8
                    for i=1 to 7 do readfloat stream
                    
                    local unk = readLong stream
                    for i=1 to unk do GriffonStudios_Helpers.SkipBytes stream 28
                    
                )
              
                if header == "UVAS" then 
                (
                    for i=1 to (readLong stream) do
                    (
                        local uvs = #()
                        local uvbs = GriffonStudios_Helpers.ReadFixedString stream 4
                        local nUvbs = readLong stream

                        for u=1 to nUvbs do
                            append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )

                        append geo.UVS uvs
                    )
                )
            )

            append geos geo
            fseek stream offset #seek_set
            GriffonStudios_Helpers.SkipBytes stream (chunk_size - 4)
            
            print ( ftell stream) 
            
            total_size -= chunk_size
        )
        
        return geos
        
    )
    local file = @"D:\Downloads\Ogron\Ogron Teal\OgronTeal.Mdx"
    local stream = fOpen file "rb"
    local streamLen = GriffonStudios_Helpers.GetStreamLength stream
    
    local tags = Warcraft3_Reforged.ReadTags stream streamLen
    
    local geos_tag = undefined
    for tag in tags do 
    (
        if tag.name == "GEOS" then geos_tag = tag
     
    )
    print geos_tag
    local geos = ReadGEOS800 stream geos_tag
    print geos
    
    
    fclose stream
)
