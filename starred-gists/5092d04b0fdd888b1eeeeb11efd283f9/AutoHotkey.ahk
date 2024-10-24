;=============================================================================
; File:          AutoHotkey.ahk
; Author:        Mattia72 
; Description:   Automatically launched AHK script   
; Created:       28 okt. 2015
; Project Repo:  https://gist.github.com/f422d965d2dcd6db3bbf.git
;=============================================================================

; This script has a special filename and path because it is automatically
; launched when you run the program directly.  Also, any text file whose
; name ends in .ahk is associated with the program, which means that it
; can be launched simply by double-clicking it.  You can have as many .ahk
; files as you want, located in any folder.  You can also run more than
; one ahk file simultaneously and each will get its own tray icon.

OutputDebug, Script loading on %A_ComputerName%.

TrayTip, Autohotkey, Starting..., 2, 1

HOME=C:\Users\akmattia\root\msys64\home\akmattia

;set default editor
;editor = %HOME%\utils\editors\SublimeText\sublime_text.exe
editor=%HOME%\utils\editors\Vim\vim80\gvim.exe
editor_params=--servername GVIM 
browser=%HOME%\apps\PortableApps\GoogleChromePortable64\App\Chrome-bin\chrome.exe
console=%HOME%\utils\misc\FarManager\ConEmu.exe
notepad=%HOME%\utils\editors\Notepad++\notepad++.exe

;set path for 
farManager=%HOME%\utils\misc\FarManager\Far.exe
freeCommander=%HOME%\utils\misc\FreeCommander XE\FreeCommander.exe
regwrite, reg_sz, hkey_classes_root, autohotkeyscript\shell\edit\command, , %editor% %editor_params% --remote-tab-silent `"`%1`"
;regwrite, reg_sz, hkey_classes_root, batfile\shell\open\command, , %HOME%\utils\power-toys\Console2\Console.exe -r `"/c `"`%1`" `%*`"
;regwrite, reg_sz, hkey_classes_root, batfile\shell\open\command, , %HOME%\utils\misc\FarManager\ConEmu.exe `"/Single /cmd `"`%1`" `%*`"


; ===========================================================================
; RunOrActivate: Run a program or switch to it if already running.
;    program - Program to run. E.g. Calc.exe or C:\Progs\Bobo.exe
;              This can be a list of paths separeted by new line
;              E.g C:\Progs\Bobo.exe`nD:\Bobo.Exe
;    params - parameter for program
;    title - Optional title of the window to activate.  Programs like
;      MS Outlook might have multiple windows open (main window and email
;      windows).  This parm allows activating a specific window.
;    alwaysRun - don't search anything just run.
; ===========================================================================
RunOrActivate(program, params := "", title := "", alwaysRun=false)
{
   PID:=0
   if alwaysRun
   {
     PID := RunProgramWithParameters(program,params)
     OutputDebug, Always run with params %fileName% params: %params%
   }

   OutputDebug, program: %program%
   StringSplit, program_path_array, program, `n

   if (PID == 0)
   Loop, %program_path_array0%
   {
      prog := program_path_array%a_index%
      OutputDebug, program in loop: %prog%

      ;exists := FileExist(prog)
      ;isPath := InStr(prog, ":")
      ;OutputDebug, %prog% %exists% %isPath%

      ;If not a path e.g calc.exe or path exists...
      If(!InStr(prog, ":") or FileExist(prog))
      {
        ; Get the filename without a path
        SplitPath, prog, fileName
        OutputDebug, search %fileName% in running process.
        Process, Exist, %fileName%
        If ErrorLevel > 0
        {
          PID = %ErrorLevel%
          OutputDebug, It runs already (%PID%) %fileName%
        }
        Else
        {
          PID := RunProgramWithParameters(prog,params)
          OutputDebug Running %fileName% with params: %params%
        }
      }
   }
   ; If an app wouldn't become active
   ; using Run, we always force a window activate.
   ; Activate by title if given, otherwise use PID.
   If title <>
   {
      SetTitleMatchMode, 2
      WinWait, %title%, , 3
      TrayTip, Activating, Window Title "%title%" (%fileName%), 2, 1
      WinActivate, %title%
   }
   Else
   {
      WinWait, ahk_pid %PID%, , 3
      TrayTip, Activating, %fileName% (PID %PID%), 2, 1
      WinActivate, ahk_pid %PID%
   }
   SetTimer, RunOrActivateTrayTipOff, 2000
}

