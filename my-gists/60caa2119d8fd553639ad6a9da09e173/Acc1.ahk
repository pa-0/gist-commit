﻿#Requires AutoHotkey v1.1

; Version: 2023.09.22.1
; https://gist.github.com/58d2b141be2608a2f7d03a982e552a71

; Private
Acc_Init(Function) {
    static hModule := DllCall("LoadLibrary", "Str", "oleacc.dll", "Ptr")
    return DllCall("GetProcAddress", "Ptr", hModule, "AStr", Function, "Ptr")
}

Acc_ObjectFromEvent(ByRef ChildIdOut, hWnd, ObjectId, ChildId) {
    static STATUS_SUCCESS := 0, address := Acc_Init("AccessibleObjectFromEvent")
    VarSetCapacity(child, A_PtrSize * 2 + 8, 0)
    pAcc := 0
    NTSTATUS := DllCall(address, "Ptr", hWnd, "UInt", ObjectId, "UInt", ChildId, "Ptr*", pAcc, "Ptr", &child, "UInt")
    if (NTSTATUS != STATUS_SUCCESS) {
        throw Exception("AccessibleObjectFromEvent() failed.", -1, A_LastError)
    }
    ChildIdOut := NumGet(child, 8, "UInt")
    return ComObj(9, pAcc, 1)
}

Acc_ObjectFromPoint(ByRef ChildIdOut := "", x := 0, y := 0) {
    static STATUS_SUCCESS := 0, address := Acc_Init("AccessibleObjectFromPoint")
    point := x & 0xFFFFFFFF | y << 32
    if (point = 0) {
        DllCall("GetCursorPos", "Int64*", point)
    }
    pAcc := 0
    VarSetCapacity(child, A_PtrSize * 2 + 8, 0)
    NTSTATUS := DllCall(address, "Int64", point, "Ptr*", pAcc, "Ptr", &child, "UInt")
    if (NTSTATUS != STATUS_SUCCESS) {
        throw Exception("AccessibleObjectFromPoint() failed.", -1, A_LastError)
    }
    ChildIdOut := NumGet(child, 8, "UInt")
    return ComObj(9, pAcc, 1)
}

/* ObjectId
    OBJID_WINDOW            := 0x00000000 ;   0
    OBJID_SYSMENU           := 0xFFFFFFFF ;  -1
    OBJID_TITLEBAR          := 0xFFFFFFFE ;  -2
    OBJID_MENU              := 0xFFFFFFFD ;  -3
    OBJID_CLIENT            := 0xFFFFFFFC ;  -4
    OBJID_VSCROLL           := 0xFFFFFFFB ;  -5
    OBJID_HSCROLL           := 0xFFFFFFFA ;  -6
    OBJID_SIZEGRIP          := 0xFFFFFFF9 ;  -7
    OBJID_CARET             := 0xFFFFFFF8 ;  -8
    OBJID_CURSOR            := 0xFFFFFFF7 ;  -9
    OBJID_ALERT             := 0xFFFFFFF6 ; -10
    OBJID_SOUND             := 0xFFFFFFF5 ; -11
    OBJID_QUERYCLASSNAMEIDX := 0xFFFFFFF4 ; -12
    OBJID_NATIVEOM          := 0xFFFFFFF0 ; -13
*/
Acc_ObjectFromWindow(hWnd, ObjectId := -4) {
    static STATUS_SUCCESS := 0, address := Acc_Init("AccessibleObjectFromWindow")
    ObjectId &= 0xFFFFFFFF
    VarSetCapacity(IID, 16, 0)
    addr := ObjectId = 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0
    rIID := NumPut(addr, IID, "Int64")
    addr := ObjectId = 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81
    rIID := NumPut(addr, rIID + 0, "Int64") - 16
    pAcc := 0
    NTSTATUS := DllCall(address, "Ptr", hWnd, "UInt", ObjectId, "Ptr", rIID, "Ptr*", pAcc, "UInt")
    if (NTSTATUS != STATUS_SUCCESS) {
        throw Exception("AccessibleObjectFromWindow() failed.", -1, A_LastError)
    }
    return ComObj(9, pAcc, 1)
}

