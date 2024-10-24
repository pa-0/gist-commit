; UpdateUrl:   https://gist.github.com/raveren/bac5196d2063665d2154#file-aio-ahk
; DownloadURL: https://gist.github.com/raveren/bac5196d2063665d2154/raw/e6291476b4f1580aca88933ada65345428b42c71/AIO.ahk
;
; ██╗███╗   ██╗██╗████████╗██╗ █████╗ ██╗     ██╗███████╗███████╗
; ██║████╗  ██║██║╚══██╔══╝██║██╔══██╗██║     ██║╚══███╔╝██╔════╝
; ██║██╔██╗ ██║██║   ██║   ██║███████║██║     ██║  ███╔╝ █████╗
; ██║██║╚██╗██║██║   ██║   ██║██╔══██║██║     ██║ ███╔╝  ██╔══╝
; ██║██║ ╚████║██║   ██║   ██║██║  ██║███████╗██║███████╗███████╗
; ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝
;
; https://gist.github.com/raveren/bac5196d2063665d2154/edit
;
; for ASCII art http://patorjk.com/software/taag/#f=ANSI%20Shadow
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoTrayIcon
#SingleInstance Force
SetTitleMatchMode(2) ; 2 = A window's title can contain WinTitle anywhere inside it to be a match.

; DetectHiddenWindows, On

;; run as admin was disabled as it breaks drag and drop onto launched apps
; SetWorkingDir %A_ScriptDir%
; if not A_IsAdmin
;     Run *RunAs "%A_ScriptFullPath%"

;  ██████╗  █████╗ ██╗███╗   ██╗███╗   ███╗███████╗████████╗███████╗██████╗
;  ██╔══██╗██╔══██╗██║████╗  ██║████╗ ████║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
;  ██████╔╝███████║██║██╔██╗ ██║██╔████╔██║█████╗     ██║   █████╗  ██████╔╝
;  ██╔══██╗██╔══██║██║██║╚██╗██║██║╚██╔╝██║██╔══╝     ██║   ██╔══╝  ██╔══██╗
;  ██║  ██║██║  ██║██║██║ ╚████║██║ ╚═╝ ██║███████╗   ██║   ███████╗██║  ██║
;  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set taskbar transparent to use with https://github.com/alatsombath/Fountain-of-Colors
WinSetTransparent(195, "ahk_class Shell_TrayWnd")

; we have to wake the rainmeter skin periodically
; SetTimer, refresh_rainmeter, 1800000 ; check every 30min one hour = 1000ms x 60s x 60m
; Return
; refresh_rainmeter:
;     Run "C:\Apps\Rainmeter\Rainmeter.exe" !Refresh
; return


;  ███╗   ██╗██╗   ██╗███╗   ███╗██╗      ██████╗  ██████╗██╗  ██╗
;  ████╗  ██║██║   ██║████╗ ████║██║     ██╔═══██╗██╔════╝██║ ██╔╝
;  ██╔██╗ ██║██║   ██║██╔████╔██║██║     ██║   ██║██║     █████╔╝
;  ██║╚██╗██║██║   ██║██║╚██╔╝██║██║     ██║   ██║██║     ██╔═██╗
;  ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║███████╗╚██████╔╝╚██████╗██║  ██╗
;  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; use numpad always as numbers, reuse NumLock as language switch

SetNumLockState("AlwaysOn")
NumpadDot::.
NumLock::SendInput("{Alt down}{shift}{Alt up}")

; Loop {
;     Input, LastKey, L1 V
;     LastPress := A_TickCount
;     WinGet, LastWindow, ID, A
; }

; NumLock::
;     SendInput, {Alt down}{shift}{Alt up}

;     WinGet, CurrentWindow, ID, A
;     SinceLastPress := A_TickCount - LastPress
;     if ( SinceLastPress > 4000 or CurrentWindow != LastWindow ) {
;         LastKey :=
;         return
;     }

