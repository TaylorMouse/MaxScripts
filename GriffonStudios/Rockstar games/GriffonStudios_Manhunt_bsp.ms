/*
    .AUTHOR
        Taylor Mouse
    
    .DATE
        3 Sept 2021
        
    .COPYRIGHT
        (c)2010-2021 Griffon Studios   
        
    .DESCRIPTION
        Read Rockstar's Manhunt BSP files

    .UPDATES
    | - Refine the texture find algorithm
    | - Added support for alpha layers in the materials
    | - Fixed a bug assigning the correct material index to the correct face
    | - Added finding the texture files from a specific location
    | - Added material support
    | - Fixed a buf on the different types of tris setup
    | - Initial import

*/

(
    clearListener()
    
    local texturePath = @"G:\Game Dev\3D Models\Game Models\Rockstar Games\Manhunt\Textures\"
    
    function CreateLayer layerName =
    (
        /* Create layer in MAX, if it exists, just return a reference to that layer */
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    )
    
    function ReplaceString str oldStr newStr=
    (
        local foundAt = findstring str oldStr
        local left    = substring str 1 (foundAt - 1)
        local right   = substring str (foundAt + oldStr.count) -1
        
        (left + newStr + right )
    )
    
    function FindTexture textureName=
    (
        struct manhunt_texture ( theFile, isAlpha )
        local searchOptions = dotnetClass "System.IO.SearchOption"
        local directory = dotnetClass "System.IO.Directory"
        local wildCard = "*" + textureName + "*.*"
        local theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
        
        local shitList = #("alpha", "ALPHA", "_A", "Alph", "_ALPHA", "der_" )
        local isAlpha = false
        
        if ( theFile == undefined ) then 
        (
            for shit in shitList do 
            (
                wildCard = ""
                if ( findstring textureName shit ) != undefined then 
                (
                    wildCard = "*" +  ( ReplaceString textureName shit "" ) + "*.*"    
                    theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
                    isAlpha = true
                )
                if ( theFile != undefined ) then exit
            )
                
            if theFile == undefined then 
            (   
                -- refine the algoritm
                isAlpha = true
                for c=textureName.count to 1 by -1 do
                (
                    local rifinedName = substring textureName 1 c
                    wildCard = "*" + rifinedName + "*.*"
                    theFile = (directory.GetFiles  texturePath  wildCard searchOptions.AllDirectories)[1]
                    if theFile != undefined then exit
                    
                )
                
                if theFile == undefined then (
                    format "Unable to find the following texture: % \n\n" textureName
                    theFile = textureName
                    isAlpha = false
                )
            )

        )
        manhunt_texture theFile:theFile isAlpha:isAlpha
    )
    
    function ReadFixedString stream val =
    (
        local str = ""
        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)
            if ( s !="\0") then str+=s
        )
        return str
    )
    
    function SkipBytes stream nbrBytesToSkip=
    (
        fseek stream nbrBytesToSkip #seek_cur
    )
    
    function ReadBspHeader stream=
    (
        struct bsp_header ( Id, Size, Flags)
        local h = bsp_header()
        
        h.Id   = readLong stream #unsigned
        h.Size = readLong stream #unsigned
        h.Flags = [readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned]
       
        return h
        
    )
    
    function ReadBspMaterial stream=
    (
        struct bsp_material ( Type, Size, ManhuntTexture, MaterialRef = Standard() )
        
        local mat = bsp_material()

        local header = ReadBspHeader stream -- 7
        mat.Type = header.Id
        mat.Size = header.Size
        
        local tmp = ReadBspHeader stream -- 1
        SkipBytes stream tmp.Size
        
        local textureHeader = ReadBspHeader stream -- 6
        
        local calcSize = textureHeader.Size
        local TextureName = ""
        while( calcSize> 0 ) do
        (
            local tmp = ReadBspHeader stream
            local tmpName = ""
            
            if ( tmp.Id == 1 ) then SkipBytes stream tmp.Size
            if ( tmp.Id == 2 ) then tmpName = ReadFixedString stream tmp.Size
            
            if ( tmpName != "" ) then TextureName = tmpName
            
            calcSize -= tmp.Size
        )
        
        mat.ManhuntTexture = FindTexture TextureName
        mat.MaterialRef.DiffuseMap = BitmapTexture fileName:mat.ManhuntTexture.theFile
        showTextureMap mat.MaterialRef mat.MaterialRef.diffuseMap true
        if mat.ManhuntTexture.isAlpha then 
        (
            mat.MaterialRef.opacityMap = BitmapTexture fileName:mat.ManhuntTexture.theFile
            mat.MaterialRef.opacityMap.monooutput = 1
            showTextureMap mat.MaterialRef true
        )
        
        
        return mat
    )
    
    function ReadBsp file=
    (
        local layer = CreateLayer (getFilenameType file )
        
        format "Parsing file %\n" file
        local WireColor = Color (random 0 128) (random 0 255) (random 0 128)
        
        local stream = fOpen file "rb"
        
        local version = ReadBspHeader stream
        if(version.Id != 11) then throw ("Incorrect file version. Expected version 11")
        
        local header = ReadBspHeader stream
        
        SkipBytes stream 16
        local nTotalFaces = readLong stream -- ?
        local nTotalVerts = readLong stream -- ?
        
        SkipBytes stream 4
        local nChunks = readLong stream
        
        SkipBytes stream ( header.Size - 32 )
        
        /* 
            Materials block 
        */
        local materialsHeader = ReadBspHeader stream
        local materialsPos = ftell stream
        if(materialsHeader.Id != 8) then throw ("Incorrect materials header. Expected value 8")
        
        local materialHeader = ReadBspHeader stream
        local nMaterials = readLong stream

        local materialColors = #()
        for i=1 to nMaterials do 
            append materialColors ([readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned, readByte stream #unsigned])
        
        local materials = #()
        for i=1 to nMaterials do
        (
            local pos = ftell stream
            local mat = readBspMaterial stream
            append materials mat
            fseek stream ( pos + mat.Size + 12 ) #seek_set
        )
        fSeek stream ( materialsPos + materialsHeader.Size ) #seek_set
        
        /*
            data
        */
        local indexName = 0

        while ( nChunks > 0 ) do
        (
            
            local dataHeader = ReadBspHeader stream
            local dataPos = ftell stream
            
            if ( dataHeader.Id != 0x0A and dataHeader.Id != 0x09 ) then exit
            
            if ( dataHeader.Id == 0x0A ) then 
            (   
                local tmp = ReadBspHeader stream
                SkipBytes stream tmp.Size
            )
        
            if( dataHeader.Id == 0x09 ) then
            (
                local chunkHeader = ReadBspHeader stream
                SkipBytes stream 4 --> always zero ?
                
                local nFaces = readLong stream
                local nVerts = readLong stream
                
                SkipBytes stream 32 --> bbox ? 
                
                local verts = #()
                local texCoords = #()
                local faces = #()
                
                for i=1 to nVerts do
                (
                    local x = readFloat stream
                    local y = readFloat stream
                    local z = readFloat stream
                    append verts [-x, z, y]
                
                )
                SkipBytes stream ( 4 * nVerts )
                SkipBytes stream ( 4 * nVerts )
                
                for i=1 to nVerts do append texCoords [readFloat stream, 1 - (readFloat stream), 0]
                
                local matIds = #()
                
                for i=1 to nFaces do
                (
                    local a = readShort stream + 1
                    local b = readShort stream + 1
                    local c = readShort stream + 1
                    local d = readShort stream + 1
                    if (chunkHeader.Flags[4] == 24) then 
                    (
                        
                        append faces [ a, b, c]
                        append matIds d
                    )
                    else
                    (
                        
                        append faces [ b, c, d]
                        append matIds a
                    )
                )
                
                fSeek stream ( dataPos + dataHeader.Size ) #seek_set
                
                if ( verts.count > 0 and faces.count > 0 and texCoords.count > 0 ) then 
                (
                    local meshName = "Obj_" + ( indexName as string )
                    indexName +=1
                    
                    try (
                        
                       -- format "Building - %\n" meshName
                        local theMesh = mesh vertices:verts name:meshName faces:faces tverts:texCoords 
                        theMesh.WireColor = wireColor
                        buildTVFaces theMesh false
                        for i = 1 to faces.count do setTVFace theMesh i faces[i]
                        update theMesh
                        
                        
                        layer.AddNode theMesh
                    
                    )
                    catch( local error = getCurrentException() 
                        format "ERROR % \n" error
                    )
                   
                    -- apply the multi material
                    local uniqueMatIds = #()
                    for i=1 to matIds.Count do appendIfUnique uniqueMatIds matIds[i]
                    
                    local mm = MultiMaterial numsubs:uniqueMatIds.Count
                    
                    for i=1 to uniqueMatIds.Count do
                    (
                        if ( materials[uniqueMatIds[i]].MaterialRef != undefined ) then 
                        mm[i] = materials[uniqueMatIds[i]].MaterialRef
                    )
                    theMesh.Material = mm
                    update theMesh
                -- apply the multimaterials to the faces

                    --format "Material Ids %\n" matIds
                    for i=1 to nFaces do
                    (
                        
                        local faceMatId = 1
                        for j=1 to uniqueMatIds.Count do
                        (
                            if ( uniqueMatIds[j] == matIds[i] ) then 
                            (
                                faceMatId = j
                                
                                exit
                            )
                        )
                        setFaceMatID theMesh i faceMatId
                    )
                    update theMesh
                )
            )
            
        )
        
        fClose stream
    )
    
    file = getOpenFileName \
			caption:"Manhunt" \
			types:"Supported Files|*.bsp*|Manhunt Map Files(*.bspX)|*.bsp*|All Files|*.*" \
			historyCategory:"ManhuntPresets"

    if (file != undefined ) then ReadBsp file
    
    
    GC()
    FreeSceneBitmaps()
    ClearUndoBuffer()
)
