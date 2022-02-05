/*
    .DESCRIPTION
    | DAE format with multiple animations has always been a pain
    | This script imports (wip) the dae format and puts the sequences in an note track and imports all animations
        
    .AUTHOR
    | Taylor Mouse
    
    .COPYRIGHT
    | (c)2022 Griffon Studios
    
    .NOTES
    | 0.1 - Initial mesh import
    
*/

global debug_mode = true
global _dae
global dae_model_scale = 5.0

struct dae_builder
(
    function BuildGeometries dae_scene=
    (
        for geo in dae_scene.geometries do (
            
            local faces = #()
            
            for polyList in geo.polylist do
                join faces polyList 
            
            geo.objRef = mesh name:geo.name vertices:geo.positions normals:geo.normals faces:faces tverts:geo.texcoords
            
            buildTVFaces geo.objRef false
            for i = 1 to faces.count do
            ( setTVFace geo.objRef i faces[i] )
            update geo.objRef
            
            geo.objRef.material = dae_scene.theMaterial
            
            local startingFace = 0
            
            for p=1 to geo.polylist.count do
            (
                local matId = 1
                
                for m=1 to dae_scene.materials.count do (
                    
                    if ( dae_scene.materials[m].id == geo.materialList[p] ) then 
                    (
                        matId = m
                        exit
                    )
                )
                
                for f=1 to geo.polyList[p].count do (
                    setFaceMatID geo.objRef (startingFace + f ) matId
                )
                startingFace += geo.polyList[p].count
            )
            
            update geo.objRef
        )
        
    ),
    function BuildMaterials dae_scene=
    (
        local meditId = 1
        for m in dae_scene.materials do
        (
            m.matRef = StandardMaterial()
            m.matRef.name = m.id
            
            local textureFile = getFileNamePath dae_scene.fileName
            
            local effect = undefined
            for f in dae_scene.effects do
                if ( m.effect == "#" + f.id ) then (
                    effect = f
                    exit
                )
            
            for t in dae_scene.images do (
                if ( t.id == effect.image ) then (
                    textureFile += t.file
                    format "%\n" textureFile
                    exit
                )
            )

            m.matRef.diffuseMap = Bitmaptexture fileName:textureFile
            
            m.matRef.ambient = effect.ambient
            m.matRef.diffuse = effect.ambient
            m.matRef.specular = effect.specular
            m.matRef.useSelfIllumColor = on
            m.matRef.selfIllumColor = effect.emission
            
            if ( effect.transparent ) then (
                m.matRef.opacityMap = Bitmaptexture fileName:textureFile
                m.matRef.opacityMap.alphaSource = 0
                m.matRef.opacityMap.monooutput = 1
                m.matRef.opacityMapEnable = off
            )
            
            showTextureMap m.matRef true
            
            if dae_scene.materials.count == 1 then (
                meditmaterials[meditId] = m.matRef
                dae_scene.theMaterial = m.matRef
            )
            meditId += 1
        )
        
        if dae_scene.materials.count > 1 then
        (
            local multiMat = Multimaterial()
            multiMat.name = getfilenamefile dae_scene.fileName
            
            multiMat.numsubs = dae_scene.materials.count
            
            multiMat.material1 = dae_scene.materials[1].matRef
            for i=2 to dae_scene.materials.count do 
                multiMat.materialList[i] = dae_scene.materials[i].matRef
            
            meditmaterials[1] = multiMat
            dae_scene.theMaterial = multiMat
        )
        
    ),
    function BuildBones dae_scene=
    (
        
        for b in dae_scene.nodes do
        (
            
            local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
            aBone.Name = b.name
            aBone.showLinks = true
            aBone.Width = 0.0
            aBone.Height = 0.0
            aBone.setBoneEnable false 0
            
            b.boneRef = aBone
        )
        
        for b in dae_scene.nodes do
        (
            if b.parent == undefined then continue
            local parentBone = getNodebyName b.parent
            b.boneRef.parent = parentBone
        )
        
        for b in dae_scene.nodes do
        (
            if b.boneRef.parent != undefined then (
                --b.boneRef.transform = b.matrix + b.boneRef.transform
                b.boneRef.rotation = b.matrix.rotationpart * b.boneRef.parent.rotation
                b.boneRef.pos = b.matrix.translationpart + b.boneRef.parent.pos
            )
            else(
                --b.boneRef.transform = b.matrix
                b.boneRef.rotation =  b.matrix.rotationpart
                b.boneRef.pos = b.matrix.translationpart
            )
        )
        
    ),
    function ApplySkin dae_scene=
    (
        local boneList = #()
        
        for joint in dae_scene.controllers.joints do (
            for n in dae_scene.nodes do(
                if ( joint == n.id ) then (
                    append boneList n.boneRef
                    exit
                )
            )
        )
        
        local vertex_weights = dae_scene.controllers.bone_indices
        
        for geo in dae_scene.geometries do
        (
            local obj = geo.objRef
            
            local mshSkin = skin name:"Skin"
            
            mshSkin.bone_Limit = 2
            max modify mode
            addmodifier obj mshSkin

            modPanel.setCurrentObject mshSkin
            
            for i=1 to boneList.count do 
                skinOps.addBone mshSkin boneList[i] 0
            
            update obj
            for v=0 to obj.vertices.count do 
                try ( skinOps.SetVertexWeights mshSkin v 1 1.0 ) catch ()
            update obj
                        
            for v=0 to obj.vertices.count do --> the first one always fails, whatever the number :/
            (
                try ( skinOps.ReplaceVertexWeights mshSkin v vertex_weights[v].boneList vertex_weights[v].weights ) catch(  )
            )
            update obj
                
        )
            
    )
)
    