Acc_WindowFromObject(oAcc) {
    static STATUS_SUCCESS := 0, address := Acc_Init("WindowFromAccessibleObject")
    if (!IsObject(oAcc)) {
        throw Exception("Not an object.", -1, oAcc)
    }
    pAcc := ComObjValue(oAcc)
    hWnd := 0
    NTSTATUS := DllCall(address, "Ptr", pAcc, "Ptr*", hWnd, "UInt")
    if (NTSTATUS != STATUS_SUCCESS) {
        throw Exception("WindowFromAccessibleObject() failed.", -1, A_LastError)
    }
    return hWnd
}

Acc_GetRoleText(nRole) {
    static address := Acc_Init("GetRoleTextW")
    size := DllCall(address, "UInt", nRole, "Ptr", 0, "UInt", 0, "UInt")
    if (!size) {
        throw Exception("GetRoleText() failed.", -1, A_LastError)
    }
    size := VarSetCapacity(role, size * 2, 0)
    size := DllCall(address, "UInt", nRole, "Str", role, "UInt", size, "UInt")
    if (!size) {
        throw Exception("GetRoleText() failed.", -1, A_LastError)
    }
    return role
}

Acc_GetStateText(nState) {
    static address := Acc_Init("GetStateTextW")
    size := DllCall(address, "UInt", nState, "Ptr", 0, "UInt", 0, "UInt")
    if (!size) {
        throw Exception("GetStateText() failed.", -1, A_LastError)
    }
    size := VarSetCapacity(state, size * 2, 0)
    size := DllCall(address, "UInt", nState, "Str", state, "UInt", size, "UInt")
    if (!size) {
        throw Exception("GetStateText() failed.", -1, A_LastError)
    }
    return state
}

