# Warcraft 3 Reforged Tools Documentation
*©2010~2020 Griffon Studios*

*Written by Taylor Mouse*

This document describes how to use the Exporter.
The exporter for 3D Studio Max 2011 and above, can be found in [my max scripts](https://github.com/TaylorMouse/MaxScripts)

## <span style="color:#0090ff">Material</span>

In the material editor of 3D Studio Max, there is a new material type the comes with my script. It is the Warcraft 3 Reforged Material (WC3RefMaterial).

![main menu](/images/exporter_001.png)

In the exported mdx file, the maps are mapped to the default path "war3mapImported\\" this means that all textures used in the model must be added in the Asset Manager but do not require changes to the path.

The textures used in Warcraft 3 Reforged are PBR textures or Physical Based Rendered textures.

### <span style="color:#0090ff">Diffuse or Albedo map</span>

Although the game still uses diffuse as a suffix in the name of their texture, it is in fact a albedo map. An albedo map (in comparason of a diffuse map) does not contain any lighting information.

The alpha channel of this texture is used as the **transparent mask**.

- White color no mask, will be fully drawn
- Black color is the mask, will not be drawn

Save this map as a DXT5 dds file.

### <span style="color:#0090ff">Normal map</span>

Save this map as a ATI2N dds file. Without any alpha map.

#### *Photoshop CS6*

This can be achieved by saving the file via the nVidia plugin as a "3Dc XY 8 bpp | Normal Map" file with generation of Mip Maps.

#### *Photoshop 2020*

This can be achieved by saving the file as a DDS file (via Intel Texture Works) and selecting the texture type of "Normal Map" and Compression "BC5 8bpp (Liner, 2 channel tangent map)" and Auto Generate the Mip Maps

#### *GIMP*

This can be achieved by exporting the file as a DDS file and setting the Compression to "BC5 / ATI2 (3Dc)".

### <span style="color:#0090ff">ORM map</span>

ORM map stands for Occlusion, Roughness and Metallness map.

The <span style="color:tomato">Red</span> channel contains the **ambient occlusion** map.

- White color represents no shadow
- Black color represents shadow

The <span style="color:green">Green</span> channel contains the **roughness** map.

- White color represents no roughness
- Black color represents lots of roughness

The <span style="color:#0090ff">Blue</span> channel contains the **Metallness** map.

- White color represents full metal reflection
- Black color represents no metal reflection

The alpha channel of this texture is used as the **team color**.

- White color is used as the team color
- Black color is used when no team color is necessary

Save this map as a DXT5 dds file.

### <div style="color:#0090ff">Emissive map</div>

Use the standard Black32.dds if you do not use an emissive map.

Where Black is no emission, and all other colors have emission

Save this map as a DXT1 dds file.

### <span style="color:#0090ff">Alpa map</span>

The alpha map can come from a specific texture, but is usually from the albedo's alpha texture.

Save this map as a DXT5 dds file.

### <span style="color:#0090ff">Reflection map</span>

This is a cubic or spherical reflection texture. 

Use the standard Environment Map from the game.

### <span style="color:#0090ff">Replacable map</span>

Leave this to none or open if not used.