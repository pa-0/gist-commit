#Requires AutoHotkey v2.0

; -------- ScreenTime --------  
; Inspired V2 port of the AHK V1 script Ticker by RustingSword (https://gist.github.com/RustingSword/4368301)
; Tracks your usage time for different categories on a daily basis
; and saves it to the file 'timelog.txt' in the User's Documents folder by default
; Pressing right-ctrl key after running script for atleast 20 secs gives detailed GUI display

InstallKeybdHook
InstallMouseHook

TraySetIcon "Shell32.dll", 239
TrayTip "Tracks your screentime. Press right-ctrl to see details", "TB Timer" 
SetWorkingDir "C:\Users\" . A_UserName . "\Documents"

SetTimer CheckTime, 20000 ; updates every 20 secs

global WorkTime := 0
global CodeTime := 0
global SurfingTime := 0
global MiscTime := 0
global IdleTime := 0
global TotalTime := 0

FormatSeconds(NumberOfSeconds)  ; Convert secs to hh:mm
{
    InitialTime := 19990101 ; *Midnight* of an arbitrary date
    CurrentTime := DateAdd(InitialTime,NumberOfSeconds,"Seconds")
    HHmm := FormatTime(CurrentTime, "HH 'hr' mm 'min'")
    Return HHmm
}

CheckTime()
{
    thedate := FormatTime(, "dd-MM-yyyy")

    global WorkTime := IniRead("timelog.txt", thedate, "work" , 0)
    global CodeTime := IniRead("timelog.txt", thedate, "code" , 0)
    global SurfingTime := IniRead("timelog.txt", thedate, "surfing" , 0)
    global MiscTime := IniRead("timelog.txt", thedate, "misc" , 0)
    global IdleTime := IniRead("timelog.txt", thedate, "idle" , 0)

    If (A_TimeIdlePhysical < 600000) ; no mouse/keyboard input for >= 10 minutes counts as idle
    {
        ; These should be modified based on the apps you use daily
        ; Use the AutoHotKey Window Spy app to check the ahk_class or ahk_exe name of any app
        If (WinActive("ahk_exe msedge.exe") or WinActive("ahk_class AcrobatSDIWindow")) 
            WorkTime := WorkTime + 20
        Else If (WinActive("ahk_exe Code.exe") or WinActive("ahk_class Notepad++"))
            CodeTime := CodeTime + 20
        Else If (WinActive("ahk_exe firefox.exe"))
            SurfingTime := SurfingTime + 20
        Else
            MiscTime := MiscTime + 20
    }
    Else
        IdleTime := IdleTime + 20
    
    ;total time does not include idle time
    global TotalTime := WorkTime + CodeTime + SurfingTime + MiscTime
    
    IniWrite(WorkTime,    "timelog.txt", thedate, "work")
    IniWrite(CodeTime,    "timelog.txt", thedate, "code")       
    IniWrite(SurfingTime,    "timelog.txt", thedate, "surfing")
    IniWrite(MiscTime,    "timelog.txt", thedate, "misc")
    IniWrite(IdleTime,    "timelog.txt", thedate, "idle")
    IniWrite(TotalTime,    "timelog.txt", thedate, "total")

    IniWrite(FormatSeconds(WorkTime),    "timelog.txt", thedate, "work_easyRead")
    IniWrite(FormatSeconds(CodeTime),    "timelog.txt", thedate, "code_easyRead")       
    IniWrite(FormatSeconds(SurfingTime),    "timelog.txt", thedate, "surfing_easyRead")
    IniWrite(FormatSeconds(MiscTime),    "timelog.txt", thedate, "misc_easyRead")
    IniWrite(FormatSeconds(IdleTime),    "timelog.txt", thedate, "idle_easyRead")
    IniWrite(FormatSeconds(TotalTime),    "timelog.txt", thedate, "total_easyRead")
}

; you may change this key according to your convenience 
rctrl::
{
    global WorkTime
    global CodeTime
    global SurfingTime
    global MiscTime
    global IdleTime
    global TotalTime

    todayDate := FormatTime(, "dd/MM/yyyy")
    newGUI := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox","TB Timer -" . todayDate,)
    newGUI.SetFont("s11","Aptos Display")
    newGUI.add("Text","W150 Left","Work:`t"    FormatSeconds(WorkTime) 
                               . "`n`nCoding:`t"  FormatSeconds(CodeTime) 
                               . "`n`nSurfing:`t"  FormatSeconds(SurfingTime) 
                               . "`n`nMisc:`t"  FormatSeconds(MiscTime) 
                               . "`n`nIdle:`t"  FormatSeconds(IdleTime))
    newGUI.SetFont("s14 bold","Aptos Display")
    newGUI.add("Text","W200 Left","Total:`t"  FormatSeconds(TotalTime)) 

    newGUI.show()
    Keywait "Esc", "D T10" ; press escape to close GUI display or it will auto-close after 10 seconds
    newGUI.destroy()
Return
}
