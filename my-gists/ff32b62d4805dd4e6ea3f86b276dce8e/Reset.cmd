@echo off
setlocal enabledelayedexpansion
set ProductGUID=0A6AA615-5321-43A0-AFAE-97BF95013EA0
set program_dir=%ProgramFiles%\GPSoftware\Directory Opus\
set findstring=gpsoftware
echo.
setacl >nul 2>&1
if !errorlevel! equ 9009 (
echo [       ERROR ] SetACL.exe not found.
echo [    DOWNLOAD ] https://helgeklein.com/downloads/SetACL/current/SetACL%%20^(executable version^).zip
echo [     EXTRACT ] SetACL.exe to "%~dp0" or "%windir%\"
echo.
goto :end
)
:event_log
wevtutil cl application
:registry
for %%a in (
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.dcf
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.dft
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.dlt
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.dop
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.dps
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.flt
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.opuscert
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AppID\dopushlp.DLL
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AppID\{3A297740-2C30-4A50-88B8-6F10EF07C4AC}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{GUID}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DesktopMouseHook
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DesktopMouseHook.1
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusFileHandle
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusFileHandle.1
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusFileOperation
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusFileOperation.1
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusZip
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusZip.1
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusZipCallbacks
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\dopushlp.DOpusZipCallbacks.1
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Interface\{087E3065-5730-4D15-AC93-4381D4161783}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Interface\{2A99A29D-5574-4936-9209-08A60DA2DFB9}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Interface\{77530F60-6CBA-4C62-AA0C-4AD16F60C352}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Interface\{AF9A2E82-D19E-4932-BC5E-4523B6C273DD}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Interface\{DB654B0D-CB3A-4BFA-A8CC-812C5E48D5E0}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Interface\{E51FAE16-57F2-48C8-A990-1472BF97CFB9}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusButtonFile
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusCertificateFile
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusCommandFile
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusFileTypesFile
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusFilterFile
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusListerTheme
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusSettingsFile
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\OpusZip
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{6D9494D7-730C-4F62-8FB0-30C55B70D092}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{EE761688-C137-4b04-8FAB-3C9CDF0886F0}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\Interface\{2A99A29D-5574-4936-9209-08A60DA2DFB9}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\Interface\{77530F60-6CBA-4C62-AA0C-4AD16F60C352}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\Interface\{AF9A2E82-D19E-4932-BC5E-4523B6C273DD}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\Interface\{DB654B0D-CB3A-4BFA-A8CC-812C5E48D5E0}
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\Interface\{E51FAE16-57F2-48C8-A990-1472BF97CFB9}
HKEY_LOCAL_MACHINE\SOFTWARE\GPSoftware
"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Low Rights\DragDrop\{EE0F1650-117B-4075-A78C-EA86C85710B3}"
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Tracing\dopus_RASAPI32
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Tracing\dopus_RASMANCS
"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\DOpus.exe"
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\OpusOpenFolder
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DesktopInterfaceMethod
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FindExtensions\Static\DOpusFind
HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GPSoftware
HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{!ProductGUID!}
"HKEY_CURRENT_USER\Control Panel\International\Time"
HKEY_CURRENT_USER\Software\Classes\x\shellex\ContextMenuHandlers\OpusZip
HKEY_CURRENT_USER\Software\Classes\coll
HKEY_CURRENT_USER\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\DOpus
HKEY_CURRENT_USER\Software\Classes\Directory\shellex\ContextMenuHandlers\OpusZip
HKEY_CURRENT_USER\Software\Classes\Directory\shellex\DragDropHandlers\OpusZip
HKEY_CURRENT_USER\Software\Classes\Folder\shellex\DragDropHandlers\OpusZip
HKEY_CURRENT_USER\Software\Classes\encrypted_computername
HKEY_CURRENT_USER\Software\Microsoft\Metro
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\DlgInfo
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\
"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Disallowed"
"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Handlers"
) do (
    set KEY=%%a
    if !KEY!==HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{GUID} (call :clsid) else (
        if !KEY!==HKEY_CURRENT_USER\Software\Classes\encrypted_computername (call :encrypted_computername) else (
            if !KEY!==HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\ (call :rot_13) else (
                if !KEY!==HKEY_CURRENT_USER\Software\Classes\x\shellex\ContextMenuHandlers\OpusZip (
                set KEY=HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers\OpusZip
                call :query
                ) else (
                    call :query
    ))))
)
set KEY=HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam\MUICache
for %%a in (
dopusrt.exe
d8viewer.exe
) do (
reg delete !KEY! /v "!program_dir!%%a" /f >nul 2>&1
    if !errorlevel! equ 0 (
        echo [   DELETED   ] !KEY! - "!program_dir!%%a"
    )
)
set KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\UnknownContentOnArrival
set value=OpusOpenFolder
reg delete !KEY! /v !value! /f >nul 2>&1
    if !errorlevel! equ 0 (echo [   DELETED   ] !KEY! - !value!)
set KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellExecuteHooks
set value={3CF9ECE0-1A9F-11D2-8C73-00C06C2005DE}
reg delete !KEY! /v !value! /f >nul 2>&1
    if !errorlevel! equ 0 (echo [   DELETED   ] !KEY! - !value!)
  
set KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\explorer\ShellExecuteHooks
set value={EE761688-C137-4b04-8FAB-3C9CDF0886F0}
reg delete !KEY! /v !value! /f >nul 2>&1
    if !errorlevel! equ 0 (echo [   DELETED   ] !KEY! - !value!)
  
set KEY="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved"
reg delete !KEY! /v !value! /f >nul 2>&1
    if !errorlevel! equ 0 (
        set KEY=!KEY:"=!
        echo [   DELETED   ] !KEY! - !value!
    )
  
set KEY="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved"
for %%a in (
{2DF394BA-1955-4a52-900E-303836135F67}
{3CF9ECE0-1A9F-11d2-8C73-00C06C2005DE}
{42BEF283-A10E-472D-B105-9F2B59AFBFC8}
{B9DD4945-1BED-4cb7-994C-F40B72B7725A}
{BBD5F00E-26A6-4fb2-BAE1-31543C0BEA47}
{D2FCA36D-93CD-46f2-8324-6308F6E31B53}
{E9FE4040-3C93-11d4-8006-00201860E88A}
{F85D7E1E-9662-4b38-B1AE-3CF1E9581A3C}
)do (
set value=%%a
reg delete !KEY! /v !value! /f >nul 2>&1
   if !errorlevel! equ 0 (
    set KEY=!KEY:"=!
    echo [   DELETED   ] !KEY! - !value!
    set KEY="!KEY!"
    )
)
set KEY="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Cached"
set value={3CF9ECE0-1A9F-11D2-8C73-00C06C2005DE}
reg query !KEY! >nul 2>&1
if !errorlevel! equ 0 (
    for /f "delims=" %%a in ('reg query !KEY! /v /f !value! ^| findstr /i !value!') do (
        set _var=%%a
        set _test=!_var:~4!
        set _endbit=!_test:*0xFFFF=!
        call set _result=%%_test:!_endbit!=%%
        reg delete !KEY! /v "!_result!" /f >nul 2>&1
        set KEY=!KEY:"=!
        echo [   DELETED   ] !KEY! - !_result!
    )
)
:filesystem
echo.
for %%a in (
C:\Windows\System32\inf32\
"C:\Program Files (x86)\InstallShield Installation Information\{!ProductGUID!}"
) do (
    set folder=%%a
    if exist !folder! (
        rd /S /Q !folder!
        set folder=!folder:"=!
        echo [   DELETED   ] !folder!
    )
)
for %%a in (
"!program_dir!dopus.dat"
%ProgramData%\sdpsenv.dat
"%ProgramData%\GPSoftware\Directory Opus\dopus.cert"
"%ProgramData%\GPSoftware\Directory Opus\Global Data\globaldata.omd"
"%AppData%\GPSoftware\Directory Opus\dopus.dat"
C:\Windows\xpcc37.log
C:\Windows\System32\argtmp39.dll
) do (
    set file=%%a
  
    if exist !file! (
        attrib -r -a -s -h !file!
        del /Q /F !file!
        set file=!file:"=!
        echo [   DELETED   ] !file!
    )
)
echo.
goto :end
:query
reg query !KEY! >nul 2>&1
if !errorlevel! equ 0 (
call :delete_key
)
exit /b
:delete_key
reg delete !KEY! /f >nul 2>&1
if !errorlevel! equ 0 (
set KEY=!KEY:"=!
    if not defined aclmark (
        echo [   DELETED   ] !KEY!
    ) else (
        echo [ !aclmark! DELETED !aclmark! ] !KEY!
    )
set aclmark=
) else (
call :setacl
)
exit /b
:setacl
SetACL.exe -on !KEY! -ot reg -actn setprot -op "dacl:p_c;sacl:p_c" -actn setowner -ownr "n:%USERNAME%" -actn ace -ace "n:%USERNAME%;p:full" -actn trustee -trst "n1:Everyone;ta:remtrst;w:dacl" -actn rstchldrn -rst "dacl,sacl" >nul 2>&1
set aclmark=*
call :delete_key
exit /b
:clsid
for /f "tokens=2 delims={}" %%a in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\ /s /d /f !findstring!') do (
  
    if /i not "%%a"=="!row!" (
        set KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{%%a}
        call :delete_key
        set row=%%a
    )
)
exit /b
:encrypted_computername
set KEY=HKEY_CURRENT_USER\Software\Classes
for /f "delims=" %%a in ('reg query !KEY!') do (
  
    if /i not "%%a"=="HKEY_CURRENT_USER\Software\Classes\*" (
        if /i not "%%a"=="HKEY_CURRENT_USER\Software\Classes\AppID" (
            if /i not "%%a"=="HKEY_CURRENT_USER\Software\Classes\CLSID" (
                if /i not "%%a"=="HKEY_CURRENT_USER\Software\Classes\Local Settings" (
                    if /i not "%%a"=="HKEY_CURRENT_USER\Software\Classes\TypeLib" (
                        if /i not "%%a"=="HKEY_CURRENT_USER\Software\Classes\Wow6432Node" (
  
    for /f %%b in ('reg query %%a /s /f "*" /t reg_binary ^| findstr "HKEY"') do (
    set KEY=%%b
    call :delete_key
    )
)))))))
exit /b
:rot_13
rem rot13.bat
rem dr@zhihua-lai.com
rem http://www.zhihua-lai.com/acm
rem 16-Sept-2012
    set _len=0
    set _str=%computername%
    rem Get the length of the sentence
    set _subs=%_str%
