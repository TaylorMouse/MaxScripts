fileIn "GriffonStudios_HelperScripts.ms"
clearlistener()

function ImportImmortalMesh f=
(
    struct _submesh ( startIndex, nIndices, startVertex, nVertices )
    
    local stream = fOpen f "rb"
    local fourtySix = readByte stream as integer
    local messia = ReadFixedString stream 7

    local h = readlong stream
    if ( h==1 ) then return undefined
    
    local dataSize  = readLong stream
    local zeroo     = readShort stream
    local nMeshes   = readshort stream
    local nVertices = readLong stream
    local nIndices  = readLong stream
    
    for i = 1 to 4 do  (
        local len = readshort stream
        local type = ReadFixedString stream len
    )

    for i= 1 to 10 do readfloat stream 

    submeshes = #()
    for m = 1 to nMeshes do 
    (
        local s = _submesh()
        s.startIndex     = readlong stream / 3 
        s.nIndices       = readlong stream / 3
        s.startVertex    = readlong stream
        s.nVertices      = readlong stream
        append submeshes s
    )

    
    local allFaces = #()
    for i=1 to nIndices/3 do 
        append allFaces [readshort stream + 1, readshort stream + 1, readshort stream + 1]

    local allVertices = #()
    for i=1 to nVertices  do (
        local x = readFloat stream
        local z = readFloat stream
        local y = readFloat stream
        local v =  [x,y,z] * 50
        append allVertices v
    )

    local something = #()
    local allUvs = #()
    for i=1 to nVertices  do (
        local s =  [ReadHalfFloat stream, ReadHalfFloat stream, ReadHalfFloat stream, ReadHalfFloat stream ] 
        append something s
         
        local uv = [ReadHalfFloat stream, ReadHalfFloat stream, 0]
        append allUvs uv

    )

    local indexBones = #()
    local weightBones = #()
    for i=1 to nVertices do (
        append weightBones ( [readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned] )
        append indexBones ( [readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned] )
    )
    
        
    local theMesh = mesh vertices:allvertices faces:allfaces tverts:alluvs
    local c = random 10 200
    local wireColor = color c c c
    theMesh.WireColor = wireColor
            
    buildTVFaces theMesh false
    for i = 1 to allfaces.count do
        ( setTVFace theMesh i allfaces[i] )
        
    update theMesh
    
    ftell stream
    fClose stream

)

(
    local f = getOpenFileName \
                    caption:"Diablo Immortal" \
                    types:"Supported Files|*.Mesh|Diablo Immortal(*.Mesh)|*.Mesh|All Files|*.*" \
                    historyCategory:"ImmortalPreset"

    -- f = @"G:\Blizzard\Diablo Immortal\Extracted\Char\barbarian\Mesh_m_barbarian_yifu_t04_001_aw3.Mesh"
    ImportImmortalMesh f
)