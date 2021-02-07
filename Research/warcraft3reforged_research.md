
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

## Color Animation

This chunk contains animation based on a color.

|Chunk size| Description|
|--|--|
|int| Number of Points|
|int| Line Type|
|int| Parent ID|

For each Point:

|Chunk size| Description|
|--|--|
|int| Keyframe, based on 1000 FPS, convert this to 30 FPS|
|3 x float | Value at this keyframe|

            NOTE: the values for the color need to be multiplied by 255 to have an actual rbg value

If the **Line Type** is higher then 1, it also contines a tangent transition specifier (rarely used in the mdx files)

|Chunk size| Description|
|--|--|
|4 byte float| Tangent transition for the In part|
|4 byte float| Tangent transition for the Out part|

## Int Animation

his chunk contains animation based on a integer.

|Chunk size| Description|
|--|--|
|int| Number of Points|
|int| Line Type|
|int| Parent ID|

For each Point:

|Chunk size| Description|
|--|--|
|int| Keyframe, based on 1000 FPS, convert this to 30 FPS|
|int | Value at this keyframe|

If the **Line Type** is higher then 1, it also contines a tangent transition specifier (rarely used in the mdx files)

|Chunk size| Description|
|--|--|
|4 byte float| Tangent transition for the In part|
|4 byte float| Tangent transition for the Out part|

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

Always size 4 bytes containing the version of the mdx file, this script handles version 900 (beta version) & 1000 (retail)

### MODL

Always 372 bytes ( no other size encountered so far ) containing the basic info of the model.

|Name | Size
|--|--|
|File Name|80 bytes characters
|External Animation File reference|260 bytes ( not used imho)
|Unk| 4 bytes
|Bounding box| 24 bytes ( 2x 3 floats) that contain the max and min points of the bounding box
|150| 4 bytes containing the integer 150 ( Always 150 up till now )

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
|Size|int
|Priority plane|int
|Flags|int
|Shader Name|80 bytes characters ( usually *Shader_HD_DefaultUnit*)|
|4 bytes| containing the name LAYS|
|int| Number of layers available|

    Flags
        0x00 None
        0x01 ConstantColor unlit
        0x02 Two Sided
        0x10 Sort Primitives by Far Z
        0x20 Full Resolution ( no mipmaps used)

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
|int| Number of layers
|int| Layer Size ( without animation this block is 52 bytes)
|int| Filter Mode (see previous list)
|int| Shading Flag (see previous list)
|int| Texture ID pointing to the texture in the textures list
|int| Texture Animation ID ( -1 if no animated texture )
|int| CoordID ( usually 0 )
|float| Alpha ( usually 1 )
|float| Emissive Strength ( usually 1 )
|3 x float| Fresnel Color ( usually 1,1,1 )
|float| Fresnel Opacity ( usually 0 )
|float| Fresnel TeamColor ( usually 0 )

If the Layer size exceeds 52 bytes, then it has texture floated animation defined on it, both KMTA and KMTE chunks. See **Float Animation** on how to read this data chunk.

|Name|Description|Type
|--|--|--
|KMTA|Key Matrial Texture Alpha|Float Animation
|KMTE|Key Material Texture Emission|Float Animation

### TEXS

Each chunk is 268 bytes

|Chunk size| Description|
|--|--|
|Replaceable Id|int
|260 byte characters| Full pathname of the texture|
|4 byte int| Replaceable Id Flags usually 3|

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

Bone groups: nbr of bones in this group

nMatrixGroups: 4 byte int; indicating the nbr of Matrix groups

MatrixGroups: nMatrixGroups time int (4 bytes each) usually always a 1 for each

#### 8. MATS

Material references

|Name|Size|Desc|
|--|--|--|
|nMaterials             |int| indicating the nbr of Material references, looks more like the number of bones in this mesh
|material reference     |nMaterials x int| is an ascending numbering going up to the nbr of nMaterials
|Material Reference Id  |int|referencing the Material ID in MTLS
|Section Group Id       |int|usually ZERO
|sectionGroupType       |int|usually ZERO
|LOD ID                 |int| Level Of Detail (starting by ZERO)
|LOD Name               |80 bytes| Name of the mesh/material
|Bounds Radius          |float|usually ZERO
|Bounding Box ?         | 6 x float|usually ZERO
|Extents ?              |int| usually ZERO

#### 9. TANG

Tangents

|Name|type|desc
|--|--|--
|nTangents|int| indicating the nbr of Tangents
|Tangents|nTangents times 4 floats ( 4 bytes each )

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
|Animation block| See animation block for info
|Collision Type|4 byte int |
|Position| 3 x 4 byte floats|
|Radius| 4 byte float|
|Height| 4 byte float|
|Unknown| 4 byte float (always zero ?) |

    Collision Type
        0x0 Cube
        0x1 Plane
        0x2 Sphere
        0x3 Cylinder

Animation block consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type

### BPOS

Binding position or initial object transformation

|Name|Size|
|--|--|
|Nbr of binding positions|4 byte int |
|Transformation Matrix|A 3 x 4 matrix containing 4 rows and 3 items per row, each item is 1 float -> 12 floats in total|

### GEOA

Visibility or alpha animation of the geometry meshes

Total Size = 28 bytes * the number of meshes ( if there is no additional KGOA animation)

|Name|Size|
|--|--|
|Size|4 byte int -> 28 if there is no KGAO animation|
|Alpha|float|usually 1.0
|Flags|int|usually 0
|Color|3 x float|usually 1.0, 1.0, 1.0
|Mesh Reference Id|4 byte int referencing the mesh in the GEO chunk|

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

