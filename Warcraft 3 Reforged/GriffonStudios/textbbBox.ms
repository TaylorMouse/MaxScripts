



-- sphere radius:1 pos:[-53.6893,-37.7426,-5.03299]
-- sphere radius:1 pos:[25.4741,54.7081,141.11]

function BuildSpline spline points=
(
    if spline == undefined then spline = SplineShape pos:[0,0,0]
    spline.WireColor = gray
    spline.renderable = off
    
    local index = addNewSpline spline
    
    for p in points do addKnot spline index #corner #curve p
    
    close spline index

    updateShape spline
    
    return spline
)

function BuildBoundingBox bbBox=
(
    local p1 = bbBox[1]
    local p2 = bbBox[2]

    local xMin = 0
    local xMax = 0
    local yMin = 0
    local yMax = 0
    local zMin = 0
    local zMax = 0
    
    if p1.x < p2.x then 
        ( 
            xMin = p1.x
            xMax = p2.X
        )
    else
        ( 
            xMin = p2.x
            xMax = p1.x
        )
    if p1.y < p2.y then 
        ( 
            yMin = p1.y
            yMax = p2.y
        )
    else
        ( 
            yMin = p2.y
            yMax = p1.y
        )
    if p1.z < p2.z then 
        ( 
            zMin = p1.z
            zMax = p2.z
        )
    else
        ( 
            zMin = p2.z
            zMax = p1.z
        )
        
    local s = BuildSpline s #([xMin, yMin, zMin], [xMax, yMin, zMin], [xMax,yMin, zMax], [xMin,yMin, zMax], [xMin, yMin, zMin] )
    s = BuildSpline s #([xMin, yMax, zMin], [xMax, yMax, zMin], [xMax,yMax, zMax], [xMin,yMax, zMax], [xMin, yMax, zMin] )
    s = BuildSpline s #([xMin, yMax, zMin], [xMin, yMin, zMin])
    s = BuildSpline s #([xMin, yMax, zMax], [xMin, yMin, zMax])    
    s = BuildSpline s #([xMax, yMax, zMin], [xMax, yMin, zMin])
    s = BuildSpline s #([xMax, yMax, zMax], [xMax, yMin, zMax])
)

bbBox=#()
bbBox[1] = [-53.6893,-37.7426,-5.03299]
bbBox[2] = [25.4741,54.7081,141.11]

BuildBoundingBox bbBox


