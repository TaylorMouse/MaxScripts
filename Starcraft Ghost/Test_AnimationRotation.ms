for obj in objects do delete obj
myBox = box height:20 width:20 length:20

boxColor = color 100 100 200
myBox.wirecolor = boxColor

clearlistener()

rot = (eulerangles 0 0 30 ) as matrix3

with animate on 
    at time 0
        print myBox.transform
    
with animate on
    at time 10
    (
        mybox.rotation = rot
    )
    
with animate on
    at time 20
    (
        mybox.rotation = rot
    )