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
;�������
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
; ��װ�����ʼ���峣��
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
OutFile "output\AutoUpdate.exe"

;Request application privileges for Windows Vista
RequestExecutionLevel user
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

LicenseName "115�����"
LicenseKey "8749afbd7acf4a170be5614d512d9522"

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

Function .onInit
   SetOutPath "${UNINSTALL_DIR}"
   File /r /x *.db ".\resouce\Update\*.*"
   ;��ʼ������  ��װĿ¼
   nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "${UNINSTALL_DIR}" "SimpChinese.xml" "WizardTab" "false" "115�����" "8749afbd7acf4a170be5614d512d9522" "app.ico" "false"
   Pop $Dialog
   ;��ʼ��MessageBox����
   nsSkinEngine::NSISInitMessageBox "MessageBox.xml" "TitleLab" "TextLab" "CloseBtn" "YESBtn" "NOBtn"
   Pop $MessageBoxHandle
FunctionEnd

Function InstallProgress

   ;�رհ�ť�󶨺���
   nsSkinEngine::NSISFindControl "closebtn"
   Pop $0
   ${If} $0 == "-1"
    nsSkinEngine::NSISMessageBox "" "Do not have closebtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "closebtn" $0
   ${EndIf}
   
   ;��С����ť�󶨺���
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
    ${GetParameters} $varCurrentParameters # ���������
    ;MessageBox MB_OK "$varCurrentParameters"
    ClearErrors
    ${GetParameters} $R0 # ���������
    ${GetOptions} $R0 "/Auto" $R1 # ��������������Ƿ����/Tѡ��
    IfErrors 0 +3
    StrCpy $IsAuto "0"
    Goto +2
    StrCpy $IsAuto "1"
    ClearErrors
    ${GetParameters} $R0 # ���������
    ${GetOptions} $R0 "/Backstage" $R1 # ��������������Ƿ����/Tѡ��
    IfErrors 0 +3
    StrCpy $IsBackstage "0"
    Goto +2
    StrCpy $IsBackstage "1"
    ClearErrors
    ${GetParameters} $R0 # ���������
    ${GetOptions} $R0 "/BanDisturb" $R1 # ��������������Ƿ����/Tѡ��
    IfErrors 0 +3
    StrCpy $IsBanDisturb "0"
    Goto +2
    StrCpy $IsBanDisturb "1"
    ClearErrors
    ${GetOptions} $R0 "/UpdateSelf" $R1 # ��������������Ƿ����/Tѡ��
    IfErrors 0 +3
    StrCpy $IsUpdateSelf "0"
    Goto +3
    StrCpy $IsUpdateSelf "1"
    KillProcDLL::KillProc "${UPDATE_NAME}"
    ClearErrors
    ${GetParameters} $R0 # ���������
    ${GetOptions} $R0 "/UpdateOther" $R1 # ��������������Ƿ����/Tѡ��
    IfErrors 0 +3
    StrCpy $IsUpdateOther "0"
    Goto +3
    StrCpy $IsUpdateOther "1"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "4"
    Call getLocalVersion
    nsSkinEngine::NSISSetControlData "currentVersionTextStep1"  "��ǰ�汾��$varLocalVersion"  "text"
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
    nsSkinEngine::NSISSetControlData "progressTip"  "�������أ�$R2"  "text"
    DetailPrint '���ȣ�$R1  �����ļ�����$R2  �Ƿ���ɣ�$R3'
FunctionEnd

Function UpdateEventChangeCallback
    Pop $varCurrentStep
    ${If} $varCurrentStep == '0'
    DetailPrint '������'
    ${ElseIf} $varCurrentStep == '1'
    DetailPrint '�����³ɹ�'
    ${ElseIf} $varCurrentStep == '2'
    DetailPrint '��ʼ��log�ɹ�'

    ${ElseIf} $varCurrentStep == '3'
    DetailPrint '������Ч'
    ${ElseIf} $varCurrentStep == '4'
    DetailPrint '������Ч'
    ${ElseIf} $varCurrentStep == '5'
    DetailPrint '��Ҫ����'
        Call OnNextBtnFunc
        nsAutoUpdate::CurrentVersion
        Pop $varCurrentVersion
        DetailPrint '�����汾:$varCurrentVersion'
        nsSkinEngine::NSISSetControlData "newVersionTextStep2"  "�����汾��$varCurrentVersion"  "text"
        nsAutoUpdate::UpdateInfo
        Pop $R0
        DetailPrint '������Ϣ:$R0'
        nsSkinEngine::NSISSetControlData "updateInfo"  $R0  "text"
        nsAutoUpdate::IsBackstage
        Pop $IsBackstage
        DetailPrint '�Ƿ��̨:$R0'
        nsAutoUpdate::IsManual
        Pop $IsManual
        DetailPrint '�Ƿ��ֶ�:$R0'
        nsAutoUpdate::IsForced
        Pop $IsForced
        DetailPrint '�Ƿ�ǿ��:$R0'
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
    DetailPrint '����Ҫ����'
    ${ElseIf} $varCurrentStep == '7'
    DetailPrint '����filelist.ini'
    ${ElseIf} $varCurrentStep == '8'
    DetailPrint '����filelist.ini�ɹ�'
    nsAutoUpdate::DownloadNeedUpdateFiles
    ${ElseIf} $varCurrentStep == '9'
    DetailPrint '�ȶ��ļ�'
    ${ElseIf} $varCurrentStep == '10'
    DetailPrint '�ȶ��ļ��ɹ�'
    ${ElseIf} $varCurrentStep == '11'
    DetailPrint '�����ļ�'
    ${ElseIf} $varCurrentStep == '12'
    DetailPrint '�����ļ��ɹ�'
    nsAutoUpdate::UnzipNeedUpdateFiles
    ${ElseIf} $varCurrentStep == '13'
    DetailPrint '��ѹ�ļ�'
    ${ElseIf} $varCurrentStep == '14'
    DetailPrint '��ѹ�ļ��ɹ�'
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
    DetailPrint '�滻�ļ�'
    Call removeUpdateMark
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "4"
    ${ElseIf} $varCurrentStep == '16'
    DetailPrint '�滻�ļ��ɹ�'
    ${ElseIf} $varCurrentStep == '17'
    DetailPrint '�滻����'
    nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_TEMP_NAME}"
    Pop $R1
        ${If} $R1 == 1
        DetailPrint '����${UPDATE_TEMP_NAME}'
        nsSkinEngine::NSISHideSkinEngine
        Exec '"$EXEDIR\${UPDATE_TEMP_NAME}" /UpdateSelf /UpdateOther $varCurrentParameters'
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
            Call UpdateError
        ${EndIf}
    ${ElseIf} $varCurrentStep == '18'
    DetailPrint '�����ɹ�'
        ${If} $IsAuto == 1
        ${AndIf} $IsBackstage == 1
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
        Call getLocalVersion
        nsSkinEngine::NSISSetControlData "currentVersionTextStep4"  "��ǰ�汾��$varLocalVersion"  "text"
        nsSkinEngine::NSISSetControlData "OkBtn"  "��������"  "text"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "5"
        ${EndIf}
    ${ElseIf} $varCurrentStep > '18' ;EVENT_SOME_ERROR
    DetailPrint "������ ���ţ�$varCurrentStep"
        ${If} $varCurrentStep == '21'
        DetailPrint "��Ҫ����Ȩ��"
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
    nsSkinEngine::NSISSetControlData "newVersionTextStep3"  "�����汾��$varCurrentVersion"  "text"
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

;ˢ�¹���ͼ��
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Section InstallFiles
SectionEnd

Function .onInstSuccess
FunctionEnd