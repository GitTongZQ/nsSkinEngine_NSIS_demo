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
Name "${PRODUCT_NAME}"
OutFile "output\115Browser.exe"
InstallDir "$PROGRAMFILES\Google Translate"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
;Request application privileges for Windows Vista
RequestExecutionLevel admin
;�ļ��汾����-��ʼ
VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "Google Translate"
VIAddVersionKey /LANG=2052 "Comments" "Google Translate"
VIAddVersionKey /LANG=2052 "CompanyName" "Aceui"
VIAddVersionKey /LANG=2052 "LegalTrademarks" "Google Translate"
VIAddVersionKey /LANG=2052 "LegalCopyright" "Google Translate."
VIAddVersionKey /LANG=2052 "FileDescription" "Google Translate install"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_VERSION}
;�ļ��汾����-����

; �����ͷ�ļ�
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "StdUtils.nsh"
;Languages 
!insertmacro MUI_LANGUAGE "SimpChinese"
;��ʼ������

; ��װ��ж��ҳ��
Page         custom     InstallProgress
Page         instfiles  "" InstallShow
UninstPage   custom     un.UninstallProgress
UninstPage   instfiles	""	un.UninstallNow
Function .onInit
   nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "${UNINSTALL_DIR}" "InstallPackages.xml" "WizardTab" "false" "115�����" "8749afbd7acf4a170be5614d512d9522" "app.ico" "true"
   Pop $Dialog
   ;��ʼ��MessageBox����
   nsSkinEngine::NSISInitMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle
   
 ;���������ֹ�ظ�����
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "ACEUIInstall") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
    nsSkinEngine::NSISMessageBox "" "��һ�� Google Translate ��װ���Ѿ����У�"
    Abort

  KillProcDLL::KillProc "${MAIN_APP_NAME}"     ;ǿ�ƽ�������

  SetOutPath "${UNINSTALL_DIR}"
  File /r /x *.db ".\resouce\115Browser\*.*"
  ;��ʼ������  ��װĿ¼
 
  ReadRegStr $installPath HKLM "SOFTWARE\aceui\115browser" "installDir"
  ${If} $installPath == ""
    ;��ʼ����װλ�� $APPDATA
    StrCpy $installPath "$PROGRAMFILES\Google Translate"
  ${EndIf}
FunctionEnd

Function InstallProgress

   ;�رհ�ť�󶨺���
   nsSkinEngine::NSISFindControl "InstallTab_sysCloseBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have InstallTab_sysCloseBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_sysCloseBtn" $0
   ${EndIf}

   ;------------------------��װ����-----------------------

    ;��װ·���༭���趨����
   nsSkinEngine::NSISFindControl "InstallTab_InstallFilePath"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have InstallTab_InstallFilePath"
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
    nsSkinEngine::NSISMessageBox "" "Do not have InstallTab_SelectFilePathBtn button"
   ${Else}
    GetFunctionAddress $0 OnInstallPathBrownBtnFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_SelectFilePathBtn"  $0
   ${EndIf}
   
	;չ���Զ���ѡ��
   nsSkinEngine::NSISFindControl "CustomOptionsCheckBox"
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have CustomOptionsCheckBox"
   ${Else}
    GetFunctionAddress $0 OnCheckChanged    
        nsSkinEngine::NSISOnControlBindNSISScript "CustomOptionsCheckBox"  $0
   ${EndIf}
   
   ;�Ƿ�ͬ��
   nsSkinEngine::NSISFindControl "acceptCheckBox"
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have acceptCheckBox"
   ${Else}
    GetFunctionAddress $0 acceptCheckChangedFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "acceptCheckBox"  $0
   ${EndIf}
   
   ;ʹ��Э��
   nsSkinEngine::NSISFindControl "acceptBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have acceptBtn button"
   ${Else}
    GetFunctionAddress $0 acceptPageFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "acceptBtn"  $0
   ${EndIf}
   
   ;ʹ��Э��ȷ��
   nsSkinEngine::NSISFindControl "okAcceptBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have okAcceptBtn button"
   ${Else}
    GetFunctionAddress $0 acceptOkFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "okAcceptBtn"  $0
   ${EndIf}
   
   ;��ʼ��װ��ť�󶨺���
   nsSkinEngine::NSISFindControl "InstallBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have InstallBtn button"
   ${Else}
    GetFunctionAddress $0 InstallPageFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "InstallBtn"  $0
   ${EndIf}
   ;--------------------------------------���ҳ��----------------------------------
   nsSkinEngine::NSISFindControl "CompleteTab_CompleteBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have CompleteTab_CompleteBtn button"
   ${Else}
    GetFunctionAddress $0 OnCompleteBtnFunc    
        nsSkinEngine::NSISOnControlBindNSISScript "CompleteTab_CompleteBtn"  $0
   ${EndIf}
   nsSkinEngine::NSISSetControlData "pop_ad_browser"  "http://www.aceui.cn"  "Navigate"
   ;--------------------------------------������ʾ-----------------------------------
   Call OnCheckChanged
   nsSkinEngine::NSISSetControlData "defaultAppCheckBox"  "true"  "Checked"
   nsSkinEngine::NSISSetControlData "acceptCheckBox"  "true"  "Checked"
   nsSkinEngine::NSISSetControlData "deskShortCheckBox"  "true"  "Checked"
   nsSkinEngine::NSISSetControlData "2345CheckBox"  "true"  "Checked"
   nsSkinEngine::NSISSetControlData "autoCheckBox"  "true"  "Checked"
   nsSkinEngine::NSISSetControlData "userFuckCheckBox"  "true"  "Checked"
   nsSkinEngine::NSISRunSkinEngine
