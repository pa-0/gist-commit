
; Version: 2021.11.14.1

TrayRefresh()
{
	dhw := A_DetectHiddenWindows
	DetectHiddenWindows On
	TrayRefresh_Clear("Shell_TrayWnd", 323)
	; For hidden icons:
	; TrayRefresh_Clear("NotifyIconOverflowWindow", 321)
	DetectHiddenWindows % dhw
}

TrayRefresh_Clear(WinClass, ControlNN)
{
	WinClass := "ahk_class" WinClass
	ControlNN := "ToolbarWindow" ControlNN
	iconSize := 16
	WinExist(WinClass)
	ControlGetPos ,,, w, h, % ControlNN
	while (h > 0)
	{
		while (w > 0)
		{
			point := (h << 16) + w
			; 0x0200 = WM_MOUSEMOVE
			PostMessage 0x0200, 0, % point, % ControlNN
			w -= iconSize
		}
		h -= iconSize
	}
}
