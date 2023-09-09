clearlistener()
yPos = 10
for obj in selection do
(
    --print ( obj.max - obj.min)
    
    --print ( ( obj.max - obj.min) - obj.pivot )
    
    obj.pivot = obj.center --( ( obj.max - obj.min) - obj.pivot )
    --print obj.center
    
    
    obj.position = [0,yPos,0]
    
    zPos = obj.max.z
        
    obj.position = [obj.position.x, obj.position.y, zPos]
    
    yPos = 5 + obj.max.y
    
)