#Requires AutoHotkey v2.0
#Include %A_LineFile%\..\AppVol.ahk

Exit() ; End of auto-execute

; Active Window
1::AppVol() ; Toggle Mute
2::AppVol("-2") ; Decrease volume 2%
3::AppVol("+2") ; Increase volume 2%
4::AppVol(  50) ; Set volume to 50%
5::AppVol( 100) ; Set volume to 100%

; By executable name
+1::AppVol("firefox.exe") ; Toggle Mute
+2::AppVol("firefox.exe", "-2") ; Decrease volume 2%
+3::AppVol("firefox.exe", "+2") ; Increase volume 2%
+4::AppVol("firefox.exe",   50) ; Set volume to 50%
+5::AppVol("firefox.exe",  100) ; Set volume to 100%

; By window title
^1::AppVol("Picture-in-Picture") ; Toggle Mute
^2::AppVol("Picture-in-Picture", "-2") ; Decrease volume 2%
^3::AppVol("Picture-in-Picture", "+2") ; Increase volume 2%
^4::AppVol("Picture-in-Picture",   50) ; Set volume to 50%
^5::AppVol("Picture-in-Picture",  100) ; Set volume to 100%
