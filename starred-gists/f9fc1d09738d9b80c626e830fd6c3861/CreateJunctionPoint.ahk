
; Version: 2022.06.30.1
; https://gist.github.com/49a60fb49402c2ebd4d9bc6db03813a1

/* ;region Example
now := A_Now
junction := A_Desktop "\Junction." now
directory := A_Desktop "\Directory." now
FileCreateDir % directory
FileOpen(directory "\test.txt", 0x1).Write("Hello World!")
created := CreateJunctionPoint(junction, directory)
if (created)
	RunWait % junction "\test.txt"
else
	MsgBox 0x40010, Error, Error while creating the junction.
FileRemoveDir % junction, 1
FileRemoveDir % directory, 1
*/ ;endregion

CreateJunctionPoint(Link, Target)
{
	if (FileExist(Link)) {
		ErrorLevel := -1
		return false ; File/directory already exists
	}
	if (!FileExist(Target)) {
		ErrorLevel := -2
		return false ; Target doesn't exists
	}
	FileCreateDir % Link
	loop Files, % Link, FD
		Link := A_LoopFileLongPath
	Link := "\\?\" Link
	loop Files, % Target, FD
		Target := A_LoopFileLongPath
	targetLen := StrLen(Target) * 2
	nativeTarget := "\??\" Target
	nativeTargetLen := StrLen(nativeTarget) * 2
	hJunction := DllCall("Kernel32\CreateFile"
		, "Ptr",&Link
		, "UInt",0x40000000 ; GENERIC_WRITE
		, "UInt",0
		, "Ptr",0
		, "UInt",3 ; OPEN_EXISTING
		, "UInt",0x02200000 ; FILE_FLAG_BACKUP_SEMANTICS|FILE_FLAG_OPEN_REPARSE_POINT
		, "Ptr",0
		, "Ptr",0)
	if (hJunction = -1) {
		ErrorLevel := -3
		return false ; INVALID_HANDLE_VALUE
	}
	bufferSize := 12
	REPARSE_MOUNTPOINT_HEADER_SIZE := 8
	IO_REPARSE_TAG_MOUNT_POINT := 0xA0000003
	size := REPARSE_MOUNTPOINT_HEADER_SIZE + bufferSize + nativeTargetLen + targetLen
	VarSetCapacity(REPARSE_DATA_BUFFER, size, 0)
	NumPut(IO_REPARSE_TAG_MOUNT_POINT, REPARSE_DATA_BUFFER,, "UInt")
	offset := StrPut(nativeTarget, &REPARSE_DATA_BUFFER + 16,, "UTF-16") * 2
	NumPut(offset, REPARSE_DATA_BUFFER, 12, "UShort")
	NumPut(nativeTargetLen, REPARSE_DATA_BUFFER, 10, "UShort")
	NumPut(targetLen, REPARSE_DATA_BUFFER, 14, "UShort")
	StrPut(Target, &REPARSE_DATA_BUFFER + 16 + offset,, "UTF-16")
	reparseDataLength := nativeTargetLen + targetLen + bufferSize
	NumPut(reparseDataLength, REPARSE_DATA_BUFFER, 4, "UShort")
	out := DllCall("Kernel32\DeviceIoControl"
		, "Ptr",hJunction
		, "UInt",0x000900A4 ; FSCTL_SET_REPARSE_POINT
		, "Ptr",&REPARSE_DATA_BUFFER
		, "UInt",reparseDataLength + REPARSE_MOUNTPOINT_HEADER_SIZE
		, "Ptr",0
		, "UInt",0
		, "UInt*",0
		, "Ptr",0)
	DllCall("Kernel32\CloseHandle", "Ptr",hJunction)
	if (!out)
		FileRemoveDir % Link
	ErrorLevel := !out
	return out
}
