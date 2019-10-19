# Warcraft 3 Reforged
Model structure description

## TAGS

The file is split into different TAGS.
Except from the very first main tag, every tag is defined with a 4 Character string followed by its size.

The following list shows the possible tags found at this time:
```
    MDLX // Main tag
    VERS // Version
    MODL // Model info
    SEQS // Animation sequences
    MTLS // Materials
    TEXS // Textures
    GEOS // Geometry
    GEOA // Geometry animation
    BONE // Bones
    ATCH // Attachments
    PIVT // Pivot 
    CAMS // Camera
    EVTS // Events
    CLID // Colission Definition
    BPOS // Binding Position
    FAFX // Facial FX
    LITE // Lights
    PRE2 // Particle Emitters
    CORN // Corners
    RIBB // Ribbons
```
```c#
struct TAG
(
    string Name
    long Offset
    int Size
)
```

Once you have the Tags, you can loop through them one by one to read them. Use the offset to jump to the position in the file.
## MDLX
Four character string containing the MDLX identifier

## VERS
```c#
struct VERS
(
   int Version
)
```
Version is 900 for reforged. NOTE: Warcraft 3 Orginal version was 800, although comparable not completely compatible.

## MODL
```c#
struct MODL
(
    string Name /* 80 characters fixed length */
    Vector3 PointA
    Vector3 PointB
    int Unk
)
```
The offset of PointA is calculated by tagSize - 80 - 28.

## SEQS

```c#
struct SEQS
(
    string Name /* 80 characters */
    int StartFrame
    int EndFrame
    float MovementSpeed
    int NoLoop
    float Rarity
)
```
After those have been read, skip 8 * 4 bytes

## MTLS
```c#
struct MTLS
(
    int Id
    string ShaderName
    LAYS lays /* layers in the material (c.f: Albedo, Normal, etc) */
    int nLays
)
```
Read size and 2 unkown ints before you can get the ShaderName, the Id is not to be read from the file but is used as a reference.

```c#
struct LAYS
(
    int Id
    int FilterMode
    int ShadingFlags
    int TextureId /* maps to TEXS chunk */
    KMTA kmta /* See keyframe animation */
)
```
### FilterMode
    0: none
    1: transparent
    2: blend
    3: additive
    4: add alpha
    5: modulate
    6: modulate 2x

### ShadingFlag
    0x1: unshaded
    0x2: sphere environment map
    0x4: ?
    0x8: ?
    0x10: two sided
    0x20: unfogged
    0x30: no depth test
    0x40: no depth set               

### Keyframe Animation 
Different keyframe animations found so far:
```c#
    - KGTR /* Keyframe Global Transform or position */
    - KGRT /* Keyframe Global Rotation */
    - KGSC /* Keyframe Global Scale */
    - KATV /* Keyframe Animation Track View */
    - KMTA /* Keyframe Main Texture Animation */
```
After reading the animation tag (cfr. KGTR, KGRT, ... ) the chunck containts first the number of Keys, then the Line Type, then FFFF, and then the actual animation starting with the time and then a point.
The point can be of type Vector3 (KGTR), Quaternian (KGRT) or Float (KGSC, KATV, KMTA).
If the LineType > 1 it also contains a in and out Tangent transition.

## TEXS
Note, the textures are in their original extension, .tiff, .png, ... you need to convert this to .dds.
```c#
struct TEXS
(
    int Id
    int ReplacableTextureId /* 0 or 1 ?? */ 
    string name /* relative texture path, size 260 */
    int Flags

)
```
## GEOS
