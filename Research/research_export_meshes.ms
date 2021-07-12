clearlistener()

struct geo800  
    (   uniqueName, VRTX = #(), NRMS = #(), PTYP = #(), PCNT = #(), PVTX = #(), GNDX = #(), MTGC = #(), MATS = #(), UVS = #(), meshRef, 
        bones = #(),  --> bones indexes for weighing the vertices, vertices are equally weighted -> 2 bones => so 1 vertex is 0.5
        uniqueBoneIds = #() --> the list of bones required for this whole mesh
    )

geos = #()
for obj in objects do
(
    if ( classof obj == editable_mesh or classof obj == PolyMeshObject ) then
    (
        if ( obj.ishidden == false ) then
        (
            if ( classof obj.material == WarcraftIII_Standard or
                  (  classof obj.material == CompositeMaterial and 
                     classof obj.material.materialList[1] == WarcraftIII_Standard and
                      classof obj.material.materialList[2] == WarcraftIII_Standard 
                  )
                ) then
                (
                    print obj.name
                    local geo = geo800 meshRef:obj
                    append geos geo
                )
        )
    )
)


testWeights = GetWeights $
for tw in testWeights do print tw
    

for geo in geos do
(
    local m = geo.meshRef
    
    local original_vertices = #()
    local original_normals  = #()
    local original_weights  = Warcraft_III_Helpers.GetWeights m
    
    for v=1 to m.numVerts do
    (
        original_vertices[v] = getVert m v
        original_normals[v]  = getNormal m v
    )

    local tvVertices = #()
    local faces = #()
    for i=1 to m.numFaces do
    (
        local f = getFace m i
        local u = getTvFace m i

        faces[i] = u
        tvVertices[u.x] = f.x
        tvVertices[u.y] = f.y
        tvVertices[u.z] = f.z
        
    )

    local vertices = #()
    local normals = #()
    local uvs = #()
    local weights = #()
    for i=1 to tvVertices.count do
    (
        local uv = getTvert m i
        
        uvs[i] = [uv.x, 1.0 - uv.y]
        vertices[i] = original_vertices[tvVertices[i]]
        normals[i]  = original_normals[tvVertices[i]]
        weights[i]  = original_weights[tvVertices[i]]
    )
)