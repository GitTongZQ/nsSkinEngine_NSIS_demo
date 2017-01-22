/*
    Compile the script to use the Unicode version of NSIS
    The producers��surou
*/
;ExecShell taskbarunpin "$DESKTOP\${PRODUCT_NAME}.lnk"��ɾ��������ͼ��

;��װ�� ��ѹ�հ�
!system '>blank set/p=MSCF<nul'
!packhdr temp.dat 'cmd /c Copy /b temp.dat /b +blank&&del blank'

;�������
Var Dialog
Var MessageBoxHandle
Var installPath
Var FreeSpaceSize

; ��װ�����ʼ���峣��
!define PRODUCT_VERSION "2016.02.16.000"
!define MAIN_APP_NAME "wpsmail.exe"
!define PRODUCT_NAME "WPS Mail"
!define PRODUCT_NAME_EN "WPS Mail"
!define PRODUCT_PUBLISHER "Kingsoft Corporation"
!define PRODUCT_WEB_SITE "http://www.wps.cn"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_NAME}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_AUTORUN_KEY "Software\Microsoft\Windows\CurrentVersion\Run"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define MUI_ICON "resouce\WPS_Mail\nsis_res\mui_icon.ico"
!define MUI_UNICON "resouce\WPS_Mail\nsis_res_uninst\mui_unicon.ico"
!define UNINSTALL_DIR "$TEMP\ACEUI\BoltStep"
;ˢ�¹���ͼ��
!define SHCNE_ASSOCCHANGED 0x08000000
!define SHCNF_IDLIST 0
; ��װ����Ҫ����
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
; �����ļ����Ǳ��
SetOverwrite on
; ����ѹ��ѡ��
SetCompress auto
; ѡ��ѹ����ʽ
SetCompressor /SOLID lzma
SetCompressorDictSize 32
; �������ݿ��Ż�
SetDatablockOptimize on
; ������������д���ļ�ʱ��
SetDateSave on
;����Unicode ���� 3.0���ϰ汾֧��
Unicode false
; �Ƿ�����װ�ڸ�Ŀ¼��
AllowRootDirInstall false
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "output\WpsMailSetup.exe"
InstallDir "$PROGRAMFILES\WPS Mail"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
;Request application privileges for Windows Vista
RequestExecutionLevel admin
;�ļ��汾����-��ʼ
VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "WPS Mail"
VIAddVersionKey /LANG=2052 "Comments" "Kingsoft Bolt Mail Client"
VIAddVersionKey /LANG=2052 "CompanyName" "Kingsoft Corporation"
VIAddVersionKey /LANG=2052 "LegalTrademarks" "Bolt is a Trademark of Kingsoft"
VIAddVersionKey /LANG=2052 "LegalCopyright" "Kingsoft and Mozilla Developers, according to the MPL 1.1/GPL 2.0/LGPL 2.1 licenses, as applicable."
VIAddVersionKey /LANG=2052 "FileDescription" "WPS Mail install"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_VERSION}
;�ļ��汾����-����

LicenseName "WPS����"
LicenseKey "c9febcaa5f1519ab06c5f67878499e29"

; �����ͷ�ļ�
!include  "MUI.nsh"
!include "FileFunc.nsh"
; �����dll
ReserveFile "${NSISDIR}\Plugins\x86-unicode\nsSkinEngine.dll"
;Languages 
!insertmacro MUI_LANGUAGE "SimpChinese"
;��ʼ������

; ��װ��ж��ҳ��
Page         custom     InstallProgress
Page         instfiles  "" InstallShow
UninstPage   custom     un.UninstallProgress
UninstPage   instfiles	""	un.UninstallNow
Function .onInit
   SetOutPath "${UNINSTALL_DIR}"
   File /r /x *.db ".\resouce\WPS_Mail\nsis_res\*.*"
   ;��ʼ������  ��װĿ¼
   nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "${UNINSTALL_DIR}" "InstallPackages.xml" "WizardTab" "true" "WPS����" "c9febcaa5f1519ab06c5f67878499e29" "mui_icon.ico" "true"
   Pop $Dialog
   ;��ʼ��MessageBox����
   nsSkinEngine::NSISInitMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle
   
 ;���������ֹ�ظ�����
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "BoltInstall") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
    nsSkinEngine::NSISMessageBox "" "��һ�� WPS Mail ��װ���Ѿ����У�"
    Abort

  KillProcDLL::KillProc "${MAIN_APP_NAME}"     ;ǿ�ƽ�������

 
  ReadRegStr $installPath HKLM "SOFTWARE\kingsoft\WpsMail" "installDir"
  ${If} $installPath == ""
    ;��ʼ����װλ�� $APPDATA
    StrCpy $installPath "$PROGRAMFILES\WPS Mail"
  ${EndIf}
