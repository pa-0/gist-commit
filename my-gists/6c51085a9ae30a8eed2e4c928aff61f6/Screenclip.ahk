#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;;_____________________________________________________________________________________
;#[General Information for file management]
ScriptName=Screenclip.ahk
VN=1.0.4.1 												    
LE=26 Juni 2021 12:40:06                               				    
AU=Learning one, adjusted by Gewerd Strauss
;______________________________________________________________________________________
;#[File Overview]
Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,118 ;Set custom Script icon
menu, Tray, Add, Win+Ctrl+Left: no copy to clipboard, WCL
menu, Tray, Add, Win+Alt+Left: auto copy to clipboard, WCL
;______________________________________________________________________________________
;#[Autorun Section]
global sPathToScreenClipFolder:= A_Desktop "\ScreenClip\"
OnMessage(0x404, "f_TrayIconSingleClickCallBack")
SCW_SetUp("MaxGuis.45") ; change the number here to set the maximum number of guis
;SCW_SetUp("MaxGuis.30 StartAfter.50 BorderAColor.ff000000 BorderBColor.ffffff00")
if((A_PtrSize=8&&A_IsCompiled="")||!A_IsUnicode){ ;32 bit=4  ;64 bit=8
	SplitPath,A_AhkPath,,dir
	if(!FileExist(correct:=dir "\AutoHotkeyU32.exe")){
		MsgBox error
		ExitApp
	}
	Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
	ExitApp
	return
}
OnError("f_RestartScreenclip")
;#NoTrayIcon
;Menu, tray, icon, AutoRun\camera.ico , 1
#SingleInstance, Force
#^Lbutton::SCW_ScreenClip2Win(clip:=0,email:=0)  ;Win+Control+Left click- no copy to clipboard
;#Lbutton::SCW_ScreenClip2Win(clip:=0,email:=1) ; Wind+Alt+left click =saves images and attach to email (path of jpg on clipboard)
#!Lbutton::SCW_ScreenClip2Win(clip:=1,email:=0) ; Win+left click mouse=auto copy to clipboard

#IfWinActive, ScreenClippingWindow
^c::SCW_Win2Clipboard(0)      ; copy selected win to clipboard  Change to (1) if want border
^s:: SCW_Win2File(0)  ;save selected clipping on desktop as timestamp named .png  ; this was submited by tervon 
Esc:: winclose, A ;contribued by tervon 
;Rbutton:: winclose, A ;contributed by tervon 
#IfWinActive


;===Description========================================================================
/*
	[module/script] ScreenClip2Win
	Author:      Learning one
	Thanks:      Tic, HotKeyIt
	
	Creates always on top layered windows from screen clippings. Click in upper right corner to close win. Click and drag to move it.
	Uses Gdip.ahk by Tic.
	
	#Include ScreenClip2Win.ahk      ; by Learning one
;=== Short documentation ===
	SCW_ScreenClip2Win()          ; creates always on top window from screen clipping. Click and drag to select area.
	SCW_DestroyAllClipWins()       ; destroys all screen clipping windows.
	SCW_Win2Clipboard()            ; copies window to clipboard. By default, removes borders. To keep borders, specify "SCW_Win2Clipboard(1)"
	SCW_SetUp(Options="")         ; you can change some default options in Auto-execute part of script. Syntax: "<option>.<value>"
	StartAfter - module will start to consume GUIs for screen clipping windows after specified GUI number. Default: 80
	MaxGuis - maximum number of screen clipping windows. Default: 6
	BorderAColor - Default: ff6666ff (ARGB format)
	BorderBColor - Default: ffffffff (ARGB format)
	DrawCloseButton - on/off draw "Close Button" on screen clipping windows. Default: 0 (off)
	AutoMonitorWM_LBUTTONDOWN - on/off automatic monitoring of WM_LBUTTONDOWN message. Default: 1 (on)
	SelColor - selection color. Default: Yellow
	SelTrans - selection transparency. Default: 80
	
	Example:   SCW_SetUp("MaxGuis.30 StartAfter.50 BorderAColor.ff000000 BorderBColor.ffffff00")
	
	
	
;=== Avoid OnMessage(0x201, "WM_LBUTTONDOWN") collision example===
	Gui, Show, w200 h200
	SCW_SetUp("AutoMonitorWM_LBUTTONDOWN.0")   ; turn off auto monitoring WM_LBUTTONDOWN	
	OnMessage(0x201, "WM_LBUTTONDOWN")   ; manualy monitor WM_LBUTTONDOWN
	Return
	
	^Lbutton::SCW_ScreenClip2Win()   ; click & drag
	Esc::ExitApp
	
	#Include Gdip.ahk      ; by Tic
	#Include ScreenClip2Win.ahk      ; by Learning one
	WM_LBUTTONDOWN() {
		if SCW_LBUTTONDOWN()   ; LBUTTONDOWN on module's screen clipping windows - isolate - it's module's buissines
			return
		else   ; LBUTTONDOWN on other windows created by script
			MsgBox,,, You clicked on script's window not created by this module,1
	}
*/


;===Functions==========================================================================
SCW_Version() {
	return 1.02
}

SCW_DestroyAllClipWins() {
	MaxGuis := SCW_Reg("MaxGuis"), StartAfter := SCW_Reg("StartAfter")
	Loop, %MaxGuis%
	{
		StartAfter++
		Gui %StartAfter%: Destroy
	}
}

SCW_SetUp(Options="") {
	if !(Options = "")
	{
		Loop, Parse, Options, %A_Space%
		{
			Field := A_LoopField
			DotPos := InStr(Field, ".")
			if (DotPos = 0)   
				Continue
			var := SubStr(Field, 1, DotPos-1)
			val := SubStr(Field, DotPos+1)
			if var in StartAfter,MaxGuis,AutoMonitorWM_LBUTTONDOWN,DrawCloseButton,BorderAColor,BorderBColor,SelColor,SelTrans
				%var% := val
		}
	}
	
	SCW_Default(StartAfter,80), SCW_Default(MaxGuis,6)
	SCW_Default(AutoMonitorWM_LBUTTONDOWN,1), SCW_Default(DrawCloseButton,0)
	SCW_Default(BorderAColor,"ff6666ff"), SCW_Default(BorderBColor,"ffffffff")
	SCW_Default(SelColor,"Yellow"), SCW_Default(SelTrans,80)
	
	SCW_Reg("MaxGuis", MaxGuis), SCW_Reg("StartAfter", StartAfter), SCW_Reg("DrawCloseButton", DrawCloseButton)
	SCW_Reg("BorderAColor", BorderAColor), SCW_Reg("BorderBColor", BorderBColor)
	SCW_Reg("SelColor", SelColor), SCW_Reg("SelTrans",SelTrans)
	SCW_Reg("WasSetUp", 1)
	if AutoMonitorWM_LBUTTONDOWN
		OnMessage(0x201, "SCW_LBUTTONDOWN")
}

SCW_ScreenClip2Win(clip=0,email=0) {
	static c
	if !(SCW_Reg("WasSetUp"))
		SCW_SetUp()
	
	StartAfter := SCW_Reg("StartAfter"), MaxGuis := SCW_Reg("MaxGuis"), SelColor := SCW_Reg("SelColor"), SelTrans := SCW_Reg("SelTrans")
	c++
	if (c > MaxGuis)
		c := 1
	
	GuiNum := StartAfter + c
	Area := SCW_SelectAreaMod("g" GuiNum " c" SelColor " t" SelTrans)
	StringSplit, v, Area, |
	if (v3 < 10 and v4 < 10)   ; too small area
		return
	
	pToken := Gdip_Startup()
	if pToken =
	{
		MsgBox, 64, GDI+ error, GDI+ failed to start. Please ensure you have GDI+ on your system.
		return
	}
	
	Sleep, 100
	pBitmap := Gdip_BitmapFromScreen(Area)
	
	if (email=1){
;**********************Added to automatically save to bmp*********************************
		File1:=A_ScriptDir . "\example.BMP" ;path to file to save (make sure uppercase extenstion.  see below for options
		Gdip_SaveBitmapToFile(pBitmap, File1) ;Exports automatcially to file
		
		File2:=A_ScriptDir . "\example.JPG" ;path to file to save (make sure uppercase extenstion.  see below for options
		Gdip_SaveBitmapToFile(pBitmap, File2) ;Exports automatcially to file
		Clipboard:=File2
		
;**********************make sure outlook is running so email will be sent*********************************
		Process, Exist, Outlook.exe    ; check to see if Outlook is running. 
		Outlook_pid=%errorLevel%         ; errorlevel equals the PID if active
		If (Outlook_pid = 0)   { ; 
			run outlook.exe
			WinWait, Microsoft Outlook, ,3
		}
;~ MsgBox here 1
;**********************Write email*********************************
;~ COM_Init()
		olMailItem := 0
		try
			IsObject(MailItem := ComObjActive("Outlook.Application").CreateItem(olMailItem)) ; Get the Outlook application object if Outlook is open
		catch
			MailItem  := ComObjCreate("Outlook.Application").CreateItem(olMailItem) ; Create if Outlook is not open
;~ MsgBox here 2
		
		olFormatHTML := 2
		MailItem.BodyFormat := olFormatHTML
;~ MailItem.TO := (MailTo)
;~ MailItem.CC :="glines@ti.com"
;~ TodayDate := A_DDDD . ", " . A_MMM . " " . A_DD . ", " . A_YYYY
		FormatTime, TodayDate , YYYYMMDDHH24MISS, dddd MMMM d, yyyy h:mm:ss tt
		MailItem.Subject :="Screen shot taken : " (TodayDate) ;Subject line of email
		
		MailItem.HTMLBody := "
<H2 style='BACKGROUND-COLOR: red'><br></H2>
<HTML>Attached you will find the screenshot taken on "(TodayDate)" <br><br>
<span style='color:black'>Please let me know if you have any questions.<br><br><a href='mailto:Glines@TI.com'>Joe Glines</a> <br>214.567.3623
</HTML>"
		MailItem.Attachments.Add(File1)
		MailItem.Attachments.Add(File2)
		MailItem.Display ;
		Reload
	}
	
;*******************************************************
	SCW_CreateLayeredWinMod(GuiNum,pBitmap,v1,v2, SCW_Reg("DrawCloseButton"))
	Gdip_Shutdown("pToken")
	if clip=1
	{
 ;********************** added to copy to clipboard by default*********************************
		WinActivate, ScreenClippingWindow ahk_class AutoHotkeyGUI ;activates lat clipped window
		SCW_Win2Clipboard(0)  ;copies to clipboard by default w/o border
;~ MsgBox on clipboard
;*******************************************************
	}
}

SCW_SelectAreaMod(Options="") {
	CoordMode, Mouse, Screen
	MouseGetPos, MX, MY
	loop, parse, Options, %A_Space%
	{
		Field := A_LoopField
		FirstChar := SubStr(Field,1,1)
		if FirstChar contains c,t,g,m
		{
			StringTrimLeft, Field, Field, 1
			%FirstChar% := Field
		}
	}
	c := (c = "") ? "Blue" : c, t := (t = "") ? "50" : t, g := (g = "") ? "99" : g
	Gui %g%: Destroy
;   Gui %g%: +AlwaysOnTop -caption +Border +ToolWindow +LastFound
	Gui %g%: +AlwaysOnTop -caption +Border +ToolWindow +LastFound -DPIScale ;provided from rommmcek 10/23/16
	
	WinSet, Transparent, %t%
	Gui %g%: Color, %c%
	Hotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W*)")
	While, (GetKeyState(Hotkey, "p"))
	{
		Sleep, 10
		MouseGetPos, MXend, MYend
		w := abs(MX - MXend), h := abs(MY - MYend)
		X := (MX < MXend) ? MX : MXend
		Y := (MY < MYend) ? MY : MYend
		Gui %g%: Show, x%X% y%Y% w%w% h%h% NA
	}
	Gui %g%: Destroy
	MouseGetPos, MXend, MYend
	If ( MX > MXend )
		temp := MX, MX := MXend, MXend := temp
	If ( MY > MYend )
		temp := MY, MY := MYend, MYend := temp
	Return MX "|" MY "|" w "|" h
}

SCW_CreateLayeredWinMod(GuiNum,pBitmap,x,y,DrawCloseButton=0) {
	static CloseButton := 16
	BorderAColor := SCW_Reg("BorderAColor"), BorderBColor := SCW_Reg("BorderBColor")
	
	Gui %GuiNum%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs
	Gui %GuiNum%: Show, Na, ScreenClippingWindow
	hwnd := WinExist()
	
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	hbm := CreateDIBSection(Width+6, Height+6), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)
	
	Gdip_DrawImage(G, pBitmap, 3, 3, Width, Height)
	Gdip_DisposeImage(pBitmap)
	
	pPen1 := Gdip_CreatePen("0x" BorderAColor, 3), pPen2 := Gdip_CreatePen("0x" BorderBColor, 1)
	if DrawCloseButton
	{
		Gdip_DrawRectangle(G, pPen1, 1+Width-CloseButton+3, 1, CloseButton, CloseButton)
		Gdip_DrawRectangle(G, pPen2, 1+Width-CloseButton+3, 1, CloseButton, CloseButton)
	}
	Gdip_DrawRectangle(G, pPen1, 1, 1, Width+3, Height+3)
	Gdip_DrawRectangle(G, pPen2, 1, 1, Width+3, Height+3)
	Gdip_DeletePen(pPen1), Gdip_DeletePen(pPen2)
	
	UpdateLayeredWindow(hwnd, hdc, x-3, y-3, Width+6, Height+6)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	SCW_Reg("G" GuiNum "#HWND", hwnd)
	SCW_Reg("G" GuiNum "#XClose", Width+6-CloseButton)
	SCW_Reg("G" GuiNum "#YClose", CloseButton)
	Return hwnd
}

