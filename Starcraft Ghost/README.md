# NOD Engine SDK 1.0

## NAD File Specifications

### Introduction

The NAD file format contains basic keyframe animation information for animating 3D object skeletons. NAD stands for Nihilistic Animation Data. All keyframed animation in the game is stored in NAD files. The NAD file data depends on the exact bone organization and ordering from a NOD file, so NAD files should be played only on models that have a matching bone structure. For this reason, both NOD and NAD files are generated from the same basic Maya data files in the game. If the NAD file doesn’t match the NOD its used on, you will see strange animation of joints.

### Data Types

Data in the NAD file is organized into a series of "bone tracks". A single bone track contains one keyframe timeline for a single bone in the skeleton. Each bone track can represent either ROTATION data or TRANSLATION data. If both translation and rotation are used on a bone, that bone contains two bone tracks in the NAD file. The order of the bone tracks is not important. The format of translation and rotation bone tracks are identical, but the way the data is used in the engine differs.

Rotational keyframes are stored in Euler angle format using (pitch/roll/yaw). These values represent angular rotations around X, Y, and Z respectively. Although the quantities are stored as vectors, each component is interpolated separately, using its own scaling factors. This most closely matches the curve methods used in Maya.

Most animations are authored for a playback rate of 30.0 frames per second, but that doesn’t mean these animations can only be played back at that speed. At standard playback rates, therefore, keyframe 30.0 will be reached in about one second of playback time.

### Keyframe Data

Each bone track contains one or more keyframes. Each keyframe contains a "frame" member, which identifies the "time" of the specific keyframe. These frame numbers must be stored in ascending order in the file. In addition to the frame number, each keyframe contains absolute position/rotation information, as well as several curve-based smoothing factors pre-calculated by the export tool and used for curve fitting during the real-time interpolation of the data.

The composition of a single keyframe record is shown in the table below:

|Field|Size|Comments|
|--|--|--|
|Frame|Float (4 bytes)|Timeline position of the keyframe, (0.0 … numFrames, floating point values are valid)|
|Value|Vector3 (12 bytes)|Absolute 3D position or euler angle at this keyframe|
|CFactor|Vector3|The constant curve fitting factor for the Hermite curve interpolation|
|BFactor|Vector3|The linear curve fitting factor|
|Afactor|Vector3|The square curve fitting factor|

### File Format

The header of the file contains some basic information about the duration and size of the remainder of the file.

|Field|Size|Comments|
|--|--|--|
|Version|UINT|Version identifier (current version in NOD 1.0 is 3)|
|NumBoneTracks|UINT|How many bone tracks are contained in the file|
|Flags|UINT|Specific animation behavior flags|
|Duration|Float|Total duration of the animation in frames.|
|BoneTracks[]|BoneTrack * NumBoneTracks|Bone track definitions according to table below|
|NumTags|UINT|Number of keyframe tags defined|
|Tags[]|KeyframeTag * NumTags|A number of keyframe tag records (see below)|

### Bone Track Definitions

After the initial preamble, the remainder of the file is made up of bone track definitions.

This definition is repeated "NumBoneTracks" times.

|Field|Size|Comments|
|--|--|--|
|NumKeys|UINT|How many keyframes are in this bone track|
|BoneNum|UINT|Which bone in the skeleton is affected by this track’s data|
|TrackType|UINT|Type of the track (0 = rotation, 1 = translate, 2 = scale). Scale is currently not supported by the engine.|
|Keys[]|Keyframe * NumKeys|This is the array of keyframe records. See Keyframe Data definition above.|

### Keyframe Tag Definitions

At the end of the NAD file there are a number of special tag records. These tags exist in the animation data as markers for specific gameplay functionality, but are not associated with any specific bone or joint. In the game engine, when these tags are reached during the playback of an animation, they trigger specific functionality which depends on the context of the animation and the type of tag. Information about the tag functions can be found in the next section.

|Field|Size|Comments|
|--|--|--|
|FrameNum|Float|Keyframe number for the tag|
|TagType|UINT|What type of tag is this|

### Keyframe Tag Meanings

The following table cotains the meanings of the various keyframe tags that can exist in a NAD file. The name specified is not stored in the file, but is the name used in the NODExporter to specify each tag type.

|Tag Name|Value|Comments|
|--|--|--|
|Lwalk|0|Left foot hits the ground in walk animation, triggers footstep sounds|
|Rwalk|1|Right foot hits the ground, used to trigger footstep sounds|
|Lrun|2|Left footfall in run, sound trigger|
|Rrun|3|Right footfall run, sound trigger|
|Fire|4|When to spawn projectile in a weapon firing animation|
|Strike|5|When to compute hit effects in a melee weapon strike animation|
|Cast|6|When to trigger the discipline cast during a casting animation|
|Fall|7|Soundtrigger for sound of body hitting the ground during death animation|
|Project|8|When to enable display of the projectile mesh in player’s hand during firing animation|
|Flap|9|Sound trigger for flying actors|
|Suck|10|When during a feeding animation to trigger suck sound effects|
|Idle|11|Special sounds for idle animations (horse whinney, etc.)|
|Idle2|12|Special sounds for idle animations|
|Codex1-Codex3|13-15|Trigger a special script callback at this point in animation|
|Repeat|16|At this keyframe, check for held-down attack key and jump to REPEATTO tag if present, for ‘strafing’ weapons|
|RepeatTo|17|Jump to this keyframe during strafe attack animations|
|Throwdeath|18|During a throw animation, check for victim death at this frame and halt their animation if dead|
