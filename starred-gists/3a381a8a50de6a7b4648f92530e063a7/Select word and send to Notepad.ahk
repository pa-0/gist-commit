/*
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Learn          *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
*/

#SingleInstance
#Requires Autohotkey v2.0+
F9:: ;F9 triggers the script
{
	ClipOld:=ClipboardAll() ;bcckup Clipboard to restore later
	A_Clipboard:="" ;blank clipboard
	Send "^+{left}" ;Send Control Shift Left arrow (will often select word )
	sleep 100 ;Just waiting a bit
	Send "^c" ;Sending Control+c / Copy
	if !ClipWait(1,0) ;waiting up to 1 second for text to be pushed into the clipboard.
	{ ;If no text is sent to clipboard 
		MsgBox "No text was copied.  Try again" ;Let user know
		return ;Stop from moving forward
	}
	
	If WinExist("ahk_exe Notepad.exe") ;Checking to see if Notepad is running
		WinActivate() ; Use the window found by WinExist.
	else
	{
		Run "Notepad.exe" ;Launch Notepad
		WinWaitActive("Untitled - Notepad") ;waiting for Notepad to exist and be active
	}	
	Send "^v`n" ;Send paste and the New line (so it will automatically move down one line)
	Sleep 500 ;best to wait after pasting before restoring the Clipboard
	A_Clipboard:=ClipOld ;Restore original clipboard
}

;Esc::Exitapp