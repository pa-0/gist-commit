/*
    AutoHotkey script - Windows Explorer

    Author: https://github.com/flipeador
    AutoHotkey: https://www.autohotkey.com
*/

#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook

ProcessSetPriority('High')
TraySetIcon('imageres.dll', -129)

; ------------------------------------------------------------
; ------------------------------------------------------------

/**
 * Open a new Explorer process in a new tab with WIN+E.
 */
#e:: TabExplorer()

/**
 * Walk between the tabs with the side mouse buttons.
 * Uncomment the lines to activate.
 */
; #HotIf WinActive('ahk_class CabinetWClass')
; XButton2:: Send(KeyState('^') ? '!{right}' : '^{tab}')
; XButton1:: Send(KeyState('^') ? '!{left}' : '^+{tab}')
; #HotIf

/**
 * Detect when a new explorer window is created.
 * Uncomment the line to activate.
 */
; RegisterShellHookWindow(OnShellWndMsg)

/**
 * Make the window under the cursor stay on top of all other windows.
 * WIN+LEFT_BUTTON to activate.
 * WIN+RIGHT_BUTTON to deactivate.
 */
#LButton:: {
    MouseGetPos(,, &hWnd)
    WinSetAlwaysOnTop(true, hWnd)
}
#RButton:: {
    A_hWnd := WinGetID('A')
    MouseGetPos(,, &hWnd)
    WinSetAlwaysOnTop(false, hWnd)
    WinActivate(hWnd)
    WinActivate(A_hWnd)
}

/**
 * Move between virtual desktops with the side mouse buttons.
 */
#XBUTTON1:: VirtualDesktop('Left')  ; move left
#XBUTTON2:: VirtualDesktop('Right') ; move right

; ------------------------------------------------------------
; ------------------------------------------------------------

ArrayHas(arr, value)
{
    for val in arr
        if (val == value)
            return true
}

OnShellWndMsg(wparam, lparam, msg, hwnd)
{
    switch (wParam)
    {
        case 1: ; HSHELL_WINDOWCREATED
            list := WinGetList('ahk_class CabinetWClass')
            check := ArrayHas(list, lparam)
            if check && list.length > 1
            {
                path := GetExplorerPath(lparam)
                WinClose(lparam)
                WinWaitClose(lparam)
                Sleep(250), TabExplorer()
                Sleep(1000), Send('!d') ; focus address bar
                Sleep(250), Send('{raw}' . path)
                Sleep(250), Send('{enter}')
            }
            else if check
                TabExplorer(false)
    }
}

VirtualDesktop(key)
{
    Send('#^{' . key . '}')
    hWnd := DllCall('FindWindowW', 'Str', 'XamlExplorerHostIslandWindow', 'Ptr', 0, 'Ptr')
    hWnd ? WinWait(hWnd) : 0
    hWnd ? WinHide(hWnd) : 0
}

TabExplorer(newtab:=true)
{
    warea := GetMonitorWorkArea()
    w := warea[5] * 60 / 100 ; 60%
    h := warea[6] * 55 / 100 ; 55%
    x := warea[3] - w ; right  - w
    y := warea[4] - h ; bottom - h

    KeyWait('e')

    if WinExist('ahk_class CabinetWClass')
    {
        WinActivate()
        WinWaitActive()
        WinRestore()
        WinMove(x, y, w, h)
        Send('+{F6}')
        if newtab
            Send('^t') ; new tab
    }
    else
    {
        Send('#e') ; win+e
        WinWait('ahk_class CabinetWClass')
        WinActivate()
        WinWaitActive()
        WinRestore()
        WinMove(x, y, w, h)
    }
}

/**
 * Get the physical state of a keyboard/mouse button.
 * @return Whether the keyboard/mouse button is pressed or released.
 */
KeyState(key)
{
    return GetKeyState(key, 'P')
}

/**
 * Get the path of the specified explorer window.
 */
GetExplorerPath(hwnd)
{
    for window in ComObject("Shell.Application").Windows
        if (window.hwnd == hwnd)
            return window.Document.Folder.Self.Path
}

/**
 * Register a function to receive certain window events.
 */
RegisterShellHookWindow(hook)
{

    if !DllCall('RegisterShellHookWindow', 'Ptr', A_ScriptHwnd)
        throw OSError()
    msgnum := DllCall('RegisterWindowMessage', 'Str', 'SHELLHOOK')
    OnMessage(msgnum, hook)
}

/**
 * Get the work area of the monitor nearest the cursor.
 *
 * The work area is the portion of the screen not obscured
 * by the system taskbar or by app desktop toolbars.
 * @returns `[left, top, right, bottom, width, height]`
 */
GetMonitorWorkArea()
{
    POINT := Buffer(8)
    DllCall('GetCursorPos', 'Ptr', POINT)

    hMon := DllCall('MonitorFromPoint', 'Ptr', POINT, 'UInt', 2, 'Ptr')

    MONITORINFO := Buffer(40)
    NumPut('UInt', MONITORINFO.Size, MONITORINFO)
    if !DllCall('GetMonitorInfoW', 'Ptr', hMon, 'Ptr', MONITORINFO)
        throw OSError()
    left := NumGet(MONITORINFO, 20, 'Int')
    top := NumGet(MONITORINFO, 24, 'Int')
    right := NumGet(MONITORINFO, 28, 'Int')
    bottom := NumGet(MONITORINFO, 32, 'Int')

    return [left, top, right, bottom, right-left, bottom-top]
}