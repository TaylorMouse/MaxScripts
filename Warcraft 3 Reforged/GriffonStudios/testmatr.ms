for obj in objects do
(
    if (classof obj == editable_mesh) then
    (
        print obj.material.diffuse_map.bitmap.filename
        print obj.material.normal_map.bitmap.filename      
        print obj.material.orm_map.bitmap.filename      
        print obj.material.teamcolor_map.bitmap.filename
        print obj.material.emissive_map.bitmap.filename    
        print obj.material.alphamask_map.bitmap.filename   
        print obj.material.reflection_map.bitmap.filename
    )
)