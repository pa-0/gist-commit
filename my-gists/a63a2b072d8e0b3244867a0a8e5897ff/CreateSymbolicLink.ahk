
; Version: 2022.06.30.1
; https://gist.github.com/071310f149978639f2f58eb92128c479

/* ;region Example
if (!A_IsAdmin) {
	Run % "*RunAs " A_ScriptFullPath
	ExitApp
}
now := A_Now
directory := A_Desktop "\Directory " now
file := directory "\File-" now ".txt"
directoryLink := A_Desktop "\Link-" now
fileLink := directoryLink "\Link-" now ".txt"
FileCreateDir % directory
FileOpen(file, 0x1).Write("Hello World!")
directoryCreated := CreateSymbolicLink(directoryLink, directory)
if (directoryCreated) {
	fileCreated := CreateSymbolicLink(fileLink, file)
	if (fileCreated)
		RunWait % fileLink
	else
		MsgBox 0x40010, Error, There was an error creating the file SymLink
	FileRemoveDir % directoryLink, 1
} else {
	MsgBox 0x40010, Error, There was an error creating the directory SymLink
}
FileRemoveDir % directory, 1
*/ ;endregion

CreateSymbolicLink(Link, Target)
{
	if (FileExist(Link)) {
		ErrorLevel := -1
		return false ; Link already exists
	}
	attributes := FileExist(Target)
	if (!attributes) {
		ErrorLevel := -2
		return false ; Target doesn't exists
	}
	if (SubStr(Link, 2, 1) = ":")
		Link := "\\?\" Link
	loop Files, % Target, DF
		Target := A_LoopFileLongPath
	Target := "\\?\" Target
	isDir := !!InStr(attributes, "D")
	DllCall("Kernel32\CreateSymbolicLink", "Ptr",&Link, "Ptr",&Target, "Int",isDir)
	ErrorLevel := !FileExist(Link)
	return !ErrorLevel
}
