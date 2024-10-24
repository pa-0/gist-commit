#SingleInstance,Force
#NoEnv
;********************Fix Windows clipboard*********************
#IfWinActive ahk_class Shell_LightDismissOverlay
enter:: ;when hit enter key
Send, {space} ;send the space key
return ;Stop from moving forward

;*********************Alternative method***********************
<#z::
    if (not WindowsClipboard_Status_ShowingHistory) {
        ; Win+V => Clipboard history  (by win10
        Send, {Blind}{LWindown}v{LWinUp}
        WindowsClipboard_Status_ShowingHistory := true
        SetTimer, WindowsClipboard_Act_ShowingHistory_keywait_win_up, -1
    }
    Return

        WindowsClipboard_Act_ShowingHistory_keywait_win_up() {
            KeyWait, LWin
            WindowsClipboard_Status_ShowingHistory := false
        }

#If WindowsClipboard_Status_ShowingHistory
z::Send, {Down}
x::Send, {up}

i::Send, {up}
k::Send, {Down}

; Space => select and confirm  (by win10
#If