FunctionEnd

Function OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
FunctionEnd

Function OnInstallCancelFunc
    nsSkinEngine::NSISExitSkinEngine "false"
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
    nsSkinEngine::NSISMessageBox "" "Do not have InstallTab_FreeSpace"
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
   ;nsSkinEngine::NSISMessageBox "" $0
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
     nsSkinEngine::NSISMessageBox "" "Do not have Wizard_InstallPathBtn4Page2 button"
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

Function OnCheckChanged
    nsSkinEngine::NSISGetControlData "CustomOptionsCheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
	nsSkinEngine::NSISResize "445" "608"
	nsSkinEngine::NSISSetControlData "customVer"  "true"  "visible"
	${Else}
	nsSkinEngine::NSISResize "445" "462"
	nsSkinEngine::NSISSetControlData "customVer"  "false"  "visible"
	${EndIf}
FunctionEnd

Function acceptCheckChangedFunc
	nsSkinEngine::NSISGetControlData "acceptCheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
		nsSkinEngine::NSISSetControlData "InstallBtn"  "true"  "enable"
	${Else}
		nsSkinEngine::NSISSetControlData "InstallBtn"  "false"  "enable"
    ${EndIf}
FunctionEnd

Function acceptPageFunc
	nsSkinEngine::NSISSetControlData "windowbk"  "1"  "TabCurrentIndexInt"
	nsSkinEngine::NSISShowLicense "acceptInfo" "license.txt"
FunctionEnd

Function acceptOkFunc
	nsSkinEngine::NSISSetControlData "windowbk"  "0"  "TabCurrentIndexInt"
FunctionEnd

Function InstallPageFunc
    nsSkinEngine::NSISSetControlData "InstallTab_sysCloseBtn"  "false"  "enable"
	nsSkinEngine::NSISResize "445" "462"
	nsSkinEngine::NSISSetControlData "customVer"  "false"  "visible"
    ;���ý�����
    nsSkinEngine::NSISSetControlData "CompleteTab_RunAppCheckBox"  "true" "Checked" ;Ĭ�Ϲ�ѡ���г���
    nsSkinEngine::NSISFindControl "InstallProgressBar"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox "" "Do not have InstallProgressBar"
      ${Else}
     nsSkinEngine::NSISSetControlData "InstallProgressBar"  "0"  "ProgressInt"
     nsSkinEngine::NSISSetControlData "progressText"  "0%"  "text"
     nsSkinEngine::NSISStartInstall
     ${EndIf} 
FunctionEnd

Function InstallShow
     nsSkinEngine::NSISFindControl "InstallProgressBar"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox "" "Do not have InstallProgressBar"
      ${Else}
     nsSkinEngine::NSISBindingProgress "InstallProgressBar" "progressText"
	 nsSkinEngine::NSISBindingDetail "progressDetail"
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
    CreateDirectory "$SMPROGRAMS\Google Translate"
    CreateShortCut "$SMPROGRAMS\Google Translate\${PRODUCT_NAME}.lnk" "$INSTDIR\${MAIN_APP_NAME}"
    CreateShortCut "$SMPROGRAMS\Google Translate\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
    CreateShortCut "$SMPROGRAMS\Google Translate\Uninstall.lnk" "$INSTDIR\uninst.exe"
    SetOverwrite ifnewer
	nsSkinEngine::NSISGetControlData "deskShortCheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
      ;���������ݷ�ʽ
		CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${MAIN_APP_NAME}"
    ${EndIf}
    
    ${StdUtils.InvokeShellVerb} $0 "$INSTDIR" "${MAIN_APP_NAME}" ${StdUtils.Const.ShellVerb.PinToTaskbar}
    Call RefreshShellIcons
SectionEnd

