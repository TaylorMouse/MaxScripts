STRUCT Warcraft_III_Helpers
(
    function ReadVector3Anim stream=
    (
        /*
        .INFO
        | LineType:
        |   NO_INTERP = 0x0
        |   LINEAR    = 0x1
        |   HERMITE   = 0x2
        |   BEZIER    = 0x3

        */
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = [readFloat stream, readFloat stream, readFloat stream]
            k.LineType = anim.lineType

            if( anim.lineType > 1)  then
            (
                k.inTan = [readFloat stream, readFloat stream, readFloat stream]
                k.outTan = [readFloat stream, readFloat stream, readFloat stream]
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadQuatAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                --format "Linetype: %\n" lineType
                k.inTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
                k.outTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadFloatAnim stream=
    (
        
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readFloat stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadVector3 stream=
    (
        local vector3 = [readFloat stream, readFloat stream, readFloat stream]
        return vector3
    ),
    function ReadColor stream=
    (
        local r = (readFloat stream * 255.0) as integer
        local g = (readFloat stream * 255.0) as integer
        local b = (readFloat stream * 255.0) as integer
        return ( color r g b )
    ),
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    ),
    function ReadColorAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = Warcraft3_Reforged.ReadColor stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadLongAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readLong stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
        
    ),
    function WriteFixedString stream str len=
    (
        if ( WC3_DEBUG ) then  Format " - Writing %\n" str
        for i=1 to str.count do
        (
            local byte = bit.charasint str[i]
            writeByte stream byte
        )
        for i=1 to (len - str.count) do
            writeByte stream 0
    ),
    function WriteVector3 stream vector3=
    (
         writeFloat stream vector3.X
         writeFloat stream vector3.Y
         writeFloat stream vector3.Z
        
        
    ),
    function WriteQuat stream quaternian=
    (
        writeFloat stream quaternian.x
        writeFloat stream quaternian.y
        writeFloat stream quaternian.z
        writeFloat stream quaternian.w

    ),
    function WriteVector4 stream vector4=
    (
        writeFloat stream vector4[1]
        writeFloat stream vector4[2]
        writeFloat stream vector4[3]
        writeFloat stream vector4[4]
        
    ),
    /* Get the biggest bounding box from all models between 2 frame, as animation changes these bounding boxes */
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        if ( WC3_DEBUG ) then Format "Calculating MODL Boundingbox between frame % and %\n" startFrame endFrame
        local allKeys = GriffonStudios_Helpers.GetAllAnimatedKeyFrames()

        maxPoint = [0,0,0]
        minPoint = [0,0,0]

        for t in allKeys do
        (
            if ( t >= startFrame and t <= endFrame ) then 
            (
                at time t 
                for obj in objects do
                (
                    if ( classof obj == Editable_Mesh and obj.visibility == true ) then
                    (
                        local bbMax = obj.max
                        
                        for i=1 to 3 do
                            if( maxPoint[i] < bbMax[i] ) then maxPoint[i] = bbMax[i]
                        
                        local bbMin = obj.min
                        
                        for i=1 to 3 do
                            if( minPoint[i] > bbMin[i] ) then minPoint[i] = bbMin[i]
                        
                    )
                )
            )
        )
        local bbox = #()
        append bbox minPoint
        append bbox maxPoint
        
        --format "%\n" bbox

        return bbox
    ),
    /* Get the biggest bounding box for the whole set of animations keys, specifically needed for the MODL chunk */
    function GetMODLBoundingBox =
    (
        local lastFrame = GriffonStudios_Helpers.FindLastKeyFrame()
        if ( lastFrame <= 1 ) then lastFrame = 10
        bbox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 1 lastFrame
        
        return bbox
        
    ),
    /* get the list of animation sequences from the animation track */
    function GetSEQS =
    (
        struct WC3AnimSequence ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
        local size = 132

        local seqs = #()
        
        local wc3startFrame = 0
        local wc3EndFrame = 0
        
        if( numNoteTracks rootNode > 0 ) then 
        (
            local track = getNoteTrack rootNode 1
            local keys = track.Keys
            
            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local parts = filterstring note "\r\n"
                local s = WC3AnimSequence()
                
                s.name = parts[1]
                if ( WC3_DEBUG ) then  format " %\n" s.name
                local StartFrameStr = (getnotekeytime track i) as string 
                local EndFrameStr = (getnotekeytime track (i+1)) as string 
                
                StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
                EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
                
                local startFrame = StartFrameStr as integer
                local endFrame = EndFrameStr as integer

                s.BBox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames startFrame endFrame
                s.StartFrame =  startFrame * 1000 / 30 --wc3startFrame
                s.EndFrame =  EndFrame * 1000 / 30 -- wc3EndFrame
                
                --wc3startFrame = wc3EndFrame + 34
                s.Default = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                    
                    --if ( WC3_DEBUG ) then format " -  %: '%' \n" key value
                    
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.movementSpeed = value as float
                    if ( key == "nonLoop" ) then 
                    (
                        s.noLoop = value as float
                        if ( value == "true" ) then s.noLoop = 1
                        if ( value == "false" ) then s.noLoop = 0
                        
                    )       
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local startFrame = 1000 / 30
            local endFrame = 50 * 1000 / 30
            local seq = WC3AnimSequence Name:"Stand 1" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        return seqs
    ),
    /* get the unique list of TEXS */
    function GetTEXS =
    (
        struct texs800 ( replacableId, path= "", flags = 3, check )
        local texs = #()
        
        for obj in objects do
        (
            if ( obj.material != undefined ) then
            (
                if ( classof obj.material == compositematerial) then 
                (
                    for subMat in obj.material.materialList do
                    (
                        if ( classof subMat == WarcraftIII_Standard ) then
                        (
                            local tex = texs800()
                            tex.replacableId = subMat.ReplaceableTexture - 1
                            if( tex.replacableId == 0 ) then 
                                tex.path = ( getfilenamefile subMat.Diffuse_map.filename ) + ".blp" 
                            if ( tex.replacableId == 2 ) then tex.flags = 0
                            tex.check = tex.replacableId as string + tex.path + tex.flags as string
                            append texs tex
                        )
                    )
                )
                if ( classof obj.material == WarcraftIII_Standard ) then
                (
                    local tex = texs800()
                    tex.replacableId = obj.material.ReplaceableTexture - 1
                    if( tex.replacableId == 0 ) then 
                        tex.path = ( getfilenamefile obj.material.Diffuse_map.filename ) + ".blp" 
                    if ( tex.replacableId == 2 ) then tex.flags = 0
                    tex.check = tex.replacableId as string + tex.path + tex.flags as string
                    append texs tex
                )
                
            )
        )
        uniqueTexs = #()
        for t in texs do
        (
            if uniqueTexs.count == 0 then 
            (
                append uniqueTexs t
            )
            else
            (
                local addit = true
                for u in uniqueTexs do
                (
                    if u.check == t.check then
                    (
                       addit = false
                        exit
                    )
                )
                if ( addit ) then append uniqueTexs t
            )
        )

        if WC3_MDX800_DEBUG then  for t in uniqueTexs do print t
        return uniqueTexs
    ),
    /* get a unique list of materials */
    function GetMTLS = 
    (
        local matList = #()
        for obj in objects do
        (
            if ( obj.material != undefined ) then 
            (
                if ( classof obj.material == compositeMaterial ) then
                (
                    if( classof obj.material.materialList[1] == WarcraftIII_Standard ) then appendIfUnique matList obj.material
                )
                if ( classof obj.material == WarcraftIII_Standard ) then
                    appendIfUnique matList obj.material
            )
        )
        if WC3_MDX800_DEBUG then for m in matList do print m
        return matList
    ),
    function GetBoneList=
    (
        local boneList = #()
        for obj in objects do 
            if (classof obj == boneGeometry ) then append boneList obj
        
        return boneList
    ),
    function GetWeights theMesh=
    (
        local boneList = GriffonStudios_Helper_Functions.GetBones()
        select theMesh
        max modify mode
        local sk = modPanel.getCurrentObject()
        
        struct vertexWeights ( vertexId, boneIndices, boneNames, weights )
        local vertices = #()
        
        if (classof sk == Skin ) then
        (
            for v=1 to skinOps.getnumbervertices sk do
            (
                local count = skinops.getvertexweightcount sk v
                local boneIndices = #(0,0,0,0)
                local boneNames = #("", "", "", "")
                local weights = #(0,0,0,0)
                
                if count > 4 then count = 4
                for k=1 to count do
                (
                    local weight = skinOps.getvertexweight sk v k
                    local boneId = skinOps.getvertexweightboneid sk v k
                    local boneName = skinOps.getBonename sk boneId 0
                    
                    for b=1 to boneList.count do
                    (
                        if ( boneList[b].name == boneName ) then 
                        (
                            boneId = b - 1
                            exit
                        )
                    )
                    
                    boneIndices[k] = boneId
                    boneNames[k] = boneName
                    weights[k] = ( weight * 255 ) as integer
                )
                
                if( 255 - weights[1] - weights[2] - weights[3] - weights[4] != 0 ) then
                    weights[1] = 255 - weights[2] - weights[3] - weights[4]

                local vertex = vertexWeights vertexId:v boneIndices:boneIndices boneNames:boneNames weights:weights
                
                append vertices vertex
            )
            
        )
        deselect theMesh
        return vertices
    ),
    function GetGeos mdx=
    (
        struct geo800  
            (   size, vrtx = #(), nrms = #(), ptyp, pcnt, pvtx = #(), gndx = #() , mtgc = #(), mats, uvas, uvbs = #(), meshRef,
                bones = #(),  --> bones indexes for weighing the vertices, vertices are equally weighted -> 2 bones => so 1 vertex is 0.5
                uniqueBoneIds = #() --> the list of bones required for this whole mesh
            )
        struct mats800 ( nbrItems, name, matrices = #(), materialId, sectionGroupId, sectionGroupType, sevenFloats = #(), nbrFloats, floats = #() )
            
        /* get the mesh references that can be exported */
        local geos = #()
        local mtls =  Warcraft_III_Helpers.GetMTLS()
            
        for obj in objects do
        (
            if ( classof obj == editable_mesh ) then
            (
                if ( obj.ishidden == false ) then
                (
                    if ( classof obj.material == WarcraftIII_Standard or
                          ( 
                            classof obj.material == CompositeMaterial and 
                            classof obj.material.materialList[1] == WarcraftIII_Standard and
                            classof obj.material.materialList[2] == WarcraftIII_Standard 
                          )
                        ) then
                        (
                            local geo = geo800 meshRef:obj
                            append geos geo
                        )
                )
            )
        )
        
        /* for each mesh in this list of meshed do */
        for geo in geos do
        (
            local theMesh = geo.meshRef
            local original_vertices = #()
            local original_normals  = #()
            local original_weights  = Warcraft_III_Helpers.GetWeights theMesh

            /* because a vertex can have multiple vertex coordinates keep track of them */
            for v=1 to theMesh.numVerts do
            (
                original_vertices[v] = getVert theMesh v
                original_normals[v]  = getNormal theMesh v
            )

            local tvVertices = #()
            local faces = #()
            for i=1 to theMesh.numFaces do
            (
                local f = getFace theMesh i
                local u = getTvFace theMesh i

                faces[i] = u
                tvVertices[u.x] = f.x
                tvVertices[u.y] = f.y
                tvVertices[u.z] = f.z
            )

            -- if there are isolated vertices, these will show up in the tvVertices as undefined -> fix this
            for i=1 to tvVertices.count do
            (
                if (tvVertices[i] == undefined ) then tvVertices[i] = i as float
            )
            
            local vertices = #()
            local normals = #()
            local uvs = #()
            local weights = #()
            for i=1 to tvVertices.count do
            (
                local uv = getTvert theMesh i
                
                uvs[i] = [uv.x, 1.0 - uv.y]
                vertices[i] = original_vertices[tvVertices[i]]
                normals[i]  = original_normals[tvVertices[i]]
                weights[i]  = original_weights[tvVertices[i]]
            )
        
            geo.Size = 4 --> start initial size
            
            -- VRTX
            geo.Size += 8
            geo.vrtx = vertices --> vector 3
            geo.Size += vertices.count * 12
            
            -- NRMS
            geo.Size += 8
            geo.nrms = normals --> vector 3
            geo.Size += normals.count * 12
            
            -- PTYP --> type = triangle
            geo.Size += 12
            geo.ptyp = 0x4
            
            -- PCNT
            geo.Size += 12
            geo.pcnt = m.numFaces * 3 --> number of corners or indices in the group
            
            -- PVTX
            geo.Size += 8
            for f=1 to faces.count do
            (
                local face = faces[f]
                append geo.pvtx [face.x - 1, face.y - 1, face.z - 1]
            )
            geo.Size += faces.count * 6
            
            -- UVAS / UVBS
            geo.Size += 8

            geo.uvas = 1 --help.GetNumUVMaps m
            for u=1 to geo.uvas do
            (
                geo.Size += 8
                geo.uvbs = uvs
                geo.Size += uvs.count * 8
            )
            
            -- MATS
            geo.Size += 8
            geo.mats = mats800()
                        
            local boneindices = #()
            for w in original_weights do 
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

            local matrices = #()
            for i=1 to boneIndices.count do
            (
                if boneIndices[i][1] != 0 then append matrices boneIndices[i][1]
                if boneIndices[i][2] != 0 then append matrices boneIndices[i][2]
                if boneIndices[i][3] != 0 then append matrices boneIndices[i][3]
                if boneIndices[i][4] != 0 then append matrices boneIndices[i][4]
                
            )

            geo.mats.matrices = matrices
            geo.Size += matrices.count * 4
            
            for x=1 to mtls.count do
            (
                if ( theMesh.material.name == mtls[x].name ) then geo.mats.materialId = x - 1
            )
            
            geo.Size += 4 --> texture ID
            
            geo.mats.sectionGroupId = 0 --> always 0
            geo.mats.sectionGroupType = 0 --> if this would be an unselectable mesh, it should be 4
            geo.Size += 8 --> section group id, section group type
            
            local baseExtend = #()
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
                geo.mats.sevenFloats = baseExtend
            )

            geo.Size += 7 * 4

            geo.Size += 4 --> one long --> nbr of seqs
            geo.mats.nbrFloats = mdx.SEQS.count
            
            for seqs in mdx.SEQS do
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
                        
                        /* only when there is a scaling involved during certain animations, the extend is different */
                        local floatsToAdd = baseExtend
                        if ( matchpattern seqs.name pattern:"death*" or matchpattern seqs.name pattern:"dissipate" or matchpattern seqs.name pattern:"decay*" ) then 
                            floatsToAdd = Extend

                        for fl in floatsToAdd do append geo.mats.floats fl
                        
                    )
            )

            geo.Size += mdx.SEQS.count * 7 * 4
            
            -- GNDX
            geo.Size += 8 --> GNDX and nbr of gndx's 
            for w in original_weights do 
            (
                for bi=1 to boneIndices.count do
                (
                    if boneIndices[bi][1] == w.boneIndices[1] and
                       boneIndices[bi][2] == w.boneIndices[2] and
                       boneIndices[bi][3] == w.boneIndices[3] and
                       boneIndices[bi][4] == w.boneIndices[4] then
                    append geo.gndx bi
                )
            )
            geo.Size += geo.gndx.count --> only byte
            
            -- MTGC
            geo.Size += 8
            for n=1 to boneIndices.count do 
            (
                local counter = 0
                
                for bi in boneIndices do 
                    if bi != 0 then counter += 1
                
                append geo.mtgc counter
            )
            geo.Size += boneIndices.count * 4
            
            if WC3_MDX800_DEBUG then format " - Size: %\n" geo.size
           --append geos.geos geo
        )
        
        mdx.geos = geos
        return geos
    )
)