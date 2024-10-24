#NoTrayIcon
#NoEnv
#Persistent
#SingleInstance Force
SendMode Input
CoordMode, Mouse, Screen

; Tracks whether a hot corner was just activated, preventing it from being
; activated repeatedly.
global PreviousCorner := "None"

; A comma-separated list of process names. If one of these processes is the
; active window when a hot corner is activated, the hot corner action will be
; ignored. Great for full-screen games!
;
; To get a program's process name, open the Task Manager, find the program in
; the list (you may need to click "More details" and then expand the program's
; processes using an arrow), right click it and select "Go to details".
ExcludedProcesses := "FactoryGame-Win64-Shipping.exe,League of Legends.exe"

; The actions to take when activating specific corners. Refer to AutoHotKey's
; documentation (https://www.autohotkey.com/docs/Hotkeys.htm) for ideas on what
; you can do here.
UpperLeftAction() {
    Send, #{Tab}
}

UpperRightAction() {
    Send, #a
}

LowerLeftAction() {
}

LowerRightAction() {
}

; Kick off the hot corners routine on a repeating timer.
SetTimer, HotCorners, 10
return

; The primary routine for monitoring hot corners and triggering actions.
HotCorners:
    ; Check for the process name of the active window.
    WinGet, ActiveProcessName, ProcessName, A

    ; Only proceed if the active process is not in the exclusion list.
    if ActiveProcessName in % ExcludedProcesses
        return

    ; Identify the currently active corner, if any.
    CurrentCorner := GetCurrentCorner(10)

    ; Only proceed if the current corner isn't the same as the previous check,
    ; preventing commands from being sent repeatedly when holding the mouse to
    ; a corner.
    if (CurrentCorner != PreviousCorner) {
        ; Trigger the appropriate corner action.
        Switch CurrentCorner {
            Case "UpperLeft": UpperLeftAction()
            Case "UpperRight": UpperRightAction()
            Case "LowerLeft": LowerLeftAction()
            Case "LowerRight": LowerRightAction()
        }
    }

    ; Store the activated corner for future comparison.
    PreviousCorner := CurrentCorner

    return

; Retrieves the currently activated hot corner based on the current mouse cursor
; position, to within the specified pixel tolerance. A higher tolerance results
; in "larger" hot corners.
GetCurrentCorner(Tolerance) {
    MouseGetPos, MouseX, MouseY

    if (MouseY < Tolerance) && (MouseX < Tolerance)
        return "UpperLeft"
    if (MouseY < Tolerance) && (MouseX > (A_ScreenWidth - Tolerance))
        return "UpperRight"
    if (MouseY > (A_ScreenHeight - Tolerance)) && (MouseX < Tolerance)
        return "LowerLeft"
    if (MouseY > (A_ScreenHeight - Tolerance)) && (MouseX > (A_ScreenWidth - Tolerance))
        return "LowerRight"

    return "None"
}