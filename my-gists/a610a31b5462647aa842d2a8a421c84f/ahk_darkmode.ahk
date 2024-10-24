#Requires AutoHotkey v2.0

; This script creates a dark mode for specific windows by inverting their colors.
; It uses the Windows Magnifier in the background for the color inverting, but it only inverts just the rectangle in place
; of the specific windows, NOT the whole screen like the Magnifier applicaion does. This is possible through DLL calls.
; Big thanks to the original source at https://www.autohotkey.com/boards/viewtopic.php?p=563023#p563023.

; Requirements:
;   - AutoHotkey needs to be installed in C:\Program Files (or use the workaround from https://www.reddit.com/r/AutoHotkey/comments/16ux144/ui_access_without_reinstalling_in_program_files_v2/).
;   - In the 'Launch Settings' of 'AutoHotkey Dash' you need to enable 'UI Access'.

; Usage:
; Use Win+i to invert a window manually or add it to the auto_invert_gp group to invert it automatically.

#SingleInstance Force
if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
	Run "*uiAccess " A_ScriptFullPath
	ExitApp
}

SetTitleMatchMode "RegEx"
; Add Programs for automatic dark mode here:
GroupAdd "auto_invert_gp", "ahk_class #32770", , "Find|Öffnen|Speichern unter"  ; Windows Explorer properties window and many others (but not the file open/save dialog that is already dark)
GroupAdd "auto_invert_gp", "ahk_class OperationStatusWindow" ; Windows Explorer dialogs
GroupAdd "auto_invert_gp", "ahk_exe AutoHotkeyUX.exe"
GroupAdd "auto_invert_gp", "ahk_exe hh.exe"		 ; Windows Help
GroupAdd "auto_invert_gp", "ahk_exe mmc.exe"
GroupAdd "auto_invert_gp", "ahk_exe procexp64.exe"  ; Process Explorer
GroupAdd "auto_invert_gp", "ahk_exe regedit.exe"
GroupAdd "auto_invert_gp", "ahk_exe Taskmgr.exe"
GroupAdd "auto_invert_gp", "ahk_exe WinRAR.exe"

; Add Programs where automatic dark mode should never be applied here:
; This is mostly because they have dialogs that match ahk_class #32770 but are already in dark mode
AutoInvIgnProcName:= ["notepad++.exe"]


#MaxThreadsPerHotkey 2
DetectHiddenWindows true
; SetBatchLines -1
SetWinDelay -1
OnExit Uninitialize

global Inverters := []
global WINDOWINFO
global pTarget := 0


; Color Matrix used to transform the colors
; Special thanks to https://github.com/mlaily/NegativeScreen/blob/master/NegativeScreen/Configuration.cs, they have many more color matrixes.

; I'm not too keen on the maths, so maybe I'm missing some things,
; but here is my basic understanding of what does what in a color matrix, when applied to a color vector:
; r*=x    g+=x*r  b+=x*r  a+=x*r  0
; r+=x*g  g*=x    b+=x*g  a+=x*g  0
; r+=x*b  g+=x*b  b*=x    a+=x*b  0
; r+=x*a  g+=x*a  b+=x*a  a*=x    0
; r+=x    g+=x    b+=x    a+=x    1

; Simple Inversion
MatrixInv := "-1|0|0|0|0|"
		   . "0|-1|0|0|0|"
		   . "0|0|-1|0|0|"
		   . "0|0|0|1|0|"
		   . "1|1|1|0|1"
		
; Smart Inversion
MatrixSmart := "0.333|-0.667|-0.667|0|0|"
			 . "-0.667| 0.333|-0.667|0|0|"
			 . "-0.667|-0.667|0.333|0|0|"
			 . "0|0|0|1|0|"
			 . "1|1|1|0|1"
		
; High saturation, good pure colors
MatrixHigh := "1|-1|-1|0|0|"
			. "-1|1|-1|0|0|"
			. "-1|-1|1|0|0|"
			. "0|0|0|1|0|"
			. "1|1|1|0|1"
		  
; set the wanted color matix
global Matrix := MatrixHigh

inGroup(GroupName, WinTitle := "A", WinText := "", ExcludeTitle := "", ExcludeText := "")
{
	GroupIDs := WinGetList("ahk_group " GroupName)
	Window := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
	Loop GroupIDs.Length
	{
		if (GroupIDs[A_Index] = Window)
		{
			;found match
			return Window
		}
	}
	return false
}


class Inverter
{
	hTarget := ""
	hGui := ""
	hGui1 := ""
	hGui2 := ""
	hChildMagnifier := ""
	hChildMagnifier1 := ""
	hChildMagnifier2 := ""
	xPrev := ""
	yPrev := ""
	wPrev := ""
	hPrev := ""
	stopped := 0
	
