/*
    mef
*/
struct Griffon_Studios_Helpers
(
    function GetStreamLength stream =
    (
        local currentPos = ftell stream
        fseek stream 0 #seek_end
        local streamLen = ftell stream
        
        fseek stream currentPos #seek_set
        
        return streamLen
    ),
    function ReadFourCC stream =
    (

        local str = ""

        for i=1 to 4 do
        (
            s= bit.IntAsChar(ReadByte stream)

            if ( s !="\0") then str = s + str
        )
        return str

    ),
    function SkipBytes stream nBytesToSkip=
    (
        /* Skip n-bytes without reading them into memory */
        fseek stream nBytesToSkip #seek_cur
    )    
)

/*
MESH 
ATTA --> 68 bytes per part -> 16 byte name
MVTX 
PORT 
PTVX 
PTFC 
RD3D 
REND  
VRTX  
LTMP 
CMSH 
CVTX  
CFCE  
CMAT  
CSPH  
CVTX  
CFCE  
CMAT 
CSPH 


*/
clearlistener()
(
    g = Griffon_Studios_Helpers()

    file = @"412_01_1.mef"

    stream = fOpen file "rb"

    streamLen = g.GetStreamLength stream
    format "Stream length %\n" streamLen
    _ILFF     = g.ReadFourCC stream
    fileSize = readlong stream
    version  = readLong stream
    miniSize = readLong stream
    
    _MECO     = g.ReadFourCC stream

    savedPos  = ftell stream
    print savedPos
    tagSize = 0
    i=0
    
    vertices = #()
    normals = #()
    uvs = #()
    
    struct tag ( name, size, offset )
    struct mesh_definition ( nbrFaces, nbrVertices ) 
    
    tags = #()
    mesh_definitions = #()
    
    while ( true ) do
    (
        t = tag()
        
        t.name     = g.ReadFourCC stream
        t.size     = readLong stream
        tagVersion = readLong stream
        tagSize    = readLong stream
        t.offset   = ftell stream
        chunkSize = t.size + 16

        if ( t.name == "CMSH" ) then
        (
            nbrMeshDefinitions = t.Size / 32
            format "nbr Submeshes %\n" nbrMeshDefinitions
            for i=1 to nbrMeshDefinitions do
            (
                md = mesh_definition()
                md.nbrFaces = readLong stream
                md.nbrVertices = readLong stream
                unk1 = readLong stream
                unk2 = readLong stream
                g.SkipBytes stream 16 --> zeroes
                
                append mesh_definitions md
                format "%\n" md
            )
        )
        
        if ( t.name == "CVTX" ) then
        (
            vertices = #()
            
            for i=1 to t.size/16 do
            (
                append vertices [readFloat stream, readFloat stream, readFloat stream]
                readFloat stream
            )
        )

        if ( t.name == "CFCE" ) then
        (
            faces = #()
            
            for i=1 to t.size/8 do
            (
                append faces [readshort stream + 1, readshort stream + 1, readshort stream + 1]
                readshort stream
            )
            mesh vertices:vertices faces:faces
        )
        
        fseek stream ( savedPos + chunkSize ) #seek_set 
        savedPos  = ftell stream

        format "%\n" t
        append tags t
        if ( savedPos + 5 > streamLen ) then exit
                
    )

    closed = fclose stream
)