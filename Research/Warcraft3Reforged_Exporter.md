# Warcraft 3 Reforged Exporter

Written by Taylor Mouse

This document describes how to use the Exporter.
The exporter for 3D Studio Max 2011 and above, can be found in [my max scripts](https://github.com/TaylorMouse/MaxScripts)

## <span style="color:#0090ff">Textures</span>

The textures used in Warcraft 3 Reforged are PBR textures or Physical Based Rendered textures.

### <span style="color:#0090ff">Diffuse or Albedo map</span>

Although the game still uses diffuse as a suffix in the name of their texture, it is in fact a albedo map. An albedo map (in comparason of a diffuse map) does not contain any lighting information.

The alpha channel of this texture is used as the **transparent mask**.

- White color no mask, will be fully drawn
- Black color is the mask, will not be drawn

Save this map as a DXT5 dds file.

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

### <span style="color:#0090ff">Emissive map</span>

Use the standard Black32.dds if you do not use an emissive map.

### <span style="color:#0090ff">Alpa map</span>

The alpha map can come from a specific texture, but is usually from the albedo's alpha texture.

### <span style="color:#0090ff">Reflection map</span>

This is a cubic or spherical reflection texture. Use the standard Environment Map from the game.

### <span style="color:#0090ff">Reflection map</span>

Leave this to none or open if not used.