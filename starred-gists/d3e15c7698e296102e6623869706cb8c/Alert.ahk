
; Version: 2022.07.01.1
; Usages and examples: https://redd.it/qplxwo

Alert(Options := 0, Title := "", Message := "", Spec := "")
{
	if !(Options ~= "i)^(0x)?\d+") {
		Message := Options
		Options := Title := Spec := ""
	}

	if (!Title)
		Title := A_ScriptName

	if (!Message)
		Message := "Press OK to continue."

	if (!IsObject(Spec))
		Spec := {}

	if (Spec.MaxIndex()) ; Plain array, buttons only
		Spec := {"buttons": Spec.Clone()}

	if (Spec.HasKey("buttons")) {
		group1 := Mod(Options, 0x10)
		if (!group1) {
			group1 := Min(3, Spec.buttons.Count())
			Options |= group1 - 1
		}
	}

	if (Spec.HasKey("help")) {
		if (!IsFunc(Spec.help))
			throw Exception("Not a function", -1, Spec.help)
		Gui Alert:New, OwnDialogs
		if (!IsObject(Spec.help))
			Spec.help := Func(Spec.help)
		OnMessage(0x0053, Spec.help, 1) ; WM_HELP
	}

	if (Spec.HasKey("ico")) {
		iconSpec := "w16 h16"
		iconSpec .= Spec.HasKey("num") ? " Icon" Spec.num : ""
		Spec.ico := LoadPicture(Spec.ico, iconSpec, _)
	}

	if (Spec.HasKey("img")) {
		if (!FileExist(Spec.img))
			throw Exception("File doesn't exist.", -1, Spec.img)
		Options |= 0x80 ; MB_USERICON
		Spec.img := LoadPicture(Spec.img, "w32 h32", imgType)
		Spec.type := imgType
	}

	if (Spec.Count())
		Alert_Callback(Spec)

	MsgBox % Options, % Title, % Message

	if (Spec.HasKey("help")) {
		OnMessage(0x0053, Spec.help, 0)
		Gui Alert:Destroy
		Spec.help := ""
	}

	labels := "Abort,Cancel,Continue,Ignore,No,OK,Retry,TryAgain,Yes"
	for _,result in StrSplit(labels, ",") {
		IfMsgBox % result
			break
	}

	if (!Spec.buttons.Count())
		return result

	labels := {}
	labels[0] := {"OK":1}
	labels[1] := {"OK":1, "Cancel":2}
	labels[2] := {"Abort":1, "Retry":2, "Ignore":3}
	labels[3] := {"Yes":1, "No":2, "Cancel":3}
	labels[4] := {"Yes":1, "No":2}
	labels[5] := {"Retry":1, "Cancel":2}
	labels[6] := {"Cancel":1, "TryAgain":2, "Continue":3}
	typeId := labels[Mod(Options, 0x10), result]
	customLabel := RegExReplace(Spec.buttons[typeId], "&([^&])", "$1")

	return customLabel ? customLabel : result
}

Alert_Callback(Spec := "")
{
	static fnObj := ""

	if (IsObject(fnObj)) {
		OnMessage(0x44, fnObj, false)
		fnObj := ""
	} else {
		fnObj := Func("Alert_Change").Bind(Spec)
		OnMessage(0x44, fnObj, true)
	}
}

Alert_Change(Spec)
{
	static pid := DllCall("Kernel32\GetCurrentProcessId")

	Alert_Callback()
	DetectHiddenWindows On
	WinExist("ahk_pid" pid " ahk_class#32770")

	if (Spec.ico) {
		; 0x0080 = WM_SETICON
		SendMessage 0x0080, 0, % Spec.ico ; Title
		SendMessage 0x0080, 1, % Spec.ico ; Alt+Tab
	}

	if (Spec.img) {
		; 0x172 = STM_SETIMAGE
		PostMessage 0x172, % Spec.type, % Spec.img, Static1
	}

	for i,lbl in Spec.buttons {
		if (StrLen(lbl))
			ControlSetText % "Button" i, % lbl
	}

}
