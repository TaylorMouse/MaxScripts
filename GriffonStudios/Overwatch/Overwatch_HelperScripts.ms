/* 
    HELPER CLASSES 
    Author:     Taylor Mouse
    Date:       ©2016 - 2022
    Version:    0.5
    
    0.5 : revisit
    0.4 : Added SetAnimationNoteTrack
    0.3 : added ClearAllAnimationKeysForAllBones
    0.2 : added FreeUpMemory
    
    
*/

struct Overwatch_Helpers
(
    function FreeUpMemory=
    (
        GC()
        FreeSceneBitmaps()
        ClearUndoBuffer()
    ),
    function FixYup=
    (
        local rootbone = getnodebyname "bone_0001"
        local bone0000 = getnodebyname "bone_0000"
        
        if ( bone0000 != undefined ) then rootbone = bone0000
        
        if( rootbone == undefined) then return undefined
        
        if (rootbone.rotation == (quat 0 0 0 1) ) then
            rotate rootbone (eulerangles 90 0 0 )
        else
            rotate rootbone (eulerangles -90 0 0 )
    ),
    function ClearAllAnimationKeysForAllBones=
    (
        animationrange = interval 0 100 
        slidertime = 0f

        for o in objects do
        (
            if( classof o == BoneGeometry )  then 
            (
                if( o.position.controller != undefined ) then
                (
                    deleteKeys o.position.controller #allKeys
                    deleteKeys o.rotation.controller #allKeys
                    deleteKeys o.scale.controller #allKeys
                    
                )
            )
        )


    ),
    function GetLastAnimationFrame=
    (
        /* Return the last found animation time on the timeslider */
        local lastFrame = 0
        for obj in objects do
        (
            local keys = obj.position.controller.keys

            
            
            if(keys.count != undefined and keys.count > 0 ) then
            (
                local lastTime = keys[ keys.count].time
                if(lastTime > lastFrame ) then lastFrame = lastTime
            )
        )    
        return lastFrame
    ),
    function ReplaceAll str findStr replaceStr =
    (
        /* Replace every string by another string */
        local parts = filterString str findStr

        local newStr = ""
        for i=1 to parts.count-1 do
            newStr = newStr + parts[i] + replaceStr

        newStr = newStr + parts[parts.count]

        return newStr
    ),
    function SkipBytes stream nBytesToSkip=
    (
        /* Pass in a filestream and skips the number of bytes without reading them to memory */
        fseek stream nBytesToSkip #seek_cur
    ),
    function ReadHalfFloat stream = 
    (
        /* Takes in a filestream and reads out a float, moves the stream pointer 2 bytes */

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
        /* Create layer in MAX, if it exists, just return a reference to that layer */
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),
    function ReadHexLength stream len=
    (
        /* reads hexadecimal values as a string, used for Overwatch */
        local result = ""
        for i=1 to len do
        (
            local val = readByte stream #unsigned
            local str = toUpper ( ( bit.IntAsHex val ) as string )
            
            if( str.count != 2) then
            (
                str = substring ( "00" + str ) 2 2
            )
            
            
            result = str + result
        )
        
        
        return result
    ),
    function ReadHex stream =
    (
        /* read the hex string from a stream and move the pointer 4 bytes */
        local result = ""
        for i=1 to 4 do
        (
            local val = readByte stream #unsigned
            local str = toUpper ( ( bit.IntAsHex val ) as string )
            
            result = str + result
        )
        return result
    ),
    function CreateBone boneName transformation scaling boneLayer=
    (
        local l = CreateLayer boneLayer
        local b = BoneSys.CreateBone [0,0,0] [0,0,0] [0,0,1]
        l.AddNode b
        
        b.Name = boneName
        b.ShowLinks = true
        b.Width  = 0 --> if sized, it becomes ugly
        b.Height = 0
        b.Length = 0
        if( transformation != undefined) then 
            b.transform = transformation
        b.scale = [1,1,1] * scaling
        
        return b
    ),
    function ReadFixedString stream val =
    (
        /* pass in nbr of characters that need to be read and returns a string */
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    ),
    function ReadFourCC stream =
    (
        /* pass in nbr of characters that need to be read and returns a string */
        local str = ""
        for i=1 to 4 do
        (
            local s = bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then 
                str = s + str
        )
        return str
    ),
    function ReadString2 stream =
    (
        /* first byte holds the length of the string to be read */
        len = ( readByte stream as integer )
        
        str = ReadFixedString stream len
        
        return str
    ),
    function ReadString3 stream =
    (
        /* first short (uint16) holds the length of the string to be read */
        len = ( ReadShort stream as integer )
        
        str = ReadFixedString stream len
        
        return str
    ),
    function ReadString4 stream =
    (
        /* first short (uint16) holds the length of the string to be read */
        len = ( ReadLong stream as integer )
        
        str = ReadFixedString stream len
        
        return str
    ),
    function CleanUpMaterialLibrary=
    (
        for m=1 to 24 do 
        (
            local mat = Standardmaterial()
            mat.name = "Standard - " + m as string
            meditMaterials[m] = mat
        )
    ),
    function SetAnimationNoteTrack list_animations=
    (
        
        /* clear existing notes */
        local starAnimTrack = undefined
            
        if( (hasNoteTracks rootNode) == true ) then
        (
            starAnimTrack = getNoteTrack rootNode 1
        )
        else
        (
            starAnimTrack = notetrack "starAnimTrack"
            addNoteTrack rootNode starAnimTrack
        )
        
        /* apply new notes */
        for anim in list_animations do
        (
            local noteExists = getNoteKeyIndex starAnimTrack  anim.start_frame
            if( noteExists == undefined) then
            (
                local startNote = AddNewNoteKey starAnimTrack anim.start_frame
                local endNote = AddNewNoteKey starAnimTrack anim.end_frame
                
                /* this is based on StarCraft 2 animation note track */
                local val = anim.name + "\r\n"
                      val += "rarity = 100\r\n"
                      val += "moveSpeed = 0\r\n"
                      val += "nonLoop = 0\r\n"
                      val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = 0"

                startNote.Value = val
                endNote.Value = val
                
            )
            
        )
        
    )
)