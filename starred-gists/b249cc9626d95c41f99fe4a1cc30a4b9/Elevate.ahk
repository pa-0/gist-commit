#Requires AutoHotkey v2.0

; Version: 2023.06.09.2
; https://gist.github.com/d92498381a74a4535662306152b34ab
; Usage and examples: https://redd.it/1450upb

Elevate(Target, WorkingDir := "", Options := "", &OutputVarPID := 0) {
    return Elevate_(false, Target, WorkingDir, Options, &OutputVarPID)
}

ElevateWait(Target, WorkingDir := "", Options := "", &OutputVarPID := 0) {
    return Elevate_(true, Target, WorkingDir, Options, &OutputVarPID)
}

/**
 * @private
 */
Elevate_(bWait, Target, WorkingDir, Options, &OutputVarPID) {
    template := '
    (
        #Requires AutoHotkey v2.0
        Persistent(true)
        TraySetIcon("imageres.dll", 265)
        appPid := -1
        ahkPid := DllCall("GetCurrentProcessId")
        FileOpen(A_WinDir "\Temp\AhkElevate2.run", 0x1).Write(ahkPid)
        SetTimer(CheckIt, 1)
        SetTimer(RunIt, -1)
        Exit() ; End of auto-execute
        RunIt() {
            global appPid
            exitCode := {}("{}", "{}", "{}", &appPid)
            FileOpen(A_WinDir "\Temp\AhkElevate2.ec", 0x1).Write(exitCode)
            FileDelete(A_ScriptFullPath)
            ExitApp(IsNumber(exitCode) ? exitCode : 0)
        }
        CheckIt() {
            global appPid
            if (appPid != -1) {
                FileOpen(A_WinDir "\Temp\AhkElevate2.pid", 0x1).Write(appPid)
                SetTimer(CheckIt, 0)
            }
        }
    )'
    Target := StrReplace(Target, "`"", "```"")
    template := Format(template, bWait ? "RunWait" : "Run", Target, WorkingDir, Options)
    try FileDelete(A_WinDir "\Temp\AhkElevate2.*")
    try {
        FileOpen(A_WinDir "\Temp\AhkElevate2.ahk", 0x1).Write(template)
    } catch {
        throw Error("There was an error creating the script for the task.", -1)
    }
    loop 2 {
        ErrorLevel := RunWait("schtasks.exe /Run /TN AhkElevate2 /HRESULT", , "Hide")
        if (ErrorLevel = -2147024894) {
            if (Elevate_AddTask()) {
                MsgBox("Scheduled task not added, cannot continue.", , 0x40010)
                Exit()
            }
            continue
        }
        if (ErrorLevel = 0) {
            break
        }
        throw Error("There was an error while running the scheduled task.", -1)
    }
    while (!FileExist(A_WinDir "\Temp\AhkElevate2.run")) {
        continue
    }
    timeout := A_TickCount + 50
    while (A_TickCount < timeout) {
        try {
            OutputVarPID := FileOpen(A_WinDir "\Temp\AhkElevate2.pid", 0x0).Read()
            break
        }
    }
    try FileDelete(A_WinDir "\Temp\AhkElevate2.pid")
    if (bWait && IsSet(OutputVarPID)) {
        ProcessWaitClose(OutputVarPID)
    }
    timeout := A_TickCount + 50
    while (A_TickCount < timeout) {
        try {
            ahkPid := FileOpen(A_WinDir "\Temp\AhkElevate2.run", 0x0).Read()
            ProcessWaitClose(ahkPid)
            break
        }
    }
    try FileDelete(A_WinDir "\Temp\AhkElevate2.run")
    exitCode := ""
    timeout := A_TickCount + 50
    while (A_TickCount < timeout) {
        try {
            exitCode := FileOpen(A_WinDir "\Temp\AhkElevate2.ec", 0x0).Read()
        }
    }
    try FileDelete(A_WinDir "\Temp\AhkElevate2.ec")
    return exitCode
}

/**
 * @private
 */
Elevate_AddTask() {
    xml := '<?xml version="1.0" encoding="UTF-16"?><Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><TimeTrigger><StartBoundary>1970-01-01T00:00:00</StartBoundary><Enabled>true</Enabled></TimeTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT0S</ExecutionTimeLimit></Settings><Actions Context="Author"><Exec><Command>"C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"</Command><Arguments>"' A_WinDir '\Temp\AhkElevate2.ahk"</Arguments></Exec></Actions></Task>'
    FileOpen(A_Temp "\AhkElevate2.xml", 0x1, "UTF-16").Write(xml)
    try {
        RunWait("*RunAs schtasks.exe /Create /TN AhkElevate2 /XML `"" A_Temp "\AhkElevate2.xml`" /F", , "Hide")
        return 0
    } catch {
        ; Avoid unhandled exception.
    } finally {
        FileDelete(A_Temp "\AhkElevate2.xml")
    }
    return 1
}
