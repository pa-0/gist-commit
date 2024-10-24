; --------------------------------
; NSIS packaging/install script with portable option!
; Docs: http://nsis.sourceforge.net/Docs/Contents.html
; Made for electron-boilerplate
; Based off this answer by Anders:
; https://stackoverflow.com/questions/13777988/use-nsis-to-create-both-normal-install-and-portable-install
; --------------------------------

; --------------------------------
; Variables
; --------------------------------
!define dest "{{dest}}"
!define src "{{src}}"
!define name "{{name}}"
!define productName "{{productName}}"
!define version "{{version}}"
!define icon "{{icon}}"
!define setupIcon "{{setupIcon}}"
!define banner "{{banner}}"
!define electron "electron.exe"
!define exec "{{name}}.exe"
!define UNINSTKEY "${productName}"
!define DEFAULTNORMALDESTINATON "$ProgramFiles\${productName}"
!define DEFAULTPORTABLEDESTINATON "$Desktop\${productName}"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${exec}"
!define MUI_FINISHPAGE_RUN_TEXT "Launch ${productName}"
; --------------------------------
; Captions & options
; --------------------------------
Name "${productName}"
Icon "${setupIcon}"
OutFile "${dest}"
CRCCheck on
SilentInstall normal

Caption "${productName} Setup"
SubCaption 3 " "
SubCaption 4 " "

; XPStyle on
; ShowInstDetails show
; AutoCloseWindow false
WindowIcon off

; Start on 'user' then require if it's not portable:
RequestExecutionlevel user
SetCompressor LZMA

Var NormalDestDir
Var PortableDestDir
Var PortableMode
Var Image
Var ImageHandle

!include LogicLib.nsh
!include FileFunc.nsh
!include MUI2.nsh

; --------------------------------
; Custom pages:
; --------------------------------
; !insertmacro MUI_PAGE_WELCOME
Page Custom WelcomePage
Page Custom PortableModePageCreate PortableModePageLeave

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE English

; --------------------------------
; Main with command line params
; --------------------------------
Function .onInit
  StrCpy $NormalDestDir "${DEFAULTNORMALDESTINATON}"
  StrCpy $PortableDestDir "${DEFAULTPORTABLEDESTINATON}"

  ; Extract banner image for welcome page
  InitPluginsDir
  ReserveFile "${banner}"
  File /oname=$PLUGINSDIR\banner.bmp "${banner}"

  ${GetParameters} $9

  ClearErrors
  ${GetOptions} $9 "/?" $8
  ${IfNot} ${Errors}
      MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "\
        /PORTABLE : Extract application to USB drive etc$\n\
        /S : Silent install$\n\
        /D=%directory% : Specify destination directory$\n"
      Quit
  ${EndIf}

  ClearErrors
  ${GetOptions} $9 "/PORTABLE" $8
  ${IfNot} ${Errors}
      StrCpy $PortableMode 1
      StrCpy $0 $PortableDestDir
  ${Else}
      StrCpy $PortableMode 0
      StrCpy $0 $NormalDestDir
      ;${If} ${Silent}
      ;    Call RequireAdmin
      ;${EndIf}
  ${EndIf}

  ${If} $InstDir == ""
      ; User did not use /D to specify a directory,
      ; we need to set a default based on the install mode
      StrCpy $InstDir $0
  ${EndIf}
  Call SetModeDestinationFromInstdir
FunctionEnd

; --------------------------------
; Welcome page with banner
; --------------------------------
Function WelcomePage
    !insertmacro MUI_HEADER_TEXT "${productName} Installation" "Version ${version}"

    nsDialogs::Create 1018

    ${NSD_CreateLabel} 185 1u 210 100% "Welcome to ${productName} version ${version} installer.$\r$\n$\r$\nClick next to begin."
    ${NSD_CreateBitmap} 0 0 170 210 ""
    Pop $Image
    ${NSD_SetImage} $Image $PLUGINSDIR\banner.bmp $ImageHandle

    nsDialogs::Show

    ${NSD_FreeImage} $ImageHandle
FunctionEnd

