; Tested and working using AutoHotkey v1.1.33.09

awaitKeypress(){
    ih := InputHook()
    ih.KeyOpt("{All}", "ES")  ; End and Suppress
    ; Exclude the modifiers
    ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-ES")
    ih.Start()
    ErrorLevel := ih.Wait()  ; Store EndReason in ErrorLevel
    result := ih.EndMods . ih.EndKey
    Return result
}

!o:: ; Pick any combo to trigger the chord. Here, Alt + O is used for "Open," as in "Launch an application"
    result := awaitKeypress()
    RegisteredKeyComb := { "b":"b" ; Add all options that you want to dispatch on to this map. 
                         , "c":"c" ; Any keys not in this map will show an error message.
                         , "t":"t" ; Remember to also add a branch in the Switch statement below that matches any keys you add.
                         , "v":"v"}
	if ( RegisteredKeyComb.HasKey( result ) )
		Switch % RegisteredKeyComb[ result ]
        {
            ; Dispatch to different actions based on second pressed key
            Case "b": ; "Alt+O B" for "Open Browser"
                Run C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe
            Case "c": ; "Alt+O C" for "Open Calculator"
                Run C:\Users\%A_UserName%\Documents\shortcuts\Calculator - Shortcut.lnk
            Case "v": ; "Alt+O V" for "Open VS Code"
                Run C:\Users\%A_UserName%\AppData\Local\Programs\Microsoft VS Code\Code.exe
            Case "t": ; "Alt+O T" for "Open Terminal" (Windows Terminal)
                Run C:\Users\%A_UserName%\Documents\shortcuts\Windows Terminal - Shortcut.lnk
        } 
	else
		MsgBox %  "Other key Comb than registered was pressed.`n`tResult = [" . result . "]`n`tErrorlevel = [" . ErrorLevel . "]"
return

!g:: ; Pick any combo to trigger the chord. Here, Alt + G is used for "Go To," as in "Go To a web page"
    result := awaitKeypress()
    RegisteredKeyComb := { "g":"g" ; Add all options that you want to dispatch on to this map. 
                         , "h":"h" ; Any keys not in this map will show an error message.
                         , "t":"t" ; Remember to also add a branch in the Switch statement below that matches any keys you add.
                         , "y":"y"}
	if ( RegisteredKeyComb.HasKey( result ) )
		Switch % RegisteredKeyComb[ result ]
        {
            ; Dispatch to different actions based on second pressed key
            Case "g": ; "Alt+G G" for "Goto Github"
                Run https:/www.github.com
            Case "h": ; "Alt+G H" for "Goto HackerNews"
                Run https:/news.ycombinator.com/
            Case "t": ; "Alt+G T" for "Goto Twitter"
                Run https:/twitter.com/home
            Case "y": ; "Alt+G Y" for "Goto YouTube"
                Run https:/www.youtube.com
        } 
	else
		MsgBox %  "Other key Comb than registered was pressed.`n`tResult = [" . result . "]`n`tErrorlevel = [" . ErrorLevel . "]"
return