clearlistener()

helve_bind_jnt = undefined
helve_02_bind_jnt = undefined

for i=1 to gbones.count do
(
    if gbones[i].name == "helve_bind_jnt" then 
    (
        helve_bind_jnt = gbones[i]
        print gbpos[i].matrix.row4
    )
    if gbones[i].name == "helve_02_bind_jnt" then 
    (
        helve_02_bind_jnt = gbones[i]
        print gbpos[i].matrix.row4
    )
)
--helve_bind_jnt
--helve_02_bind_jnt

jnt = helve_02_bind_jnt
for i=1 to 10 --helve_bind_jnt.kgtr.kg.count 
    do
(
    kg = jnt.kgtr.kg[i]
    format "%\t%\n" (kg.time) kg.point
    
)

b = getnodebyname "helve_02_bind_jnt"
at time 0 
    in coordsys parent 
        basePos = b.pos

--help = GriffonStudios_Helper_Functions()
    
nbrKeys = numkeys b.pos.controller 

at time 0 baseTransform = b.transform
at time 0 baseParentPos = b.parent.pos
for k=1 to 12 do
(
    t =  help.TimeToInt ( getKeyTime b.pos.controller k )
    
    at time t
    (
        in coordsys parent
            format "%\t%\n" (t-10) (b.pos - basePos )
    )
    
)












