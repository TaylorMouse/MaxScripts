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
( exportFileName, stream, vers, modl, seqs, mtls, texs, geos, geoa, bone, pivt, bpos )
    
global mdxExport = undefined 

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
                --> TODO loop over every frame 
                
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
        
        if file == undefined then file = ""
        
        local pos = findstring file Warcraft3_AssetFolder
        local fileName = ""
        if ( pos != undefined ) then  
            fileName = substring file (Warcraft3_AssetFolder.count + 1) -1
        else
            fileName = ( filenameFromPath file )

        if ( getfilenamefile fileName == "" ) then fileName = ""
        
        fileName = Writer_Helpers.replaceAll fileName @"\" "/"
        
        local t = WC3RefTexs ReplacableId:replacableId fileName:fileName flag:3 originalFileName:file
        
        return t
    ),
    function AppendIfUniqueFileName texs t=
    (
        local tFound = false
            for tex in texs do
                if tex.fileName == t.fileName then tFound = true
                    
        if tFound == false then append texs t
    ),
    function ConvertToWC3Time t=
    (
        local str = t as string
        local i  = ( ( substring str 1 (str.count-1)) as integer )
        
        local newTime = i * 1000 / 30
        return newTime
        
    ),
    function GetPosAnim obj transformMatrix=
    (
        struct anim ( frame, point )
        
        local posController = obj.pos.controller
        local nKeys = numKeys posController
        local anims = #()
        
        for i=1 to nKeys do
        (
            local t = getKeyTime posController i
            
            at time t in coordsys transformMatrix pos = obj.pos
            local wc3frame = Writer_Helpers.ConvertToWC3Time t
            append anims ( anim frame:wc3frame point:pos )
        )
        return anims
    ),
    function GetRotAnim obj transformMatrix=
    (
        struct anim ( frame, point )
        
        local rotController = obj.rotation.controller
        local nKeys = numKeys rotController
        local anims = #()
        
        for i=1 to nKeys do
        (
            local t = getKeyTime rotController i
            local rot = 0
            at time t in coordsys transformMatrix rot = obj.rotation
            local wc3frame = Writer_Helpers.ConvertToWC3Time t
            append anims ( anim frame:wc3frame point:rot )
        )
        return anims
    ),
    function GetSclAnim obj transformMatrix=
    (
        struct anim ( frame, point )
        
        local sclController = obj.scale.controller
        local nKeys = numKeys sclController
        local anims = #()
        
        for i=1 to nKeys do
        (
            local t = getKeyTime sclController i
            local scale = [1,1,1]
            at time t in coordsys transformMatrix scale = obj.scale
            local wc3frame = Writer_Helpers.ConvertToWC3Time t
            append anims ( anim frame:wc3frame point:scale )
        )
        return anims
    ),
    function CalculateTangents theMesh=
    (
        local tan1 = #()
        local tan2 = #()
        local tangent = #()
        for i=1 to theMesh.numFaces do
        (

            local f = getFace theMesh i

            local v1 = getVert theMesh f[1]
            local v2 = getVert theMesh f[2]
            local v3 = getVert theMesh f[3]

            local w1 = getTVert theMesh f[1]
            local w2 = getTVert theMesh f[2]
            local w3 = getTVert theMesh f[3]


            local x1 = v2.x - v1.x
            local x2 = v3.x - v1.x
            local y1 = v2.y - v1.y
            local y2 = v3.y - v1.y
            local z1 = v2.z - v1.z
            local z2 = v3.z - v1.z

            local s1 = w2.x - w1.x
            local s2 = w3.x - w1.x
            local t1 = w2.y - w1.y
            local t2 = w3.y - w1.y

            local r = 1.0 / ( s1 * t2 - s2 * t1)

            local sdir = [ ( t2 * x1 - t1 * x2) * r , ( t2 * y1 - t1 * y2 ) * r, ( t2 * z1 - t1 * z2 ) * r ]
            local tdir = [ ( s1 * x2 - s2 * x1) * r , ( s1 * y2 - s2 * y1 ) * r, ( s1 * z2 - s2 * z1 ) * r ]

            tan1[f[1]] = sdir
            tan1[f[2]] = sdir
            tan1[f[3]] = sdir

            tan2[f[1]] = tdir
            tan2[f[2]] = tdir
            tan2[f[3]] = tdir

        )

        for i=1 to theMesh.numVerts do
        (
            local n = getnormal theMesh i
            local t = tan1[i]
            
            local v = normalize ( ( t - n ) * ( dot n t ) )
            local w = dot ( cross n t ) tan2[i]
            
            if ( w < 0.0 ) then w = -1.0 else w = 1.0
            tangent[i] = [v.y, v.x, v.z, w]
        )
        return tangent
    ),
    function GetWeights theMesh boneList=
    (
        max modify mode
        select theMesh
        local sk = modPanel.getCurrentObject()

        struct vertexWeights ( vertexId, boneIndices, weights )
        local vertices = #()
        
        if (classof sk == Skin ) then
        (
            for v=1 to skinOps.getnumbervertices sk do
            (
                count = skinops.getvertexweightcount sk v
                
                local boneIndices = #(0,0,0,0)
                local weights = #(0,0,0,0)
                
                for k=1 to count do
                (
                    weight = skinOps.getvertexweight sk v k
                    boneId = skinOps.getvertexweightboneid sk v k
                    boneName = skinOps.getBonename sk boneId 0
                    
                    for b in mdxExport.bone do
                    (
                        if ( b.boneRef.name == boneName ) then 
                        (
                            boneId = b.Id - 1
                            exit
                        )
                    )
                    
                    boneIndices[k] = boneId
                    weights[k] = ( weight * 255 ) as integer
                )
                local vertex = vertexWeights vertexId:v boneIndices:boneIndices weights:weights
                
                append vertices vertex
            )
            
        )
        deselect theMesh
        return vertices
    ),
    function GetNumUVMaps m=
    (
        local n = meshop.getnummaps m
        
        local availableUVMaps = 0
        
        for i=1 to n do
        (
            if( ( meshop.getMapSupport m i ) == true ) then availableUVMaps +=1 
        )
        
        return availableUVMaps
        
    ),
    function GetUVCoordinates theMesh mapChannel=
    (
        local uvs = #()
        
        for v=1 to theMesh.NumVerts do
        (
            local uv = meshop.getMapVert theMesh mapChannel v
            
            append uvs [ uv.x, ( 1.0 - uv.y ) ]
        )
        return uvs
    ),
    function GetLastControllerFrame ctrl=
    (
        local lastTimeFrame = 0
        if(ctrl != undefined ) then 
        (
            if(ctrl.keys.count > 0 ) then 
            (
                local maxTimeFrame = ctrl.keys[ctrl.keys.count].time
        
                if (lastTimeFrame < maxTimeFrame) then lastTimeFrame = maxTimeFrame
            )
        )

        return lastTimeFrame
    ),
    function GetLastAnimFrame=
    (
        local lastFrame = 0
        
        for obj in objects do
        (
            local lastPosFrame = Writer_Helpers.GetLastControllerFrame obj.pos.controller
            local lastRotFrame = Writer_Helpers.GetLastControllerFrame obj.rotation.controller
            local lastScaleFrame = Writer_Helpers.GetLastControllerFrame obj.scale.controller

            if ( lastFrame < lastPosFrame ) then lastFrame = lastPosFrame
            if ( lastFrame < lastRotFrame ) then lastFrame = lastRotFrame
            if ( lastFrame < lastScaleFrame ) then lastFrame = lastScaleFrame
        )
        return lastFrame
    ),
    function WriteFloatAnim stream animations name=
    (
        if ( animations.Count > 0 ) then 
        (
            Writer_Helpers.WriteFixedString stream name 4
            writeLong stream animations.Count
            writeLong stream 1
            writeLong stream -1 #signed
            
            for anim in animations do
            (
                writeLong stream anim.frame
                local i = 3
                if ( classof anim.point == Point4 ) then i = 4
                if ( classof anim.point == Quat   ) then i = 4
                
                writeFloat stream anim.Point.x
                writeFloat stream anim.Point.y
                writeFloat stream anim.Point.z
                
                if i==4 then writeFloat stream anim.Point.w
                
            )
        )
    )
    
)

