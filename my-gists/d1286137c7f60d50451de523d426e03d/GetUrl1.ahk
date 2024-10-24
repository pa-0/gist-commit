﻿#Requires AutoHotkey v1.1

; Version: 2023.10.05.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140

GetUrl() { ; Active Window Only
    static S_OK := 0, TreeScope_Descendants := 4, UIA_ControlTypePropertyId := 30003, UIA_DocumentControlTypeId := 50030, UIA_EditControlTypeId := 50004, UIA_ValueValuePropertyId := 30045
    WinGet hWnd, ID, A
    WinGetClass winClass, A
    eRoot := condition := eFirst := 0
    IUIAutomation := ComObjCreate("{FF48DBA4-60EF-4201-AA87-54103EEF594E}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
    HRESULT := DllCall(NumGet(NumGet(IUIAutomation + 0) + 6 * A_PtrSize), "Ptr", IUIAutomation, "Ptr", hWnd, "Ptr*", eRoot)
    if (HRESULT != S_OK) {
        throw Exception("IUIAutomation::ElementFromHandle()", -1, HRESULT)
    }
    ctrlTypeId := (winClass ~= "Chrome" ? UIA_DocumentControlTypeId : UIA_EditControlTypeId)
    VarSetCapacity(value, 8 + 2 * A_PtrSize, 0)
    NumPut(3, value, 0, "UShort")
    NumPut(ctrlTypeId, value, 8, "Ptr")
    if (A_PtrSize = 8) {
        HRESULT := DllCall(NumGet(NumGet(IUIAutomation + 0) + 23 * A_PtrSize), "Ptr", IUIAutomation, "UInt", UIA_ControlTypePropertyId, "Ptr", &value, "Ptr*", condition)
    } else {
        HRESULT := DllCall(NumGet(NumGet(IUIAutomation + 0) + 23 * A_PtrSize), "Ptr", IUIAutomation, "UInt", UIA_ControlTypePropertyId, "UInt64", NumGet(value, 0, "UInt64"), "UInt64", NumGet(value, 8, "UInt64"), "Ptr*", condition)
    }
    if (HRESULT != S_OK) {
        throw Exception("IUIAutomation::CreatePropertyCondition()", -1, HRESULT)
    }
    HRESULT := DllCall(NumGet(NumGet(eRoot + 0) + 5 * A_PtrSize), "Ptr", eRoot, "UInt", TreeScope_Descendants, "Ptr", condition, "Ptr*", eFirst)
    if (HRESULT != S_OK) {
        throw Exception("IUIAutomationElement::FindFirst()", -1, HRESULT)
    }
    VarSetCapacity(propertyValue, 8 + 2 * A_PtrSize, 0)
    HRESULT := DllCall(NumGet(NumGet(eFirst + 0) + 10 * A_PtrSize), "Ptr", eFirst, "UInt", UIA_ValueValuePropertyId, "Ptr", &propertyValue)
    if (HRESULT != S_OK) {
        throw Exception("IUIAutomationElement::GetCurrentPropertyValue()", -1, HRESULT)
    }
    ObjRelease(eRoot)
    ObjRelease(condition)
    ObjRelease(eFirst)
    ObjRelease(IUIAutomation)
    try {
        pProperty := NumGet(propertyValue, 8, "Ptr")
        return StrGet(pProperty, "UTF-16")
    }
}
