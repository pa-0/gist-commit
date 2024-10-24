#Requires AutoHotkey v1.1

; Version: 2023.10.05.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140

GetUrl(WinTitle*) {
    static OBJID_CLIENT := 4294967292, WM_GETOBJECT := 61
    active := WinExist("A")
    target := WinExist(WinTitle*)
    if (!target) {
        return
    }
    objId := OBJID_CLIENT
    WinGetClass wClass
    if (wClass ~= "Chrome") {
        WinGet appPid, PID
        target := WinExist("ahk_pid" appPid)
        if (active != target) {
            objId := 0
        }
    }
    oAcc := Acc_ObjectFromWindow(target, objId)
    if (wClass ~= "Chrome") {
        try {
            SendMessage WM_GETOBJECT, 0, 1, Chrome_RenderWidgetHostHWND1
            oAcc.accName(0)
        }
    }
    oAcc := GetUrl_Recurse(oAcc)
    try return oAcc.accValue(0)
}

GetUrl_Recurse(oAcc) {
    if (ComObjType(oAcc, "Name") != "IAccessible") {
        return
    }
    if (oAcc.accValue(0) ~= "^[\w-]+:") {
        return oAcc
    }
    try for _, accChild in Acc_Children(oAcc) {
        oAcc := GetUrl_Recurse(accChild)
        if (IsObject(oAcc)) {
            return oAcc
        }
    }
}
