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
Var varShowInstTimerId
Var varCurrentStep
; 安装程序初始定义常量
!define PRODUCT_VERSION "2016.01.10.000"
!define MAIN_APP_NAME "GoogleTranslate.exe"
!define PRODUCT_NAME "Google Translate"
!define PRODUCT_NAME_EN "Google Translate"
!define PRODUCT_PUBLISHER "aceui"
!define PRODUCT_WEB_SITE "http://www.aceui.cn"
!define PRODUCT_2345WEB_SITE "http://www.2345.com/?k652511569"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_NAME}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_AUTORUN_KEY "Software\Microsoft\Windows\CurrentVersion\Run"
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
   
   nsSkinEngine::NSISSetControlData "userFuckCheckBox"  "true"  "Checked"
   GetFunctionAddress $varShowInstTimerId InitUpdate
   nsSkinEngine::NSISCreatTimer $varShowInstTimerId 1000
   nsSkinEngine::NSISRunSkinEngine
FunctionEnd

Function InitUpdate
    nsSkinEngine::NSISKillTimer $varShowInstTimerId
    ${GetParameters} $R0 # 获得命令行
    ;MessageBox MB_OK "$R0"
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
    Goto +2
    StrCpy $IsUpdateOther "1"
    nsAutoUpdate::SetAppServerSettings "1" "65B70DE7540C42759156483165E35215" "http://update.aceui.cn/api/Public/Update/?"
    IntCmp $IsUpdateSelf 1 +3
    nsAutoUpdate::InitLog "false"
    Goto +2
    nsAutoUpdate::InitLog "true"
    nsAutoUpdate::SetAppSettings "${UPDATE_NAME}" "$EXEDIR"
    GetFunctionAddress $0 UpdateEventChangeCallback 
    nsAutoUpdate::SetUpdateEventChangeCallback $0
    GetFunctionAddress $0 ProgressChangeCallback 
    nsAutoUpdate::SetProgressChangeCallback $0
    
    IntCmp $IsUpdateOther 1 +2
    nsAutoUpdate::RequestUpdateInfo
    IntCmp $IsUpdateSelf 0 +2
    nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_NAME}"
    IntCmp $IsUpdateOther 0 +3
    GetFunctionAddress $0 ReplaceOtherFiles
    BgWorker::CallAndWait
    ;
FunctionEnd

Function OnInstallMinFunc
    nsSkinEngine::NSISMinSkinEngine
FunctionEnd

Function OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
FunctionEnd

Function OnInstallCancelFunc
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function ReplaceOtherFiles
   nsAutoUpdate::ReplaceOtherFiles
FunctionEnd

Function ProgressChangeCallback
    Pop $R1
    Pop $R2
    Pop $R3
    nsSkinEngine::NSISSetControlData "progressText"  "$R1%"  "text"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1"  "ProgressInt"
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
    Pop $R0
    DetailPrint '最新版本:$R0'
    nsSkinEngine::NSISSetControlData "newVersionTextStep2"  $R0  "text"
    nsAutoUpdate::UpdateInfo
    Pop $R0
    DetailPrint '升级信息:$R0'
    nsSkinEngine::NSISSetControlData "updateInfo"  $R0  "text"
    nsAutoUpdate::IsBackstage
    Pop $R0
    DetailPrint '是否后台:$R0'
    nsAutoUpdate::IsManual
    Pop $R0
    DetailPrint '是否手动:$R0'
    nsAutoUpdate::IsForced
    Pop $R0
    DetailPrint '是否强制:$R0'
    DetailPrint '开始下载filelist.ini'
    ;nsAutoUpdate::DownloadUpdateFileListIni
    ${ElseIf} $varCurrentStep == '6'
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
    nsAutoUpdate::ReplaceFiles
    ${ElseIf} $varCurrentStep == '15'
    DetailPrint '替换文件'
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "4"
    ${ElseIf} $varCurrentStep == '16'
    DetailPrint '替换文件成功'
    ${ElseIf} $varCurrentStep == '17'
    DetailPrint '替换自身'
    nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_TEMP_NAME}"
    Pop $R1
    IntCmp $R1 0 +5
    DetailPrint '运行${UPDATE_TEMP_NAME}'
    nsSkinEngine::NSISHideSkinEngine
    Exec '"$EXEDIR\${UPDATE_TEMP_NAME}" /UpdateSelf /UpdateOther'
    nsSkinEngine::NSISExitSkinEngine "false"
    ;nsAutoUpdate::RunAsProcessByFilePath "$EXEDIR\${UPDATE_TEMP_NAME}" "/UpdateSelf /UpdateOther"
    Goto +2
    DetailPrint '替换${UPDATE_TEMP_NAME}失败'
    ${ElseIf} $varCurrentStep == '18'
    DetailPrint '升级成功'
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "5"
    ${ElseIf} $varCurrentStep > '18' ;EVENT_SOME_ERROR
    DetailPrint "出错了 代号：$varCurrentStep"
    ${If} $varCurrentStep == '21'
    DetailPrint "需要提升权限"
    nsAutoUpdate::RunAsProcessByFilePath "$EXEPATH" ""
    DetailPrint "退出"
    Abort
    ${EndIf}
    ${EndIf}
FunctionEnd

Function OnUpdateFunc
    ${If} $varCurrentStep == '5'
    Call OnNextBtnFunc
    nsAutoUpdate::DownloadUpdateFileListIni
    ${EndIf}
FunctionEnd

Function InstallShow
     
FunctionEnd

Function OnCompleteBtnFunc
    nsSkinEngine::NSISHideSkinEngine
    nsSkinEngine::NSISGetControlData "autoCheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
      WriteRegStr HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}" "$INSTDIR\${MAIN_APP_NAME} -mini"
    ${EndIf}
	
    Exec '"$INSTDIR\${MAIN_APP_NAME}"'
    nsSkinEngine::NSISExitSkinEngine "false"
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