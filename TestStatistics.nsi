/*
    Compile the script to use the Unicode version of NSIS
    The producers：surou
*/
LicenseName "115浏览器"
LicenseKey "8749afbd7acf4a170be5614d512d9522"

; 引入的头文件
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "StdUtils.nsh"
;Languages 
!insertmacro MUI_LANGUAGE "SimpChinese"
;初始化数据
OutFile "output\TestStatistics.exe"
Section "xxxxx"
    MessageBox MB_OK "fuck you"
    nsStatistics::InitCommonStatistics
    nsStatistics::AddOneAttribute "step" "3"
    nsStatistics::SendStatisticsInfo "http://127.0.0.1" "65B70DE7540C42759156483165E35215" "1"
SectionEnd