Acc_SetWinEventHook(EventMin, EventMax, Callback) {
    return DllCall("SetWinEventHook", "UInt", EventMin, "UInt", EventMax, "Ptr", 0, "Ptr", Callback, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr")
}

Acc_UnhookWinEvent(hHook) {
    return DllCall("UnhookWinEvent", "Ptr", hHook, "Int")
}

/* Win Events
Callback := RegisterCallback("WinEventProc")
WinEventProc(hHook, Event, hWnd, ObjectId, ChildId, EventThread, EventTime) {
    Critical
    oAcc := Acc_ObjectFromEvent(ChildIdOut, hWnd, ObjectId, ChildId)
    ; Code Here
}
*/

; Written by jethrow

Acc_Role(oAcc, ChildId := 0) {
    out := "invalid object"
    try {
        role := oAcc.accRole(ChildId + 0)
        out := Acc_GetRoleText(role)
    }
    return out
}

Acc_State(oAcc, ChildId := 0) {
    out := "invalid object"
    try {
        state := oAcc.accState(ChildId + 0)
        out := Acc_GetStateText(state)
    }
    return out
}

Acc_Location(oAcc, ChildId := 0, ByRef Position := "") {
    static VT_BYREF := 16384, VT_I4 := 3, varType := VT_BYREF | VT_I4
    VarSetCapacity(x, 4, 0)
    VarSetCapacity(y, 4, 0)
    VarSetCapacity(w, 4, 0)
    VarSetCapacity(h, 4, 0)
    xPtr := ComObj(varType, &x, 1)
    yPtr := ComObj(varType, &y, 1)
    wPtr := ComObj(varType, &w, 1)
    hPtr := ComObj(varType, &h, 1)
    Position := "ERROR"
    out := { x: 0, y: 0, w: 0, h: 0, Pos: Position }
    try {
        oAcc.accLocation(xPtr, yPtr, wPtr, hPtr, ChildId + 0)
        x := NumGet(x, 0, "Int")
        y := NumGet(y, 0, "Int")
        w := NumGet(w, 0, "Int")
        h := NumGet(h, 0, "Int")
        Position := "x" x " y" y " w" w " h" h
        out := { x: x, y: y, w: w, h: h, Pos: Position }
    }
    return out
}

Acc_Parent(oAcc) {
    try {
        return Acc_Query(oAcc.accParent)
    }
}

Acc_Child(oAcc, ChildId := 0) {
    try {
        child := oAcc.AccChild(ChildId + 0)
        return Acc_Query(child)
    }
}

; Private
Acc_Query(oAcc) {
    try {
        query := ComObjQuery(oAcc, "{618736E0-3C3D-11CF-810C-00AA00389B71}")
        return ComObj(9, query, 1)
    }
}

; Private, deprecated
Acc_Error(Previous := "") {
    static setting := 0
    if (StrLen(Previous)) {
        setting := Previous
    }
    return setting
}

Acc_Children(oAcc) {
    static address := Acc_Init("AccessibleChildren")
    if (ComObjType(oAcc, "Name") != "IAccessible") {
        throw Exception("Invalid IAccessible Object", -1, oAcc)
    }
    pAcc := ComObjValue(oAcc)
    size := A_PtrSize * 2 + 8
    VarSetCapacity(accChildren, oAcc.accChildCount * size, 0)
    obtained := 0
    NTSTATUS := DllCall(address, "Ptr", pAcc, "Int", 0, "Int", oAcc.accChildCount, "Ptr", &accChildren, "Int*", obtained, "UInt")
    if (NTSTATUS != 0) {
        throw Exception("AccessibleChildren() failed.", -1, A_LastError)
    }
    children := []
    loop % obtained {
        i := (A_Index - 1) * size
        child := NumGet(accChildren, i + 8, "Int64")
        if (NumGet(accChildren, i, "Int64") = 9) {
            accChild := Acc_Query(child)
            children.Push(accChild)
            ObjRelease(child)
        } else {
            children.Push(child)
        }
    }
    return children
}

Acc_ChildrenByRole(oAcc, RoleText) {
    children := []
    for _, child in Acc_Children(oAcc) {
        if (Acc_Role(child) = RoleText) {
            children.Push(child)
        }
    }
    return children
}

/* Commands:
    - Aliases:
    Action -> DefaultAction
    DoAction -> DoDefaultAction
    Keyboard -> KeyboardShortcut
    - Properties:
    Child
    ChildCount
    DefaultAction
    Description
    Focus
    Help
    HelpTopic
    KeyboardShortcut
    Name
    Parent
    Role
    Selection
    State
    Value
    - Methods:
    DoDefaultAction
    Location
    - Other:
    Object
*/
Acc_Get(Command, ChildPath, ChildId := 0, Target*) {
    if (Command ~= "i)^(HitTest|Navigate|Select)$") {
        throw Exception("Command not implemented", -1, Command)
    }
    ChildPath := StrReplace(ChildPath, "_", " ")
    if (IsObject(Target[1])) {
        oAcc := Target[1]
    } else {
        hWnd := WinExist(Target*)
        oAcc := Acc_ObjectFromWindow(hWnd, 0)
    }
    if (ComObjType(oAcc, "Name") != "IAccessible") {
        throw Exception("Cannot access an IAccessible Object", -1, oAcc)
    }
    ChildPath := StrSplit(ChildPath, ".")
    for level, item in ChildPath {
        RegExMatch(item, "OS)(?<Role>\D+)(?<Index>\d*)", match)
        if (match) {
            item := match.Index ? match.Index : 1
            children := Acc_ChildrenByRole(oAcc, match.Role)
        } else {
            children := Acc_Children(oAcc)
        }
        if (children.HasKey(item)) {
            oAcc := children[item]
            continue
        }
        extra := match.Role
            ? "Role: " match.Role ", Index: " item
            : "Item: " item ", Level: " level
        throw Exception("Cannot access ChildPath Item", -1, extra)
    }
    switch (Command) { ; Expand aliases
        case "Action": Command := "DefaultAction"
        case "DoAction": Command := "DoDefaultAction"
        case "Keyboard": Command := "KeyboardShortcut"
        case "Object": return oAcc
    }
    switch (Command) {
        case "Location": out := Acc_Location(oAcc, ChildId).pos
        case "Parent": out := Acc_Parent(oAcc)
        case "Role", "State": out := Acc_%Command%(oAcc, ChildId)
        case "ChildCount", "Focus", "Selection": out := oAcc["acc" Command]
        default: out := oAcc["acc" Command](ChildId + 0)
    }
    return out
}
