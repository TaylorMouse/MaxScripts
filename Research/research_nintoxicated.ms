-- research nintoxicated weird import
-- struct myMDX ( seqs, mtls, geos, objs, pivots, geobones )
clearlistener()
mdxnin.geos[1].pnts.group -->per vertex a mapping to the bones
gmdx800.geos[1].gndx
gmdx800.geos[1].vrtx.count

mdxnin.geos[1].bonegroups
gmdx800.geos[1].MTGC


mdxnin.geos[1].bones

gmdx800.geos[1].bones

mdxnin.objs[17].no

geo = gmdx800.geos[1]

obj = geo.meshRef
            
-- apply the skin modifier
max modify mode
select obj
mshSkin = skin()
addmodifier obj mshSkin
modPanel.setCurrentObject mshSkin

-- add the bones to the modifier
for uniqueBoneId in geo.uniqueBoneIds do
(
    local b = gmdx800.bone[uniqueBoneId].boneRef
    skinOps.addBone mshSkin b 0
)

for v=1 to geo.VRTX.count do
(
    gndx = geo.GNDX[v]
    boneRefIds = geo.bones[gndx]
    boneIds = #()
    for boneRefId in boneRefIds do 
    (
        for u=1 to geo.uniqueBoneIds.count do
        (
            local uniqueId = geo.uniqueBoneIds[u]
            if uniqueId == boneRefId then append boneIds u
        )
    )
    
    weights = #()
    weight = 1.0 / boneIds.count
    for i=1 to boneIds.count do
        append weights weight
    
    skinOps.SetVertexWeights mshSkin v boneIds weights
    
   -- skinOps.ReplaceVertexWeights mshSkin v boneRefIds weights
    
)
update obj