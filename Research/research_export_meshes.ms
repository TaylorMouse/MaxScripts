clearlistener()
--     boneList = #()
--         for obj in objects do 
--             if (classof obj == boneGeometry ) then append boneList obj
struct geo800  
    (   uniqueName, 
        VRTX = #(),  --> vertices
        NRMS = #(),  --> normals
        PTYP = #(),  --> type = triangles 0x4
        PCNT = #(),  --> nbr faces * 3 ( nbr of indices )
        PVTX = #(),   --> faces
        GNDX = #(), 
        MTGC = #(),   
        MATS = #(),  --> ok
        UVS = #(),  --> uv texture
        meshRef, 
        bones = #(),  --> bones indexes for weighing the vertices, vertices are equally weighted -> 2 bones => so 1 vertex is 0.5
        uniqueBoneIds = #() --> the list of bones required for this whole mesh
    )

testWeights = Warcraft_III_Helpers.GetWeights $

   
for i=1 to WC3_MDX.geos[15].GNDX.count do print WC3_MDX.geos[15].GNDX[i]
WC3_MDX.geos[15].MTGC

WC3_MDX.geos[15].MATS.matrices --> list unique bones
WC3_MDX.geos[15].uniqueBoneIds

for w in testWeights do print w


testWeights

boneList[]


boneindices = #()
for w in testWeights do 
(
    
    if( boneIndices.count == 0 ) then
        append boneIndices w.boneIndices
    else
    (
        local foundIt = false
        for bi in boneIndices do
        (   
             if bi[1] == w.boneIndices[1] and bi[2] == w.boneIndices[2] and bi[3] == w.boneIndices[3] and bi[4] == w.boneIndices[4] then foundIt = true
        )   
         if foundIt == false then append boneIndices w.boneIndices
    )
    
)

matrices = #()
for i=1 to boneIndices.count do
(
    if boneIndices[i][1] != 0 then append matrices boneIndices[i][1]
    if boneIndices[i][2] != 0 then append matrices boneIndices[i][2]
    if boneIndices[i][3] != 0 then append matrices boneIndices[i][3]
    if boneIndices[i][4] != 0 then append matrices boneIndices[i][4]
    
)
gc()

-- testWeights[1].boneIndices == testWeights[2].boneIndices

WC3_MDX.GEOS[15].MTGC
mtgc = #()
for n=1 to boneIndices.count do 
(
    local counter = 0
    
    for bi in boneIndices do 
        if bi != 0 then counter += 1
    
    append mtgc counter
)



for gndx in WC3_MDX.GEOS[15].GNDX do print gndx

for w in testWeights do 
(
    
    --print w.boneIndices
    
    
    for bi=1 to boneIndices.count do
    (
        local boneIndex = boneIndices[bi]
        if boneIndex[1] == w.boneIndices[1] and
           boneIndex[2] == w.boneIndices[2] and
           boneIndex[3] == w.boneIndices[3] and
           boneIndex[4] == w.boneIndices[4] then
        print bi
    )

    
)




select geos[15].meshRefWC3_MDX.GEOS[15]
WC3_MDX.GEOS[14].mats.sevenfloats
index = 0
   
for i= 1 to WC3_MDX.GEOS[14].mats.floats.count/7 do
(
    myArray = #()
    for f=1 to 7 do
    (
         append myArray WC3_MDX.GEOS[14].mats.floats[index + f]
    )
    
    index +=7
    format "%\n" ( myArray)
)



WC3_MDX.GEOS[14].mats.sevenfloats

(distance $.min $.max) / 2.0

WC3_MDX.SEQS.count

theBone = getnodebyname "LowArmR"
theBone.controller.keys
theBone.pos.controller.keys.count
theBone.scale.controller.keys.count



--theMesh = $
baseExtend = #()
with animate on at time 0
(
    local rad = distance theMesh.min theMesh.max
    append baseExtend rad
    append baseExtend theMesh.min.x
    append baseExtend theMesh.min.y
    append baseExtend theMesh.min.z
    append baseExtend theMesh.max.x
    append baseExtend theMesh.max.y
    append baseExtend theMesh.max.z
        format "%\n" baseExtend
)
for seqs in WC3_MDX.SEQS do
(

    with animate on
        at time seqs.startFrame
        (
            local extend = #()
            local rad = distance theMesh.min theMesh.max
            append Extend rad
            append Extend theMesh.min.x
            append Extend theMesh.min.y
            append Extend theMesh.min.z
            append Extend theMesh.max.x
            append Extend theMesh.max.y
            append Extend theMesh.max.z
            
            if ( matchpattern seqs.name pattern:"death*" or matchpattern seqs.name pattern:"dissipate" or matchpattern seqs.name pattern:"decay*" ) then 
                format "%\n" Extend
            else
                format "%\n" baseExtend
        )
    
    
)






















