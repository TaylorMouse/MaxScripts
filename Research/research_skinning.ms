/*
    research skinning
*/
struct mdx800 ( file, stream, seqs, glbs, mtls, texs, geos, geoa, allObjects )
mdx = mdx800()

Warcraft_III_Helpers.GetObjects mdx

for x in WC3_MDX.tags do print x
-- for mesh Spartan_2
WC3_MDX.GEOS[2].GNDX --> bytes = nbr of vertices referecing the MTGC
WC3_MDX.GEOS[2].MTGC --> matching group count
WC3_MDX.GEOS[2].MATS.matrices --> matching sets -- referencing the bones

theMesh = getNodeByName "Spartan_2"

struct weights800 ( matrices = #(), mtgc = #(), gndx = #() )
struct vertex_weight ( vertex, boneIndices = #(), crc = "")

weights = weights800()

select theMesh
max modify mode
skinMod = modPanel.getCurrentObject()

vertex_weight_list = #()
for v=1 to skinOps.getnumbervertices skinMod do
(
    local vw = vertex_weight vertex:v
    local vertexweightcount = skinops.getvertexweightcount skinMod v

    for w=1 to vertexweightcount do
    (
        local boneId = skinOps.getvertexweightboneid skinMod v w
        local boneName = skinOps.getBonename skinMod boneId 0
        
        for obj in mdx.allobjects do
        (
            if ( obj.objRef.name == boneName ) then 
            (
                append vw.boneIndices obj.id
                vw.crc += obj.id as string + "|"
                exit
            )
        )

    )
    
    append vertex_weight_list vw
    
)
-- > annoyingly necessary to apply the correct weights to the correct vertices
tvVertices = #()
for i=1 to theMesh.numFaces do
(
    local f = getFace theMesh i
    local u = getTvFace theMesh i
    tvVertices[u.x] = f.x as integer
    tvVertices[u.y] = f.y as integer
    tvVertices[u.z] = f.z as integer
)
--> necessary as well as some models have isolated vertices...
for i=1 to tvVertices.count do if (tvVertices[i] == undefined ) then tvVertices[i] = i as integer

tv_vertex_weight_list = #()
for tv in tvVertices do
    append tv_vertex_weight_list vertex_weight_list[tv]
    
mtgcList = #()
for vw in tv_vertex_weight_list do appendIfUnique mtgcList vw.crc

-->  GEOS.MATS.matrices
for m in mtgcList do
(
    local parts = filterstring m "|"
    for p in parts do
    (
        if p != "" then append weights.matrices (p as integer )
    )
)

--> GEOS.MTGC
for m in mtgcList do
(
    local parts = filterstring m "|"
    append weights.mtgc parts.count
)

--> GEOS.GNDX
for vw in tv_vertex_weight_list do
(
    for m=1 to mtgcList.count do 
    (
        if mtgcList[m] == vw.crc then append weights.gndx m
    )
)
deselect theMesh