SCW_LBUTTONDOWN() {
	MouseGetPos,,, WinUMID
	WinGetTitle, Title, ahk_id %WinUMID%
	if Title = ScreenClippingWindow
	{
		PostMessage, 0xA1, 2,,, ahk_id %WinUMID%
		KeyWait, Lbutton
		CoordMode, mouse, Relative
		MouseGetPos, x,y
		XClose := SCW_Reg("G" A_Gui "#XClose"), YClose := SCW_Reg("G" A_Gui "#YClose")
		if (x > XClose and y < YClose)
			Gui %A_Gui%: Destroy
		return 1   ; confirm that click was on module's screen clipping windows
	}
}

SCW_Reg(variable, value="") {
	static
	if (value = "") {
		yaqxswcdevfr := kxucfp%variable%pqzmdk
		Return yaqxswcdevfr
	}
	Else
		kxucfp%variable%pqzmdk = %value%
}

SCW_Default(ByRef Variable,DefaultValue) {
	if (Variable="")
		Variable := DefaultValue
}

SCW_Win2Clipboard(KeepBorders=0) {
	/*   ;   does not work for layered windows
		ActiveWinID := WinExist("A")
		pBitmap := Gdip_BitmapFromHWND(ActiveWinID)
		Gdip_SetBitmapToClipboard(pBitmap)
	*/
	Send, !{PrintScreen} ; Active Win's client area to Clipboard
	if !KeepBorders
	{
		pToken := Gdip_Startup()
		pBitmap := Gdip_CreateBitmapFromClipboard()
		Gdip_GetDimensions(pBitmap, w, h)
		pBitmap2 := SCW_CropImage(pBitmap, 3, 3, w-6, h-6)
		Gdip_SetBitmapToClipboard(pBitmap2)
		
		Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2)
		Gdip_Shutdown("pToken")
	}
}

SCW_CropImage(pBitmap, x, y, w, h) {
	pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
	Gdip_DeleteGraphics(G2)
	return pBitmap2
}


; Gdip standard library v1.38 by tic (Tariq Porter) 28/08/10
;
;#####################################################################################
;#####################################################################################
; STATUS ENUMERATION
; Return values for functions specified to have status enumerated return type
;#####################################################################################
;
; Ok =      = 0
; GenericError    = 1
; InvalidParameter   = 2
; OutOfMemory    = 3
; ObjectBusy    = 4
; InsufficientBuffer  = 5
; NotImplemented   = 6
; Win32Error    = 7
; WrongState    = 8
; Aborted     = 9
; FileNotFound    = 10
; ValueOverflow    = 11
; AccessDenied    = 12
; UnknownImageFormat  = 13
; FontFamilyNotFound  = 14
; FontStyleNotFound   = 15
; NotTrueTypeFont   = 16
; UnsupportedGdiplusVersion = 17
; GdiplusNotInitialized  = 18
; PropertyNotFound   = 19
; PropertyNotSupported  = 20
; ProfileNotFound   = 21
;
;#####################################################################################
;#####################################################################################
; FUNCTIONS
;#####################################################################################
;
; UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster="")
; SetImage(hwnd, hBitmap)
; Gdip_BitmapFromScreen(Screen=0, Raster="")
; CreateRectF(ByRef RectF, x, y, w, h)
; CreateSizeF(ByRef SizeF, w, h)
; CreateDIBSection
;
;#####################################################################################

; Function:        UpdateLayeredWindow
; Description:     Updates a layered window with the handle to the DC of a gdi bitmap
; 
; hwnd            Handle of the layered window to update
; hdc              Handle to the DC of the GDI bitmap to update the window with
; Layeredx         x position to place the window
; Layeredy         y position to place the window
; Layeredw         Width of the window
; Layeredh         Height of the window
; Alpha            Default = 255 : The transparency (0-255) to set the window transparency
;
; return          If the function succeeds, the return value is nonzero
;
; notes      If x or y omitted, then layered window will use its current coordinates
;       If w or h omitted then current width and height will be used

UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
{
	if ((x != "") && (y != ""))
		VarSetCapacity(pt, 8), NumPut(x, pt, 0), NumPut(y, pt, 4)
	
	if (w = "") ||(h = "")
		WinGetPos,,, w, h, ahk_id %hwnd%
	
	return DllCall("UpdateLayeredWindow", "uint", hwnd, "uint", 0, "uint", ((x = "") && (y = "")) ? 0 : &pt
 , "int64*", w|h<<32, "uint", hdc, "int64*", 0, "uint", 0, "uint*", Alpha<<16|1<<24, "uint", 2)
}

;#####################################################################################

