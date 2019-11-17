
--theMesh = $
function CalculateTangent theMesh=
(
    local tan1 = #()
    local tan2 = #()
    local tangent = #()
    for i=1 to theMesh.numFaces do
    (

        local f = getFace theMesh i

        local v1 = getVert theMesh f[1]
        local v2 = getVert theMesh f[2]
        local v3 = getVert theMesh f[3]

        local w1 = getTVert theMesh f[1]
        local w2 = getTVert theMesh f[2]
        local w3 = getTVert theMesh f[3]


        local x1 = v2.x - v1.x
        local x2 = v3.x - v1.x
        local y1 = v2.y - v1.y
        local y2 = v3.y - v1.y
        local z1 = v2.z - v1.z
        local z2 = v3.z - v1.z

        local s1 = w2.x - w1.x
        local s2 = w3.x - w1.x
        local t1 = w2.y - w1.y
        local t2 = w3.y - w1.y

        local r = 1.0 / ( s1 * t2 - s2 * t1)

        local sdir = [ ( t2 * x1 - t1 * x2) * r , ( t2 * y1 - t1 * y2 ) * r, ( t2 * z1 - t1 * z2 ) * r ]
        local tdir = [ ( s1 * x2 - s2 * x1) * r , ( s1 * y2 - s2 * y1 ) * r, ( s1 * z2 - s2 * z1 ) * r ]

        tan1[f[1]] = sdir
        tan1[f[2]] = sdir
        tan1[f[3]] = sdir

        tan2[f[1]] = tdir
        tan2[f[2]] = tdir
        tan2[f[3]] = tdir

    )

    for i=1 to theMesh.numVerts do
    (
        local n = getnormal theMesh i
        local t = tan1[i]
        
        local v = normalize ( ( t - n ) * ( dot n t ) )
        local w = dot ( cross n t ) tan2[i]
        
        if ( w < 0.0 ) then w = -1.0 else w = 1.0
        tangent[i] = [v.x, v.y, v.z, w]
    )
    return tangent
)
    re