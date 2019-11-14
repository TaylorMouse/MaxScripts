/*
    (c) 2020 Griffon Studios
    
    by Taylor Mouse
    
    Warcraft III Reforged export model
    
*/

/*
  flags
    Bone:256
    Light:512
    Attachment:2048
    ParticleEmitter:4096
    ParticleEmitter2:4096
    RibbonEmitter:16384
    Event:1024
    CollisionShape:8192
*/
struct MDX_EXPORT
(  seqs, mtls, texs )
    
global mdxExport = MDX_EXPORT()

struct Writer_Helpers
(
    function WriteFixedString stream str len=
    (
        for i=1 to str.count do
        (
            local byte = bit.charasint str[i]
            writeByte stream byte
        )
        for i=1 to (len - str.count) do
            writeByte stream 0
    ),
    function WriteBytes stream byte len=
    (
        for i=1 to len do
            writeByte stream byte
        
    ),
    function WriteVector3 stream vector3=
    (
        writeFloat stream vector3.X
        writeFloat stream vector3.Y
        writeFloat stream vector3.Z
    ),
    function GetBoundingBox=
    (
        local bbPoints = #()
        local bbMax = [0,0,0]
        local bbMin = [0,0,0]
        
        for obj in objects do
        (
            if ( classof obj == Editable_mesh ) then
            (
                if ( obj.Max.X > bbMax.X) then bbMax.X = obj.Max.X
                if ( obj.Max.Y > bbMax.Y) then bbMax.Y = obj.Max.Y
                if ( obj.Max.Z > bbMax.Z) then bbMax.Z = obj.Max.Z
                if ( obj.Min.X < bbMin.X) then bbMin.X = obj.Min.X
                if ( obj.Min.Y < bbMin.Y) then bbMin.Y = obj.Min.Y
                if ( obj.Min.Z < bbMin.Z) then bbMin.Z = obj.Min.Z
                
            )
        )
        append bbPoints bbMin 
        append bbPoints bbMax
        return bbPoints
    ),
    function ReplaceAll str source target=
    (
        local ret = ""
        for i=1 to str.count do
        (
            if( str[i] == source ) then ret +=target else ret += str[i]
            
        )
        return ret
    ),
    function ParseTexs file replacableId=
    (
        struct WC3RefTexs ( ReplacableId, fileName, flag, originalFileName )
        
        local fileName = substring file (Warcraft3_AssetFolder.count + 1) -1
        fileName = Writer_Helpers.replaceAll fileName @"\" "/"
        
        if ( getfilenamefile fileName == "" ) then fileName = ""
        
        local t = WC3RefTexs ReplacableId:replacableId fileName:fileName flag:3 originalFileName:file
        
        return t
    )
    
)