; Function    BitBlt
; Description   The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle 
;      of pixels from the specified source device context into a destination device context.
;
; dDC     handle to destination DC
; dx     x-coord of destination upper-left corner
; dy     y-coord of destination upper-left corner
; dw     width of the area to copy
; dh     height of the area to copy
; sDC     handle to source DC
; sx     x-coordinate of source upper-left corner
; sy     y-coordinate of source upper-left corner
; Raster    raster operation code
;
; return    If the function succeeds, the return value is nonzero
;
; notes     If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;
; BLACKNESS    = 0x00000042
; NOTSRCERASE   = 0x001100A6
; NOTSRCCOPY   = 0x00330008
; SRCERASE    = 0x00440328
; DSTINVERT    = 0x00550009
; PATINVERT    = 0x005A0049
; SRCINVERT    = 0x00660046
; SRCAND    = 0x008800C6
; MERGEPAINT   = 0x00BB0226
; MERGECOPY    = 0x00C000CA
; SRCCOPY    = 0x00CC0020
; SRCPAINT    = 0x00EE0086
; PATCOPY    = 0x00F00021
; PATPAINT    = 0x00FB0A09
; WHITENESS    = 0x00FF0062
; CAPTUREBLT   = 0x40000000
; NOMIRRORBITMAP  = 0x80000000

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
{
	return DllCall("gdi32\BitBlt", "uint", dDC, "int", dx, "int", dy, "int", dw, "int", dh
 , "uint", sDC, "int", sx, "int", sy, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function    StretchBlt
; Description   The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle, 
;      stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
;      The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
;
; ddc     handle to destination DC
; dx     x-coord of destination upper-left corner
; dy     y-coord of destination upper-left corner
; dw     width of destination rectangle
; dh     height of destination rectangle
; sdc     handle to source DC
; sx     x-coordinate of source upper-left corner
; sy     y-coordinate of source upper-left corner
; sw     width of source rectangle
; sh     height of source rectangle
; Raster    raster operation code
;
; return    If the function succeeds, the return value is nonzero
;
; notes     If no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt  

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
{
	return DllCall("gdi32\StretchBlt", "uint", ddc, "int", dx, "int", dy, "int", dw, "int", dh
 , "uint", sdc, "int", sx, "int", sy, "int", sw, "int", sh, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function    SetStretchBltMode
; Description   The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
;
; hdc     handle to the DC
; iStretchMode   The stretching mode, describing how the target will be stretched
;
; return    If the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
;
; STRETCH_ANDSCANS   = 0x01
; STRETCH_ORSCANS   = 0x02
; STRETCH_DELETESCANS  = 0x03
; STRETCH_HALFTONE   = 0x04

SetStretchBltMode(hdc, iStretchMode=4)
{
	return DllCall("gdi32\SetStretchBltMode", "uint", hdc, "int", iStretchMode)
}

;#####################################################################################

; Function    SetImage
; Description   Associates a new image with a static control
;
; hwnd     handle of the control to update
; hBitmap    a gdi bitmap to associate the static control with
;
; return    If the function succeeds, the return value is nonzero

SetImage(hwnd, hBitmap)
{
	SendMessage, 0x172, 0x0, hBitmap,, ahk_id %hwnd%
	E := ErrorLevel
	DeleteObject(E)
	return E
}

;#####################################################################################

; Function    SetSysColorToControl
; Description   Sets a solid colour to a control
;
; hwnd     handle of the control to update
; SysColor    A system colour to set to the control
;
; return    If the function succeeds, the return value is zero
;
; notes     A control must have the 0xE style set to it so it is recognised as a bitmap
;      By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
;
; COLOR_3DDKSHADOW    = 21
; COLOR_3DFACE     = 15
; COLOR_3DHIGHLIGHT    = 20
; COLOR_3DHILIGHT    = 20
; COLOR_3DLIGHT     = 22
; COLOR_3DSHADOW    = 16
; COLOR_ACTIVEBORDER   = 10
; COLOR_ACTIVECAPTION   = 2
; COLOR_APPWORKSPACE   = 12
; COLOR_BACKGROUND    = 1
; COLOR_BTNFACE     = 15
; COLOR_BTNHIGHLIGHT   = 20
; COLOR_BTNHILIGHT    = 20
; COLOR_BTNSHADOW    = 16
; COLOR_BTNTEXT     = 18
; COLOR_CAPTIONTEXT    = 9
; COLOR_DESKTOP     = 1
; COLOR_GRADIENTACTIVECAPTION = 27
; COLOR_GRADIENTINACTIVECAPTION = 28
; COLOR_GRAYTEXT    = 17
; COLOR_HIGHLIGHT    = 13
; COLOR_HIGHLIGHTTEXT   = 14
; COLOR_HOTLIGHT    = 26
; COLOR_INACTIVEBORDER   = 11
; COLOR_INACTIVECAPTION   = 3
; COLOR_INACTIVECAPTIONTEXT  = 19
; COLOR_INFOBK     = 24
; COLOR_INFOTEXT    = 23
; COLOR_MENU     = 4
; COLOR_MENUHILIGHT    = 29
; COLOR_MENUBAR     = 30
; COLOR_MENUTEXT    = 7
; COLOR_SCROLLBAR    = 0
; COLOR_WINDOW     = 5
; COLOR_WINDOWFRAME    = 6
; COLOR_WINDOWTEXT    = 8

SetSysColorToControl(hwnd, SysColor=15)
{
	WinGetPos,,, w, h, ahk_id %hwnd%
	bc := DllCall("GetSysColor", "Int", SysColor)
	pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
	pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	Gdip_DeleteBrush(pBrushClear)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	return 0
}

;#####################################################################################

; Function    Gdip_BitmapFromScreen
; Description   Gets a gdi+ bitmap from the screen
;
; Screen    0 = All screens
;      Any numerical value = Just that screen
;      x|y|w|h = Take specific coordinates with a width and height
; Raster    raster operation code
;
; return         If the function succeeds, the return value is a pointer to a gdi+ bitmap
;      -1:  one or more of x,y,w,h not passed properly
;
; notes     If no raster operation is specified, then SRCCOPY is used to the returned bitmap

Gdip_BitmapFromScreen(Screen=0, Raster="")
{
	if (Screen = 0)
	{
		Sysget, x, 76
		Sysget, y, 77 
		Sysget, w, 78
		Sysget, h, 79
	}
	else if (Screen&1 != "")
	{
		Sysget, M, Monitor, %Screen%
		x := MLeft, y := MTop, w := MRight-MLeft, h := MBottom-MTop
	}
	else
	{
		StringSplit, S, Screen, |
		x := S1, y := S2, w := S3, h := S4
	}
	
	if (x = "") || (y = "") || (w = "") || (h = "")
		return -1
	
	chdc := CreateCompatibleDC(), hbm := CreateDIBSection(w, h, chdc), obm := SelectObject(chdc, hbm), hhdc := GetDC()
	BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
	ReleaseDC(hhdc)
	
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hhdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
	return pBitmap
}

;#####################################################################################

; Function    Gdip_BitmapFromHWND
; Description   Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;
; hwnd     handle to the window to get a bitmap from
;
; return    If the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes     Window must not be not minimised in order to get a handle to it's client area

Gdip_BitmapFromHWND(hwnd)
{
	WinGetPos,,, Width, Height, ahk_id %hwnd%
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}
;#####################################################################################

; Function       CreateRectF
; Description   Creates a RectF object, containing a the coordinates and dimensions of a rectangle
;
; RectF          Name to call the RectF object
; x               x-coordinate of the upper left corner of the rectangle
; y               y-coordinate of the upper left corner of the rectangle
; w               Width of the rectangle
; h               Height of the rectangle
;
; return         No return value

CreateRectF(ByRef RectF, x, y, w, h)
{
	VarSetCapacity(RectF, 16)
	NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}
;#####################################################################################

; Function       CreateSizeF
; Description   Creates a SizeF object, containing an 2 values
;
; SizeF           Name to call the SizeF object
; w               w-value for the SizeF object
; h               h-value for the SizeF object
;
; return         No Return value

CreateSizeF(ByRef SizeF, w, h)
{
	VarSetCapacity(SizeF, 8)
	NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float")     
}
;#####################################################################################

; Function       CreatePointF
; Description   Creates a SizeF object, containing an 2 values
;
; SizeF           Name to call the SizeF object
; w               w-value for the SizeF object
; h               h-value for the SizeF object
;
; return         No Return value

CreatePointF(ByRef PointF, x, y)
{
	VarSetCapacity(PointF, 8)
	NumPut(x, PointF, 0, "float"), NumPut(y, PointF, 4, "float")     
}
;#####################################################################################

; Function    CreateDIBSection
; Description   The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;
; w      width of the bitmap to create
; h      height of the bitmap to create
; hdc     a handle to the device context to use the palette from
; bpp     bits per pixel (32 = ARGB)
; ppvBits    A pointer to a variable that receives a pointer to the location of the DIB bit values
;
; return    returns a DIB. A gdi bitmap
;
; notes     ppvBits will receive the location of the pixels in the DIB

CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
{
	hdc2 := hdc ? hdc : GetDC()
	VarSetCapacity(bi, 40, 0)
	NumPut(w, bi, 4), NumPut(h, bi, 8), NumPut(40, bi, 0), NumPut(1, bi, 12, "ushort"), NumPut(0, bi, 16), NumPut(bpp, bi, 14, "ushort")
	hbm := DllCall("CreateDIBSection", "uint" , hdc2, "uint" , &bi, "uint" , 0, "uint*", ppvBits, "uint" , 0, "uint" , 0)
	
	If !hdc
		ReleaseDC(hdc2)
	return hbm
}

;#####################################################################################

; Function    PrintWindow
; Description   The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;
; hwnd     A handle to the window that will be copied
; hdc     A handle to the device context
; Flags     Drawing options
;
; return    If the function succeeds, it returns a nonzero value
;
; PW_CLIENTONLY   = 1

PrintWindow(hwnd, hdc, Flags=0)
{
	return DllCall("PrintWindow", "uint", hwnd, "uint", hdc, "uint", Flags)
}

;#####################################################################################

; Function    DestroyIcon
; Description   Destroys an icon and frees any memory the icon occupied
;
; hIcon     Handle to the icon to be destroyed. The icon must not be in use
;
; return    If the function succeeds, the return value is nonzero

DestroyIcon(hIcon)
{
	return DllCall("DestroyIcon", "uint", hIcon)
}

;#####################################################################################

PaintDesktop(hdc)
{
	return DllCall("PaintDesktop", "uint", hdc)
}

;#####################################################################################

CreateCompatibleBitmap(hdc, w, h)
{
	return DllCall("gdi32\CreateCompatibleBitmap", "uint", hdc, "int", w, "int", h)
}

;#####################################################################################

; Function    CreateCompatibleDC
; Description   This function creates a memory device context (DC) compatible with the specified device
;
; hdc     Handle to an existing device context     
;
; return    returns the handle to a device context or 0 on failure
;
; notes     If this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

CreateCompatibleDC(hdc=0)
{
	return DllCall("CreateCompatibleDC", "uint", hdc)
}

;#####################################################################################

; Function    SelectObject
; Description   The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;
; hdc     Handle to a DC
; hgdiobj    A handle to the object to be selected into the DC
;
; return    If the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;
; notes     The specified object must have been created by using one of the following functions
;      Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;      Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;      Font - CreateFont, CreateFontIndirect
;      Pen - CreatePen, CreatePenIndirect
;      Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;
; notes     If the selected object is a region and the function succeeds, the return value is one of the following value
;
; SIMPLEREGION   = 2 Region consists of a single rectangle
; COMPLEXREGION   = 3 Region consists of more than one rectangle
; NULLREGION   = 1 Region is empty

SelectObject(hdc, hgdiobj)
{
	return DllCall("SelectObject", "uint", hdc, "uint", hgdiobj)
}

;#####################################################################################

; Function    DeleteObject
; Description   This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;      After the object is deleted, the specified handle is no longer valid
;
; hObject    Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;
; return    Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

DeleteObject(hObject)
{
	return DllCall("DeleteObject", "uint", hObject)
}

;#####################################################################################

; Function    GetDC
; Description   This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;      The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window. 
;
; hwnd     Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen     
;
; return    The handle the device context for the specified window's client area indicates success. NULL indicates failure

GetDC(hwnd=0)
{
	return DllCall("GetDC", "uint", hwnd)
}

;#####################################################################################

; Function    ReleaseDC
; Description   This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;
; hdc     Handle to the device context to be released
; hwnd     Handle to the window whose device context is to be released
;
; return    1 = released
;      0 = not released
;
; notes     The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;      An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function.

ReleaseDC(hdc, hwnd=0)
{
	return DllCall("ReleaseDC", "uint", hwnd, "uint", hdc)
}

;#####################################################################################

; Function    DeleteDC
; Description   The DeleteDC function deletes the specified device context (DC)
;
; hdc     A handle to the device context
;
; return    If the function succeeds, the return value is nonzero
;
; notes     An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

DeleteDC(hdc)
{
	return DllCall("DeleteDC", "uint", hdc)
}
;#####################################################################################

; Function    Gdip_LibraryVersion
; Description   Get the current library version
;
; return    the library version
;
; notes     This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

Gdip_LibraryVersion()
{
	return 1.38
}

;#####################################################################################

; Function:       Gdip_BitmapFromBRA
; Description:    Gets a pointer to a gdi+ bitmap from a BRA file
;
; BRAFromMemIn   The variable for a BRA file read to memory
; File     The name of the file, or its number that you would like (This depends on alternate parameter)
; Alternate    Changes whether the File parameter is the file name or its number
;
; return         If the function succeeds, the return value is a pointer to a gdi+ bitmap
;      -1 = The BRA variable is empty
;      -2 = The BRA has an incorrect header
;      -3 = The BRA has information missing
;      -4 = Could not find file inside the BRA

Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
{
	if !BRAFromMemIn
		return -1
	Loop, Parse, BRAFromMemIn, `n
	{
		if (A_Index = 1)
		{
			StringSplit, Header, A_LoopField, |
			if (Header0 != 4 || Header2 != "BRA!")
				return -2
		}
		else if (A_Index = 2)
		{
			StringSplit, Info, A_LoopField, |
			if (Info0 != 3)
				return -3
		}
		else
			break
	}
	if !Alternate
		StringReplace, File, File, \, \\, All
	RegExMatch(BRAFromMemIn, "mi`n)^" (Alternate ? File "\|.+?\|(\d+)\|(\d+)" : "\d+\|" File "\|(\d+)\|(\d+)") "$", FileInfo)
	if !FileInfo
		return -4
	
	hData := DllCall("GlobalAlloc", "uint", 2, "uint", FileInfo2)
	pData := DllCall("GlobalLock", "uint", hData)
	DllCall("RtlMoveMemory", "uint", pData, "uint", &BRAFromMemIn+Info2+FileInfo1, "uint", FileInfo2)
	DllCall("GlobalUnlock", "uint", hData)
	DllCall("ole32\CreateStreamOnHGlobal", "uint", hData, "int", 1, "uint*", pStream)
	DllCall("gdiplus\GdipCreateBitmapFromStream", "uint", pStream, "uint*", pBitmap)
	DllCall(NumGet(NumGet(1*pStream)+8), "uint", pStream)
	return pBitmap
}

;#####################################################################################

; Function    Gdip_DrawRectangle
; Description   This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x      x-coordinate of the top left of the rectangle
; y      y-coordinate of the top left of the rectangle
; w      width of the rectanlge
; h      height of the rectangle
;
; return    status enumeration. 0 = success
;
; notes     as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
	return DllCall("gdiplus\GdipDrawRectangle", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function    Gdip_DrawRoundedRectangle
; Description   This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x      x-coordinate of the top left of the rounded rectangle
; y      y-coordinate of the top left of the rounded rectangle
; w      width of the rectanlge
; h      height of the rectangle
; r      radius of the rounded corners
;
; return    status enumeration. 0 = success
;
; notes     as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
	Gdip_ResetClip(pGraphics)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_ResetClip(pGraphics)
	return E
}

;#####################################################################################

; Function    Gdip_DrawEllipse
; Description   This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x      x-coordinate of the top left of the rectangle the ellipse will be drawn into
; y      y-coordinate of the top left of the rectangle the ellipse will be drawn into
; w      width of the ellipse
; h      height of the ellipse
;
; return    status enumeration. 0 = success
;
; notes     as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
	return DllCall("gdiplus\GdipDrawEllipse", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function    Gdip_DrawBezier
; Description   This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x1     x-coordinate of the start of the bezier
; y1     y-coordinate of the start of the bezier
; x2     x-coordinate of the first arc of the bezier
; y2     y-coordinate of the first arc of the bezier
; x3     x-coordinate of the second arc of the bezier
; y3     y-coordinate of the second arc of the bezier
; x4     x-coordinate of the end of the bezier
; y4     y-coordinate of the end of the bezier
;
; return    status enumeration. 0 = success
;
; notes     as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
{
	return DllCall("gdiplus\GdipDrawBezier", "uint", pgraphics, "uint", pPen
   , "float", x1, "float", y1, "float", x2, "float", y2
   , "float", x3, "float", y3, "float", x4, "float", y4)
}

;#####################################################################################

; Function    Gdip_DrawArc
; Description   This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x      x-coordinate of the start of the arc
; y      y-coordinate of the start of the arc
; w      width of the arc
; h      height of the arc
; StartAngle   specifies the angle between the x-axis and the starting point of the arc
; SweepAngle   specifies the angle between the starting and ending points of the arc
;
; return    status enumeration. 0 = success
;
; notes     as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	return DllCall("gdiplus\GdipDrawArc", "uint", pGraphics, "uint", pPen, "float", x
   , "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function    Gdip_DrawPie
; Description   This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x      x-coordinate of the start of the pie
; y      y-coordinate of the start of the pie
; w      width of the pie
; h      height of the pie
; StartAngle   specifies the angle between the x-axis and the starting point of the pie
; SweepAngle   specifies the angle between the starting and ending points of the pie
;
; return    status enumeration. 0 = success
;
; notes     as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	return DllCall("gdiplus\GdipDrawPie", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function    Gdip_DrawLine
; Description   This function uses a pen to draw a line into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; x1     x-coordinate of the start of the line
; y1     y-coordinate of the start of the line
; x2     x-coordinate of the end of the line
; y2     y-coordinate of the end of the line
;
; return    status enumeration. 0 = success  

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
	return DllCall("gdiplus\GdipDrawLine", "uint", pGraphics, "uint", pPen
   , "float", x1, "float", y1, "float", x2, "float", y2)
}

;#####################################################################################

; Function    Gdip_DrawLines
; Description   This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pPen     Pointer to a pen
; Points    the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return    status enumeration. 0 = success    

Gdip_DrawLines(pGraphics, pPen, Points)
{
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}
	return DllCall("gdiplus\GdipDrawLines", "uint", pGraphics, "uint", pPen, "uint", &PointF, "int", Points0)
}

;#####################################################################################

; Function    Gdip_FillRectangle
; Description   This function uses a brush to fill a rectangle in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; x      x-coordinate of the top left of the rectangle
; y      y-coordinate of the top left of the rectangle
; w      width of the rectanlge
; h      height of the rectangle
;
; return    status enumeration. 0 = success

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
	return DllCall("gdiplus\GdipFillRectangle", "uint", pGraphics, "int", pBrush
   , "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function    Gdip_FillRoundedRectangle
; Description   This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; x      x-coordinate of the top left of the rounded rectangle
; y      y-coordinate of the top left of the rounded rectangle
; w      width of the rectanlge
; h      height of the rectangle
; r      radius of the rounded corners
;
; return    status enumeration. 0 = success

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
	Region := Gdip_GetClipRegion(pGraphics)
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_DeleteRegion(Region)
	return E
}

;#####################################################################################

; Function    Gdip_FillPolygon
; Description   This function uses a brush to fill a polygon in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; Points    the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return    status enumeration. 0 = success
;
; notes     Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
; Alternate    = 0
; Winding     = 1

Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
{
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}   
	return DllCall("gdiplus\GdipFillPolygon", "uint", pGraphics, "uint", pBrush, "uint", &PointF, "int", Points0, "int", FillMode)
}

;#####################################################################################

; Function    Gdip_FillPie
; Description   This function uses a brush to fill a pie in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; x      x-coordinate of the top left of the pie
; y      y-coordinate of the top left of the pie
; w      width of the pie
; h      height of the pie
; StartAngle   specifies the angle between the x-axis and the starting point of the pie
; SweepAngle   specifies the angle between the starting and ending points of the pie
;
; return    status enumeration. 0 = success

Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
{
	return DllCall("gdiplus\GdipFillPie", "uint", pGraphics, "uint", pBrush
   , "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function    Gdip_FillEllipse
; Description   This function uses a brush to fill an ellipse in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; x      x-coordinate of the top left of the ellipse
; y      y-coordinate of the top left of the ellipse
; w      width of the ellipse
; h      height of the ellipse
;
; return    status enumeration. 0 = success

Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
	return DllCall("gdiplus\GdipFillEllipse", "uint", pGraphics, "uint", pBrush, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function    Gdip_FillRegion
; Description   This function uses a brush to fill a region in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; Region    Pointer to a Region
;
; return    status enumeration. 0 = success
;
; notes     You can create a region Gdip_CreateRegion() and then add to this

Gdip_FillRegion(pGraphics, pBrush, Region)
{
	return DllCall("gdiplus\GdipFillRegion", "uint", pGraphics, "uint", pBrush, "uint", Region)
}

;#####################################################################################

; Function    Gdip_FillPath
; Description   This function uses a brush to fill a path in the Graphics of a bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBrush    Pointer to a brush
; Region    Pointer to a Path
;
; return    status enumeration. 0 = success

Gdip_FillPath(pGraphics, pBrush, Path)
{
	return DllCall("gdiplus\GdipFillPath", "uint", pGraphics, "uint", pBrush, "uint", Path)
}

;#####################################################################################

; Function    Gdip_DrawImagePointsRect
; Description   This function draws a bitmap into the Graphics of another bitmap and skews it
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBitmap    Pointer to a bitmap to be drawn
; Points    Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
; sx     x-coordinate of source upper-left corner
; sy     y-coordinate of source upper-left corner
; sw     width of source rectangle
; sh     height of source rectangle
; Matrix    a matrix used to alter image attributes when drawing
;
; return    status enumeration. 0 = success
;
; notes     if sx,sy,sw,sh are missed then the entire source bitmap will be used
;      Matrix can be omitted to just draw with no alteration to ARGB
;      Matrix may be passed as a digit from 0 - 1 to change just transparency
;      Matrix can be passed as a matrix with any delimiter

Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
{
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}
	
	if (Matrix&1 = "")
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
	
	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		sx := 0, sy := 0
		sw := Gdip_GetImageWidth(pBitmap)
		sh := Gdip_GetImageHeight(pBitmap)
	}
	
	E := DllCall("gdiplus\GdipDrawImagePointsRect", "uint", pGraphics, "uint", pBitmap
 , "uint", &PointF, "int", Points0, "float", sx, "float", sy, "float", sw, "float", sh
 , "int", 2, "uint", ImageAttr, "uint", 0, "uint", 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return E
}

;#####################################################################################

; Function    Gdip_DrawImage
; Description   This function draws a bitmap into the Graphics of another bitmap
;
; pGraphics    Pointer to the Graphics of a bitmap
; pBitmap    Pointer to a bitmap to be drawn
; dx     x-coord of destination upper-left corner
; dy     y-coord of destination upper-left corner
; dw     width of destination image
; dh     height of destination image
; sx     x-coordinate of source upper-left corner
; sy     y-coordinate of source upper-left corner
; sw     width of source image
; sh     height of source image
; Matrix    a matrix used to alter image attributes when drawing
;
; return    status enumeration. 0 = success
;
; notes     if sx,sy,sw,sh are missed then the entire source bitmap will be used
;      Gdip_DrawImage performs faster
;      Matrix can be omitted to just draw with no alteration to ARGB
;      Matrix may be passed as a digit from 0 - 1 to change just transparency
;      Matrix can be passed as a matrix with any delimiter. For example:
;      MatrixBright=
;      (
;      1.5  |0  |0  |0  |0
;      0  |1.5 |0  |0  |0
;      0  |0  |1.5 |0  |0
;      0  |0  |0  |1  |0
;      0.05 |0.05 |0.05 |0  |1
;      )
;
; notes     MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;      MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;      MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
{
	if (Matrix&1 = "")
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
	
	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		if (dx = "" && dy = "" && dw = "" && dh = "")
		{
			sx := dx := 0, sy := dy := 0
			sw := dw := Gdip_GetImageWidth(pBitmap)
			sh := dh := Gdip_GetImageHeight(pBitmap)
		}
		else
		{
			sx := sy := 0
			sw := Gdip_GetImageWidth(pBitmap)
			sh := Gdip_GetImageHeight(pBitmap)
		}
	}
	
	E := DllCall("gdiplus\GdipDrawImageRectRect", "uint", pGraphics, "uint", pBitmap
 , "float", dx, "float", dy, "float", dw, "float", dh
 , "float", sx, "float", sy, "float", sw, "float", sh
 , "int", 2, "uint", ImageAttr, "uint", 0, "uint", 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return E
}

;#####################################################################################

; Function    Gdip_SetImageAttributesColorMatrix
; Description   This function creates an image matrix ready for drawing
;
; Matrix    a matrix used to alter image attributes when drawing
;      passed with any delimeter
;
; return    returns an image matrix on sucess or 0 if it fails
;
; notes     MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;      MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;      MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

Gdip_SetImageAttributesColorMatrix(Matrix)
{
	VarSetCapacity(ColourMatrix, 100, 0)
	Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", "", 1), "[^\d-\.]+", "|")
	StringSplit, Matrix, Matrix, |
	Loop, 25
	{
		Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
		NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
	}
	DllCall("gdiplus\GdipCreateImageAttributes", "uint*", ImageAttr)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "uint", ImageAttr, "int", 1, "int", 1, "uint", &ColourMatrix, "int", 0, "int", 0)
	return ImageAttr
}

;#####################################################################################

; Function    Gdip_GraphicsFromImage
; Description   This function gets the graphics for a bitmap used for drawing functions
;
; pBitmap    Pointer to a bitmap to get the pointer to its graphics
;
; return    returns a pointer to the graphics of a bitmap
;
; notes     a bitmap can be drawn into the graphics of another bitmap

Gdip_GraphicsFromImage(pBitmap)
{
	DllCall("gdiplus\GdipGetImageGraphicsContext", "uint", pBitmap, "uint*", pGraphics)
	return pGraphics
}

;#####################################################################################

; Function    Gdip_GraphicsFromHDC
; Description   This function gets the graphics from the handle to a device context
;
; hdc     This is the handle to the device context
;
; return    returns a pointer to the graphics of a bitmap
;
; notes     You can draw a bitmap into the graphics of another bitmap

Gdip_GraphicsFromHDC(hdc)
{
	DllCall("gdiplus\GdipCreateFromHDC", "uint", hdc, "uint*", pGraphics)
	return pGraphics
}

;#####################################################################################

; Function    Gdip_GetDC
; Description   This function gets the device context of the passed Graphics
;
; hdc     This is the handle to the device context
;
; return    returns the device context for the graphics of a bitmap

Gdip_GetDC(pGraphics)
{
	DllCall("gdiplus\GdipGetDC", "uint", pGraphics, "uint*", hdc)
	return hdc
}

;#####################################################################################

; Function    Gdip_ReleaseDC
; Description   This function releases a device context from use for further use
;
; pGraphics    Pointer to the graphics of a bitmap
; hdc     This is the handle to the device context
;
; return    status enumeration. 0 = success

Gdip_ReleaseDC(pGraphics, hdc)
{
	return DllCall("gdiplus\GdipReleaseDC", "uint", pGraphics, "uint", hdc)
}

;#####################################################################################

; Function    Gdip_GraphicsClear
; Description   Clears the graphics of a bitmap ready for further drawing
;
; pGraphics    Pointer to the graphics of a bitmap
; ARGB     The colour to clear the graphics to
;
; return    status enumeration. 0 = success
;
; notes     By default this will make the background invisible
;      Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
{
	return DllCall("gdiplus\GdipGraphicsClear", "uint", pGraphics, "int", ARGB)
}

;#####################################################################################

; Function    Gdip_BlurBitmap
; Description   Gives a pointer to a blurred bitmap from a pointer to a bitmap
;
; pBitmap    Pointer to a bitmap to be blurred
; Blur     The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
;
; return    If the function succeeds, the return value is a pointer to the new blurred bitmap
;      -1 = The blur parameter is outside the range 1-100
;
; notes     This function will not dispose of the original bitmap

Gdip_BlurBitmap(pBitmap, Blur)
{
	if (Blur > 100) || (Blur < 1)
		return -1 
	
	sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
	dWidth := sWidth//Blur, dHeight := sHeight//Blur
	
	pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
	G1 := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_SetInterpolationMode(G1, 7)
	Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)
	
	Gdip_DeleteGraphics(G1)
	
	pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
	G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_SetInterpolationMode(G2, 7)
	Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)
	
	Gdip_DeleteGraphics(G2)
	Gdip_DisposeImage(pBitmap1)
	return pBitmap2
}

;#####################################################################################

; Function:       Gdip_SaveBitmapToFile
; Description:    Saves a bitmap to a file in any supported format onto disk
;   
; pBitmap    Pointer to a bitmap
; sOutput         The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality         If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return         If the function succeeds, the return value is zero, otherwise:
;      -1 = Extension supplied is not a supported file format
;      -2 = Could not get a list of encoders on system
;      -3 = Could not find matching encoder for specified file format
;      -4 = Could not get WideChar name of output file
;      -5 = Could not save file to disk
;
; notes     This function will use the extension supplied from the sOutput parameter to determine the output format

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=100)
{
	SplitPath, sOutput,,, Extension
	if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
		return -1
	Extension := "." Extension
	
	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "uint", &ci)
	if !(nCount && nSize)
		return -2
	
	Loop, %nCount%
	{
		Location := NumGet(ci, 76*(A_Index-1)+44)
		if !A_IsUnicode
		{
			nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
			VarSetCapacity(sString, nSize)
			DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
			if !InStr(sString, "*" Extension)
				continue
		}
		else
		{
			nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
			sString := ""
			Loop, %nSize%
				sString .= Chr(NumGet(Location+0, 2*(A_Index-1), "char"))
			if !InStr(sString, "*" Extension)
				continue
		}
		pCodec := &ci+76*(A_Index-1)
		break
	}
	if !pCodec
		return -3
	
	if (Quality != 75)
	{
		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
		if Extension in .JPG,.JPEG,.JPE,.JFIF
		{
			DllCall("gdiplus\GdipGetEncoderParameterListSize", "uint", pBitmap, "uint", pCodec, "uint*", nSize)
			VarSetCapacity(EncoderParameters, nSize, 0)
			DllCall("gdiplus\GdipGetEncoderParameterList", "uint", pBitmap, "uint", pCodec, "uint", nSize, "uint", &EncoderParameters)
			Loop, % NumGet(EncoderParameters)      ;%
			{
				if (NumGet(EncoderParameters, (28*(A_Index-1))+20) = 1) && (NumGet(EncoderParameters, (28*(A_Index-1))+24) = 6)
				{
					p := (28*(A_Index-1))+&EncoderParameters
					NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20)))
					break
				}
			}      
		}
	}
	
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sOutput, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wOutput, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sOutput, "int", -1, "uint", &wOutput, "int", nSize)
		VarSetCapacity(wOutput, -1)
		if !VarSetCapacity(wOutput)
			return -4
		E := DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &wOutput, "uint", pCodec, "uint", p ? p : 0)
	}
	else
		E := DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &sOutput, "uint", pCodec, "uint", p ? p : 0)
	return E ? -5 : 0
}

