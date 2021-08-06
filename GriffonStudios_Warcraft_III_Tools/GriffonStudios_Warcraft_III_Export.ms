/*
    .SYNOPSIS
    | Exporter for Warcraft III mdx (old version = version 800 )
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 1.5 - Export KMTA
    | 1.4 - Export TXAN
    | 1.3 - Export GLBS with texture support
    | 1.2 - First successfull export!
    | 1.1 - bugfix: vertex weights should be done on tv Vertices
    | 1.0 - bugfix: MTLS incorrect TEXS & incorrect BONE size
    | 0.9 - Export BONE, HELP
    | 0.8 - Export CLID, EVTS, PIVT, ATCH
    | 0.7 - Gather all Objects 
    | 0.6 - Export GEOA
    | 0.5 - Export GEOS
    | 0.4 - Export MTLS & TEXS
    | 0.3 - Export GLBS
    | 0.2 - Export MODL & SEQS
    | 0.1 - Initial setup


*/

fileIn "GriffonStudios_Warcraft_III_Helpers.ms"
fileIn "GriffonStudios_Helpers.ms"

GLOBAL WC3_MDX800_DEBUG = true
GLOBAL MDX_EXPORT = undefined
GLOBAL WC3_INVERT_UVW = true
GLOBAL WC3_TEXTURE_EXPORT_EXTENSION = ".tga" --> .blp, .dds, .tga have been tested
GLOBAL WC3_VALIDATE_MESHES = false

