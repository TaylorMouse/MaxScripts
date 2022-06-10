/*
	Import Diablo III Animation
	Written by Taylor Mouse (c) 08.2014
	Added config possibilities
	Added Reaper Of Souls Animations
*/

    
    /************************************************************************************************
     STRUCTS
    ************************************************************************************************/
    struct D3Bone ( ID, Name, TheBone )
    struct TranslationAnimation ( BoneId, KeyFrame, Position )
    struct RotationAnimation (BoneId, KeyFrame, Quaternion  )
    struct ScaleAnimation (BoneId, KeyFrame, Scaling )

    /************************************************************************************************
      HELPER FUNCTIONS
    ************************************************************************************************/

    fn ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if(s!="\0") then str+=s
        )
        return str
    )

    fn SetWorldRotation theNode theRot =
    (
        local matrix = transmatrix theNode.transform.pos
        in coordsys matrix (theNode.rotation = theRot)
    )



    fn GetAnimationTrack =
    (
        local animationTrack = undefined

        local noteTracks = numNoteTracks rootNode
        
        if( noteTracks > 0 ) then
        (
            for n=1 to noteTracks do
            (
                track = getNoteTrack rootNode 1
                track.name = "StarAnimTrack"
                animationTrack = track
            )
        )
        if ( animationTrack == undefined ) then
        (        
            animationTrack = noteTrack "StarAnimTrack"
            animationTrack.name = "StarAnimTrack"
            addNoteTrack rootNode animationTrack
            
        )
        
        --format "Notetrack: %s\n" track.name
        
        return animationTrack

    )

    fn AnimationExists animName =
    (
        track = GetAnimationTrack()
        if( track.keys.count == 0 ) then return false

        for i=1 to track.keys.count do
        (
            values = filterString track.keys[i].Value "\r\n"
            if(values[1] == animName) then return true
        )

        return false
    )


    fn ParseAnimationName animname =
    (
    --animName = "OmniNPC_Male_HTH_town_idle_02"
        animNameSplit = filterString animName "_"

        numSplit = animNameSplit.count

        finalAnimName = ""

        if(animNameSplit[numSplit] == undefined ) then
            finalAnimName =  animNameSplit[numSplit]
        if(animNameSplit[numSplit] != undefined ) then
            finalAnimName =  ( animNameSplit[numSplit-1] + " " + animNameSplit[numSplit] )

        finalAnimName = ( toUpper finalAnimName[1] ) + substring finalAnimName 2 -1

        doesitexist = AnimationExists finalAnimName

        if (doesitexist) then
        (
            finalAnimName = ( toUpper animNameSplit[numSplit-2][1] ) + (substring animNameSplit[numSplit-2] 2 -1) + ( toUpper finalAnimName[1] ) + substring finalAnimName 2 -1
        )
    
        return finalAnimName
    )

    fn SetNote animNote animName =
    (

        local txt = animName + "\r\n" + "rarity = 100" + "\r\n" + "moveSpeed = 0.0" + "\r\n" + "nonLoop = false" + "\r\n" + "default_Anim = false" + "\r\n" + "sub_anim = false" + "\r\n" + "defaultPriority = 0"
        animNote.Value = txt

    )
    function GetLastAnimFrame=
    (
        local lastTimeFrame = 0

        for obj in objects do
        (
            local ctrl = obj.pos.controller
            --getKey
            
            if(ctrl != undefined ) then 
            (
                if(ctrl.keys.count > 0 ) then 
                (
                    local maxTimeFrame = ctrl.keys[ctrl.keys.count].time
            
                    if (lastTimeFrame < maxTimeFrame) then lastTimeFrame = maxTimeFrame
                )
            )
        )
        return lastTimeFrame
    )
    function GetNextStartFrame=
    (
         local lf = (GetLastAnimFrame() as string ) 
        local len = lf.count
        len = len - 1
        nbr = (  substring lf 1 len ) as  integer
        local lfi = ( nbr  / 10) * 10 + 20
        
        return lfi
    )    
    /************************************************************************************************
        MAIN METHOD
    ************************************************************************************************/
    function GriffonStudios_DiabloIII_ImportAnimation file startFrame animName=
    (
        local  animationNotes = GetAnimationTrack()

--         d = GetNodeByName "Animations"
--         if(d==undefined) then d = dummy pos:[0,0,0] Scale:[0.5,0.5,0.5] name:"Animations"

--         hide d

        startingFrame = 0
        startingFrame = startFrame

        animStartNote = AddNewNoteKey animationNotes startFrame


        --SetUserProp d ((GetFileNameFile file) + " START") (startingFrame as string)

        Format "	START READING ANIMATION FILE"

        stream = fOpen file "rb"	-- Open the file for reading

        SkipBytes stream 76 		-- Skip 76 bytes

        animationName = ReadFixedString stream 64	-- Animation name
        parsedAnimName = ParseAnimationName animationName
        if (parsedAnimName.count == 0) then 
        (
            parsedAnimName = "Unkown"
        )
        if( animName != "" ) then 
            animationName = animName
        print animationName
        
        SetNote animStartNote parsedAnimName

        SkipBytes stream 52 		-- Skip 52 bytes

        nBones = ReadLong stream	-- number of bones
        offBones = ReadLong stream	-- data for the bones
        sizeBones = ReadLong stream -- size in bytes of the bones

        SkipBytes stream 12 		-- Skip 12 bytes

        totalFrames = ReadLong stream	-- total frames  in this animation

        animEndNote = AddNewNoteKey animationNotes ( startFrame + totalFrames - 1 )
        SetNote animEndNote parsedAnimName

        --SetUserProp d ((GetFileNameFile file) + " END") ((startingFrame + totalFrames) as string)

        offTranslation = ReadLong stream 	-- data for translation animation
        sizeTranslation = ReadLong stream	-- size of the translation animation data

        SkipBytes stream 12 		-- Skip 12 bytes

        offRotation = ReadLong stream 		-- data for the rotations
        sizeRotation = ReadLong stream 		-- size of the rotation data

        SkipBytes stream 8 			-- Skip 8 bytes

        offScale = ReadLong stream 		-- data for the scaling
        sizeScale = ReadLong stream 	-- size for the scaling data

        SkipBytes stream 208 			-- Skip 208 bytes

        xan = ReadFixedString stream 256	-- always 0000.xan
        source = ReadFixedString stream 256	-- initial location of this file

        /* BONES */
        fSeek stream ( offBones + 16 ) #seek_set -- jump to the bone data position
        allBones = #()
        for i=1 to nBones do
        (
            b = D3Bone()
            b.ID = i	--> for reference only
            b.Name = ReadFixedString stream 64	-- name of the bone
            b.TheBone = GetNodeByName b.Name	-- find the bone in the scene
            append allBones b
        )
        --print allBones

        /* Frame data*/
        nFrameData = #()
        offFrameData = #()
        sizeFrameData = #()

        /* TRANSLATION */
        fSeek stream ( offTranslation + 16 ) #seek_set
        for i=1 to nBones do -- get the offset of where the translation data is stored
        (
            append nFrameData (ReadLong stream)
            append offFrameData (ReadLong stream)
            append sizeFrameData (ReadLong stream)
            SkipBytes stream 12	-- always 00 00 00 00 - 00 00 00 00 - 00 00 00 00 ?
        )

        allTranslations = #()
        for i=1 to nBones do -- Read the translation data structure
        (
            fSeek stream ( offFrameData[i] + 16 ) #seek_set

            for fd=1 to nFrameData[i] do
            (
                tran = TranslationAnimation()
                tran.BoneId = i
                tran.KeyFrame = ReadLong stream

                boneY = ReadFloat stream * -17
                boneX = ReadFloat stream * 17
                boneZ = ReadFloat stream * 17

                tran.Position = [boneX,boneY,boneZ]

                --tran.Position = [ReadFloat stream, ReadFloat stream, ReadFloat stream]

                append allTranslations tran
            )
        )
        --print allTranslations

        /* Reset Frame data*/
        nFrameData = #()
        offFrameData = #()
        sizeFrameData = #()

        /* ROTATION */
        fSeek stream ( offRotation + 16 ) #seek_set
        for i=1 to nBones do -- get the offset of where the translation data is stored
        (
            append nFrameData (ReadLong stream)
            append offFrameData (ReadLong stream)
            append sizeFrameData (ReadLong stream)
            SkipBytes stream 12	-- always 00 00 00 00 - 00 00 00 00 - 00 00 00 00 ?
        )

        allRotations = #()
        for i=1 to nBones do -- Read the rotation data structure
        (
            fSeek stream ( offFrameData[i] + 16 ) #seek_set

            for fd=1 to nFrameData[i] do
            (
                rot = RotationAnimation()
                rot.BoneId = i
                rot.KeyFrame = ReadLong stream
                y = (ReadShort stream #signed) / -32767.0
                x = (ReadShort stream #signed) / 32767.0
                z = (ReadShort stream #signed) / 32767.0
                w = (ReadShort stream #signed) / 32767.0

                rot.Quaternion = quat x y z w

                append allRotations rot
            )
        )
        --print allRotations

        /* Reset Frame data*/
        nFrameData = #()
        offFrameData = #()
        sizeFrameData = #()

        /* SCALE */
        fSeek stream ( offScale + 16 ) #seek_set
        for i=1 to nBones do -- get the offset of where the scaling data is stored
        (
            append nFrameData (ReadLong stream)
            append offFrameData (ReadLong stream)
            append sizeFrameData (ReadLong stream)
            SkipBytes stream 12
        )

        allScaling = #()
        for i=1 to nBones do -- Read the scale data structure
        (
            fSeek stream ( offFrameData[i] + 16 ) #seek_set

            for fd=1 to nFrameData[i] do
            (
                s = ScaleAnimation()
                s.BoneId = i
                s.KeyFrame = ReadLong stream
                s.Scaling = ReadFloat stream

                append allScaling s
            )
        )
        --print allScaling

        -- TODO:  get the last used animation key, so we can add multiple animations to the scene


        --Apply the Rotation
        prevQ = quat 1 -- set a starting rotation
        prevB = 1
        for i=1 to allRotations.count do
        (
            b = allBones[allRotations[i].BoneId].TheBone
            if(b == undefined) then continue

            t = allRotations[i].KeyFrame + startingFrame
            q = allRotations[i].Quaternion

            with animate on
            (
                at time t (
                    b.assumeskinpose()
                    local mtrx = matrix3 1
                    rotate mtrx (inverse q)
                    mtrx.row4 = b.pos
                    if b.parent != undefined then(
                        mtrx = mtrx * b.parent.transform
                    )
                    b.transform = mtrx
                    deleteKey b.position.controller (numKeys b.position.controller)
                    deleteKey b.scale.controller (numKeys b.scale.controller)
                )
            )

        )

        -- Apply the Translation
        for i=1 to allTranslations.count do
        (
            b = allBones[allTranslations[i].BoneId].TheBone
            t = allTranslations[i].KeyFrame + startingFrame
            pos = allTranslations[i].Position

            if(b!=undefined) then
            (
            with animate on
                at time t
                    in coordsys parent b.position = pos
            )
        )

        -- Apply the Scaling
        for i=1 to allScaling.count do
        (
            b = allBones[allScaling[i].BoneId].TheBone
            scaling = point3 allScaling[i].Scaling allScaling[i].Scaling allScaling[i].Scaling
            t = allScaling[i].KeyFrame + startingFrame

            if( b!=undefined) then (
            with animate on
                at time t
                    in coordsys parent b.Scale = scaling
            )
        )

        fClose stream

        print "DONE"
    )