:loop
    if not defined _subs goto result
    rem remove the first char
    set _subs=%_subs:~1%
    set /a _len+=1
    goto loop 
    
:result
    set /a _len-=1
    (set s=)
    for /l %%g in (0,1,%_len%) do (
        call :build %%g
    )
    set KEY=!KEY!%s%
    call :query
    exit /b
:build
    rem get the next character
    call set _digit=%%_str:~%1,1%%%
    rem rot13 ^& rot5
    if "!_digit!"=="a" (
        (set s=!s!n)
    ) else if "!_digit!"=="b" (
        (set s=!s!o)
    ) else if "!_digit!"=="c" (
        (set s=!s!p)
    ) else if "!_digit!"=="d" (
        (set s=!s!q)
    ) else if "!_digit!"=="e" (
        (set s=!s!r)
    ) else if "!_digit!"=="f" (
        (set s=!s!s)
    ) else if "!_digit!"=="g" (
        (set s=!s!t)
    ) else if "!_digit!"=="h" (
        (set s=!s!u)
    ) else if "!_digit!"=="i" (
        (set s=!s!v)
    ) else if "!_digit!"=="j" (
        (set s=!s!w)
    ) else if "!_digit!"=="k" (
        (set s=!s!x)
    ) else if "!_digit!"=="l" (
        (set s=!s!y)
    ) else if "!_digit!"=="m" (
        (set s=!s!z)
    ) else if "!_digit!"=="n" (
        (set s=!s!a)
    ) else if "!_digit!"=="o" (
        (set s=!s!b)
    ) else if "!_digit!"=="p" (
        (set s=!s!c)
    ) else if "!_digit!"=="q" (
        (set s=!s!d)
    ) else if "!_digit!"=="r" (
        (set s=!s!e)
    ) else if "!_digit!"=="s" (
        (set s=!s!f)
    ) else if "!_digit!"=="t" (
        (set s=!s!g)
    ) else if "!_digit!"=="u" (
        (set s=!s!h)
    ) else if "!_digit!"=="v" (
        (set s=!s!i)
    ) else if "!_digit!"=="w" (
        (set s=!s!j)
    ) else if "!_digit!"=="x" (
        (set s=!s!k)
    ) else if "!_digit!"=="y" (
        (set s=!s!l)
    ) else if "!_digit!"=="z" (
        (set s=!s!m)
    ) else if "!_digit!"=="A" (
        (set s=!s!N)
    ) else if "!_digit!"=="B" (
        (set s=!s!O)
    ) else if "!_digit!"=="C" (
        (set s=!s!P)
    ) else if "!_digit!"=="D" (
        (set s=!s!Q)
    ) else if "!_digit!"=="E" (
        (set s=!s!R)
    ) else if "!_digit!"=="F" (
        (set s=!s!S)
    ) else if "!_digit!"=="G" (
        (set s=!s!T)
    ) else if "!_digit!"=="H" (
        (set s=!s!U)
    ) else if "!_digit!"=="I" (
        (set s=!s!V)
    ) else if "!_digit!"=="J" (
        (set s=!s!W)
    ) else if "!_digit!"=="K" (
        (set s=!s!X)
    ) else if "!_digit!"=="L" (
        (set s=!s!Y)
    ) else if "!_digit!"=="M" (
        (set s=!s!Z)
    ) else if "!_digit!"=="N" (
        (set s=!s!A)
    ) else if "!_digit!"=="O" (
        (set s=!s!B)
    ) else if "!_digit!"=="P" (
        (set s=!s!C)
    ) else if "!_digit!"=="Q" (
        (set s=!s!D)
    ) else if "!_digit!"=="R" (
        (set s=!s!E)
    ) else if "!_digit!"=="S" (
        (set s=!s!F)
    ) else if "!_digit!"=="T" (
        (set s=!s!G)
    ) else if "!_digit!"=="U" (
        (set s=!s!H)
    ) else if "!_digit!"=="V" (
        (set s=!s!I)
    ) else if "!_digit!"=="W" (
        (set s=!s!J)
    ) else if "!_digit!"=="X" (
        (set s=!s!K)
    ) else if "!_digit!"=="Y" (
        (set s=!s!L)
    ) else if "!_digit!"=="Z" (
        (set s=!s!M)
    ) else if "!_digit!"=="0" (
        (set s=!s!0)
    ) else if "!_digit!"=="1" (
        (set s=!s!6)
    ) else if "!_digit!"=="2" (
        (set s=!s!7)
    ) else if "!_digit!"=="3" (
        (set s=!s!8)
    ) else if "!_digit!"=="4" (
        (set s=!s!9)
    ) else if "!_digit!"=="5" (
        (set s=!s!x)
    ) else if "!_digit!"=="6" (
        (set s=!s!6)
    ) else if "!_digit!"=="7" (
        (set s=!s!7)
    ) else if "!_digit!"=="8" (
        (set s=!s!8)
    ) else if "!_digit!"=="9" (
        (set s=!s!9)
    ) else (
        (set s=!s!!_digit!)
    )
exit /b
:end
endlocal
EXIT