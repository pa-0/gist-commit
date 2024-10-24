; Partially from https://superuser.com/a/1538134

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode 2
#SingleInstance force
#NoTrayIcon

; Define groups for task bar (3+ monitor support)
GroupAdd, Shell_PrimaryTrayGroup, ahk_class Shell_TrayWnd
GroupAdd, Shell_SecondaryTrayGroup, ahk_class Shell_SecondaryTrayWnd

; Hide icons on startup.
ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
If DllCall("IsWindowVisible", UInt, HWND)
{
	WinHide, ahk_id %HWND%
}

; Win + `
; Hide icons on desktop
#`::
{
	;https://stackoverflow.com/questions/53109281/what-is-the-windows-workerw-windows-and-what-creates-them
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	; Toggle between displaying and hiding the desktop icons
	If DllCall("IsWindowVisible", UInt, HWND)
		WinHide, ahk_id %HWND%
	Else
		WinShow, ahk_id %HWND%
	return
}

; Win  + `
; Hide taskbar
#Escape::
{
	if WinExist("ahk_class Shell_TrayWnd") 
	{
		WinHide, ahk_group Shell_PrimaryTrayGroup
		WinHide, ahk_group Shell_SecondaryTrayGroup
	}
	Else
	{
		WinShow, ahk_group Shell_PrimaryTrayGroup
		WinShow, ahk_group Shell_SecondaryTrayGroup
	}
	return
}

; Win + Ctrl + Left
; Move to adjacent desktop (Default Windows keybind)

; Win + Ctrl + Right
; Move to adjacent desktop (Default Windows keybind)

; Win + Alt + Left
; Move active window to adjacent window
!#Left::
{
	WinGetTitle, Title, A
	WinSet, ExStyle, ^0x80, %Title%
	Send {LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}
	sleep, 50
	WinSet, ExStyle, ^0x80, %Title%
	WinActivate, %Title%
	return
}

; Win + Alt + Right
; Move active window to adjacent window
!#Right::
{
	WinGetTitle, Title, A
	WinSet, ExStyle, ^0x80, %Title%
	Send {LWin down}{Ctrl down}{Right}{Ctrl up}{LWin up}
	sleep, 50
	WinSet, ExStyle, ^0x80, %Title%
	WinActivate, %Title%
	return
}

; Win + Shift + `
; Reset and kill
#+`::
{
	WinShow, ahk_group Shell_PrimaryTrayGroup
	WinShow, ahk_group Shell_SecondaryTrayGroup

	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	If !DllCall("IsWindowVisible", UInt, HWND)
	{
		WinShow, ahk_id %HWND%
	}
	ExitApp
}