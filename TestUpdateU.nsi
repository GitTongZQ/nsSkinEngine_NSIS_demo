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

; 安装程序初始定义常量
!define PRODUCT_VERSION "2016.01.11.000"
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
!define MUI_ICON "resouce\115Browser\app.ico"
!define MUI_UNICON "resouce\115Browser\app.ico"
!define UNINSTALL_DIR "$TEMP\ACEUI\aceuiStep"
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
OutFile "output\testUpdate.exe"
InstallDir "$PROGRAMFILES\Google Translate"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
;Request application privileges for Windows Vista
RequestExecutionLevel admin
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
   nsAutoUpdate::SetAppServerSettings "1" "65B70DE7540C42759156483165E35215" "http://update.aceui.cn/api/Public/Update/?"
   nsAutoUpdate::InitLog "false"
   nsAutoUpdate::SetAppSettings "$EXEFILE" "$EXEDIR"
   GetFunctionAddress $0 UpdateEventChangeCallback 
   nsAutoUpdate::SetUpdateEventChangeCallback $0
   GetFunctionAddress $0 ProgressChangeCallback 
   nsAutoUpdate::SetProgressChangeCallback $0
   nsAutoUpdate::RequestUpdateInfo
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
    ${ElseIf} $R0 == '18'
    DetailPrint '替换自身成功'
    ${ElseIf} $R0 == '19'
    DetailPrint '开始更新版本'
    ${ElseIf} $R0 == '20'
    DetailPrint '更新版本成功'
    ${ElseIf} $R0 == '21'
    DetailPrint '升级成功'
    ${ElseIf} $R0 > '21' ;EVENT_SOME_ERROR
    DetailPrint "出错了 代号：$R0"
    ${EndIf}
FunctionEnd

;刷新关联图标
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function .onInstSuccess
FunctionEnd