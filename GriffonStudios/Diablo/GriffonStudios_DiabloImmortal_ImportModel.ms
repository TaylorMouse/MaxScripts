/*
    .DESCRIPTION
    | Read mesh from Diablo Immortal
    | Written by Taylor Mouse
    
    .DATE
    | (c)2022
    
    .RELEASENOTES
    
    | 0.1 - INIT
    
*/

struct HelperScripts 
(
    function SkipBytes stream nBytesToSkip = ( fseek stream nBytesToSkip #seek_cur ),
    
    function ReadTris stream = 
    ( 
        local a = readshort stream + 1
        local b = readshort stream + 1
        local c = readshort stream + 1
        return [a,b,c] 
    ),
    function ReadIntTris stream = 
    ( 
        local a = readLong stream + 1
        local b = readLong stream + 1
        local c = readLong stream + 1
        return [a,b,c] 
    ),
    
    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    ),
    
    function BuildBoundingBox bBox=
    (
        local p1 = bBox[1]
        local p2 = bBox[2]

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
            
        return s
    ),
    
    function ReadHalfFloat stream = 
    (
        hf = readshort stream
        sign = bit.get hf 16
        exponent = (bit.shift (bit.and hf (bit.hexasint "7C00")) -10) as integer - 16
        
        fraction = bit.and hf (bit.hexasint "03FF")
        
        if ( sign == true)  then 
            sign = 1 
        else 
            sign = 0
        
        exponentF = exponent + 127
        outputAsFloat = bit.or (bit.or (bit.shift fraction 13) \
                       (bit.shift exponentF 23)) (bit.shift sign 31)
        
        return bit.intasfloat outputasfloat*2
    ),
    
    function CreateLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    )
)

struct DiabloImmortalTools
(
    function ImportMessiah file cleanScene scale=
    (
        struct _submesh ( startVert,nVerts,startIndex,nIndices, meshName)
        local fileName = getfilenamefile file
        local _help = HelperScripts()
        if cleanScene then (
            max select all
            max delete
        )
        
        local stream = fOpen file "rb"
        local version = readByte stream as integer
        local messiah = _help.ReadFixedString stream 7
        local type = readLong stream --> 8 = contains mesh data, 1 does not
        
        if type == 1 then return undefined
        
        local layer = _help.CreateLayer "Meshes"
        
        local size = readLong stream

        local unk = readshort stream
        local nMeshes = readshort stream
        local nTotalVerts = readLong stream
        local nTotalIndices = readLong stream
        local readshorts = true
        if ( nTotalVerts > 32767 ) then readShorts = false
        
        format "Vertices: %\n" nTotalVerts
        format "Indices : %\n" nTotalIndices
        
        local chunks = #()
        for i=1 to 4 do 
            append chunks ( _help.readFixedString stream (readShort stream) )
           
        format "Chunks: %\n" chunks

        _help.SkipBytes stream 40 --> ??
        
        
        local submeshes = #()
        for m=1 to nMeshes do 
        (
            local sm = _submesh()
            sm.startIndex = readLong stream / 3
            sm.nIndices   = readLong stream / 3
            sm.startVert = readLong stream
            sm.nVerts   = readLong stream
            sm.meshName = fileName + "_" + (m as string )
            append submeshes sm
        ) 
        print submeshes
        local faces = #()
        for f=1 to nTotalIndices / 3 do (
            if readShorts then 
                append faces (_help.ReadTris stream)
            else
                append faces (_help.ReadIntTris stream)
        )
        local verts = #()
        local tangents = #()
        local uvSets = #()
        local normals = #()
        
        for n=1 to chunks.count do
        (
            local chunk = chunks[n]
            
            if chunk == "P3F" then (
                for v=1 to nTotalVerts do (
                    local pos = [ReadFloat stream, ReadFloat stream, ReadFloat stream] * scale
                    append verts [pos.x, pos.z, pos.y]
                )
            )
            if chunk == "P3F_N4B_T2F" then (
                local uvSet = #()
                for v=1 to nTotalVerts do
                (
                    local pos = [ReadFloat stream, ReadFloat stream, ReadFloat stream] * scale
                    append verts [pos.x, pos.z, pos.y]
                    _help.SkipBytes stream 4
                    append uvSet [_help.ReadHalfFloat stream, _help.ReadHalfFloat stream, 0.0]
                )
                append uvSets uvSet
            )
            if chunk == "Q4H_T2H" then (
                local uvSet = #()
                for v=1 to nTotalVerts do
                (
                    _help.SkipBytes stream 8
                    append uvSet [_help.ReadHalfFloat stream, _help.ReadHalfFloat stream, 0.0]
                ) 
                append uvSets uvSet
            )
            if chunk == "Q4H_T2H_T2H" then (
                local uvSet1 = #()
                local uvSet2 = #()
                for v=1 to nTotalVerts do
                (
                    _help.SkipBytes stream 8
                    append uvSet1 [_help.ReadHalfFloat stream, _help.ReadHalfFloat stream, 0.0]
                    append uvSet2 [_help.ReadHalfFloat stream, _help.ReadHalfFloat stream, 0.0]
                ) 
                append uvSets uvSet1
                append uvSets uvSet2
            )
            if chunk == "W4B_I4B" then ( --> vertex weights 4 bytes, bone indices 4 b
                
                _help.SkipBytes stream 8
            )
            
        )
        
        local uv = #()
        if uvSets.count > 0 then uv = uvSets[1]
        
        for m in submeshes do 
        (
            local theVerts = #()
            local theUvs = #()
            local theFaces = #()

            for v=(m.startVert+1) to (m.startVert + m.nVerts ) do (

                append theVerts verts[v]
                append theUvs uv[v]

            )
            for f=(m.startIndex+1) to (m.startIndex + m.nIndices ) do
            (
                local face = [faces[f].x - m.startVert, faces[f].y - m.startVert, faces[f].z - m.startVert ]
                append theFaces face
                
            )

            
            local wireColor = random (color 0 0 0 ) ( color 128 128 128 )
            local theMesh = mesh vertices:theVerts name:m.meshName faces:theFaces tverts:theUvs 
            theMesh.WireColor = wireColor
                
            buildTVFaces theMesh false
            
            for i = 1 to theFaces.count do ( setTVFace theMesh i theFaces[i] )
            
            layer.AddNode theMesh
            
            update theMesh
            
        )
        fClose stream
        
        max zoomext sel
        gc()
    )
)
(
    ClearListener()
    local file = getOpenFileName \
                    caption:"Diablo Immortal" \
                    types:"Supported Files|*.mesh|Diablo Immortal(*.mesh)|*.mesh|All Files|*.*" \
                    historyCategory:"DiabloImmortalPreset"
    if (file != undefined) then 
        if (doesfileexist file == true ) then 
            DiabloImmortalTools.ImportMessiah file false 50
)