#Requires AutoHotkey v2.0

; Version: 2023.10.05.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140

GetUrl(WinTitle*) {
    active := WinExist("A")
    target := WinExist(WinTitle*)
    wClass := WinGetClass()
    root := UIA.ElementFromHandle(target)
    static eCondition := UIA.PropertyCondition({ ControlType: "Edit" })
    ; Gecko family
    if (wClass ~= "Mozilla") {
        edit := root.FindFirst(eCondition)
        return edit.GetCurrentPropertyValue(UIA.Property.ValueValue)
    }
    ; Chromium-based, active
    if (active = target) {
        static dCondition := UIA.PropertyCondition({ ControlType: "Document" })
        edit := root.FindFirst(dCondition)
        return edit.GetCurrentPropertyValue(UIA.Property.ValueValue)
    }
    ; Chromium-based, inactive
    static tCondition := UIA.PropertyCondition({ ControlType: "ToolBar" })
    toolBar := root.FindFirst(tCondition)
    edit := toolBar.FindFirst(eCondition)
    url := edit.GetCurrentPropertyValue(UIA.Property.ValueValue)
    wTitle := WinGetTitle()
    ; Google Chrome
    if (InStr(wTitle, "- Google Chrome") && url && !(url ~= "^\w+:")) {
        static mCondition := UIA.PropertyCondition({ ControlType: "MenuItem" })
        menuItem := toolBar.FindFirst(mCondition)
        rect := menuItem.CurrentBoundingRectangle
        w := rect.right - rect.left, h := rect.bottom - rect.top
        url := "http" (w > h * 2 ? "" : "s") "://" url
    }
    ; Microsoft Edge
    static edge := "- Microsoft" Chr(0x200b) " Edge" ; Zero-width space
    if (InStr(wTitle, edge) && url && !(url ~= "^\w+:")) {
        url := "http://" url
    }
    return url
}