; ===========================================================================
; RunOrActivateTrayTipOf: fTurn off the tray tip
; ===========================================================================
RunOrActivateTrayTipOff:
   SetTimer, RunOrActivateTrayTipOff, off
   TrayTip
Return

; ===========================================================================
; GetSelectedText: Returns with the selected text
; ===========================================================================
GetSelectedText()
{
   tmp = %ClipboardAll% ; save clipboard
   CopyToClipboard()
   selection = %Clipboard% ; save the content of the clipboard
   OutputDebug Selection: %selection%
   Clipboard = %tmp% ; restore old content of the clipboard
   VarSetCapacity(tmp, 0)
   return selection
}

; ===========================================================================
; CopyToClipboard: Copy selected text to clipboard
; ===========================================================================
CopyToClipboard()
{
  Clipboard =  ; Start off empty to allow ClipWait to detect when the text has arrived.
  Send, ^{Ins}
  ClipWait, 1  ; Wait for the clipboard to contain text.
  return
}

; ===========================================================================
; SearchSelectionOnWeb: Searches selected text on web site
; postFix is the end of the url, search string(selection)
; is between searchSite and postfix
; if there is no selected text, it opens the main site
; ===========================================================================
SearchSelectionOnWeb(searchSite, postFix="")
{
  selection := GetSelectedText()
  SearchOnWebs(searchSite, selection, postFix)
}

; ===========================================================================
; SearchClipBoardOnWeb: Searches clipboard content text on web site
; postFix is the end of the url, search string(selection)
; is between searchSite and postfix
; if there is no selected text, it opens the main site
; ===========================================================================
SearchClipBoardOnWeb(searchSite, postFix="")
{
  content = %Clipboard% ; save the content of the clipboard
  SearchOnWebs(searchSite, content, postFix)
}

; ===========================================================================
; SearchSelectionOnWebs: Searches selected text on web sites
; searchSites are separeted with spaces...
; if there is no selected text, it opens the main site
; ===========================================================================
SearchSelectionOnWebs(searchSites, postFixes="")
{
  selection := GetSelectedText()
  SearchOnWebs(searchSites, selection, postFixes)
}

; ===========================================================================
; SearchClipBoardOnWebs: Searches clipboard content text on web sites
; searchSites are separeted with spaces...
; if there is no selected text, it opens the main site
; ===========================================================================
SearchClipBoardOnWebs(searchSites, postFixes="")
{
  content = %Clipboard% ; save the content of the clipboard
  SearchOnWebs(searchSites, content, postFixes)
}

