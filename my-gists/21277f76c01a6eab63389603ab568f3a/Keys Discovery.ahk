
; Version: 2022.07.01.1
; https://gist.github.com/da81e29517b0ba6dd552f7c6439be032

/* Virtual/Scan Codes & Key Names

Uses a keyboard hook to provide all information of a key pressed.

The idea of the Gui is from SKAN, however his script fails to detect some keys and other info
https://autohotkey.com/board/topic/21105-crazy-scripting-scriptlet-to-find-scancode-of-a-key/
*/

#NoTrayIcon
#SingleInstance force

hook := InputHook()
hook.KeyOpt("{All}", "NS")
hook.OnKeyDown := Func("KeyDown")
hook.Start()

Gui New, ToolWindow AlwaysOnTop
Gui Font, Bold q5 s14, Consolas
Gui Add, Text, 0x201 +Border w160 h33, {vk00} {sc000}
Gui Show,, > Key Information Discovery


return ; End of auto-execute


KeyDown(Hook, vk, sc) {
	vkCode := Format("vk{:02X}", vk)
	scCode := Format("sc{:03X}", sc)
	ToolTip % "Key name: " GetKeyName(vkCode), 2, 80
	GuiControl Text, Static1, % "{" vkCode "} {" scCode "}"
}

GuiClose:
	ExitApp
return
