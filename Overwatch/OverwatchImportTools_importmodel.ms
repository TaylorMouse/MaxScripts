/*
    Blizzard Overwatch Model Importer (.00C)

    © 2017~2018 Script by Taylor Mouse

    Special thanks to id-daemon for reviewing and correcting the animation
    Special thanks to dynaomi for the awesome overtool.exe
    
    Release notes:
    - v1.1 added support for multiple texture coordinates uv maps
    - v1.0 packed for mzp
    - v0.8 added import dialog
    - v0.7 fix bone reference pose
    - v0.6 apply bone indices and vertex weights
    - v0.5 read bone indices and vertex weights
    - v0.4 build bone structure
    - v0.3 read bones structure
    - v0.2 read and build hard points 
    - v0.1 read new mesh format


*/
fileIn "TMsHelperScripts.ms"

    STRUCT OWChunk 
        ( name, Size, Size2, CheckSum, Offset )
    STRUCT MRNMChunk 
        ( nr_vertices, nr_submesh_desc, nr_materials, nr_vertex_buffer_desc, nr_index_buffer_desc, vertex_buffer_desc, index_buffer_desc, submesh_desc, submeshes, vertex_buffers, index_buffers );
    STRUCT OWSubmesh 
        ( vertex_start, index_start, index_count, nr_indices_to_draw, nr_vertices_to_draw, offset_bone_id, index_buffer_used, vertex_buffer_used, flags, mat_id, LOD_Flag)
    STRUCT OWVertexBuffer
        ( nr_input_elements, stream_1_block_size, stream_2_block_size, nr_vertex_elements_desc, vertex_elements_desc, stream_1_desc, stream_2_desc, vertex_element_list )
    STRUCT OWIndexBuffer
        ( nr_indices, index_format, offset )
    STRUCT OWVertexElement
        ( semantic_type, semantic_index, data_format, stream_number, classification, stride_offset )
    STRUCT OWHardPoint
        ( hp_name, parent_bone_name, transformation, scale )
    STRUCT OWBones
        ( hierarchy, transformations,bone_scales, bone_ids, animated_bone_ids, bone_refs, nr_bones, nr_bones_rigid, nr_bones_cloth )


      
    
   
    fn ReadChunks stream totalSize=
    (
        local chunks = #()
        while (true) do
        (
            local c = OWChunk()
            
            c.Name = ReadFourCC stream
            c.Size = ReadLong stream
            c.Size2 = ReadLong stream
            c.CheckSum = ReadLong stream
            c.Offset = ftell stream

            append chunks c
            
            if (c.Size + c.Offset >= totalSize) then exit

            SkipBytes stream c.Size
            
            format "Chunk % - Size: % - Offset: % \n" c.Name c.Size c.Offset
            
        )

        return chunks
    )

    function ReadLODs file=
    (
        local stream = fOpen file "rb"
        local magic = readLong stream 
        
        if(magic != -249346705 ) then 
        (
            format "Unsupported file type!\n"
            return undefined        
        )
        
        local modl = ReadFourCC stream
        local totalSize = readLong stream #unsigned 
        local checkSum = readLong stream #unsigned
        
        local chunks = #()
        local availableLODflags = #()
        
        chunks = ReadChunks stream totalSize
        
        for chunk in chunks do
        (
            if (chunk.name == "MRNM") then
            (
                fSeek stream chunk.offset #seek_set
                
                nr_vertices = ReadLong stream
                nr_submesh_desc = ReadLong stream
                nr_materials = ReadShort stream
                nr_vertex_buffer_desc = ReadByte stream 
                nr_index_buffer_desc = ReadByte stream
                
                SkipBytes stream 100
                
                vertex_buffer_desc = (ReadLongLong stream as integer) + chunk.offset
                index_buffer_desc = (ReadLongLong stream as integer) + chunk.offset
                submesh_desc = (ReadLongLong stream as integer) + chunk.offset
                
                SkipBytes stream 8
                
                fseek stream submesh_desc #seek_set
                for i=1 to nr_submesh_desc do
                (
                    skipBytes stream 91
                    local LOD_Flag = readByte stream #unsigned
                    skipBytes stream 4
                    
                    appendIfUnique availableLODflags LOD_flag
                )
            )
        )
        fClose stream
        
        return availableLODflags
    )

    fn ReadMRNM stream chunk=
    (
        local mrnm = MRNMChunk()

        local availableLODflags = #()
        
        fSeek stream chunk.offset #seek_set
        
        /*
            read mrnm buffer
        */
        mrnm.nr_vertices = ReadLong stream
        mrnm.nr_submesh_desc = ReadLong stream
        mrnm.nr_materials = ReadShort stream
        mrnm.nr_vertex_buffer_desc = ReadByte stream 
        mrnm.nr_index_buffer_desc = ReadByte stream
        
        SkipBytes stream 100
        
        mrnm.vertex_buffer_desc = (ReadLongLong stream as integer) + chunk.offset
        mrnm.index_buffer_desc = (ReadLongLong stream as integer) + chunk.offset
        mrnm.submesh_desc = (ReadLongLong stream as integer) + chunk.offset
        
        SkipBytes stream 8
        
        /* 
            read the submesh data 
        */
        submeshes = #()
        fseek stream mrnm.submesh_desc #seek_set
        for i=1 to mrnm.nr_submesh_desc do
        (
            local sm = OWSubMesh()
                skipBytes stream 52
            sm.vertex_start  = readLong stream  #unsigned
            sm.index_start = readShort stream #unsigned
                skipBytes stream 14
            sm.index_count = readShort stream #unsigned
            sm.nr_indices_to_draw = readShort stream #unsigned
            sm.nr_vertices_to_draw = readShort stream #unsigned
            sm.offset_bone_id = readShort stream
            sm.index_buffer_used = readByte stream
                skipBytes stream 7
            sm.vertex_buffer_used = readByte stream
            sm.flags = readByte stream
            sm.mat_id = readByte stream
            sm.LOD_Flag = readByte stream #unsigned
                skipBytes stream 4
            
            
            
            appendIfUnique availableLODflags sm.LOD_flag
            
            
            append submeshes sm

        )
        
        mrnm.submeshes = submeshes
        
        /* 
            read the vertex buffer 
        */
        vertex_buffers = #()
        fseek stream mrnm.vertex_buffer_desc #seek_set
        for i=1 to mrnm.nr_vertex_buffer_desc do
        (
            local vb = OWVertexBuffer()
            vb.nr_input_elements       = readLong stream
               unk1                    = readLong stream
            vb.stream_1_block_size     = readByte stream 
            vb.stream_2_block_size     = readByte stream
            vb.nr_vertex_elements_desc = readByte stream
               unk2                    = readByte stream
            SkipBytes stream 4
            vb.vertex_elements_desc  = ( readLongLong stream #unsigned as integer ) + chunk.offset
            vb.stream_1_desc         = ( readLongLong stream #unsigned as integer ) + chunk.offset
            vb.stream_2_desc         = ( readLongLong stream #unsigned as integer ) + chunk.offset
            
            append vertex_buffers vb
        )
        mrnm.vertex_buffers = vertex_buffers
        
        /* 
            read the index buffer 
        */
        index_buffers = #()
        fseek stream mrnm.index_buffer_desc #seek_set
        for i=1 to mrnm.nr_index_buffer_desc do
        (
            local ib = OWIndexBuffer()
            ib.nr_indices  = readLong stream --> devide by 3 to get the nbr of faces
            ib.index_format = (readLong stream) --> if 0 then 2 bytes per index
            ib.offset = (readLongLong stream #unsigned as integer ) + chunk.offset
            append index_buffers ib
        )
        mrnm.index_buffers = index_buffers
        
        /*
            read vertex elements
        */
        for i=1 to mrnm.nr_vertex_buffer_desc do
        (
            fseek stream mrnm.vertex_buffers[i].vertex_elements_desc #seek_set
            mrnm.vertex_buffers[i].vertex_element_list = #()
            
            -- format "Element desc offset %\n" mrnm.vertex_buffers[i].vertex_elements_desc
            
            for j=1 to vertex_buffers[i].nr_vertex_elements_desc do
            (
                local ve = OWVertexElement()
                ve.semantic_type   = readByte stream #unsigned 
                ve.semantic_index  = readByte stream #unsigned 
                ve.data_format     = readByte stream #unsigned 
                ve.stream_number   = readByte stream #unsigned 
                ve.classification  = readShort stream #unsigned 
                ve.stride_offset   = readShort stream #unsigned 
             
                append mrnm.vertex_buffers[i].vertex_element_list ve
            )
        )
        
     
        return mrnm
    )
    fn ReadMHRP stream chunk=
    (
        fSeek stream chunk.offset #seek_set
        
        local nr_hard_points = readLong stream #unsigned

        skipBytes stream 28
        
        local hardpoints = #()
        
        for i=1 to nr_hard_points do --> 96 bytes per point
        (
            local hp = OWHardPoint()
            
            local row1 = [readfloat stream, readfloat stream, readfloat stream]
            skipBytes stream 4
            local row2 = [readfloat stream, readfloat stream, readfloat stream]
            skipBytes stream 4
            local row3 = [readfloat stream, readfloat stream, readfloat stream]
            skipBytes stream 4
            local row4 = [readfloat stream, readfloat stream, readfloat stream]
            
            hp.scale = 1 - (readfloat stream)
            
            hp.hp_name = "Attachment_" + ( ReadHex stream ) --> 4 bytes
            
            skipBytes stream 4 --> 4 bytes
            
            hp.parent_bone_name = "bone_" + ( ReadHex stream ) --> 4 bytes

            skipBytes stream 20
            
            local posRow = [row4[1] * 50, row4[2] * 50, row4[3] * 50 ]
            hp.transformation  = matrix3 row1 row2 row3 posRow

            append hardpoints hp
           

        )
        return hardpoints
    )

    fn ReadMSKL stream chunk=
    (
        --if( buildBones == false ) then return undefined
        
        local boneStruct = OWBones()
        
        fSeek stream chunk.offset #seek_set
        
        bone_hierarchy_desc             = ( readLongLong stream as integer )  + chunk.offset
        bone_matrices_desc              = ( readLongLong stream as integer )  + chunk.offset
        bone_matrices_inverted_desc     = ( readLongLong stream as integer )  + chunk.offset
        bone_matrices3x4_desc           = ( readLongLong stream as integer )  + chunk.offset
        bone_matrices3x4_inverted_desc  = ( readLongLong stream as integer )  + chunk.offset
        bone_unk_struct_desc            = ( readLongLong stream as integer )  + chunk.offset
        bone_id_desc                    = ( readLongLong stream as integer )  + chunk.offset
        bone_names_desc                 = ( readLongLong stream as integer )  + chunk.offset
        bone_unk_struct_desc2           = ( readLongLong stream as integer )  + chunk.offset
        bone_id_remapping_desc          = ( readLongLong stream as integer )  + chunk.offset
        bone_hierarchy_desc2            = ( readLongLong stream as integer )  + chunk.offset
        
        checkSum              = readLong stream #unsigned
        nr_bones              = readShort stream 
        nr_bones_rigid        = readShort stream 
        nr_bones_cloth        = readShort stream 
        nr_bones_id_remapping = readShort stream
        nr_bones_ids          = readShort stream
        nr_unk_struct         = readShort stream
        unk1                  = readShort stream
        unk2                  = readShort stream
        nr_unk_struct2        = readShort stream
        unk3                  = readShort stream
        nr_padding            = readShort stream
        
        
        boneStruct.nr_bones = nr_bones
        boneStruct.nr_bones_rigid = nr_bones_rigid
        boneStruct.nr_bones_cloth = nr_bones_cloth
        
        /* read the hierarchy */
        local hierarchy = #()
        fSeek stream bone_hierarchy_desc #seek_set
        for i=1 to nr_bones do
        (
            skipBytes stream 4
            local parentId =  ( readShort stream ) + 1 --> 0 = no parent
            append hierarchy parentId
        )
        boneStruct.hierarchy = hierarchy

        /* read the transformations */
        local transformations = #()
        local boneScales = #()
        fSeek stream bone_matrices_desc #seek_set
        
       
        for i=1 to nr_bones do
        (
            local row1 = [readfloat stream, readfloat stream, readfloat stream]
            skipBytes stream 4
            
            local row2 = [readfloat stream, readfloat stream, readfloat stream]
            skipBytes stream 4
            
            local row3 = [readfloat stream, readfloat stream, readfloat stream]
            skipBytes stream 4
            
            --local row4 = [readfloat stream, readfloat stream, readfloat stream]  * 50
            local posX = readfloat stream
            local posY = readfloat stream
            local posZ = readfloat stream
            
            local row4 = [posX, posY, posZ]  * 50
            --local row4 = [posX, posZ * -1, posY]  * 50
            scl = 1 - (readfloat stream)
            
            local transformation = matrix3 row1 row2 row3 row4

            append transformations transformation
            append boneScales scl

        )
        boneStruct.transformations = transformations
        boneStruct.bone_scales = boneScales
        

        
        /* read the bone Id's */
        local boneIds = #()
        fseek stream bone_id_desc #seek_set
        
        for i=1 to nr_bones do
        (
            local bone_id = "bone_" + ( readHex stream )
            --print bone_id
            append boneIds bone_id
        )
        boneStruct.bone_ids = boneIds
        
        /* read the list of animated bones */
        local animatedBones = #()
        fseek stream bone_id_remapping_desc #seek_set
        for i=1 to nr_bones_id_remapping do
        (
            local bone_id = (readShort stream ) +1
            
            append animatedBones bone_id --> perticular order ??
        )
        boneStruct.animated_bone_ids = animatedBones

        format "nbr animated bones :%n" nr_bones_id_remapping

        return boneStruct
        
    )

    fn ReadCloth stream chunk=
    (
        fSeek stream chunk.offset #seek_set
        
        local nr_cloth_desc = readLongLong stream as integer
        local cloth_desc = readLongLong stream as integer
        
        print nr_cloth_desc
        print cloth_desc
        
        for i=1 to nr_cloth_desc do
        (
            local unk1 = readLongLong stream as integer
            local unk2 = readLongLong stream as integer
            local unk3 = readLongLong stream as integer
            local unk4 = readLongLong stream as integer
            
            local system_map = readLongLong stream as integer
        
            local pos = ftell stream
            
            format "Unk1 offset = %\n" unk1
            format "Unk2 offset = %\n" unk2
            format "Unk3 offset = %\n" unk3
            format "Unk4 offset = %\n" unk4
            
            SkipBytes stream 32
            local clothName = ReadFixedString stream 32
            print clothName
            
            local nr_unk1 = readLong stream
            
            print nr_unk1
            
            SkipBytes stream 100
            
            
        )
        
        
        
    )
    
    fn ReadMCOL stream chunk=
    (
        
        
    )

    fn BuildMSKL bone_list=
    (
        --clearlistener()
        if( bone_list == undefined ) then return undefined
        
        bone_list.bone_refs = #()
        
        local boneLayer = CreateLayer "Bones"
        local boneClothLayer = CreateLayer "Cloth Bones"
        
        --for i=1 to bone_list.bone_ids.count do
        
        for i=1 to bone_list.nr_bones_rigid do
        (
            local b = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
            b.Name = bone_list.bone_ids[i]
            b.ShowLinks = true
            b.Width  = 0 
            b.Height = 0
            b.Length = 0
            
            boneLayer.addNode b
            
            append bone_list.bone_refs b
            
        )
        
        for i=1 to bone_list.hierarchy.count do
        (
            if( bone_list.hierarchy[i] == 0) then continue
            
            local parentBone = bone_list.bone_refs[bone_list.hierarchy[i]]
            
            if( parentBone != undefined and bone_list.bone_refs[i] != undefined ) then 
            (
                if(parentBone.name == "bone_0000" and parentBone.name != "bone_0001" and bone_list.bone_refs[i].name != "bone_0001") then 
                (
                  --  format "%\t%\n" i bone_list.bone_refs[i].name
                    
                    bone_list.bone_refs[i].ShowLinks = false
                    bone_list.bone_refs[i].Width  = 1
                    bone_list.bone_refs[i].Height = 1
                    bone_list.bone_refs[i].Length = 1
                     
                    boneClothLayer.addNode bone_list.bone_refs[i]
                )
                bone_list.bone_refs[i].parent = parentBone
            )
        )    
        
        
        
        for i=1 to bone_list.transformations.count do
        (
            
            local b = getNodeByName bone_list.bone_ids[i]
            local s =  bone_list.bone_scales[i]

            if ( b != undefined ) then 
                in coordsys parent b.transform = bone_list.transformations[i]

            --b.scale = [s,s,s]
        )
    )

    fn BuildMHRP hardpoint_list=
    (
       if( hardpoint_list == undefined) then return undefined
        
        local hplayer = CreateLayer "Hard Points"
        for hp in hardpoint_list do
        (
            local p = point transform:hp.transformation name:hp.hp_name size:7 scale:[hp.scale,hp.scale,hp.scale]
            
            p.SetSkinPose()
            
            p.wirecolor = color 224 198 87
            
            hplayer.addNode p
            
            local pbr = getnodebyname hp.parent_bone_name
            if(pbr != undefined) then p.parent = pbr
            
            
        )

    )

    function Import_Overwatch_00C file buildMesh buildHardPoints buildBones importLODs=
    (
        -- amp it up to 2GB of mem
        heapSize += 200000000 - heapSize
        
        clearlistener()
        if(file == undefined) then return undefined
        
        stream = fOpen file "rb"

        /* read header : 16 bytes */
        local magic = readLong stream 
        
        if(magic != -249346705 ) then 
        (
            format "Unsupported file type!\n"
            return undefined        
            
        )
        
        local modl = ReadFourCC stream
        local totalSize = readLong stream #unsigned /* size without header */
        local checkSum = readLong stream #unsigned
        
        /* Read the chunks to get an overview */
        local chunks = #()
        chunks = ReadChunks stream totalSize
        
        /* parse each chunk seperatly */
        local mrnm = undefined
        local mhrp = undefined
        local mskl = undefined
        
        --print chunks
        
        for chunk in chunks do
        (
            
            if (chunk.name == "mskl") then mskl = ReadMSKL stream chunk -- Skeleton
            if (chunk.name == "MHRP") then mhrp = ReadMHRP stream chunk -- Hard Points
            if (chunk.name == "MRNM") then mrnm = ReadMRNM stream chunk -- Meshes
            
            -- TODO
            if (chunk.name == "MCOL") then mrnm = ReadMCOL stream chunk -- collision mesh

            --if (chunk.name == "CLTH") then clth = ReadCloth stream chunk -- cloth data
            
            --         "CLTH" -- cloth
            --         "MDLC"
            --         "MESD" -- emitters
            --         "RGDL" -- Ragdoll
            
        )
        
        /* build the bones */
        if (buildBones) then BuildMSKL mskl 
        
        /* build hard points, do this AFTER building the bones, the hard points use them as parent objects */
        if (buildHardPoints) then BuildMHRP mhrp

        /* Read and build the actual model */
        if(buildMesh == true and (getFileNameType file != ".007" )) then
        (
            format "Nbr of Submeshes : %\n" mrnm.nr_submesh_desc
            
            for i=1 to mrnm.nr_submesh_desc do
            (
                
                local sm = mrnm.submeshes[i]
                
                local vb = mrnm.vertex_buffers[sm.vertex_buffer_used + 1]
                local ib = mrnm.index_buffers[sm.index_buffer_used + 1]

                local meshLayer = undefined
                local meshName = undefined
                
                local index_list        = #()
                local faces_list        = #()
                local textcoord_list    = #()
                
                local vertex_list       = #()
                local normal_list       = #()
                local vertex_bones      = #()
                local vertex_weights    = #()
                local nr_vertices = 0
                
                
                -- only render out the requested LOD's
                if ( (finditem importLODs sm.LOD_Flag) == 0 ) then continue
                
                --if( sm.LOD_Flag != preferredLODFlag and preferredLODFlag != 0) then continue
                
               
                meshLayer = CreateLayer ("LOD - " + sm.LOD_Flag as string)
                meshName = "LOD - " + (sm.LOD_Flag as string) +  " mesh_" + (i as string)
                
                if(sm.LOD_Flag < 0 and availableLODflags.Count > 1 ) then
                (
                        meshLayer = CreateLayer "Collision"
                        meshName = "CollisionBox_" + (i as string)
                        meshLayer.IsHidden = true
                )            
                
                Format "Reading data for % \n" meshName
                
                /* read tris */
                local offsetIndices = ib.offset + sm.index_start * 2
                fSeek stream offsetIndices #seek_set
                
                --format "Offset %\n" offsetIndices
                
                format " - reading indices %\n" sm.nr_indices_to_draw
                
                for idx=1 to sm.nr_indices_to_draw do
                    append index_list (( readShort stream #unsigned ) + 1 )
                
                --print index_list
                    
                for f=1 to index_list.count by 3 do
                (
                    local a = index_list[f]
                    local b = index_list[f+1]
                    local c = index_list[f+2]
                /* weird way of getting the nbr of vertices, but didn't find another :( */
                    if( a > nr_vertices ) then nr_vertices = a
                    if( b > nr_vertices ) then nr_vertices = b
                    if( c > nr_vertices ) then nr_vertices = c
                    append faces_list [a, b, c]
                )
                
                /* read vertices */
                for j=1 to vb.vertex_element_list.count do
                (
                    
                    local element = vb.vertex_element_list[j]
                    local offsetStream = 0
                    local streamBlock = 0
                    
                    if(element.stream_number == 0) then 
                    (
                        streamBlock = vb.stream_1_block_size
                        offsetStream = vb.stream_1_desc + sm.vertex_start * streamBlock
                        
                    )
                    if(element.stream_number == 1) then 
                    (
                        streamBlock = vb.stream_2_block_size
                        offsetStream = vb.stream_2_desc + sm.vertex_start * streamBlock
                        
                    )

                    fseek stream offsetStream #seek_set
                    
                    -- POSITION : R32G32B32_FLOAT
                    if( element.semantic_type == 0) then
                    (
                        for v=1 to nr_vertices do
                        (
                            fseek stream element.stride_offset #seek_cur

                            local x = readFloat stream * 50
                            local y = readFloat stream * 50
                            local z = readFloat stream * 50
                    
                            append vertex_list [x, y, z]
                           
                            SkipBytes stream ( streamBlock - element.stride_offset - 12 )
                        )
                       
                    )

                    -- NORMALS : R8G8B8A8_SNORM
                    if( element.semantic_type == 1) then
                    (
                        for v=1 to nr_vertices do
                        (
                            fseek stream element.stride_offset #seek_cur
                            
                            local n1 = (readByte stream #signed ) / 255.0
                            local n2 = (readByte stream #signed ) / 255.0
                            local n3 = (readByte stream #signed ) / 255.0
                            local n4 = (readByte stream #signed ) / 255.0
                            
                            append normal_list [n1, n2, n3, n4]
                        
                            SkipBytes stream ( streamBlock - element.stride_offset - 4 )
                        )
                    )
                    
                    -- COLOR
                    if( element.semantic_type == 3) then
                    (
                        for v=1 to nr_vertices do
                        (
--                             fseek stream element.stride_offset #seek_cur
--                            
--                         
--                             SkipBytes stream ( streamBlock - element.stride_offset - 4 )
                        )
                    )
                    
                      -- TANGENTS: not supported
                    if( element.semantic_type == 3) then
                    (
                    )
                    
                    -- BONE_INDICES : R8G8B8A8_UINT
                    if( element.semantic_type == 4) then
                    (
                        for v=1 to nr_vertices do
                        (
                            fseek stream element.stride_offset #seek_cur
                            
                            local i1 = (readByte stream #unsigned) + 1 + sm.offset_bone_id
                            local i2 = (readByte stream #unsigned) + 1 + sm.offset_bone_id
                            local i3 = (readByte stream #unsigned) + 1 + sm.offset_bone_id
                            local i4 = (readByte stream #unsigned) + 1 + sm.offset_bone_id
                            
                            append vertex_bones [i1, i2, i3, i4]
                            
                            SkipBytes stream ( streamBlock - element.stride_offset - 4 )
                        )
                    )
                    
                    -- BONE_WEIGHTS : R8G8B8A8_UNORM
                    if( element.semantic_type == 5) then
                    (
                        for v=1 to nr_vertices do
                        (
                            fseek stream element.stride_offset #seek_cur
                            
                            local f1 = (readByte stream #unsigned ) / 255.0
                            local f2 = (readByte stream #unsigned ) / 255.0
                            local f3 = (readByte stream #unsigned ) / 255.0
                            local f4 = (readByte stream #unsigned ) / 255.0
                        
                            append vertex_weights [f1, f2, f3, f4]
                            
                            SkipBytes stream ( streamBlock - element.stride_offset - 4 )
                        )
                    )
                    
                    -- TEXCOORD : R16G16_FLOAT
                    if( element.semantic_type == 9) then
                    (
                        local textcoord = #()
                        for v=1 to nr_vertices do
                        (
                            fseek stream element.stride_offset #seek_cur
                        
                            local u = ReadHalfFloat stream
                            local v = ReadHalfFloat stream
                            
                            append textcoord [u,1-v,0]
                        
                            SkipBytes stream ( streamBlock - element.stride_offset - 4 )
                        )
                        append textcoord_list textcoord
                    )
                    
                   
                )

                /* fix weights and bone indices for max */
                if( vertex_weights.count > 0 ) then 
                (
                    
                    local new_vertex_weights = #()
                    local new_vertex_bones = #()
                    
                    for v=1 to nr_vertices do
                    (
                        local ws = #()
                        local bs = #()
                        
                        
                        local vWeights = vertex_weights[v]
                        local vBones = vertex_bones[v]

                       
                        if (vWeights[1] > 0 ) then 
                        (
                            append ws vWeights[1]
                            append bs vBones[1]
                        )
                        if (vWeights[2] > 0 ) then
                        (
                            append ws vWeights[2]
                            append bs vBones[2]
                        )
                        if (vWeights[3] > 0 ) then 
                        (
                            append ws vWeights[3]
                            append bs vBones[3]
                        )
                        if (vWeights[4] > 0 ) then 
                        (
                            append ws vWeights[4]
                            append bs vBones[4]
                        )

                        append new_vertex_weights ws
                        append new_vertex_bones bs

                    )
                    
                    vertex_weights = new_vertex_weights
                    vertex_bones = new_vertex_bones
                )
                
                format "Building Mesh '%'\n" meshName

                if( buildMesh == true ) then
                (
                                        
                    local theMesh = mesh vertices:vertex_list name:meshName faces:faces_list vnorms:normal_list -- tverts:textcoord_list[1] 
                    theMesh.WireColor = Color (random 0 250) (random 0 255) (random 0 250)

                    
                    local numUVMaps = textcoord_list.count + 1
                    meshop.setNumMaps theMesh numUVMaps
                    
                    Format "Number of uv texture coordinates mappings: %\n" textcoord_list.count
                    for t=1 to textcoord_list.count do
                    (
                        Format "Applying uv texture coordinates mapping %\n" t
                        local uvMap = t
                        
                        meshop.setMapSupport theMesh uvMap true 
                        for x=1 to textcoord_list[uvMap].count do
                            meshop.setMapVert theMesh uvMap x textcoord_list[uvMap][x]

                        meshop.buildMapFaces theMesh uvMap
                        update theMesh
                    )
                    
                    meshLayer.AddNode theMesh
                    
                    if( vertex_weights.count > 0 ) then
                    (
                        format " - Applying bones and weights to the vertices\n"
                        try
                        (
                            if(mskl.animated_bone_ids.count > 0) then
                            (
                                with redraw off
                                (
                                    local skinMod = skin()
                                    max modify mode --> DO NOT FORGET THIS, it requires the tab to be selected
                                    addmodifier theMesh skinMod
                                    modPanel.setCurrentObject skinMod

                                    local nr_anim_bones = mskl.animated_bone_ids.count
                                    
                                    
                                    for b = 1 to nr_anim_bones do
                                    (
                                        local boneRef = mskl.bone_refs[mskl.animated_bone_ids[b]]
                                    
                                        if(boneRef != undefined) then 
                                            skinops.addbone skinMod boneRef 1 
                                    )

                                    modPanel.setCurrentObject skinMod
                                    
                                    for v = 1 to nr_vertices do
                                    (
                                        try(
                                            skinOps.ReplaceVertexWeights skinMod v vertex_bones[v] vertex_weights[v]
                                        )
                                        catch()
                                    )
                                    
                                    update theMesh
                                )
                            )
                            
                        ) catch( format "\n[Error]\n%\n\n" (getCurrentException()) )
                    )
                    
                    meshop.deleteIsoVerts theMesh
                    
                )
                format "\n"
            )
        )
        fClose stream 
        try (FixYup()) catch ()
    )

f = @"F:\Blizzard\Overwatch\Extracted\Heroes\Zenyatta\Ascendant\000000000ACE.00C"

-- Import_Overwatch_00C file buildMesh buildHardPoints buildBones importLODs
    Import_Overwatch_00C f true true true #(8)
