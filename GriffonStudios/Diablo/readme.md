# Diablo Immortal

## Description

3D Studio Max script that imports a static 3D mesh from Blizzard's Diablo Immortal game.

## Chunk Types

|Name|Description|Status|
|--|--|--|
|P3F|Point 3 Float, position of the vertices|Read
|W4B_I4B|Vertex weights 4 bytes compressed, Bone indices 4 bytes|Not read in the script
|Q4H_T2H|Q(uat) ? 4 Half Floats and Texture Coordinates 2 Half Floats|Uv's are read
|Q4H_T2H_T2H|Q(uat) ? 4 Half Floats and 2 pari of Texture Coordinates 2 Half Floats|Uv's are read
|P3F_N4B_T2F|Point 3 Floats for position of the vertices, Normals 4 Bytes compressed, Texture Coordinate 2 floats|Read
|N4B_T2H_T2H|Normals 4 Bytes compressed, 2 pair of Texture Coordinate 2 floats|Read

## Supported fileformat
- .mesh

### Examples
![diablo import example](../../images/diablo_immortal_screen_01.png)

## How to get the models

Use the following tool to download, extract and decode the content of the game:

[Diablo Immortal Data Tool](https://github.com/CucFlavius/DIDT)

First download the Apple/Android version of the game via the first tab.
Then go to the second tab and hit the sort button, then hit the decompress button.
Eventually you will end up with lost of files without extension, these can be ignored/deleted.

## TODO

- Cover more chunk types
- Convert the .texture2D files into .dds files
