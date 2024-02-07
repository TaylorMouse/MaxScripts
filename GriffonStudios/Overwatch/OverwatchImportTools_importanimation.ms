/*
    Blizzard Overwatch Animation Importer (.006)
    
    (c) 2017~2018 Script by Taylor Mouse
    
    Special thanks to id-daemon for reviewing and correcting the animation
    Special thanks to dynaomi for the awesome overtool.exe
    
    Releas Notes:
    - v1.7 : corrections on importing animation names and bones
    - v1.0 : release
    - v0.9 : implemented a dummy rotation controller to support correct animation as suggested by id-daemon
    - v0.8 : Revert all changes to the bone implementation (original setup changed in the model import )
    - v0.7 : changed nr_bones from long to short
    - v0.6 : Testing on different animations
    - v0.5 : Correct implementation of the bone rotation
    - v0.4 : Comparing bone rotation to other existing scripts
    - v0.3 : Brain breaker on bone rotation
    - v0.2 : Added unpack rotation algorithm
    - v0.1 : Initial version
*/

    fileIn "Overwatch_HelperScripts.ms"

    struct OverwatchAxisList ( axis, rotation )

    function ReadFrames stream nr_frames=
    (
        local list = #()
        for i=1 to nr_frames do
        (
            local frame = undefined
            if (nr_frames < 255) then
                frame = readByte stream #unsigned
            else
                frame = readShort stream #unsigned
            
            append list frame
        )
        return list
        
    )
    function ReadScaleData stream nr=
    (
        local list = #()
        for i=1 to nr do
        (
            local scale_x = ( readShort stream #unsigned ) / 1024.0
            local scale_y = ( readShort stream #unsigned ) / 1024.0
            local scale_z = ( readShort stream #unsigned ) / 1024.0
                
            append list [scale_x, scale_y, scale_z ]
        )
        return list
    )
    function ReadPositionData stream nr=
    (
        local list = #()
        for i=1 to nr do
        (
            local x = readFloat stream * 50
            local y = readFloat stream * 50
            local z = readFloat stream * 50 
            
            --append list [x, -z, y]
            append list [x, y, z]
            
        )
        return list
    )
	
    function ReadRotationData stream nr=
    (
        local list=#()
        
        for i=1 to nr do
        (
            local a = readShort stream #unsigned
            local b = readShort stream #unsigned
            local c = readShort stream #unsigned
            
            local q = quat 0 0 0 0
            
            axis1 = bit.shift a -15
            axis2 = bit.shift b -15
            axis  = bit.or (bit.shift axis2 1) axis1
           
           -- format "Axis value: %\n" axis
            
            a = bit.and a 0x7FFF
            b = bit.and b 0x7FFF

            x = 1.41421 * (a - 0x4000) / 0x8000
            y = 1.41421 * (b - 0x4000) / 0x8000
            z = 1.41421 * (c - 0x8000) / 0x10000
            w = pow (1.0 - x * x - y * y - z * z) 0.5

            if(axis == 3) then q = quat x y z w
            if(axis == 2) then q = quat x y w z
            if(axis == 1) then q = quat x w y z
            if(axis == 0) then q = quat w x y z


            local al = OverwatchAxisList()
            al.axis = axis
            al.rotation = q
            
            append list al
        )
        
        return list
    )
	
    function ImportOverwatchAnimation_v18 file starting_frame anim_id=undefined =
    (
        -- if the user rotated the model, fix it back
        FixYup()
        
        
        local stream = fOpen file "rb"

        /**************************************************************************************************************/
        STRUCT AnimationInfo
            ( nr_scales, nr_positions, nr_rotations, flags, offset_scale_indices, offset_position_indices, offset_rotation_indices, offset_scale_data, offset_position_data, offset_rotation_data )

        STRUCT AnimationData
            ( scale_data, position_data, rotation_data )

        STRUCT AnimationFrames --> frames
            ( scale_frames, position_frames, rotation_frames )

        STRUCT animation_item 
            ( name, start_frame, end_frame)
        
        /**************************************************************************************************************/
        bone_list               = #()
        animation_info_list     = #()
        animation_data_list     = #()
        animation_frames_list   = #()

        /**************************************************************************************************************/
        local animType    = readShort stream #unsigned -- usually 160
		local nr_bones    = readShort stream #unsigned
		
		SkipBytes stream 4
        local duration    = readFloat stream -- nbr seconds
		local fps         = readFloat stream -- usually 30.0
        
		SkipBytes stream 16
		
        --local flag        = readShort stream #unsigned

        format "Reading animation %\n" (getfilenamefile file)
        format "- Animation Type: %\n" animType
        format "- Animation duration: %s\n" duration
        format "- Frames per second : %\n" fps
        format "- Number of frames  : %\n" ( fps * duration )

        local anim = animation_item()
        local animation_list = #()
        
        if (anim_id == undefined) then anim_id = 0
        if (starting_frame == undefined) then starting_frame = 10
		
        anim.name = "Anim " + (anim_id as string) + " - (" + (getfilenamefile file) + ")"
        anim.start_frame = starting_frame
        anim.end_frame = (starting_frame + ( duration * fps ))

        --SkipBytes stream 24

        offset_bone_names = (readLongLong stream #unsigned) as integer
		SkipBytes stream 16
        offset_anim_info  = (readLongLong stream #unsigned) as integer

        --format "Bone names start at %\n" offset_bone_names
        --format "Nbr of bones %\n" nr_bones
            
        append animation_list anim
            
        SkipBytes stream 24

        format "- Reading bones\n"
        fSeek stream offset_bone_names #seek_set
        for i=1 to nr_bones do
        (
            local nm = "Bone_" + (ReadHex stream)
            append bone_list nm
        )

        format "- Reading bone animation info\n"
        fSeek stream offset_anim_info #seek_set
        for i=1 to nr_bones do
        (
            local currentStreamPosition = ftell stream
            local info = AnimationInfo()
            info.nr_scales    = readShort stream #unsigned
            info.nr_positions = readShort stream #unsigned
            info.nr_rotations = readShort stream #unsigned
            info.flags        = readShort stream #unsigned
            
            info.offset_scale_indices    = (readLong stream #unsigned) * 4 + currentStreamPosition
            info.offset_position_indices = (readLong stream #unsigned) * 4 + currentStreamPosition
            info.offset_rotation_indices = (readLong stream #unsigned) * 4 + currentStreamPosition
            
            info.offset_scale_data    = (readLong stream #unsigned) * 4 + currentStreamPosition
            info.offset_position_data = (readLong stream #unsigned) * 4 + currentStreamPosition
            info.offset_rotation_data = (readLong stream #unsigned) * 4 + currentStreamPosition
            
            append animation_info_list info
            
        )

        format "- Reading animation info\n"
        for info in animation_info_list do
        (
            local data = AnimationData()
            local frames = AnimationFrames()
            
            -- Reading frames for scaling
            fseek stream info.offset_scale_indices #seek_set
            frames.scale_frames = ReadFrames stream info.nr_scales
            
            -- Reading frames for positions
            fseek stream info.offset_position_indices #seek_set
            frames.position_frames = ReadFrames stream info.nr_positions
            
            -- Reading frames for rotations
            fseek stream info.offset_rotation_indices #seek_set
            frames.rotation_frames = ReadFrames stream info.nr_rotations
            
            -- add the frames to the list
            append animation_frames_list frames
            
            -- Reading data for scaling
            fseek stream info.offset_scale_data #seek_set
            data.scale_data = ReadScaleData stream info.nr_scales
            
            -- Reading data for positions
            fseek stream info.offset_position_data #seek_set
            data.position_data = ReadPositionData stream info.nr_positions
            
            -- Reading data for rotations
            fseek stream info.offset_rotation_data #seek_set
            data.rotation_data = ReadRotationData stream info.nr_rotations
            
            append animation_data_list data
            
            
        )

        fClose stream

        format "- Apply animation info\n"
        
        SetAnimationNoteTrack animation_list
        
        for i=1 to  bone_list.Count do
        (
            -- get a reference to the bone
            local b = getNodeByName bone_list[i]
            if (b == undefined) then 
            (
                --format "Bone not found! (%)\n" bone_list[i]
                continue
            )
            
            b.assumeSkinPose()
          
            
            
            if ( b.name == "bone_0001") then 
             ( 
                 format "Bone % skipped\n" b.name
                 continue
             )
            
            local axis = animation_data_list[i].rotation_data[1].axis

            -- apply rotation       
            local dr = dummy name:"RotationController" --> use this dummy as a animation controller

            dr.rotation.controller = b.rotation.controller

            for j=1 to animation_info_list[i].nr_rotations do
            (
                local t = animation_frames_list[i].rotation_frames[j] + starting_frame
                local q = animation_data_list[i].rotation_data[j].rotation
                
                local q0 = dr.transform
                
                --with animate on at time (t-1) q0 = dr.rotation 
                
                with animate on
                    at time t
                    (
                        if ( animType == 160 or
                             animType == 288 or 
                             animType == 168 
                            ) then in coordsys parent dr.rotation = q

                        if ( animType == 164 or 
                            animType == 166 
                            ) then  in coordsys q0 dr.rotation = q

 
                            
                            
                    )

            )
            with animate on b.rotation.controller = copy dr.rotation.controller
                
            -- apply position
            for j=1 to animation_info_list[i].nr_positions do 
            (
                local t = animation_frames_list[i].position_frames[j] + starting_frame
                local p = animation_data_list[i].position_data[j]
                local p0 = [0,0,0]
                with animate on at time 0 p0 = b.position 
                
                
                with animate on
                    at time t
                    (
                        if ( animType == 160 or
                             animType == 288 or
                             animType == 168
                            ) then in coordsys parent b.position = p

                        if ( animType == 164 or
                            animType == 166 
                            ) then b.position = p + p0



                            
                    )
            )

                
            -- apply scale
            for j=1 to animation_info_list[i].nr_scales do 
            (
                local t = animation_frames_list[i].scale_frames[j] + starting_frame
                local s = animation_data_list[i].scale_data[j]
                with animate on
                    at time t
                        in coordsys parent b.scale = s
            )

            delete dr

        )
        
        
        FixYup()
    )

--file = @"E:\Blizzard\Overwatch\Extracted\Extracted 00C\Heroes\Tracer\HighlightIntro\Serious Business\Animations\160\000000002410.006"

--   
 -- ImportOverwatchAnimation_v18 file 700 undefined