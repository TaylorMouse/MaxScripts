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
        local seqs = Warcraft_III_Helpers.GetSEQS()
        writeLong mdx.stream ( 132 * seqs.count)
        
        for seq in seqs do
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
        mdx.seqs = seqs
    ),
    function WriteGLBS800 mdx=
    (
        format "Writing GLBS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "GLBS" 4
        
        local glbs = #()
        
        for obj in objects do 
        (
            if (  classof obj == WarcraftIII_Behavior) then
            (
                for b in obj.listOfBones  do
                (
                    local maxFrame =  0
                    local posStr = b.pos.controller.keys[b.pos.controller.keys.count].time as string
                    local rotStr = b.rotation.controller.keys[b.rotation.controller.keys.count].time as string
                    local scaleStr = b.scale.controller.keys[b.scale.controller.keys.count].time as string
                    
                    local posTime = substring posStr 1 (posStr.count - 1 ) as integer
                    local rotTime = substring rotStr 1 (rotStr.count - 1 ) as integer
                    local scaleTime = substring scaleStr 1 (scaleStr.count - 1 ) as integer
                    
                    if posTime > maxFrame then maxFrame = posTime
                    if rotTime > maxFrame then maxFrame = rotTime
                    if scaleTime > maxFrame then maxFrame = scaleTime
                        
                    maxFrame = maxFrame * 1000 / 30 as integer
                    append glbs maxFrame
                )
                exit
            )
        )
        if ( WC3_MDX800_DEBUG ) then print glbs
        writeLong mdx.stream (glbs.count * 4)
        for g in glbs do writeLong mdx.stream g

    ),
    function WriteMTLS800 mdx=
    (
        format "Writing MTLS\n"
        Warcraft_III_Helpers.WriteFixedString mdx.stream "MTLS" 4
        
        mdx.texs = Warcraft_III_Helpers.GetTexs()
       -- TODO : Warcraft_III_Helpers.GetMTLS mdx
        
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
    function Export file=
    (
        clearlistener()
        struct mdx800 ( file, stream, seqs, mtls, texs )
        local mdx = mdx800()
        local export = WC3_MDX800_EXPORTER()
        
        -- set the T-pose of the object to export correctly
        local animationInterval = animationrange
        animationrange = interval 0 100
        slidertime = 0

        mdx.file = file
        mdx.stream = fOpen file "wb"
        
        export.WriteMDLX800 mdx
        export.WriteMODL800 mdx
        export.WriteSEQS800 mdx
        export.WriteGLBS800 mdx
        export.WriteMTLS800 mdx
        export.WriteTEXS800 mdx
        
        
        
        fFlush mdx.stream
        fClose mdx.stream
        animationrange = interval animationInterval.start animationInterval.end
        gc() 
    )
)

WC3_MDX800_EXPORTER.Export @"F:\Blizzard\Warcraft - Reforged\Warcraft III\Spartan Warrior\Spartan Warrior\SpartanWarrior_Exported.mdx"