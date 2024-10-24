; Version: 2022.06.30.1
; Usages and examples: https://redd.it/mpf896

/* Clipboard Wrapper

.Locked  ; Clipboard status.
.Check() ; Automated check (throws Exception).

.Backup()                         ; Manual backup.
.Clear([Backup := true])          ; Empties (automatic backup).
.Get([Backup := true, Wait := 5]) ; Copies (automatic backup).
.Paste([Restore := false])        ; Pastes (optional restore).
.Restore()                        ; Manual restore.

; Puts data (automatic backup).
.Set(Data[, Backup := true, Wait := 1, NoHistory := false])

*/

class Clip
{

	Locked[]
	{
		get {
			return this._Check(false)
		}
	}

	Backup()
	{
		this._Storage(true)
	}

	Check()
	{
		this._Check(true)
	}

	Clear(Backup := true)
	{
		if (Backup)
			this._Storage(true)
		DllCall("User32\OpenClipboard", "Ptr",A_ScriptHwnd)
		DllCall("User32\EmptyClipboard")
		DllCall("User32\CloseClipboard")
	}

	Get(Backup := true, Wait := 5)
	{
		this.Clear(Backup)
		Send ^c
		ClipWait % Wait, 1
		if (ErrorLevel)
			throw Exception("Couldn't get Clipboard contents.", -1)
		return Clipboard
	}

	Paste(RestoreBackup := false)
	{
		BlockInput Send
		Send ^v
		Sleep 20
		while (DllCall("User32\GetOpenClipboardWindow"))
			continue
		BlockInput Off
		if (RestoreBackup)
			this._Storage(false)
	}

	Restore()
	{
		this._Storage(false)
	}

	Set(Data, Backup := true, Wait := 1, NoHistory := false)
	{
		this.Clear(Backup)
		if (!IsObject(Data) && !StrLen(Data))
			return
		if (NoHistory)
			this._SetNH(Data)
		else
			Clipboard := Data
		ClipWait % Wait, 1
		if (ErrorLevel)
			throw Exception("Couldn't set Clipboard contents.", -1)
		return Data
	}

	; Private

	_Check(WithException)
	{
		inUse := !DllCall("OpenClipboard", "Ptr",A_ScriptHwnd)
		if (inUse) {
			DetectHiddenWindows On
			hWnd := DllCall("User32\GetOpenClipboardWindow")
			WinGet exe, ProcessName, % "ahk_id" hWnd
		}
		if (inUse && WithException)
			throw Exception("Clipboard locked.", -1, exe)
		return !DllCall("User32\CloseClipboard")
	}

	_Storage(bSet)
	{
		static storage := ""

		if (bSet) {
			storage := ClipboardAll
		} else {
			Clipboard := storage
			VarSetCapacity(storage, 0)
			VarSetCapacity(storage, -1)
		}
	}

	_SetNH(String) ; No History
	{
		format := DllCall("User32\RegisterClipboardFormat"
			, "Str","ExcludeClipboardContentFromMonitorProcessing")
		size := StrPut(String, "UTF-16")
		hMem := DllCall("Kernel32\GlobalAlloc", "UInt",0x0040, "UInt",size * 2) ; GHND
		pMem := DllCall("Kernel32\GlobalLock", "Ptr",hMem)
		StrPut(String, pMem, size, "UTF-16")
		DllCall("Kernel32\GlobalUnlock", "Ptr",hMem)
		DllCall("User32\OpenClipboard", "Ptr",0)
		DllCall("User32\SetClipboardData", "UInt",format, "Ptr",0)
		DllCall("User32\SetClipboardData", "UInt",13, "Ptr",hMem) ; CF_UNICODETEXT
		DllCall("User32\CloseClipboard")
	}

}
