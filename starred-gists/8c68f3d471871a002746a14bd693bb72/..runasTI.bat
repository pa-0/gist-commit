@echo off & title AveYo`s :runasTI snippet usage showcase (final)

:: First handle command line parameters (for example via Send to) to run as TrustedInstaller AllPrivileges
if /i "%~dp0" equ "%APPDATA%\Microsoft\Windows\SendTo\" call :runasTI 1 %* &exit/b

echo(
echo  Fully portable, compact, plain-text runas TrustedInstaller or SYSTEM snippet v20191010
echo ========================================================================================
echo  - now also supports short common programs names such as cmd, regedit, powershell..
echo  - now sets console buffer so that the scrollbars are visible!
echo  - should work even on naked Windows 7 with powershell 2.0, both x64 and x86
echo  - snippet is minified for size but still very readeable
echo  - just copy-paste the 18 lines in your own batch scripts and call the snippet as needed!
echo  - can also be used from the right-click - Send to menu (entry appears after 1st run)
echo(
timeout /t 5 >nul

:: If this script is already elevated to SYSTEM prevent loop and just print a message
whoami /user|findstr "S-1-5-18">nul && (
  whoami /all
  echo Script %~dnx0 has activated SYSTEM [DefPrivileges] command line!
  exit/b
)

:: Elevate just once to ADMIN instead of uac nagging 6 times..
reg query HKU\S-1-5-19 >nul 2>nul || ( powershell -nop -c "start cmd -ArgumentList '/c call \"%~f0\"' -verb runas" &exit)

:: Open four powershell windows for each supported mode
call :runasTI 0 powershell -noexit -c "whoami /priv /groups;write-host -fore magenta :runasTI 0 = TrustedInstaller DefPrivileges"
call :runasTI 1 powershell -noexit -c "whoami /priv /groups;write-host -fore magenta :runasTI 1 = TrustedInstaller AllPrivileges"
call :runasTI 2 powershell -noexit -c "whoami /priv /groups;write-host -fore    cyan :runasTI 2 = System DefPrivileges"
call :runasTI 3 powershell -noexit -c "whoami /priv /groups;write-host -fore    cyan :runasTI 3 = System AllPrivileges"

:: Open REGEDIT as TrustedInstaller DefPrivileges
rem call :runasTI 0 regedit

:: This script could also be used from the right-click - Send to menu to launch any program as TI / System
if /i "%~dp0" neq "%APPDATA%\Microsoft\Windows\SendTo\" (copy /y "%~f0" "%APPDATA%\Microsoft\Windows\SendTo\_runasTI.bat")

:: Elevate itself to TrustedInstaller DefPrivileges once
whoami /user|findstr "S-1-5-18">nul || (call :runasTI 0 cmd /k call "%~f0" &exit)

echo HALT! How did I reach this line?!
timeout -1

exit/b

:runasTI [0-3] [cmd] AveYo`s Lean and Mean runas TrustedInstaller / System snippet v20191010                 pastebin.com/AtejMKLj
set ">>=('-nop -c ',[char]34,'$mode=%1; $cmd=''%*''; iex(([io.file]::ReadAllText(''%~f0'')-split '':ps_TI\:.*'')[1])',[char]34)"
(whoami/user|findstr "S-1-5-18">nul||powershell -nop -c "start powershell -win 1 -verb runas -Arg %>>:"=\\\"% ") &exit/b  :ps_TI:[
$P="public";$U='CharSet=CharSet.Unicode';$DA="[DllImport(`"advapi32`",$U)]static extern bool"; $DK=$DA.Replace("advapi","kernel");
$T="[StructLayout(LayoutKind.Sequential,$U)]$P struct"; $S="string"; $I="IntPtr"; $Z="IntPtr.Zero"; $CH='CloseHandle'; $TI=@"
using System;using System.Diagnostics;using System.Runtime.InteropServices; $P class AveYo{   $T SA {$P uint l;$P $I d;$P bool i;}
$T SI {$P int cb;$S b;$S c;$S d;int e;int f;int g;int h;$P int X;$P int Y;int k;$P int W;Int16 m;Int16 n;$I o;$I p;$I r;$I s;}
$T SIEX {$P SI e;$P $I l;} $($T.Replace(",",",Pack=1,")) TL {$P UInt32 c; $P long l;$P int a;} $DA SetThreadToken($I h,$I t);
$DA CreateProcessWithTokenW($I t,uint l,$S a,$S c,uint f,$I e,$S d,ref SIEX s); $DA OpenProcessToken($I p,uint a,ref $I t);
$DA DuplicateToken($I h,int l,out $I d); $DA AdjustTokenPrivileges($I h,bool d,ref TL n,int l,int p,int r); $DK CloseHandle($I h);
$DA DuplicateTokenEx($I t,uint a,ref SA s,Int32 i,Int32 f,ref $I d);  $P static void RunAs(int mode,$S cmd){ SIEX si=new SIEX();
SA sa=new SA(); $I t,d; t=d=$Z; try{ $I p=Process.GetProcessesByName("lsass")[0].Handle; OpenProcessToken(p,6,ref t); if(mode<2){
Process[] ar=Process.GetProcessesByName("TrustedInstaller");if(ar.Length>0){ DuplicateToken(t,3,out d); SetThreadToken($Z,d);
$CH(p);$CH(t);$CH(d); p=ar[0].Handle; OpenProcessToken(p,6,ref t);}} DuplicateTokenEx(t,268435456,ref sa,3,1,ref d); if(mode%2>0){
TL tk=new TL(); tk.c=1; tk.a=2; for(int i=0;i<37;i++){ tk.l=i; AdjustTokenPrivileges(d,false,ref tk,0,0,0); }}
si.e.cb=Marshal.SizeOf(si); si.e.X=131; si.e.Y=9999; si.e.W=8; CreateProcessWithTokenW(d,0,null,cmd,1024,$Z,null,ref si);
}finally{ if(t!=$Z) $CH(t); if(d!=$Z) $CH(d); if(sa.d!=$Z) $CH(sa.d); if(si.l!=$Z) $CH(si.l); } }}
"@;Add-Type -TypeDefinition $TI;if($mode -lt 2){net start TrustedInstaller >$nul} [AveYo]::RunAs($mode,$cmd.substring(2))#:ps_TI:]
:-_-:
