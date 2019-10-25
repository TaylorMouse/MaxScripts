            local b = obj.boneRef
            
            if ( obj.KGRT != undefined ) then 
            (
                b.assumeSkinPose()
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller
                local q0 = dr.transform
                
                for anim in obj.KGRT do
                (
                    local t = anim.Time + 10
                    local q = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                            
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr
            )
            
            if ( obj.KGTR != undefined ) then
            (
               
                    b.assumeSkinPose()
                    
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = b.position.controller
                    local p0 = dp.transform
                    
                    for anim in obj.KGTR do
                    (
                        local t = anim.Time + 10
                        local p = anim.Point
                        
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on b.position.controller = copy dp.position.controller
                    
                    delete dp
                
            )
            
            if ( obj.KGSC != undefined ) then
            (
                b.assumeSkinPose()
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                local p0 = ds.transform
                
                for anim in obj.KGSC do
                (
                    local t = anim.Time + 10
                    local p = anim.Point
                    
                    with animate on 
                        at time t
                        (
                            in coordsys p0 ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )