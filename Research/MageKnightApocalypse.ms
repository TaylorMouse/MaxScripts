
(
    clearlistener()
    function SkipBytes stream nbrToSkip = 
    (
        fseek stream nbrToSkip #seek_cur
    )
        
    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if(s!="\0") then str+=s
        )
        return str
    )

    f = @"D:\Games\Mage Knight Apocalypse\model\unique_warstaff_1z.gm3"

    local stream = fopen f "rb"

    local header = readFixedString stream 32
    local version = readLong stream
    
    local materialInfo  = readFixedString stream 16 
    local matOffset     = readLong stream
    local matSize       = readLong stream
    
    local modelInfo     = readFixedString stream 16
    local modelOffset   = readLong stream
    local modelSize     = readLong stream
    
    -- vertexWeight
    local vwInfo        = readFixedString stream 16
    local vwOffset      = readLong stream
    local vwSize        = readLong stream

    -- bone
    local boneInfo        = readFixedString stream 16
    local boneOffset      = readLong stream
    local boneSize        = readLong stream

    fSeek stream modelOffset #seek_set
    modelInfo     = readFixedString stream 16
    local totalNbrFaces = readLong stream
    local nbrMeshes      = readLong stream
    local nbrMeshes2     = readLong stream
    local offset_x       = readLong stream
    local totalNbrVerts  = readLong stream
print nbrMeshes2
    local objHeader      = readFixedString stream 13

    local meshes = #()
    struct mageknight_mesh ( name, nFaces, nVerts, faceType, vertices = #(), faces = #(), normals =#(), uvs = #()  )
    for i=1 to nbrMeshes do -- 156
    (
        local m = mageknight_mesh()
        m.name = readFixedString stream 32
        
        SkipBytes stream 84
        m.nFaces = readLong stream

        m.faceType = readLong stream
        SkipBytes stream 4
        m.nVerts = readLong stream
        SkipBytes stream 24

        append meshes m
    )

    local vertexList = readFixedString stream 11

    for m in meshes do
    (
        for i = 1 to m.nVerts do
        (
            append m.vertices [readFloat stream, readFloat stream, readFloat stream]
            
            append m.normals [readFloat stream, readFloat stream, readFloat stream]
            SkipBytes stream 40
            append m.uvs [readFloat stream, 1 - readFloat stream, 0]
            
            SkipBytes stream 8
        )
    )

    local faceList = readFixedString stream 9
    for m in meshes do
    (
        for i=1 to m.nFaces do
        (
            local a = readLong stream #unsigned + 1
            local b = readLong stream #unsigned + 1
            local c = readLong stream #unsigned + 1
            
            append m.faces [a, b, c]
            
        )
    )
    
    for m in meshes do
    (
        local theMesh = mesh name:m.name vertices:m.vertices faces:m.faces tverts:m.uvs vnorms:m.Normals
        
        theMesh.WireColor = Color (random 0 128) (random 0 255) (random 0 128)
        meshOp.setMapSupport theMesh 1 true
        
        for t = 1 to m.vertices.count do
            meshop.setMapVert theMesh 1 t m.uvs[t]
        update theMesh
        
    )
    fClose stream
    gc()
)