;#####################################################################################

; Function    Gdip_GetPixel
; Description   Gets the ARGB of a pixel in a bitmap
;
; pBitmap    Pointer to a bitmap
; x      x-coordinate of the pixel
; y      y-coordinate of the pixel
;
; return    Returns the ARGB value of the pixel

Gdip_GetPixel(pBitmap, x, y)
{
	DllCall("gdiplus\GdipBitmapGetPixel", "uint", pBitmap, "int", x, "int", y, "uint*", ARGB)
	return ARGB
}

;#####################################################################################

; Function    Gdip_SetPixel
; Description   Sets the ARGB of a pixel in a bitmap
;
; pBitmap    Pointer to a bitmap
; x      x-coordinate of the pixel
; y      y-coordinate of the pixel
;
; return    status enumeration. 0 = success

Gdip_SetPixel(pBitmap, x, y, ARGB)
{
	return DllCall("gdiplus\GdipBitmapSetPixel", "uint", pBitmap, "int", x, "int", y, "int", ARGB)
}

;#####################################################################################

; Function    Gdip_GetImageWidth
; Description   Gives the width of a bitmap
;
; pBitmap    Pointer to a bitmap
;
; return    Returns the width in pixels of the supplied bitmap

Gdip_GetImageWidth(pBitmap)
{
	DllCall("gdiplus\GdipGetImageWidth", "uint", pBitmap, "uint*", Width)
	return Width
}

