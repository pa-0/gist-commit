
# UI Access (UIA)

## What's UI Access?

UIA is the way around UIPI **User Interface Privilege Isolation**[^1] which in simple terms is a way of bypassing the security built into Windows to avoid applications interacting with other applications that have a higher integrity level (security).

In other words, when you run a script it cannot communicate with the system or elevated (running as Administrator) processes; this is to avoid insecure and non-sanctioned interactions.

## Why would I want UIA?

Most of the time, by running a script elevated (as Admin) most restrictions will budge, but there are some that only by running the script with UIA can be bypassed.

Also, any process that doesn't ***forcefully need*** to run elevated shouldn't be elevated. This is true no matter the OS and/or user level of expertise.

Let's look at a simple example: the Windows 10 built-in volume OSD. In a blank script paste the following lines, run it normally, then elevated, and finally with UIA:

```ahk
DetectHiddenWindows On
hWnd := WinExist("ahk_class NativeHWNDHost")
PostMessage 0xC028, 0x000C, 0xA0000, , % "ahk_id" hWnd
Sleep 100
MsgBox 0x40040, OSD visible?, % DllCall("IsWindowVisible", "Ptr", hWnd) ? "Yes" : "No"
```

The first two attempts don't show the OSD, only with UIA is the OSD shown. Bear in mind that this is an over-simplistic example, but the idea is to show that running a script elevated is not a silver bullet.

## Caveats with UIA

In **documentation**[^2] there's a list of the scenarios where UIA might not be in the best interest of the user; that said, most users won't run into those issues as they are pretty particular.

I've managed to run a single AutoHotkey instance for years, but if you run into issues, you can run a regular instance of AutoHotkey and one with UIA.

## Pre-requisites

At install time, you need to enable the option:

![](https://i.imgur.com/ejk3oFj.png)

That later will present the option to run with UIA:

![](https://i.imgur.com/zg5QxyZ.png)

If you didn't enable it, reinstalling with this script will enable it:

```ahk
if (!A_IsAdmin) {
    Run % "*RunAs " A_ScriptFullPath
    ExitApp
}
if (!FileExist(A_Temp "\ahk-install.exe")) {
    UrlDownloadToFile https://www.autohotkey.com/download/ahk-install.exe
        , % A_Temp "\ahk-install.exe"
}
cmd := "timeout /t 1"
    . " & taskkill /F /IM AutoHotkey*.exe"
    . " & ahk-install.exe /S /uiAccess=1" (A_Is64bitOS ? " /U64" : "")
    . " & del ahk-install.exe"
Run % A_ComSpec " /C """ cmd """", % A_Temp
```

## Automation via code

If you don't want to always right-click a script and select the UIA option, you can add this fragment of code at the top of your script to restart it in UIA mode:

```ahk
#SingleInstance Force
if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
    Run % "*uiAccess " A_ScriptFullPath
    ExitApp
}
```

For a more fine-grained control over the bitness of the interpreter, change the line:

```ahk
Run % "*uiAccess " A_ScriptFullPath
```

For:

```ahk
newPath := RegExReplace(A_AhkPath, "(U\d+)?\.exe", "U" (A_Is64bitOS ? 64 : 32) "_UIA.exe")
Run % StrReplace(DllCall("GetCommandLine", "Str"), A_AhkPath, newPath)
```

This part: `A_Is64bitOS ? 64 : 32`, selects the 64bit executable on Windows x64. You can change it to `A_PtrSize * 8` to match the bitness you defaulted at install time (useful when you chose the **32bit**[^3] version on x64 OS).

[^1]: https://en.wikipedia.org/wiki/User_Interface_Privilege_Isolation
[^2]: https://www.autohotkey.com/docs/Program.htm#Installer_uiAccess
[^3]: https://i.imgur.com/54aQ8BG.png


>[!Tip] 
>**For `.ShellExecute()` Commands:**
>Please, checkout this post: [redd.it/v8c9x0](https://redd.it/v8c9x0). In there you'll find the `.ShellExecute()` implementation by Lexikos and the shorthand I use alongside an explanation for the arguments.
>
>*Example:*
> ```ahk
> RunAs_general("cmd.exe",, "D:")
> 
> RunAs_general(exe:="", arg:="", workdir:="") {  
>    ShellExecute(exe, arg, workdir)  
> }
>
> ShellExecute(Parameters*) {  
>    ComObjCreate("Shell.Application")  
>    .Windows  
>    .FindWindowSW(0, 0, 8, 0, 1)  
>    .Document  
>    .Application  
>    .ShellExecute(Parameters*)
>  }
> ```
>
><br/>
>
> **More on Shell Execute:**
>
> [Microsoft Learn | `ShellExecute` (win32/shell/shell-shellexecute)](https://learn.microsoft.com/en-us/windows/win32/shell/shell-shellexecute)

#### References
