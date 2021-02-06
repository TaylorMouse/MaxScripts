/*


*/
struct DOW_III_HelperScripts
(
    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    ),
    function ReadHexLength stream len=
    (
        local result = ""
        for i=1 to len do
        (
            local val = readByte stream #unsigned
            local str = toUpper ( ( bit.IntAsHex val ) as string )
            
            if( str.count != 2) then
            (
                str = substring ( "00" + str ) 2 2
            )
            
            
            result = result +  str
        )
        
        
        return result
    ),
    function ReadDoWString stream=
    (
        local val = readLong stream
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
        fseek stream nBytesToSkip #seek_cur
    ),
    function ReadDoWChunk stream=
    (
        struct dow_chunk ( header, name, size,  data_offset, one, data )
        
        local dh = dow_chunk()
        dh.header = DOW_III_HelperScripts.ReadFixedString stream 8
        dh.one = readLong stream
        dh.size = readLong stream
        dh.name = DOW_III_HelperScripts.ReadDoWString stream
        dh.data_offset = ftell stream
        
        print dh
        
        return dh
    ),
    function ReadData stream chunk=
    (
        local help = DOW_III_HelperScripts()
        if (chunk.header == "DATABMSH" ) then
            help.ReadBasicMesh stream chunk
        else
        (
            fseek stream chunk.data_offset #seek_set
        
            DOW_III_HelperScripts.SkipBytes stream chunk.size --> for now
        )
    ),
    function ReadBasicMesh stream chunk=
    (
        fseek stream chunk.data_offset #seek_set
    
        struct basic_mesh_data ( vertices, faces )
        
        local nbrVertices = readLong stream
        local nbrIndices = readLong stream
        
        local vertices = #()
        for v=1 to nbrVertices do
            append vertices [readFloat stream, readFloat stream, readFloat stream]
        
        local faces = #()
        for i= 1 to nbrIndices by 3 do
            append faces [readShort stream + 1, readShort stream + 1, readShort stream + 1]
        
        chunk.data = basic_mesh_data vertices:vertices faces:faces
        
    ),
    function Build chunk=
    (
        local help = DOW_III_HelperScripts()
        if (chunk.header == "DATABMSH" ) then help.BuildBasicMesh chunk
            
        
    ),
    function BuildBasicMesh chunk=
    (
        
        local theMesh = mesh name:chunk.name vertices:chunk.data.vertices faces:chunk.data.faces
        
    )
        
)

function DOW_III_Import_DGM file =
(
    local help = DOW_III_HelperScripts()
    
    local stream = fOpen file "rb"
    
    /* READ */
    local Relic_Chunky = help.ReadFixedString stream 12
    format "%\n" Relic_Chunky
    
    local Relic_ID = help.ReadHexLength stream 4
    format "  Relic ID: %\n" Relic_ID
    
    local majorVersion = readLong stream
    local minorVersion = readLong stream
    format "  Version: %.% \n" majorVersion minorVersion
    
    local currentPos = ftell stream
    
    fseek stream 0 #seek_end
    local streamSize = ftell stream
    fseek stream currentPos #seek_set
    
    local chunks = #()
    
    -- FOLDMODL
    local chunk = help.ReadDoWChunk stream
    append chunks chunk
    
    while ( ftell stream < streamSize )  do
    (
        local chunk = help.ReadDoWChunk stream
        DOW_III_HelperScripts.SkipBytes stream chunk.size
        
        append chunks chunk
        
    )
    
--     
--     local FOLDMSHL = help.ReadDoWChunk stream
--     local DATAMSLI = help.ReadDoWChunk stream
--     help.ReadData stream DATAMSLI
--     
--     local DATAMSHI = help.ReadDoWChunk stream
--     help.ReadData stream DATAMSHI

--     local DATABMSH = help.ReadDoWChunk stream
--     help.ReadData stream DATABMSH
    
    fClose stream
    
    /* CREATE */
--     help.Build DATABMSH
    
    
)

clearlistener()
file = @"G:\Game Dev\3D Models\Game Models\DOW III\Extracted\art\armies\space_marines\troops\space_marine\armour\powerarmour_mk7_damage_common\powerarmour_mk7_damage_common.rpb"
--file = @"G:\Game Dev\3D Models\Game Models\DOW III\Extracted\art\environment\cubus\cubus_tech\ct_eye.dgm"

--DOW_III_Import_DGM file