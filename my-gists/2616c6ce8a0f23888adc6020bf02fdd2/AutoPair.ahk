#Requires AutoHotkey v2.0
#SingleInstance Force ; https://stackoverflow.com/a/51973659/21294350 https://superuser.com/a/371141/1658455
; InstallKeybdHook ; https://stackoverflow.com/questions/18693881/detect-what-button-is-pressed#comment118671604_57718403

^!r::Reload  ; Ctrl+Alt+R
MsgBox "reload"

^!a::Run "D:\AutoHotkey\UX\AutoHotkeyUX.exe `"D:\AutoHotkey\UX\ui-dash.ahk`"" ; Ctrl+Alt+R

; https://www.autohotkey.com/boards/viewtopic.php?p=345923#p345923
WriteLog(text) 
{
	FileAppend A_NowUTC ": " text "`n", A_ScriptDir "\logfile.txt" ; can provide a full path to write to another directory
}

; https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=c2f3ce15e2d437a64a64564bd4a7697f#p109173
HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}

; https://www.autohotkey.com/boards/viewtopic.php?p=145298#p145298
PairArr := ["(","`"","'","[","{","``"]
PairArrTarget := ["()","`"`"","''","[]","{}","````"]
; here { will be used in `info` to search. 
; " and ' are because I often input one of them instead of 2.
SkipList := ["`"","{","'"]
for value in SkipList
  for index, src_value in PairArr
    if (value = src_value){
      PairArr.Removeat(index)
      PairArrTarget.Removeat(index)
    }
PairMapTarget := Map()
; https://stackoverflow.com/a/17620014/21294350
GroupAdd "Use_self_punct", "ahk_exe Code.exe"
GroupAdd "Use_self_punct", "ahk_exe WindowsTerminal.exe"
GroupActivate "MyGroup"
Loop PairArr.Length{
  ; Notice hook key is not same as keyboard hook where the latter is one monitor while the former is one key type.
  PairArr[A_Index] := "$" . PairArr[A_Index]
  WriteLog(PairArr[A_Index] . ";" . PairArrTarget[A_Index])
  PairMapTarget[PairArr[A_Index]] := PairArrTarget[A_Index]
  HotIfWinNotActive "ahk_group Use_self_punct"
  ; HotIfWinNotActive "ahk_exe Code.exe"
  ; HotIfWinNotActive "ahk_exe WindowsTerminal.exe"
  Hotkey PairArr[A_Index], PairOutput
}

Use_UIA:=false
if (Use_UIA==true){
  #Include UIA.ahk
}
; vscode fails only with (
PairOutput(ThisHotkey)
{
  if (Use_UIA==true) {
    clipboard := ""
    ; MsgBox "try UIA"
    try if (el := UIA.GetFocusedElement()) && el.IsTextPatternAvailable {
      selectionRange := el.GetSelection()[1]
      selectionRange.ExpandToEnclosingUnit(UIA.TextUnit.Word)
      clipboard := selectionRange.GetText()
      MsgBox clipboard
    }
  }else{
    clipback := ClipboardAll()
    A_Clipboard := "" ; Empty the clipboard
    Send "^c"
    if !ClipWait(0.1) ; 0.05 will fail.
    {
      ; MsgBox "The attempt to copy text onto the clipboard failed."
    }
  }

  WriteLog("To send" . ThisHotkey . ";" . PairMapTarget[ThisHotkey])
  SendText PairMapTarget[ThisHotkey]
  Send "{Left}"
  if (Use_UIA==true) {
    if clipboard != "" {
      SendText clipboard
    }
  } else{
    if A_Clipboard != ""
    {
      SendText A_Clipboard
    }
    
    ;restore clipboard
    A_Clipboard := clipback
  }
}

$-::
{
  Send "-"
}