	__New(hTarget)
	{
		DetectHiddenWindows true
		this.hTarget := hTarget
		DllCall("LoadLibrary", "str", "magnification.dll")
		DllCall("magnification.dll\MagInitialize")
					
		MAGCOLOREFFECT := Buffer(100, 0)
		Loop Parse Matrix, "|"
			NumPut("Float", A_LoopField, MAGCOLOREFFECT, (A_Index - 1) * 4)
		Loop 2
		{
			gid := hTarget "_" A_Index
			MyGui := Gui(, gid,)
			if (A_Index = 2)
				MyGui.Opt("+AlwaysOnTop")   ; needed for ZBID_UIACCESS
			; +HWNDhGui%A_Index%
			MyGui.Opt("-DPIScale +toolwindow -Caption +E0x02000000 +E0x00080000 +E0x20") ;  WS_EX_COMPOSITED := E0x02000000  WS_EX_LAYERED := E0x00080000  WS_EX_CLICKTHROUGH := E0x20
			MyGui.Show("NA")
			this.hGui%A_Index%:= MyGui.Hwnd
			this.hChildMagnifier%A_Index% := DllCall("CreateWindowEx", "uint", 0, "str", "Magnifier", "str", "MagnifierWindow", "uint", WS_CHILD := 0x40000000, "int", 0, "int", 0, "int", 0, "int", 0, "ptr", this.hGui%A_Index%, "uint", 0, "ptr", DllCall("GetWindowLong" (A_PtrSize=8 ? "Ptr" : ""), "ptr", this.hGui%A_Index%, "int", GWL_HINSTANCE := -6 , "ptr"), "uint", 0, "ptr")
			DllCall("magnification.dll\MagSetColorEffect", "ptr", this.hChildMagnifier%A_Index%, "ptr", MAGCOLOREFFECT)
		}
		gid := hTarget "_" 2
		this.hGui := this.hGui1
		this.hChildMagnifier := this.hChildMagnifier1
		return this 
	}
	
	stop() {
		DetectHiddenWindows true
		if(!this.stopped) {
			this.stopped := 1
			hGui := this.hGui
			WinHide "ahk_id " hGui
			hGui := this.hGui1
			WinHide "ahk_id " hGui
			hGui := this.hGui2
			WinHide "ahk_id " hGui
			
			hChildMagnifier := this.hChildMagnifier
			WinHide "ahk_id " hChildMagnifier
			hChildMagnifier := this.hChildMagnifier1
			WinHide "ahk_id " hChildMagnifier
			hChildMagnifier := this.hChildMagnifier2
			WinHide "ahk_id " hChildMagnifier
		}
	}
	
	start() {
		DetectHiddenWindows true
		if(this.stopped) {
			this.stopped := 0
			
			hChildMagnifier := this.hChildMagnifier
			WinShow "ahk_id " hChildMagnifier
			
			hGui := this.hGui
			WinShow "ahk_id " hGui	
		}
	}