FunctionEnd

Function InstallProgress
   ;�رհ�ť�󶨺���
   nsSkinEngine::NSISFindControl "InstallTab_sysCloseBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have InstallTab_sysCloseBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_sysCloseBtn" $0
   ${EndIf}

   ;-------------------------��ӭ����----------------------
   ;��һ����ť�󶨺���
   nsSkinEngine::NSISFindControl "WelcomeTab_NextBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have WelcomeTab_NextBtn button"
   ${Else}
    GetFunctionAddress $0 OnNextBtnFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "WelcomeTab_NextBtn"  $0
   ${EndIf}
   
   ;------------------------��װ����-----------------------

    ;��װ·���༭���趨����
   nsSkinEngine::NSISFindControl "InstallTab_InstallFilePath"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have InstallTab_InstallFilePath"
   ${Else}
   
    GetFunctionAddress $0 OnTextChangeFunc
    nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_InstallFilePath" $0
    nsSkinEngine::NSISSetControlData "InstallTab_InstallFilePath" $installPath "text"
    Call OnTextChangeFunc
   ${EndIf}

   ;��װ·�������ť�󶨺���
   nsSkinEngine::NSISFindControl "InstallTab_SelectFilePathBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have InstallTab_SelectFilePathBtn button"
   ${Else}
    GetFunctionAddress $0 OnInstallPathBrownBtnFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_SelectFilePathBtn"  $0
   ${EndIf}

   ;��ʼ��װ��ť�󶨺���
   nsSkinEngine::NSISFindControl "InstallTab_InstallBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have InstallTab_InstallBtn button"
   ${Else}
    GetFunctionAddress $0 InstallPageFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_InstallBtn"  $0
   ${EndIf}
   ;--------------------------------------���ҳ��----------------------------------
   nsSkinEngine::NSISFindControl "CompleteTab_CompleteBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have CompleteTab_CompleteBtn button"
   ${Else}
    GetFunctionAddress $0 OnCompleteBtnFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "CompleteTab_CompleteBtn"  $0
   ${EndIf}
   ;--------------------------------------������ʾ-----------------------------------
   GetFunctionAddress $0 goAheadCallback
   GetFunctionAddress $1 retreatCallback
   nsSkinEngine::NSISInitAnimationBkControl "windowbk" "${UNINSTALL_DIR}\step" "145" "90" "1" "68" $0 $1
   nsSkinEngine::NSISStartAnimationBkControl "windowbk" "0" "33"
   nsSkinEngine::NSISSetControlData "welcomeText"  "false"  "visible"
   nsSkinEngine::NSISRunSkinEngine "true"
FunctionEnd

Function goAheadCallback
    nsSkinEngine::NSISSetControlData "welcomeText"  "true"  "visible"
FunctionEnd

Function retreatCallback
    nsSkinEngine::NSISSetControlData "WelcomeTab_NextBtn"  "false"  "visible"
    nsSkinEngine::NSISSetControlData "welcomeText"  "false"  "visible"
FunctionEnd

Function OnBackBtnFunc
   nsSkinEngine::NSISBackTab "WizardTab"
FunctionEnd

Function OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
   Call goAheadCallback
   nsSkinEngine::NSISStartAnimationBkControl "windowbk" "90" "33"
FunctionEnd

Function OnInstallCancelFunc
   nsSkinEngine::NSISMessageBox "" " ȷ��Ҫ�˳�WPS�ʼ��İ�װ��"
   ;nsSkinEngine::NSISSendMessage $Dialog WM_NSISCANCEL "Wps Mail��װ" "ȷ��Ҫ�˳�Wps Mail��װ��"
   Pop $0
    ${If} $0 == "1"
     nsSkinEngine::NSISExitSkinEngine "true"
   ${EndIf} 
FunctionEnd

