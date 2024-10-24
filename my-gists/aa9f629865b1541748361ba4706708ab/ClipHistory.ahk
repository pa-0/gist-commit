
; Version: 2022.06.30.1
; Usages and examples: https://redd.it/mq9m58

ClipHistory(Ini, Monitoring := true)
{
	static instance := false

	if (!instance)
		instance := new ClipHistory(Ini, Monitoring)
	return instance
}

#Include <Clip>

class ClipHistory extends Clip
{
	; Properties

	Monitor[]
	{
		get {
			return this._active
		}
		set {
			return this.Toggle(value)
		}
	}

	Skip[]
	{
		get {
			return this._skips
		}
		set {
			this._skips := Format("{:d}", value)
			return this._skips
		}
	}

	; Public methods

	__New(Ini, Monitoring)
	{
		this._skips := 0
		this._last := Clipboard

		loop files, % Ini
			Ini := A_LoopFileLongPath
		if (!FileExist(Ini))
			throw Exception("File '" Ini "' not found.", -1)

		Monitoring := !!Monitoring

		IniRead path, % Ini, CLIPBOARD, path
		attributes := FileExist(path)
		if (!InStr(attributes, "D"))
			throw Exception("Bad path, check '" Ini "'.", -1)
		this._path := path

		IniRead key1, % Ini, CLIPBOARD, key1, % false
		IniRead key2, % Ini, CLIPBOARD, key2, % false
		if (!key1 && !key2)
			throw Exception("No keys to bind.", -1)
		this._data := {}

		if (key1)
			this._MenuHistoryBind(key1, Monitoring)

		if (key2)
			this._MenuSnippetsBind(key2, Ini)

		IniRead size, % Ini, CLIPBOARD, size
		this._size := size > 99 ? 99 : size < 1 ? 49 : size
	}

	Get(Backup := true, Wait := 5, Skip := 0)
	{
		this._skips += Skip
		parent := ObjGetBase(this.Base)
		parent.Get(Backup, Wait)
	}

	Previous()
	{
		this.Set(this._prev, false, false)
		this.Paste()
	}

	Toggle(State := -1)
	{
		if (State = -1)
			this._active ^= 1
		else
			this._active := State
		OnClipboardChange(this._monitorBind, this._active)
		return this._active
	}

	; Private

	_Crc32(String)
	{
		return DllCall("Ntdll\RtlComputeCrc32", "UInt",0, "Ptr",&String
			, "UInt",StrLen(String) * 2, "UInt")
	}

	_Delete(Path)
	{
		Clipboard := ""
		FileDelete % Path
	}

	_DeleteAll()
	{
		MsgBox 0x40024, > ClipHistory, Delete all Clipboard History?
		IfMsgBox Yes
		{
			Clipboard := ""
			FileDelete % this._path "\*.clip"
		}
	}

	_MenuHistory()
	{
		files := []
		loop files, % this._path "\*.clip"
			files[A_LoopFileTimeModified] := A_LoopFileLongPath
		; No History
		if (!files.Count())
			return
		; Max History, FIFO mode.
		loop % files.Count() - this._size {
			last := files.MinIndex()
			FileDelete % files.RemoveAt(last)
		}
		; (re)Set
		this._data["hist"] := []
		last := files[files.MaxIndex()]
		while (file := files.Pop()) {
			; Read
			FileRead contents, % "*P1200 " file
			this._data["hist"].Push(contents)
			contents := LTrim(contents, "`t`n`r ")
			; Number of lines
			StrReplace(contents, "`n",, numLines)
			; 0-padded index
			index := Format("{:02}", A_Index)
			; First LF occurrence
			firstLF := InStr(contents, "`n")
			; Limit to first LF or 30 chars
			size := firstLF && firstLF < 30 ? firstLF : 30
			; Cut
			title := SubStr(contents, 1, size)
			; Ellipsis if needed
			title .= StrLen(contents) > 30 ? "..." : ""
			; Put number of lines at the right
			title .= numLines > 1 ? "`t+" numLines : ""
			this._MenuHistoryBuild(index, title)
		}
		noOp := {}
		; Always bind, faster than store/retrieve
		fnToggle := ObjBindMethod(this, "Toggle", -1)
		fnDeleteAll := ObjBindMethod(this, "_DeleteAll")
		fnDeleteLast := ObjBindMethod(this, "_Delete", last)
		Menu History, Add
		Menu History, Add, &Monitor, % fnToggle
		Menu History, Add
		Menu History, Add, Delete &All, % fnDeleteAll
		Menu History, Add, Delete &Last, % fnDeleteLast
		Menu History, Add, &Cancel, % noOp
		if (this._active)
			Menu History, Check, &Monitor
		Menu History, Show
		; Cleanup
		loop % index // 10 ; Sub-menu number
			Menu % "clipSub" A_Index, DeleteAll
		Menu History, DeleteAll
	}

