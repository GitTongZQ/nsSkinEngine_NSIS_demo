/*
    Compile the script to use the Unicode version of NSIS
    The producers：surou
*/
;ExecShell taskbarunpin "$DESKTOP\${PRODUCT_NAME}.lnk"是删除任务栏图标

;安装包 解压空白
!system '>blank set/p=MSCF<nul'
!packhdr temp.dat 'cmd /c Copy /b temp.dat /b +blank&&del blank'

;定义变量
Var Dialog
Var MessageBoxHandle
Var installPath
Var FreeSpaceSize
;定义变量
Var IsUpdateSelf
Var IsUpdateOther
Var IsAuto
Var IsForced
Var IsManual
Var IsBackstage
Var IsBanDisturb
Var IsHasUpdateMark

Var varShowInstTimerId
Var varCurrentStep
Var varCurrentVersion
Var varLocalVersion
Var varCurrentParameters
; 安装程序初始定义常量
!define PRODUCT_VERSION "2016.01.10.000"
!define MAIN_APP_NAME "notepad++.exe"
!define PRODUCT_NAME "notepad++"
!define PRODUCT_NAME_EN "notepad++"
!define PRODUCT_PUBLISHER "aceui"
!define PRODUCT_WEB_SITE "http://www.aceui.cn"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_NAME}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_AUTORUN_KEY "Software\Microsoft\Windows\CurrentVersion\Run"
!define PRODUCT_KEY "Software\Aceui\update"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define MUI_ICON "resouce\Update\app.ico"
!define MUI_UNICON "resouce\Update\app.ico"
!define UNINSTALL_DIR "$TEMP\ACEUI\aceuiStep"
!define UPDATE_TEMP_NAME "AutoUpdateSelf.exe"
!define UPDATE_NAME "AutoUpdate.exe"

;刷新关联图标
!define SHCNE_ASSOCCHANGED 0x08000000
!define SHCNF_IDLIST 0
; 安装不需要重启
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
; 设置文件覆盖标记
SetOverwrite on
; 设置压缩选项
SetCompress auto
; 选择压缩方式
SetCompressor /SOLID lzma
SetCompressorDictSize 32
; 设置数据块优化
SetDatablockOptimize on
; 设置在数据中写入文件时间
SetDateSave on
;设置Unicode 编码 3.0以上版本支持
Unicode true
; 是否允许安装在根目录下
AllowRootDirInstall false
Name "${PRODUCT_NAME}"
OutFile "output\AutoUpdate.exe"

;Request application privileges for Windows Vista
RequestExecutionLevel user
;文件版本声明-开始
VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "Google Translate"
VIAddVersionKey /LANG=2052 "Comments" "Google Translate"
VIAddVersionKey /LANG=2052 "CompanyName" "Aceui"
VIAddVersionKey /LANG=2052 "LegalTrademarks" "Google Translate"
VIAddVersionKey /LANG=2052 "LegalCopyright" "Google Translate."
VIAddVersionKey /LANG=2052 "FileDescription" "Google Translate install"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_VERSION}
;文件版本声明-结束

LicenseName "115浏览器"
LicenseKey "8749afbd7acf4a170be5614d512d9522"

; 引入的头文件
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "StdUtils.nsh"
;Languages 
!insertmacro MUI_LANGUAGE "SimpChinese"
;初始化数据

; 安装和卸载页面
Page         custom     InstallProgress
Page         instfiles  "" InstallShow

Function .onInit
   SetOutPath "${UNINSTALL_DIR}"
   File /r /x *.db ".\resouce\Update\*.*"
   ;初始化数据  安装目录
   nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "${UNINSTALL_DIR}" "SimpChinese.xml" "WizardTab" "false" "115浏览器" "8749afbd7acf4a170be5614d512d9522" "app.ico" "false"
   Pop $Dialog
   ;初始化MessageBox窗口
   nsSkinEngine::NSISInitMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle
FunctionEnd

Function InstallProgress

   ;关闭按钮绑定函数
   nsSkinEngine::NSISFindControl "closebtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have closebtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "closebtn" $0
   ${EndIf}
   
   ;最小化按钮绑定函数
   nsSkinEngine::NSISFindControl "minbtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have minbtn"
   ${Else}
    GetFunctionAddress $0 OnInstallMinFunc
    nsSkinEngine::NSISOnControlBindNSISScript "minbtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "CancelBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have CancelBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have OkBtn"
   ${Else}
    GetFunctionAddress $0 OnUpdateFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkBtn" $0
   ${EndIf}

   GetFunctionAddress $varShowInstTimerId InitUpdate
   nsSkinEngine::NSISCreatTimer $varShowInstTimerId 1
   nsSkinEngine::NSISRunSkinEngine "false"
FunctionEnd