Function UpdateFreeSpace
  ${GetRoot} $INSTDIR $0
  StrCpy $1 "Bytes"

  System::Call kernel32::GetDiskFreeSpaceEx(tr0,*l,*l,*l.r0)
   ${If} $0 > 1024
   ${OrIf} $0 < 0
      System::Int64Op $0 / 1024
      Pop $0
      StrCpy $1 "KB"
      ${If} $0 > 1024
      ${OrIf} $0 < 0
     System::Int64Op $0 / 1024
     Pop $0
     StrCpy $1 "MB"
     ${If} $0 > 1024
     ${OrIf} $0 < 0
        System::Int64Op $0 / 1024
        Pop $0
        StrCpy $1 "GB"
     ${EndIf}
      ${EndIf}
   ${EndIf}

   StrCpy $FreeSpaceSize  "$0$1"
FunctionEnd

Function FreshInstallDataStatusFunc
    ;���´��̿ռ��ı���ʾ
   nsSkinEngine::NSISFindControl "InstallTab_FreeSpace"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have InstallTab_FreeSpace"
   ${Else}
    nsSkinEngine::NSISSetControlData "InstallTab_FreeSpace"  $FreeSpaceSize  "text"
   ${EndIf}
   ;·���Ƿ�Ϸ����Ϸ���Ϊ0Bytes��
   ${If} $FreeSpaceSize == "0Bytes"
    nsSkinEngine::NSISSetControlData "InstallTab_InstallBtn" "false" "enable"
   ${Else}
    nsSkinEngine::NSISSetControlData "InstallTab_InstallBtn" "true" "enable"
   ${EndIf}
FunctionEnd

Function OnTextChangeFunc
   ; �ı���ô��̿ռ��С
   nsSkinEngine::NSISGetControlData InstallTab_InstallFilePath "text"
   Pop $0
   ;nsSkinEngine::NSISMessageBox ""  $0
   StrCpy $INSTDIR $0

   ;���»�ȡ���̿ռ�
   Call UpdateFreeSpace
   Call FreshInstallDataStatusFunc
FunctionEnd

Function OnInstallPathBrownBtnFunc
   nsSkinEngine::NSISGetControlData "InstallTab_InstallFilePath" "text" ;
   Pop $installPath
   nsSkinEngine::NSISSelectFolderDialog "��ѡ���ļ���" $installPath
   Pop $installPath

   StrCpy $0 $installPath
   ${If} $0 == "-1"
   ${Else}
      StrCpy $INSTDIR "$installPath\${PRODUCT_NAME_EN}"
      ;���ð�װ·���༭���ı�
      nsSkinEngine::NSISFindControl "InstallTab_InstallFilePath"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox ""  "Do not have Wizard_InstallPathBtn4Page2 button"
      ${Else}
     ;nsSkinEngine::SetText2Control "InstallTab_InstallFilePath"  $installPath
     StrCpy $installPath $INSTDIR
     nsSkinEngine::NSISSetControlData "InstallTab_InstallFilePath"  $installPath  "text"
      ${EndIf}
   ${EndIf}

   ;���»�ȡ���̿ռ�
   Call UpdateFreeSpace
   Call FreshInstallDataStatusFunc
FunctionEnd

Function InstallPageFunc
    nsSkinEngine::NSISSetControlData "InstallTab_sysCloseBtn"  "false"  "enable"
    ;���ý�����
    nsSkinEngine::NSISSetControlData "CompleteTab_RunAppCheckBox"  "true" "Checked" ;Ĭ�Ϲ�ѡ���г���
    nsSkinEngine::NSISFindControl "InstallProgressBar"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox ""  "Do not have InstallProgressBar"
      ${Else}
     nsSkinEngine::NSISSetControlData "InstallProgressBar"  "0"  "ProgressInt"
     nsSkinEngine::NSISSetControlData "progressText"  "0%"  "text"
     nsSkinEngine::NSISStartInstall "true"
     ${EndIf} 
FunctionEnd

Function InstallShow
     nsSkinEngine::NSISFindControl "InstallProgressBar"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox ""  "Do not have InstallProgressBar"
      ${Else}
     nsSkinEngine::NSISBindingProgress "InstallProgressBar" "progressText"
	 ${EndIf}
FunctionEnd

Section InstallFiles
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File /r "bin\*.*"
SectionEnd

