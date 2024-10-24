#Requires AutoHotkey v1.1

; Version: 2023.10.05.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140

GetUrl(WinTitle*) {
    active := WinExist("A")
    target := WinExist(WinTitle*)
    WinGetClass wClass
    root := UIA_Interface().ElementFromHandle(target)
    ; Gecko family
    if (wClass ~= "Mozilla") {
        return root.FindFirstByType("Edit").CurrentValue
    }
    ; Chromium-based, active
    if (active = target) {
        return root.FindFirstByType("Document").CurrentValue
    }
    ; Chromium-based, inactive
    toolBar := root.FindFirstByType("ToolBar")
    url := toolBar.FindFirstByType("Edit").CurrentValue
    WinGetTitle wTitle
    ; Google Chrome
    if (InStr(wTitle, "- Google Chrome") && url && !(url ~= "^\w+:")) {
        rect := toolBar.FindFirstByType("MenuItem").CurrentBoundingRectangle
        w := rect.r - rect.l, h := rect.b - rect.t
        url := "http" (w > h * 2 ? "" : "s") "://" url
    }
    ; Microsoft Edge
    static edge := "- Microsoft" Chr(0x200b) " Edge" ; Zero-width space
    if (InStr(wTitle, edge) && url && !(url ~= "^\w+:")) {
        url := "http://" url
    }
    return url
}
