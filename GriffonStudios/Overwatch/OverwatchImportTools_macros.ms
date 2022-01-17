macroscript ImportModel category:"OverwatchImportTools" tooltip:"Import model"
(
    if( OverwatchImportModelDialog != undefined) then destroydialog OverwatchImportModelDialog
        CreateDialog OverwatchImportModelDialog \
            lockwidth: true \
            style: #(#style_resizing , #style_titlebar , #style_border , #style_sysmenu)

)

macroscript ImportSingleAnim category:"OverwatchImportTools" tooltip:"Import Single Animation"
(
   
    if(OverwatchImportAnimDialog != undefined) then destroydialog OverwatchImportAnimDialog
        CreateDialog OverwatchImportAnimDialog \
            lockwidth: true \
            style: #(#style_resizing , #style_titlebar , #style_border , #style_sysmenu)
    
)

macroscript ImportMultiAnim category:"OverwatchImportTools" tooltip:"Import Multiple Animations"
(
    if (OverwatchImportMultiAnimDialog != undefined) then destroydialog OverwatchImportMultiAnimDialog
        CreateDialog OverwatchImportMultiAnimDialog \
            lockwidth: true \
            style: #(#style_resizing , #style_titlebar , #style_border , #style_sysmenu)

)

macroscript FixAnimationAxisUp category:"OverwatchImportTools" tooltip:"Rotate model to face correct direction"
(
    
    FixYup()
)

macroscript AnimationProperties category:"OverwatchImportTools" tooltip:"Display animation list"
(
)

macroscript OverwatchAboutWindow category:"OverwatchImportTools"
(
    messageBox "\xa9 2017 Created by Taylor Mouse\nSpecial thanks to id-daemon and dynaomi\nfor making this possible" \
    title: "Overwatch Import Tools"
    
)