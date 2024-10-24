#Requires AutoHotkey v2.0

; Maps windows key to powertoys run shortcut
; $ means that this hotkey won it execute itself when sending LWin
$LWin::
{
    SHORT_THRESHOLD := "T0.2"
    ; quick is 1 if < SHORT_THRESHOLD, 0 if >= SHORT_THRESHOLD
    quick := KeyWait("LWin", SHORT_THRESHOLD)
    if quick
        Send("{Ctrl Down}{Shift Down}{Alt Down}{Space Down}{Space Up}{Alt Up}{Shift Up}{Ctrl Up}")
    else
        Send("{LWin Down}")

    ; Regardless, need to release LWin automatically once binded
    Keywait("LWin")
    send("{LWin Up}")
}
