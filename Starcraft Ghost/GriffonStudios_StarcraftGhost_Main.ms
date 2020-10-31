/* 
    (c) 2020 Griffon Studios
    
    by Taylor Mouse
    
    Imports Starcraft Ghost (xbox game) models
    
    Based on the initial script found here:
    https://github.com/RenolY2/scg-modeldump
    
*/
struct GriffonStudios_Helpers
(
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
    function CreateLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),
    function FindFiles root pattern=
    (
        dirList = GetDirectories (root+"/*")
        for d in dirList do
          join dirList (GetDirectories (d+"/*"))
        files = #()
        for f in dirList do
          join files (getFiles (f + pattern))
        return files
    ),
    function ReadBoundingBox stream=
    (
        local bbox = #()
        local pointA = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        local pointB = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        append bbox pointA
        append bbox pointB
        
        return bbox
    ),
    function ReadFixedString stream val =
    (
        /* Read n-length string */
        local str = ""

        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if ( s !="\0") then str+=s
        )
        return str

    ),
    function SkipBytes stream nBytesToSkip=
    (
        /* Skip n-bytes without reading them into memory */
        fseek stream nBytesToSkip #seek_cur
    ),
    function ReadVector3 stream correction=
    (
        return [readFloat stream, readFloat stream, readFloat stream] * correction
    ),
    function ReadUV2 stream=
    (
        return [readFloat stream, 1.0 - (readFloat stream)]
    )
)

