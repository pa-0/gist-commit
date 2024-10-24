**Update**: I updated the code below so it works correctly when there are spaces in the path or script name. Thanks to Pat Richard for performance and deprecation improvements.  
  
Most of the scripts I write require elevation -- they must be run from an elevated PowerShell prompt because they make changes to Windows that require Administrator access. The following code snippet will self-elevate a PowerShell script with this added to the beginning of the script. I honestly can't remember where I found the original code, but I updated it to work with Windows 10 and Windows Server 2016 and later build numbers.  
  
**Of course, you should ALWAYS confirm that your script is running properly before allowing it to self-elevate.** I take no responsibility for the scripts that run using this code.  

Simply add this snippet at the beginning of a script that requires elevation to run properly. It works by starting a new elevated PowerShell window and then re-executes the script in this new window, if necessary. If User Account Control (UAC) is enabled, you will get a UAC prompt. If the script is already running in an elevated PowerShell session or UAC is disabled, the script will run normally. This code also allows you to right-click the script in File Explorer and select "Run with PowerShell".  
  
Here's how it works:

```powershell
# 1. Checks if pwsh is running elevated e.g., pwsh was run as admin or UAC was disabled. If so, script runs uninterrupted
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    # 2. Checks if Windows OS build >= 6000 (Windows Vista) - earlier builds do not support RunAs flag
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        # 3. Retrieves the command that ran the original script, including any arguments.
        $CommandLine = $MyInvocation.UnboundArguments
        # 4. Starts new elevated pwsh process and runs the script again there. Once script terminates, elevated pwsh window is closed
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}
```

Url: https://blog.expta.com/2017/03/how-to-self-elevate-powershell-script.html