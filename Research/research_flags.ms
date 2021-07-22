/*
Flag	    Meaning	                        Notes
CORRECT ONES
0x0         HELPER OBJECT       --> set as property

0x8	        BILLBOARD	        --> set as property
0x10	    BILLBOARD_LOCK_X	--> set as property
0x20	    BILLBOARD_LOCK_Y	--> set as property
0x40	    BILLBOARD_LOCK_Z	--> set as property

0x100       BONE OBJECT         --> use bonegeometry
0x400       EVENT OBJECT        --> use warcraftIII_event object
0x800       ATTACHMENT OBJECT   --> use warcraftIII_attachment object
0x2000      COLLISION OBJECT    --> set as property

... GENOBJECT_MDLLIGHTSECTION	
... GENOBJECT_MDLPARTICLEEMITTER2	
... GENOBJECT_MDLRIBBONEMITTER	

*/

for t in WC3_MDX.TAGS do print t

for t in WC3_MDX.BONE do print t


setUserProp $ "COLLISION-OBJECT" true


-- apply flags
for b in WC3_MDX.CLID do
(
    print b.flags
    
    --if ( bit.and b.flags 0x08 > 0 ) then setUserProp b.boneRef "BILLBOARD" true
    
)    
    