;#####################################################################################

; Function    Gdip_GetImageHeight
; Description   Gives the height of a bitmap
;
; pBitmap    Pointer to a bitmap
;
; return    Returns the height in pixels of the supplied bitmap

Gdip_GetImageHeight(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHeight", "uint", pBitmap, "uint*", Height)
	return Height
}

;#####################################################################################

; Function    Gdip_GetDimensions
; Description   Gives the width and height of a bitmap
;
; pBitmap    Pointer to a bitmap
; Width     ByRef variable. This variable will be set to the width of the bitmap
; Height    ByRef variable. This variable will be set to the height of the bitmap
;
; return    No return value
;      Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Width := Gdip_GetImageWidth(pBitmap) ;*[Screenclip]
	Height := Gdip_GetImageHeight(pBitmap)
}

;#####################################################################################

Gdip_GetImagePixelFormat(pBitmap)
{
	DllCall("gdiplus\GdipGetImagePixelFormat", "uint", pBitmap, "uint*", Format)
	return Format
}

;#####################################################################################

; Function    Gdip_GetDpiX
; Description   Gives the horizontal dots per inch of the graphics of a bitmap
;
; pBitmap    Pointer to a bitmap
; Width     ByRef variable. This variable will be set to the width of the bitmap
; Height    ByRef variable. This variable will be set to the height of the bitmap
;
; return    No return value
;      Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetDpiX(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiX", "uint", pGraphics, "float*", dpix)
	return Round(dpix)
}

Gdip_GetDpiY(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiY", "uint", pGraphics, "float*", dpiy)
	return Round(dpiy)
}

Gdip_GetImageHorizontalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHorizontalResolution", "uint", pBitmap, "float*", dpix)
	return Round(dpix)
}

Gdip_GetImageVerticalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageVerticalResolution", "uint", pBitmap, "float*", dpiy)
	return Round(dpiy)
}

Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
{
	SplitPath, sFile,,, ext
	if ext in exe,dll
	{
		Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
		VarSetCapacity(buf, 40)
		Loop, Parse, Sizes, |
		{
			DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", A_LoopField, "int", A_LoopField, "uint*", hIcon, "uint*", 0, "uint", 1, "uint", 0)
			if !hIcon
				continue
			
			if !DllCall("GetIconInfo", "uint", hIcon, "uint", &buf)
			{
				DestroyIcon(hIcon)
				continue
			}
			hbmColor := NumGet(buf, 16)
			hbmMask  := NumGet(buf, 12)
			
			if !(hbmColor && DllCall("GetObject", "uint", hbmColor, "int", 24, "uint", &buf))
			{
				DestroyIcon(hIcon)
				continue
			}
			break
		}
		if !hIcon
			return -1
		
		Width := NumGet(buf, 4, "int"),  Height := NumGet(buf, 8, "int")
		hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
		
		if !DllCall("DrawIconEx", "uint", hdc, "int", 0, "int", 0, "uint", hIcon, "uint", Width, "uint", Height, "uint", 0, "uint", 0, "uint", 3)
		{
			DestroyIcon(hIcon)
			return -2
		}
		
		VarSetCapacity(dib, 84)
		DllCall("GetObject", "uint", hbm, "int", 84, "uint", &dib)
		Stride := NumGet(dib, 12), Bits := NumGet(dib, 20)
		
		DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, "uint", Bits, "uint*", pBitmapOld)
		pBitmap := Gdip_CreateBitmap(Width, Height), G := Gdip_GraphicsFromImage(pBitmap)
		Gdip_DrawImage(G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
		SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
		Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapOld)
		DestroyIcon(hIcon)
	}
	else
	{
		if !A_IsUnicode
		{
			VarSetCapacity(wFile, 1023)
			DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sFile, "int", -1, "uint", &wFile, "int", 512)
			DllCall("gdiplus\GdipCreateBitmapFromFile", "uint", &wFile, "uint*", pBitmap)
		}
		else
			DllCall("gdiplus\GdipCreateBitmapFromFile", "uint", &sFile, "uint*", pBitmap)
	}
	return pBitmap
}

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
{
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "uint", hBitmap, "uint", Palette, "uint*", pBitmap)
	return pBitmap
}

Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
{
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "uint", pBitmap, "uint*", hbm, "int", Background)
	return hbm
}