Section RegistKeys
    WriteUninstaller "$INSTDIR\uninst.exe"
    WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\${MAIN_APP_NAME}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\${MAIN_APP_NAME},0"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Section CreateShorts
    WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
    SetShellVarContext all
    ;������ʼ�˵���ݷ�ʽ
    CreateDirectory "$SMPROGRAMS\WPS Mail"
    CreateShortCut "$SMPROGRAMS\WPS Mail\${PRODUCT_NAME}.lnk" "$INSTDIR\${MAIN_APP_NAME}"
    CreateShortCut "$SMPROGRAMS\WPS Mail\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
    CreateShortCut "$SMPROGRAMS\WPS Mail\Uninstall.lnk" "$INSTDIR\uninst.exe"
    SetOverwrite ifnewer
    ;���������ݷ�ʽ
    CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${MAIN_APP_NAME}"
/* 	CreateShortCut "$QUICKLAUNCH\${PRODUCT_NAME}.lnk" "$INSTDIR\${MAIN_APP_NAME}"
	System::Call 'shell32.dll::ShellExecute(i 0, t "taskbarpin", t "$QUICKLAUNCH\${PRODUCT_NAME}.lnk", i 0, i 0, i 0)  i .r1 ?e' */
    Call RefreshShellIcons
SectionEnd

Section Finish
SectionEnd

Function OnCompleteBtnFunc
    nsSkinEngine::NSISHideSkinEngine
    nsSkinEngine::NSISStopAnimationBkControl "windowbk"
    nsSkinEngine::NSISGetControlData "CompleteTab_AutoRunCheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
      WriteRegStr HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}" "$INSTDIR\${MAIN_APP_NAME} -mini"
    ${EndIf}

    nsSkinEngine::NSISGetControlData "CompleteTab_RunAppCheckBox" "Checked" ;
    Pop $0
   ${If} $0 == "1"
     Exec '"$INSTDIR\${MAIN_APP_NAME}"'
   ${EndIf}
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------------

Function un.onInit
  ;���������ֹ�ظ�����
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "BoltUnInstall") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
    nsSkinEngine::NSISMessageBox "" "��һ�� WPS Mail ��װ���Ѿ����У�"
    Abort

  SetOutPath "${UNINSTALL_DIR}"
  File /r /x *.db ".\resouce\WPS_Mail\nsis_res_uninst\*.*"
  
  KillProcDLL::KillProc "${MAIN_APP_NAME}"     ;ǿ�ƽ�������
FunctionEnd

Function un.UninstallProgress
    nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "${UNINSTALL_DIR}" "UninstallPackages.xml" "WizardTab" "false" "WPS����" "c9febcaa5f1519ab06c5f67878499e29" "${UNINSTALL_DIR}\mui_unicon.ico"
   Pop $Dialog
   ;��ʼ��MessageBox����
   nsSkinEngine::NSISInitMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle
   
   ;�رհ�ť�󶨺���
   nsSkinEngine::NSISFindControl "sysCloseBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have sysCloseBtn"
   ${Else}
    GetFunctionAddress $0 un.OnUnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "sysCloseBtn" $0
   ${EndIf}
   
   ;ȡ����ť�󶨺���
   nsSkinEngine::NSISFindControl "cancelUninstallBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have cancelUninstallBtn"
   ${Else}
    GetFunctionAddress $0 un.OnUnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "cancelUninstallBtn" $0
   ${EndIf}
   
   ;��ϵ���ǰ�ť 
   nsSkinEngine::NSISFindControl "contactbtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have contactbtn"
   ${Else}
    GetFunctionAddress $0 un.contactUs
    nsSkinEngine::NSISOnControlBindNSISScript "contactbtn" $0
   ${EndIf}
   
   ;����ж�� okUninstallBtn
   nsSkinEngine::NSISFindControl "okUninstallBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have okUninstallBtn"
   ${Else}
    GetFunctionAddress $0 un.UnInstallPageFunc
    nsSkinEngine::NSISOnControlBindNSISScript "okUninstallBtn" $0
   ${EndIf}
   
   ;ж����� completeBtn
   nsSkinEngine::NSISFindControl "completeBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have completeBtn"
   ${Else}
    GetFunctionAddress $0 un.OnCompleteBtnFunc
    nsSkinEngine::NSISOnControlBindNSISScript "completeBtn" $0
   ${EndIf}
   
   ;����1
   nsSkinEngine::NSISFindControl "question1btn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have question1btn"
   ${Else}
    GetFunctionAddress $0 un.question1
    nsSkinEngine::NSISOnControlBindNSISScript "question1btn" $0
   ${EndIf}
   
   ;����2
   nsSkinEngine::NSISFindControl "question2btn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have question2btn"
   ${Else}
    GetFunctionAddress $0 un.question2
    nsSkinEngine::NSISOnControlBindNSISScript "question2btn" $0
   ${EndIf}
   
   ;����3
   nsSkinEngine::NSISFindControl "question3btn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox ""  "Do not have question3btn"
   ${Else}
    GetFunctionAddress $0 un.question3
    nsSkinEngine::NSISOnControlBindNSISScript "question3btn" $0
   ${EndIf}
   ;--------------------------------------������ʾ-----------------------------------
   nsSkinEngine::NSISSetControlData "SavaData_CheckBox"  "true"  "Checked"
   nsSkinEngine::NSISRunSkinEngine "true"
