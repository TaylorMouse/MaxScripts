/*
	Import Diablo IV 
	by Taylor Mouse (c) 06.2023
*/
global d4 = undefined

STRUCT DiabloIV
(
    /************************************************************************************************
      HELPER FUNCTIONS
    ************************************************************************************************/
    function SkipBytes stream nBytesToSkip=
    (
        fseek stream nBytesToSkip #seek_cur
    ),

    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if(s!="\0") then str+=s
        )
        return str
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

    /***********************************************************************************************
        MAIN METHOD for Diablo IV
    ***********************************************************************************************/
    function ReadAppearance metaFile payloadFile =
    (
        struct d4payload ( vertices, faces )
        local d4Meshes = #()
        local pl = d4payload()
            
        local pStream = fOpen  payloadFile "rb"
        
        /* Vertices */
        --fseek pStream 1152 #seek_set
        
        384 + 768 --> 1152
        1152 + 480 --> 1632
        fseek pStream 1632 #seek_set
        --fseek pStream ( 7237 - 36*156) #seek_set
        local vSize = 6096
        
        local vertices = #()
        local nbrVertices = 156 -- vSize / 32
        for v=1 to nbrVertices do /* 36 byte chunk */
        (
           
           local vert = [readFloat pStream *50, readFloat pStream *50, readFloat pStream *50]
            append vertices vert
            
            d4.SkipBytes pStream (36 - 12)
        )

        /* Faces */
        fSeek pStream 7248 #seek_set
        local fSize = 1560
        
        local faces = #()
        local nbrFaces = fSize / 6
        for f=1 to nbrFaces do /* 2 bytes per vertex*/
        (
            local f = [readShort pStream + 1, readShort pStream + 1, readShort pStream + 1]
            append faces f
        )

        local pl = d4payload vertices:vertices faces:faces

        append d4Meshes pl
        
        
        
        
        /* Vertices */
        
        fseek pStream 8816 #seek_set

        
        local vertices = #()
        local nbrVertices = 162 
        for v=1 to nbrVertices do /* 36 byte chunk */
        (
           
           local vert = [readFloat pStream *50, readFloat pStream *50, readFloat pStream *50]
            append vertices vert
            
            d4.SkipBytes pStream (36 - 12)
        )
        

        
        /* Faces */
        fSeek pStream 14656 #seek_set
        local fSize = 1380
        
        local faces = #()
        local nbrFaces = fSize / 6
        for f=1 to nbrFaces do /* 2 bytes per vertex*/
        (
            local f = [readShort pStream + 1, readShort pStream + 1, readShort pStream + 1]
            append faces f
        )
        local pl2 = d4payload vertices:vertices faces:faces
        append d4Meshes pl2
        
        fClose pStream
        print d4Meshes
        d4Meshes
    ),

    function CreateObjects d4Meshes=
    (
        
        for m in d4Meshes do
        (
            
            local theMesh = mesh name:"temp" vertices:m.vertices faces:m.faces
        )
        
        return "ok"
    ),
    
    function Import3DModel metaFile payloadFile =
    (
        d4 = DiabloIV()
        
--         local metaStream = fOpen metaFile "rb"

--         local deadbeaf = ReadLong metaStream
--         local f06fd11d = ReadLongLong metaStream as integer

--         if( deadbeaf != -559038737 and f06fd11d != -261107427 ) then
--         (
--             MessageBox("File is not the correct format!")
--             return undefined
--         )
--         else
--             print "DEAD BEAF!"
--         fClose stream
        
        local pl = d4.ReadAppearance metaFile payloadFile
        
        d4.CreateObjects pl
    )


)

/* TEST */
(  
    ClearListener()
    local metaFile = @"G:\Blizzard\Diablo 4\Extracted\Base\meta\Appearance\Zakarum_GreatHelm_01.app"
    local payloadFile = @"G:\Blizzard\Diablo 4\Extracted\Base\payload\Appearance\Zakarum_GreatHelm_01.app"
    
    
    DiabloIV.Import3DModel metaFile payloadFile 
    
)

    
