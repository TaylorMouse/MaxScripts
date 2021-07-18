   struct mdx800 ( file, stream, seqs, glbs, mtls, texs, geos, geoa, allObjects )
   mdx = mdx800()
    
    
       
    
    Warcraft_III_Helpers.GetObjects mdx
    
    for a in mdx.allObjects do 
    (
        if a.flags == 0x400 then
        (
        print a.name
        print a.objRef.keyList
        )
    )
    
    for obj in WC3_MDX.BONE do print obj --> flag 0x100
    for obj in WC3_MDX.HELP do print obj --> flag 0x000
    for obj in WC3_MDX.ATCH do print obj --> flag 0x800
    for obj in WC3_MDX.EVTS do print obj --> flag 0x400
    for obj in WC3_MDX.CLID do print obj --> flag 0x2000
        
    for tag in WC3_MDX.tags do print tag


for obj in WC3_MDX.BONE do print obj
    

$.height

pos = $.pos
pos.z += $.height
$.center