; ===========================================================================
; SearchOnWebs: Searches text on web sites
; searchSites are separeted with spaces...
; if there is no selected text, it opens the main site
; ===========================================================================
SearchOnWebs(searchSites,text, postFixes="")
{

  OutputDebug, sites: '%searchSites%' text: '%text%' post: '%postFixes%'
	StringSplit, postFix_array, postFixes, `n
  index=1
  Loop, parse, searchSites, `n
  {
    searchSite=%A_LoopField%
    post := postFix_array%index%

   ; MsgBox, %searchSite%
    if (StrLen(text) == 0)
        searchSite := RegexReplace(searchSite,"(http.?://[^/]*)/.*$","$1" )

    StringGetPos, pos, searchSite, `%
    if (pos == 0)
    {
      EncodeUriString(text)
      StringTrimLeft, searchSite, searchSite, 1
    }
    ;MsgBox, %searchSite% %pos% %text%
    OutputDebug, handle:'%searchSite%' text:'%text%' post:'%post%'
    fullSearchString = %searchSite%%text%%post%

    OutputDebug, Full search string: %fullSearchString%
    TrayTip, Open, %fullSearchString%, 2, 1
    Run,  %fullSearchString%
    SetTimer, RunOrActivateTrayTipOff, 3000
    index+=1
  }
}

; ===========================================================================
; OpenSelectedTextInVim: Opens selection in a new buffer in Vim 
; ===========================================================================
OpenSelectedTextInVim()
{
  global editor
  tmp = %ClipboardAll% ; save clipboard
  CopyToClipboard()
  selection = %Clipboard% ; save the content of the clipboard
  OutputDebug Selection: %selection%
  RunOrActivate( editor, "-c ""put! *""" , "", true)
  Clipboard = %tmp% ; restore old content of the clipboard
  VarSetCapacity(tmp, 0)
}

; ===========================================================================
; OpenSelectedURL: Opens selection, optional with given program
; if selection could not be launched, MsgBox is shown.
; ===========================================================================
OpenSelectedURL(program_path="", program_args="", remove_protocol=false)
{
  selection := GetSelectedText()
  selection := RegExReplace( selection, "(^\s+)|(\s+$)")
  if (remove_protocol)
  {
    selection := RemoveProtocolSelector(selection)
  }
  TryOpen(selection, program_path, program_args)
}

; ===========================================================================
; OpenURLFromClipBoard: Opens clipboard content, optional with given program
; if selection could not be launched, MsgBox is shown.
; ===========================================================================
OpenURLFromClipBoard(program_path="", program_args="", remove_protocol=false)
{
  content = %Clipboard% ; save the content of the clipboard
  content := RegExReplace( content, "(^\s+)|(\s+$)")
  if (remove_protocol)
  {
    selection := RemoveProtocolSelector(selection)
  }
  TryOpen(content, program_path, program_args)
}

RemoveProtocolSelector(text)
{
  text := RegExReplace( text, "i)^(file|https?|mailto)://" )
  return text
}

; ===========================================================================
; TryOpen: Opens something, optional with given program
; if selection could not be launched, MsgBox is shown.
; ===========================================================================
TryOpen(something, program_path="", program_args="")
{
  if (StrLen(something) != 0)
  {
    TrayTip, Open, %something%, 2, 1
    if (StrLen(program_path) == 0)
    {
      Run, %something%, , UseErrorLevel
      if ErrorLevel = ERROR ; document not found...
      {
        MsgBox, 52, Autohotkey: error, The document "%something%" could not be launched.`nWould you search it on the web?
        IfMsgBox Yes
          SearchOnWebs("http://www.google.com/search?q=",something)
      }
      else
      {
        OutputDebug, Run something=%something%
      }
    }
    else
    {
	    StringSplit, program_path_array, program_path, `n
      Loop, %program_path_array0%
      {
        program_path := program_path_array%a_index%
        IfExist, %program_path%
        {
          Run, %program_path% %program_args% "%something%", , UseErrorLevel
          if ErrorLevel = ERROR ; document not found...
          {
            MsgBox, 16, Autohotkey: error %program_path% %program_args% "%something%" could not be launched.
          }
          else
          {
            OutputDebug, Run prog=%program_path% args=%program_args% with="%something%"
          }
        }
        else
        {
          OutputDebug, prog=%program_path% not found!
        }

      }
    }
    SetTimer, RunOrActivateTrayTipOff, 3000
  }
}

; ===========================================================================
; RunProgramWithParameters: Runs a program with given parameters
; ===========================================================================
RunProgramWithParameters(program_path, param="")
{
    PID:=0
    StringSplit, program_path_array, program_path, `n
    Loop, %program_path_array0%
    {
      prog := program_path_array%a_index%
      IfNotExist, %prog%
      {
        OutputDebug, prog=%prog% not found, but we try to start it, it may be in path!
      }
      TrayTip, Running, %prog% %param%, 2, 1
      if (StrLen(param) == 0)
        Run,%prog%, , ,PID
      else
        Run, %prog% %param%, , ,PID
      SetTimer, RunOrActivateTrayTipOff, 3000
    }
    return PID
}

