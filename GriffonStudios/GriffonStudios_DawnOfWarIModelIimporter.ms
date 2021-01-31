/*
    .COPYRIGHT
    |   (c) 2020-2021 Griffon Studios
    
    
    .AUTHOR
    |   Taylor Mouse
    
    .DESCRIPTION
    |   Dawn of War I Model importer

*/

fileIn "GriffonStudios_HelperScripts_Struct.ms"
global debug_mode = true

struct dow_reader
(
    function read_TAGS stream=
    (
        local gs = GriffonStudios_Helpers()
        
        struct Tag ( header, id, size, name, data_offset )

        local currentPos = fTell stream 
        
        fSeek stream 0 #seek_end
        
        local streamSize = ftell stream
        
        fSeek stream currentPos #seek_set
        
        local tags = #()
        local x = 1 --> failsafe

        while ( x < 100 ) do
        (
            local t = Tag()
            
            t.header = gs.readFixedString stream 8
            t.id = readLong stream
            t.size = readLong stream
            t.name = gs.readFixedString stream (readLong stream)
            t.data_offset = ftell stream --> position where the data starts
            
            gs.SkipBytes stream t.size
            
            append tags t
            
            currentPos = fTell stream 
            if ( currentPos + 8 >= streamSize ) then exit
            
            x = x + 1
        )
        
        return tags
    ),
    function read_DATAFBIF tag stream=
    (
        struct FileBurnInfo ( PluginName, PluginVersion, Author, CreatedOn )
        local gs = GriffonStudios_Helpers()
        
        local fbi = FileBurnInfo()
        
        fSeek stream tag.data_offset #seek_set
        
        fbi.PluginName = gs.readFixedString stream (readLong stream)
        fbi.PluginVersion = readLong stream
        fbi.Author = gs.readFixedString stream (readLong stream)
        fbi.CreatedOn = gs.readFixedString stream (readLong stream)

        return fbi
    ),
    function read_DATASSHR stream=
    (
        struct StringData ( Id, StringList )
        
        local sd = StringData()
        local gs = GriffonStudios_Helpers()
        local nbrTextures = readLong stream
        
        sd.Id = readLong stream
        sd.StringList = #()
        
        for i= 1 to nbrTextures do
        (
            local name = gs.readFixedString stream (readLong stream)
            appendIfUnique sd.StringList name
        )
        
        return sd
        
    ),
    function read_DATASKEL stream=
    (
        local gs = GriffonStudios_Helpers()
        
        struct SkeletonData ( Id, Size, nBones, BoneList )
        struct BoneInfo ( Id, Name, ParentId, Pos, Rot, BoneRef  )
        
        local sk  = SkeletonData()
        sk.Id     = readLong stream
        sk.size   = readLong stream
        local unk = readLong stream
        sk.nBones = readLong stream
        sk.BoneList = #()
        
        for i=1 to sk.nBones do
        (
            local b = BoneInfo()
            b.Id = i
            b.Name = gs.readFixedString stream (readLong stream)
            b.ParentId = readLong stream #unsigned + 1
            b.Pos = [readFloat stream, readFloat stream, readFloat stream]
            b.Rot = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream)
            append sk.BoneList b
        )
        
        return sk
    ),
    function read_FOLDRSGM main_tag stream=
    (
        local gs = GriffonStudios_Helpers()
        fseek stream main_tag.data_offset #seek_set
        
        local totalSize = main_tag.data_offset + main_tag.size
        
        struct ModelData ( DATASSHR, DATASKEL )
        
        local md = ModelData()
        local strings = #()
        local failSafe = 10000
        while ( (ftell stream ) < totalSize ) do
        (
            local chunk_name = gs.readFixedString stream 8
        
            if( chunk_name == "DATASSHR" ) then 
                append strings ( dow_reader.read_DATASSHR stream )
            
            if ( chunk_name == "DATASKEL" ) then 
                md.DATASKEL = dow_reader.read_DATASKEL stream
            
            failSafe = failSafe - 1
            if ( failSafe < 0 ) then exit
        )
        
        md.DATASSHR = strings
        
        return md
    )
    
)

struct dow_builder
(
    function build_Bones modelData=
    (
        local gs = GriffonStudios_Helpers()
        
        local boneLayer = gs.CreateLayer "Bones"
        local boneList = modelData.DATASKEL.boneList
        
        for b in boneList do
        (
            
            b.boneRef = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            b.boneRef.name = b.Name
            b.boneRef.Width = 0.05
			b.boneRef.Height = 0.05
            
            
            boneLayer.AddNode b.boneRef
            b.boneRef.showLinks = true
        )
        
        for b in boneList do
        (
            if ( b.parentId > 0 ) then b.boneRef.parent = boneList[b.parentId].boneRef
        )

        for b in boneList do
        (
            local newmat = (matrix3 [0,0,0] [0,0,0] [0,0,0] [0,0,0])											

            bonequat = b.rot as matrix3	
            newmat.row1 = (point3 bonequat[1][1] -bonequat[2][1] -bonequat[3][1])						
            newmat.row2 = (point3 -bonequat[1][2] bonequat[2][2] bonequat[3][2])						
            newmat.row3 = (point3 -bonequat[1][3] bonequat[2][3] bonequat[3][3])						
            newmat.row4 = b.pos	* 50		

            newrot = newmat as quat																		            
            newrot.w *= -1																				

            newpos = newmat.translationpart																
            newpos.x *= -1																				

            in coordsys parent b.boneRef.rotation = newrot												
            in coordsys parent b.boneRef.pos = newpos													
        
        )
    )
)

struct dow_importer
(
    function start file=
    (   

        local gs = GriffonStudios_Helpers()
        local stream = fOpen file "rb"

        local relicChunky = gs.readFixedString stream 12
        local unk1 = readLong stream
        local versionMax = readLong stream
        local versionMin = readLong stream
    
        local tags = dow_reader.read_TAGS stream
        local fileBurnInfo = undefined
        local modelData = undefined
        
        for tag in tags do
        (
            if tag.header == "DATAFBIF" then fileBurnInfo = dow_reader.read_DATAFBIF tag stream
            if tag.header == "FOLDRSGM" then modelData = dow_reader.read_FOLDRSGM tag stream
        )
        

        fClose stream
        
        if debug_mode then 
        (
            print tags
            print fileBurnInfo
            print modelData.DATASSHR
            print modelData.DATASKEL
            
            --dow_builder.build_Bones modelData

        )
        
        return true
    )
)

clearlistener()
dow_importer.start @"G:\Game Dev\Griffon Studios\My Max Scripts\DOW I Scripts\dark_eldar_archon_sp.whm"