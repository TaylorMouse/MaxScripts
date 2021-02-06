/*
    .COPYRIGHT 
    | (c) 2021 Griffon Studios
    
    .AUTHOR
    | by Taylor Mouse
    
    .DESCRIPTION
    | Warcraft III Reforged mdx exporter 
    
    .RELEASE NOTES
    | 0.02 - Writes MDLX, VERS, MODL, SEQS, MTLS, LAYS, KMTA, TEXS
    | 0.01 - Main setup
    
    
    
*/
GLOBAL WC3_DEBUG = true

STRUCT GriffonStudios_Warcraft_3_Writer_Functions
(
    function WriteFixedString stream str len=
    (
        if ( WC3_DEBUG ) then  Format "Writing %\n" str
        for i=1 to str.count do
        (
            local byte = bit.charasint str[i]
            writeByte stream byte
        )
        for i=1 to (len - str.count) do
            writeByte stream 0
    ),
    function WriteVector3 stream vector3=
    (
        writeFloat stream vector3.X
        writeFloat stream vector3.Y
        writeFloat stream vector3.Z
    ),
    function WriteMODLBoundingBox stream=
    (
        local bbox = GriffonStudios_Helper_Functions.GetMODLBoundingBox()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        if ( WC3_DEBUG ) then  Format "Writing bbox %\n" bbox
        
        writer.WriteVector3 stream bbox[1]
        writer.WriteVector3 stream bbox[2]
        
    ),
    function WriteSEQS stream=
    (
        local help = GriffonStudios_Helper_Functions()
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        local seqs = help.GetSEQS()
        
        writeLong stream ( 132 * seqs.count)
        
        -- ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
        for seq in seqs do
        (
            
            
            writer.WriteFixedString stream seq.Name 80
            WriteLong  stream seq.StartFrame
            WriteLong  stream seq.EndFrame
            WriteFloat stream seq.MovementSpeed
            WriteLong  stream seq.NoLoop
            WriteFloat stream seq.Rarity
            WriteLong  stream seq.Default
            WriteFloat stream seq.Priority
            
            writer.WriteVector3 stream seq.BBox[1]
            writer.WriteVector3 stream seq.BBox[2]
            
            if ( WC3_DEBUG ) then  Format " - %\n" seq
        )

        
    ),
    function WriteMTLS stream=
    (
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        local mtls = GriffonStudios_Helper_Functions.GetMTLS()
        
        if (WC3_DEBUG) then 
        (
            for i=1 to mtls.TEXSList.Count do
                format " - %\n" mtls.TEXSList[i]
        )
        
        writeLong stream mtls.TotalSize
        
        for s in mtls.ShaderList do
        (
            writeLong stream s.shaderSizeIncluded
            writeLong stream s.priorityPlane
            writeLong stream s.flag
            writer.WriteFixedString stream s.shaderName 80
            
            writer.WriteFixedString stream "LAYS" 4
            writeLong stream s.Layers.Count --> usually 6
            
            for l=1 to s.Layers.Count do
            (
                local lay = s.Layers[l]
                writeLong stream lay.layerSizeIncluded
                writeLong stream lay.filterMode
                writeLong stream lay.shadingFlag
                writeLong stream ( lay.TextureId - 1 )
                writeLong stream lay.textureAnimationId
                
                writeLong stream 0 -- CoordId
                writeFloat stream 1 -- Alpha
                writeFloat stream 1 -- Emissive
                
                writeFloat stream 1 -- Fresnel Color R
                writeFloat stream 1 -- Fresnel Color G
                writeFloat stream 1 -- Fresnel Color B
                writeFloat stream 0 -- Fresnel Opacity
                writeFloat stream 0 -- Fresnel Team Color
                
                if ( l==1) then 
                (
                    if ( lay.KMTA != undefined ) then
                    (
                        writer.WriteFixedString stream "KMTA" 4
                        writeLong stream lay.KMTA.timeList.count
                        writeLong stream 1 --> line type
                        writeLong stream -1 --> parentId
                        
                        for k=1 to lay.KMTA.timeList.count do
                        (
                            writeLong stream lay.KMTA.timeList[k]
                            writeLong stream lay.KMTA.valueList[k]
                        )
                        
                    )
                )
            )

        )
        
        GriffonStudios_Warcraft_3_Writer_Functions.WriteTEXS stream mtls.TEXSList
    ),
    function WriteTEXS stream texsList =
    (
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        writer.WriteFixedString stream "TEXS" 4
        
        writeLong stream ( texslist.count * 268 )
        for tex in texsList do
        (
            writeLong stream tex.replaceableId
            writer.WriteFixedString stream tex.fileName 260
            writeLong stream tex.flag
        )            
        
    )
)