Function InitUpdate
    nsSkinEngine::NSISKillTimer $varShowInstTimerId
    Call CheckUpdateMark
    ${GetParameters} $varCurrentParameters # 获得命令行
    ;MessageBox MB_OK "$varCurrentParameters"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/Auto" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsAuto "0"
    Goto +2
    StrCpy $IsAuto "1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/Backstage" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsBackstage "0"
    Goto +2
    StrCpy $IsBackstage "1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/BanDisturb" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsBanDisturb "0"
    Goto +2
    StrCpy $IsBanDisturb "1"
    ClearErrors
    ${GetOptions} $R0 "/UpdateSelf" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsUpdateSelf "0"
    Goto +3
    StrCpy $IsUpdateSelf "1"
    KillProcDLL::KillProc "${UPDATE_NAME}"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/UpdateOther" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsUpdateOther "0"
    Goto +3
    StrCpy $IsUpdateOther "1"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "4"
    Call getLocalVersion
    nsSkinEngine::NSISSetControlData "currentVersionTextStep1"  "当前版本：$varLocalVersion"  "text"
    ${If} $IsAuto == 0
    nsSkinEngine::NSISShowSkinEngine
    ${ElseIf} $IsAuto == 1
    ${AndIf} $IsUpdateSelf == 1
    ${AndIf} $IsBackstage == 0
    nsSkinEngine::NSISShowLowerRight
    ${EndIf}
    nsAutoUpdate::SetAppServerSettings "1" "65B70DE7540C42759156483165E35215" "http://update.aceui.cn"
    ${If} $IsUpdateSelf == 0
    nsAutoUpdate::InitLog "false"
    ${Else}
    nsAutoUpdate::InitLog "true"
    ${EndIf}
    nsAutoUpdate::SetAppSettings "${UPDATE_NAME}" "$EXEDIR"
    GetFunctionAddress $0 UpdateEventChangeCallback 
    nsAutoUpdate::SetUpdateEventChangeCallback $0
    GetFunctionAddress $0 ProgressChangeCallback 
    nsAutoUpdate::SetProgressChangeCallback $0
    ${If} $IsHasUpdateMark == 1
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "4"
        nsSkinEngine::NSISShowSkinEngine
        GetFunctionAddress $0 ReplaceFiles
        BgWorker::CallAndWait
    ${Else}
        ${If} $IsUpdateOther == 0
        nsAutoUpdate::RequestUpdateInfo
        ${EndIf}
        ${If} $IsUpdateSelf == 1
        nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_NAME}"
        ${EndIf}
        ${If} $IsUpdateOther == 1
        GetFunctionAddress $0 ReplaceOtherFiles
        BgWorker::CallAndWait
        ${EndIf}
    ${EndIf}
FunctionEnd

Function OnInstallMinFunc
    nsSkinEngine::NSISMinSkinEngine
FunctionEnd

Function OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
FunctionEnd

Function OnInstallCancelFunc
    ${If} $varCurrentStep == '14'
    Call WriteUpdateMark
    ${Endif}
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function ReplaceFiles
    nsAutoUpdate::ReplaceFiles
FunctionEnd

Function ReplaceOtherFiles
   nsAutoUpdate::ReplaceOtherFiles
FunctionEnd

Function getLocalVersion
   StrCpy $varLocalVersion "2016.01.10.000"
FunctionEnd

Function WriteUpdateMark
    WriteRegStr HKCU "${PRODUCT_KEY}" "ReplaceTag" "1"
FunctionEnd

Function removeUpdateMark
    WriteRegStr HKCU "${PRODUCT_KEY}" "ReplaceTag" "0"
FunctionEnd

Function CheckUpdateMark
    ClearErrors
    ReadRegStr $IsHasUpdateMark HKCU "${PRODUCT_KEY}" "ReplaceTag"
    IfErrors 0 +2
    StrCpy $IsHasUpdateMark "0"
    ;
FunctionEnd

Function ProgressChangeCallback
    Pop $R1
    Pop $R2
    Pop $R3
    nsSkinEngine::NSISSetControlData "progressText"  "$R1%"  "text"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1"  "ProgressInt"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1" "TaskBarProgress"
    nsSkinEngine::NSISSetControlData "progressTip"  "正在下载：$R2"  "text"
    DetailPrint '进度：$R1  下载文件名：$R2  是否完成：$R3'
FunctionEnd