Gdip_CreateBitmapFromHICON(hIcon)
{
	DllCall("gdiplus\GdipCreateBitmapFromHICON", "uint", hIcon, "uint*", pBitmap)
	return pBitmap
}

Gdip_CreateHICONFromBitmap(pBitmap)
{
	DllCall("gdiplus\GdipCreateHICONFromBitmap", "uint", pBitmap, "uint*", hIcon)
	return hIcon
}

Gdip_CreateBitmap(Width, Height, Format=0x26200A)
{
	DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, "uint", 0, "uint*", pBitmap)
	Return pBitmap
}

Gdip_CreateBitmapFromClipboard()
{
	if !DllCall("OpenClipboard", "uint", 0)
		return -1
	if !DllCall("IsClipboardFormatAvailable", "uint", 8)
		return -2
	if !hBitmap := DllCall("GetClipboardData", "uint", 2)
		return -3
	if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
		return -4
	if !DllCall("CloseClipboard")
		return -5
	DeleteObject(hBitmap)
	return pBitmap
}

Gdip_SetBitmapToClipboard(pBitmap)
{
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	DllCall("GetObject", "uint", hBitmap, "int", VarSetCapacity(oi, 84, 0), "uint", &oi)
	hdib := DllCall("GlobalAlloc", "uint", 2, "uint", 40+NumGet(oi, 44))
	pdib := DllCall("GlobalLock", "uint", hdib)
	DllCall("RtlMoveMemory", "uint", pdib, "uint", &oi+24, "uint", 40)
	DllCall("RtlMoveMemory", "Uint", pdib+40, "Uint", NumGet(oi, 20), "uint", NumGet(oi, 44))
	DllCall("GlobalUnlock", "uint", hdib)
	DllCall("DeleteObject", "uint", hBitmap)
	DllCall("OpenClipboard", "uint", 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "uint", 8, "uint", hdib)
	DllCall("CloseClipboard")
}

Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
{
	DllCall("gdiplus\GdipCloneBitmapArea", "float", x, "float", y, "float", w, "float", h
 , "int", Format, "uint", pBitmap, "uint*", pBitmapDest)
	return pBitmapDest
}

;#####################################################################################
; Create resources
;#####################################################################################

Gdip_CreatePen(ARGB, w)
{
	DllCall("gdiplus\GdipCreatePen1", "int", ARGB, "float", w, "int", 2, "uint*", pPen)
	return pPen
}

Gdip_CreatePenFromBrush(pBrush, w)
{
	DllCall("gdiplus\GdipCreatePen2", "uint", pBrush, "float", w, "int", 2, "uint*", pPen)
	return pPen
}

Gdip_BrushCreateSolid(ARGB=0xff000000)
{
	DllCall("gdiplus\GdipCreateSolidFill", "int", ARGB, "uint*", pBrush)
	return pBrush
}

; HatchStyleHorizontal = 0
; HatchStyleVertical = 1
; HatchStyleForwardDiagonal = 2
; HatchStyleBackwardDiagonal = 3
; HatchStyleCross = 4
; HatchStyleDiagonalCross = 5
; HatchStyle05Percent = 6
; HatchStyle10Percent = 7
; HatchStyle20Percent = 8
; HatchStyle25Percent = 9
; HatchStyle30Percent = 10
; HatchStyle40Percent = 11
; HatchStyle50Percent = 12
; HatchStyle60Percent = 13
; HatchStyle70Percent = 14
; HatchStyle75Percent = 15
; HatchStyle80Percent = 16
; HatchStyle90Percent = 17
; HatchStyleLightDownwardDiagonal = 18
; HatchStyleLightUpwardDiagonal = 19
; HatchStyleDarkDownwardDiagonal = 20
; HatchStyleDarkUpwardDiagonal = 21
; HatchStyleWideDownwardDiagonal = 22
; HatchStyleWideUpwardDiagonal = 23
; HatchStyleLightVertical = 24
; HatchStyleLightHorizontal = 25
; HatchStyleNarrowVertical = 26
; HatchStyleNarrowHorizontal = 27
; HatchStyleDarkVertical = 28
; HatchStyleDarkHorizontal = 29
; HatchStyleDashedDownwardDiagonal = 30
; HatchStyleDashedUpwardDiagonal = 31
; HatchStyleDashedHorizontal = 32
; HatchStyleDashedVertical = 33
; HatchStyleSmallConfetti = 34
; HatchStyleLargeConfetti = 35
; HatchStyleZigZag = 36
; HatchStyleWave = 37
; HatchStyleDiagonalBrick = 38
; HatchStyleHorizontalBrick = 39
; HatchStyleWeave = 40
; HatchStylePlaid = 41
; HatchStyleDivot = 42
; HatchStyleDottedGrid = 43
; HatchStyleDottedDiamond = 44
; HatchStyleShingle = 45
; HatchStyleTrellis = 46
; HatchStyleSphere = 47
; HatchStyleSmallGrid = 48
; HatchStyleSmallCheckerBoard = 49
; HatchStyleLargeCheckerBoard = 50
; HatchStyleOutlinedDiamond = 51
; HatchStyleSolidDiamond = 52
; HatchStyleTotal = 53
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
{
	DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "int", ARGBfront, "int", ARGBback, "uint*", pBrush)
	return pBrush
}

;GpStatus WINGDIPAPI GdipCreateTexture2I(GpImage *image, GpWrapMode wrapmode, INT x, INT y, INT width, INT height, GpTexture **texture)
;GpStatus WINGDIPAPI GdipCreateTexture2(GpImage *image, GpWrapMode wrapmode, REAL x, REAL y, REAL width, REAL height, GpTexture **texture)
;GpStatus WINGDIPAPI GdipCreateTexture(GpImage *image, GpWrapMode wrapmode, GpTexture **texture)

Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
{
	if !(w && h)
		DllCall("gdiplus\GdipCreateTexture", "uint", pBitmap, "int", WrapMode, "uint*", pBrush)
	else
		DllCall("gdiplus\GdipCreateTexture2", "uint", pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, "uint*", pBrush)
	return pBrush
}

; WrapModeTile = 0
; WrapModeTileFlipX = 1
; WrapModeTileFlipY = 2
; WrapModeTileFlipXY = 3
; WrapModeClamp = 4
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
{
	CreatePointF(PointF1, x1, y1), CreatePointF(PointF2, x2, y2)
	DllCall("gdiplus\GdipCreateLineBrush", "uint", &PointF1, "uint", &PointF2, "int", ARGB1, "int", ARGB2, "int", WrapMode, "uint*", LGpBrush)
	return LGpBrush
}

; LinearGradientModeHorizontal = 0
; LinearGradientModeVertical = 1
; LinearGradientModeForwardDiagonal = 2
; LinearGradientModeBackwardDiagonal = 3
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
{
	CreateRectF(RectF, x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", "uint", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "uint*", LGpBrush)
	return LGpBrush
}

Gdip_CloneBrush(pBrush)
{
	static pNewBrush
	VarSetCapacity(pNewBrush, 288, 0)
	DllCall("RtlMoveMemory", "uint", &pNewBrush, "uint", pBrush, "uint", 288)
	VarSetCapacity(pNewBrush, -1)
	return &pNewBrush
}

;#####################################################################################
; Delete resources
;#####################################################################################

Gdip_DeletePen(pPen)
{
	return DllCall("gdiplus\GdipDeletePen", "uint", pPen)
}

Gdip_DeleteBrush(pBrush)
{
	return DllCall("gdiplus\GdipDeleteBrush", "uint", pBrush)
}

Gdip_DisposeImage(pBitmap)
{
	return DllCall("gdiplus\GdipDisposeImage", "uint", pBitmap)
}

Gdip_DeleteGraphics(pGraphics)
{
	return DllCall("gdiplus\GdipDeleteGraphics", "uint", pGraphics)
}

Gdip_DisposeImageAttributes(ImageAttr)
{
	return DllCall("gdiplus\GdipDisposeImageAttributes", "uint", ImageAttr)
}

Gdip_DeleteFont(hFont)
{
	return DllCall("gdiplus\GdipDeleteFont", "uint", hFont)
}

Gdip_DeleteStringFormat(hFormat)
{
	return DllCall("gdiplus\GdipDeleteStringFormat", "uint", hFormat)
}

Gdip_DeleteFontFamily(hFamily)
{
	return DllCall("gdiplus\GdipDeleteFontFamily", "uint", hFamily)
}

Gdip_DeleteMatrix(Matrix)
{
	return DllCall("gdiplus\GdipDeleteMatrix", "uint", Matrix)
}

;#####################################################################################
; Text functions
;#####################################################################################

Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
{
	IWidth := Width, IHeight:= Height
	
	RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
	RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
	RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
	RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
	RegExMatch(Options, "i)R(\d)", Rendering)
	RegExMatch(Options, "i)S(\d+)(p*)", Size)
	
	if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
		PassBrush := 1, pBrush := Colour2
	
	if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
		return -1
	
	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	Loop, Parse, Styles, |
	{
		if RegExMatch(Options, "\b" A_loopField)
			Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
	}
	
	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	Loop, Parse, Alignments, |
	{
		if RegExMatch(Options, "\b" A_loopField)
			Align |= A_Index//2.1      ; 0|0|1|1|2|2
	}
	
	xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
	ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
	Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
	Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
	if !PassBrush
		Colour := "0x" (Colour2 ? Colour2 : "ff000000")
	Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
	Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12
	
	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	hFormat := Gdip_StringFormatCreate(0x4000)
	pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
	if !(hFamily && hFont && hFormat && pBrush && pGraphics)
		return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
	
	CreateRectF(RC, xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
	
	if vPos
	{
		StringSplit, ReturnRC, ReturnRC, |
		
		if (vPos = "vCentre") || (vPos = "vCenter")
			ypos += (Height-ReturnRC4)//2
		else if (vPos = "Top") || (vPos = "Up")
			ypos := 0
		else if (vPos = "Bottom") || (vPos = "Down")
			ypos := Height-ReturnRC4
		
		CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
		ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
	}
	
	if !Measure
		E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)
	
	if !PassBrush
		Gdip_DeleteBrush(pBrush)
	Gdip_DeleteStringFormat(hFormat)   
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)
	return E ? E : ReturnRC
}

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize)
		return DllCall("gdiplus\GdipDrawString", "uint", pGraphics
  , "uint", &wString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", pBrush)
	}
	else
	{
		return DllCall("gdiplus\GdipDrawString", "uint", pGraphics
  , "uint", &sString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", pBrush)
	} 
}

Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
	VarSetCapacity(RC, 16)
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)   
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize)
		DllCall("gdiplus\GdipMeasureString", "uint", pGraphics
  , "uint", &wString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", &RC, "uint*", Chars, "uint*", Lines)
	}
	else
	{
		DllCall("gdiplus\GdipMeasureString", "uint", pGraphics
  , "uint", &sString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", &RC, "uint*", Chars, "uint*", Lines)
	}
	return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}

