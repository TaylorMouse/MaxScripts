
function GetWeights theMesh=
(
    local sk = modPanel.getCurrentObject()

    struct vertexWeights ( vertexId, boneIndices, weights )
    
    if (classof sk == Skin ) then
    (
        local vertices = #()
        
        for v=1 to skinOps.getnumbervertices sk do
        (
            
            count = skinops.getvertexweightcount sk v
            
            local boneIndices = #(0,0,0,0)
            local weights = #(0,0,0,0)
            
            for k=1 to count do
            (
                weight = skinOps.getvertexweight sk v k
                boneId = skinOps.getvertexweightboneid sk v k
                boneName = skinOps.getBonename sk boneId 0
                
                boneIndices[k] = boneId
                weights[k] = ( weight * 255 ) as integer
            )
            local vertex = vertexWeights vertexId:v boneIndices:boneIndices weights:weights
            
            append vertices vertex
        )
        print vertices
    )
)


getWeights $