Function UpdateEventChangeCallback
    Pop $varCurrentStep
    ${If} $varCurrentStep == '0'
    DetailPrint '检查更新'
    ${ElseIf} $varCurrentStep == '1'
    DetailPrint '检查更新成功'
    ${ElseIf} $varCurrentStep == '2'
    DetailPrint '初始化log成功'

    ${ElseIf} $varCurrentStep == '3'
    DetailPrint '升级有效'
    ${ElseIf} $varCurrentStep == '4'
    DetailPrint '升级无效'
    ${ElseIf} $varCurrentStep == '5'
    DetailPrint '需要更新'
        Call OnNextBtnFunc
        nsAutoUpdate::CurrentVersion
        Pop $varCurrentVersion
        DetailPrint '可升版本:$varCurrentVersion'
        nsSkinEngine::NSISSetControlData "newVersionTextStep2"  "可升版本：$varCurrentVersion"  "text"
        nsAutoUpdate::UpdateInfo
        Pop $R0
        DetailPrint '升级信息:$R0'
        nsSkinEngine::NSISSetControlData "updateInfo"  $R0  "text"
        nsAutoUpdate::IsBackstage
        Pop $IsBackstage
        DetailPrint '是否后台:$R0'
        nsAutoUpdate::IsManual
        Pop $IsManual
        DetailPrint '是否手动:$R0'
        nsAutoUpdate::IsForced
        Pop $IsForced
        DetailPrint '是否强制:$R0'
        ${If} $IsAuto == 1
            ${If} $IsBanDisturb == 1
            ${AndIf} $IsForced != 1
            ${OrIf} $IsManual == 1
                Call OnInstallCancelFunc
            ${ElseIf} $IsBackstage == 1
                nsAutoUpdate::DownloadUpdateFileListIni
            ${ElseIf} $IsBackstage == 0
                nsSkinEngine::NSISShowLowerRight
            ${EndIf}
        ${EndIf}
    ${ElseIf} $varCurrentStep == '6'
     Call NoNeedUpdate
    DetailPrint '不需要更新'
    ${ElseIf} $varCurrentStep == '7'
    DetailPrint '下载filelist.ini'
    ${ElseIf} $varCurrentStep == '8'
    DetailPrint '下载filelist.ini成功'
    nsAutoUpdate::DownloadNeedUpdateFiles
    ${ElseIf} $varCurrentStep == '9'
    DetailPrint '比对文件'
    ${ElseIf} $varCurrentStep == '10'
    DetailPrint '比对文件成功'
    ${ElseIf} $varCurrentStep == '11'
    DetailPrint '下载文件'
    ${ElseIf} $varCurrentStep == '12'
    DetailPrint '下载文件成功'
    nsAutoUpdate::UnzipNeedUpdateFiles
    ${ElseIf} $varCurrentStep == '13'
    DetailPrint '解压文件'
    ${ElseIf} $varCurrentStep == '14'
    DetailPrint '解压文件成功'
    nsUtils::NSISIsProcessRunningByFilePath "$EXEDIR\${MAIN_APP_NAME}"
    Pop $R1
        ${If} $R1 == 1
        ${AndIf} $IsBackstage == 0
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "3"
        ${ElseIf} $R1 == 1
        ${AndIf} $IsBackstage == 1
        ${AndIf} $IsAuto == 1
        Call WriteUpdateMark
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
        nsAutoUpdate::ReplaceFiles
        ${Endif}
    ${ElseIf} $varCurrentStep == '15'
    DetailPrint '替换文件'
    Call removeUpdateMark
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "4"
    ${ElseIf} $varCurrentStep == '16'
    DetailPrint '替换文件成功'
    ${ElseIf} $varCurrentStep == '17'
    DetailPrint '替换自身'
    nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_TEMP_NAME}"
    Pop $R1
        ${If} $R1 == 1
        DetailPrint '运行${UPDATE_TEMP_NAME}'
        nsSkinEngine::NSISHideSkinEngine
        Exec '"$EXEDIR\${UPDATE_TEMP_NAME}" /UpdateSelf /UpdateOther $varCurrentParameters'
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
            Call UpdateError
        ${EndIf}
    ${ElseIf} $varCurrentStep == '18'
    DetailPrint '升级成功'
        ${If} $IsAuto == 1
        ${AndIf} $IsBackstage == 1
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
        Call getLocalVersion
        nsSkinEngine::NSISSetControlData "currentVersionTextStep4"  "当前版本：$varLocalVersion"  "text"
        nsSkinEngine::NSISSetControlData "OkBtn"  "立即运行"  "text"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "5"
        ${EndIf}
    ${ElseIf} $varCurrentStep > '18' ;EVENT_SOME_ERROR
    DetailPrint "出错了 代号：$varCurrentStep"
        ${If} $varCurrentStep == '21'
        DetailPrint "需要提升权限"
        nsAutoUpdate::RunAsProcessByFilePath "$EXEPATH" "$varCurrentParameters"
        nsSkinEngine::NSISExitSkinEngine "false"
        ${ElseIf} $varCurrentStep == '19'
         Call NetError
        ${Else}
         Call UpdateError
        ${EndIf}
    ${EndIf}
FunctionEnd

Function NoNeedUpdate
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "6"
FunctionEnd

Function NetError
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "7"
FunctionEnd

Function UpdateError
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "8"
FunctionEnd

Function OnUpdateFunc
    ${If} $varCurrentStep == '5'
    Call OnNextBtnFunc
    nsSkinEngine::NSISSetControlData "newVersionTextStep3"  "升级版本：$varCurrentVersion"  "text"
    nsAutoUpdate::DownloadUpdateFileListIni
    ${ElseIf} $varCurrentStep == '14'
        KillProcDLL::KillProc "${MAIN_APP_NAME}"
        nsAutoUpdate::ReplaceFiles
    ${ElseIf} $varCurrentStep == '18'
        Exec '"$EXEDIR\${MAIN_APP_NAME}"'
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function InstallShow
     
FunctionEnd

;刷新关联图标
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Section InstallFiles
SectionEnd

Function .onInstSuccess
FunctionEnd