FunctionEnd

Function un.OnUnInstallCancelFunc
   nsSkinEngine::NSISMessageBox "" " ȷ��Ҫ�˳�WPS�ʼ���ж�أ�"
   Pop $0
    ${If} $0 == "1"
     nsSkinEngine::NSISExitSkinEngine "false"
   ${EndIf} 
FunctionEnd

Function un.OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
FunctionEnd

Function un.UnInstallPageFunc
    nsSkinEngine::NSISSetControlData "okUninstallBtn2"  "false"  "enable"
    nsSkinEngine::NSISSetControlData "cancelUninstallBtn2"  "false"  "enable"
	nsSkinEngine::NSISSetControlData "progressTip"  "����ɾ��WPS����"  "text"
    nsSkinEngine::NSISStartUnInstall "true"
FunctionEnd

Function un.UninstallNow
     nsSkinEngine::NSISFindControl "UnInstallProgressBar"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox ""  "Do not have UnInstallProgressBar"
      ${Else}
     nsSkinEngine::NSISBindingProgress "UnInstallProgressBar" "progressText"
	 ${EndIf}
FunctionEnd

Section "Uninstall"
    # ����Ϊ��ǰ�û�
    SetShellVarContext current
    nsSkinEngine::NSISGetControlData "SavaData_CheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "0"
     RMDir /r /REBOOTOK "$APPDATA\Kingsoft\Bolt"
    ${EndIf}
    # ����Ϊ�����û�
    SetShellVarContext all
    ;ɾ����������ݷ�ʽ
    ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
    ${if} $R0 >= 6.0  # Vista����  ����������
        ExecShell taskbarunpin "$DESKTOP\${PRODUCT_NAME}.lnk"
    ${else}           # XP����  ����������
        IfFileExists "$QUICKLAUNCH\${PRODUCT_NAME}.lnk" 0 +2
            Delete "$QUICKLAUNCH\${PRODUCT_NAME}.lnk";
    ${Endif}

    Delete "$SMPROGRAMS\WPS Mail\*.lnk"
    Delete "$SMPROGRAMS\WPS Mail\Uninstall.lnk"
    Delete "$SMPROGRAMS\WPS Mail\Website.lnk"
    Delete "$SMPROGRAMS\WPS Mail\${PRODUCT_NAME}.lnk"
    Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
    RMDir /r /REBOOTOK  "$SMPROGRAMS\WPS Mail"
    RMDir /r /REBOOTOK  "$INSTDIR"
	
	DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
    DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WPS Mail"
    DeleteRegKey HKLM "Software\Clients\Mail\WPS Mail"
    DeleteRegKey HKLM "Software\Clients\News\WPS Mail"
    DeleteRegKey HKLM "SOFTWARE\kingsoft\WpsMail"
    DeleteRegValue HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}"
    
SectionEnd

Function un.OnCompleteBtnFunc
    nsSkinEngine::NSISHideSkinEngine
    ;Call un.SendStatistics
    ;Call un.DeleteRegKey ;������ͳ���ٵ���ɾ��key,��Ϊ���Ϳ�����ҪĳЩ��ֵ
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

;ˢ�¹���ͼ��
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function un.contactUs
  ;nsSkinEngine::NSISSendMessage $Dialog WM_NSISOPENURL "";
FunctionEnd

Function un.question1
  ;nsSkinEngine::NSISSendMessage $Dialog WM_NSISOPENURL "";
FunctionEnd

Function un.question2
  ;nsSkinEngine::NSISSendMessage $Dialog WM_NSISOPENURL "";
FunctionEnd

Function un.question3
  ;nsSkinEngine::NSISSendMessage $Dialog WM_NSISOPENURL "";
FunctionEnd

Function .onInstSuccess
FunctionEnd