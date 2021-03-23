/*
    .COPYRIGHT
    |   (c) 2020-2021 Griffon Studios
    |   Warcraft and Warcraft III Reforged are properties of Blizzard Entertainment
    
    .AUTHOR
    |   Taylor Mouse
    
    .DESCRIPTION
    |   Warcraft III Import model
    
    .RELEASE NOTES
    | 0.03 Most of the tags have been read todo, light(LITE), texture animation (TXAN), ribbons (RIBB) a particles (PREM & PRE2)
    | 0.02 Reading all the tags
    | 0.01 Initial setup
    
    .FLAGS
        0x0: helper
        0x1: dont inherit translation
        0x2: dont inherit rotation
        0x4: dont inherit scaling
        0x8: billboarded
        0x10: billboarded lock x
        0x20: billboarded lock y
        0x40: billboarded lock z
        0x80: camera anchored
        0x100: bone
        0x200: light
        0x400 event object
        0x800: attachment
        0x1000 particle emitter
        0x2000: collision shape
        0x4000: ribbon emitter
        0x8000: if particle emitter: emitter uses mdl, if particle emitter 2: unshaded
        0x10000: if particle emitter: emitter uses tga, if particle emitter 2: sort primitives far z
        0x20000: line emitter
        0x40000: unfogged
        0x80000: model space
        0x100000: xy quad
        
*/

global _helper  = undefined
global _wc3     = undefined
global _debug_read   = false
global _debug_build  = true
global gMDX = undefined

struct Warcraft_3_Build
(
    function BuildGEOS mdx=
    (
        local geos = mdx.geos
        if (geos == undefined ) then return undefined
        
        local wireColor = color 128 128 128
        
        for geo in geos do
        (
            
            if _debug_build then format "Building %\n" geo.UniqueName
            
            local layer = _helper.CreateLayer "Unit"
            
            local v  = geo.VRTX
            local n  = geo.NRMS
            local f  = geo.PVTX
            local uv = geo.UVS[1]
            local theMesh = mesh vertices:v vnorms:n name:geo.UniqueName faces:f tverts:uv 

            theMesh.WireColor = wireColor
            
            buildTVFaces theMesh false
            for i = 1 to f.count do
            ( setTVFace theMesh i f[i] )
        
            layer.AddNode theMesh
            update theMesh
            geo.meshRef = theMesh

        )
    ),
    function BuildPIVT mdx=
    (
        
        if _debug_build then format "Building Pivots\n"
                    
        local layer = _helper.CreateLayer "PIVT"
        
        for i=1 to mdx.bone.count do
            local p = point name:mdx.bone[i].name pos:mdx.pivt[mdx.bone[i].id].position size:5
        
        for i=1 to mdx.help.count do
            local p = point name:mdx.help[i].name pos:mdx.pivt[mdx.help[i].id].position size:5
        
        for i=1 to mdx.atch.count do
            local p = point name:mdx.atch[i].name pos:mdx.pivt[mdx.atch[i].id].position size:5
        
        for i=1 to mdx.evts.count do
            local p = point name:mdx.evts[i].name pos:mdx.pivt[mdx.evts[i].id].position size:5
        
        for i=1 to mdx.clid.count do
            local p = point name:mdx.clid[i].name pos:mdx.pivt[mdx.clid[i].id].position size:5

    ),
    function BuildATCH mdx=
    (
        local atch  = mdx.atch
        local boneList = mdx.bone
        local layer = GriffonStudios_Helpers.CreateLayer "Attachments"
        format "Building Attachments\n"
        sliderTime = 0f
        
        for a in atch do 
        (
            local pnt = WC3RefAttachment name:a.name
            pnt.pos = mdx.pivt[a.id].position
            
            layer.AddNode pnt
--             if( a.parentBoneId > 0) then 
--             (
--                 local parentBone = boneList[a.parentID].boneRef
--                 if( parentBone == undefined) then
--                     parentBone = getnodebyname boneList[a.parentBoneId].name
--                 pnt.transform = parentbone.transform
--                 pnt.parent = parentBone
--             )
        )
        
    ),
    function BuildBONE mdx=
    (
        local boneList = mdx.bone
        local bpos = mdx.pivt
        local boneLayer = _helper.CreateLayer "Bones"
        
        format "Building Bones\n"
        
        for b in boneList do
        (
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.05
            aBone.Height = 0.05
            aBone.setBoneEnable false 0
            b.boneRef = aBone
            boneLayer.AddNode aBone
        )
        
        for obj in boneList do
            obj.boneRef.pos = mdx.pivt[obj.Id].position
        
        for b in boneList do
        (
            if ( b.ParentBoneId > 0 and b.ParentBoneId <= boneList.count ) then 
            (
                b.boneRef.parent = boneList[b.ParentBoneId].boneRef
            )
        )

        for objX in objects do addNewKey objX.controller 0
        
       -- apply bone animation
        local applyBoneAnim = true
        if applyBoneAnim == true then 
        for obj in boneList do
        (
            local b = obj.boneRef
            
            b.assumeSkinPose()

            if ( obj.KGRT != undefined ) then 
            (
               -- b.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                local prevTime = 0
                
                for anim in obj.KGRT.KG do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            if ( obj.KGTR != undefined ) then
            (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = b.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in obj.KGTR.KG do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point

                        if ( prevTime == t ) then continue else prevTime = t
                        
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on b.position.controller = copy dp.position.controller
                    
                    delete dp
            )
            
            if ( obj.KGSC != undefined ) then
            (
               -- b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in obj.KGSC.KG do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )
            
        )
   
    )
)

struct Warcraft_3_Main
(
    function Import file=
    (
        fileIn "GriffonStudios_Helpers.ms"
        fileIn "GriffonStudios_Warcraft_3_Read.ms"
        
        _helper = GriffonStudios_Helpers()
        clearlistener()
        
        if ( _helper.CheckFile file == undefined ) then return undefined

        print file
        
        struct wc3_mdx ( TAGS, VERS, MODL, SEQS, GLBS, MTLS, TEXS, GEOS, BONE, HELP, ATCH, CLID, GEOA, EVTS, PIVT, CAMS, LITE, TXAN, RIBB, PRE2)
        local mdx = wc3_mdx()
        
        /* Reading */
        _wc3 = Warcraft_3_Read()
        local stream = fOpen file "rb"
        mdx.tags = _wc3.ReadTags stream streamLen
        for tag in mdx.tags do
        (
            format "Processing %\n" tag

            if( tag.Name == "VERS" ) then mdx.vers = _wc3.ReadVERS stream tag
            if( tag.Name == "MODL" ) then mdx.modl = _wc3.ReadMODL stream tag
            if( tag.Name == "SEQS" ) then mdx.seqs = _wc3.ReadSEQS stream tag
            if( tag.Name == "GLBS" ) then mdx.glbs = _wc3.ReadGLBS stream tag
            if( tag.Name == "MTLS" ) then mdx.mtls = _wc3.ReadMTLS stream tag                
            if( tag.Name == "TEXS" ) then mdx.texs = _wc3.ReadTEXS stream tag
            if( tag.Name == "GEOS" ) then mdx.geos = _wc3.ReadGEOS stream tag mdx.modl
            if( tag.Name == "GEOA" ) then mdx.geoa = _wc3.ReadGEOA stream tag
            if( tag.Name == "BONE" ) then mdx.bone = _wc3.ReadBONE stream tag
            if( tag.Name == "HELP" ) then mdx.help = _wc3.ReadHELP stream tag
            if( tag.Name == "ATCH" ) then mdx.atch = _wc3.ReadATCH stream tag 
            if( tag.Name == "PIVT" ) then mdx.pivt = _wc3.ReadPIVT stream tag
            if( tag.Name == "CAMS" ) then mdx.cams = _wc3.ReadCAMS stream tag
            if( tag.Name == "EVTS" ) then mdx.evts = _wc3.ReadEVTS stream tag            
            if( tag.Name == "CLID" ) then mdx.clid = _wc3.ReadCLID stream tag

            /* TO DO */
--             -- LITE // lights
--             if( tag.Name == "LITE" ) then mdx.lite = Warcraft3_Reforged.ReadLITE stream tag
--             -- TXAN // texture animations
--             if( tag.Name == "TXAN" ) then mdx.txan = Warcraft3_Reforged.ReadTXAN stream tag
--             -- RIBB // ribbon emitters
--             if( tag.Name == "RIBB" ) then mdx.ribb = Warcraft3_Reforged.ReadRIBB stream tag
--             -- PRE2 // particle emitter
--             if( tag.Name == "PRE2" ) then mdx.pre2 = Warcraft3_Reforged.ReadPRE2 stream tag
            
        )
        gMDX = mdx
        fclose stream
        _wc3 = undefined
        
        /* Building */
        _build = Warcraft_3_Build()
        _build.BuildGEOS mdx
        _build.BuildBONE mdx
        --_build.BuildPIVT mdx
        --_build.BuildATCH mdx
        _build = undefined
        
        
        _helper = undefined
        gc()
        
    )
    
)

--Warcraft_3_Main.Import @"F:\Blizzard\Warcraft - Reforged\Warcraft III\assets\units\creeps\darktroll\darktroll.mdx"