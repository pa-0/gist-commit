#Requires AutoHotkey v1.1

; Version: 2023.06.09.2
; https://gist.github.com/d92498381a74a4535662306152b34ab
; Usage and examples: https://redd.it/1450upb

Elevate(Target, WorkingDir := "", Options := "", ByRef OutputVarPID := 0) {
    return Elevate_(false, Target, WorkingDir, Options, OutputVarPID)
}

ElevateWait(Target, WorkingDir := "", Options := "", ByRef OutputVarPID := 0) {
    return Elevate_(true, Target, WorkingDir, Options, OutputVarPID)
}

/**
 * @private
 */
Elevate_(bWait, Target, WorkingDir, Options, ByRef OutputVarPID) {
    template =
    (%
        #Requires AutoHotkey v1.1
        #Persistent
        Menu Tray, Icon, imageres.dll, 265
        appPid := -1
        ahkPid := DllCall("GetCurrentProcessId")
        FileOpen(A_WinDir "\Temp\AhkElevate1.run", 0x1).Write(ahkPid)
        SetTimer CheckIt, 1
        SetTimer RunIt, -1
        Exit ; End of auto-execute
        RunIt() {
            global appPid
            {} {}, {}, {}, appPid
            exitCode := ErrorLevel
            FileOpen(A_WinDir "\Temp\AhkElevate1.ec", 0x1).Write(exitCode)
            FileDelete % A_ScriptFullPath
            ExitApp % Format("{:d}", exitCode)
        }
        CheckIt() {
            global appPid
            if (appPid != -1) {
                FileOpen(A_WinDir "\Temp\AhkElevate1.pid", 0x1).Write(appPid)
                SetTimer CheckIt, Delete
            }
        }
    )
    Target := StrReplace(Target, """", """""")
    template := Format(template, bWait ? "RunWait" : "Run", Target, WorkingDir, Options)
    try FileDelete % A_WinDir "\Temp\AhkElevate1.*"
    try {
        FileOpen(A_WinDir "\Temp\AhkElevate1.ahk", 0x1).Write(template)
    } catch {
        throw Exception("There was an error creating the script for the task.", -1)
    }
    loop 2 {
        RunWait schtasks.exe /Run /TN AhkElevate1 /HRESULT, , Hide
        if (ErrorLevel = -2147024894) {
            if (Elevate_AddTask()) {
                MsgBox 0x40010, , Scheduled task not added`, cannot continue.
                Exit
            }
            continue
        }
        if (ErrorLevel = 0) {
            break
        }
        throw Exception("There was an error while running the scheduled task.", -1)
    }
    while (!FileExist(A_WinDir "\Temp\AhkElevate1.run")) {
        continue
    }
    timeout := A_TickCount + 50
    while (A_TickCount < timeout) {
        try {
            OutputVarPID := FileOpen(A_WinDir "\Temp\AhkElevate1.pid", 0x0).Read()
            break
        }
    }
    try FileDelete % A_WinDir "\Temp\AhkElevate1.pid"
    if (bWait && IsSet(OutputVarPID)) {
        Process WaitClose, % OutputVarPID
    }
    timeout := A_TickCount + 50
    while (A_TickCount < timeout) {
        try {
            ahkPid := FileOpen(A_WinDir "\Temp\AhkElevate1.run", 0x0).Read()
            Process WaitClose, % ahkPid
            break
        }
    }
    try FileDelete % A_WinDir "\Temp\AhkElevate1.run"
    exitCode := ""
    timeout := A_TickCount + 50
    while (A_TickCount < timeout) {
        try {
            exitCode := FileOpen(A_WinDir "\Temp\AhkElevate1.ec", 0x0).Read()
        }
    }
    try FileDelete % A_WinDir "\Temp\AhkElevate1.ec"
    return exitCode
}

/**
 * @private
 */
Elevate_AddTask() {
    xml = <?xml version="1.0" encoding="UTF-16"?><Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><TimeTrigger><StartBoundary>1970-01-01T00:00:00</StartBoundary><Enabled>true</Enabled></TimeTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT0S</ExecutionTimeLimit></Settings><Actions Context="Author"><Exec><Command>"C:\Program Files\AutoHotkey\AutoHotkey.exe"</Command><Arguments>"%A_WinDir%\Temp\AhkElevate1.ahk"</Arguments></Exec></Actions></Task>
    FileOpen(A_Temp "\AhkElevate1.xml", 0x1, "UTF-16").Write(xml)
    try {
        RunWait % "*RunAs schtasks.exe /Create /TN AhkElevate1 /XML """ A_Temp "\AhkElevate1.xml"" /F", , Hide
        return 0
    } catch {
        ; Avoid unhandled exception.
    } finally {
        FileDelete % A_Temp "\AhkElevate1.xml"
    }
    return 1
}
