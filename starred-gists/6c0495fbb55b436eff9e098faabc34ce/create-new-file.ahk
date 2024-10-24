; create new file

; installation: 
; 1. you must be running autohotkey: http://www.autohotkey.com
; 2. double click on script to run
; [pro-tip] add this script to your startup folder to run when windows start
; [pro-top] you can add this script to another .ahk script file.

; hotkey is set to control + alt + n
; more on hotkeys: http://www.autohotkey.com/docs/Hotkeys.htm
^!n::

; script will automatically use its current directory as its "working directory"
; to get the file to appear in the active directory we have to extract 
; the full path from the window(stupid!)

; get full path from open windows
WinGetText, FullPath, A

; split up result (returns paths seperated by newlines [also lame])
StringSplit, PathArray, FullPath, `n

; get first item
FullPath = %PathArray1%

; clean up result
FullPath := RegExReplace(FullPath, "(^Address: )", "")
StringReplace, FullPath, FullPath, `r, , all

; change working directory
SetWorkingDir, %FullPath%

; an error occurred with the SetWorkingDir directive
if ErrorLevel
	return

; display input box for file name
InputBox, UserInput, New File (example: foo.txt), , ,400, 100

; user pressed cancel
if ErrorLevel
    return

; success! output file with user input
else
	FileAppend, ,%UserInput%	
return