#Requires AutoHotkey v2.0

^space:: ;CTRL + SPACE
{
    win := WinGetTitle("A") ; Get window's title
    if (win != "") { ; Check title not null
        ExStyle := WinGetExStyle(win)
        if (ExStyle & 0x8){ ; 0x8 is WS_EX_TOPMOST.
            notifMsg := win " is no longer always on top."
            notifIcon := 2 ; Warning icon (2)
        } else {
            notifMsg := win " is now always on top."
            notifIcon := 1 ; Info icon (1)
        }
        WinSetAlwaysOnTop -1, "A" ; Use A to reference the active window
    } else {
        notifMsg := "No window is selected."
        notifIcon := 3 ; Error icon (3)
    }
    TrayTip notifMsg, "Always On Top", notifIcon
    Sleep 2500 ; Let it display for 2.5 seconds.
    TrayTip ; Attempt to hide it the normal way.
}