; Near = 0
; Center = 1
; Far = 2
Gdip_SetStringFormatAlign(hFormat, Align)
{
	return DllCall("gdiplus\GdipSetStringFormatAlign", "uint", hFormat, "int", Align)
}

Gdip_StringFormatCreate(Format=0, Lang=0)
{
	DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, "uint*", hFormat)
	return hFormat
}

; Regular = 0
; Bold = 1
; Italic = 2
; BoldItalic = 3
; Underline = 4
; Strikeout = 8
Gdip_FontCreate(hFamily, Size, Style=0)
{
	DllCall("gdiplus\GdipCreateFont", "uint", hFamily, "float", Size, "int", Style, "int", 0, "uint*", hFont)
	return hFont
}

Gdip_FontFamilyCreate(Font)
{
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Font, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wFont, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Font, "int", -1, "uint", &wFont, "int", nSize)
		DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &wFont, "uint", 0, "uint*", hFamily)
	}
	else
		DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &Font, "uint", 0, "uint*", hFamily)
	return hFamily
}

;#####################################################################################
; Matrix functions
;#####################################################################################

Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
{
	DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, "uint*", Matrix)
	return Matrix
}

Gdip_CreateMatrix()
{
	DllCall("gdiplus\GdipCreateMatrix", "uint*", Matrix)
	return Matrix
}

;#####################################################################################
; GraphicsPath functions
;#####################################################################################

; Alternate = 0
; Winding = 1
Gdip_CreatePath(BrushMode=0)
{
	DllCall("gdiplus\GdipCreatePath", "int", BrushMode, "uint*", Path)
	return Path
}

Gdip_AddPathEllipse(Path, x, y, w, h)
{
	return DllCall("gdiplus\GdipAddPathEllipse", "uint", Path, "float", x, "float", y, "float", w, "float", h)
}

Gdip_AddPathPolygon(Path, Points)
{
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}  
	
	return DllCall("gdiplus\GdipAddPathPolygon", "uint", Path, "uint", &PointF, "int", Points0)
}

Gdip_DeletePath(Path)
{
	return DllCall("gdiplus\GdipDeletePath", "uint", Path)
}

;#####################################################################################
; Quality functions
;#####################################################################################

; SystemDefault = 0
; SingleBitPerPixelGridFit = 1
; SingleBitPerPixel = 2
; AntiAliasGridFit = 3
; AntiAlias = 4
Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
	return DllCall("gdiplus\GdipSetTextRenderingHint", "uint", pGraphics, "int", RenderingHint)
}

; Default = 0
; LowQuality = 1
; HighQuality = 2
; Bilinear = 3
; Bicubic = 4
; NearestNeighbor = 5
; HighQualityBilinear = 6
; HighQualityBicubic = 7
Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
{
	return DllCall("gdiplus\GdipSetInterpolationMode", "uint", pGraphics, "int", InterpolationMode)
}

; Default = 0
; HighSpeed = 1
; HighQuality = 2
; None = 3
; AntiAlias = 4
Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
	return DllCall("gdiplus\GdipSetSmoothingMode", "uint", pGraphics, "int", SmoothingMode)
}

; CompositingModeSourceOver = 0 (blended)
; CompositingModeSourceCopy = 1 (overwrite)
Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
{
	return DllCall("gdiplus\GdipSetCompositingMode", "uint", pGraphics, "int", CompositingMode)
}

;#####################################################################################
; Extra functions
;#####################################################################################

Gdip_Startup()
{
	if !DllCall("GetModuleHandle", "str", "gdiplus")
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "uint*", pToken, "uint", &si, "uint", 0)
	return pToken
}

