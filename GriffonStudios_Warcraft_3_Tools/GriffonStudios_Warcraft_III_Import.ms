/*
    .SYNOPSIS
    | Importer for Warcraft III mdx (old version = version 800 )
    
    .COPYRIGHT
    | �2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 0.3 - Clean up for usage
    | 0.2 - Applied correct skinning ( after re-reading nintoxicated's script )
    | 0.1 - Initial setup

*/

clearlistener()
fileIn "GriffonStudios_Warcraft_III_Plugins_Material.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Attachment.ms"
fileIn "GriffonStudios_Warcraft_III_Plugins_Event.ms"
fileIn "GriffonStudios_Warcraft_III_Helpers.ms"
fileIn "GriffonStudios_Helpers.ms"

GLOBAL WC3_MDX800_DEBUG = true
GLOBAL WC3_MDX = undefined
STRUCT WC3_MDX800
(   
    function ReadCAMS800 stream tag=
    (
        struct cam800 ( size, name, camPos, FOV, farClip, nearClip, targetPos )
        
        local cams = #()
        local totalSize = tag.size
        local currentOffset = tag.offset
        while (totalSize > 0) do
        (
            fseek stream currentOffset #seek_set
                
            local cam = cam800()
            
            cam.size = readLong stream
            cam.name = GriffonStudios_Helpers.ReadFixedString stream 80
            cam.camPos = [readFloat stream,readFloat stream,readFloat stream]
            cam.FOV = radToDeg ( readFloat stream )
            cam.FarClip = readFloat stream
            cam.NearClip = readFloat stream
            cam.targetPos = [readFloat stream,readFloat stream,readFloat stream]
            
            append cams cam
            totalSize -= cam.size
            currentOffset += cam.size
        )
        if WC3_MDX800_DEBUG then print cams
        return cams
    ),
    function ReadTAGS800 stream streamLen=
    (
        struct tag800 ( Name, Offset, Size )     
        
        local tags = #() 
        local mainTag = tag800()

        mainTag.Name = GriffonStudios_Helpers.ReadFixedString stream 4
        mainTag.Offset = 0
        mainTag.Size = 0
        
        local currentStreamPos = ftell stream

        while (currentStreamPos < streamLen ) do
        (
            local tag = tag800()
            
            tag.Offset = ftell stream + 8 -- the +8 indicates where the data starts
            tag.Name = GriffonStudios_Helpers.ReadFixedString stream 4
            tag.Size = ReadLong stream
            
            GriffonStudios_Helpers.SkipBytes stream tag.Size

            currentStreamPos = ftell stream
            
            append tags tag
            --print tag
        )
        return tags
    ),
    function ReadEVTS800 stream tag=
    (
        /*
            for a full understanding what these sounds are, see the official Warcraft III Art Tools documentation
            
        */
        
        struct evts800 ( Id, Name, ParentId, Flags, KEVT, objRef )
        fseek stream tag.Offset #seek_set
        local evts = #()
              
        
        while ( ftell stream < (tag.offset + tag.size)) do
        (
            local evt = evts800()
            local size = readLong stream
            
            evt.name = GriffonStudios_Helpers.ReadFixedString stream 80
            evt.id  = readLong stream + 1
            evt.parentId = readLong stream + 1
            evt.flags = readLong stream
            local kevt = GriffonStudios_Helpers.ReadFixedString stream 4
            if ( kevt == "KEVT" ) then
            (
                local keys = #()
                local nbr = readLong stream
                local parentId = readLong stream + 1
                for i=1 to nbr do 
                (
                    local key =  ( GriffonStudios_Helpers.RoundToFrame ( readLong stream ) ) + 10
                    append keys key
                )
                evt.KEVT = keys
            )
            else
            (
                format "Animation not implemented in ReadEVTS (%)"  evts
            )
            append evts evt
            
           
        )
        
        return evts
    ),
    function ReadATCH800 stream tag=
    (
        struct atch800 ( Id, Name, ParentBoneId, Flags, Offset, Size, KGTR, KGRT, KGSC, KATV)
        
        fseek stream tag.Offset #seek_set
        
        local atchs = #()

        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local att = atch800()
            
            local size = readLong stream
            local headerSize = readLong stream --> 96 bytes consisting of name, id, parentId and flagid and headerSize

            att.name = GriffonStudios_Helpers.ReadFixedString stream 80
            att.Id = readLong stream + 1
            att.ParentBoneId = readLong stream + 1
            att.flags = readLong stream
            att.Offset = ftell stream
            att.Size = size - 4 - 4 - 80 - 8 - 4
            
            GriffonStudios_Helpers.SkipBytes stream att.Size
        
            append atchs att
        )
        
        for att in atchs do
        (
            fseek stream att.offset #seek_set
            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )
            
            att.KGTR = kgtr
            att.KGRT = kgrt
            att.KGSC = kgsc
            local correction = 0
            if ( kgtr == undefined ) then correction = correction + 4
            if ( kgrt == undefined ) then correction = correction + 4
            if ( kgsc == undefined ) then correction = correction + 4
           
            GriffonStudios_Helpers.SkipBytes stream ( 264 - correction)

            local katv = GriffonStudios_Helpers.ReadFixedString stream 4
            
            if( katv == "KATV") then att.katv = Warcraft_III_Helpers.ReadFloatAnim stream -- visibility track ?

        )
        
        return atchs
        
    ),
    function ReadBONE800 stream tag=
    (
        struct bone800 ( Id, Name, ParentBoneId, Flags, boneRef, KGTR, KGRT, KGSC, offset, geosetId, geosetAnimationId )
        
        fseek stream tag.offset #seek_set
                
        local boneList = #()

        /* read the bone chunks*/
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local b = bone800()
            
            local size = readLong stream
        
            b.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            b.Id = readLong stream + 1
            b.ParentBoneId = readLong stream + 1
            
            b.Flags = readLong stream
            b.offset = ftell stream
            
            GriffonStudios_Helpers.SkipBytes stream ( size - 80 - 16 )
            
            b.geosetId =  readlong stream
            b.geosetAnimationId =  readlong stream

            append boneList b
        )
        /* read the animation frames */
        for b in boneList do
        (
            fseek stream b.offset #seek_set

            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )
            
            b.KGTR = kgtr
            b.KGRT = kgrt
            b.KGSC = kgsc
            
        )
        
        return boneList
    ),
    function ReadCLID800 stream tag=
    (
        /*
            0: cube
            1: plane
            2: sphere
            3: cylinder
        */
        
        struct clid800( size, name, id, parentid, flags, KGTR, KGRT, KGSC, CollisionType, StartPosition, EndPosition, Radius )
        local clidList = #()
        local totalSize = tag.size
        local currentOffset = tag.Offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local startPos = ftell stream
            
            local clid = clid800()
            
            clid.size = readLong stream
            clid.name = GriffonStudios_Helpers.ReadFixedString stream 80
            clid.Id = readLong stream + 1
            clid.parentId = readLong stream + 1
            clid.flags = readLong stream

            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then clid.KGTR = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then clid.KGRT = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then clid.KGSC = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )
            local currentPos = ftell stream
            
            if (clid.KGTR == undefined ) then currentPos -=4
            if (clid.KGRT == undefined ) then currentPos -=4
            if (clid.KGSC == undefined ) then currentPos -=4
            
            fseek stream currentPos #seek_set
            
            clid.CollisionType = readLong stream
            clid.StartPosition = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( clid.CollisionType != 2 ) then clid.EndPosition = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( clid.CollisionType == 2 or clid.CollisionType == 3 ) then clid.radius = readFloat stream
            
            currentOffset = ftell stream
            append clidList clid
            local size = currentOffset - startPos
            totalSize -= size
            
        )
        --print clidList
        return clidList
    ),
    function ReadPIVT800 stream tag=
    (
        fseek stream tag.offset #seek_set
        local nbr = tag.Size / 12.0
        local pivts = #()
        for n=1 to nbr do
        (
            local m  = matrix3 1
            m.row4 = [readfloat stream, readfloat stream, readfloat stream]
            append pivts m
        )
        --print pivts
        return pivts
    ),
    function ReadHELP800 stream tag=
    (
        
        local totalSize = tag.Size
        local helperList = #()
        
        struct help800 ( size, name, id, parentId, flags, KGTR, KGRT, KGSC, helperRef )
        
        local currentOffset = tag.Offset
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local h = help800()
            h.size = readLong stream
            h.name = GriffonStudios_Helpers.ReadFixedString stream 80
            h.Id = readLong stream + 1
            h.parentId = readLong stream + 1
            h.flags = readLong stream
            
            for i=1 to 3 do
            (
                local kg = GriffonStudios_Helpers.ReadFixedString stream 4

                if ( kg == "KGTR" ) then h.KGTR = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then h.KGRT = Warcraft_III_Helpers.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then h.KGSC = Warcraft_III_Helpers.ReadVector3Anim stream -- Key Global Scale
            )

            
            totalSize -= h.size
            currentOffset = currentOffset + h.Size
            
            append helperList h
        )
        
       -- print helperList
        return helperList
    ),
    function ReadGEOA800 stream tag=
    (
        fseek stream tag.Offset #seek_set
        local totalSize = tag.Size
        local geoa = #()
        
        struct geoa800 (size, opacity, geoId, color, index)
        
        while ( totalSize > 0 ) do
        (
            local g = geoa800()
            g.size      = readLong stream
            g.opacity   = readFloat stream
            g.geoId     = readLong stream
            g.color     = color (readFloat stream * 255.0) (readFloat stream * 255.0) (readFloat stream * 255.0) 1.0
            g.index     = readlong stream
            
            append geoa g
            
            totalSize -= g.Size
        )
    
        --print geoa
        return geoa
    ),
    function ReadVERS800 stream tag=
    (
        fseek stream tag.Offset #seek_set
        local version = readLong stream
        if(version != 800 ) then 
            throw ("Version " +  (version as string) + " not supported !" )
        return version
    ),
    function ReadTEXS800 stream tag=
    (
        struct texs800 ( replacableId, path, flags )
        fseek stream tag.offset #seek_set
        local texs = #()
        
        local numTexs = tag.Size / 268
        
        for i=1 to numTexs do
        (
            local t = texs800()
           
            t.replacableId = readLong stream 
            t.path = GriffonStudios_Helpers.ReadFixedString stream 260
            t.flags = readLong stream
            
            append texs t
        )
        --print texs
        return texs
    ),
    function ReadMTLS800 stream tag=
    (
        
        struct layer800 ( name, size, priority, flags, nMaps, maps = #(), materialRef )
        struct map800 ( size, filterMode, shadingFlags, textureId, parentId, coordId, alpha, kmta, kmte )
        
        -- FilterMode (0:none;1:trans;2:blend;3:add)
        -- ShadingFlags (1:unshaded;+16:two sided;+32:unfogged)
        
        fseek stream tag.offset #seek_set
        local totalSize = tag.size
        
        local mtls = #()
        local id = 1
        
        while ( totalSize > 0 ) do
        (
            local layer = layer800()
            
            layer.size     = readLong stream
            layer.priority = readLong stream
            layer.flags    = readLong stream
            layer.name     = GriffonStudios_Helpers.ReadFixedString stream 4
            layer.nMaps    = readLong stream
            
            for i=1 to layer.nMaps do
            (
                local map   = map800()
                map.size          = readLong stream --> 28 bytes
                map.filterMode    = readLong stream 
                map.shadingFlags  = readLong stream 
                map.textureId     = readLong stream 
                map.parentId      = readLong stream 
                map.CoordId       = readLong stream
                map.alpha         = readfloat stream
             
                if (map.size > 28 ) then
                (
                    for x=1 to 2 do
                    (
                        local km = GriffonStudios_Helpers.ReadFixedString stream 4
                        if ( km == "KMTA" ) then lay.KMTA = Warcraft_III_Helpers.ReadFloatAnim stream
                        if ( km == "KMTE" ) then lay.KMTE = Warcraft_III_Helpers.ReadFloatAnim stream
                        
                    )
                    if ( lay.KMTA == undefined ) then fseek stream -4 #seek_cur
                    if ( lay.KMTE == undefined ) then fseek stream -4 #seek_cur
                )
                append layer.maps map
                
            )
            totalSize -= layer.size
            
            id +=1
           --print layer
            append mtls layer
        )
        
        return mtls
        
    ),
    function ReadGEOS800 stream tag=
    (
        struct geo800  
            (   uniqueName, VRTX = #(), NRMS = #(), PTYP = #(), PCNT = #(), PVTX = #(), GNDX = #(), MTGC = #(), MATS = #(), UVS = #(), meshRef, 
                bones = #(),  --> bones indexes for weighing the vertices, vertices are equally weighted -> 2 bones => so 1 vertex is 0.5
                uniqueBoneIds = #() --> the list of bones required for this whole mesh
            )
        struct mats800 ( nbrItems, name, matrices = #(), id, sectionGroupId, sectionGroupType, sevenFloats = #(), nbrFloats, floats = #() )
        local total_size = tag.size
        local offset = tag.offset
        
        local geos = #()
        while ( total_size > 0 ) do
        (
            fseek stream offset #seek_set
            
            local geo = geo800() 
            local chunk_size = readLong stream
            
            for h=1 to 9 do
            (
                local header = GriffonStudios_Helpers.ReadFixedString stream 4
                --format "% \n" header
                if header == "VRTX" then 
                (
                    local amount = readLong stream
                    for v=1 to amount do append geo.vrtx (Warcraft_III_Helpers.ReadVector3 stream)
                    -- format "% %\n" header amount
                )
                if header == "NRMS" then 
                    for v=1 to (readLong stream) do append geo.nrms (Warcraft_III_Helpers.ReadVector3 stream)

                if header == "PTYP" then 
                    for v=1 to (readLong stream) do append geo.ptyp (readLong stream)
                
                if header == "PCNT" then 
                    for v=1 to (readLong stream) do append geo.pcnt (readLong stream)
                
                if header == "PVTX" then 
                    for v=1 to (readLong stream)/3 do append geo.pvtx (Warcraft_III_Helpers.ReadTris stream)
                
                if header == "GNDX" then -- groups
                (
                    local amount = readLong stream
                    local maxBoneIndex = 0
                    for v=1 to amount do 
                    (
                        local boneIdx = readbyte stream + 1
                        append geo.gndx boneIdx

                    )
                    --format "% %\n" header amount
                    
                )
                if header == "MTGC" then -- boneGroups
                (
                    local amount = readLong stream
                    for v=1 to amount do append geo.mtgc (readLong stream)
                    --format "Bonegroups: % %\n" header amount
                )
                if header == "MATS" then 
                (
                    
                    geo.mats = mats800()
                    
                    geo.mats.nbrItems = readLong stream
                    for v=1 to geo.mats.nbrItems do append geo.mats.matrices (readLong stream + 1) 
                    
                    geo.mats.Id = readlong stream
                    geo.mats.sectionGroupId = readlong stream
                    geo.mats.sectionGroupType = readlong stream
                    for i=1 to 7 do append geo.mats.sevenFloats (readfloat stream) -- vector3 + quaternian ?
                    
                    geo.mats.nbrFloats = readLong stream
                    for i=1 to geo.mats.nbrFloats * 7 do append geo.mats.floats (readfloat stream )
                    --format "Material Structures: % %\n" header geo.mats.nbrItems
                )

                if header == "UVAS" then 
                (
                    local amount = readLong stream
                    for i=1 to amount do
                    (
                        local uvs = #()
                        local uvbs = GriffonStudios_Helpers.ReadFixedString stream 4
                        local nUvbs = readLong stream

                        for u=1 to nUvbs do
                            append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )
                        append geo.UVS uvs
                    )
                    --format "% %\n" header amount
                )
            )

            append geos geo
            
            offset += chunk_size
            total_size -= chunk_size
        )
        -- calculate the bones the need to be added per vertex
        for geo in geos do
        (
            index = 1
            for mtgc in geo.MTGC do
            (
                list = #()
                for i=1 to mtgc do
                (
                    append list geo.MATS.matrices[index]
                    index  +=1
                )
                append geo.bones list
            )
            for boneId in geo.mats.matrices do
                appendIfUnique geo.uniqueBoneIds boneId
            
            geo.uniqueBoneIds = sort geo.uniqueBoneIds
        )
        
        
        
        return geos
        
    ),
    function ReadMODL800 stream tag=
    (
        struct modl800 ( name, path, radius, bbox, Always150 )
        local modl = modl800()
        fseek stream tag.offset #seek_set
        
        modl.name = GriffonStudios_Helpers.ReadFixedString stream 80
        modl.path = GriffonStudios_Helpers.ReadFixedString stream 260
        
        modl.bbox = #()
        modl.radius = readFloat stream / 4.0
        append modl.bbox [readFloat stream, readFloat stream, readFloat stream]
        append modl.bbox [readFloat stream, readFloat stream, readFloat stream]
        modl.Always150 = readLong stream

        return modl
    ),
    function ReadSEQS800 stream tag=
    (
        
        struct seqs800 ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity,Priority,Default, BBox )
        
        fseek stream tag.offset #seek_set
        
        local nbrSeqs = tag.size / 132
        local seqs = #()
        
        for i=1 to nbrSeqs do
        (
            local seq = seqs800()
            seq.Name = GriffonStudios_Helpers.ReadFixedString stream 80
            
            local originalStartFrame = readLong stream
            local originalEndFrame = readLong stream
            
            --format "Original sequence: % (%-%)\n" seq.Name originalStartFrame originalEndFrame
            
            seq.StartFrame = ( GriffonStudios_Helpers.RoundToFrame ( originalStartFrame ) ) + 10
            seq.EndFrame = ( GriffonStudios_Helpers.RoundToFrame ( originalEndFrame ) ) + 10
            seq.MovementSpeed = readFloat stream
            seq.NoLoop = readLong stream
            seq.Rarity = readFloat stream
            seq.Default = readlong stream
            seq.Priority = readFloat stream
            
            seq.BBox = #([readfloat stream,readfloat stream,readfloat stream], [readfloat stream,readfloat stream,readfloat stream] )

            append seqs seq
        )

        if (mdxConvertToSC2AnimationNames == true ) then 
            StarTools_Helpers.RenameSEQS seqs

        return seqs
        
    ),
    function BuildGEOS800 mdx=
    (
        if mdx.geos == undefined then return undefined
        format "Building Meshes \n"
        local layer = GriffonStudios_Helpers.CreateLayer "Unit"
        for i=1 to mdx.geos.count do 
         (
            local geo = mdx.geos[i]
            
            local r = random 1 255
            local g = random 1 255
            local b = random 1 255
            local wireColor = color r g b
            
            local v = geo.VRTX
            local n = geo.NRMS
            local f = geo.PVTX
            local uv = geo.UVS[1]
            
            geo.MATS.name = mdx.modl.name + "_" + ( i as string )
            
            local theMesh = mesh vertices:v vnorms:n name:geo.MATS.Name faces:f tverts:uv 

            theMesh.WireColor = wireColor
            
            buildTVFaces theMesh false
            for i = 1 to f.count do
            ( setTVFace theMesh i f[i] )
        
            layer.AddNode theMesh
            
            update theMesh
            resetXform theMesh
            
            maxOps.CollapseNodeTo theMesh 1 off
            
            geo.meshRef = theMesh
        )
        
    ),
    function BuildSEQS800 mdx=
    (
        if mdx.seqs == undefined then return undefined
        format "Building Animation Sequences\n"
        local animTrack1 = undefined 
        local nNoteTracks = numNoteTracks rootNode
        if(  nNoteTracks > 0 ) then
        (
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode (getNoteTrack rootNode 1)
        )
        if( numNoteTracks rootNode == 0 ) then
        (
            animTrack1 = notetrack "AnimTrack1"
            addNoteTrack rootNode animTrack1
        )
        local prevEndFrame = 0                       
        
        for t=1 to mdx.seqs.count do
        (
            local seq = mdx.seqs[t]
            local theAnimTrack = animTrack1 --> always pick first one

            local startNote = AddNewNoteKey theAnimTrack seq.startFrame
            local endNote = AddNewNoteKey theAnimTrack seq.endFrame
            
            local val = seq.name + "\r\n"
                  val += "rarity = " 	 + (seq.Rarity as string)    + "\r\n"
                  val += "moveSpeed = "  + (seq.MovementSpeed as string) + "\r\n"
                  val += "nonLoop = " 	 + (seq.Noloop as string)    + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + (seq.Priority as string)

           
            startNote.Value = val
            endNote.Value = val

            format "Animation sequence: % (%-%)\n" seq.name seq.startFrame seq.endFrame
			
        )
        
    ),
    function BuildAndAssignMaterials mdx=
    (
        if mdx.mtls == undefined then return undefined
        format "Building Materials\n"
        /*
            Replacable Id's
            0 - Diffuse map
            1 - Use teamcolor in the texture
            2 - Use team glow -> a radial texture with teamcolor ( hero glow )
        */
        
        WC3_MDX800.BuildMaterials800 mdx
        for geo in mdx.geos do
            geo.meshRef.material = mdx.mtls[geo.mats.id+1].materialRef

    ),
    function BuildMaterials800 mdx=
    (
        
        for x=1 to 24 do 
        (
            local matname = "Standard Material - " + (x as string)
            meditMaterials[x] = standard name:matname
        )
        
        
        local m = 0
        for mtl in mdx.mtls do
        (
            
            local map = mtl.maps[1]
            local mat = WC3_MDX800.CreateWC3Material mdx map m
            

            if( mtl.nMaps == 1 ) then 
            (
                mtl.materialRef = mat
                showTextureMap mtl.materialRef true
            )
            else
            (
                m = m + 1
                mtl.materialRef = compositematerial()
                mtl.materialRef.name = mdx.modl.name + "_COMPOSITE_" + ( m as string )
                
                for y=mtl.nMaps to 9 do mtl.materialRef.mapEnables[y] = off
                mtl.materialRef.baseMaterial = mat
                
                for i=2 to mtl.nMaps do 
                (
                    local map = mtl.maps[i]
                    m = m + 1
                    local submat = WC3_MDX800.CreateWC3Material mdx map m
                    
                    mtl.materialRef.materialList[i] = submat
                )
                
                for ml in mtl.materialref.materialList do
                (
                    if ( ml.diffuse_map.fileName != "") then (
                        showTextureMap ml true
                        exit
                    )
                )
                
            )
            
        )
        
        for i=1 to mdx.mtls.count do 
        (
            local mtl = mdx.mtls[i]
            if ( i <= 24 and mtl.materialRef != undefined ) then
                meditMaterials[i] = mtl.materialRef
        )
    ),
    function CreateWC3Material mdx map index=
    (
        local mat = WarcraftIII_Standard()
        mat.name = mdx.modl.name + "_MATERIAL_" + ( index as string )
        local tex = mdx.texs[map.textureId + 1]
        
        mat.ReplaceableTexture = tex.ReplacableId + 1
        mat.Alpha = map.alpha * 100.0
        mat.FilterMode = map.filtermode + 1
        
        if( bit.and map.shadingflags 0x01 > 0) then mat.unshaded = true
        if( bit.and map.shadingflags 0x10 > 0) then mat.twosided = true
        if( bit.and map.shadingflags 0x20 > 0) then mat.unfogged = true
        if( bit.and map.shadingflags 0x40 > 0) then mat.nodepthset = true
        if( bit.and map.shadingflags 0x80 > 0) then mat.nodepthtest = true
        if( bit.and map.shadingflags 0x100 > 0) then mat.unselectable = true

        if ( tex.path != "") then 
        (
            local file_path = getFileNamePath mdx.fileName
            local file_name = getFileNameFile tex.path
            local fileName = file_path + file_name + ".TGA"
            mat.Diffuse_Map = Bitmaptexture fileName:fileName  
        )
        
        return mat
    ),
    function BuildBonesAndHelpers mdx=
    (
        
        local boneLayer = GriffonStudios_Helpers.CreateLayer "Bones"
        local helpLayer = GriffonStudios_Helpers.CreateLayer "Helpers"
        
        mdx.objs = #()
        
        if mdx.bone != undefined then
        for b in mdx.bone do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.setBoneEnable false 0
            
            b.boneRef = aBone
            b.boneRef.pos = mdx.pivt[b.id].translationpart
            boneLayer.AddNode aBone
            
            append mdx.objs aBone
        )
        if mdx.help != undefined then
        for h in mdx.help do
        (
            local d = dummy name:h.name
            d.showLinks = true
            helpLayer.addNode d
            d.pos = mdx.pivt[h.id].translationpart
            h.helperRef = d
            append mdx.objs d
        )
        
    ),
    function BuildBONE800 mdx=
    (
        if mdx.bone == undefined then return undefined
        format "Building Bones\n"
        local boneList = mdx.bone
        local bpos = mdx.pivt
        
        -- build the hierarchy
        for b in boneList do
            if ( b.ParentBoneId > 0 ) then b.boneRef.parent = mdx.objs[b.parentBoneId]

        for objX in objects do
            addNewKey objX.controller 0

        for obj in boneList do
        (
            local b = obj.boneRef
            
            b.assumeSkinPose()

            if ( obj.KGRT != undefined ) then 
            (
               -- b.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                local prevTime = 0
                
                for anim in obj.KGRT.KG do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            if ( obj.KGTR != undefined ) then
            (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = b.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in obj.KGTR.KG do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point

                        if ( prevTime == t ) then continue else prevTime = t
                        
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on b.position.controller = copy dp.position.controller
                    
                    delete dp
            )
            
            if ( obj.KGSC != undefined ) then
            (
               -- b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in obj.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )
            
        )
    ),
    function BuildHELP800 mdx=
    (
        if mdx.help == undefined then return undefined
        format "Building Helpers\n"
        for h in mdx.help do
        (
            local d = h.helperRef
            if( h.parentId > 0 ) then 
                d.parent = mdx.objs[h.parentId]
            
            addNewKey d.controller 0
            
            d.assumeSkinPose()

            if ( h.KGRT != undefined ) then 
            (
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = d.rotation.controller
                local q0 = dr.transform
                local prevTime = 0
                
                for anim in h.KGRT.KG do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on d.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            if ( h.KGTR != undefined ) then
            (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = d.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in h.KGTR.KG do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point

                        if ( prevTime == t ) then continue else prevTime = t
                        
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on d.position.controller = copy dp.position.controller
                    
                    delete dp
            )
            
            if ( h.KGSC != undefined ) then
            (
               -- b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = d.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in h.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.scale = p 
                        )
                )
                with animate on d.scale.controller = copy ds.scale.controller
                
                delete ds
            )
        )
        
    ),
    function BuildEVTS800 mdx=
    (
        if mdx.evts == undefined then return undefined
        format "Building Events\n"
        local evts = mdx.evts
        
        if (evts == undefined ) then return undefined
        local layer = GriffonStudios_Helpers.CreateLayer "Events"
        
        for evt in evts do
        (
            local pnt = WarcraftIII_Event()  -- point name:evt.Name
            
            pnt.Name = evt.name

            if ( evt.parentId > 0 ) then evt.pos = mdx.pivt[evt.parentId].translationpart
            
            for key in evt.KEVT do
                pnt.AddKey key
            
            evt.objRef = pnt
            layer.AddNode pnt
        )
        
    ),
    function BuildCLID800 mdx=
    (
        if mdx.clid == undefined then return undefined
        format "Building Collision Objects\n"
        local bpos = mdx.pivt
        local layer = GriffonStudios_Helpers.CreateLayer "Collision Objects"
        
        for cl in mdx.clid do
        (
            local clObj = undefined
            
            -- CUBE
            if(cl.CollisionType == 0 ) then 
            (
                local diameter = distance cl.startPosition cl.EndPosition
                local radius = diameter / 2.0 * 0.8
                clObj = Sphere radius:radius name:cl.name pos:cl.startPosition
            )
            
            -- PLANE
            if(cl.CollisionType == 0 ) then 
            (
                local x = distance [cl.startPosition.x,0,0] [cl.EndPosition.x,0,0]
                local y = distance [0,cl.startPosition.y,0] [0,cl.EndPosition.y,0]
                
                clObj = Plane length:x width:y name:cl.name pos:cl.startPosition
            )
            
            -- SPHERE
            if(cl.CollisionType == 2 ) then
            (
                clObj = Sphere radius:cl.Radius name:cl.name pos:cl.startPosition
            )
            
            -- Cylinder
            if(cl.CollisionType == 3 ) then
            (
                local height = distance [0, 0, cl.startPosition.z] [0, 0, cl.endPosition.z]
                clObj = Cylinder radius:cl.Radius name:cl.name pos:cl.startPosition height:height heightsegs:1 sides:12
            )
            
            
            if clObj == undefined then return undefined

            clObj.pos = mdx.pivt[cl.id].translationpart
            
            --print cl
            
            if cl.parentId > 0 then cl.parent = mdx.bone[cl.parentId].boneRef
            
            local mtrx = bpos[cl.id]    
            
            if ( cl.KGRT != undefined ) then 
            (
                
                for anim in cl.KGRT.KG do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx clObj.rotation = q
                )
                    
            )
            
            if ( cl.KGTR != undefined ) then 
            (

                local prevTime = 0
                for anim in cl.KGTR.KG do
                (
                    local t = anim.time + 10
                    local p = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on at time t in coordsys mtrx clObj.pos = p
                )
                    
            )
            
            clObj.boxmode = true
            clObj.wirecolor = color 64 128 255
            clObj.renderable = off
            clObj.castShadows = off
            clObj.receiveshadows = off
            clObj.ApplyAtmospherics = off
            clObj.inheritVisibility = off
            clObj.primaryVisibility = off
            clObj.secondaryVisibility = off
            freeze clObj
            layer.addnode clObj
        )
    ),
    function BuildATCH800 mdx=
    (
        
        if mdx.atch == undefined then return undefined
        format "Building Attachments\n"
        local layer = GriffonStudios_Helpers.CreateLayer "Attachments"
        sliderTime = 0f
        
        for a in mdx.atch do
        (
        
            local pnt = WarcraftIII_Attachment name:a.name
            pnt.pos = mdx.pivt[a.id].translationpart
            layer.AddNode pnt
            
            if ( a.ParentBoneId > 0 ) then
                pnt.parent = mdx.objs[a.ParentBoneId]

        )
        
    ),
    function BuildMODL800 mdx=
    (
        format "Building base models\n"
        local layer = GriffonStudios_Helpers.CreateLayer "Bounding Box"
        
        local obj = GriffonStudios_Helpers.BuildBoundingBox mdx.modl.bbox
        obj.name = "MODL - " + mdx.modl.name
        freeze obj
        obj.boxmode = true
        obj.wirecolor = color 100 100 100
        layer.addNode obj
        
        if mdx.modl.radius > 0 then 
        (
            local pos = obj.max.z/2.0
            local obj2 = sphere name:"Selection Sphere" radius:mdx.modl.radius pos:[0,0,pos]
        
            freeze obj2
            obj2.boxmode = true
            obj2.wirecolor = color 100 100 100
            layer.addNode obj2
        )
        
        
    ),
    function ApplySkinning mdx=
    (
        format "Apply Skinning (this may take some time )\n"
        completeRedraw()
        for geo in mdx.geos do
        (
            -- get a reference to the scene mesh
            local obj = geo.meshRef
            
            -- apply the skin modifier
            max modify mode
            mshSkin = skin()
            addmodifier obj mshSkin
            select obj
            modPanel.setCurrentObject mshSkin
        
            -- add the bones to the modifier
            for uniqueBoneId in geo.uniqueBoneIds do
            (
                local b = mdx.bone[uniqueBoneId].boneRef
                skinOps.addBone mshSkin b 0
            )
            update obj
            
            for v=1 to obj.verts.count do -- geo.VRTX.count do
            (
                local gndx = geo.GNDX[v]
                local boneRefIds = geo.bones[gndx]
                local boneIds = #()
                for boneRefId in boneRefIds do 
                (
                    for u=1 to geo.uniqueBoneIds.count do
                    (
                        local uniqueId = geo.uniqueBoneIds[u]
                        if uniqueId == boneRefId then append boneIds u
                    )
                )
                
                local weights = #()
                local weight = 1.0 / boneIds.count
                for i=1 to boneIds.count do
                    append weights weight
                
               -- skinOps.SetVertexWeights mshSkin v boneIds weights
                
                skinOps.ReplaceVertexWeights mshSkin v boneIds weights
                
            )
            update obj
        )
        completeRedraw()
        
    ),
    function BuildCAMS800 mdx=
    (
        if mdx.cams == undefined then return undefined  
        format "Building Cameras \n"
        local layer = GriffonStudios_Helpers.CreateLayer "Cameras"
        
        for i=1 to mdx.cams.count do
        (
            local c = mdx.cams[i]
            local targetName = c.name + ".Target." + ( i as string)
            local camName = c.name + ( i as string)
            local target = Targetobject pos:c.targetPos name:targetName wirecolor:red 
            local cam = Targetcamera fov:c.FOV farclip:c.farClip nearclip:c.nearClip pos:c.camPos name:camName wirecolor:yellow target:target
            layer.AddNode target
            layer.AddNode cam
        )
        
        
    ),
    function Import file=
    (
        clearlistener()
        SetWaitCursor()
        animationrange = interval 0 150
        slidertime = 0
        local stream = fOpen file "rb"
        local streamLen = GriffonStudios_Helpers.GetStreamLength stream
        
        struct mdx800 
            ( tags, fileName, vers, modl, seqs, glbs, mtls, texs, geos, geoa, bone, help, atch, pivt, evts, clid, cams, objs )
        
        local mdx = mdx800()
        mdx.fileName = file
        mdx.tags = WC3_MDX800.ReadTAGS800 stream streamLen
        
        for tag in mdx.tags do 
        (
            --format "Reading TAG: %\n" tag.name
            if tag.name == "VERS" then mdx.vers = WC3_MDX800.ReadVERS800 stream tag
            if tag.name == "MODL" then mdx.modl = WC3_MDX800.ReadMODL800 stream tag
            if tag.name == "SEQS" then mdx.seqs = WC3_MDX800.ReadSEQS800 stream tag
            if tag.name == "MTLS" then mdx.mtls = WC3_MDX800.ReadMTLS800 stream tag
            if tag.name == "TEXS" then mdx.texs = WC3_MDX800.ReadTEXS800 stream tag
            if tag.name == "GEOS" then mdx.geos = WC3_MDX800.ReadGEOS800 stream tag
            if tag.name == "GEOA" then mdx.geoa = WC3_MDX800.ReadGEOA800 stream tag
            if tag.name == "BONE" then mdx.bone = WC3_MDX800.ReadBONE800 stream tag
            if tag.name == "HELP" then mdx.help = WC3_MDX800.ReadHELP800 stream tag
            if tag.name == "ATCH" then mdx.atch = WC3_MDX800.ReadATCH800 stream tag
            if tag.name == "PIVT" then mdx.pivt = WC3_MDX800.ReadPIVT800 stream tag
            if tag.name == "EVTS" then mdx.evts = WC3_MDX800.ReadEVTS800 stream tag
            if tag.name == "CLID" then mdx.clid = WC3_MDX800.ReadCLID800 stream tag
            if tag.name == "CAMS" then mdx.cams = WC3_MDX800.ReadCAMS800 stream tag
        )
        
        fclose stream
        if WC3_MDX800_DEBUG then WC3_MDX = mdx
        WC3_MDX800.BuildMODL800 mdx
        WC3_MDX800.BuildGEOS800 mdx
        WC3_MDX800.BuildSEQS800 mdx
        WC3_MDX800.BuildAndAssignMaterials mdx
        WC3_MDX800.BuildBonesAndHelpers mdx
        WC3_MDX800.BuildHELP800 mdx
        WC3_MDX800.BuildBONE800 mdx
        WC3_MDX800.BuildEVTS800 mdx
        WC3_MDX800.BuildCLID800 mdx
        WC3_MDX800.ApplySkinning mdx
        WC3_MDX800.BuildATCH800 mdx
        WC3_MDX800.BuildCAMS800 mdx
        
        gc()
        setArrowCursor() 
    )
)

file = getOpenFileName caption:"Import MDX" \
                       types:"WarCraft III MDX File (*.mdx)|*.mdx|All Files (*.*)|*.*|"

if ( file != undefined and doesfileexist file ) then 
    WC3_MDX800.Import file -- @"F:\Blizzard\Warcraft - Reforged\Warcraft III\Spartan Warrior\Spartan Warrior\SpartanWarrior.mdx"
        
