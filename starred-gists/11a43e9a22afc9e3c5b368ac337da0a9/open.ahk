process := A_Args[1]

if WinExist("ahk_exe " process)
{
    ;MsgBox, Process %process% exist. just focus in
    WinActivate, ahk_exe %process%

	WinGet, ActiveProcessName, ProcessName, A
	WinGet, WinClassCount, Count, ahk_exe %ActiveProcessName%
	IF WinClassCount = 1
	    Return
	Else
	WinSet, Bottom,, A
	WinActivate, ahk_exe %ActiveProcessName%
}
else
{
    ;MsgBox, Process %process% does not exists. start shortcut
    Run, C:\bin\%process%.lnk
}
