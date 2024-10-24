/* 2>nul || title FreeStandbyMemory.bat by AveYo v2018.10.12 final
@echo off|| UPDATE: now ultra fast at checking free ram! csc compiling snippet, advanced schedule, builtin add_remove

set/a CLEAR_EVERY_MINUTES=5
set/a CLEAR_WHEN_UNDER_MB=512
set/a CLEAR_SYSTEMCACHEWS=1

:: check_admin_rights
reg query "HKEY_USERS\S-1-5-20\Environment" /v TEMP >nul 2>nul || (
 color 0e & echo. & echo  PERMISSION DENIED! Right-click %~nx0 ^& Run as administrator
 timeout /t -1 & color 0f & title %COMSPEC% & exit/b
)

:: add_remove whenever script is run again
schtasks /query /tn FreeStandbyMemory >nul 2>nul && (
 echo.
 schtasks /Delete /TN "FreeStandbyMemory" /f 2>nul
 reg delete HKLM\Software\AveYo /v FreeStandbyMemory /f 2>nul
 del /f /q "%Windir%\FreeStandbyMemory.exe" 2>nul
 color 0b &echo. &echo REMOVED! Run script again to recompile and add schedule!
 timeout /t -1 &color 0f &title %COMSPEC% &exit/b
)

:: compile c# snippet
pushd %~dp0
del /f /q FreeStandbyMemory.exe >nul 2>nul
for /f "tokens=* delims=" %%v in ('dir /b /s /a:-d /o:-n "%Windir%\Microsoft.NET\Framework\*csc.exe"') do set "csc="%%v""
set "mmi=%Windir%\Microsoft.NET\assembly\GAC_MSIL\Microsoft.Management.Infrastructure"
for /f "tokens=* delims=" %%v in ('dir /b /s /a:-d /o:-n "%mmi%\*Microsoft.Management.Infrastructure.dll"') do set "mmi="%%v""
%csc% /out:FreeStandbyMemory.exe /target:winexe /platform:anycpu /optimize /nologo /reference:%mmi% "%~f0"
if not exist FreeStandbyMemory.exe echo ERROR! Failed compiling c# snippet & timeout /t -1 & exit /b
echo|set/p=FreeStandbyMemory.exe &copy /y FreeStandbyMemory.exe "%Windir%\FreeStandbyMemory.exe" &set "OUTDIR=%Windir%"
if not exist "%Windir%\FreeStandbyMemory.exe" echo WARNING! Cannot copy FreeStandbyMemory.exe to %Windir%\ &set "OUTDIR=%CD%"

:: setup advanced schedule - can afford higher priority after switching from wmi to winapi
set "task_run=%OUTDIR%\FreeStandbyMemory.exe %CLEAR_WHEN_UNDER_MB% %CLEAR_SYSTEMCACHEWS%"
set "schedule=/Create /RU "System" /NP /RL HIGHEST /F /SD "01/01/2001" /ST "01:00:00" "
schtasks %schedule% /SC MINUTE /MO %CLEAR_EVERY_MINUTES% /TN "FreeStandbyMemory" /TR "%task_run%"
set "sset=$s=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Priority 1 -StartWhenAvailable;"
set "stopexisting=$s.CimInstanceProperties['MultipleInstances'].Value=3;"
powershell -noprofile -c "%sset% %stopexisting% $null=Set-ScheduledTask -TaskName FreeStandbyMemory -Settings $s"

:: trigger task, force a manual clear and finish setup
schtasks /Run /TN "FreeStandbyMemory"
echo.
echo  Clearing StandbyMemory every %CLEAR_EVERY_MINUTES% minutes ONLY if available memory goes under %CLEAR_WHEN_UNDER_MB% MB
echo  Can force a clear manually from Command Prompt (Admin) by entering: freestandbymemory
echo.
echo ADDED! Run "%~nx0" again to remove compiled snippet and schedule!
timeout /t -1
exit /b

:: Based on idea from "PowerShell wrapper script for clear StandBy memory without RAMMap" by Alexander Korotkov
:: Implemented SetSystemFileCacheSize and NtSetSystemInformation suggestions by Maks.K
:: Using RtlAdjustPrivilege, GlobalMemoryStatusEx, force clear if no args, stripped output, sanitized by AveYo
*/
using System;
using System.Runtime.InteropServices;
using System.Reflection;

[assembly:AssemblyTitle("FreeStandbyMemory")]
[assembly:AssemblyCompanyAttribute("AveYo")]
[assembly:AssemblyVersionAttribute("2018.10.12")]

namespace FreeStandbyMemory
{
  class Program
  {
    const uint SE_INCREASE_QUOTA_PRIVILEGE = 0x00000005;
    const uint SE_PROF_SINGLE_PROCESS_PRIVILEGE = 0x0000000d;
    const int SystemFileCacheInformation = 0x0015;
    const int SystemMemoryListInformation = 0x0050;
    static int MemoryPurgeStandbyList = 0x0004;
    static bool retv = false;
    [DllImport("ntdll.dll")]
    static extern uint RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool RetValue);
    [DllImport("ntdll.dll")]
    static extern uint NtSetSystemInformation(int InfoClass, ref int Info, int Length);
    [DllImport("kernel32.dll")]
    static extern bool SetSystemFileCacheSize(IntPtr MinimumFileCacheSize, IntPtr MaximumFileCacheSize, int Flags);
    [return: MarshalAs(UnmanagedType.Bool)]
    [DllImport("kernel32.dll")]
    static extern bool GlobalMemoryStatusEx([In, Out] MEMORYSTATUSEX lpBuffer);
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    private class MEMORYSTATUSEX
    {
      public uint dwLength;
      public uint dwMemoryLoad;
      public ulong ullTotalPhys;
      public ulong ullAvailPhys;
      public ulong ullTotalPageFile;
      public ulong ullAvailPageFile;
      public ulong ullTotalVirtual;
      public ulong ullAvailVirtual;
      public ulong ullAvailExtendedVirtual;
      public MEMORYSTATUSEX()
      {
        this.dwLength = (uint)Marshal.SizeOf(typeof(MEMORYSTATUSEX));
      }
    }
    static void Main(string[] args)
    {
      UInt64 freemtarget = (args.Length == 0) ? UInt64.MaxValue : Convert.ToUInt64(args[0]) * 1024 * 1024;
      bool systemcachews = (args.Length == 0 || (args.Length >=2 && args[1] == "1"));
      try
      {
        MEMORYSTATUSEX memStatus = new MEMORYSTATUSEX();
        if (GlobalMemoryStatusEx(memStatus) && memStatus.ullAvailPhys > freemtarget) return;
        RtlAdjustPrivilege(SE_INCREASE_QUOTA_PRIVILEGE,      true, false, ref retv);
        RtlAdjustPrivilege(SE_PROF_SINGLE_PROCESS_PRIVILEGE, true, false, ref retv);
        if (systemcachews) SetSystemFileCacheSize(IntPtr.Subtract(IntPtr.Zero, 1), IntPtr.Subtract(IntPtr.Zero, 1), 0);
        NtSetSystemInformation(SystemMemoryListInformation, ref MemoryPurgeStandbyList, Marshal.SizeOf(MemoryPurgeStandbyList));
      }
      catch (Exception)
      {
      }
    }
  }
}
/*_*/