struct dae
(
    function InverseMatrix matrix4x4=
    (
        local row1 = [matrix4x4.row1[1], matrix4x4.row2[1], matrix4x4.row3[1]]
        local row2 = [matrix4x4.row1[2], matrix4x4.row2[2], matrix4x4.row3[3]]
        local row3 = [matrix4x4.row1[3], matrix4x4.row2[3], matrix4x4.row3[3]]
        local row4 = [matrix4x4.row1[4], matrix4x4.row2[4], matrix4x4.row3[4]] * dae_model_scale
        local m = matrix3 row1 row2 row3 row4
        
    ),
    function ParseXmlProperty xmlStr property=
    (
        local pos = findString xmlStr property
        if ( pos == undefined ) then return undefined
        
        local startPos = pos + property.count + 2
        local valEnd = substring xmlStr startPos -1
        local len = findString valEnd "\""
        local val = substring xmlStr startPos (len - 1)
        val
    ),
    function ParseXmlTag xmlStr tag=
    (
        local endTag = "</" + tag + ">"
        local startPos = findString xmlStr ">"
        local endPos   = findString xmlStr endTag
        
        if ( startPos == undefined or endPos == undefined ) then return undefined
        
        startPos += 1
        
        local len = endPos - startPos
        local val = substring xmlStr startPos len
        
        val
    ),
    function ParseFloatArrayToVector3Array fStream model_scale =
    (
        local theLine = readLine fStream
        local floatStr = _dae.ParseXmlTag theLine "float_array"
        
        if floatStr == undefined then return undefined
        local floats = filterString floatStr " "
        
        local vector3Array = #()
        for f=1 to floats.count by 3 do
        (
            append vector3Array ( [floats[f] as float, floats[f + 1] as float, floats[f + 2] as float] * model_scale )
        )
        
        vector3Array
    ),
    function ParseFloatArrayToTexCoordsArray fStream=
    (
        local theLine = readLine fStream
        local floatStr = _dae.ParseXmlTag theLine "float_array"
        
        if floatStr == undefined then return undefined
        local floats = filterString floatStr " "
        
        local vector3Array = #()
        for f=1 to floats.count by 2 do
        (
            append vector3Array ( [floats[f] as float, floats[f + 1] as float, 0.0] )
        )
        
        vector3Array
    ),
    function ParseLibraryImages fStream=
    (
        struct library_image ( id, file )
        
        local images = #()
        
        local theLine = readLine fStream
        
        while ( findString theLine "</library_images>" == undefined ) do (
                
            if ( findString theLine "<image id=" != undefined ) then (
                
                local libImg = library_image()
                libImg.id = _dae.ParseXmlProperty theLine "id"
                theLine = readLine fStream
                libImg.file = _dae.ParseXmlTag theLine "init_from"
                append images libImg
            )
            theLine = readLine fStream
        )
        if debug_mode then print images
        images
    ),
    function ParseLibraryMaterials fStream=
    (
        struct library_materials ( id, name, effect, matRef )
        
        local materials = #()
        
        local theLine = readLine fStream
        
        while ( findString theLine "</library_materials>" == undefined ) do (
                
            if ( findString theLine "<material id=" != undefined ) then (
                
                local libMat = library_materials()
                libMat.id = _dae.ParseXmlProperty theLine "id"
                libMat.name = _dae.ParseXmlProperty theLine "name"
                theLine = readLine fStream
                libMat.effect = _dae.ParseXmlProperty theLine "url"
                append materials libMat
            )
            theLine = readLine fStream
        )
        if debug_mode then print materials
            
        materials
    ),
    function ParseColor fStream=
    (
        local colorLine = readLine fStream
        if ( findString colorLine "<color>" == undefined ) then return undefined
        
        local colorValues = _dae.ParseXmlTag colorLine "color"
        local colorList = filterString colorValues " "
        local colorFloats = #()
        for i=1 to colorList.count do append colorFloats (colorList[i] as float * 255 )
        
        local theColor = color colorFloats[1] colorFloats[2] colorFloats[3] colorFloats[4]
        
        theColor
    ),
    function ParseLibraryEffects fStream=
    (
        struct library_effect ( id, name, image, image_format, emission, ambient, specular, transparent = false )

        local effects = #()
        
        local theLine = readLine fStream
        
        while ( findString theLine "</library_effects>" == undefined ) do (
            
            if ( findString theLine "<effect" != undefined ) then (
                local effect = library_effect()
                append effects effect
                effect.id = _dae.ParseXmlProperty theLine "id"
                effect.name = _dae.ParseXmlProperty theLine "name"
                
                while ( findString theLine "</effect>" == undefined ) do (
                    if ( findString theLine "<init_from>"   != undefined ) then effect.image = _dae.ParseXmlTag theLine "init_from"
                    if ( findString theLine "<format>"      != undefined ) then effect.image_format = _dae.ParseXmlTag theLine "format"
                    if ( findString theLine "<emission>"    != undefined ) then effect.emission = ParseColor fStream
                    if ( findString theLine "<ambient>"     != undefined ) then effect.ambient = ParseColor fStream
                    if ( findString theLine "<specular>"    != undefined ) then effect.specular = ParseColor fStream
                    if ( findString theLine "<transparent>" != undefined ) then effect.transparent = true
                    theLine = readLine fStream
                )
                if debug_mode then print effect
            )
            theLine = readLine fStream
        )
        
        effects
    ),
    function ParsePolyList fStream=
    (
        local theLine = readLine fStream
        local indices = #()
        local vcounts = #()
        
        -- there are multiple polylists where a material is attached to it
        while ( findString theLine "</polylist>" == undefined ) do (
            
            if ( findString theLine "<vcount>" != undefined ) then (
            
                local vcountStr = _dae.ParseXmlTag theLine "vcount"
                local vcountsArr = filterString vcountStr " "
                for v in vcountsArr do append vcounts ( v as integer )

            )
            
            if ( findString theLine "<p>" != undefined ) then (
            
                local indicesStr = _dae.ParseXmlTag theLine "p"
                local indicesArr = filterString indicesStr " "
                for i in indicesArr do append indices ( i as integer + 1)

            )
            theLine = readLine fStream
        )
        
        local faces = #()
        local index = 1
        -- polylist can have quads and tris, fixed that to only tris
        for v in vcounts do (
        
            if v==4 then (
                append faces [indices[index], indices[index+1], indices[index+2]]
                append faces [indices[index], indices[index+2], indices[index+3]]
                index += 4
            )
                
            if v==3 then (
                append faces [indices[index], indices[index+1], indices[index+2]]
                index += 3
            )
        )
        faces
    ),
    function ParseLibraryGeometries fStream=
    (
        struct library_geometry ( id, name, positions, texcoords, colors, normals, polylist = #(), materiallist = #(), objRef )
        
        local geometries = #()
        
        local theLine = readLine fStream
        
        while ( findString theLine "</library_geometries>" == undefined ) do (
                
            if ( findString theLine "<geometry id=" != undefined ) then (
                
                local geo = library_geometry()
                geo.id = _dae.ParseXmlProperty theLine "id"
                geo.name = _dae.ParseXmlProperty theLine "name"
                
                theLine = readLine fStream
                if ( findString theLine "<mesh>" != undefined ) then (

                    theLine = readLine fStream
                    while ( findString theLine "</mesh>"  == undefined ) do (
                    
                        if ( findString theLine "<source id=\"positions\">" != undefined ) then
                            geo.positions = _dae.ParseFloatArrayToVector3Array fstream dae_model_scale
                        
                        if ( findString theLine "<source id=\"texcoords\">" != undefined ) then
                            geo.texcoords = _dae.ParseFloatArrayToTexCoordsArray fstream
                        
                        if ( findString theLine "<source id=\"normals\">" != undefined ) then
                            geo.normals = _dae.ParseFloatArrayToVector3Array fstream 1.0
                        
                        if ( findString theLine "<polylist material=" != undefined ) then (
                            local mat = _dae.ParseXmlProperty theLine "material"
                            local polyList = _dae.ParsePolyList fStream
                            append geo.materiallist mat
                            append geo.polylist polyList
                        )
                        
                        theLine = readLine fStream
                    )
                )
                append geometries geo
            )
            theLine = readLine fStream
        )
        
            
        geometries
    ),
    function ParseJoints fStream=
    (
        local jointsLine = readLine fStream
        local jointsStr = _dae.ParseXmlTag jointsLine "Name_array"
        
        local joints = filterString jointsStr " "

        joints
    ),
    function ParseBindPoses fStream=
    (
        struct matrix4x4 ( row1, row2, row3, row4 )
        local bpLine = readLine fStream
        local bpStr = _dae.ParseXmlTag bpLine "float_array"
        local bps = filterString bpStr " "
        local bpFloats = #()

        for bp in bps do append bpFloats ( bp as float )

        local bind_poses = #()
        local i=0

        for x=1 to bpFloats.count/16 do 
        (
            local row1 = [bpfloats[i+1], bpfloats[i+2], bpfloats[i+3], bpfloats[i+4]]
            local row2 = [bpfloats[i+5], bpfloats[i+6], bpfloats[i+7], bpfloats[i+8]]
            local row3 = [bpfloats[i+9], bpfloats[i+10], bpfloats[i+11], bpfloats[i+12]]
            local row4 = [bpfloats[i+13], bpfloats[i+14], bpfloats[i+15], bpfloats[i+16]]
            local m = matrix4x4 row1:row1 row2:row2 row3:row3 row4:row4
            
            append bind_poses ( InverseMatrix m )
            i += 16
            
        )
        
        bind_poses
        
    ),
    function ParseBoneIndices fStream=
    (
        struct vertex_weight ( boneList = #(), weights = #() )
        
        local vertex_weight_list = #()
        readLine fStream
        readLine fStream
        local vcountLine = readLine fStream
        vcountStr = _dae.ParseXmlTag vcountLine "vcount"
        local vLine = readLine fStream
        vStr = _dae.ParseXmlTag vLine "v"
        
        local vcounts = filterString vcountStr " "
        local valuesStr = filterString vStr " "
        
        local vIndex = 1
        for i=1 to vcounts.count do (
            
            local vw = vertex_weight()
            append vertex_weight_list vw
            local nbrBones = vcounts[i] as integer
            
            for n=1 to nbrBones * 2 by 2 do (
                append vw.boneList ( valuesStr[vIndex] as integer + 1)
                append vw.weights ( valuesStr[vIndex + 1] as float )
                
                vIndex += 2 
            )
        )
        
        -- calculate 3ds max weights
        for vw in vertex_weight_list do (
            
            if vw.weights.count == 1 then vw.weights[1] = 1.0
            else (
                local totalWeight = 0.0
            
                for w in vw.weights do totalWeight += w
                    
                for w=1 to vw.weights.count do vw.weights[w] = vw.weights[w] / totalWeight
            )
        )
        
        vertex_weight_list
    ),
    function ParseLibraryControllers fStream=
    (
        struct library_controller ( joints, bind_poses, bone_indices )
        
        local controller = library_controller()
        
        local theLine = readLine fStream
        
        while ( findString theLine "</library_controllers>" == undefined ) do (
                
            if ( findString theLine "<source id=\"controller-joints\">" != undefined ) then 
                controller.joints = _dae.ParseJoints fStream
            
            if ( findString theLine "<source id=\"controller-bind-poses\">" != undefined ) then 
                controller.bind_poses = _dae.ParseBindPoses fStream
            
            if ( findString theLine "<vertex_weights" != undefined ) then 
                controller.bone_indices = _dae.ParseBoneIndices fStream
            
            theLine = readLine fStream
        )
            
        controller
     
        
    ),
    function ParseNodeMatrix fStream=
    (
        struct matrix4x4 ( row1, row2, row3, row4 )
        local matrixLine = readLine fStream
        local transformValuesStr = _dae.ParseXmlTag matrixLine "matrix"
        local transformValues = filterString transformValuesStr " "
        local matrixValues = #()
        for t in transformValues do append matrixValues ( t as float )
        
        local row1 = [matrixValues[1], matrixValues[2], matrixValues[3], matrixValues[4]]
        local row2 = [matrixValues[5], matrixValues[6], matrixValues[7], matrixValues[8]]
        local row3 = [matrixValues[9], matrixValues[10], matrixValues[11], matrixValues[12]]
        local row4 = [matrixValues[13], matrixValues[14], matrixValues[15], matrixValues[16]]
        local m = matrix4x4 row1:row1 row2:row2 row3:row3 row4:row4
        
        return ( InverseMatrix m )
        
    ),
    function ParseVisualScene fStream=
    (
        
        struct dae_node ( id, name, matrix, parent, index, boneRef )
        local nodes = #()
        readLine fStream -- visual_scene
        
        local currentOffset = filePos fStream
        print currentOffset
        
        local theLine = readLine fStream -- nodes
        local prevLine = ""
        local theLines = #()
        append theLines theLine
        
        local parentNode = undefined
        local parentIndex = 0
        
        while ( findString theLine "</library_visual_scenes>" == undefined ) do (
            
            
            if ( findstring theLine "<node" != undefined ) then (
                
                local type = _dae.ParseXmlProperty theLine "type"
                if ( type != "JOINT" ) then exit
                
                local theNode = dae_node()
                append nodes theNode
                theNode.id     = _dae.ParseXmlProperty theLine "id"
                theNode.name   = _dae.ParseXmlProperty theLine "name"
                theNode.matrix = _dae.ParseNodeMatrix fStream
                theNode.index = findString theLine "<node"
            )
            theLine = readLine fStream

            
        )
        
        -- built hierarchy --> I hate XML bs :/      
        for n=nodes.count to 1 by -1 do
        (
            local theNode = nodes[n]
            for m=n to 1 by -1  do
            (
                if ( theNode.index - 2 == nodes[m].index ) then (
                    theNode.parent = nodes[m].name
                    exit
                )
                
            )
        )
        print nodes
        nodes
    ),
    
    function FixScene =
    (
        local rootObj = #()
        for obj in objects do (
            
            if ( classof obj == bonegeometry ) then
            (
                if obj.parent == undefined then append rootObj obj
            )
        )
        
        local h = point pos:[0,0,0]
        
        for obj in rootObj do (
            obj.parent = h
        )
        
        rotate h (angleaxis 90 [1,0,0])
        delete h
    ),
    
    function ParseDae file=
    (
        _dae = dae()
        
    
        struct _dae_struct ( fileName, images, materials, theMaterial, effects, geometries, controllers, nodes )
        
        clearlistener()
        SetWaitCursor()
        local fStream = openFile file
        local dae_scene = _dae_struct fileName:file
        
        while ( eof fStream != true ) do
        (
            local theLine = readLine fStream
            
            if ( findString theLine "<library_images>" != undefined ) then 
                dae_scene.images = _dae.ParseLibraryImages fStream
            
            if ( findString theLine "<library_materials>" != undefined ) then 
                dae_scene.materials = _dae.ParseLibraryMaterials fStream
            
            if ( findString theLine "<library_effects>" != undefined ) then 
                dae_scene.effects = _dae.ParseLibraryEffects fStream
            
            if ( findString theLine "<library_geometries>" != undefined ) then 
                dae_scene.geometries = _dae.ParseLibraryGeometries fStream
            
            if ( findString theLine "<library_controllers>" != undefined ) then 
                dae_scene.controllers = _dae.ParseLibraryControllers fStream 
            
            if ( findString theLine "<library_visual_scenes>" != undefined ) then  
                dae_scene.nodes = _dae.ParseVisualScene fStream
            
        )

        free fStream
        close fStream
        
        dae_builder.BuildMaterials dae_scene
        dae_builder.BuildGeometries dae_scene
        dae_builder.BuildBones dae_scene
        dae_builder.ApplySkin dae_scene
        
        _dae.FixScene()
        gc()
        format "Done!\n"
        clearSelection()
        max zoomext sel
        setArrowCursor() 
    )
)
max select all
max delete
--dae.ParseDae @"G:\Game Dev\3D Models\Game Models\Final Fantasy - The 4 Heroes of Light\m039_01.dae"
--dae.ParseDae @"G:\Game Dev\3D Models\Game Models\Final Fantasy - The 4 Heroes of Light\m101_01.dae"
dae.ParseDae @"G:\Game Dev\3D Models\Game Models\Final Fantasy - The 4 Heroes of Light\d01_86.dae"

