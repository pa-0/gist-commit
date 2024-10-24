#Requires AutoHotkey v2.0

; =================================
; ======== Center Window  =========
; =================================

^+F12::{
	title := WinGetTitle("A")
	WinRestore(title)
	screen_width := SysGet(0)
	screen_height := SysGet(1)
	WinGetPos(,,, &taskBarHeight, "ahk_class Shell_TrayWnd")
	TARGET_PERCENT_WIDTH := 70
	x_offset := (screen_width * (100 - TARGET_PERCENT_WIDTH) / 2) / 100
	w := (screen_width * TARGET_PERCENT_WIDTH) / 100
	h := screen_height - taskBarHeight + 6
	WinMove x_offset, 0, w, h, title
}

; =================================
; =========== Accents  ============
; =================================

~RAlt::Send '{Blind}{vkE8}'

; For ANSI US layout (physical and logical)

>!e::Send "é"
>!+e::Send "É"
>!w::Send "è"
>!+w::Send "È"
>!r::Send "ê"
>!+r::Send "Ê"
>!a::Send "à"
>!+a::Send "À"
>!u::Send "ù"
>!+u::Send "Ù"
>!c::Send "ç"
>!+c::Send "Ç"
>!4::Send "€"

>!6::{
	ih := InputHook("L1 C", "{delete}{esc}{backspace}", "a,i,o,u")
	ih.Start()
	ih.Wait()	
	switch ih.Input
	{
		case "a": Send "â"
		case "A": Send "Â"
		case "i": Send "î"
		case "I": Send "Î"
		case "o": Send "ô"
		case "O": Send "Ô"
		case "u": Send "û"
		case "U": Send "Û"
		default: Send ih.Input
	}    
}

>!'::{
	ih := InputHook("L1 C", "{delete}{esc}{backspace}", "a,e,i,o,u")
	ih.Start()
	ih.Wait()	
	switch ih.Input
	{
		case "a": Send "ä"
		case "A": Send "Ä"
		case "e": Send "ë"
		case "E": Send "Ë"
		case "i": Send "ï"
		case "I": Send "Ï"
		case "o": Send "ö"
		case "O": Send "Ö"
		case "u": Send "ü"
		case "U": Send "Ü"
		default: Send ih.Input
	}    
}

; =================================
; ======== Applications         ===
; =================================

ToggleApplication(processName, launchCommand){
	if(WinExist("ahk_exe" . processName)){
		if(WinActive("ahk_exe" . processName)) {
			WinMinimize("ahk_exe" . processName)
		} else {
			WinActivate("ahk_exe" . processName)
		}
	}else{
		run(launchCommand)
		WinWaitActive("ahk_exe" .  processName)
	}
}

^`;::{
	ToggleApplication("notepad++.exe", "C:\Program Files\Notepad++\notepad++.exe C:\Users\Tom\Home\workspace\notes.md")
}

^'::{
	ToggleApplication("WindowsTerminal.exe", "C:\Users\Tom\Home\Shortcuts\Windows Terminal")
}

; =================================
; ======== Sound control ==========
; =================================

#HotIf MouseIsOver("ahk_class Shell_TrayWnd") or MouseIsOver("ahk_class Shell_SecondaryTrayWnd")
   WheelUp::Send("{Volume_Up}")
   WheelDown::Send("{Volume_Down}")
#HotIf

MouseIsOver(winTitle){  
	MouseGetPos(,, &Win)
	Return WinExist(winTitle . " ahk_id " . Win)
}

