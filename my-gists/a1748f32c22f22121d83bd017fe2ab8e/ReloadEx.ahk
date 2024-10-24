#Requires AutoHotkey v2.0

/**
 * Unconditionally reloads a script when changes are detected.
 *
 * @param {integer} Period Time in millisecond to check for modifications.
 * @param {boolean} bForce Force reload or use built-in `Reload()` function.
 * @param {boolean} bRecurse Recursively check for changes on `.ahk` files.
 * @param {integer} Timeout Seconds to allow `OnExit()` callbacks to run.
 * @returns {boolean} Active status.
 */
ReloadEx(Period, bForce := false, bRecurse := false, Timeout := 0) {
    static previous, fn

    current := bRecurse ? _recurse() : FileGetTime(A_ScriptFullPath, "M")
    if (IsSet(fn) = false) { ; Start
        previous := current
        fn := ReloadEx.Bind(Period, bForce, bRecurse, Timeout)
        SetTimer(fn, Period)
        return true
    } else if (Period = 0) { ; Stop
        SetTimer(fn, 0)
        fn := unset
        return false
    } else if (current != previous) {
        A_IconHidden := true
        bForce ? _reload() : Reload()
    }

    _recurse() {
        crc := 0
        loop files A_ScriptDir "\*.ahk", "FR" {
            try {
                data := FileRead(A_LoopFileFullPath, "RAW")
                crc := DllCall("ntdll\RtlComputeCrc32", "UInt", crc, "Ptr", data.Ptr, "UInt", data.Size, "UInt")
            } catch {
                Exit() ; File opened exclusively or with pending IO
            }
        }
        return crc
    }

    _reload() {
        pid := ProcessExist()
        cli := DllCall("GetCommandLine", "Str")
        cmd := 'timeout {} & tskill {} & start "" {}'
        cmd := Format(cmd, Timeout, pid, cli)
        Run(A_ComSpec ' /C "' cmd '"', , "Hide")
        ExitApp() ; Trigger OnExit() if present
    }
}
