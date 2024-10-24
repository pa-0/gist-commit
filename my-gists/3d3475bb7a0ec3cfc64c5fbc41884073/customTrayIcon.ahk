#Requires AutoHotKey v2.0
#SingleInstance Force
Persistent

; ---- This script will add a new tray icon that you can double click to run something
; ---- i wrote this at 2am with absolutely zero prior knowledge to AHK, it only took like 3 hours heh...

; ---- EDITABLE STUFF --------------------

filePath := "C:\path\to\file.bat"
; path to the file that you want this to open (i've only tested it on .BAT files, but theoretically should work on anything)

trayIcon := "C:\path\to\icon.ico"
; path to the icon you want to use. both .PNG and .ICO work but .ICO yields a much less pixelated icon when scaled down so i recommend that (just put your png through an online converter)

trayTooltip := "Switch Audio Output"
; tooltip name that will show when hovering or right clicking the tray icon & right clicking

clicksToRun := 2
; the amount of times you need to click the icon. 2 is double click, 1 is single click (if you're insane, go above 2 i guess?)

; ---- END OF EDITABLE STUFF --------------
; -----------------------------------------

TraySetIcon(trayIcon) ; Override default tray icon with what we want
A_IconTip := trayTooltip ; Set name of tray icon to {trayTooltip}

sysTray := A_TrayMenu ; Get right click menu of the tray icon
sysTray.Delete() ; Remove all pre-existing stuff that it makes by default
sysTray.Add(trayTooltip, (i, *) => Run(filePath)) ; Add a new menu item in the right click menu that uses {trayTooltip} as title and runs {filePath}
sysTray.Default := trayTooltip ; Set the default tray menu item to the one we just made (makes it so it will run that menu item when you click the icon)
sysTray.ClickCount := clicksToRun

sysTray.Add("Hide (Closes AHK Script)", MenuExit) ; another new menu item that runs the function below

MenuExit(*) { ; im not sure why this function had to exist instead of just putting MenuExit directly in sysTray.Add but whatever, it works.
	ExitApp
}