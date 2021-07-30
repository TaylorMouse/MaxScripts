--obj = $
select obj
max modify mode
modif = modPanel.getCurrentObject()
index = 1
if ( classof modif != skin ) then
(
    aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
    aBone.Name = "TOBEDELETED_" + (index as string)

    max modify mode
    mshSkin = skin()
    addmodifier obj mshSkin
    select obj
    modPanel.setCurrentObject mshSkin
    
    skinOps.addBone mshSkin aBone -1
    for v=1 to obj.verts.count do
    (
        skinOps.SetVertexWeights mshSkin v 1 1
        
        --skinOps.ReplaceVertexWeights mshSkin v boneIds weights
        
    )
    update obj
)
clearSelection()