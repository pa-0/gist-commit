#Requires AutoHotkey v2.0

global previousWindow := ""

; Define a function to focus or open
FocusOrOpen(exe, runit) {
    global previousWindow
    edgeWindow := "ahk_exe " . exe
    ; Check if Microsoft Edge is already open
    if WinExist(edgeWindow) {
        if (WinActive(edgeWindow)) {
            if previousWindow {
                WinActivate(previousWindow)
                previousWindow := ""
            }
        } else {
            previousWindow := WinExist("A")
            WinActivate(edgeWindow)
        }
    } else {
        previousWindow := WinActive()
        Run(runit)
        WinWaitActive(edgeWindow)
    }
}

#w::FocusOrOpen("msedge.exe", "msedge.exe")
#j::FocusOrOpen("WindowsTerminal.exe", "wt.exe")