; ===========================================================================
; EncodeUriString: Encodes the uri
; ===========================================================================
EncodeUriString(ByRef Text)
{
    ;oSC := ComObjCreate("ScriptControl")
    ;oSC.Language := "JScript"
    ;Script := "var Encoded = encodeURIComponent(""" . Uri . """)"
    ;oSC.ExecuteStatement(Script)
    ;encoded := oSC.Eval("Encoded")
    ;Return encoded
   StringReplace, Text, Text, `%, `%25, All
   FormatInteger := A_FormatInteger, FoundPos := 0
   SetFormat, IntegerFast, Hex
   While (FoundPos := RegExMatch(Text, "[^\w-.~% ]", Char, FoundPos + 1))
   {
   a:= Asc(Char)
   OutputDebug Char:%Char% %a%
      StringReplace, Text, Text, %Char%, % "%" SubStr(0 SubStr(Asc(Char), 3), -1), All
      }
   OutputDebug %Text%
   StringReplace, Text, Text, %A_Space%, +, All
   SetFormat, IntegerFast, %FormatInteger%
   Text := RegExReplace(Text, "%..", "$U0")
}

; ===========================================================================
; Hotkey definitions...
; ===========================================================================

;Alt+Win -> Search / Open selected text
;---------------------------------------
;_b_ing
!#b:: SearchSelectionOnWebs("http://www.bing.com/search?q=")
;_d_e-hu dict
!#d::
!#+d::
; `n separated list of sites and postfixes
; begins with % if needs to be encoded
sites=http://de`.thefreedictionary`.com/`nhttp://szotar`.sztaki`.hu/search?fromlang=ger&tolang=hun&searchWord=
postfixes=`n`n
;MsgBox, %A_Thishotkey%
if ( A_ThisHotkey = "!#d" )
  SearchSelectionOnWebs( sites, postfixes)
else if ( A_ThisHotkey = "!#+d" )
  SearchClipBoardOnWebs( sites, postfixes)
return
;_e_n dict
!#e::
!#+e::
; `n separated list of sites and postfixes
; begins with % if needs to be encoded
sites=http://en`.thefreedictionary`.com/`nhttp://www`.macmillandictionary`.com/dictionary/british/`nhttp://szotar`.sztaki`.hu/search?fromlang=eng&tolang=hun&searchWord=
;http://www`.webforditas`.hu/szotar`.php?S=
postfixes=`n`n
if ( A_ThisHotkey = "!#e" )
  SearchSelectionOnWebs( sites, postfixes)
else if ( A_ThisHotkey = "!#+e" )
  SearchClipBoardOnWebs( sites, postfixes)
return
;google _f_ordító
!#f:: SearchSelectionOnWebs("http://translate.google.hu/#auto|hu|")
;google search
!#g:: SearchSelectionOnWebs("http://www.google.com/search?q=")
!#+g:: SearchClipBoardOnWebs("http://www.google.com/search?q=")
;internet explorer
!#i:: OpenSelectedURL("C:\Program Files\Internet Explorer\iexplore.exe")
!#+i:: OpenURLFromClipBoard("C:\Program Files\Internet Explorer\iexplore.exe")
;_l_eo dict
!#l::
!#+l::
; `n separated list of sites and postfixes
; begins with % if needs to be encoded
sites=`%http://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=on&chinese=both&pinyin=diacritic&relink=on&search=`nhttp://www`.linguee`.de/deutsch-englisch/search?source=auto&query=
postfixes=`n`n
if ( A_ThisHotkey = "!#l" )
  SearchSelectionOnWebs( sites, postfixes)
else if ( A_ThisHotkey = "!#+l" )
  SearchClipBoardOnWebs( sites, postfixes)
return

;open 
!#m:: OpenSelectedURL(farManager, "/C", true)
!#+m:: OpenURLFromClipBoard(farManager, "/C", true)

;sites=http://szotar.sztaki.hu/search?fromlang=hu&tolang=ger&searchWord=
;;http://www`.webforditas`.hu/szotar`.php?S=
;postfixes=`n
;SearchSelectionOnWebs( sites, postfixes)
;return

;;open with notepad++
!#n:: OpenSelectedURL("C:\Program Files\Notepad++\notepad++.exe")
!#+n:: OpenURLFromClipBoard("C:\Program Files\Notepad++\notepad++.exe")
;open with 
!#t:: OpenSelectedURL(freeCommander, "/C", true)
!#+t:: OpenURLFromClipBoard(freeCommander, "/C", true)
;search in Everyithing
!#y:: OpenSelectedURL("C:\Program Files\Everything\Everything.exe","-s")
!#+y:: OpenURLFromClipBoard("C:\Program Files\Everything\Everything.exe","-s")
;open with vim
!#v:: OpenSelectedTextInVim()
!#s:: OpenSelectedURL(editor, editor_params)
!#+v:: OpenURLFromClipBoard(editor, editor_params)
!#+s:: OpenURLFromClipBoard(editor, editor_params)
;search on wiki
!#w:: SearchSelectionOnWebs("http://hu.wikipedia.org/wiki/Special:Search?search=")
!#r:: SearchSelectionOnWebs("https://q4de3csy121.gdc-chnz01.t-systems.com/trac/ABILIT/ticket/")
;open with default...
!#o:: OpenSelectedURL()
!#+o:: OpenURLFromClipBoard()

;Ctrl+Win Run or Activate
;---------------------------------------
^#=:: RunOrActivate("calc.exe")
^#b:: RunOrActivate(browser, "", "")
^#c:: RunOrActivate(console, "/Dir " HOME " /cmd {Dos}","",true)
^#e:: Edit ;edit this script
^#f:: RunOrActivate(freeCommander,"","",true)

;different path on 32 and 64 bit windows
; firefox_path_array = C:\Program Files (x86)\Mozilla Firefox\firefox.exe`nc:\Program Files\Mozilla Firefox\firefox.exe`nc:\Program Files\Nightly\firefox.exe
; RunOrActivate(firefox_path_array)
;return

;^#g:: ; vimgolf
  ;selection := RegExReplace( GetSelectedText(), "(^\s+)|(\s+$)")
  ;command = %console% /dir %HOME%\dev\ruby\gems\bin\ /cmd "/k " %HOME% "\dev\ruby\gems\bin\vimgolf.bat put " %selection%
  ;Run, %command%
  ;Return

^#l::    ;Make Selection Lowercase
 selection := GetSelectedText()
 StringLower Clipboard, selection
 Send %Clipboard%
 return
^#u:: 
 selection := GetSelectedText()
 StringUpper Clipboard, selection
 Send %Clipboard%
 return
^#k:: 
 selection := GetSelectedText()
 StringUpper Clipboard, selection, T
 Send %Clipboard%
 return

^#m:: RunOrActivate(console, "/dir " HOME " /cmd {Far}")
^#n:: RunOrActivate(notepad,"-n0","",true)
^#o:: RunOrActivate("C:\Program Files (x86)\Microsoft Office\Office14\OUTLOOK.EXE","/recycle","",true)
^#p:: RunOrActivate(console, "/dir " HOME " /cmd {PowerShell}", "", true)
^#r:: Reload ;reload this script
^#t:: RunOrActivate(freeCommander,"","",true)

; vim ...
^#v:: RunOrActivate(editor, editor_params)

;AltGr Run only (Vigyázz az äÄ&@# billentyűkkel!)
;---------------------------------------
<^>!d:: RunProgramWithParameters( "c:\WINDOWS\system32\rundll32.exe", "shell32.dll`,Control_RunDLL desk.cpl`,`, 3 ")
<^>!r:: RunProgramWithParameters("c:\WINDOWS\system32\mstsc.exe", "/span")
<^>!p::
RunProgramWithParameters("%HOME%\UTILS\Remote\PUTTY\PAGEANT.EXE","%HOME%\utils\remote\ssh-rsa-putty.ppk")
RunProgramWithParameters("%HOME%\UTILS\Remote\PUTTY\PUTTY.EXE")
return

;Ctrl+Alt system...
;---------------------------------------
^!CtrlBreak::Run, %HOME%\bin\waitsusp.exe
^!+CtrlBreak::Run, %HOME%\bin\waitsusp.exe -m hibernate
^!m::Run, %HOME%\utils\system\PowerOnOff\pwroff301\poweroff.exe monitor_off
;^!p::Run,"%HOME%\utils\power-toys\Wallpaper\wallpaper_changer.exe"
;^!p::Run, powershell.exe -File %HOME%\utils\power-toys\Wallpaper\Set-Wallpaper.ps1 -WindowStyle Hidden
^!p::Run, C:\Users\akmattia\root\msys64\home\akmattia\apps\Start.exe

;Abbreviations
;---------------------------------------
::a÷::ä
::A÷::Ä
::EU$::€

::2dm::      ;this hotstring replaces '2dm' to the current date
FormatTime, CurrentDateTime,, yyyy.MM.dd
SendInput %CurrentDateTime%
return

::2dd::      ;this hotstring replaces '2dd' to the current date
FormatTime, CurrentDateTime,, dd.MM.yyyy
SendInput %CurrentDateTime%
return

::2de::      ;this hotstring replaces '2de' to the current date
FormatTime, CurrentDateTime,, dd/MM/yyyy
SendInput %CurrentDateTime%
return

::2di::      ;this hotstring replaces '2di' to the current date
FormatTime, CurrentDateTime,, yyyyMMdd
SendInput %CurrentDateTime%
return

::2dii::      ;this hotstring replaces '2dii' to the current date and time
FormatTime, CurrentDateTime,, yyyyMMddHH24MI
SendInput %CurrentDateTime%
return

#Include %A_ScriptDir%
;#Include Jabber.ahk
;#Include FreeCommander.ahk
;#Include  %A_ScriptDir%\vim.ahk
;vim:tw=80:ts=4:ft=ahk:norl
