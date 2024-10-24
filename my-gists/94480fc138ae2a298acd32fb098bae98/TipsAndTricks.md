# GeekDude's Tips, Tricks, and Standalones

This is intended to be a useful reference for any AutoHotkey scriptwriter
regardless of their experience. If you find any of the examples to be confusing
please let me know so I can update them for clarity.

## Table of Contents

<!-- alternate
[list][*] String Manipulation
[*] Objects
[*] Logic
[*] DllCalls
[*] Writing Libraries
[*] Windows
[*] Threading
[*] GUIs
[*] Regular Expressions
[*] Networking and Web
[*] Files and Folders[/list]
-->
* [String Manipulation](#string-manipulation)
* [Objects](#objects)
* [Logic](#logic)
* [DllCalls](#dllcalls)
* [Writing Libraries](#writing-libraries)
* [Windows](#windows)
* [Threading](#threading)
* [GUIs](#guis)
* [Regular Expressions](#regular-expressions)
* [Networking and Web](#networking-and-web)
* [Files and Folders](#files-and-folders)
<!-- /alternate -->


## String manipulation

Repeat a string.
```AutoHotkey
StrRepeat(String, Times)
{
	return StrReplace(Format("{:0" Times "}", 0), "0", String)
}
```

Pad a string to a given length.
```AutoHotkey
Var := "abc123"

; Format can be used to left-pad with zeros
MsgBox, % Format("{:010}", Var)

; SubStr can be used for prefix padding or postfix padding with any character.
; However, if the string is already larger than the size you want to pad to,
; the string will be truncated.
MsgBox, % SubStr("-=-=-=-=-=" Var, 1-10)
MsgBox, % SubStr(Var "=-=-=-=-=-", 1, 10)
```

Remove duplicate delimiters when compiling a
list in a loop WITHOUT using an if statement.
```AutoHotkey
Loop, 9
	List .= ", " A_Index

; SubStr can be used to remove a single delimiter
MsgBox, % SubStr(List, 3)

; LTrim can be used to remove many delimiters
MsgBox, % LTrim(List, ", ")
```

Check if a string starts with another string.
```AutoHotkey
; Using InStr
if (InStr("Monkey Tacos", "Monkey") == 1)

; Using SubStr (if you know the length of the other string)
if (SubStr("Monkey Tacos", 1, 6) == "Monkey")

; Using Regular Expressions
if ("Monkey Tacos" ~= "^Monkey")
```


## Objects

Use standard JSON format when defining your objects by placing the definition
into a continuation section.
```AutoHotkey
; http://www.json.org/example.html
MyObject :=
( LTrim Join
{
	"glossary": {
		"title": "example glossary",
		"GlossDiv": {
			"title": "S",
			"GlossList": {
				"GlossEntry": {
					"ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
					"Acronym": "SGML",
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
						"para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "XML"]
					},
					"GlossSee": "markup"
				}
			}
		}
	}
}
)
```

Retrieve the item count from an associative array. Note that
[AutoHotkey v1.1.29](https://autohotkey.com/boards/viewtopic.php?f=24&t=49565)
makes this unnecessary.
```AutoHotkey
Count := NumGet(&Array, 4*A_PtrSize)
```


## Logic

Do a toggle with only one line.
```AutoHotkey
Loop
	MsgBox, % Toggle := !Toggle
```


## DllCalls

Lock your screen with a simple DllCall.
```AutoHotkey
DllCall("LockWorkStation")
```

Output to a console window.
Notes:
* This doesn't work when running from SciTE4AHK.
* This is not the same as using the standard output, so output done in this
	way will not appear if you run your script from the command prompt.
```AutoHotkey
; By hand using FileAppend. FileOpen could also have been used.
DllCall("AllocConsole")
Loop, 10
	FileAppend, %A_Index%`n, CONOUT$


; As a function using FileOpen. FileAppend could also have been used.
Print(Text){
	static c := FileOpen("CONOUT$", ("rw", DllCall("AllocConsole")))
	
	; Reference __Handle to force AHK to flush the write buffer. Without it,
	; Without it, AHK will cache the write until later, such as when the
	; file is closed.
	c.Write(Text), c.__Handle
}
```

Run command line tools without having a command prompt pop up by attaching to a
hidden command prompt.
```AutoHotkey
; Launch a command promt and attach to it
DetectHiddenWindows, On
Run, cmd,, Hide, PID
WinWait, ahk_pid %PID%
DllCall("AttachConsole", "UInt", PID)

; Run another process that would normally
; make a command prompt pop up
RunWait, %ComSpec% /c ping localhost > %A_Temp%\PingOutput.txt

; Close the hidden command prompt process
Process, Close, %PID%

; Look at the output
FileRead, Output, %A_Temp%\PingOutput.txt
MsgBox, %Output%
```



## Writing Libraries

When writing a library that has code which must be run before any of your
functions can be used, you can create an initialization function that runs
itself automatically when the script starts. This eliminates any need for the
library's users to put your code into their auto-execute section.
```AutoHotkey
Initialize()
{
	Static Dummy := Initialize()
	MsgBox, This init function has been called automatically
}
```

If your library defines hotkeys, it can break other scripts that include it in
their auto-execute section. You can avoid this by wrapping your hotkey
definitions in `if False`.
```AutoHotkey
if False
{
	x::MsgBox, You hit x
	y::MsgBox, You hit y
}

MsgBox, Auto-execution not interrupted
```


## Windows

Change the default script template by modifying
`C:\Windows\ShellNew\Template.ahk`
```AutoHotkey
Run, *RunAs notepad.exe C:\Windows\ShellNew\Template.ahk
```

Start your scripts on login by placing shortcuts (or the actual scripts) into
the Startup folder.
```AutoHotkey
FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%A_ScriptName%.lnk
```


## Threading

**&#9888; WARNING &#9888;**

These tricks DO NOT add real multithreading to AutoHotkey. They are bound
by the limitations of AutoHotkey's [green thread](
https://en.wikipedia.org/wiki/Green_threads) implementation and do not work
around those restrictions in any way. If you would like to use real
multithreading with AutoHotkey look into [AutoHotkey_H](
https://autohotkey.com/boards/viewtopic.php?f=65&t=28803) or multiprogramming
(multiple programs/scripts interacting with eachother).

**&#9888; WARNING &#9888;**


Create a new thread context using SetTimer with a small negative period.

One example of where this is useful is if you have a message handler from
OnMessage that you have to do a lot of processing in, but that the result of
doesn't actually change what you return to the sender of the message. By using
SetTimer to schedule a new thread context to be created, you can be responsive
and return immediately, then do your processing afterward.
```AutoHotkey
; The trick on its own
SetTimer, Label, -0


; The trick in context
WM_LBUTTONDOWN(wParam, lParam, Msg, hWnd)
{
	; Return immediately then handle the click afterward
	SetTimer, HandleClick, -0
	return
}

HandleClick:
MsgBox, You clicked!
return
```

## GUIs

Create a menu bar for your GUI using a well formatted object instead of a long
list of menu commands.
```AutoHotkey
; Create a well-formatted object using one of the tricks
; from the objects section of this document
Menu :=
( LTrim Join Comments
[
	["&File", [
		["&New`tCtrl+N", "LabelNew"],
		["&Open`tCtrl+O", "LabelOpen"],
		["&Save`tCtrl+S", "LabelSave"],
		[],
		["E&xit`tCtrl+W", "GuiClose"]
	]], ["&Edit", [
		["Find`tCtrl+F", "LabelFind"],
		[],
		["Copy`tCtrl+C", "LabelCopy"],
		["Paste`tCtrl+V", "LabelPaste"]
	]], ["&Help", [
		["&About", Func("About").Bind(A_Now)]
	]]
]
)

MenuArray := CreateMenus(Menu)
Gui, Menu, % MenuArray[1]
Gui, Show, w640 h480
return

LabelNew:
LabelOpen:
LabelSave:
LabelFind:
LabelCopy:
LabelPaste:
return

GuiClose:
Gui, Destroy

; Release menu bar (Has to be done after Gui, Destroy)
for Index, MenuName in MenuArray
	Menu, %MenuName%, DeleteAll

ExitApp
return

About(Time)
{
	FormatTime, Time, %Time%
	MsgBox, This menu was created at %Time%
}

CreateMenus(Menu)
{
	static MenuName := 0
	Menus := ["Menu_" MenuName++]
	for each, Item in Menu
	{
		Ref := Item[2]
		if IsObject(Ref) && Ref._NewEnum()
		{
			SubMenus := CreateMenus(Ref)
			Menus.Push(SubMenus*), Ref := ":" SubMenus[1]
		}
		Menu, % Menus[1], Add, % Item[1], %Ref%
	}
	return Menus
}
```


## Regular Expressions

Find, and optionally replace, all matches of regular expression efficiently
using a [custom enumerator](
https://autohotkey.com/boards/viewtopic.php?f=7&t=7199).
```AutoHotkey
Haystack =
(
abc123|

abc456|

abc789|
)

for Match, Ctx in new RegExMatchAll(Haystack, "O)abc(\d+)")
{
	if (Match[1] == "456")
		Ctx.Replacement := "Replaced"
}

MsgBox, % Ctx.Haystack


class RegExMatchAll
{
	__New(ByRef Haystack, ByRef Needle)
	{
		this.Haystack := Haystack
		this.Needle := Needle
	}
	
	_NewEnum()
	{
		this.Pos := 0
		return this
	}
	
	Next(ByRef Match, ByRef Context)
	{
		if this.HasKey("Replacement")
		{
			Len := StrLen(IsObject(this.Match) ? this.Match.Value : this.Match)
			this.Haystack := SubStr(this.Haystack, 1, this.Pos-1)
			. this.Replacement
			. SubStr(this.Haystack, this.Pos + Len)
			this.Delete("Replacement")
		}
		Context := this
		this.Pos := RegExMatch(this.Haystack, this.Needle, Match, this.Pos+1)
		this.Match := Match
		return !!this.Pos
	}
}
```


## Networking and Web

Download a file from the web and use its contents without having to save to a
temporary file.
```AutoHotkey
Address := "https://example.com/"

; Send a request for the resource we want using an HTTP Request object
Request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
Request.Open("GET", Address)
Request.Send()


; If you want to get text data:

MsgBox, % Request.responseText


; If you want to get binary data:

; Get the data pointer and size. The pointer will be valid
; only as long as a reference to Request.responseBody is kept.
pData := NumGet(ComObjValue(Request.responseBody)+8+A_PtrSize, "UInt")
Size := Request.responseBody.MaxIndex()+1

; Do something with the binary data
FileOpen("BinaryFile.png", "w").RawWrite(pData+0, Size)

```


## Files and Folders

Read a file directly in an expression using `FileOpen`.
```AutoHotkey
MsgBox, % FileOpen("C:\Windows\System32\drivers\etc\hosts", "r").Read()
```

Overwrite a file in one step using `FileOpen`.
```AutoHotkey
/* Old method:
	FileDelete, FileName.txt
	FileAppend, New contents, FileName.txt
*/

FileOpen("FileName.txt", "w").Write("New contents")
```


---
## Revision History

You can view old versions of this post from the GitHub link below.

https://gist.github.com/G33kDude/1601bd24996cf380e03bcf2c2d9c2372/revisions
