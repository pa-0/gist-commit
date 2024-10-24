#Requires AutoHotkey v2.0


;^+v:: ; Ctrl + Shift + V
^!v:: ; Ctrl + Alt + V
{
    SendInput "{Raw}" A_Clipboard
    ; Ensure CTRL and ALT are released
    SendInput "{Ctrl up}"
    SendInput "{Alt up}"
}