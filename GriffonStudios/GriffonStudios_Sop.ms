clearListener()
(
    function ReadVerts file=
    (
    
        local stream = fOpen file "rb"
        
        local CHAN    = readLong stream
        local version = readShort stream
        local one     = readLong stream --> should be one indicating it contains verts
        local zeroes  = readLong stream --> 0000
        
        local four_thousand = readLong stream 
        local one_hundred   = readLong stream

        local cntr = readlong stream
        
        local verts = #()
        for i=1 to cntr do 
        (
            local nbr3 = readLong stream
            for i=1 to nbr3 do 
            (
                local x = readFloat stream
                local y = readFloat stream
                local z = readFloat stream
                
                append verts [z,-x,y]
                readFloat stream
            )
            exit
        )
        
        fClose stream
        verts
    )

    function ReadFaces file=
    (
    
        local stream = fOpen file "rb"
        
        local CHAN    = readLong stream
        local version = readShort stream
        local two     = readLong stream --> should be two indicating it contains faces
        local zeroes  = readLong stream --> 0000
        
        local four_thousand = readLong stream 
        local one_hundred   = readLong stream
        local cntr = readLong stream
        local ffff = readLong stream #signed
        local nbr3 = readLong stream
        
        local indices = #()
        for i=1 to nbr3 * 3 do append indices (readShort stream)
        
       
        local faces = #()
        append faces [1, 3, 2]
        for i=1 to nbr3-1 do (
            local a = indices[i*3] + 1
            local b = indices[i*3+1] + 1
            local c = indices[i*3+2] + 1

            append faces [a, c, b]
        )
        fClose stream
        faces
    )

    function ReadColors file=
    (
    
        local stream = fOpen file "rb"
        
        local CHAN    = readLong stream
        local version = readShort stream
        local two     = readLong stream --> should be two indicating it contains faces info
        local zeroes  = readLong stream --> 0000
        
        local four_thousand = readLong stream 
        local one_hundred   = readLong stream
        local cntr = readLong stream
        local ffff = readLong stream #signed
        local nbr3 = readShort stream
        local one = readShort stream
        print nbr3
        
        local colors = #()
        local ucolors = #()
        for i=1 to nbr3 do (
            local c = (readbyte stream #unsigned)
            append colors c
            appendifunique uColors c
        )
        uColors = sort uColors
        print uColors
        fClose stream
        colors
        
    )
    
    function ApplyColors theMesh colors =
    (
        obj = convertToPoly theMesh
        obj.displayByLayer = false 
        obj.vertexColorType = 5
        obj.vertexColorMapChannel = 99
        obj.showVertexColors = on

        facesCollection =  #{1..polyOp.getNumFaces obj}

        for f in facesCollection do
        (

            local c = color 10 10 10
            -- white
            if ( colors[f] == 112 ) then c = color 200 200 200
            if ( colors[f] == 113 ) then c = color 200 200 200
            -- blue
            if ( colors[f] == 115 ) then c = color 12 23 57
            if ( colors[f] == 116 ) then c = color 12 23 57
            --red
            if ( colors[f] == 124 ) then c = color 51 0 0
            if ( colors[f] == 125 ) then c = color 51 0 0
            
            
            if ( colors[f] == 127 ) then c = color 140 112 102
            if ( colors[f] == 135 ) then c = color 140 112 102
            
            if ( colors[f] == 132 ) then c = color 90 60 40
            if ( colors[f] == 133 ) then c = color 90 60 40
            if ( colors[f] == 187 ) then c = color 21 6 20
            
            
            polyOp.SetFaceColor obj 99 f c
            
        )
        update obj
    )
    
    file1 = @"D:\Downloads\main_idle.sop"
    file2 = @"D:\Downloads\main_idle.mesh"
    file3 = @"D:\Downloads\main_idle.tex"
    
    max select all
    max delete
    verts = ReadVerts file1
    faces = ReadFaces file2
    colors = ReadColors file3

    local theMesh = mesh name:"main" vertices:verts faces:faces
    
    
    ApplyColors theMesh colors
    
)



