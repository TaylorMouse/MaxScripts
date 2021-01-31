
# Warcraft 3 Reforged mdx format

This document describes mdx structure of the 3D models of Blizzards Warcraft III Reforged files. To keep it software agnostic, no code will be used during the explanation. 

Code for importing these models in 3D Studio Max 2011 and above, can be found in [my max scripts](https://github.com/TaylorMouse/MaxScripts)


    FLAG Values
      Bone              256
      Light             512
      Event            1024
      Attachment       2048
      ParticleEmitter  4096
      PopCornEffect    4096 
      CollisionShape   8192
      RibbonEmitter   16384

## Float Animation

This chunk contains animation based on a float.

|Chunk size| Description|
|--|--|
|4 byte int| Number of Points|
|4 byte int| Line Type|
|4 byte int| Parent ID|

For each Point:

|Chunk size| Description|
|--|--|
|4 byte int| Keyframe, based on 1000 FPS, convert this to 30 FPS|
|4 byte float| Value at this keyframe|

If the **Line Type** is higher then 1, it also contines a tangent transition specifier (rarely used in the mdx files)

|Chunk size| Description|
|--|--|
|4 byte float| Tangent transition for the In part|
|4 byte float| Tangent transition for the Out part|

## Vector 3 Animation

This chunk contains animation based on a 3 floats, representing a Vector 3.

|Chunk size| Description|
|--|--|
|4 byte int| Number of Points|
|4 byte int| Line Type|
|4 byte int| Parent ID|

For each Point:

|Chunk size| Description|
|--|--|
|4 byte int| Keyframe, based on 1000 FPS, convert this to 30 FPS|
|vector 3| 3 floats as vector 3 for the value at this keyframe|

If the **Line Type** is higher then 1, it also contines a tangent transition specifier (rarely used in the mdx files)

|Chunk size| Description|
|--|--|
|4 byte float| Tangent transition for the In part|
|4 byte float| Tangent transition for the Out part|

## Quaternian Animation

This chunk contains animation based on a 4 floats, representing a quaternian.

|Chunk size| Description|
|--|--|
|4 byte int| Number of Points|
|4 byte int| Line Type|
|4 byte int| Parent ID|

For each Point:

|Chunk size| Description|
|--|--|
|4 byte int| Keyframe, based on 1000 FPS, convert this to 30 FPS|
|Quaternian| 4 floats as quat for the value at this keyframe|

If the **Line Type** is higher then 1, it also contines a tangent transition specifier (rarely used in the mdx files)

|Chunk size| Description|
|--|--|
|4 byte float| Tangent transition for the In part|
|4 byte float| Tangent transition for the Out part|

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

    Filter Mode
      0x0: none
      0x1: transparent
      0x2: blend
      0x3: additive
      0x4: add alpha
      0x5: modulate
      0x6: modulate 2x
      0x7: fallback
            
    Shading Flag
      0x1: unshaded
      0x2: sphere environment map
      0x4: Wrap Width
      0x8: Wrap Hieght
      0x10: two sided
      0x20: unfogged
      0x40: no depth test
      0x80: no depth set               
      0x100: Fallback

|Chunk size| Description|
|--|--|
|4 byte int| Layer Size|
|4 byte int| Filter Mode (see previous list)|
|4 byte int| Shading Flag (see previous list)|
|4 byte int| Texture ID pointing to the texture in the textures list|
|4 byte int| Texture Animation ID|
|32 bytes  | Unknown|

If the Layer size exceeds 52 bytes, then it has texture floated animation defined on it, both KMTA and KMTE chunks. See **Float Animation** on how to read this data chunk.

- KMTA: Alpha animation of the texture.
- KMTE: Unused -> Emission maybe ?

### TEXS

Each chunk is 268 bytes

|Chunk size| Description|
|--|--|
|4 byte int| Replaceable Id|
|260 byte characters| Full pathname of the texture|
|4 byte int| Flags usually 3|

    Replaceable Id
    0: a texture
    1: presumably a color of some kind, no texture name found

### GEOS

This chunk contains the geometry sets.

The 4 first bytes contain the size of the chunk and each chunk is split into 11 different subchunks.

#### 1. VRTX

Vertices

nVerts: 4 byte int; indicating the nbr of vertices

Vertex Coordinates: nVerts times 3 floats ( 4 bytes each )

#### 2. NRMS

Normals

nNormals: 4 byte int; indicating the nbr of normals

Normal Coordinates: nNormals times 3 floats ( 4 bytes each )

#### 3. PTYP

Types

nTypes: 4 byte int; indicating the nbr of types, usually only 1

Types: nTypes int ( 4 bytes each ) usually type = 4

      0: points
      1: lines
      2: line loop
      3: line strip
      4: triangles
      5: triangle strip
      6: triangle fan
      7: quads
      8: quad strip
      9: polygons

#### 4. PCNT

Primitive Corners: probably the number of submeshes, usually 1, with n being the number of faces ( not indices )

nPrimitiveCorners: 4 byte int; indicating the nbr of Primitives

PrimitiveCorners: nPrimitives times int ( 4 bytes each )

#### 5. PVTX

Indices

nIndices: 4 byte int; indicating the nbr of Indices

Indices: nIndices / 3 times 3 shorts ( 2 bytes each )

#### 6. GNDX

Groups, usually 0

nGroups: 4 byte int; indicating the nbr of Groups

Groups: nGroups times a byte

#### 7. MTGC

Bone groups: nbr of bones in each group

nMatrixGroups: 4 byte int; indicating the nbr of Matrix groups

MatrixGroups: nMatrixGroups time int (4 bytes each) usually always a 1 for each

#### 8. MATS

Material references

nMaterials: 4 byte int; indicating the nbr of Material references

material reference: nMaterials times int (4 bytes each)

Material Reference Id : 4 byte int; referencing the Material ID in MTLS

Unkown: 8 bytes all zero

LOD level: 4 bytes int; pointing to the LOD (starting by ZERO)

Material Name: 80 bytes character

Unknown: 7 floats usually zero

Unkown: 4 byte int

    NOTE: This is gonna be a pain to write out :(!

#### 9. TANG

Tangents

nTangents: 4 byte int; indicating the nbr of Tangents
Tangents: nTangents times 4 floats ( 4 bytes each )

#### 10. SKIN

Bone and vertex weights

For each vertex there are 4 bone indices and 4 vertex weights, where the vertex weights are compressed.

nBoneWeights: 4 byte int; indicating the size of the chunk

Bone & Weights: nBoneWeights / 8 times 8 unassigned bytes where the 4 first bytes indicate the bone indices and the next 4 bytes the weights ( that you need to devide by 255.0 to get to the weight alue )

    NOTE The devision by 255.0 may result in total sum not equal to 1.0, this has to be corrected to 1.0 to prevent weird vertex weighting!

#### 11. UVAS

UV Coordinate Sets

A mesh can have multiple coordination sets, for example for decals. Each set has a header being UVBS

nUVSets: 4 byte int; indicating the nbr of UV Coordinate Sets

UV subset: nUVSets times a UVBS chunk

##### UVBS chunk

UVBS: 4 byte chars containing this chunk name
nUVBS: 4 byte int; indicating the number of UV texture coordinates

UV Texture Coordinates: nUVBS times 2 floats ( 4 bytes each)

    NOTE: There is no W coordinate, which is required in some programs, set it to 0.0!

### BONE

|Name|Size|
|--|--|
|Size|4 byte int|
|Name|80 bytes characters|
|Id|4 byte int|
|Parent Bone Id|4 byte int ( -1 indicates no parent )|
|Flag |4 byte int (= 256)|
|Animation block|Size - 80 - 12 bytes |
|FFFF|4 byte int (always FFFF)|

    Animation block If the animation block reads 4 bytes being FFFF, no animation is available furter available.

Animation block consists of 3 possible animation types:

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type

When building the bones in 3D Studio Max, first build the bones, then build the hierarchy, then apply the rotation, then the translation.

### ATCH

Attachment or hardpoints, for a full list of attachment points, refer to the offical [Warcraft II Art Tools Documentation]().

|Name|Size|
|--|--|
|Total Size|4 byte int (including these 4 bytes)|
|Header Size|4 byte int  value 96 |
|Name|80 bytes characters|
|Id|4 byte int|
|Parent Bone Id|4 byte int ( -1 indicates no parent )|
|Flag|4 byte int (= 2048)|
|Animation block|Size - 80 - 20 bytes |

Animation block consists of 4 possible animation types:

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type
|KGTV|Visibility|Float Animation Type

### CLID

Collision Identifiers or Collision objects

|Name|Size|
|--|--|
|Size|4 byte int |
|Header Size|4 byte int value 96 |
|Name|80 bytes characters|
|Id|4 byte int|
|Parent Bone Id|4 byte int ( -1 indicates no parent )|
|Flag|4 byte int (= 8192)|
|Animation block|x size|

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type

|Name|Size|
|--|--|
|Collision Type|4 byte int |
|Position| 3 x 4 byte floats|
|Radius| 4 byte float|
|Height| 4 byte float|
|Unknown| 4 byte float (always zero ?) |

### BPOS

Binding position or initial object transformation

|Name|Size|
|--|--|
|Nbr of binding positions|4 byte int |
|Transformation Matrix|A 3 x 4 matrix containing 4 rows and 3 items per row, each item is 1 float -> 12 floats in total|

### GEOA

Visibility or alpha animation of the geometry meshes

|Name|Size|
|--|--|
|Size|4 byte int |
|Unknown| 5 x 4 byte float|
|Mesh Reference Id|4 byte int referncing the mesh in the GEO chunk|

Animation block consists of 1 possible animation types:

|Name| description| Type|
|--|--|--|
|KGAO|Alpha Object animation|Float Animation Type

### EVTS

For a full understanding of this block, please refer to the official [Warcraft III Art Tools Documentation]() see the Event Objects documentation.

|Name|Size|
|--|--|
|Size|4 byte int |
|Name|80 bytes characters|
|Id|4 byte int|
|Parent Bone Id|4 byte int ( -1 indicates no parent )|
|Flag|4 byte int (= 1024)|
|KEVT| 4 bytes characters Keyed events, frames on which the event takes place|

#### KEVT

|Name|Size|
|--|--|
|Number of Keys|4 byte int |
|Parent ID|4 byte int|
|Keys| Nbr of Keys x 4 byte int representing the fema where the event takes place|

### PIVT

Weird chunk that holds pivot points, referencing an id that points to all previous id's read in the file.

Number of points = this chunk size / 12

|Name|Size|
|--|--|
|Points| nbr of points x 3 x 4 byte floats representing a position of the pivot point|

### FAFX

Facial Effects, referencing an external file

Number of effects = this chunk size / 340

|Name|Size|
|--|--|
|Name| 80 byte characters|
|External File reference| 260 byte characters|

### CAMS

|Name|Size|
|--|--|
|Size|4 byte int |
|Name|80 bytes characters|
|Camera Position| 3 x 4 byte floats
|FOV| 4 byte float in radians
|Far Clipping| 4 byte float 
|Near Clipping| 4 byte float
|Camera Target position|3 x 4 byte floats
|Animation block||

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KCTR|Keys for Camera Transformation|Vector 3 Animation Type
|KTTR|Keys for Target Transformation|Vector 3 Animation Type
|KCRL|Keys for Camera Rotation|Quaternian Animation Type

### CORN

Popcorn effect, weird naming for referencing an external effect. Usually only available in hero models, like a hero glow effect.

|Name|Size|
|--|--|
|Total Size|int
|Header Size|int
|Name|80 bytes characters
|Id|int
|Parent Id|int
|Flag|int = 4096
|Animation block|

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KGTR|Keys for Tranlation in world space|Vector 3 Animation Type
|KGRT|Keys for Rotation in world space|Quaternian Animation Type
|KGSC|Keys for Scale in world space|Vector 3 Animation Type

|Name|Size|
|--|--|
|External file name|260 byte characters
|Properties|260 byte characters, these are comma seperated properties
|Animation block|

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KPPE|Keys for popcorn particle emission|Float Animation Type
|KPPA|Keys for popcorn particle alpha attenuation|Float Animation Type
|KPPV|Keys for popcorn particle visibility or speed|Float Animation Type

### LITE

Contains data about lights.

    Light Types
      0x0: Omni
      0x1: Directional
      0x2: Ambient
      0x3: Default

|Name|Size|
|--|--|
|Total Size|int
|Header Size|int
|Name|80 bytes characters
|Id|int
|Parent Id|int
|Flag|int = 4096
|Animation block||
|Light Type|int|
|Far Attenuation|float
|Near Attenuation|float
|Color|3 floats
|RGB Intensity|float
|Ambient Color|3 floats
|Ambient Intensity|float

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type

### GLBS

Global frames ?

Number of globals = Chunk Size / 4 ( each global bein an int)

A global represent a frame in a 1000FPS rate

### TXAN

Contains texture animation, this is being referenced by the LAYS Texture Animation ID

|Name|Size|
|--|--|
|Size|int
|Animation block|

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KTAT|Key Texture Animation Transformation|Vector 3 Animation Type
|KTAR|Key Texture Animation Rotation|Quaternian Animation Type
|KTAS|Key Texture Animation Scale|Vector 3 Animation Type

### RIBB

    TODO

### PRE2

    TODO