Animation block consists of 6 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KPPE|Keys for popcorn particle Emission|Float Animation Type
|KPPA|Keys for popcorn particle Alpha|Float Animation Type
|KPPV|Keys for popcorn particle Visibility|Float Animation Type
|KPPC|Keys for Popcorn Particle Color|Color Animation Type
|KPPL|Keys for Popcorn Particle Lifespan |Float Animation Type
|KPPS|Keys for Popcorn Speed|Float Animation Type

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

Contains the data for the ribbon emitter.

|Name|Size|
|--|--|
|Total Size|int
|Header Size|int
|Name|80 bytes characters
|Id|int
|Parent Bone Id|int
|Flag|int (=16384)
|Animation Block| see Animation block
|Height Above|float
|Height Below|float
|Alpha|float
|Color|3 float
|Life Span|float
|Texture Id|int
|Emission Rate|int
|Flipbook Rows|int
|Flipbook Columns|int
|Material Id|int
|Gravity|float
|Additional Animation block| see additional ribbon animations

Animation block: consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type

Ribbon animations: consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KRHA|Key Ribbon Height Above|Float Animation Type
|KRHB|Key Ribbon Height Below|Float Animation Type
|KRAL|Key Ribbon Alpha|Float Animation Type
|KRCO|Key Ribbon Color|Color Animation Type
|KRTX|Key Ribbon Texture|Int Animation Type
|KRVS|Key Ribbon Visibility|Float Animation Type

### PRE2

Contains the definition of a particle emmitter version 2 ( Reforged )

|Name|Size|
|--|--|
|Total Size|int
|Header Size|int
|Name|80 bytes characters
|Id|int
|Parent Bone Id|int
|Flag Settings   | see bit wise settings descriptions
|Animation block | see animation block
|Speed        |float
|Variation    |float
|ConeAngle    |float
|Gravity      |float
|Lifespan     |float
|Emissionrate |float
|Length       |float
|Width        |float
|EmitterType  |int
|RowCount     |int
|ColCount     |int
|ParticleType |int
|TailLength   |float
|MidTime      |float
|StartColor   |3 x float * 255
|MidColor     |3 x float * 255
|EndColor     |3 x float * 255
|StartAlpha   |byte
|MidAlpha     |byte
|EndAlpha     |byte
|StartSize    |float
|MidSize      |float
|EndSize      |float
|StartLifespanUVAnim  |int
|MidLifespanUVAnim    |int
|EndLifespanUVAnim    |int
|StartDecayUVAnim     |int
|MidDecayUVAnim       |int
|EndDecayUVAnim       |int
|StartTailUVAnim      |int
|MidTailUVAnim        |int
|EndTailUVAnim        |int
|StartTailDecayUVAnim |int
|MidTailDecayUVAnim   |int
|EndTailDecayUVAnim   |int
|BlendMode            |int
|TextureId            |int
|ReplacableTextureId  |int 
|PriorityPlane        |int
|Particle Emitter Animation Block| See Particle Emitter Animation block

        Priority Plane
            BASE   = 0x0
            PLANE  = 0x1
            SPHERE = 0x2
            SPLINE = 0x3

Animation block: consists of 3 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KGTR|Transformation|Vector 3 Animation Type
|KGRT|Rotation|Quaternian Animation Type
|KGSC|Scale|Vector 3 Animation Type

Particla Emitter Animation block: consists of 2 possible animation types, possible that this is not even present

|Name| description| Type|
|--|--|--|
|KP2V|Key Particle Emitter v2 Visibility|Float Animation Type
|KP2E|Key Particle Emitter v2 Emission|Float Animation Type

#### Bit Wise Flag description

When the bit is availble the following setting are true

    0x00000001	DONT_INHERIT_TRANSLATION
    0x00000002	DONT_INHERIT_SCALING
    0x00000004	DONT_INHERIT_ROTATION
    0x00000008	BILLBOARDED
    0x00000010	BILLBOARD_LOCK_X
    0x00000020	BILLBOARD_LOCK_Y
    0x00000040	BILLBOARD_LOCK_Z
    0x00000080	GENOBJECT_MDLBONESECTION
    0x00000100	GENOBJECT_MDLLIGHTSECTION
    0x00000200	GENOBJECT_MDLEVENTSECTION
    0x00000400	GENOBJECT_MDLATTACHMENTSECTION
    0x00000800	GENOBJECT_MDLPARTICLEEMITTER2
    0x00001000	GENOBJECT_MDLHITTESTSHAPE
    0x00002000	GENOBJECT_MDLRIBBONEMITTER
    0x00004000	PROJECT
    0x00008000	UNSHADED
    0x00010000	SORT_PRIMITIVES_FAR_Z
    0x00020000	LINE_EMITTER
    0x00040000	PARTICLE_UNFOGGED
    0x00080000	PARTICLE_USE_MODEL_SPACE
    0x00100000	PARTICLE_INHERIT_SCALE
    0x00200000	PARTICLE_INSTANT_VELOCITY_LIN
    0x00400000	PARTICLE_0XKILL
    0x00800000	PARTICLE_Z_VELOCITY_ONLY
    0x01000000	PARTICLE_TUMBLER
    0x02000000	PARTICLE_TAIL_GROWS
    0x04000000	PARTICLE_EXTRUDE
    0x08000000	PARTICLE_XYQUADS
    0x10000000	PARTICLE_PROJECT
    0x20000000	PARTICLE_FOLLOW

The remaining bytes of this chunk are skipped ( for now)