struct Starcraft_Ghost_Tools
(
    function ReadGhostBone stream=
    (
        struct Ghost_bone ( id, parentId, tagId, translation, invTranslation, boneRef )
        -- 64 bytes
        
        local gb = Ghost_bone()
        gb.translation = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        SkipBytes stream 36
        
        gb.invTranslation = [readFloat stream, readFloat stream, readFloat stream] * 100.0
        
        local unk1 = readByte stream as integer
        local unk2 = readByte stream as integer
        gb.parentId = ( readByte stream as integer ) + 1
        gb.tagId    = readByte stream as integer
        return gb
    ),
    function ReadMaterials file=
    (
        format "Parsing materials ( shaders and textures )\n"
        
        struct ghost_material ( shaders, textures )
        struct ghost_shader   ( name, shader, texture, sound, surfflags, envmap, meshtype, sightForce )
        
        local filePath = getFilenamePath file
        local rootPath = substring file 1 (findString filePath @"\3D\")
        
        local gmat = ghost_material ()
        
        gmat.textures = #()
        gmat.shaders = #()
        
        if ( doesdirectoryexist rootPath ) then
        (
            gmat.textures = GriffonStudios_Helpers.FindFiles rootPath "*.dds"
            format "- % textures (.dds) found\n" gmat.textures.count
            local shaderFiles = GriffonStudios_Helpers.FindFiles rootPath "*.nsa"

            
            for f in shaderFiles do
            (
                local str = openfile f
                
                while ( ( eof str ) == false ) do
                (
                    local l = readLine str
                    if ( eof str ) then exit
                    
                    local gs = ghost_shader()
                    
                    gs.name = l
                    
                    l = readLine str
                    if ( eof str ) then exit
                    while ( l != "}" ) do
                    (
                        if ( eof str ) then exit
                        
                        l = trimleft (trimright l)

                        if ( findstring l "shader" != undefined )       then gs.shader     = trimleft(substitutestring l "shader" "")
                        if ( findstring l "sightForce" != undefined )   then gs.sightForce = l
                        if ( findstring l "texture" != undefined )      then gs.texture    = trimleft(substitutestring l "texture" "")
                        if ( findstring l "sound" != undefined )        then gs.sound      = trimleft(substitutestring l "sound" "")
                        if ( findstring l "surfflags" != undefined )    then gs.surfflags  = trimleft(substitutestring l "surfflags" "")
                        if ( findstring l "envmap" != undefined )       then gs.envmap     = trimleft(substitutestring l "envmap" "")
                        if ( findstring l "meshtype" != undefined )     then gs.meshtype   = trimleft(substitutestring l "meshtype" "")

                        l = readLine str
                        if ( eof str ) then exit
                    )
                    
                    append gmat.shaders gs
                )
                close str
            )
            format "- % shaders found\n" gmat.shaders.count
        )
        
        return gmat
    ),
    function FindMaterial nod materials=
    (
        local mats = #()
        for i=1 to nod.nShaders do
        (
            local shaderName = tolower nod.shaderNames[i]
            local textureName = "\\" + ( tolower nod.shaderNames[i] ) + ".dds"
            
            format "Looking for shader '%'\n" shaderName
            mats[i] = undefined
            
            for ghostShader in materials.shaders do
            (
                if ( ( tolower ghostShader.name ) == shaderName ) then
                (
                    --format "Shader found %\n" ghostShader.name
                    mats[i] = ghostShader
                    exit
                )
            )
            
            if ( mats[i] == undefined ) then 
            (
                format "Looking for texture '%.dds'\n" shaderName
                
                for texture in materials.textures do
                (
                    if ( ( findstring ( tolower texture ) textureName ) != undefined ) then
                    (
                        --format "Texture found '%'\n" texture
                        mats[i] = texture
                        exit
                    )
                )
            )
        )
        
        return mats
    ),
    function BuildGhostBones boneList=
    (
        for b in boneList do
        (
            local bName = "bone_" + (b.id as string)
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
                
            aBone.Name = bName
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.Pos = b.translation
            b.boneRef = aBone
        )
        
        for b in boneList do
        (
            if (b.parentID > 0) then
            (
                b.boneRef.Parent = boneList[b.parentID].boneRef
            )

        )        
    ),
    function BuildNodMesh nod=
    (
        format "Building 3D Model\n"
        local help = GriffonStudios_Helpers()
        
        local bboxLayer = help.CreateLayer "Bounding Box"
        local bbox = help.BuildBoundingBox nod.bbox
        
        bboxLayer.AddNode bbox
        
    ),
    function ReadNod file=
    (
        format "Reading 3D model file '%'\n" (filenameFromPath file)
        struct ghost_nod ( version, nShaders, nBones, nVertGrp, nMeshGrp, flags, bbox, vtxGroups, meshGroups, nIndices, indices, lodStarts, lodCount, shaderNames, boneList, materials )
        struct ghost_vert_grp ( vertexCount, vertexType, vertices, normals, uvs )
        struct ghost_mesh_grp ( matId, lods, vertexCount, flags, nBlendShapes, blendGroup, boneList, nBones, vertexGroup  )
        struct ghost_mesh_lod ( stripStart, stripCount, listStart, listCount, vertexCount )
        
        local gshelp = GriffonStudios_Helpers()
        
        stream = fOpen file "rb"

        local nod = ghost_nod()
        
        nod.version  = readLong stream
        nod.nShaders = readByte stream as integer
        nod.nBones   = readByte stream as integer
        nod.nVertGrp = readByte stream as integer
        nod.nMeshGrp = readByte stream as integer 
        nod.flags    = readLong stream
        nod.bbox     = gshelp.ReadBoundingBox stream

        nod.vtxGroups = #()
        for i=1 to 4 do
        (
            local vg = ghost_vert_grp()
            vg.vertexType = readLong stream
            vg.vertexCount = readLong stream
            append nod.vtxGroups vg
        )
        nod.nIndices = readLong stream

        nod.lodStarts = #()
        for i=1 to 4 do
            append nod.lodStarts (readLong stream)

        nod.lodCount = readLong stream

        nod.shaderNames = #()
        for i=1 to nShaders do
            append nod.shaderNames ( gshelp.ReadFixedString stream 0x20 )

        nod.boneList = #()
        for i=1 to nBones do
        (
            local gb = ReadGhostBone stream
            gb.id = i
            append nod.boneList gb

        )

        for vg in nod.vtxGroups do
        (
            vg.vertices = #()
            vg.normals  = #()
            vg.uvs      = #()
            
            for i=1 to vg.vertexCount do
            (
                append vg.vertices ( gshelp.ReadVector3 stream 100.0 )
                append vg.normals  ( gshelp.ReadVector3 stream 1.0)
                append vg.uvs      ( gshelp.ReadUV2 stream )
            
                if ( vg.vertexType == 1 ) then
                    gshelp.SkipBytes stream 4
                if ( vg.vertexType == 2 ) then
                    gshelp.SkipBytes stream 16
            )
        )
        
        nod.indices = #()
        for i=1 to nod.nIndices by 3 do
        (
           append nod.indices [readShort stream #unsigned +1, readShort stream #unsigned +1, readShort stream #unsigned +1 ]
        )

        nod.meshGroups = #()
        for i=1 to nod.nMeshGrp do
        (
            local mg = ghost_mesh_grp()
            
            mg.matId = readLong stream
            mg.lods  = #()
            indexOffset = 0
            
            for l=1 to 4 do
            (
                local d = ghost_mesh_lod()
                
                d.stripStart = indexOffset
                d.stripCount = readShort stream #unsigned
                d.listStart = indexOffset + d.stripCount
                d.listCount = readShort stream #unsigned
                d.vertexCount = readShort stream #unsigned
                
                indexOffset += d.stripCount + d.listCount
                
                append mg.lods d
            )

            mg.vertexCount = readShort stream
            mg.flags = readByte stream
            mg.nBlendShapes = readByte stream as integer
            mg.blendGroup = readByte stream as integer
            mg.boneList = #()
            for b=1 to 20 do --> bones with id 204 -> are not used...
            (
                append mg.boneList (readByte stream #unsigned as integer)
            )

            mg.nBones = readByte stream as integer
            mg.vertexGroup = readShort stream
            
            append nod.meshGroups mg
        )

        fClose stream

        local materials = ReadMaterials file
        nod.materials = FindMaterial nod materials
        
        return nod
    ),
    /* 
        Main functions
    */
    function ImportNod file=
    (
        
        local nod = ReadNod file
                
        BuildNodMesh nod
        
        return "Import Done"
    )
)
/*
    Testing only
*/
clearListener()
file = @"F:\Blizzard\Starcraft Ghost\StarCraft Ghost Xbox\3D\Models\zergling.nod"

Starcraft_Ghost_Tools.ImportNod file
