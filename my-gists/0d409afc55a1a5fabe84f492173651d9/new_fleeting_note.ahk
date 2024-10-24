#Requires AutoHotKey v2.0

; A simple example on how to:
;   - open the Fleeting Notes flutter app (Windows)
;   - Click the "New Note" button
;   - Enter a timestamp into the title of the new note
;   - Move the cursor to the note body for input
;
; This uses
;   - Fleeting Notes flutter app -- https://github.com/fleetingnotes/fleeting-notes-flutter
;   - AutoHotKey -- https://www.autohotkey.com/
;
; Also, it assumes that Fleeting Notes is configured to focus a new note on the title.

SendMode "Input"
SetWorkingDir A_ScriptDir
SetTitleMatchMode "RegEx"

; Win+Alt+N --> New Fleeting Note
#!n::
{
    try
    {
        if WinExist("Fleeting Notes")   ; If app is already launched, activate it ...
        {
            WinActivate "Fleeting Notes"
        }
        else    ; ... otherwise, launch the app.
        {
            Run '"C:\Program Files (x86)\Fleeting Notes\Fleeting Notes.exe"'    ; Your path may vary
            Sleep 1400
        }

        Sleep 500

        ; Right now, the Fleeting Notes app doesn't have any hotkeys, so the only option
        ; you've got is to "run it like an auto tester" and figure out where to click on
        ; the window.
        ;
        ; NOTE -- The coordinates below are based on the Fleeting Notes app window being
        ; sized a particular way.  If you size the window differently, you'll have to
        ; recompute the click targets.
        ;

        CoordMode "Mouse", "Window"                     ; Set mouse to relative to window
        Click 38, 200                                   ; click below the hamburger menu (close any open note)
        Sleep 250                                       ; give the app time to redraw
        Click 725, 79                                   ; click the 'New Note' button
        Sleep 250                                       ; give the app time to redraw
        
        SendText FormatTime(,  "yyyy.MM.dd-HH.mm.ss")   ; Write datestamp in title
        Send "{Enter}"                                  ; Return to move to body
        
        MouseMove 38,200                                ; move mouse out of way
    }
    catch
        MsgBox A_LastError
}
