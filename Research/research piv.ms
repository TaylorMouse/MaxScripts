clearlistener()
WC3_MDX.HELP
for h in WC3_MDX.BONE do 
(
    if h.name == "Pelvis01" then
    (        
        print h.name
        format "% %\n" h.Id h.parentBoneId
        print h.kgtr
        
        if h.kgtr != undefined then
        for kg in h.kgtr.kg do 
        (
        
            print kg
        )
    )
)

--b = $
select b
b.position.controller = undefined
pivt = [-4.587020,-0.475050,123.166000]
c = bezier_position()

-- dp = dummy name:"TestDummy" 
-- dp.pos = pivt

for h in WC3_MDX.HELP do 
(
    if h.kgtr != undefined then
    for kg in h.kgtr.kg do 
    (
        k = addnewkey c ( kg.time + 10 )
        k.value = in coordsys parent ( kg.Point + pivt )
         k.intangentType = #linear 
         k.intangent = kg.inTan
         k.outtangentType = #linear 
         k.outtangent = kg.outTan
        
    )
)


-- dp.position.controller = c
b.position.controller = c