	_MenuHistoryBind(Key, Monitoring)
	{
		fnObj := ObjBindMethod(this, "_MenuHistory")
		Hotkey % Key, % fnObj, UseErrorLevel
		if (ErrorLevel)
			throw Exception("Couldn't bind '" Key "'.", -1)
		this._active := Monitoring
		this._monitorBind := ObjBindMethod(this, "_Monitor")
		OnClipboardChange(this._monitorBind, this._active)
	}

	_MenuHistoryBuild(index, item)
	{
		tens := SubStr(index, 1, 1)
		unit := SubStr(index, 0, 1)
		item := StrReplace(item, "&", "&&")
		fnObj := ObjBindMethod(this, "_Paste", "hist", "", index)
		if (!tens) ; Top level menu
			Menu History, Add, % "&" unit ") " item, % fnObj
		else if (index = 10) ; Separator
			Menu History, Add
		if (tens) { ; Sub menu items
			index := SubStr(index, 1, 1) "&" SubStr(index, 2)
			Menu % "clipSub" tens, Add, % index ") " item, % fnObj
		}
		if (!unit) ; Sub menu headers
			Menu History, Add, % tens "0 - " tens "9", % ":clipSub" tens
	}

	_MenuSnippets()
	{
		Menu Snippets, Show
	}

	_MenuSnippetsBind(Key, Ini)
	{
		fnObj := ObjBindMethod(this, "_MenuSnippets")
		Hotkey % Key, % fnObj, UseErrorLevel
		if (ErrorLevel)
			throw Exception("Couldn't bind '" Key "'.", -1)
		IniRead snippets, % Ini, SNIPPETS
		if (!snippets)
			throw Exception("No snippets defined.", -1)
		loop parse, snippets, `n
			this._snips .= A_Index < 10 ? A_LoopField "`n" : ""
		this._snips := RTrim(this._snips, "`n")
		this._MenuSnippetsBuild()
	}

	_MenuSnippetsBuild()
	{
		fnObj := ObjBindMethod(this, "_Paste", "snip")
		loop parse, % this._snips, `n
		{
			snip := StrSplit(A_LoopField, "=",, 2)
			this._data["snip", A_Index] := snip[2]
			Menu Snippets, Add, % "&" A_Index ") " snip[1], % fnObj
		}
		noOp := {}
		Menu Snippets, Add
		Menu Snippets, Add, &Cancel, % noOp
	}

	_Monitor(Type)
	{
		static format := DllCall("User32\RegisterClipboardFormat"
			, "Str","ExcludeClipboardContentFromMonitorProcessing")

		if (Type != 1)
		|| (DllCall("User32\IsClipboardFormatAvailable", "UInt",format))
			return

		if (this._skips) {
			this._skips--
			return
		}

		crcCurrent := this._Crc32(Clipboard)
		if (this._crcLast = crcCurrent)
			return
		this._crcLast := crcCurrent

		; Set previous
		this._prev := this._last
		this._last := Clipboard

		; Save as UTF-16
		FileOpen(this._path "\" crcCurrent ".clip", 0x1, "CP1200").Write(Clipboard)
	}

	_Paste(DataType, _, Index)
	{
		skip := (DataType = "snip")
		this.Set(this._data[DataType, Index],,, skip)
		this.Paste(false)
	}

}