struct Warcraft3_Reforged_Export
(
    function WriteLAYR stream filtermode flags textureFileName texs=
    (
            writelong stream 32
            writelong stream ( filterMode - 1 )
            writelong stream flags
            
            for t=1 to texs.count do
            (
                if ( texs[t].originalFileName == textureFileName ) then 
                ( 
                    writelong stream t
                    exit 
                )
            )
            writelong stream -1 #signed
            writeLong stream 0 
            writefloat stream 1
            writefloat stream 1  
        
        
    ),
    function WriteMDLX stream=
    (
        Writer_Helpers.WriteFixedString stream "MDLX" 4
        Writer_Helpers.WriteFixedString stream "VERS" 4
        writeLong stream 4
        writeLong stream 900
    ),
    function WriteMODL stream file=
    (
        -- size 372 bytes
        Writer_Helpers.WriteFixedString stream "MODL" 4
        writeLong stream 372

        local name = getfilenamefile file 
        Writer_Helpers.WriteFixedString stream name 80
        Writer_Helpers.WriteBytes stream 0 264

        local bbBox = Writer_Helpers.GetBoundingBox()
        
        Writer_Helpers.WriteVector3 stream bbBox[1]
        Writer_Helpers.WriteVector3 stream bbBox[2]
        writeLong stream 150
        
    ),
    function WriteSEQS stream=
    (
        struct WC3Seqs ( Name, Rarity, MoveSpeed, NonLoop, DefaultAnim, Sub_Anim, Priority, BBox, StartFrame, endFrame )
        
        local seqs = #()
        
        if( numNoteTracks rootNode > 0 ) then 
        (
            local track = getNoteTrack rootNode 1
            local keys = track.Keys
            
            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local parts = filterstring note "\r\n"
                local s = WC3Seqs()
                
                s.name = parts[1]
                
                local StartFrameStr = (getnotekeytime track i) as string 
                local EndFrameStr = (getnotekeytime track (i+1)) as string 
                
                StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
                EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
                
                local startFrame = StartFrameStr as integer
                local endFrame = EndFrameStr as integer
                
                with animate on at time startFrame s.BBox = Writer_Helpers.GetBoundingBox()
                    
                s.StartFrame =  startFrame * 1000 / 30
                s.EndFrame = EndFrame * 1000 / 30
                s.sub_anim = 0
                s.DefaultAnim = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                     
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.moveSpeed = value as float
                    if ( key == "nonLoop" ) then 
                    (
                        if value == false then s.nonLoop = 0.0 else s.nonloop = 1.0
                    )
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local starAnimTrack = notetrack "starAnimTrack"
            addNoteTrack rootNode starAnimTrack
            
            local startNote = AddNewNoteKey starAnimTrack 10
            local endNote = AddNewNoteKey starAnimTrack 100
            local val = "Stand\r\n"
                  val += "rarity = 100\r\n"
                  val += "moveSpeed = 0.0\r\n"
                  val += "nonLoop = false\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = 0"

            startNote.Value = val
            endNote.Value = val
            
            local seq = WC3Seqs()
            seq.Name = "Stand"
            seq.Rarity = 1.0
            seq.MoveSpeed = 0.0
            seq.NonLoop = 0
            seq.Priority = 0.0
            seq.DefaultAnim = 0
            seq.sub_anim = 0
            with animate on at time 10 seq.BBox = Writer_Helpers.GetBoundingBox()
            
            append seqs seq
        )
        
        Writer_Helpers.WriteFixedString stream "SEQS" 4
        writeLong stream ( 132 * seqs.count)
        
        for seq in seqs do
        (
            Writer_Helpers.WriteFixedString stream seq.Name 80
            WriteLong stream seq.StartFrame
            WriteLong stream seq.EndFrame
            WriteFloat stream seq.MoveSpeed
            WriteLong stream seq.NonLoop
            WriteFloat stream seq.Rarity
            WriteLong stream seq.DefaultAnim
            WriteFloat stream seq.Priority
            Writer_Helpers.WriteVector3 stream seq.BBox[1]
            Writer_Helpers.WriteVector3 stream seq.BBox[2]
        )
        
        mdxExport.seqs = seqs
    ),
    function WriteMTLS_TEXS stream=
    (

        Writer_Helpers.WriteFixedString stream "MTLS" 4
        
        local shaderName = "Shader_HD_DefaultUnit"

        local mats = #()
        
        for obj in objects do
            if ( classof obj.material == WC3RefMaterial ) then append mats obj.material
        
        mdxExport.mtls = mats
        
        local texs = #()

        for m in mats do
        (
            local t1 = Writer_Helpers.ParseTexs  m.diffuse_map.filename 0
            local t2 = Writer_Helpers.ParseTexs  m.normal_map.filename 0
            local t3 = Writer_Helpers.ParseTexs  m.orm_map.filename 0
            local t4 = Writer_Helpers.ParseTexs  m.emissive_map.filename 0
            local t5 = Writer_Helpers.ParseTexs  m.replacable_map.filename 1
            local t6 = Writer_Helpers.ParseTexs  m.reflection_map.filename 0

            appendifunique texs t1
            appendifunique texs t2
            appendifunique texs t3
            appendifunique texs t4
            appendifunique texs t5
            appendifunique texs t6
        )
        
        for obj in objects do
        (
            if ( classof obj == WC3RefEmitter ) then 
            (
                local t = Writer_Helpers.ParseTexs obj.texture 0 
                appendifunique texs t
            )
        )

        local nbrMtls = mats.count
        Writelong stream ( 292 * nbrMtls )
        
        -- 1 layer with no anim = 292 bytes
        for m in mats do
        (
            Writelong stream 292
            writelong stream m.priorityPlane
            writelong stream 0
            Writer_Helpers.WriteFixedString stream shaderName 80
            Writer_Helpers.WriteFixedString stream "LAYS" 4
            writelong stream 6
            
            local flags = 0
            
            if ( m.unlit == true ) then flags +=0x1
            if ( m.envmap == true ) then flags +=0x2  
            if ( m.wrapwidth == true ) then  flags +=0x4
            if ( m.wrapheight == true ) then flags +=0x8
            if ( m.twosided == true ) then flags +=0x10
            if ( m.nofog == true ) then flags +=0x20
            if ( m.nodepthtest == true ) then flags +=0x40
            if ( m.nodepthset  == true ) then flags +=0x80
            
            -- per layer
            Warcraft3_Reforged_Export.WriteLAYR stream m.filtermode flags m.diffuse_map.fileName texs
            Warcraft3_Reforged_Export.WriteLAYR stream m.filtermode flags m.normal_map.fileName texs
            Warcraft3_Reforged_Export.WriteLAYR stream m.filtermode flags m.orm_map.fileName texs
            Warcraft3_Reforged_Export.WriteLAYR stream m.filtermode flags m.emissive_map.fileName texs
            Warcraft3_Reforged_Export.WriteLAYR stream m.filtermode flags m.replacable_map.fileName texs
            Warcraft3_Reforged_Export.WriteLAYR stream m.filtermode flags m.reflection_map.fileName texs
            
        )
        
        
        Writer_Helpers.WriteFixedString stream "TEXS" 4
        
        writelong stream ( 268 * texs.count )
        
        for t in texs do
        (
            writelong stream t.ReplacableId
            Writer_Helpers.WriteFixedString stream t.fileName 260
            writelong stream t.flag
        )
        mdxExport.texs = texs
    ),
    function Write file=
    (
        local export = Warcraft3_Reforged_Export()
        local materials
        
        stream = fopen file "wb"

        export.WriteMDLX stream
        export.WriteMODL stream file
        export.WriteSEQS stream
        export.WriteMTLS_TEXS stream
        
        print mdxExport
        
        fflush stream
        fclose stream
        gc()
        
    )
    
    
    
)
clearlistener()

-- F:\Blizzard\Warcraft - Reforged\Exported\assets\doodads\terrain\citycliffs\CityCliffsAAAB0.mdx
file = @"G:\Game Dev\Griffon Studios\My Max Scripts\Blizzard Stuff\test3.mdx"

Warcraft3_Reforged_Export.Write file


