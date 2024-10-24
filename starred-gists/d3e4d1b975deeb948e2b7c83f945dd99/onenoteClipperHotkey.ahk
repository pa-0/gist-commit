;An autohotkey script
EnvGet, ProgramFiles32, ProgramFiles(x86)
onenote := "\Microsoft Office\root\Office16\ONENOTE.EXE"
onenote32 := ProgramFiles32 . onenote
onenote64 := A_ProgramFiles . onenote
;msgbox, % onenote32
ONENOTE_PATH:="C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE"

if FileExist(onenote64) {
	ONENOTE_PATH:=onenote64	
	}
else if FileExist(onenote32) {
	ONENOTE_PATH:=onenote32
	;msgbox, % ONENOTE_PATH
	}

;;; the below is hotkeys ;;;

#a::
Send, ^c
sleep,100
;msgbox, %ONENOTE_PATH%   /sidenote /paste
;"C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE"
run %ONENOTE_PATH%  /sidenote /paste
;run C:\Program Files (x86)\Microsoft Office\root\Office16\ONENOTE.EXE  /sidenote /paste
Return
;