	doit()
	{
		DetectHiddenWindows true
		hTarget := this.hTarget
		hGui := this.hGui
		hGui1 := this.hGui1
		hGui2 := this.hGui2
		hChildMagnifier := this.hChildMagnifier
		hChildMagnifier1 := this.hChildMagnifier1
		hChildMagnifier2 := this.hChildMagnifier2
		hideGui := ""
		
		WINDOWINFO := Buffer(60, 0)
		if (this.stopped or DllCall("GetWindowInfo", "ptr", hTarget, "ptr", WINDOWINFO) = 0) and (A_LastError = 1400)   
		{
			; xx("destroyed")
			return
		}
		if (NumGet(WINDOWINFO, 36, "uint") & 0x20000000) or !(NumGet(WINDOWINFO, 36, "uint") & 0x10000000) 
		{
			; minimized or not visible
			if (this.wPrev != 0)
			{
				WinHide "ahk_id " hGui
				this.wPrev := 0
			}
			sleep 10
			return 1
		}
		x := NumGet(WINDOWINFO, 20, "int")
		y := NumGet(WINDOWINFO, 8, "int")
		w := NumGet(WINDOWINFO, 28, "int") - x
		h := NumGet(WINDOWINFO, 32, "int") - y
		move := 0
		if (hGui = hGui1) and ((NumGet(WINDOWINFO, 44, "uint") = 1) or (DllCall("GetAncestor", "ptr", WinExist("A"), "uint", GA_ROOTOWNER := 3, "ptr") = hTarget))   
		{
			; xx("activated")
			hGui := hGui2
			hChildMagnifier := hChildMagnifier2
			move := 1
			hideGui := hGui1
		}
		else if (hGui = hGui2) and (NumGet(WINDOWINFO, 44, "uint") != 1) and ((hr := DllCall("GetAncestor", "ptr", WinExist("A"), "uint", GA_ROOTOWNER := 3, "ptr")) != hTarget) and hr  
		{
			; deactivated
			hGui := hGui1
			hChildMagnifier := hChildMagnifier1
			WinMove x, y, w, h, "ahk_id " hGui
			WinMove 0, 0, w, h, "ahk_id " hChildMagnifier
			WinShow "ahk_id " hChildMagnifier
			DllCall("SetWindowPos", "ptr", hGui, "ptr", hTarget, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x0040|0x0010|0x001|0x002)
			DllCall("SetWindowPos", "ptr", hTarget, "ptr", 1, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x0040|0x0010|0x001|0x002)   ; some windows can not be z-positioned before setting them to bottom
			DllCall("SetWindowPos", "ptr", hTarget, "ptr", hGui, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x0040|0x0010|0x001|0x002)
			hideGui := hGui2 
		}
		else if (x != this.xPrev) or (y != this.yPrev) or (w != this.wPrev) or (h != this.hPrev)  
		{
			; location changed
			move := 1
		}
		if(move) {
			WinGetPos ,,&_w_, &_h_, "ahk_class Shell_TrayWnd"
			hs := A_ScreenHeight-_h_
			if(y+h>hs) {
				h := hs-y ; escape taskbar
			}
			WinMove x, y, w, h, "ahk_id " hGui
			WinMove 0, 0, w, h, "ahk_id " hChildMagnifier
			WinShow "ahk_id " hChildMagnifier
			WinShow "ahk_id " hGui
		}
		if (A_PtrSize = 8)
		{
			RECT := Buffer(16, 0)
			NumPut("int", x, RECT, 0)
			NumPut("int", y, RECT, 4)
			NumPut("int", w, RECT, 8)
			NumPut("int", h, RECT, 12)
			DllCall("magnification.dll\MagSetWindowSource", "ptr", hChildMagnifier, "ptr", RECT)
		}
		else
			DllCall("magnification.dll\MagSetWindowSource", "ptr", hChildMagnifier, "int", x, "int", y, "int", w, "int", h)
		this.xPrev := x, this.yPrev := y, this.wPrev := w, this.hPrev := h
		this.hChildMagnifier := hChildMagnifier
		this.hGui := hGui
		if hideGui
		{
			WinHide "ahk_id " hideGui
			hideGui := ""
		}
		return 1
	}
}

; Automatically turn on inversion filter
loop 
{	
	DetectHiddenWindows false ;would otherwise find many other windows

	aTarget := WinExist("A")
	if (aTarget != pTarget) { ; other window focused, check if it should be automatically inverted
		pTarget:= aTarget
		GroupIDs := WinGetList("ahk_group auto_invert_gp")

		;Concat := ""
		;For Each, Element In GroupIDs {
		;	If (Concat != "") {
		;		Concat .= "`n"
		;	}
		;	Concat .= Element ": " WinGetProcessName(Element) ;WinGetTitle(Element)
		;}
		;MsgBox Concat
	
		Loop GroupIDs.Length
		{
			hTarget := GroupIDs[A_Index]
			if (hTarget = aTarget) { ;currently focused window in auto_invert_gp group
				found:= 0
				For index, tmp in Inverters {
					if(tmp.hTarget = hTarget) {
						found:= 1
						Break
					}
				}
				if (found = 0) {
					;MsgBox "Invert " hTarget " " WinGetProcessName(hTarget)
					hTargetName:= WinGetProcessName(hTarget)
					ignore:= 0
					Loop AutoInvIgnProcName.Length
					{
						if AutoInvIgnProcName[A_Index] = hTargetName {
							ignore:= 1
							Break
						}
					}
					if (ignore = 0) {
						ToggleInversion(hTarget)
					}
				}
				Break
			}
		}
	}
	
	; Refresh all inverted windows
	For index, tmp in Inverters {
		if(!tmp.stopped) {
			ret := tmp.doit()
			if(!ret) {
				tmp.stop()
				Inverters.removeAt(index)
				;logic to exit if target window not found (uncommement)
				;invLen:= Inverters.Length
				;if(invLen = 0) {
				;	Uninitialize(ExitApp,0)
				;}
				Break
			}
		}
	}
}

ToggleInversion(hTarget) {
	found:= 0
	For index, tmp in Inverters {
		if(tmp.hTarget=hTarget) {
			found:= 1
			if(tmp.stopped) {
				tmp.start()
			}
			else {
				tmp.stop()
			}
			Break
		}
	}
	if (found = 0) {
		tmp := Inverter(hTarget)
		Inverters.push(tmp)
	}
}


#i:: ;Win+i
{
	ToggleInversion(WinExist("A"))
}

Uninitialize(ExitReason, ExitCode)
{
  DllCall("magnification.dll\MagUninitialize")
  ExitApp
}