/*
    Compile the script to use the Unicode version of NSIS
    The producers：surou
*/
;ExecShell taskbarunpin "$DESKTOP\${PRODUCT_NAME}.lnk"是删除任务栏图标

;安装包 解压空白
!system '>blank set/p=MSCF<nul'
!packhdr temp.dat 'cmd /c Copy /b temp.dat /b +blank&&del blank'

;定义变量
Var IsUpdateSelf
Var IsUpdateOther
!define PRODUCT_VERSION "2016.01.10.000"
!define MUI_ICON "resouce\115Browser\app.ico"
!define MUI_UNICON "resouce\115Browser\app.ico"
!define UNINSTALL_DIR "$TEMP\ACEUI\aceuiStep"

!define UPDATE_TEMP_NAME "UpdateSelf.exe"
!define UPDATE_NAME "Update.exe"

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
OutFile "output\Update.exe"
InstallDir "$PROGRAMFILES\Google Translate"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
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

Function .onInit
    ${GetParameters} $R0 # 获得命令行
    MessageBox MB_OK "$R0"
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
    MessageBox MB_OK "$IsUpdateSelf $IsUpdateOther"
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
    IntCmp $IsUpdateOther 0 +2
    nsAutoUpdate::ReplaceOtherFiles
FunctionEnd

Section "xxxxx"
    
    
SectionEnd

Function ProgressChangeCallback
    Pop $R1
    Pop $R2
    Pop $R3
    DetailPrint '进度：$R1  下载明：$R2  是否完成：$R3'
FunctionEnd

Function UpdateEventChangeCallback
    Pop $R0
    ${If} $R0 == '0'
    DetailPrint '检查更新'
    ${ElseIf} $R0 == '1'
    DetailPrint '检查更新成功'
    ${ElseIf} $R0 == '2'
    DetailPrint '初始化log成功'

    ${ElseIf} $R0 == '3'
    DetailPrint '升级有效'
    ${ElseIf} $R0 == '4'
    DetailPrint '升级无效'
    ${ElseIf} $R0 == '5'
    DetailPrint '需要更新'
    nsAutoUpdate::CurrentVersion
    Pop $R0
    DetailPrint '最新版本:$R0'
    nsAutoUpdate::UpdateInfo
    Pop $R0
    DetailPrint '升级信息:$R0'
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
    nsAutoUpdate::DownloadUpdateFileListIni
    ${ElseIf} $R0 == '6'
    DetailPrint '不需要更新'
    ${ElseIf} $R0 == '7'
    DetailPrint '下载filelist.ini'
    ${ElseIf} $R0 == '8'
    DetailPrint '下载filelist.ini成功'
    nsAutoUpdate::DownloadNeedUpdateFiles
    ${ElseIf} $R0 == '9'
    DetailPrint '比对文件'
    ${ElseIf} $R0 == '10'
    DetailPrint '比对文件成功'
    ${ElseIf} $R0 == '11'
    DetailPrint '下载文件'
    ${ElseIf} $R0 == '12'
    DetailPrint '下载文件成功'
    nsAutoUpdate::UnzipNeedUpdateFiles
    ${ElseIf} $R0 == '13'
    DetailPrint '解压文件'
    ${ElseIf} $R0 == '14'
    DetailPrint '解压文件成功'
    nsAutoUpdate::ReplaceFiles
    ${ElseIf} $R0 == '15'
    DetailPrint '替换文件'
    ${ElseIf} $R0 == '16'
    DetailPrint '替换文件成功'
    ${ElseIf} $R0 == '17'
    DetailPrint '替换自身'
    nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_TEMP_NAME}"
    Pop $R1
    IntCmp $R1 0 +5
    DetailPrint '运行${UPDATE_TEMP_NAME}'
    Exec '"$EXEDIR\${UPDATE_TEMP_NAME}" /UpdateSelf /UpdateOther'
    ;nsAutoUpdate::RunAsProcessByFilePath "$EXEDIR\${UPDATE_TEMP_NAME}" "/UpdateSelf /UpdateOther"
    Goto +2
    DetailPrint '替换${UPDATE_TEMP_NAME}失败'
    ${ElseIf} $R0 == '18'
    DetailPrint '升级成功'
    ${ElseIf} $R0 > '18' ;EVENT_SOME_ERROR
    DetailPrint "出错了 代号：$R0"
    ${If} $R0 == '21'
    nsAutoUpdate::RunAsProcessByFilePath "$EXEPATH" ""
    Quit
    ${EndIf}
    ${EndIf}
FunctionEnd

;刷新关联图标
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function .onInstSuccess
FunctionEnd