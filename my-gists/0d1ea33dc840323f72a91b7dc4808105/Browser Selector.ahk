
; Version: 2021.12.15.2
; Infomation: https://redd.it/rg5f17

#NoTrayIcon
#Persistent
#SingleInstance off
#Include <Message>

;@Ahk2Exe-IgnoreBegin
MsgBox 0x400100, Error, Compile and install first!
ExitApp 1
;@Ahk2Exe-IgnoreEnd

; Configuration

showIcon := false

appId := "AHK.BrowserSelector"
appName := "Browser Selector"
appDesc := "AutoHotkey Browser(/profile) Selector based on active application."

; End of configuration

DetectHiddenWindows On

if (A_Args[1] ~= "^[-|\/]") {
	if (A_Args[1] ~= "i)(help|\?)") {
		MsgBox 0x40020, Help, % "Usage:`n`n"
			. "--install [protocols]`n"
			. "--uninstall`n`n"
			. "By default registers 'http' and 'https' protocols, "
			. "optional: ftp http https mailto webcal urn tel smsto"
			. " sms nntp news mms irc"
	} else if (A_Args[1] ~= "i)\bInstall$") {
		A_Args.RemoveAt(1)
		A_Args.Push("http", "https")
		Install(A_Args)
	} else if (A_Args[1] ~= "i)\bUninstall$") {
		Uninstall()
		MsgBox 0x40040, Complete, Uninstall successful.
	} else {
		MsgBox 0x40010, Error, % "Unrecognized option: " A_Args[1]
	}
	ExitApp
}

if !A_Args.Count()
	WinSetTitle % "ahk_id" A_ScriptHwnd,, % appId

WinGet cnt, Count, % appId
if (cnt = 0) {
	Run % A_ScriptFullPath
	WinWait % appId
}

if StrLen(A_Args[1]) {
	Message.Send(A_Args[1], appId)
	Sleep 1000
	ExitApp
}

if (ShowIcon) {
	Menu Tray, NoStandard
	Menu Tray, Add, &Exit, Quit
	Menu Tray, Icon, netshell.dll, 86
	Menu Tray, Icon
}

SplitPath A_ScriptName,,,, ini
ini := A_ScriptDir "\" ini ".ini"
if !FileExist(ini) {
	MsgBox 0x40010, Error, Configuration file not found.
	ExitApp 1
}

browsers := {}
IniRead buffer, % ini, browsers
for _,line in StrSplit(buffer, "`n") {
	pair := StrSplit(line, "=",, 2)
	browsers[pair[1]] := pair[2]
}
if !browsers.HasKey("default") {
	MsgBox 0x40010, Error, Add a default browser.
	ExitApp 1
}

apps := {}
IniRead buffer, % ini, apps
for _,line in StrSplit(buffer, "`n") {
	pair := StrSplit(line, "=",, 2)
	apps[pair[1]] := browsers[pair[2]]
}
if !apps.Count()
	MsgBox 0x40030, Warning, No applications have been defined.


global ActiveApp
WinGet ActiveApp, ProcessName, A
DllCall("User32\SetWinEventHook"
	, "Int",0x0003 ; EVENT_SYSTEM_FOREGROUND
	, "Int",0x0003
	, "Ptr",0
	, "Ptr",RegisterCallback("UpdateActiveApp", "F")
	, "Int",0
	, "Int",0
	, "Int",0)

Message.Listen("UrlReceived")

return ; End of auto-execute thread

UpdateActiveApp(hWinEventHook, Event, hWnd)
{
	WinGet ActiveApp, ProcessName, % "ahk_id" hWnd
}

Install(Protocols)
{
	global appId, appName, appDesc

	WinKill % appId
	RegWrite REG_SZ, % "HKCU\Software\Classes\" appId ".Handler",, % appName " Handler"
	RegWrite REG_SZ, % "HKCU\Software\Classes\" appId ".Handler\DefaultIcon",, % A_ScriptFullPath ",0"
	RegWrite REG_SZ, % "HKCU\Software\Classes\" appId ".Handler\shell\open\command",, % """" A_ScriptFullPath """ ""`%1"""
	RegWrite REG_SZ, HKCU\Software\RegisteredApplications, % appId, % "Software\Clients\StartMenuInternet\" appId "\Capabilities"
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId,, % appName
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\DefaultIcon",, % A_ScriptFullPath ",0"
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\shell\open\command",, % A_ScriptFullPath
	RegWrite REG_DWORD, % "HKCU\Software\Clients\StartMenuInternet\" appId "\InstallInfo", IconsVisible, 1
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\InstallInfo", ReinstallCommand, % """" A_ScriptFullPath """ --install"
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities", ApplicationIcon, % A_ScriptFullPath ",0"
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities", ApplicationName, % appName
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities", ApplicationDescription, % appDesc
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities\StartMenu", StartMenuInternet, % appId
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities\URLAssociations", http, % appId ".Handler"
	RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities\URLAssociations", https, % appId ".Handler"
	RegWrite REG_SZ, HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache, % A_ScriptFullPath ".FriendlyAppName", % appName
	for _,protocol in Protocols {
		if protocol in ftp,http,https,mailto,webcal,urn,tel,smsto,sms,nntp,news,mms,irc
			RegWrite REG_SZ, % "HKCU\Software\Clients\StartMenuInternet\" appId "\Capabilities\URLAssociation", % protocol, % appId ".Handler"
	}
	Run % A_ScriptFullPath
	Run % "control.exe /name Microsoft.DefaultPrograms /page "
		. "pageDefaultProgram\pageAdvancedSettings?pszAppName="
		. StrReplace(appName, " ", "%20")
}

Uninstall()
{
	global appId

	WinKill % appId
	RegDelete % "HKCU\Software\Classes\" appId ".Handler"
	RegDelete HKCU\Software\RegisteredApplications, % appId
	RegDelete % "HKCU\Software\Clients\StartMenuInternet\" appId
	RegDelete HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache, % A_ScriptFullPath ".FriendlyAppName"
}

UrlReceived(Url)
{
	global apps, browsers

	browser := apps.HasKey(ActiveApp) ? apps[ActiveApp]
		: browsers["default"]
	Run % browser " """ Url """",, UseErrorLevel
	if (ErrorLevel) {
		MsgBox 0x40010, Error, % "Browser couldn't be started, check "
			. "its path.`n`n- " browser
	}
}

Quit:
	ExitApp
