
(
    struct DBC ( head, records )
    struct HEADER
    (
        fileID, nRecords, nFields, recordSize, stringBlockSize,
        
        fn Read bitStream =
        (
            local head = HEADER()
            head.fileID = ReadFixedString bitStream 4
            head.nRecords = ReadLong bitStream #unsigned
            head.nFields = ReadLong bitStream #unsigned
            head.recordSize = ReadLong bitStream #unsigned
            head.stringBlockSize = ReadLong bitStream #unsigned
            
            return head
        )
    )
    struct AnimField
    (
        animID, name, WeaponState, flags, d1, parentAnimID, realID, aGroup,
        
        fn Read bitStream head =
        (
            local dbcrecords = #()
            dbcrecords[head.nRecords] = 0
            str_ofs = (head.recordSize * head.nRecords) + 20 --header size
            for i = 1 to head.nRecords do
            (
                local af = AnimField()
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
    local dbcfile = @"G:\Blizzard\World Of Warcraft\Exported\dbfilesclient\AnimationData.db2"
    
    --local dbcfile = @"G:\Blizzard\World Of Warcraft\Exported\AnimationData.dbc"
    local dbcstream = fopen dbcfile "rb"
    local adbc = DBC()

    adbc.head = HEADER.Read dbcstream
    adbc.records = AnimField.Read dbcstream adbc.head
    
    for i=1 to adbc.records.count do
        format "%-%\n" adbc.records[i].AnimId adbc.records[i].Name
    
    if (dbcstream != undefined) then fclose dbcstream


)