STRUCT WC3_MDX800_EXPORTER
(
    function WriteMDLX800 mdx=
    (
        format "Writing MDLX\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "MDLX" 4
        format "Writing VERS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "VERS" 4
        writeLong mdx.stream 4
        writeLong mdx.stream 800
    ),
    function WriteMODL800 mdx=
    (
        format "Writing MODL\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "MODL" 4
        writeLong mdx.stream 372
        
        local fileName = getfilenamefile mdx.file
        Warcraft_III_Helpers.WriteFixedString mdx.stream fileName 80
        Warcraft_III_Helpers.WriteFixedString mdx.stream "" 260
        
        local radius = 0.0
        local selectionSphere = getnodebyname "Selection_Sphere"
        if( classOf selectionSphere == sphere ) then radius = selectionSphere.radius * 4.0
        
        writefloat mdx.stream radius

        local bbox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 0 1
        
        Warcraft_III_Helpers.WriteVector3 mdx.stream bbox[1]
        Warcraft_III_Helpers.WriteVector3 mdx.stream bbox[2]

        writeLong mdx.stream 150
    ),
    function WriteSEQS800 mdx=
    (
        format "Writing SEQS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "SEQS" 4
        
        writeLong mdx.stream ( 132 * mdx.seqs.count)
        
        for seq in mdx.seqs do
        (
            Warcraft_III_Helpers.WriteFixedString mdx.stream seq.Name 80
            WriteLong  mdx.stream seq.StartFrame
            WriteLong  mdx.stream seq.EndFrame
            WriteFloat mdx.stream seq.MovementSpeed
            WriteLong  mdx.stream seq.NoLoop
            WriteFloat mdx.stream seq.Rarity
            WriteLong  mdx.stream seq.Default
            WriteFloat mdx.stream seq.Priority
            
            Warcraft_III_Helpers.WriteVector3 mdx.stream seq.BBox[1]
            Warcraft_III_Helpers.WriteVector3 mdx.stream seq.BBox[2]

        )

    ),
    function WriteGLBS800 mdx=
    (
        if mdx.glbs == undefined then return undefined

        
        Warcraft_III_Helpers.GetGLBS mdx
       
        if mdx.glbs.count > 0 then (
        
            format "Writing GLBS\n"
            Warcraft_III_Helpers.WriteFixedString mdx.stream "GLBS" 4
            
            writeLong mdx.stream (mdx.glbs.count * 4)
            for g in mdx.glbs do writeLong mdx.stream g.frame
        )
    ),
    function WriteMTLS800 mdx=
    (
        format "Writing MTLS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "MTLS" 4

        local size = 0
        for mat in mdx.mtls do
        (
            if classof mat.materialRef == compositeMaterial then
            (
                if ( classof mat.materialRef.materialList[1] == WarcraftIII_Standard and 
                     classof mat.materialRef.materialList[1] == WarcraftIII_Standard ) then 
                (
                    size += 76
                    for i=1 to 2 do
                    (
                        if ( mat.materialRef.materialList[i].Alpha.controller != undefined ) then 
                            size += 16 + ( 8 * mat.materialRef.materialList[i].Alpha.controller.keys.count)
                    )
                    
                )
            )
            if ( classof mat.materialRef == WarcraftIII_Standard ) then
            (
                size += 48
                if ( mat.materialRef.Alpha.controller != undefined ) then size += 16 + ( 8 * mat.materialRef.Alpha.controller.keys.count)
            )
        )
        
        writeLong mdx.stream size
        
        for i=1 to mdx.mtls.count do
        (
            local mat = mdx.mtls[i].materialRef
            
            if classof mat == compositeMaterial then --> Team color or .fli
            (
                
                writeLong mdx.stream 76 --> size --> currently only supports 2 sub materials
                writeLong mdx.stream 0 --> priority
                writeLong mdx.stream 0 --> flags --> TODO rework this, check the lava elemental for more info
                Warcraft_III_Helpers.WriteFixedString mdx.stream "LAYS" 4 
                writeLong mdx.stream 2 --> nMaps
                
                for j=1 to 2 do
                (
                    local path = mat.materialList[j].diffuse_map.fileName
                    WC3_MDX800_EXPORTER.WriteLAYS800 mdx path mat.materialList[j] mdx.mtls[i].txanId
                )
            )
            if ( classof mat == WarcraftIII_Standard ) then
            (
                local laySize = 48
                if ( mat.Alpha.controller != undefined ) then 
                (
                    laySize = laySize + 16 + ( mat.Alpha.controller.keys.count * 8 )
                )
                
                writeLong mdx.stream laySize --> size 
                writeLong mdx.stream 0 --> priority
                writeLong mdx.stream 0 --> flags
                Warcraft_III_Helpers.WriteFixedString mdx.stream "LAYS" 4 
                writeLong mdx.stream 1 --> nMaps
                local path = mat.diffuse_map.fileName
                WC3_MDX800_EXPORTER.WriteLAYS800 mdx path mat mdx.mtls[i].txanId
               
            )
        )
    ),
    function WriteLAYS800 mdx path mat txanId=
    (
        local miniSize = 28
        local hasKMTA = false
        local lineType = 0
        if ( mat.Alpha.controller != undefined ) then 
        (
            hasKMTA = true
            if (  classof mat.Alpha.controller == Linear_Float ) then lineType = 1
            if (  classof mat.Alpha.controller == TCB_Float ) then lineType = 2
            if (  classof mat.Alpha.controller == Bezier_Float ) then lineType = 3
            miniSize = miniSize + 16 + ( mat.Alpha.controller.keys.count * 8 )
            
            format "KMTA % \n" miniSize
        )

        writeLong mdx.stream miniSize --> size
        writeLong mdx.stream (mat.FilterMode - 1) --> filtermode
        
        local shadingFlags = 0
       
        if mat.unshaded then shadingFlags += 0x01
        if mat.twosided then shadingFlags += 0x10
        if mat.unfogged then shadingFlags += 0x20
        if mat.nodepthset then shadingFlags += 0x40
        if mat.nodepthtest then shadingFlags += 0x80
        if mat.unselectable then shadingFlags += 0x100
        
        writeLong mdx.stream shadingFlags
        
        local replacableId = mat.ReplaceableTexture - 1

        if ( path == undefined ) then path = "" --> no textures selected
        if ( path.count > 0 ) then path = (getfilenamefile path) + WC3_TEXTURE_EXPORT_EXTENSION --> extension only
        
        if replacableId == 2 then path = ""

        local texsID = 0
        for t=1 to mdx.texs.count do 
        (
            if mdx.texs[t].replacableId == replacableId and mdx.texs[t].path == path then 
            (
                texsID = t - 1
                exit
            )
        )
        writeLong mdx.stream texsID --> matching texture id
        writeLong mdx.stream txanId #unsigned --> TXAN ID
        writeLong mdx.stream 0 --> uv layer
        writeFloat mdx.stream ( mat.alpha / 100.0)
        
        -- is this part of a glbs ?
        local glbsId = -1
        for m=1 to mdx.GLBS.Count do
            if mdx.GLBS[m].objRef.name == mat.name and mdx.GLBS[m].type == #MATERIAL then glbsId = m - 1
               
        
        
        -- Write KMTA
        if (hasKMTA) then
        (
            Warcraft_III_Helpers.WriteFixedString mdx.stream "KMTA" 4
            writeLong mdx.stream mat.Alpha.controller.keys.count
            writeLong mdx.stream linetype
            writeLong mdx.stream glbsId #unsigned
            
            for key in mat.Alpha.controller.keys do
                at time key.time 
                (
                    local frame = ( key.time as integer / ticksperframe ) * 1000 / 30 as integer
                    writeLong mdx.stream frame
                    writeFloat mdx.stream ( mat.Alpha / 100.0 )
                )
        )
        
    ),
    function WriteTEXS800 mdx=
    (
        format "Writing TEXS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "TEXS" 4
        
        writeLong mdx.stream ( mdx.texs.count * 268 ) 
        
        for tex in mdx.texs do
        (
            writeLong mdx.stream tex.replacableId
            Warcraft_III_Helpers.WriteFixedString mdx.stream tex.path 260
            writeLong mdx.stream tex.flags
        )

    ),
    function WriteTXAN800 mdx=
    (
        if mdx.TXAN == undefined then return undefined
        if mdx.TXAN.count == 0 then return undefined
            
        format "Writing TXAN\n"

        local totalSize = 0
        for txan in mdx.TXAN do totalSize += txan.size
        
        Warcraft_III_Helpers.WriteFixedString mdx.stream "TXAN" 4
        writeLong mdx.stream totalSize
        
        for txan in mdx.TXAN do
        (
            writeLong mdx.stream txan.size
            Warcraft_III_Helpers.WriteFixedString mdx.stream "KTAT" 4
            writeLong mdx.stream txan.KTAT.numPts
            writeLong mdx.stream txan.KTAT.lineType
            writeLong mdx.stream txan.KTAT.glbsId
            
            for kg in txan.KTAT.KG do
            (
                writeLong mdx.stream ( kg.time * 1000 / 30 )
                Warcraft_III_Helpers.WriteVector3 mdx.stream kg.Point
            )
        )
        
        
    ),
    function WriteGEOS800 mdx=
    (
        format "Writing GEOS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "GEOS" 4
        
        local totalSize = 0
        for geo in mdx.geos do totalSize += geo.size
        
        writeLong mdx.stream totalSize
        if WC3_MDX800_DEBUG then format " - total size: %\n" totalSize
        
        for geo in mdx.geos do
        (
            writeLong mdx.stream geo.size
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "VRTX" 4
            writeLong mdx.stream geo.VRTX.count
            for v in geo.VRTX do Warcraft_III_Helpers.WriteVector3 mdx.stream v
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "NRMS" 4
            writeLong mdx.stream geo.NRMS.count
            for n in geo.NRMS do Warcraft_III_Helpers.WriteVector3 mdx.stream n

            Warcraft_III_Helpers.WriteFixedString mdx.stream "PTYP" 4
            writeLong mdx.stream 1
            writeLong mdx.stream geo.PTYP
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "PCNT" 4
            writeLong mdx.stream 1
            writeLong mdx.stream geo.PCNT
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "PVTX" 4
            writeLong mdx.stream ( geo.PVTX.count * 3 )
            for p in geo.PVTX do Warcraft_III_Helpers.WriteTris mdx.stream p
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "GNDX" 4
            writeLong mdx.stream geo.GNDX.count
            for g in geo.GNDX do writeByte mdx.stream ( g - 1 )
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "MTGC" 4 --> matching bone group counts
            writeLong mdx.stream geo.MTGC.count
            for m in geo.MTGC do writeLong mdx.stream m
                
            Warcraft_III_Helpers.WriteFixedString mdx.stream "MATS" 4 --> matching bone sets
            writeLong mdx.stream geo.MATS.matrices.count
            for m in geo.MATS.matrices do writeLong mdx.stream m
            writeLong mdx.stream geo.MATS.materialId
            writeLong mdx.stream geo.MATS.sectionGroupId
            writeLong mdx.stream geo.MATS.sectionGroupType
            for f=1 to 7 do writeFloat mdx.stream geo.MATS.sevenFloats[f]
            writeLong mdx.stream geo.MATS.nbrFloats
            for f=1 to geo.MATS.nbrFloats*7 do writeFloat mdx.stream geo.MATS.floats[f]
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "UVAS" 4
            writeLong mdx.stream 1
            Warcraft_III_Helpers.WriteFixedString mdx.stream "UVBS" 4
            writeLong mdx.stream geo.UVBS.count
            for uv in geo.UVBS do 
            (
                writeFloat mdx.stream uv[1]
                writeFloat mdx.stream uv[2]
            )
        
        )
        
    ),
    function WriteGEOA800 mdx=
    (
        format "Writing GEOA\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "GEOA" 4
        
        local totalSize = 0
        for geoa in mdx.geoa do totalSize += geoa.size
        writeLong  mdx.stream totalSize
        for geoa in mdx.geoa do
        (
            writeLong  mdx.stream geoa.size
            writeFloat mdx.stream geoa.opacity
            writeLong  mdx.stream geoa.type
            for i=1 to 3 do writeFloat mdx.stream geoa.color[i]
            writeLong  mdx.stream geoa.geoId

            if ( geoa.KGAO != undefined ) then 
            (
                Warcraft_III_Helpers.WriteFixedString mdx.stream "KGAO" 4
                writeLong  mdx.stream geoa.KGAO.numPts
                writeLong  mdx.stream geoa.KGAO.LineType
                writeLong  mdx.stream geoa.KGAO.GLBSID #signed
                for kg in geoa.KGAO.KG do
                (
                    writeLong  mdx.stream kg.time
                    writeFloat mdx.stream kg.point
                )
                
            )
        )
    ),
    function WriteBONE800 mdx=
    (
        format "Writing BONE\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "BONE" 4
        
        local totalSize = 0
        
        local behavior = Warcraft_III_Helpers.GetBehavior()
        
        for obj in mdx.allObjects do
        (
            if ( obj.ObjectType == #wc3BONE ) then
            (
                totalSize += obj.totalSize + 8 --> headersize + geosetid + geosetAnimId
                
                if ( behavior != undefined ) then 
                (
                    for b in behavior.listOfObjects do 
                    (
                        if ( obj.objref.name == b.name and classof b == boneGeometry ) then 
                        (
                            obj.geosetId = 2
                            obj.geosetAnimationId = 2
                        )
                    )
                )
            )
        )
        writeLong mdx.stream totalSize
        
        for obj in mdx.allObjects do
        (                
            if ( obj.ObjectType == #wc3BONE ) then
            (
                writeLong mdx.stream obj.totalSize
                Warcraft_III_Helpers.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
                Warcraft_III_Helpers.WriteKGAnim mdx.stream obj.KGTR
                Warcraft_III_Helpers.WriteKGAnim mdx.stream obj.KGRT
                Warcraft_III_Helpers.WriteKGAnim mdx.stream obj.KGSC
                
                writeLong mdx.stream obj.geosetId
                writeLong mdx.stream obj.geosetAnimationId
            )
        )
        
    ),
    function WriteHELP800 mdx=
    (
        local nbrHelpers = 0
        for obj in mdx.allObjects do
            if ( obj.ObjectType == #wc3HELP ) then nbrHelpers += 1
        
        if nbrHelpers == 0 then return undefined
        format "Writing HELP\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "HELP" 4
        
        local totalSize = 0
        
        for obj in mdx.allObjects do
            if ( obj.ObjectType == #wc3HELP ) then
                totalSize += obj.totalSize
        
        writeLong mdx.stream totalSize
        
        for obj in mdx.allObjects do
        (                
            if ( obj.ObjectType == #wc3HELP ) then
            (
                writeLong mdx.stream obj.totalSize
                Warcraft_III_Helpers.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
               Warcraft_III_Helpers.WriteKGAnim mdx.stream obj.KGTR
               Warcraft_III_Helpers.WriteKGAnim mdx.stream obj.KGRT
               Warcraft_III_Helpers.WriteKGAnim mdx.stream obj.KGSC
                
            )
        )
        
    ),
    function WriteATCH800 mdx=
    (
        format "Writing ATCH\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "ATCH" 4
        
        local totalSize = 0
        
        for obj in mdx.allObjects do
            if obj.ObjectType == #wc3ATCH then totalSize += 364  -- obj.TotalSize --> no animations yet
        
        writeLong mdx.stream totalSize
            
        local index = 0
        for obj in mdx.allObjects do
        (
            if obj.ObjectType == #wc3ATCH then 
            (
                writeLong mdx.stream 364 --obj.totalSize
                writeLong mdx.stream obj.headerSize
                Warcraft_III_Helpers.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                Warcraft_III_Helpers.WriteFixedString mdx.stream "" 260
                writeLong mdx.stream index
                
                index += 1
            )
        )
        
    ),
    function WritePIVT800 mdx=
    (
        format "Writing PIVT\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "PIVT" 4  
        
        local totalSize = mdx.allObjects.count * 12
        writeLong mdx.stream totalSize
        
        for obj in mdx.allobjects do
        (
            writeFloat mdx.stream obj.objRef.pos.x
            writeFloat mdx.stream obj.objRef.pos.y
            writeFloat mdx.stream obj.objRef.pos.z
        )
        
    ),
    function WriteEVTS800 mdx=
    (
        format "Writing EVTS\n"
        
        
        local totalSize = 0
        for obj in mdx.allObjects do
        (
            if ( obj.ObjectType == #wc3EVTS ) then 
            if ( obj.objRef.keyList.count > 0 ) then 
            (
                totalSize += obj.headerSize
                totalSize += 12 --> KEVT + nbrKeys + ParentId 
                totalSize += obj.objRef.keyList.count * 4
            )
        )
        if totalSize == 0 then return undefined
        Warcraft_III_Helpers.WriteFixedString mdx.stream "EVTS" 4
        writeLong mdx.stream totalSize
        
        for obj in mdx.allObjects do
        (
            if ( obj.ObjectType == #wc3EVTS ) then 
            if ( obj.objRef.keyList.count > 0 ) then 
            (
                writeLong mdx.stream obj.headerSize
                Warcraft_III_Helpers.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
                Warcraft_III_Helpers.WriteFixedString mdx.stream "KEVT" 4
                writeLong mdx.stream obj.objRef.keyList.count
                writeLong mdx.stream -1 #signed
                for k in obj.objRef.keyList do writeLong mdx.stream ( k * 1000 / 30 )
            )
        )
        
    ),
    function WriteCLID800 mdx=
    (
        format "Writing CLID\n"
         
        
        local totalSize = 0
        for obj in mdx.allobjects do
        (
            if obj.ObjectType == #wc3CLID then
            (
                totalSize += obj.headerSize
                if ( classof obj.objRef == box ) then totalSize += 28
                if ( classof obj.objRef == plane ) then totalSize += 28
                if ( classof obj.objRef == sphere ) then totalSize += 20
                if ( classof obj.objRef == cylinder ) then totalSize += 32
            )
        )
        if totalSize == 0 then return undefined
        Warcraft_III_Helpers.WriteFixedString mdx.stream "CLID" 4 
        writeLong mdx.stream totalSize

        for obj in mdx.allobjects do
        (
            if obj.ObjectType == #wc3CLID then
            ( 
                writeLong mdx.stream obj.headerSize
                Warcraft_III_Helpers.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
                if ( classof obj.objRef == box ) then 
                (
                    writeLong mdx.stream 0
                    writeFloat mdx.stream obj.objRef.min.x
                    writeFloat mdx.stream obj.objRef.min.y
                    writeFloat mdx.stream obj.objRef.min.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                )    
                if ( classof obj.objRef == plane ) then 
                (
                    writeLong mdx.stream 1
                    writeFloat mdx.stream obj.objRef.min.x
                    writeFloat mdx.stream obj.objRef.min.y
                    writeFloat mdx.stream obj.objRef.min.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                )    
                if ( classof obj.objRef == sphere ) then 
                (
                    writeLong mdx.stream 2
                    writeFloat mdx.stream obj.objRef.pos.x
                    writeFloat mdx.stream obj.objRef.pos.y
                    writeFloat mdx.stream obj.objRef.pos.z
                    writeFloat mdx.stream obj.objRef.radius
                )                
                if ( classof obj.objRef == cylinder ) then 
                (
                    writeLong mdx.stream 3
                    writeFloat mdx.stream obj.objRef.pos.x
                    writeFloat mdx.stream obj.objRef.pos.y
                    writeFloat mdx.stream obj.objRef.pos.z
                    writeFloat mdx.stream obj.objRef.pos.x
                    writeFloat mdx.stream obj.objRef.pos.y
                    writeFloat mdx.stream ( obj.objRef.pos.z + obj.objRef.height )
                    writeFloat mdx.stream obj.objRef.radius
                ) 
            )
        )
        
    ),
    function Export file=
    (
        if ( file == undefined ) then return undefined
        clearlistener()
        struct mdx800 
            ( file, stream, 
              seqs, glbs, mtls, texs, geos, geoa, txan, 
              allObjects, autoCreatedObjectsForExport = #()
            )
        local mdx = mdx800()
        mdx.file = file
        local export = WC3_MDX800_EXPORTER()
        
        -- set the T-pose of the object to export correctly
        clearselection()

        local animationInterval = animationrange
        animationrange = interval 0 100
        slidertime = 0

        Warcraft_III_Helpers.GetObjects mdx

        Warcraft_III_Helpers.GetSEQS mdx
        Warcraft_III_Helpers.GetMTLS mdx
        Warcraft_III_Helpers.GetTEXS mdx
        Warcraft_III_Helpers.GetGEOS mdx
        Warcraft_III_Helpers.GetGEOA mdx
        Warcraft_III_Helpers.GetGLBS mdx        
        Warcraft_III_Helpers.GetTXAN mdx
        
        mdx.stream = fOpen file "wb"
        
        if WC3_MDX800_DEBUG then MDX_EXPORT = mdx
        
        export.WriteMDLX800 mdx
        export.WriteMODL800 mdx
        export.WriteSEQS800 mdx
        export.WriteGLBS800 mdx
        export.WriteMTLS800 mdx
        export.WriteTEXS800 mdx
        export.WriteTXAN800 mdx
        export.WriteGEOS800 mdx
        export.WriteGEOA800 mdx
        export.WriteBONE800 mdx
        export.WriteHELP800 mdx
        export.WriteATCH800 mdx
        export.WritePIVT800 mdx
        export.WriteEVTS800 mdx
        export.WriteCLID800 mdx
        
        fFlush mdx.stream
        fClose mdx.stream
        
        animationrange = interval animationInterval.start animationInterval.end
        gc() 
        return mdx
    )
)