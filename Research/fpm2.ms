function SkipBytes stream nBytesToSkip= 
( fseek stream nBytesToSkip #seek_cur )

function ReadZeroEndingString stream=
(
    local str = ""
    local canRead = true
    while (canRead) do
    (
        local b = ReadByte stream
        s= bit.IntAsChar(b)
        
        if ( b != 0 ) then str+=s else canRead = false
    )
    return str
)

clearListener()
file = @"C:\Users\Mario\Downloads\WP_ARC_Stone_Plaque.fpm"

stream = fOpen file "rb"

-- mapnames
fSeek stream 236 #seek_set
mapnameOffsets = #()
for i=1 to 3 do append mapnameOffsets ( ReadLong stream )

mapnames = #()
for i=1 to 3 do
(
    fSeek stream nameOffsets[i] #seek_set
    append mapnames ( ReadZeroEndingString stream )
)
print mapnames

-- vertices ?
fSeek stream 640 #seek_set
-- 42 found on 614
verts = #()
colors = #()
uvs = #()
normals = #()
for i=1 to 42 do
(
    append verts ( [readfloat stream, readfloat stream, readfloat stream] * 50.0 )
    append colors [readbyte stream, readbyte stream, readbyte stream, readbyte stream]
    
    append normals [readfloat stream, readfloat stream, readfloat stream]
    
    SkipBytes stream 24
    append uvs [readfloat stream, readfloat stream, 0.0]
)

--fSeek stream 3168 #seek_set
fSeek stream 3168 #seek_set
indices = #()
for i=1 to 87 do --87
(
    append indices (readshort stream + 1)
)
--print indices


faces = #()
backfaceCullingIssue = 0
for i=0  to 86  do
(
    local a = indices[i+1]
    local b = indices[i+2]
    local c = indices[i+3]
    
    backfaceCullingIssue = 1 - backfaceCullingIssue
    if( a!=b and a!=c and b!=c ) then 
    (
        if ( backfaceCullingIssue == 1 ) then
            append faces [a,b,c]
        else
            append faces [a,c,b] 
    )

)
    

 print faces
meshName = getfilenamefile file

theMesh = mesh name:meshName vertices:verts faces:faces tverts:uvs vnorms:normals

buildTVFaces theMesh false
for i = 1 to faces.count do ( setTVFace theMesh i faces[i] )
theMesh.WireColor = color (random 100 150) (random 100 150) (random 50 250)

fClose stream 