STRUCT GriffonStudios_Helper_Functions
(
    /* Get the bounding box of a specific object */
    function GetBoundingBox =
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
    /* Calculate the volume of a bounding box in order to see which one is the biggest */
    function GetBoundingBoxVolume bbox=
    (
        local p1 = bbox[1]
        local p2 = bbox[2]
        
        local height = distance [p2.X,0,0] [p1.X,0,0]
        local width  = distance [p2.Y,0,0] [p1.Y,0,0]
        local depth  = distance [p2.Z,0,0] [p1.Z,0,0]
        
        local volume = height * width * depth
        
        return volume
    ),
    /* Get the last key on the animation track for one object */
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
                        last_frame = GriffonStudios_Helper_Functions.FindLastKeyFrameByObject obj[i] last_frame
                    )
                    
                )
            )
        )
        return last_frame
        
    ),
    /* Get the last key on the animation track from ALL objects */
    function FindLastKeyFrame =
    (
        local last_frame = 0
        for obj in objects do
        (
            last_frame = GriffonStudios_Helper_Functions.FindLastKeyFrameByObject obj last_frame
        )
        return last_frame
    ),
    /* Get the biggest bounding box from all models between 2 frame, as animation changes these bounding boxes */
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        local help = GriffonStudios_Helper_Functions()
        
        struct bboxVolume ( bbox, volume )

        bboxVolumeList = #()

        for f = startFrame to endFrame do
            at time f (
                
                local bbox = help.GetBoundingBox()
                local vol = help.GetBoundingBoxVolume bbox
                local bv = bboxVolume bbox:bbox volume:vol
                
                append bboxVolumeList bv
            )
            

        biggestId = 1
        for i=1 to bboxVolumeList.count do
        (
            for j=(i+1) to bboxVolumeList.count do
            (
                if ( bboxVolumeList[i].volume > bboxVolumeList[j].volume ) then biggestId = i
            )
        )
        
        return bboxVolumeList[biggestId].bbox  
    ),
    /* Get the biggest bounding box for the whole set of animations keys, specifically needed for the MODL chunk */
    function GetMODLBoundingBox =
    (
        local help = GriffonStudios_Helper_Functions()
        local lastFrame = help.FindLastKeyFrame()

        bbox = help.GetMODLBoundingBoxBetweenFrames 1 lastFrame
        
        return bbox
        
    ),
    /* get the list of animation sequences from the animation track */
    function GetSEQS =
    (
        struct WC3RefAnimSequence ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
        local size = 132

        local seqs = #()
        
        local wc3startFrame = 0
        local wc3EndFrame = 0
        
        if( numNoteTracks rootNode > 0 ) then 
        (
            local track = getNoteTrack rootNode 1
            local keys = track.Keys
            
            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local parts = filterstring note "\r\n"
                local s = WC3RefAnimSequence()
                
                s.name = parts[1]
                
                local StartFrameStr = (getnotekeytime track i) as string 
                local EndFrameStr = (getnotekeytime track (i+1)) as string 
                
                StartFrameStr = substring StartFrameStr 1 (StartFrameStr.count-1)
                EndFrameStr   = substring EndFrameStr 1 (EndFrameStr.count-1)
                
                local startFrame = StartFrameStr as integer
                local endFrame = EndFrameStr as integer
                
                
                s.BBox = GriffonStudios_Helper_Functions.GetMODLBoundingBoxBetweenFrames startFrame endFrame
                    
                seqLength = ( EndFrame - startFrame ) * 1000 / 30 
                
                wc3EndFrame = wc3startFrame + seqLength
                
                s.StartFrame = wc3startFrame --startFrame * 1000 / 30
                s.EndFrame = wc3EndFrame -- EndFrame * 1000 / 30
                
                wc3startFrame = wc3EndFrame + 34
                s.Default = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                     
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.movementSpeed = value as float
                    if ( key == "nonLoop" ) then s.noLoop = value as float
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local startFrame = 1000 / 30
            local endFrame = 50 * 1000 / 30
            local seq = WC3RefAnimSequence Name:"Stand" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = GriffonStudios_Helper_Functions.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        --print seqs
        return seqs
    ),
    /* Get the list of materials and their properties and the list of associated textures */
    function GetMTLS=
    (
        local help = GriffonStudios_Helper_Functions()
        local default_shader_name = "Shader_HD_DefaultUnit"
        
        struct _mtls ( TotalSize = 0, ShaderList = #(), TEXSList = #() )
        
        struct _shaders ( shaderSizeIncluded, priorityPlane, shaderName = default_shader_name, flag = 0, Layers = #() )
        struct _lays ( layerSizeIncluded,  filterMode, shadingFlag, textureId, textureAnimationId, KMTA )
        struct _kmta ( timeList = #(), valueList = #() )
        local mtls = _mtls()
        
        local uniqueMaterials = #()
        
        for obj in objects do
        (
            if ( obj.material != undefined and ( classof obj.material == WC3RefMaterial ) ) then
                appendIfUnique uniqueMaterials obj.material
        )
        /* get the textures, their ID is important in writing the MTLS */
        mtls.TEXSList = help.GetUniqueTextures uniqueMaterials
        
        for mat in uniqueMaterials do
        (
            mtls.TotalSize = mtls.TotalSize + 92 --> 92 bytes -> priority plane, shadername, flag
            
            local s = _shaders()
            
            s.shaderSizeIncluded = 92 --> starter header size 
            s.priorityPlane = mat.priorityplane
            if ( mat.twosided ) then s.flag = 0x2
            
            
            s.shaderSizeIncluded = s.shaderSizeIncluded + 8 --> 4 byte characters LAYS, 4 bytes nbr layers
            mtls.TotalSize = mtls.TotalSize + 8 --> 4 byte characters LAYS, 4 bytes nbr layers

            -- LAYS
            for i=1 to 6 do
            (
                local lay = _lays()
                
                lay.layerSizeIncluded = 52
                s.shaderSizeIncluded = s.shaderSizeIncluded + 52
                mtls.TotalSize = mtls.TotalSize + 52
                lay.filterMode = mat.filterMode - 1
                lay.shadingFlag = 0
                if( mat.twosided ) then lay.shadingFlag = 0x10
                
                if (i==1) then 
                (
                    lay.textureId = help.GetLayerTextureId mtls.TEXSList mat.diffuse_map
                    
                    if ( mat.material_alpha.controller != undefined ) then 
                    (
                        --> KMTA, nbr Key Values, Linetype, parent Id -> extra 16 bytes
                        s.shaderSizeIncluded  = s.shaderSizeIncluded + 16
                        mtls.TotalSize        = mtls.TotalSize + 16
                        lay.layerSizeIncluded = lay.layerSizeIncluded + 16
                        
                        local kmta = _kmta()
                        
                        for key in ctrl.keys do
                        (
                            s.shaderSizeIncluded  = s.shaderSizeIncluded + 8
                            mtls.TotalSize        = mtls.TotalSize + 8
                            lay.layerSizeIncluded = lay.layerSizeIncluded + 8
                            
                            local theTime = help.TimeToInt key.time
                            theTime = theTime * 1000 / 30
                            append kmta.timeList theTime
                            append kmta.valueList key.value
                        )
                        
                        lay.KMTA = kmta
                    )
                    
                )
                if (i==2) then lay.textureId = help.GetLayerTextureId mtls.TEXSList mat.normal_map
                if (i==3) then lay.textureId = help.GetLayerTextureId mtls.TEXSList mat.orm_map
                if (i==4) then lay.textureId = help.GetLayerTextureId mtls.TEXSList mat.emissive_map
                if (i==5) then lay.textureId = help.GetLayerTextureId mtls.TEXSList mat.replacable_map
                if (i==6) then lay.textureId = help.GetLayerTextureId mtls.TEXSList mat.reflection_map
                
                lay.textureAnimationId = -1
                
                
                append s.Layers lay
            )
            
            
            append mtls.shaderlist s
        )
        
        
        
        
        return mtls
    ),
    /* Get the unique list of textures so that a reference can be made when writing the mtls block */
    function GetTEXS bitmap=
    (
        
        if( bitmap==undefined ) then 
            tex = ""
        else
        (
            local fileName = filenameFromPath bitmap.fileName
            
            if( fileName == "" or fileName.count <=4 ) then 
                tex = ""
            else
                tex = "Textures/" + fileName 
        )
        return tex
    ),
    /* helper function to list only the unique texs based on the reference to texture files */
    function GetUniqueTextures uniqueMaterials=
    (
        struct _texs ( id, replaceableId, fileName, flag = 3 )
        
        /* get the list of textures */
        local texsList = #()
        for mat in uniqueMaterials do
        (
            local tex  = undefined
            
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.diffuse_map
            appendIfUnique texsList tex
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.normal_map
            appendIfUnique texsList tex
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.orm_map
            appendIfUnique texsList tex
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.emissive_map
            appendIfUnique texsList tex
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.replacable_map
            appendIfUnique texsList tex
            tex = GriffonStudios_Helper_Functions.GetTEXS mat.reflection_map
            appendIfUnique texsList tex
            
        )
        
        local mtlsTextures = #()
        for i=1 to texsList.count do
        (
            textureFile = texsList[i]
            local t = _texs id:i replaceableId:1 fileName:""
            
            if ( textureFile != "" ) then t = _texs id:i replaceableId:0 fileName:textureFile
            
            append mtlsTextures t
        )
        
        return mtlsTextures
    ),
    function GetLayerTextureId textureList map=
    (
        if ( map == undefined ) then textureToFind = ""
        if ( map != undefined ) then 
        (
            textureToFind = (filenameFromPath map.fileName)
            if ( textureToFind.count <= 4 ) then textureToFind = ""
            if ( textureToFind.count > 4) then textureToFind = "Textures/" +  (filenameFromPath map.fileName)
            
        )
        
        local textureId = 0
        for t in textureList do
        (
            if ( t.fileName == textureToFind ) then 
            (
                textureId = t.id
                exit
            )
        )
        if textureId ==0 then throw "Texture ID not found !!"
        --format "Texture ID : %\n" textureId
        return textureId
        
    ),
    function TimeToInt theTime=
    (
        local strTime = theTime as string
        local intTime = ( substring strTime 1 (strTime.count - 1) ) as integer
        return intTime
    )
    
)


STRUCT GriffonStudios_Warcraft_3_Reforged_Exporter
(
    function Export file=
    (
        if ( objects.count == 0 ) then return undefined
        local writer = GriffonStudios_Warcraft_3_Writer_Functions()
        
        local stream = fopen file "wb"
        
        --try (
            /* MDLX */
            writer.WriteFixedString stream "MDLX" 4
            
            /* VERS */
            writer.WriteFixedString stream "VERS" 4
            writeLong stream 4
            writeLong stream 1000
            
            /* MODL */
            writer.WriteFixedString stream "MODL" 4
            writeLong stream 372
            
            writer.WriteFixedString stream ( getFileNameFile file ) 80
            writer.WriteFixedString stream "" 260
            writeLong stream 0
            writer.WriteMODLBoundingBox stream
            writeLong stream 150
            
            /* SEQS */
            writer.WriteFixedString stream "SEQS" 4
            writer.WriteSEQS stream
            
            /* MTLS & TEXS */
            writer.WriteFixedString stream "MTLS" 4
            writer.WriteMTLS stream
        

            Format "DONE!\n"
        --) catch ( print ( getCurrentException() ) )

        fFlush stream
        fClose stream
        gc()        
    )
)

clearlistener()

file = @"G:\Game Dev\Griffon Studios\My 3D Models\Warcraft\WC3 Reforged\tm_tulip.mdx"

--GriffonStudios_Warcraft_3_Reforged_Exporter.Export file

