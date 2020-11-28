fileIn "GriffonStudios_WorldOfWarcraft_ImportWMO.ms"
fileIn "GriffonStudios_WorldOfWarcraft_ImportM2.ms"

global nConvertExe = ""

struct _WorldOfWarcraft_ImportTool
(
    public 
        importDooaddHelpers = true,
        
    
    function ShowSettings=
    (
        rollout nConvert_Rollout "WMO Settings" width:350 height:150
        (

            label		lbl2 "Locate the nConvert Application:\nFor automatical conversion from blp to png" align:#left
            label		lbl3 "The nConvert Application can be downloaded from here:" align:#left
            hyperlink   lnk1 "www.xnview.com/nconvert" color:(color 00 180 200) hoverColor:(color 220 80 80) address:"https://www.xnview.com/en/nconvert/" height:20
            edittext	txtConvertApp width:290 height:20 text:nConvertExe align:#left
            button		btnBrowseExe "..." tooltip:"Locate nConvert File" align:#right width:35 height:24 border:false offset:[5,-28]
            button      btnSaveAndClose "Save & Close" align:#right width:100 height:35 border:false

            local iniFile = (GetDir #userScripts) + "\\wow_wmo.ini"

            
            on Settings_Rollout open do
            (
                
                if(DoesFileExist iniFile) then
                (
                    nConvertExe = getIniSetting iniFile "nConvertExe" "Value"
                    txtConvertApp.Text = nConvertExe
                )
                else
                (
                    txtConvertApp.Text = "Please select the nConvert Application"
                    texturePath = ""
                )
            )

            on btnBrowseExe PRESSED do
            (
                nConvertExe = getOpenFileName \
                    caption: "nConvert Application" \
                    types: "nConvert.exe|*.exe" \
                    historyCategory: "nConvertApplication"
                if(nConvertExe!= undefined ) then txtConvertApp.Text = nConvertExe
            )
            on btnSaveAndClose PRESSED do
            (
                nConvertExe = txtConvertApp.text
                SetIniSetting iniFile "nConvertExe" "Value" nConvertExe
                DestroyDialog nConvert_Rollout
            )
        )
        createDialog nConvert_Rollout
        
    ),
    function UI_Main=
    (

        rollout Main_rollout "World Of Warcraft WMO model importer" height:150 width:340
            
        (
            label       lblSelect       "Select WMO group file:" align:#left
            edittext    txtWmoFile      width:280 height:20 text:"" align:#left border:false offset:[-5,0]
            button		btnBrowseExe    "..." align:#right width:35 height:24 border:false offset:[5,-28]
            
            checkBox    cbCreateDooaddHelpers "Create dooadd helpers" offset:[0,5]
            
            button btnImport "Start WMO Import" align:#left height:35 width:300
            
            label lblInfo "\xa9 2018 Importer by Taylor Mouse" align:#left
            
            on Main_rollout open do
            (
                cbCreateDooaddHelpers.checked = importDooaddHelpers
            )
            
            on cbCreateDooaddHelpers changed theState do
            (
                if(importDooaddHelpers) then 
                (
                    importDooaddHelpers = false
                    cbCreateDooaddHelpers.checked = false
                )
                else
                (
                    importDooaddHelpers = true
                    cbCreateDooaddHelpers.checked = true
                )
            )
                
            on btnBrowseExe PRESSED do
            (
                local selectedFile = getOpenFileName \
                            caption: "World Of Warcraft - WMO" \
                            types: "World Of Warcraft - World Model File(*.wmo)|*.wmo" 
                
                if(selectedFile!= undefined ) then 
                    txtWmoFile.Text = selectedFile
            )

            on btnImport PRESSED do
            (
                local wmoFile = txtWmoFile.Text
                local chk = cbCreateDooaddHelpers.checked
                if(wmoFile!=undefined and wmoFile != "" and (doesFileExist wmoFile) == true) then 
                (
                    local wmo = _WorldOfWarcraft_wmo()
                    wmo.Import wmoFile chk
                )
            )
            
        )
        
    ),
    function ShowMain=
    (
        createDialog (UI_Main())
    ),
    function UI_ImportM2=
    (
        rollout ImportM2_rollout "World Of Warcraft M2 Static model importer" height:150 width:340
        (
            label       lblSelect   "Select m2 file:" align:#left
            edittext    txtM2File   width:280 height:20 text:"" align:#left border:false offset:[-5,0]
            button		btnBrowse   "..." align:#right width:35 height:24 border:false offset:[5,-28]
            button      btnM2Import "Import selected M2 file" align:#left height:35 width:300
            button      btnDynamicImport "Import M2 files from the scene" align:#left height:35 width:300
            label lblSceneM2Files "" align:#left
            
            on ImportM2_rollout OPEN do
            (
                btnDynamicImport.enabled = false
                local nbrM2Found = 0
                for obj in objects do
                (
                    if( classof obj == dummy) then
                    (
                        m2FileName = getUserProp obj "m2filename"
                        if( m2FileName != undefined and m2FileName != "undefined" ) then
                        (
                            nbrM2Found = nbrM2Found +1
                        )
                    )
                )
                if( nbrM2Found > 0 ) then 
                (
                    lblSceneM2Files.Text = "Found " + (nbrM2Found as string ) + " m2 props in the scene."
                    btnDynamicImport.enabled = true
                )
                    
                
                
            )
            on btnBrowse PRESSED do
            (
                local selectedFile = getOpenFileName \
                            caption: "World Of Warcraft - m2" \
                            types: "World Of Warcraft - Model File(*.m2)|*.m2" 
                
                if(selectedFile!= undefined ) then 
                    txtM2File.Text = selectedFile
            )
            on btnM2Import PRESSED do
            (
                local selectedFile = txtM2File.Text
                if(selectedFile!= undefined and doesFileExist selectedFile) then 
                (
                    local m2Tool = _WorldOfWarcraft_m2()
                    m2Tool.Import selectedFile undefined
                )
            )
            on btnDynamicImport PRESSED do
            (
                local m2Tool = _WorldOfWarcraft_m2()

                for obj in objects do
                (
                    if( classof obj == dummy) then
                    (
                        m2FileName = getUserProp obj "m2filename"
                        if( m2FileName != undefined and m2FileName != "undefined" ) then
                        (
                            Format "Importing m2 '%' \n" ( getFileNameFile m2FileName )
                            try
                            (
                                m2Tool.Import m2FileName obj
                            )
                            catch()
                        )
                    )
                )
            )
        )
        
        
    ),
    function ShowImportM2=
    (
        createDialog (UI_ImportM2())
        
    )
    
    
)

