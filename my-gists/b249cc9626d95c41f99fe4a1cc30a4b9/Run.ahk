#Requires AutoHotkey v2.0

; Version: 2023.06.09.2
; https://gist.github.com/d92498381a74a4535662306152b34ab
; Usage and examples: https://redd.it/1450upb

#Include <Elevate>

Run_Patch() {
    if (RunWait("schtasks.exe /Query /TN AhkElevate2", , "Hide")) {
        if (Elevate_AddTask()) {
            MsgBox("Scheduled task was not added, the UAC prompt will be shown.", , 0x40010)
            return
        }
    }
    Run_Call := Run.base.GetOwnPropDesc("Call").Call
    RunWait_Call := RunWait.base.GetOwnPropDesc("Call").Call
    Run.DefineProp("Call", { Call: (self, Params*) => Elevate_Patch(self, false, Params*) })
    RunWait.DefineProp("Call", { Call: (self, Params*) => Elevate_Patch(self, true, Params*) })
    Elevate_Patch(self, bWait, Target, WorkingDir := "", Options := "", &OutputVarPID := 0) {
        Target := RegExReplace(Target, "i)^\h*\*RunAs\h+", , &elevate)
        if (elevate) {
            return Elevate_(bWait, Target, WorkingDir, Options, &OutputVarPID)
        }
        fn := bWait ? RunWait_Call : Run_Call
        return fn(self, Target, WorkingDir, Options, &OutputVarPID)
    }
}
