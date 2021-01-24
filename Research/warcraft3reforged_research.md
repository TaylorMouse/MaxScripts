
# Warcraft 3 Reforged mdx format

## TAGS

Every tag is followed by its size in bytes, except the first 4 bytes, that holds the main tag being MDLX. The following explains the different tags and their build up.

### VERS

Version of the file, this script handles version 900 & 1000

- 4 bytes

### MODL

Basic info of the model.

- 372 bytes ( no other size encountered so far )
- First 344 bytes:
  - 80 bytes containing the name of the file without extension
  - skip the rest containing zeroes ( skipped these when reading)
- 24 bytes ( 2x 3 floats) that contain the max and min points of the bounding box
- 4 bytes containing the integer 150 ( Always 150 up till now )

### SEQS

Animation sequences, being 132 bytes per animation sequence. The number of sequences is calculated by taking the full size devided by 132.
Frames are in 1000 Frames Per Second, in Max they are converted to 30 FPS.

|Chunk size| Description|
|--|--|
|80 bytes| containing the Name of the sequence|
|4 byte int|Starting frame|
|4 byte int|Ending frame|
|4 byte float|Movement speed|
|4 byte int| No loop|
|4 byte float|Rarity|
|4 byte int|Default|
|4 byte float|Priority|
|24 byte floats|6 floats indicating the corners of the animation bounding box|

*NOTE: The names are not compatible with Starcraft II names and need to be converted correctly to make it work.*

### MTLS

Info about the Materials and the number of layers used, together with its shader name.
No fixed size for each chunk. Each chunk has its specific size defined at the start. Loop through it until you reach the end of its total size.
In the MTLS tag, we will find different layers, each starting with the LAYS tag

|Chunk size| Description|
|--|--|
|4 byte int| Shader Size|
|4 byte int| Priority Plane (no idea what to do with this)|
|4 byte int| unknown|
|80 bytes| conaining the name of the shader ( usually *Shader_HD_DefaultUnit*)|
|4 bytes| containing the name LAYS|
|4 byte int| Number of layers available|

#### LAYS

Settings for a layer:

    /* Filter Mode
      0x0: none
      0x1: transparent
      0x2: blend
      0x3: additive
      0x4: add alpha
      0x5: modulate
      0x6: modulate 2x
      0x7: fallback
    */
        
    /* Shading Flag
      0x1: unshaded
      0x2: sphere environment map
      0x4: Wrap Width
      0x8: Wrap Hieght
      0x10: two sided
      0x20: unfogged
      0x40: no depth test
      0x80: no depth set               
      0x100: Fallback
    */

|Chunk size| Description|
|--|--|
|4 byte int| Layer Size|
|4 byte int| Filter Mode (see previous list)|
|4 byte int| Shading Flag (see previous list)|
|4 byte int| Texture ID pointing to the texture in the textures list|
|4 byte int| Parent ID|
|32 bytes  | Unknown|

If the Layer size exceeds 52 bytes, then it has texture floated animation defined on it, both KMTA and KMTE chunks. See **Float Animation** on how to read this data chunk.

- KMTA: Alpha animation of the texture.
- KMTE: Unused -> Emission maybe ?

### Float Animation

This chunk contains animation based on a float.

|Chunk size| Description|
|--|--|
|4 byte int| Number of Points|
|4 byte int| Line Type|
|4 byte int| Parent ID|

For each Point:

|Chunk size| Description|
|--|--|
|4 byte int| Keyframe, again based on 1000 FPS, converted this to 30 FPS|
|4 byte float| Value at this keyframe|

If the **Line Type** is higher then 1, it also contines a tangent transition specifier (rarely used in the mdx files)

|Chunk size| Description|
|--|--|
|4 byte float| Tangent transition for the In part|
|4 byte float| Tangent transition for the Out part|