struct Warcraft3_Reforged_Export
(
    function WriteLAYR stream filtermode flags textureFileName texs=
    (
            --writelong stream 32
            writelong stream 52
            writelong stream ( filterMode - 1 )
            writelong stream flags
            
            local textureId = 0
        
            for t=1 to texs.count do
            (
                if ( texs[t].originalFileName == textureFileName ) then 
                ( 
                    textureId = t - 1 
                    exit 
                )
            )
            writelong stream textureId
            writelong stream -1 #signed
            writeLong stream 0 
            for i=1 to 5 do writefloat stream 1
            writeLong stream 0 
            writeLong stream 0 
        
        
    ),
    function WriteMDLX=
    (
        local stream = mdxExport.Stream
        
        struct vers ( len, version )
        
        mdxExport.vers = vers()
        mdxExport.vers.len = 4
        mdxExport.vers.version = 1000
        
        Writer_Helpers.WriteFixedString stream "MDLX" 4
        Writer_Helpers.WriteFixedString stream "VERS" 4
        writeLong stream mdxExport.vers.len
        writeLong stream mdxExport.vers.version
    ),
    function WriteMODL=
    (
        local stream = mdxExport.Stream
        local file = mdxExport.ExportFileName
        
        struct modl ( size, name, bbBox, always150 )
        
        mdxExport.modl = modl()
        mdxExport.modl.size = 372
        mdxExport.modl.name = getfilenamefile file 
        mdxExport.modl.bbBox = Writer_Helpers.GetBoundingBox()
        mdxExport.modl.always150 = 150
        
        Writer_Helpers.WriteFixedString stream "MODL" 4
        writeLong stream mdxExport.modl.size
        Writer_Helpers.WriteFixedString stream mdxExport.modl.name 80
        Writer_Helpers.WriteBytes stream 0 264
        Writer_Helpers.WriteVector3 stream mdxExport.modl.bbBox[1]
        Writer_Helpers.WriteVector3 stream mdxExport.modl.bbBox[2]
        writeLong stream mdxExport.modl.always150
        
    ),
    function WriteSEQS=
    (
        local stream = mdxExport.Stream
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
    function WriteMTLS_TEXS=
    (
        local stream = mdxExport.Stream
        
        Writer_Helpers.WriteFixedString stream "MTLS" 4
        
        local shaderName = "Shader_HD_DefaultUnit"

        local mats = #()
        
        for obj in objects do
            if ( classof obj.material == WC3RefMaterial ) then 
                appendifunique mats obj.material
        
        mdxExport.mtls = mats
        
        local texs = #()

        for m in mats do
        (
            local t1 = Writer_Helpers.ParseTexs  m.diffuse_map.filename 0
            local t2 = Writer_Helpers.ParseTexs  m.normal_map.filename 0
            local t3 = Writer_Helpers.ParseTexs  m.orm_map.filename 0
            local t4 = Writer_Helpers.ParseTexs  m.emissive_map.filename 0
            local t5 = Writer_Helpers.ParseTexs  m.replacable_map.filename 1
            local t6 = Writer_Helpers.ParseTexs  m.reflection_map.filename 1

            Writer_Helpers.AppendIfUniqueFileName texs t1
            Writer_Helpers.AppendIfUniqueFileName texs t2
            Writer_Helpers.AppendIfUniqueFileName texs t3
            Writer_Helpers.AppendIfUniqueFileName texs t4
            Writer_Helpers.AppendIfUniqueFileName texs t5
            Writer_Helpers.AppendIfUniqueFileName texs t6

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
        Writelong stream ( 412 * nbrMtls )
        
        -- 1 layer with no anim = 292 bytes
        for m in mats do
        (
            Writelong stream 412
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
    function ReadBONE=
    (
        struct wc3bone ( Id, ParentId, BoneRef, KGTR, KGRT, KGSC, Size )
        local wc3bones = #()
        
        -- Get the Bones in the scene
        for obj in objects do
        (
            local index = 1
            if ( classof obj == BoneGeometry ) then
            (
                local b = wc3bone Id:index BoneRef:obj ParentId:0 Size:0
                append wc3bones b
                index +=1
            )
        )
        -- build the hierarchy
        for b in wc3Bones do
        (
            if ( b.BoneRef.Parent != undefined ) then
            (
                for i=1 to wc3Bones.Count do
                (
                    if ( b.BoneRef.Parent == wc3Bones[i].BoneRef ) then
                    (
                        b.BoneRef.ParentId = i
                    )
                )
            )
        )  
        mdxExport.bone = wc3bones
        
    ),
    function ReadBoneAnim=
    (
        for wc3bone in mdxExport.bone do
        (
            local transformMatrix = mdxExport.bpos[wc3bone.Id].mtrx
            
            wc3bone.KGTR = Writer_Helpers.GetPosAnim wc3bone.boneRef transformMatrix
            wc3bone.KGRT = Writer_Helpers.GetRotAnim wc3bone.boneRef transformMatrix
            wc3bone.KGSC = Writer_Helpers.GetSclAnim wc3bone.boneRef transformMatrix
        )
        
    ),
    function WriteGEOS=
    (
        local stream = mdxExport.Stream
        local meshes = #()
        for obj in objects do
            if (classof obj == Editable_mesh ) then append meshes obj

        struct wc3lod (size, vrtx, nrms, ptyp, pcnt, pvtx, gndx, mtgc, mats, tang, skin, uvas, uvbs )
        struct wc3mats ( id, lodid, name )
        
        -- todo: defeine how to make a difference bewteen LOD's
        
        local lods = #()
        for m in meshes do
        (
            local l = wc3lod()
            
            l.vrtx = #()
            for v=1 to m.numverts do
                append l.vrtx ( getvert m v )
            
            l.nrms = #()
            for v=1 to m.numverts do
                append l.nrms ( getnormal m v )
            
            l.ptyp = 4
            
            l.pcnt = m.numFaces * 3
            
            l.pvtx = #()
            for f=1 to m.numFaces do
            (
                local face = getface m f
                append l.pvtx [face.x - 1, face.y - 1, face.z - 1]
            )
            
            l.gndx = 0
            
            l.mtgc = 1
            
            l.mats = wc3mats()
            
            for x=1 to mdxExport.mtls.count do
                if ( mdxExport.mtls[x] == m.material ) then ( l.mats.id = x - 1; exit )

            l.mats.lodid = 0 --> for now
            l.mats.name = m.name
            
            l.tang = Writer_Helpers.CalculateTangents m
            
            l.skin = Writer_Helpers.GetWeights m mdxExport.bone
            
            l.uvas = Writer_Helpers.GetNumUVMaps m

            l.uvbs = #()
            for u=1 to l.uvas do
                  append l.uvbs ( Writer_Helpers.GetUVCoordinates m u )

            append lods l
        )        
        local geosSize = 0    
        for l in lods do
        (
            local lodSize = 0
            lodSize += 4 --> count the position of the "size" to
            lodSize += l.vrtx.count * 3 * 4 + 8
            lodSize += l.nrms.count * 3 * 4 + 8
            lodSize += 12 -- ptyp
            lodSize += 12 -- pcnt
            lodSize += l.pvtx.count * 3 * 2 + 8
            lodSize += 8 -- gndx
            lodSize += 12 -- mtgc
            lodSize += 28 + 112 -- mats
            lodSize += l.tang.count * 4 * 4  + 8
            lodSize += l.skin.count * 8 + 8 -- weights
            lodSize += 8 -- uvas
            
            for u in l.uvbs do
                lodSize += u.count * 8 + 8
            
            l.size = lodSize
            geosSize += lodSize
        )

        
        Writer_Helpers.WriteFixedString stream "GEOS" 4
        writelong stream geossize
        
        for l in lods do
        (
            writelong stream l.size
            
            Writer_Helpers.WriteFixedString stream "VRTX" 4
            writelong stream l.vrtx.count
            for v in l.vrtx do
            (
                writefloat stream v.x
                writefloat stream v.y
                writefloat stream v.z
            )
            
            Writer_Helpers.WriteFixedString stream "NRMS" 4
            writelong stream l.vrtx.count
            for v in l.nrms do
            (
                writefloat stream v.x
                writefloat stream v.y
                writefloat stream v.z
            )
            
            Writer_Helpers.WriteFixedString stream "PTYP" 4
            writelong stream 1
            writelong stream l.ptyp
            
            Writer_Helpers.WriteFixedString stream "PCNT" 4
            writelong stream 1
            writelong stream l.pcnt
            
            Writer_Helpers.WriteFixedString stream "PVTX" 4
            writelong stream ( l.pvtx.count * 3 )
            for i in l.pvtx do
            (
                writeshort stream i.x
                writeshort stream i.y
                writeshort stream i.z
                
            )
            
            Writer_Helpers.WriteFixedString stream "GNDX" 4
            writelong stream l.gndx
            
            
            Writer_Helpers.WriteFixedString stream "MTGC" 4
            writelong stream 1
            writelong stream 1
            
            Writer_Helpers.WriteFixedString stream "MATS" 4
            writelong stream 1
            writelong stream 0
            writelong stream l.mats.id
            writelong stream 0
            writelong stream 0
            writelong stream l.mats.lodid
            Writer_Helpers.WriteFixedString stream l.mats.name 112
            
            Writer_Helpers.WriteFixedString stream "TANG" 4
            writelong stream l.vrtx.count
            for t in l.tang do
            (
                writefloat stream t[1]
                writefloat stream t[2]
                writefloat stream t[3]
                writefloat stream t[4]
            )
            
            Writer_Helpers.WriteFixedString stream "SKIN" 4
            writeLong stream ( l.skin.count * 8 )
            for s in l.skin do
            (
                writebyte stream s.boneIndices[1]
                writebyte stream s.boneIndices[2]
                writebyte stream s.boneIndices[3]
                writebyte stream s.boneIndices[4]
                writebyte stream s.weights[1]
                writebyte stream s.weights[2]
                writebyte stream s.weights[3]
                writebyte stream s.weights[4]
            )

            Writer_Helpers.WriteFixedString stream "UVAS" 4
            writelong stream l.uvas
            
            for uvb in l.uvbs do
            (
                Writer_Helpers.WriteFixedString stream "UVBS" 4
                writelong stream l.vrtx.count
                
                for uv in uvb do
                (
                    writefloat stream uv[1]
                    writefloat stream uv[2]
                )
                
            )

        )
        
        
        /*
        GEOS 
            COMPLETE SIZE --> all the LOD's
            SIZE LOD --> complete size of 1 LOD
                VRTX
                    Nbr of vertices
                    floats ( 3 per vertex)
                NRMS
                    Nbr of vertices
                    floats ( 3 per vertex)
                PTYP
                    Nbr of different types ( = 1 )
                    Long ( = 4 )
                PCNT
                    Nbr of primitives ( = 1 )
                    Nbr of indeces ( nbr faces * 3 )
                PVTX 
                    Nbr of indeces ( nbr faces * 3 )
                    shorts 
                GNDX
                    Nbr of Groups ( = 0 )
                MTGC
                    Nbr of matrix groups ( = 1)
                    Long ( = 1)
                MATS
                    Nbr of materials ( = 1 )
                    Long ( = 0 )
                    Id in the mtls list
                    2 x long ( 2x 0 )
                    LOD id
                    name of the object ( 112 characters )
                TANG
                    Nbr of tangents ( = nbr of vertices )
                    floats ( 4 per tang )
                    use CalculateTangents
                SKIN
                    nbr vertices * 8 ( 8 bytes per definition, 4 weights, 4 bones )
                    bytes ( 8 per vertex )
                    use GetWeights
                UVAS
                    Nbr of UV coordinates
                    use GetNumUVMaps
                
                    UVBS ( appears UVAS times )
                        Nbr of vertices
                        U as a float
                        V as a float
                        use GetUVCoordinates
        */
        
    ),
    function ReadGEOA=
    (
        
        struct wc3geoa ( meshId, keys, size )
        struct wc3geoakey ( frame, visible )
        
        local meshes = #()
        local geoas = #()
        local meshId = 1
        
        for obj in objects do 
            if (classof obj == Editable_mesh ) then append meshes obj

        
        for m in meshes do
        (
            local geoa = wc3geoa meshid:meshId size:0
            if ( m.visibility != undefined and (getVisController m) != undefined ) then 
            (
                geoa.keys = #()
                -- add ZERO frame
                local g = wc3geoakey frame:0
                with animate on at time 0 g.visible = m.visibility
                append geoa.keys g
                
                for i= 1 to ( numKeys m.visibility.controller ) do
                (
                    local t = getkeytime m.visibility.controller i
                    local t_before = t - 1
                    
                    -- add previous frame state
                    local g = wc3geoakey frame:t_before
                    with animate on at time t_before
                        g.visible = m.visibility
                    append geoa.keys g
                    
                    local g = wc3geoakey frame:t
                    with animate on at time t
                        g.visible = m.visibility
                    append geoa.keys g
                )
                
                -- add last frame
                local lastFrame = Writer_Helpers.GetLastAnimFrame()
                local g = wc3geoakey frame:lastFrame
                local t = getkeytime m.visibility.controller ( numKeys m.visibility.controller )
                with animate on at time t g.visible = m.visibility
                append geoa.keys g

            )
           -- print geoa
            append geoas geoa
            meshId += 1 
        )
        mdxExport.geoa = geoas
        
    ),
    function WriteGEOA=
    (
        local stream = mdxExport.Stream
        Warcraft3_Reforged_Export.ReadGEOA()
        
        if ( mdxExport.geoa == undefined ) then return undefined
        
        local totalSize = 0
        
        for g in mdxExport.geoa do
        (
            totalSize +=28
            g.Size = 28
            if( g.keys != undefined ) then 
            (
                g.Size +=16
                g.Size += g.keys.count * 8 
                totalSize +=16 -- KGAO nbrofKGAO linetype=0 -1
                totalSize += g.keys.count * 8 
            )

            
        )

        Writer_Helpers.WriteFixedString stream "GEOA" 4
        writelong stream totalSize
        
        for g in mdxExport.geoa do
        (    
            
            writelong stream g.size
            writefloat stream 1
            writeLong stream 0
            writefloat stream 1
            writefloat stream 1
            writefloat stream 1
            writeLong stream ( g.meshId - 1 )
            
            if( g.keys != undefined ) then 
            (
                Writer_Helpers.WriteFixedString stream "KGAO" 4
                writeLong stream g.keys.count
                writeLong stream 0
                writeLong stream -1 #signed
                
                for i=1 to g.keys.count do
                (
                    local key = g.keys[i]
                    local frameStr = ( key.frame as string )
                    local frameInt = (substring frameStr 1 (frameStr.count - 1 )) as integer
                    local frame = frameInt * 1000 / 30
                    
                    writeLong stream frame
                    
                    if ( key.visible == true ) then writefloat stream 1 else writefloat stream 0
                        
                )
            )
            
        )
    ),
    function WriteBONE=
    (
        local stream = mdxExport.Stream
        -- Calculate the sizes first
        local totalSize = 0 --> BONE + size
        for b in mdxExport.Bone do
        (
            totalSize += 4  -- size
            totalSize += 80 -- name
            totalSize += 4  -- Id
            totalSize += 4  -- ParentBoneId
            totalSize += 4  -- Flags = 256
            totalSize += 4  -- 0000
            totalSize += 4  -- ffff
            b.Size = 96
            
            if ( b.KGTR.Count > 0 ) then 
            (
                totalSize += 16 -- > KGTR + nbr + linetype + parentid
                totalSize += b.KGTR.Count * 16
                b.Size += 16 + b.KGTR.Count * 16
            )
            if ( b.KGRT.Count > 0 ) then 
            (
                totalSize += 16 -- > KGRT + nbr + linetype + parentid
                totalSize += b.KGRT.Count * 20
                b.Size += 16 + b.KGRT.Count * 20
            )
            if ( b.KGSC.Count > 0 ) then 
            (
                totalSize += 16 -- > KGSC + nbr + linetype + parentid
                totalSize += b.KGSC.Count * 16
                b.Size += 16 + b.KGSC.Count * 16
            )
        )

        -- Write out
        Writer_Helpers.WriteFixedString stream "BONE" 4
        WriteLong stream totalSize
        
        for b in mdxExport.Bone do
        (
            writelong stream b.Size
            Writer_Helpers.WriteFixedString stream b.BoneRef.Name 80
            writeLong stream ( b.Id - 1 )
            writeLong stream ( b.ParentId - 1 ) #signed
            writeLong stream 256

            Writer_Helpers.WriteFloatAnim stream b.KGTR "KGTR"
            Writer_Helpers.WriteFloatAnim stream b.KGRT "KGRT"
            Writer_Helpers.WriteFloatAnim stream b.KGSC "KGSC"
            writelong stream 0
            writelong stream -1 #signed
        )
        
        
        
    ),
    function ReadBPOS=
    (
        struct wc3bpos ( id, mtrx )
        
        local bpos = #()
        for b in mdxExport.bone do
        (
            local bp = wc3bpos id:b.id mtrx:b.BoneRef.transform
            append bpos bp
        )
        mdxExport.bpos = bpos
    ),
    function WriteBPOS=
    (
        local stream = mdxExport.Stream
        Writer_Helpers.WriteFixedString stream "BPOS" 4
        writelong stream ( mdxExport.bpos.count * 48 + 4 )
        writelong stream mdxExport.bpos.count
        
        for bpos in mdxExport.bpos do
        (
            for i=1 to 4 do
            (
                writefloat stream bpos.mtrx[i].x
                writefloat stream bpos.mtrx[i].y
                writefloat stream bpos.mtrx[i].z
            )
        )
    ),
    function WritePIVT=
    (
        local stream = mdxExport.Stream
        local totalSize = 0
        
        totalSize += mdxExport.Bone.Count * 12
        
        Writer_Helpers.WriteFixedString stream "PIVT" 4
        writelong stream totalSize
        
        for b in mdxExport.Bone do
        (
            local pos
            at time 0 pos =  b.BoneRef.Pos
            writeFloat stream pos.x
            writeFloat stream pos.y
            writeFloat stream pos.z
        )
        
    ),
    function Write file=
    (
        local export = Warcraft3_Reforged_Export()
        Warcraft3_AssetFolder = getinisetting "griffonstudios.config" "Warcraft3Reforged" "AssetFolder"
        
        if Warcraft3_AssetFolder == undefined then 
        (   
            Warcraft3_AssetFolder = ""
            format "[WARNING] Warcraft3_AssetFolder is not set !"
        )
        
        mdxExport = MDX_EXPORT()
        mdxExport.stream = fopen file "wb"
        mdxExport.exportFileName = file
        
        export.ReadBONE()
        export.ReadBPOS()
        export.ReadBoneAnim()
        
        export.WriteMDLX()
        export.WriteMODL()
        export.WriteSEQS()
        export.WriteMTLS_TEXS() --> TODO write Alpha animation !!
        export.WriteGEOS()
        export.WriteGEOA()
        export.WriteBONE()
        export.WritePIVT()
        
        -- CORN
        -- EVNTS
		
        export.WriteBPOS()
        
        fflush mdxExport.stream
        fclose mdxExport.stream
        
        mdxExport = undefined
        gc()
        
    )
    
)
clearlistener()


-- file= @"G:\Game Dev\Griffon Studios\My Max Scripts\Blizzard Stuff\pumpkin.mdx"

-- Warcraft3_Reforged_Export.Write file