Section Finish
	nsSkinEngine::NSISSetControlData "InstallTab_sysCloseBtn"  "true"  "enable"
	nsSkinEngine::NSISGetControlData "2345CheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
      ;�����������ҳ
		WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Main" "Start Page" "${PRODUCT_2345WEB_SITE}"
    ${EndIf}
SectionEnd

Function OnCompleteBtnFunc
    nsSkinEngine::NSISHideSkinEngine
    nsSkinEngine::NSISStopAnimationBkControl
    nsSkinEngine::NSISGetControlData "autoCheckBox" "Checked" ;
    Pop $0
    ${If} $0 == "1"
      WriteRegStr HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}" "$INSTDIR\${MAIN_APP_NAME} -mini"
    ${EndIf}
	
    Exec '"$INSTDIR\${MAIN_APP_NAME}"'
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd


Function un.accept
  ;nsSkinEngine::NSISSendMessage $Dialog WM_NSISOPENURL "http://www.aceui.cn/";
FunctionEnd
;-----------------------------------------------------------------------------------------------------------------------------

Function un.onInit
  ;���������ֹ�ظ�����
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "aceuiUnInstall") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
    nsSkinEngine::NSISMessageBox "" "��һ�� 115����� ж�����Ѿ����У�"
    Abort

  SetOutPath "${UNINSTALL_DIR}"
  File /r /x *.db ".\resouce\115Browser\*.*"
  
  KillProcDLL::KillProc "${MAIN_APP_NAME}"     ;ǿ�ƽ�������
FunctionEnd

Function un.UninstallProgress
    nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "${UNINSTALL_DIR}" "UninstallPackages.xml" "WizardTab" "false" "115�����" "8749afbd7acf4a170be5614d512d9522" "app.ico" "true"
   Pop $Dialog
   ;��ʼ��MessageBox����
   nsSkinEngine::NSISInitMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle
   
   ;�رհ�ť�󶨺���
   nsSkinEngine::NSISFindControl "sysCloseBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have sysCloseBtn"
   ${Else}
    GetFunctionAddress $0 un.OnUnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "sysCloseBtn" $0
   ${EndIf}
   
   ;ȡ����ť�󶨺���
   nsSkinEngine::NSISFindControl "cancelUninstallBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have cancelUninstallBtn"
   ${Else}
    GetFunctionAddress $0 un.OnUnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "cancelUninstallBtn" $0
   ${EndIf}
 
   ;����ж�� okUninstallBtn
   nsSkinEngine::NSISFindControl "okUninstallBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have okUninstallBtn"
   ${Else}
    GetFunctionAddress $0 un.UnInstallPageFunc
    nsSkinEngine::NSISOnControlBindNSISScript "okUninstallBtn" $0
   ${EndIf}
   
   ;ж����� completeBtn
   nsSkinEngine::NSISFindControl "completeBtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have completeBtn"
   ${Else}
    GetFunctionAddress $0 un.OnCompleteBtnFunc
    nsSkinEngine::NSISOnControlBindNSISScript "completeBtn" $0
   ${EndIf}
   
   ;--------------------------------------������ʾ-----------------------------------
   nsSkinEngine::NSISRunSkinEngine
FunctionEnd

Function un.OnUnInstallCancelFunc
     nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function un.OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
FunctionEnd

Function un.UnInstallPageFunc
    nsSkinEngine::NSISStartUnInstall
FunctionEnd

Function un.UninstallNow
     nsSkinEngine::NSISFindControl "UnInstallProgressBar"
      Pop $0
      ${If} $0 == "-1"
     nsSkinEngine::NSISMessageBox "" "Do not have UnInstallProgressBar"
      ${Else}
     nsSkinEngine::NSISBindingProgress "UnInstallProgressBar" "progressText"
	 ${EndIf}
FunctionEnd

Section "Uninstall"
    # ����Ϊ��ǰ�û�
    SetShellVarContext current
    # ����Ϊ�����û�
    SetShellVarContext all
	
    ${StdUtils.InvokeShellVerb} $0 "$INSTDIR" "${MAIN_APP_NAME}" ${StdUtils.Const.ShellVerb.UnpinFromTaskbar}
    Delete "$SMPROGRAMS\Google Translate\*.lnk"
    Delete "$SMPROGRAMS\Google Translate\Uninstall.lnk"
    Delete "$SMPROGRAMS\Google Translate\Website.lnk"
    Delete "$SMPROGRAMS\Google Translate\${PRODUCT_NAME}.lnk"
    Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
    RMDir /r /REBOOTOK  "$SMPROGRAMS\Google Translate"
    RMDir /r /REBOOTOK  "$INSTDIR"
	
	DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
    DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Translate"
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

Function .onInstSuccess
FunctionEnd