;     Matched := true
;     switch LastKey
;     {
;         case "ą": SendInput, {Backspace}{Text}1
;         case "Ą": SendInput, {Backspace}{Text}!
;         case "č": SendInput, {Backspace}{Text}2
;         case "Č": SendInput, {Backspace}{Text}@
;         case "ę": SendInput, {Backspace}{Text}3
;         case "Ę": SendInput, {Backspace}{Text}#
;         case "ė": SendInput, {Backspace}{Text}4
;         case "Ė": SendInput, {Backspace}{Text}$
;         case "į": SendInput, {Backspace}{Text}5
;         case "Į": SendInput, {Backspace}{Text}`%
;         case "š": SendInput, {Backspace}{Text}6
;         case "Š": SendInput, {Backspace}{Text}^
;         case "ų": SendInput, {Backspace}{Text}7
;         case "Ų": SendInput, {Backspace}{Text}&
;         case "ū": SendInput, {Backspace}{Text}8
;         case "Ū": SendInput, {Backspace}{Text}*
;         case "ž": SendInput, {Backspace}{Text}=
;         case "Ž": SendInput, {Backspace}{Text}+

;         case "1": SendInput, {Backspace}{Text}ą
;         case "!": SendInput, {Backspace}{Text}Ą
;         case "2": SendInput, {Backspace}{Text}č
;         case "@": SendInput, {Backspace}{Text}Č
;         case "3": SendInput, {Backspace}{Text}ę
;         case "#": SendInput, {Backspace}{Text}Ę
;         case "4": SendInput, {Backspace}{Text}ė
;         case "$": SendInput, {Backspace}{Text}Ė
;         case "5": SendInput, {Backspace}{Text}į
;         case "%": SendInput, {Backspace}{Text}Į
;         case "6": SendInput, {Backspace}{Text}š
;         case "^": SendInput, {Backspace}{Text}Š
;         case "7": SendInput, {Backspace}{Text}ų
;         case "&": SendInput, {Backspace}{Text}Ų
;         case "8": SendInput, {Backspace}{Text}ū
;         case "*": SendInput, {Backspace}{Text}Ū
;         case "=": SendInput, {Backspace}{Text}ž
;         case "+": SendInput, {Backspace}{Text}Ž
;         default: Matched := false
;     }

;     if(Matched) {
;         SoundPlay, %A_WinDir%\Media\notify.wav
;     }

;     LastKey :=
; return

;
; ███╗   ███╗ ██████╗ ██╗   ██╗███████╗███████╗
; ████╗ ████║██╔═══██╗██║   ██║██╔════╝██╔════╝
; ██╔████╔██║██║   ██║██║   ██║███████╗█████╗
; ██║╚██╔╝██║██║   ██║██║   ██║╚════██║██╔══╝
; ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝███████║███████╗
; ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
;

; Holding left mouse button and pressing right send ctrl+b
~RButton & XButton1::Send("^{Tab}")
~RButton & XButton2::Send("+^{Tab}")
; Hold right+scrll = zoom in/out
RButton & WheelUp::Send("{CTRLDOWN}{NumpadSub}{CTRLUP}")
RButton & WheelDown::Send("{CTRLDOWN}{NumpadAdd}{CTRLUP}")

;  ███████╗██████╗  ██████╗ ████████╗██╗███████╗██╗   ██╗
;  ██╔════╝██╔══██╗██╔═══██╗╚══██╔══╝██║██╔════╝╚██╗ ██╔╝
;  ███████╗██████╔╝██║   ██║   ██║   ██║█████╗   ╚████╔╝
;  ╚════██║██╔═══╝ ██║   ██║   ██║   ██║██╔══╝    ╚██╔╝
;  ███████║██║     ╚██████╔╝   ██║   ██║██║        ██║
;  ╚══════╝╚═╝      ╚═════╝    ╚═╝   ╚═╝╚═╝        ╚═╝
;

; #3::
; {
;     WinGet, active_id, ID, A
;     Run, %A_AppData%\Spotify\Spotify.exe, , Hide
;     WinActivate, ahk_id %active_id%
;     Return
; }

; shift+volumeUp: Volume up
+Volume_Up::
{
    if WinActive("ahk_exe spotify.exe")
    {
        Send("`"^{Up}`"")
    }
    else
    {

        spotifyHwnd := WinGetID("ahk_exe spotify.exe")
        ; Chromium ignores keys when it isn't focused.
        ; Focus the document window without bringing the app to the foreground.
        ControlFocus("Chrome_RenderWidgetHostHWND1", "ahk_id " spotifyHwnd)
        ControlSend("`"^{Up}`"", , "ahk_id " spotifyHwnd)
    }
}

; shift+volumeDown: Volume down
+Volume_Down::
{
    if WinActive("ahk_exe spotify.exe")
    {
        Send("`"^{Down}`"")
    }
    else
    {
        spotifyHwnd := WinGetID("ahk_exe spotify.exe")
        ; Chromium ignores keys when it isn't focused.
        ; Focus the document window without bringing the app to the foreground.
        ControlFocus("Chrome_RenderWidgetHostHWND1", "ahk_id " spotifyHwnd)
        ControlSend("`"^{Down}`"", , "ahk_id " spotifyHwnd)
    }
}


;   █████╗ ██╗  ████████╗      ██╗       ██████╗████████╗██████╗ ██╗           ██╗      ████████╗
;  ██╔══██╗██║  ╚══██╔══╝      ██║      ██╔════╝╚══██╔══╝██╔══██╗██║           ██║      ╚══██╔══╝
;  ███████║██║     ██║    ████████████╗ ██║        ██║   ██████╔╝██║      ████████████╗    ██║
;  ██╔══██║██║     ██║    ╚════██╔════╝ ██║        ██║   ██╔══██╗██║      ╚════██╔════╝    ██║
;  ██║  ██║███████╗██║         ██║      ╚██████╗   ██║   ██║  ██║███████╗      ██║         ██║
;  ╚═╝  ╚═╝╚══════╝╚═╝         ╚═╝       ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝      ╚═╝         ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; alt+ctrl+T = toggle currnet window to be AlwaysOnTop
; replaced by Windows PowerToys
^!T::
{
    WinSetAlwaysontop(-1, "A")
    Title := WinGetTitle("A")
    ; TraySetIcon("Menu Tray, Icon","Menu Tray, Icon","Menu Tray, Icon")
    A_IconHidden := false
    TrayTip("Always on top", "For window " Title)
    SoundPlay(A_WinDir "\Media\notify.wav")  ; beep even if alerts are off
    Sleep(5000)   ; Let it display for 5 seconds.
    A_IconHidden := true
}

; ██╗    ██╗██╗███╗   ██╗      ██╗      ███████╗██╗  ██╗██╗███████╗████████╗      ██╗       ██████╗    ██╗██╗   ██╗
; ██║    ██║██║████╗  ██║      ██║      ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝      ██║      ██╔════╝   ██╔╝██║   ██║
; ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ███████╗███████║██║█████╗     ██║    ████████████╗ ██║       ██╔╝ ██║   ██║
; ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ╚════██║██╔══██║██║██╔══╝     ██║    ╚════██╔════╝ ██║      ██╔╝  ╚██╗ ██╔╝
; ╚███╔███╔╝██║██║ ╚████║      ██║      ███████║██║  ██║██║██║        ██║         ██║      ╚██████╗██╔╝    ╚████╔╝
;  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝         ╚═╝       ╚═════╝╚═╝      ╚═══╝
; For Ditto, it does not accept this shortcut which seems organic to me.


#+C::SendInput("#!^c") ; instead map functionality in-app to win+shift+alt+ctrl+c
#+V::SendInput("#!^v")


;  ██╗    ██╗██╗███╗   ██╗      ██╗           ██╗
;  ██║    ██║██║████╗  ██║      ██║           ██║
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗      ██║
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██   ██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ╚█████╔╝
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝       ╚════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+J opens wallpaper from screen under mouse in WIN8+ (only works in single-monitor now)
#J::
{
    MonitorGet(1, &Mon1Left, &Mon1Top, &Mon1Right, &Mon1Bottom)
    MonitorGet(2, &Mon2Left, &Mon2Top, &Mon2Right, &Mon2Bottom)

    CoordMode("Mouse", "Screen")
    MouseGetPos(&x)

    if ( x <= Mon1Right ) {
        openWallpaperUnderMouse(0)
    } else {
        openWallpaperUnderMouse(1)
    }
}

;  ██╗    ██╗██╗███╗   ██╗      ██╗       ██████╗
;  ██║    ██║██║████╗  ██║      ██║      ██╔════╝
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ██║  ███╗
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██║   ██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ╚██████╔╝
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝       ╚═════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+G searches selected text in google (good calculator!). Alternatively recognizes
; explorer and Regedit paths. If the shortcut is overriden by xbox crap see:
; https://gist.github.com/joshschmelzle/04c57d957c5bb92e85ae9180021b26dc

#G::
{
    SavedClipboard := ClipboardAll()
    A_Clipboard := "" ; empty the clipboard
    Send("^c")
    Errorlevel := !ClipWait(0.5)
    if ErrorLevel {
        A_Clipboard := SavedClipboard
        return
    }

    SelectedText := trim(A_Clipboard)

    if RegExMatch(SelectedText, "^https?://") {
        Run(SelectedText)
    } else if RegExMatch(SelectedText, "(^HKEY_)|(^HKLM)") {
        RegJump( SelectedText )
    } else if RegExMatch(SelectedText, "^\d:\\") {
        ExplorerPath:= "explorer /select," SelectedText
        Run(ExplorerPath)
    } else {
        ; Modify some characters that screw up the URL
        SelectedText := StrReplace(SelectedText, "`r`n", A_Space)
        SelectedText := StrReplace(SelectedText, "#", "`%23")
        SelectedText := StrReplace(SelectedText, "&", "`%26")
        SelectedText := StrReplace(SelectedText, "+", "`%2b")
        SelectedText := StrReplace(SelectedText, "`"", "`%22")
        Run("https://www.google.com/search?hl=en&q=" . SelectedText)
    }
    ; Clipboard := SavedClipboard
}

;  ██╗    ██╗██╗███╗   ██╗      ██╗       █████╗
;  ██║    ██║██║████╗  ██║      ██║      ██╔══██╗
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ███████║
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██╔══██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ██║  ██║
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+A: Slack
#a::
{
    ErrorLevel := ProcessExist("slack.exe")
    slackPid := ErrorLevel

    if !WinExist("ahk_pid " slackPid)
    {
        Run(A_AppData "\..\Local\slack\slack.exe")
    }
    else
    {
        if WinActive("ahk_pid " slackPid)
        {
            WinClose("ahk_pid " slackPid)
        } else {
            WinActivate("ahk_pid " slackPid)
        }
    }
}

;  ██╗    ██╗██╗███╗   ██╗      ██╗      ███████╗
;  ██║    ██║██║████╗  ██║      ██║      ██╔════╝
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ █████╗
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██╔══╝
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ███████╗
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+E focuses existing explorer window (for qttabbar). Pressing again opens My PC.

#e::
{
    If ( WinActive("ahk_class CabinetWClass") ) { ; windows explorer
        Run("shell:mycomputerfolder")
        ; Run c:/
    } else {
        If ( WinExist("ahk_class CabinetWClass") ) {
            WinActivate("ahk_class CabinetWClass")
        } else {
            Run("explorer")
            WinWait("ahk_class CabinetWClass")
            WinActivate()
        }
    }
}

; ██████╗ █████╗ ██████╗ ███████╗██╗      ██████╗  ██████╗██╗  ██╗
;██╔════╝██╔══██╗██╔══██╗██╔════╝██║     ██╔═══██╗██╔════╝██║ ██╔╝
;██║     ███████║██████╔╝███████╗██║     ██║   ██║██║     █████╔╝
;██║     ██╔══██║██╔═══╝ ╚════██║██║     ██║   ██║██║     ██╔═██╗
;╚██████╗██║  ██║██║     ███████║███████╗╚██████╔╝╚██████╗██║  ██╗
; ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Capslock toggles between browser and PHPStorm.

Capslock::
{
    ; editor := "ahk_exe sublime_text.exe"
    editor := "ahk_exe phpstorm64.exe"
    browser := "ahk_exe firefox.exe"
    ; browser := "ahk_exe chrome.exe"
    secondary_browser := "ahk_exe chrome.exe"
    ; secondary_editor := "ahk_exe sublime_text.exe"

    ; ListVars
    ; Pause

    ; in autohotkey v1 this is the only way I found to call WinActivate w/ variable:
    ; WinActivate % browser


    if ( WinActive( secondary_browser ) )
    {
        WinActivate(browser)
        ; if ( WinExist( editor ) ) {
        ;     WinActivate % editor
        ; } else {
        ;     WinActivate % browser
        ; }
    } else {
        if WinActive( browser )
        {
            WinActivate(editor)
            ; set language to english - this MUST be set up in windows settings -> keyboard -> input language hot keys
            SendInput("{Ctrl down}9{Ctrl up}")

        } else {
            if ( WinExist( browser ) ) {
                WinActivate(browser)
            } else {
                WinActivate(secondary_browser)
            }
        }
    }
}



; ███████╗██╗  ██╗██╗███████╗████████╗      ██╗       ██████╗ █████╗ ██████╗ ███████╗
; ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝      ██║      ██╔════╝██╔══██╗██╔══██╗██╔════╝
; ███████╗███████║██║█████╗     ██║    ████████████╗ ██║     ███████║██████╔╝███████╗
; ╚════██║██╔══██║██║██╔══╝     ██║    ╚════██╔════╝ ██║     ██╔══██║██╔═══╝ ╚════██║
; ███████║██║  ██║██║██║        ██║         ██║      ╚██████╗██║  ██║██║     ███████║
; ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝         ╚═╝       ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SHIFT+Capslock is chrome
+Capslock::
{
    secondary_browser := "Google Chrome"
    editor := "ahk_exe phpstorm64.exe"

    if ( WinActive( secondary_browser ) )
    {
        MsgBox("`"asdasd`"")

        WinActivate(editor)
        ; if ( WinExist( editor ) ) {
        ;     WinActivate % editor
        ; } else {
        ;     WinActivate % browser
        ; }
    } else {
        if ( WinExist( secondary_browser ) ) {
            WinActivate(secondary_browser)
        } else {
            Run("chrome")
            WinWait(secondary_browser)
            WinActivate()
        }
    }
}

;  ██████╗████████╗██████╗ ██╗           ██╗       █████╗ ██╗  ████████╗      ██╗      ██████╗
; ██╔════╝╚══██╔══╝██╔══██╗██║           ██║      ██╔══██╗██║  ╚══██╔══╝      ██║      ██╔══██╗
; ██║        ██║   ██████╔╝██║      ████████████╗ ███████║██║     ██║    ████████████╗ ██████╔╝
; ██║        ██║   ██╔══██╗██║      ╚════██╔════╝ ██╔══██║██║     ██║    ╚════██╔════╝ ██╔══██╗
; ╚██████╗   ██║   ██║  ██║███████╗      ██║      ██║  ██║███████╗██║         ██║      ██║  ██║
;  ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝      ╚═╝      ╚═╝  ╚═╝╚══════╝╚═╝         ╚═╝      ╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ctrl+Alt+R Reloads this script
^!r::
{
    MsgBox("Reloading autohotkey script " A_ScriptFullPath)
    Reload()
}

; ██████╗ ██╗  ██╗██████╗ ███████╗████████╗ ██████╗ ██████╗ ███╗   ███╗
; ██╔══██╗██║  ██║██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗████╗ ████║
; ██████╔╝███████║██████╔╝███████╗   ██║   ██║   ██║██████╔╝██╔████╔██║
; ██╔═══╝ ██╔══██║██╔═══╝ ╚════██║   ██║   ██║   ██║██╔══██╗██║╚██╔╝██║
; ██║     ██║  ██║██║     ███████║   ██║   ╚██████╔╝██║  ██║██║ ╚═╝ ██║
; ╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#HotIf WinActive("ahk_exe phpstorm64.exe", )
    ; pressing f5 in PhpStorm activates Firefox and refreshes
    F5::
    {
        Send("^s")
        ; WinActivate ahk_exe chrome.exe
        WinActivate("ahk_exe firefox.exe")
        SendInput("{F5}")
    }

    ; taskkill /IM phpstorm64.exe /F

    NumLock::SendInput("{Ctrl down}9{Ctrl up}")

    ; ė::
    ; SC005::
    ; {
    ;     SendInput, {Alt down}{shift}{Alt up}
    ;     SendInput, $
    ;     Return
    ; }
    ; SC278::Send $

    ; Holding left mouse button and pressing right send ctrl+b
    ; ~RButton & MButton::SendInput {F7}

    ~LButton & RButton::^b
    ~RButton & LButton::SendInput("{F7}")
    ~LButton & XButton1::SendInput("{F7}")
    ~LButton & XButton2::SendInput("{F7}")
    !F4::!F3

    ; RButton & WheelDown::MsgBox You turned the mouse wheel down while holding down the middle button.
#HotIf

#HotIf WinActive("ahk_exe firefox.exe", )
    F10::
    {
        WinActivate("ahk_exe phpstorm64.exe")
        SendInput("{F10}")
    }
#HotIf


; ██████╗ ██████╗ ████████╗███████╗ ██████╗
; ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔════╝
; ██████╔╝██████╔╝   ██║   ███████╗██║
; ██╔═══╝ ██╔══██╗   ██║   ╚════██║██║
; ██║     ██║  ██║   ██║   ███████║╚██████╗
; ╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝
;
; replace PrintScreen with the superior Win10 Snip&Sketch
PrintScreen::+#S


; ███████╗██╗  ██╗██╗███████╗████████╗      ██╗      ██╗    ██╗██╗███╗   ██╗      ██╗      ██╗
; ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝      ██║      ██║    ██║██║████╗  ██║      ██║      ██║
; ███████╗███████║██║█████╗     ██║    ████████████╗ ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ██║
; ╚════██║██╔══██║██║██╔══╝     ██║    ╚════██╔════╝ ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██║
; ███████║██║  ██║██║██║        ██║         ██║      ╚███╔███╔╝██║██║ ╚████║      ██║      ███████╗
; ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝         ╚═╝       ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shift+WIN+L locks pc for 15 minutes
+#L::
{
    ; Process,Close,Cold Turkey Blocker.exe
    Run("C:\Program Files\Cold Turkey\Cold Turkey Blocker.exe" -start `"Frozen Turkey`" -lock 15")
}

;  ██╗    ██╗██╗███╗   ██╗      ██╗      ███████╗
;  ██║    ██║██║████╗  ██║      ██║      ██╔════╝
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ███████╗
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ╚════██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ███████║
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+S is sublime text

#s::
{
    if WinExist("ahk_exe sublime_text.exe")
        WinActivate()
    else
        Run("C:\apps\SublimeText\sublime_text.exe")
}

;  ██╗    ██╗██╗███╗   ██╗      ██╗      ██╗  ██╗
;  ██║    ██║██║████╗  ██║      ██║      ╚██╗██╔╝
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗  ╚███╔╝
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝  ██╔██╗
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ██╔╝ ██╗
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+X is play media

#x::
{
    Send("{Media_Play_Pause}")
}


;  ██╗    ██╗██╗███╗   ██╗      ██╗      ███████╗
;  ██║    ██║██║████╗  ██║      ██║      ╚══███╔╝
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗   ███╔╝
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝  ███╔╝
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ███████╗
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+Z previous track

#z:: ;the + means shift
{
    Send("{Media_Prev}")
}


;  ██╗    ██╗██╗███╗   ██╗      ██╗      ██╗   ██╗
;  ██║    ██║██║████╗  ██║      ██║      ██║   ██║
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ██║   ██║
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ╚██╗ ██╔╝
;  ╚███╔███╔╝██║██║ ╚████║      ██║       ╚████╔╝
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝        ╚═══╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+V next track

#v::
{
    Send("{Media_Next}")
}


;  ██╗    ██╗██╗███╗   ██╗      ██╗       ██████╗
;  ██║    ██║██║████╗  ██║      ██║      ██╔════╝
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ██║
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ╚██████╗
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝       ╚═════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+C opens shell in current folder/PhpStorm project

#c::
{
    if ( WinActive("ahk_class CabinetWClass") ) { ; we are in windows explorer

        ActiveExplorer := WinActive("ahk_class CabinetWClass")

        for window in ComObject("Shell.Application").Windows {
            if (window && window.hwnd && window.hwnd == ActiveExplorer) {
                Fullpath := window.Document.Folder.Self.Path
            }
        }

        If InStr(Fullpath, "\") {
            Run("C:\apps\cmder\Cmder.exe /start `"" Fullpath "`"")
        } else {
            Run("C:\apps\cmder\Cmder.exe /start C:\")
        }

    } else if ( WinActive( "ahk_exe phpstorm64.exe" ) ) {
        ActiveTitle := WinGetTitle("A")
        RegExMatch(ActiveTitle, "\[(.*)\]", &Match)

        ; MsgBox, %Match1%
        if ( Match[1] = "" ) {
            Match[1] := "c:\work"
        }

        ; Path := StrReplace(StrReplace(Match1,"c:\\","/mnt/c/"),"\\","/")

        Run("C:\apps\cmder\Cmder.exe /start `"" Match[1] "`"")
    } else {
        Run("C:\apps\cmder\Cmder.exe")
    }
}


;  ██╗    ██╗██╗███╗   ██╗      ██╗      ██╗
;  ██║    ██║██║████╗  ██║      ██║      ██║
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ██║
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ███████╗
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+L: pause media and turn off monitor when locking screen

#l::
{
    Send("{Media_Stop}")
    Sleep(1000) ; Give user a chance to release keys (in case their release would wake up the monitor again).
    ; Turn Monitor Off:
    SendMessage(0x112, 0xF170, 2, , "Program Manager") ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
    ; Note for the above: Use -1 in place of 2 to turn the monitor on.
    ; Use 1 in place of 2 to activate the monitor's low-power mode.
    ; Lock Workstation:
    DllCall("LockWorkStation")
}

; █████╗ ██╗  ████████╗      ██╗      ███████╗███████╗
;██╔══██╗██║  ╚══██╔══╝      ██║      ██╔════╝██╔════╝
;███████║██║     ██║    ████████████╗ █████╗  ███████╗
;██╔══██║██║     ██║    ╚════██╔════╝ ██╔══╝  ╚════██║
;██║  ██║███████╗██║         ██║      ██║     ███████║
;╚═╝  ╚═╝╚══════╝╚═╝         ╚═╝      ╚═╝     ╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ALT+F5 inserds current date time

!F5::
{
    CurrentDateTime := FormatTime(, "yyyyMMdd_HHmmss")
    SendInput(CurrentDateTime)
}


;████████╗███████╗██╗  ██╗████████╗
;╚══██╔══╝██╔════╝╚██╗██╔╝╚══██╔══╝
;   ██║   █████╗   ╚███╔╝    ██║
;   ██║   ██╔══╝   ██╔██╗    ██║
;   ██║   ███████╗██╔╝ ██╗   ██║
;   ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TYPE ";eur" to replace it with €. This file must be saved in UTF8 with BOM for this to work:
:?:;eur::€

; ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
; ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
; ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
; ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
; ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
; ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; unfortunately only works for two monitors side by side, don't have motivation to alter for advanced layouts

openWallpaperUnderMouse(monitorNo)
{
    fHexString := RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "TranscodedImageCache_00" monitorNo)

    Loop Parse, fHexString
        NewHexString .= A_LoopField (Mod(A_Index,2) ? "" : ",")

    consequtiveZeroes := 0
    Loop Parse, NewHexString, ","
    {
        if (A_Index < 25)
            continue

        if (consequtiveZeroes > 1)
        {
            Break
        }

        if (A_LoopField = 0)
        {
            consequtiveZeroes := consequtiveZeroes + 1
        } else {
            ConvString .= Chr("0x" A_LoopField)
            consequtiveZeroes := 0
        }
    }

    Run(ConvString)
}

;Open Regedit and navigate to RegPath.
;RegPath accepts both HKEY_LOCAL_MACHINE and HKLM formats.
RegJump(RegPath)
{
    ;Must close Regedit so that next time it opens the target key is selected
    WinClose("Registry Editor ahk_class RegEdit_RegEdit")

    If (SubStr(RegPath, -1) = "\") ;remove trailing "\" if present
        RegPath := SubStr(RegPath, 1, -1)

    ;Extract RootKey part of supplied registry path
    Loop Parse, RegPath, "\"
    {
        RootKey := A_LoopField
        Break
    }

    ;Now convert RootKey to standard long format
    If !InStr(RootKey, "HKEY_") ;If short form, convert to long form
    {
        if (RootKey = "HKCR")
            RegPath := StrReplace(RegPath, RootKey, "HKEY_CLASSES_ROOT",,, 1)
                Else if (RootKey = "HKCU")
            RegPath := StrReplace(RegPath, RootKey, "HKEY_CURRENT_USER",,, 1)
                Else if (RootKey = "HKLM")
            RegPath := StrReplace(RegPath, RootKey, "HKEY_LOCAL_MACHINE",,, 1)
                Else if (RootKey = "HKU")
            RegPath := StrReplace(RegPath, RootKey, "HKEY_USERS",,, 1)
                Else if (RootKey = "HKCC")
            RegPath := StrReplace(RegPath, RootKey, "HKEY_CURRENT_CONFIG",,, 1)
    }

    ;Make target key the last selected key, which is the selected key next time Regedit runs
    RegWrite(RegPath, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey")
    Run("Regedit.exe")
}




;██████╗ ██╗███████╗ █████╗ ██████╗ ██╗     ███████╗██████╗
;██╔══██╗██║██╔════╝██╔══██╗██╔══██╗██║     ██╔════╝██╔══██╗
;██║  ██║██║███████╗███████║██████╔╝██║     █████╗  ██║  ██║
;██║  ██║██║╚════██║██╔══██║██╔══██╗██║     ██╔══╝  ██║  ██║
;██████╔╝██║███████║██║  ██║██████╔╝███████╗███████╗██████╔╝
;╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═════╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; pressing alt+s on micro:bit saves it to device
; #IfWinActive, Microsoft MakeCode for micro:bit
;     !s::
;     {
;         Click, 214, 780 Left
;         WinWaitActive, Save As ahk_class #32770 ; wait for save window
;         Click, 614, 448 Left
;         Sleep, 200
;         Click, 1130, 275 Left ; click x
;         Sleep, 100
;         Click, 1084, 394 Left
;     }
; #IfWinActive
; return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ctrl+z to toggle autoclicker
; #MaxThreadsPerHotkey 3
; ^z::
; Toggle := !Toggle
; Loop
; {
;     If (!Toggle)
;         Break
;     ; Send, {e down}
;     ; Sleep 10
;     ; Send, {e up}
;     Click
;     ; Sleep 10 ; Make this number higher for slower clicks, lower for faster.
; }



; Input, OutputVar, L1 M
; MsgBox, %OutputVar%
; if (OutputVar = "Ė")
;     MsgBox, You pressed Control-C.
; ExitApp



;  ██╗    ██╗██╗███╗   ██╗      ██╗       █████╗
;  ██║    ██║██║████╗  ██║      ██║      ██╔══██╗
;  ██║ █╗ ██║██║██╔██╗ ██║ ████████████╗ ███████║
;  ██║███╗██║██║██║╚██╗██║ ╚════██╔════╝ ██╔══██║
;  ╚███╔███╔╝██║██║ ╚████║      ██║      ██║  ██║
;   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝      ╚═╝      ╚═╝  ╚═╝
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WIN+A: Aimp

; #a::
; {
;     app := "ahk_exe aimp.exe"

;     if ( WinActive( app ) )
;     {
;         ; Minimize
;     } else {
;         Run("C:\apps\AIMP\AIMP.exe")
;     }
; }