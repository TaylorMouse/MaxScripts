--theMesh = $


tangents = #()

for i=1 to theMesh.numFaces do
(
    local f = getFace theMesh i

    local v = #(), t = #(), n = #()
    
    
    v[1] = getVert theMesh f[1]
    v[2] = getVert theMesh f[2]
    v[3] = getVert theMesh f[3]

    t[1] = getTVert theMesh f[1]
    t[2] = getTVert theMesh f[2]
    t[3] = getTVert theMesh f[3]
    
    edge1 = [0,0,0]
    edge2 = [0,0,0]
    tangentArray = #([0,0,0], [0,0,0], [0,0,0])
    
    /* Calculate X */
    edge1[1] = v[2][1] - v[1][1]
    edge1[2] = t[2][1] - t[1][1]
    edge1[3] = t[2][2] - t[1][2]
    
    edge2[1] = v[3][1] - v[1][1]
    edge2[2] = t[3][1] - t[1][1]
    edge2[3] = t[3][2] - t[1][2]
    
    crossProd = cross edge1 edge2
    crossP = normalize crossProd
    
    if ( crossP[1] == 0 ) then crossP[1] = 1.0

    tanX = - crossP[2] / crossP[1]
    tangentArray[1][1] = tanX
    tangentArray[2][1] = tanX
    tangentArray[3][1] = tanX
    
    /* Calculate Y */
    edge1[1] = v[2][2] - v[1][2]
    edge2[1] = v[3][2] - v[1][2]
    edge2[2] = t[3][1] - t[1][1]
    edge2[3] = t[3][2] - t[1][2]
    
    crossProd = cross edge1 edge2
    crossP = normalize crossProd
    
    if ( crossP[1] == 0 ) then crossP[1] = 1.0

    tanY = - crossP[2] / crossP[1]
    tangentArray[1][2] = tanY
    tangentArray[2][2] = tanY
    tangentArray[3][2] = tanY
    
    /* Calculate Z */
    edge1[1] = v[2][3] - v[1][3]
    edge2[1] = v[3][3] - v[1][3]
    edge2[2] = t[3][1] - t[1][1]
    edge2[3] = t[3][2] - t[1][2]
    
    crossProd = cross edge1 edge2
    crossP = normalize crossProd
    
    if ( crossP[1] == 0 ) then crossP[1] = 1.0

    tanZ = - crossP[2] / crossP[1]
    tangentArray[1][3] = tanZ
    tangentArray[2][3] = tanZ
    tangentArray[3][3] = tanZ
    
    for i=1 to 3 do
    (
        tangentArray[i] -= n[i] * ( dot tangentArray[i] n[i] )
    )
    
    x = normalize tangentArray[1]
    y = normalize tangentArray[2]
    z = normalize tangentArray[3]
    
    tangents[f[1]] = x
    tangents[f[2]] = y
    tangents[f[3]] = z
    
)

for i=1 to theMesh.numVerts do
(
    local n = getnormal theMesh i
    local w = dot ( cross n t ) tan2[i]
    
)

