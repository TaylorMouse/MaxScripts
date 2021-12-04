/*
    ©2021 Griffon Studios
    Author: Taylor Mouse
    Research for everything

*/

STRUCT HelperScripts
(
    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    ),
    function SkipBytes stream nBytesToSkip=
    (
        fseek stream nBytesToSkip #seek_cur
    ),
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
        
        local help = GriffonStudios_Helpers()
        local s = help.BuildSpline s #([xMin, yMin, zMin], [xMax, yMin, zMin], [xMax,yMin, zMax], [xMin,yMin, zMax], [xMin, yMin, zMin] )
        s = help.BuildSpline s #([xMin, yMax, zMin], [xMax, yMax, zMin], [xMax,yMax, zMax], [xMin,yMax, zMax], [xMin, yMax, zMin] )
        s = help.BuildSpline s #([xMin, yMax, zMin], [xMin, yMin, zMin])
        s = help.BuildSpline s #([xMin, yMax, zMax], [xMin, yMin, zMax])    
        s = help.BuildSpline s #([xMax, yMax, zMin], [xMax, yMin, zMin])
        s = help.BuildSpline s #([xMax, yMax, zMax], [xMax, yMin, zMax])
        
        s.name = "Bounding Box"
        freeze s
        return s
    ),
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
)
clearListener()
(
    local _helpers = HelperScripts()
    
    
    file = @"G:\Game Dev\3D Models\Game Models\Ruined King\Mesh\A_08_Mug_01.dat"
    strm = fOpen file "rb"

    local lenName = readLong strm
    local objName = _helpers.ReadFixedString strm lenName
    
    local restByteLength = ( (( lenName / 4 ) + 1 ) * 4 ) - lenName
    local zeroes = _helpers.SkipBytes strm restByteLength
    
    local nbrMeshes = readLong strm
    local unk1 = readLong strm
    local nbrIndices = readlong strm
    
    local unk1 = readLong strm
    local unk2 = readLong strm
    local unk3 = readLong strm
    
    local nbrVertices = readLong strm
    local bBox = #( [readFloat strm, readFloat strm, readFloat strm] * 100 , [readFloat strm, readFloat strm, readFloat strm] * 100 )
    
    local zeroes = _helpers.SkipBytes strm 44
    
    local sizeIndices = readLong strm
    local faces = #()
    for i=1 to nbrIndices / 3 do
        append faces [readShort strm + 1,readShort strm + 1,readShort strm + 1]


    print ( ftell strm )
    fClose strm
    
    
)

