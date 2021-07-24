--obj = $

struct mdx800_transform ( translationData, rotationData, scaleData )
struct KeyValuePair ( Key, Val )

--obj.pos.isanimated


trans = mdx800_transform()

trans.transaltionData = obj

obj.pos.controller.keys


obj.pos.controller == tcb_position
 
pvt = undefined
cntrl =  obj.pos.controller
pvt = at time 0f in coordsys parent obj.pos

-- if the parent is not a dummy and not a bone and not a mesh and is animated, then it is an animation control !!

keys = #()
for k in cntrl.keys do
(
    local pos = at time k.time in coordsys parent obj.pos
    pos = pos - pvt
    append keys ( KeyValuePair key:k.time val:pos )
)

GetKGTR obj

-- IKControl or Rotation_List !!!!! --> see WC3Animation.ms line 270

classof $
$.pos.isanimated
$.transform.controller --> IKControl
$.rotation.controller --> Rotation_List
$.rotation.controller[2]  --> orientation constraint --> get rotation of the IK Keys



obj = $

obj.rotation.controller
rot_base = at time 0f obj.transform.rotationpart
pr = quat 0 0 0 1

if obj.parent != undefined  then pr = at time 0f obj.parent.transform.rotationpart

if classof obj.transform.controller == IKControl then
(
    
    
)

IKChains 