; --------------------------------
; Function to check the user privs
; --------------------------------
Function RequireAdmin
  UserInfo::GetAccountType
  Pop $8
  ${If} $8 != "admin"
      MessageBox MB_ICONSTOP "You need administrator rights to install ${productName}. Please rerun the installer as an administrator."
      SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
      Quit
  ${EndIf}
FunctionEnd

; --------------------------------
; Set the directory based on $PortableMode
; --------------------------------
Function SetModeDestinationFromInstdir
  ${If} $PortableMode = 0
      StrCpy $NormalDestDir $InstDir
  ${Else}
      StrCpy $PortableDestDir $InstDir
  ${EndIf}
FunctionEnd

; --------------------------------
; Create the page with the options to choose
; whether it's a portable installation
; --------------------------------
Function PortableModePageCreate
  Call SetModeDestinationFromInstdir ; If the user clicks BACK on the directory page we will remember their mode specific directory
  !insertmacro MUI_HEADER_TEXT "Install Mode" "Choose how you wish to install ${productName}."
  nsDialogs::Create 1018
  Pop $0
  ${NSD_CreateLabel} 0 10u 100% 24u "Select install mode:"
  Pop $0
  ${NSD_CreateRadioButton} 30u 50u -30u 8u "Normal installation"
  Pop $1
  ${NSD_CreateRadioButton} 30u 70u -30u 8u "Portable installation"
  Pop $2
  ${If} $PortableMode = 0
      SendMessage $1 ${BM_SETCHECK} ${BST_CHECKED} 0
  ${Else}
      SendMessage $2 ${BM_SETCHECK} ${BST_CHECKED} 0
  ${EndIf}
  ; ${NSD_CreateBitmap} 0 0 170 210 ""
  ; Pop $Image
  ; ${NSD_SetImage} $Image $PLUGINSDIR\banner.bmp $ImageHandle
  nsDialogs::Show
  ; ${NSD_FreeImage} $ImageHandle
FunctionEnd

; --------------------------------
; Post-choosing page
; --------------------------------
Function PortableModePageLeave
  ${NSD_GetState} $1 $0
  ${If} $0 <> ${BST_UNCHECKED}
      StrCpy $PortableMode 0
      StrCpy $InstDir $NormalDestDir
      Call RequireAdmin
  ${Else}
      StrCpy $PortableMode 1
      StrCpy $InstDir $PortableDestDir
  ${EndIf}
FunctionEnd

; --------------------------------
; Install the files based on $PortableMode
; --------------------------------
Section
  ; RequireAdmin if not portable:
  ${If} $PortableMode = 0
    Call RequireAdmin
  ${EndIf}

  SetOutPath "$InstDir"
  File /r "${src}\*"
  Rename "$INSTDIR\${electron}" "$INSTDIR\${exec}"
  ${If} $PortableMode = 0
      CreateShortCut "$SMPROGRAMS\${productName}.lnk" "$INSTDIR\${exec}" "" "$INSTDIR\icon.ico"
      WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "DisplayName" "${productName}"
      WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
      WriteUninstaller "$INSTDIR\uninstall.exe"
  ${Else}
      CreateShortCut "$INSTDIR\${productName}.lnk" "$INSTDIR\${exec}" "" "$INSTDIR\icon.ico"
      ; Create the file the application uses to detect portable mode
      FileOpen $0 "$INSTDIR\portable.dat" w
      FileWrite $0 "PORTABLE"
      FileClose $0
  ${EndIf}
SectionEnd

; --------------------------------
; Uninstallation section for non-portables
; --------------------------------
Section Uninstall
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTKEY}"
  ;Delete "$INSTDIR\uninstall.exe"
  ;Delete "$INSTDIR\myapp.exe"
  ;RMDir "$InstDir"
  ;DeleteRegKey HKLM "${uninstkey}"
  ;DeleteRegKey HKLM "${regkey}"

  Delete "$SMPROGRAMS\${productName}.lnk"

  ; Remove whole directory from Program Files
  RMDir /r "$INSTDIR"

  ; Remove also appData directory generated by your app if user checked this option
  ; maybe we should be using ${name} instead of ${productName}?
  ${If} $RemoveAppDataCheckbox_State == ${BST_CHECKED}
      RMDir /r "$LOCALAPPDATA\${productName}"
  ${EndIf}
SectionEnd
