/*
    .SYNOPSIS
    | Standard Material for Warcraft III
    
    .COPYRIGHT
    | �2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse


*/

plugin Material WarcraftIII_Standard
    name: "Warcraft III Standard"
    classID:#(0x688eec57, 0xd3f3e91)
    category:"Warcraft III"
    extends:Standard
    replaceUI:true 
    version:1
(

    parameters main rollout:maps
    (
        
        --material_alpha  type:#float      animatable:true   ui:spn_alpha
        Diffuse_Map     type:#texturemap animatable:false  ui:mb_diffuse
        Alpha  type:#float     animatable:true   ui:spn_alpha

        on Alpha set val do 
        (
            delegate.opacity = val
        )
        
        on diffuse_map set val do 
		(
            delegate.diffuseMap = diffuse_map
            if (diffuse_map != undefined ) then showTextureMap this delegate.diffusemap true
		)
    )
    parameters shader_params rollout:shader_parameters
    (
        ReplaceableTexture  type:#integer   animatable:false  ui:ddl_replaceableTexture
        TwoSided            type:#boolean   animatable:false  ui:cbx_twoSided
        Unshaded            type:#boolean   animatable:false  ui:cbx_unshaded
        Unfogged            type:#boolean   animatable:false  ui:cbx_unfogged
        Nodepthset          type:#boolean   animatable:false  ui:cbx_noDepthSet
        Nodepthtest         type:#boolean   animatable:false  ui:cbx_noDepthTest
        Unselectable        type:#boolean   animatable:false  ui:cbx_unselectable
        
        on TwoSided set val do 
        (
            delegate.TwoSided = val
        )
    )
    
    parameters extended_params rollout:extended_parameters
    (
        FilterMode type:#integer animatable:false ui:lb_filterMode


    )        
    
    rollout shader_parameters "Shader Basic Parameters"
    (
        label lbl_shaderType "Shader: Blinn" align:#left
        dropdownlist ddl_replaceableTexture          items:#( "Not Replacable","Team Color","Team Glow") width:120 offset:[0,20]
        checkbox cbx_unshaded "Unshaded"            tooltip: "This option causes the material to be fully lit and ignore light sources" offset:[130,-60]
        checkbox cbx_noDepthSet "No depth set"      tooltip: "The object's polygons will not write to the depth buffer. This option is ignored when using Additive, Alpha, Modulate, and Modulate 2X blend modes" offset:[130,-2]
        checkbox cbx_noDepthTest "No depth test"    tooltip: "The object's polygons will not test the sort order from the depth buffer." offset:[130,-2]
        checkbox cbx_twoSided "2 Sided"             tooltip: "The polygons will always draw and not use backface culling. The lighting is determined by the one normal for the faces, so one side will always shade incorrectly." offset:[230,-55]
        checkbox cbx_unfogged "Unfogged"            tooltip: "An unfogged geoset will ignore darkening from distance fog." offset:[230,0]
        checkbox cbx_unselectable "Unselectable"    tooltip: "A geoset that is flagged as unselectable is ignored for hit-test collision testing" offset:[230,0]
        
        
        on ddl_replaceableTexture selected selectedItem do
        (
            if (selectedItem == 2) then
            (
                cbx_unshaded.checked = true
                
            )
        )
    )
    
    rollout basic_parameters "Blinn Basic Parameters"
    (
        checkbox cbx_useColor "Color"
        colorpicker cp_selfIllumination offset:[50,-22] visible:false color:[0,0,0]
        
        
        on cbx_useColor changed theState do
        (
            cp_selfIllumination.visible = theState
        )

    )
    
    rollout extended_parameters "Advanced Transparency"
    (
        radiobuttons lb_filterMode labels:#("Opaque","2 Color Alpha","Full Alpha", "Additive", "Modulate", "Modulate 2X") \
                                   tooltip:#("The geoset draws as solid, with no blend to the frame buffer.", \
                                             "The geoset draws as solid except for regions over which the texture map alpha channel is black, where the geoset is completely transparent. The cutoff from transparent to solid is 75% white in the alpha channel. This blend mode can have a fixed or animating opacity channel.",\
                                             "Standard blend mode using an 8-bit alpha channel texture and/or opacity channel. Depth set is turned off. Draw order is in the transparent queue. Overlapping tris can cause errors in sort order. This is the slowest-drawing blend mode.", \
                                             "The geoset adds its RGB values to the frame buffer, causing a ghost-like glowing effect. Most spells use this to make glowing effects. Depth set is turned off. Draw order is in the transparent queue. No sort order errors with its own geoset.", \ 
                                             "The geoset multiplies its RGB values to the frame buffer, making a semi-transparent darkening of the background. Depth set is turned off. Draw order is in the transparent queue. Opacity has no effect. No sort order errors with its own geoset.", \
                                             "The geoset first doubles its initial RGB values, then multiplies them against the frame buffer. This technique causes both brightening and darkening in one pass. Depth set is turned off. Draw order is in the transparent queue. Opacity has no effect. No sort order errors with its own geoset")
        
        
    )

    rollout maps "Maps"
    (
        mapbutton mb_diffuse "(drag & drop texture here)" height:25 width:300 
        
        spinner spn_alpha  "Opacity :" range:[0,100.0,100.0] width:60 align:#left  
    
        
    )
    

    
    on create do
    (
        replaceableTexture = 1
        material_alpha = 100.0
        diffuse_map = Bitmaptexture fileName:""
    )
    
    
)

