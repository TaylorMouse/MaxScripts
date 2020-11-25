/*
    (c) 2018 Griffon Studios
    Author: Taylor Mouse

    Helper functions
    
*/

function FindLastKeyFrameByObject obj last_frame = 
(
    for i=1 to obj.numSubs do -- number of possible animation controllers
    (
        local keys = obj[i].keys
        if( keys != undefined ) then
        (
            if( keys.count > 0 ) then
            (
                local timeFrame = keys[keys.count].time
                if( timeFrame > last_frame ) then
                    last_frame = timeFrame
            )
            if (obj[i].numSubs > 0 ) then
            (
                for j=1 to obj[i].numSubs do
                (
                    last_frame = FindLastKeyFrameByObject obj[i] last_frame
                )
                
            )
        )
    )
    return last_frame
    
)

/* 
    get the last frame on the time line 

    note: function retursn type Time

*/
function FindLastKeyFrame =
(
    local last_frame = 0
    for obj in objects do
    (
        last_frame = FindLastKeyFrameByObject obj last_frame
    )
    return last_frame
)


/*
    Remove the menu from the main Max Menu interface
*/
function GriffonStudios_RemoveMenu menuName=
(
	for i = 1 to menuman.numMenus() do
    (
        local mnu = menuman.FindMenu menuName
        if( mnu == undefined ) then
            exit
        else
            menuMan.unRegisterMenu mnu
    )

)


/*
    add a custom menu in front of the Max Help Menu by positioning it at the same position as the original Help menu itme
    returns the current position of the Help meny
*/
function GriffonStudios_GetHelpMenuPosition =
(
    local mainMenu = menuMan.getMainMenuBar() 
    for i=1 to mainMenu.numItems() do
    (
        local title = ((mainMenu.getItem(i)).getTitle())
        if(title == "&Help" ) then return i
    )
    
    return undefined
)


/* Free up max memory */
function FreeUpMemory=
(
    GC()
    FreeSceneBitmaps()
    ClearUndoBuffer()
    
)


/* Pass in a filestream and skips the number of bytes without reading them to memory */
function SkipBytes stream nBytesToSkip=
(
	fseek stream nBytesToSkip #seek_cur
)

/* Takes in a filestream and reads out a float, moves the stream pointer 2 bytes */
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
)

/* Create layer in MAX, if it exists, just return a reference to that layer */
function CreateLayer layerName =
(

	layer = LayerManager.GetLayerFromName layerName
	if(layer == undefined) then
	(
		layer = LayerManager.NewLayerFromName layerName
	)
	return layer
)


function ReadHexLength stream len=
(
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
)


/* read the hex string from a stream and move the pointer 4 bytes */
function ReadHex stream =
(
    local result = ""
    for i=1 to 4 do
    (
        local val = readByte stream #unsigned
        local str = toUpper ( ( bit.IntAsHex val ) as string )
        
        result = str + result
    )
    
    return result
)


/* quick create on bones in max */
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
    b.transform = transformation
    b.scale = [1,1,1] * scaling
    
    return b
)
/* pass in nbr of characters that need to be read and returns a string */
fn ReadFixedString stream val =
(
	local str = ""
	for i=1 to val do
	(
		s= bit.IntAsChar(ReadByte stream)
		if ( s !="\0") then str+=s
	)
	return str
)

/* pass in nbr of characters that need to be read and returns a string */
fn ReadFourCC stream =
(
	local str = ""
	for i=1 to 4 do
	(
		local s = bit.IntAsChar(ReadByte stream)
		if ( s !="\0") then 
            str = s + str
	)
	return str
)

/* first byte holds the length of the string to be read */
fn ReadString2 stream =
(
    len = ( readByte stream as integer )
    
    str = ReadFixedString stream len
    
    return str
)

function CleanUpMaterialLibrary=
(
    for m=1 to 24 do 
    (
        local mat = Standardmaterial()
        mat.name = "Standard - " + m as string
        meditMaterials[m] = mat
        
    )

)