@echo off
title Windows 10 native ANSI colors fast and compact macro setup by AveYo - just replace ECHO with %%@%% and ^<ESC^> with @
:: Initiate macro just once
call :@echo

::  [screenonly] [processed escape sequences]
%@% @^^[101;93m  @[101;93m STYLES
%@% @^^[0m       @[0m Reset
%@% @^^[1m       @[1m Bold
%@% @^^[4m       @[4m Underline
%@% @^^[7m       @[7m Inverse

%@% @^^[101;93m  @[101;93m NORMAL FOREGROUND COLORS
%@% @^^[30m      @[30m Black @[0m (black)
%@% @^^[31m      @[31m Red
%@% @^^[32m      @[32m Green
%@% @^^[33m      @[33m Yellow
%@% @^^[34m      @[34m Blue
%@% @^^[35m      @[35m Magenta
%@% @^^[36m      @[36m Cyan
%@% @^^[37m      @[37m White

%@% @^^[101;93m  @[101;93m NORMAL BACKGROUND COLORS 
%@% @^^[40m      @[40m Black
%@% @^^[41m      @[41m Red
%@% @^^[42m      @[42m Green
%@% @^^[43m      @[43m Yellow
%@% @^^[44m      @[44m Blue
%@% @^^[45m      @[45m Magenta
%@% @^^[46m      @[46m Cyan
%@% @^^[47m      @[47m White @[0m (white)

%@% @^^[101;93m  @[101;93m STRONG FOREGROUND COLORS
%@% @^^[90m      @[90m White
%@% @^^[91m      @[91m Red
%@% @^^[92m      @[92m Green
%@% @^^[93m      @[93m Yellow
%@% @^^[94m      @[94m Blue
%@% @^^[95m      @[95m Magenta
%@% @^^[96m      @[96m Cyan
%@% @^^[97m      @[97m White

%@% @^^[101;93m  @[101;93m STRONG BACKGROUND COLORS
%@% @^^[100m     @[100m Black
%@% @^^[101m     @[101m Red
%@% @^^[102m     @[102m Green
%@% @^^[103m     @[103m Yellow
%@% @^^[104m     @[104m Blue
%@% @^^[105m     @[105m Magenta
%@% @^^[106m     @[106m Cyan
%@% @^^[107m     @[107m White

%@% @^^[101;93m  @[101;93m COMBINATIONS
%@% @^^[31m      @[31m red foreground color
%@% @^^[7m       @[7m inverse foreground - background
%@% @^^[7;31m    @[7;31m inverse red foreground color
%@% @^^[7m       @[7m before @[31m nested
%@% @^^[31m      @[31m before @[7m nested

:: add spaces in front
%@% @^^[10C      @[10C text starts after 10 extra spaces

:: CAN EVEN WRITE OVER PREVIOUS LINES!
::  s       = save cursor position
::  10;30H  = move cursor to 10th line, 30th column
::  102;93m = bold/bright green to background, bold/bright yellow to foreground
::  30m     = non-bold/bright black to foreground
::  @@ alone to preserve spaces at the end of text
%@% @[s @[10;30H @[102;93m  Hello  @[30m  World  @[
::  u     = restore cursor position
%@% @[u
:: empty line
%@% @[ 

pause>nul
exit/b

:@echo Windows 10 native ANSI colors fast and compact macro setup by AveYo - just replace ECHO with %@% and <ESC> with @
set @10=&for /f "tokens=2-5 delims=[." %%k in ('ver') do for %%M in (%%k) do if %%M. equ 10. set "@10=%%m.%%n"
set "@=for %%n in (1,2) do if %%n==2 ( set #=^&(set @echo=!@echo:;=:! ^& for %%s in (!@echo!) do for /f "delims=[" %%t in "
 set @=%@%("%%s") do if %%s==%%t set #=!#!%%~s )^&echo(!#!^&endlocal) else setlocal enableDelayedExpansion ^&set @echo=%
if not defined @10 exit/b macro below restores escape sequences on Win10                macro above stripps @[* on older versions
for /f "tokens=1,2" %%s in ('forfiles /m "%~nx0" /c "cmd /cecho(0x1B 0xFF"') do set "@ESC=%%s" &set "@NBSP=%%t"
set @=for %%n in (1,2) do if %%n==2 (call echo(%%@echo:@[=%@ESC%[%%%@ESC%[0m%@NBSP%) else call ^&set @echo=%
for %%v in (VirtualTerminalLevel ForceV2) do reg add HKCU\Console /v %%v /d 1 /f /t reg_dword >nul 2>nul
exit/b Example: %@% @[102;93m  Hello  @[30m  World  @[                      Documentation: msft Console Virtual Terminal Sequences
::