Gdip_Shutdown(pToken)
{
	DllCall("gdiplus\GdiplusShutdown", "uint", pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus")
		DllCall("FreeLibrary", "uint", hModule)
	return 0
}

; Prepend = 0; The new operation is applied before the old operation.
; Append = 1; The new operation is applied after the old operation.
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
{
	return DllCall("gdiplus\GdipRotateWorldTransform", "uint", pGraphics, "float", Angle, "int", MatrixOrder)
}

Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
	return DllCall("gdiplus\GdipScaleWorldTransform", "uint", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
	return DllCall("gdiplus\GdipTranslateWorldTransform", "uint", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_ResetWorldTransform(pGraphics)
{
	return DllCall("gdiplus\GdipResetWorldTransform", "uint", pGraphics)
}

Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
{
	pi := 3.14159, TAngle := Angle*(pi/180) 
	
	Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
	if ((Bound >= 0) && (Bound <= 90))
		xTranslation := Height*Sin(TAngle), yTranslation := 0
	else if ((Bound > 90) && (Bound <= 180))
		xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
	else if ((Bound > 180) && (Bound <= 270))
		xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
	else if ((Bound > 270) && (Bound <= 360))
		xTranslation := 0, yTranslation := -Width*Sin(TAngle)
}

Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
	pi := 3.14159, TAngle := Angle*(pi/180)
	if !(Width && Height)
		return -1
	RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
	RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

; Replace = 0
; Intersect = 1
; Union = 2
; Xor = 3
; Exclude = 4
; Complement = 5
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
{
	return DllCall("gdiplus\GdipSetClipRect", "uint", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}

Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
{
	return DllCall("gdiplus\GdipSetClipPath", "uint", pGraphics, "uint", Path, "int", CombineMode)
}

Gdip_ResetClip(pGraphics)
{
	return DllCall("gdiplus\GdipResetClip", "uint", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
	Region := Gdip_CreateRegion()
	DllCall("gdiplus\GdipGetClip", "uint" pGraphics, "uint*", Region)
	return Region
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
{
	return DllCall("gdiplus\GdipSetClipRegion", "uint", pGraphics, "uint", Region, "int", CombineMode)
}

Gdip_CreateRegion()
{
	DllCall("gdiplus\GdipCreateRegion", "uint*", Region)
	return Region
}

Gdip_DeleteRegion(Region)
{
	return DllCall("gdiplus\GdipDeleteRegion", "uint", Region)
}

;***********Function by Tervon******************* 
SCW_Win2File(KeepBorders=0)
{
	global lOpenFolder
	Send, !{PrintScreen} ; Active Win's client area to Clipboard
	sleep 50
	if !KeepBorders
	{
		pToken := Gdip_Startup()
		pBitmap := Gdip_CreateBitmapFromClipboard()
		Gdip_GetDimensions(pBitmap, w, h)
		pBitmap2 := SCW_CropImage(pBitmap, 3, 3, w-6, h-6)
      ;~ File2:=A_Desktop . "\" . A_Now . ".PNG" ; tervon  time /path to file to save
		FormatTime, TodayDate , YYYYMMDDHH24MISS, MM_dd_yy @h_mm_ss ;This is Joe's time format
		if !FileExist(sPathToScreenClipFolder)
			FileCreateDir, %sPathToScreenClipFolder%
	 ;m(A_Desktop "\ScreenClip\")
		File2:= sPathToScreenClipFolder . TodayDate . ".PNG" ;path to file to save
		Gdip_SaveBitmapToFile(pBitmap2, File2) ;Exports automatcially to file
		ntfy:=Notify()
		ntfy.AddWindow("Image saved. Press CapsLock+E in the next 10 seconds to open location folder. ",{Title:"Screenclip.ahk",TitleColor:"0xFFFFFF",Time:10000,Color:"0xFFFFFF",Background:"0x000000",TitleSize:10,Size:10,ShowDelay:0,Radius:15, Flash:1000,FlashColor:0x5555,Buttons:"Open"})
		lOpenFolder:=true
		Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2)
		Gdip_Shutdown("pToken")
		sleep, 10000
		lOpenFolder:=false
	}
	RETURN
	Open:
	Click(Obj)
	return
	
}

Click(Obj) 
{	; ; addition to the notify-function, slightly adapted to run the folder path
	global sPathToScreenClipFolder
	for a,b in Obj
		msg.=a " = " b "`n"
	if (msg!="")
		run, % sPathToScreenClipFolder
}
;______________________________________________________________________________________
;#[Hotkeys Section]
#if (lOpenFolder)
CapsLock & E::run, %sPathToScreenClipFolder% ; Open ScreenClipFolder



;______________________________________________________________________________________
;#[Label Section]
WCL:
return
;______________________________________________________________________________________
;#[Functions Section
f_RestartScreenclip()
{
	reload
}
f_TrayIconSingleClickCallBack(wParam, lParam)
{ ; taken from https://autohotkey.com/board/topic/26639-tray-menu-show-gui/
	VNI:=1.0.3.12
	; 0x201 WM_LBUTTONDOWN
	; 0x202 WM_LBUTTONUP
	if (lParam = 0x202)
	{
		reload
	}
}



#SingleInstance,Force
Count:=0
Notify:=Notify(20)
/*
	Usage:
	Notify:=Notify()
	Window:=Notify.AddWindow("Your Text Here",{Icon:4,Background:"0xAA00AA"})
	|---Window ID                                          |--------Options
	Options:
	
	Window ID will be used when making calls to Notify.SetProgress(Window,ProgressValue)
	
	Animate: Ways that the window will animate in eg. {Animate:""} Can be Bottom, Top, Left, Right, Slide, Center, or Blend (Some work together, and some override others)
	Background: Color value in quotes eg. {Background:"0xAA00AA"}
	Buttons: Comma Delimited list of names for buttons eg. {Buttons:"One,Two,Three"}
	Color: Font color eg.{Color:"0xAAAAAA"}
	Destroy: Comma Delimited list of Bottom, Top, Left, Right, Slide, Center, or Blend
	Flash: Flashes the background of the notification every X ms eg. {Flash:1000}
	FlashColor: Sets the second color that your notification will change to when flashing eg. {FlashColor:"0xFF00FF"}
	Font: Face of the message font eg. {Font:"Consolas"}
	Icon: Can be either an Integer to pull an icon from Shell32.dll or a full path to an EXE or full path to a dll.  You can add a comma and an integer to select an icon from within that file eg. {Icon:"C:\Windows\HelpPane.exe,2"}
	IconSize: Width and Height of the Icon eg. {IconSize:20}
	Hide: Comma Separated List of Directions to Hide the Notification eg. {Hide:"Left,Top"}
	Progress: Adds a progress bar eg. {Progress:10} ;Starts with the progress set to 10%
	Radius: Size of the border radius eg. {Radius:10}
	Size: Size of the message text eg {Size:20}
	ShowDelay: Time in MS of how long it takes to show the notification
	Sound: Plays either a beep if the item is an integer or the sound file if it exists eg. {Sound:500}
	Time: Sets the amount of time that the notification will be visible eg. {Time:2000}
	Title: Sets the title of the notification eg. {Title:"This is my title"}
	TitleColor: Title font color eg. {TitleColor:"0xAAAAAA"}
	TitleFont: Face of the title font eg. {TitleFont:"Consolas"}
	TitleSize: Size of the title text eg. {TitleSize:12}
*/
if(1){
	Notify.AddWindow("Testing",{Background:"0xFF00FF",Color:"0xFF0000",ShowDelay:1000,Hide:"Top,Left",Buttons:"This,One,Here",Radius:40})
	return
}
Text:=["Longer text for a longer thing","Taller Text`nfor`na`ntaller`nthing"]
SetTimer,RandomProgress,500
Loop,2
{
	Random,Time,3000,8000
	/*
		Time:=A_Index=40?1000:Time
		Random,Sound,500,800
	*/
	Random,TT,1,2
	Random,Background,0x0,0xFFFFFF
	Random,Color,0x0,0xFFFFFF
	Random,Icon,20,200
	Notify.AddWindow(Text[TT],{Icon:300,Title:"This is my title",TitleFont:"Tahoma",TitleSize:10,Time:Time,Background:Background,Flash:1000,Color:Color})
	Notify.AddWindow(Text[TT],{Icon:"D:\AHK\AHK-Studio\AHK-Studio.exe",IconSize:20,Title:"This is my title",TitleFont:"Tahoma",TitleSize:10,Time:Time,Background:Background,Flash:1000,FlashColor:"0xAA00AA",Color:Color,Time:Time,Sound:Sound})
	Notify.AddWindow(Text[TT],{Icon:Icon,IconSize:80,Title:"This is my title",TitleFont:"Tahoma",TitleSize:10,Time:Time,Background:Background,Flash:1000,FlashColor:"0xAA00AA",Color:Color,Time:Time,Sound:Sound})
	ID:=Notify.AddWindow(Text[TT],{Progress:0,Icon:Icon,IconSize:80,Title:"This is my title",TitleFont:"Tahoma",TitleSize:10,Time:Time,Background:Background,Flash:1000,FlashColor:"0xAA00AA",Color:Color,Time:Time,Sound:Sound})
	Notify.AddWindow("This is my text",{Title:"My Title"})
	Random,Ico,1,5
	Notify.AddWindow("Odd icon",{Icon:A_AhkPath "," Ico,IconSize:20,Title:"This is my title",TitleFont:"Tahoma",TitleSize:10,Time:Time,Background:Background,Flash:1000,Color:Color,Time:Time})
	Random,Delay,100,400
	Delay:=1000
	Notify.AddWindow(Text[TT],{Radius:20,Hide:"Left,Bottom",Animate:"Right,Slide",ShowDelay:Delay,Icon:Icon,IconSize:20,Title:"This is my title",TitleFont:"Tahoma",TitleSize:10,Background:Background,Color:Color,Time:Time,Progress:0})
	}
return
RandomProgress:
for a,b in NotifyClass.Windows{
	Random,Pro,10,100
	Notify.SetProgress(a,Pro)
}
return
;Click(Obj){
	;for a,b in Obj
		;Msg.=a " = " b "`n"
    	;MsgBox,%Msg% ;; this msg-box is activated whenever any editfield of any gui within a script containing notify is clicked.
;}
;Actual code starts here
Notify(Margin:=5){
	static Notify:=New NotifyClass()
	Notify.Margin:=Margin
	return Notify
}
Class NotifyClass{
	__New(Margin:=10){
		this.ShowDelay:=40,this.ID:=0,this.Margin:=Margin,this.Animation:={Bottom:0x00000008,Top:0x00000004,Left:0x00000001,Right:0x00000002,Slide:0x00040000,Center:0x00000010,Blend:0x00080000}
		if(!this.Init)
			OnMessage(0x201,NotifyClass.Click.Bind(this)),this.Init:=1
	}AddWindow(Text,Info:=""){
		(Info?Info:Info:=[])
		for a,b in {Background:0,Color:"0xAAAAAA",TitleColor:"0xAAAAAA",Font:"Consolas",TitleSize:12,TitleFont:"Consolas",Size:20,Font:"Consolas",IconSize:20}
			if(Info[a]="")
				Info[a]:=b
		if(!IsObject(Win:=NotifyClass.Windows))
			Win:=NotifyClass.Windows:=[]
		Hide:=0
		for a,b in StrSplit(Info.Hide,",")
			if(Val:=this.Animation[b])
				Hide|=Val
		Info.Hide:=Hide
		DetectHiddenWindows,On
		this.Hidden:=Hidden:=A_DetectHiddenWindows,this.Current:=ID:=++this.ID,Owner:=WinActive("A")
 		Gui,Win%ID%:Default
		if(Info.Radius)
			Gui,Margin,% Floor(Info.Radius/3),% Floor(Info.Radius/3)
		Gui,-Caption +HWNDMain +AlwaysOnTop +Owner%Owner%
		Gui,Color,% Info.Background,% Info.Background
		NotifyClass.Windows[ID]:={ID:"ahk_id" Main,HWND:Main,Win:"Win" ID,Text:Text,Background:Info.Background,FlashColor:Info.FlashColor,Title:Info.Title,ShowDelay:Info.ShowDelay,Destroy:Info.Destroy}
		for a,b in Info
			NotifyClass.Windows[ID,a]:=b
		if((Ico:=StrSplit(Info.Icon,",")).1)
			Gui,Add,Picture,% (Info.IconSize?"w" Info.IconSize " h" Info.IconSize:""),% "HBITMAP:" LoadPicture(Foo:=(Ico.1+0?"Shell32.dll":Ico.1),Foo1:="Icon" (Ico.2!=""?Ico.2:Info.Icon),2)
		if(Info.Title){
			Gui,Font,% "s" Info.TitleSize " c" Info.TitleColor,% Info.TitleFont
			Gui,Add,Text,x+m,% Info.Title
		}Gui,Font,% "s" Info.Size " c" Info.Color,% Info.Font
		Gui,Add,Text,HWNDText,%Text%
		SysGet,Mon,MonitorWorkArea
		if(Info.Sound+0)
			SoundBeep,% Info.Sound
		if(FileExist(Info.Sound))
			SoundPlay,% Info.Sound
		this.MonBottom:=MonBottom,this.MonTop:=MonTop,this.MonLeft:=MonLeft,this.MonRight:=MonRight
		if(Info.Time){
			TT:=this.Dismiss.Bind({this:this,ID:ID})
			SetTimer,%TT%,% "-" Info.Time
		}if(Info.Flash){
			TT:=this.Flash.Bind({this:this,ID:ID})
			SetTimer,%TT%,% Info.Flash
			NotifyClass.Windows[ID].Timer:=TT
		}
		for a,b in StrSplit(Info.Buttons,","){
			Gui,Margin,% Info.Radius?Info.Radius/2:5,5
			Gui,Font,s10
			Gui,Add,Button,% (a=1?"xm":"x+m"),%b%
		}
		if(Info.Progress!=""){
			Gui,Win%ID%:Font,s4
			ControlGetPos,x,y,w,h,,ahk_id%Text%
			Gui,Add,Progress,w%w% HWNDProgress,% Info.Progress
			NotifyClass.Windows[ID].Progress:=Progress
		}Gui,Win%ID%:Show,Hide
		WinGetPos,x,y,w,h,ahk_id%Main%
		if(Info.Radius)
			WinSet, Region, % "0-0 w" W " h" H " R" Info.Radius "-" Info.Radius,ahk_id%Main%
		Obj:=this.SetPos(),Flags:=0
		for a,b in StrSplit(Info.Animate,",")
			Flags|=Round(this.Animation[b])
		DllCall("AnimateWindow","UInt",Main,"Int",(Info.ShowDelay?Info.ShowDelay:this.ShowDelay),"UInt",(Flags?Flags:0x00000008|0x00000004|0x00040000|0x00000002))
		for a,b in StrSplit((Obj.Destroy?Obj.Destroy:"Top,Left,Slide"),",")
			Flags|=Round(this.Animation[b])
		Flags|=0x00010000,NotifyClass.Windows[ID].Flags:=Flags
		DetectHiddenWindows,%Hidden%
		return ID
	}Click(){
		Obj:=NotifyClass.Windows[RegExReplace(A_Gui,"\D")],Obj.Button:=A_GuiControl,(Fun:=Func("Click"))?Fun.Call(Obj):"",this.Delete(A_Gui)
	}Delete(Win){
		Win:=RegExReplace(Win,"\D"),Obj:=NotifyClass.Windows[Win],NotifyClass.Windows.Delete(Win)
		if(WinExist("ahk_id" Obj.HWND)){
			DllCall("AnimateWindow","UInt",Obj.HWND,"Int",Obj.ShowDelay,"UInt",Obj.Flags)
			Gui,% Obj.Win ":Destroy"
		}if(TT:=Obj.Timer)
			SetTimer,%TT%,Off
		this.SetPos()
	}Dismiss(){
		this.this.Delete(this.ID)
	}Flash(){
		Obj:=NotifyClass.Windows[this.ID]
		Obj.Bright:=!Obj.Bright
		Color:=Obj.Bright?(Obj.FlashColor!=""?Obj.FlashColor:Format("{:06x}",Obj.Background+800)):Obj.Background
		if(WinExist(Obj.ID))
			Gui,% Obj.Win ":Color",%Color%,%Color%
	}SetPos(){
		Width:=this.MonRight-this.MonLeft,MH:=this.MonBottom-this.MonTop,MinX:=[],MinY:=[],Obj:=[],Height:=0,Sub:=0,MY:=MH,MaxW:={0:1},Delay:=A_WinDelay,Hidden:=A_DetectHiddenWindows
		DetectHiddenWindows,On
		SetWinDelay,-1
		for a,b in NotifyClass.Windows{
			WinGetPos,x,y,w,h,% b.ID
			Height+=h+this.Margin
			if(MH<=Height)
				Sub:=Width-MinX.MinIndex()+this.Margin,MY:=MH,MinY:=[],MinX:=[],Height:=h,MaxW:={0:1},Reset:=1
			MaxW[w]:=1,MinX[Width-w-Sub]:=1,MinY[MY:=MY-h-this.Margin]:=y,XPos:=MinX.MinIndex()+(Reset?0:MaxW.MaxIndex()-w)
			WinMove,% b.ID,,%XPos%,MinY.MinIndex()
			Obj[a]:={x:x,y:y,w:w,h:h},Reset:=0
		}DetectHiddenWindows,%Hidden%
		SetWinDelay,%Delay%
	}SetProgress(ID,Progress){
		GuiControl,,% NotifyClass.Windows[ID].Progress,%Progress%
	}
}

;Actual Code Ends Here
return
;Escape::
;ExitApp
;return