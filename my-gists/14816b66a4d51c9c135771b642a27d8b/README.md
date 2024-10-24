# Handling the Clipboard in AutoHotkey

_by anonymous1184_

### TOC

- [README](https://gist.github.com/pa-0/14816b66a4d51c9c135771b642a27d8b/#README.md)
- [Clipboard Wrapper (`Clip.ahk`)](https://gist.github.com/pa-0/14816b66a4d51c9c135771b642a27d8b/#Clip.ahk)
- [`ClipHistory.ahk`](https://gist.github.com/pa-0/14816b66a4d51c9c135771b642a27d8b/#ClipHistory.ahk)
- [Clipboard History Mgr](https://gist.github.com/pa-0/14816b66a4d51c9c135771b642a27d8b/#ClipHistoryMgr.md)

### Introduction

The Clipboard is a PITA[^1], funny thing is that AHK makes it very easy as opposed to what the C++ code is wrapping[^2], so in theory:

```autohotkey
Clipboard := ""     ; Ready
Clipboard := "test" ; Set
Send ^v             ; Go
```

Should be enough, right? RIGHT? Well is not by a long shot. That's why I try to avoid as much as possible relying on the Clipboard but the truth is that is almost always needed, specially when dealing with large amounts of text.

`ClipWait`[^3] proves its helpfulness but also is not enough. Nor any of the approaches that I've seen/tried (including the ones I've wrote). This is an attempt with my best intentions and not an ultimate option but at very least covers all scenarios\*.

> [!NOTE]
> Race conditions can and might happen as it is a shared memory heap.

I blab way too much and the worst thing is that I'm not a native Speaker so my mind is always in a different place than my words, suffice to say that there are access and timing issues with the operations because, even tho we see just a variable is not; is a whole infrastructure behind controlled by the underlying OS. Enter:

### Clip.ahk[^4] — Clipboard Wrapper

Nothing out of the ordinary and a somewhat basic object but with the little "tricks" (at the lack of a better term) I've picked that have solved the issues at hand.

#### The good:

Prevents messing up if the Clipboard is not accessible and avoids timing problems.

#### The bad: 

There's no way of detecting when the `Paste` command starts and when it ends; depends on system load, how much the application cares about user input (as it receives the `^v` combo) and its processing time. A `while()` is used.

#### The ugly: 

The Clipboard is not an AHK resource, is a system-wide shared asset and higher precedence applications can get a hold of it, blocking it and even render it unusable when calamity strikes.

Anyway, the object is small and intuitive:

```autohotkey
Clip.Locked
 ```

Is the only public property, can be used in a conditional to manually check if the Clipboard is in use, otherwise for automatic checking use:

```autohotkey
Clip.Check()
```

It throws a catchable `Exception` if something is wrong. It also tells which application is currently locking the Clipboard.

The rest is self explanatory:

```autohotkey
Clip.Backup()                         ; Manual backup.
Clip.Clear([Backup := true])          ; Empties (automatic backup).
Clip.Get([Backup := true, Wait := 5]) ; Copies (automatic backup).
Clip.Paste([Restore := false])        ; Pastes (optional restore).
Clip.Restore()                        ; Manual restore.

; Puts data (automatic backup, optionally skip managers).
Clip.Set(Data[, Backup := true, Wait := 1, NoHistory := false])
```

And here is an example, press `1` in **Notepad**\* to see it in action and `2` to for 10 `loops` of the same:

> [!NOTE]
> Is important to be the built-in Notepad as it handles properly the amount of text and the fast nature of the test.

```autohotkey
; As fast as possible
ListLines Off
SetBatchLines -1

; Create a .5 MiB worth of text
oneKb := ""
loop 1024
	oneKb .= "#"

halfMb := ""
loop 512
	halfMb .= oneKb
halfMb .= "`r`n"

; "test data"
Clipboard := "test123test`r`n"


return ; End of auto-execute


#Include <Clip>

1::
	Clip.Check() ; Simple check

	/*
	; Manual check
	if (Clip.Locked) {
		MsgBox 0x40010, Error, Clipboard inaccessible.
		return
	}
	*/

	/*
	; Personalized check
	try {
		Clip.Check()
	} catch e {
		DetectHiddenWindows On
		WinGet path, ProcessPath, % "ahk_id" e.Extra
		if (path) {
			SplitPath path, file, path
			e.Message .= "`nFile:`t" file
			e.Message .= "`nPath:`t" path
		}
		MsgBox 0x40010, Error, % e.Message
		Exit ; End the thread
	}
	*/

	Clip.Paste() ; Paste current Clipboard, no restore
	Clip.Set(halfMb) ; Fill Clipboard (512kb of text, automatic backup)
	Clip.Paste() ; Paste `large` variable contents, no restore
	Clip.Restore() ; Restore "test data"
	Clip.Paste() ; Paste "test data", no restore

	; Type some text and select it
	SendInput This is a test{Enter}+{Up}

	Sleep 500 ; Wait for it

	Clip.Get() ; Copy selection
	Clip.Paste() ; Paste selection, no restore
	Clip.Paste(true) ; Paste selection, restoring "test data"
	Clip.Paste() ; Paste "test data"

	SendInput {Enter} ; Blank line
return

2::
	loop 10
		Send 1
return
```

You can put it in your Standard library[^5] so it can be used anywhere. In any case hope is useful, please let me know about any findings.


[^1]: https://stackoverflow.com/questions/tagged/clipboard
[^2]: https://docs.microsoft.com/en-us/windows/win32/dataxchg/using-the-clipboard#implementing-the-cut-copy-and-paste-commands
[^3]: https://www.autohotkey.com/docs/commands/ClipWait.htm
[^4]: https://git.io/Jilgc
[^5]: https://www.autohotkey.com/docs/Functions.htm