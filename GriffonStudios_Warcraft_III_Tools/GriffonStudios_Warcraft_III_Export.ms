/*
    .SYNOPSIS
    | Exporter for Warcraft III mdx (old version = version 800 )
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 0.1 - Initial setup

    .NOTE
    | DOES NOT  WORK YET !!

*/

fileIn "GriffonStudios_Warcraft_III_Helpers.ms"
fileIn "GriffonStudios_Helpers.ms"

GLOBAL WC3_MDX800_DEBUG = true
GLOBAL MDX_EXPORT = undefined
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
        format "Writing GLBS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "GLBS" 4
        
        Warcraft_III_Helpers.GetGLBS mdx
       
        writeLong mdx.stream (mdx.glbs.count * 4)
        for g in mdx.glbs do writeLong mdx.stream g
        
    ),
    function WriteMTLS800 mdx=
    (
        format "Writing MTLS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "MTLS" 4

        local size = 0
        
        for mat in mdx.mtls do --> no animation support yet
        (
            if classof mat == compositeMaterial then 
                size += 76
            else
                size += 48
        )
        writeLong mdx.stream size
        
        for mat in mdx.mtls do
        (
            if classof mat == compositeMaterial then
            (
                writeLong mdx.stream 76 --> size --> currently only supports 2 sub materials
                writeLong mdx.stream 0 --> priority
                writeLong mdx.stream 0 --> flags
                Warcraft_III_Helpers.WriteFixedString mdx.stream "LAYS" 4 
                writeLong mdx.stream 2 --> nMaps
                
                for i=1 to 2 do
                (
                    writeLong mdx.stream 28 --> size
                    writeLong mdx.stream (mat.materialList[i].FilterMode - 1) --> filtermode
                    
                    local shadingFlags = 0
                   
                    if mat.materialList[i].unshaded then shadingFlags += 0x01
                    if mat.materialList[i].twosided then shadingFlags += 0x10
                    if mat.materialList[i].unfogged then shadingFlags += 0x20
                    if mat.materialList[i].nodepthset then shadingFlags += 0x40
                    if mat.materialList[i].nodepthtest then shadingFlags += 0x80
                    if mat.materialList[i].unselectable then shadingFlags += 0x100
                    
                    writeLong mdx.stream shadingFlags
                    
                    local replacableId = mat.materialList[i].ReplaceableTexture
                    local path = mat.materialList[i].diffuse_map.fileName
                    if ( path == undefined ) then path = ""
                    
                    local texsID = 0
                    for t=1 to mdx.texs.count do 
                    (
                        if mdx.texs[t].replacableId == replacableId and mdx.texs[t].path == path then 
                        (
                            texsID = t-1
                            exit
                        )
                    )
                    writeLong mdx.stream texsID --> matching texture id
                    writeLong mdx.stream -1 #unsigned --> parentId
                    writeLong mdx.stream 0 --> uv layer
                    writeFloat mdx.stream ( mat.materialList[1].alpha / 100.0)
                )
            )
            else
            (
                writeLong mdx.stream 48 --> size 
                writeLong mdx.stream 0 --> priority
                writeLong mdx.stream 0 --> flags
                Warcraft_III_Helpers.WriteFixedString mdx.stream "LAYS" 4 
                writeLong mdx.stream 1 --> nMaps
                writeLong mdx.stream 28 --> size
                writeLong mdx.stream (mat.FilterMode - 1) --> filtermode
                
                local shadingFlags = 0
               
                if mat.unshaded then shadingFlags += 0x01
                if mat.twosided then shadingFlags += 0x10
                if mat.unfogged then shadingFlags += 0x20
                if mat.nodepthset then shadingFlags += 0x40
                if mat.nodepthtest then shadingFlags += 0x80
                if mat.unselectable then shadingFlags += 0x100
                
                writeLong mdx.stream shadingFlags
                
                local replacableId = mat.ReplaceableTexture
                local path = mat.diffuse_map.fileName
                if ( path == undefined ) then path = ""
                
                local texsID = 0
                for t=1 to mdx.texs.count do 
                (
                    if mdx.texs[t].replacableId == replacableId and mdx.texs[t].path == path then 
                    (
                        texsID = t-1
                        exit
                    )
                )
                writeLong mdx.stream texsID --> matching texture id
                writeLong mdx.stream -1 #unsigned --> parentId
                writeLong mdx.stream 0 --> uv layer
                writeFloat mdx.stream ( mat.alpha / 100.0)
               
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
            for g in geo.GNDX do writeByte mdx.stream g
            
            Warcraft_III_Helpers.WriteFixedString mdx.stream "MTGC" 4
            writeLong mdx.stream geo.MTGC.count
            for m in geo.MTGC do writeLong mdx.stream m
                
            Warcraft_III_Helpers.WriteFixedString mdx.stream "MATS" 4
            writeLong mdx.stream geo.MATS.matrices.count
            for m in geo.MATS.matrices do writeLong mdx.stream (m - 1)
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
    function Export file=
    (
        clearlistener()
        struct mdx800 ( file, stream, seqs, glbs, mtls, texs, geos, geoa, boneList )
        local mdx = mdx800()
        local export = WC3_MDX800_EXPORTER()
        
        -- set the T-pose of the object to export correctly
        local animationInterval = animationrange
        animationrange = interval 0 100
        slidertime = 0

        mdx.file = file
        mdx.stream = fOpen file "wb"
        
        Warcraft_III_Helpers.GetBoneList mdx --> required to make the weights etc... does not yet get the animation data
        
        Warcraft_III_Helpers.GetSEQS mdx
        Warcraft_III_Helpers.GetGLBS mdx
        Warcraft_III_Helpers.GetMTLS mdx
        Warcraft_III_Helpers.GetTEXS mdx
        Warcraft_III_Helpers.GetGEOS mdx
        Warcraft_III_Helpers.GetGEOA mdx
        
        if WC3_MDX800_DEBUG then MDX_EXPORT = mdx
        
        export.WriteMDLX800 mdx
        export.WriteMODL800 mdx
        export.WriteSEQS800 mdx
        export.WriteGLBS800 mdx
        export.WriteMTLS800 mdx
        export.WriteTEXS800 mdx
        export.WriteGEOS800 mdx
        export.WriteGEOA800 mdx
        
        fFlush mdx.stream
        fClose mdx.stream
        animationrange = interval animationInterval.start animationInterval.end
        gc() 
    )
)
-- WC3_MDX800_EXPORTER.Export @"F:\Blizzard\Warcraft - Reforged\Warcraft III\Spartan Warrior\Spartan Warrior\Medivh_export.mdx"
-- WC3_MDX800_EXPORTER.Export @"F:\Blizzard\Warcraft - Reforged\Warcraft III\Spartan Warrior\Spartan Warrior\SpartanWarrior_Exported.mdx"