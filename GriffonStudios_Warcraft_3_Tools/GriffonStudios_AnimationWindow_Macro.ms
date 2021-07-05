macroscript Animation_Window category:"Griffon Studio Tools" tooltip:"Animation Window" 
(
    filein "GriffonStudios_AnimationWindow.ms"
    
    if(GriffonStudios_AnimationWindow != undefined) then destroydialog GriffonStudios_AnimationWindow
            CreateDialog GriffonStudios_AnimationWindow lockwidth: true      
)