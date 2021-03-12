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

struct Warcraft_3_Tools_Build
(
    
)
struct Warcract_3_Tools
(
    function Import file=
    (
        fileIn "GriffonStudios_Helpers.ms"
        fileIn "GriffonStudios_Warcraft_3_Tools_Read.ms"
        
        _helper = GriffonStudios_Helpers()
        clearlistener()
        
        if ( _helper.CheckFile file == undefined ) then return undefined

        print file
        _wc3 = Warcraft_3_Tools_Read()
        struct wc3_mdx ( TAGS, VERS, MODL, SEQS, GLBS, MTLS, TEXS, GEOS, BONE, HELP, ATCH, CLID, GEOA, EVTS, PIVT, CAMS, LITE, TXAN, RIBB, PRE2)
        
        local mdx = wc3_mdx()
        
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
        
        fclose stream
        
        _helper = undefined
        _wc3 = undefined
        gc()
        
    )
    
)

_debug_read = false
Warcraft_3_Tools.Import @"D:\Downloads\Ogron\Ogron Teal\OgronTeal.Mdx"