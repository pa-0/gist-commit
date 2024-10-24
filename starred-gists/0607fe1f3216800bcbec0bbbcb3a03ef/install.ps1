     # Self-elevate the script if required
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
     if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
      $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
      Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
      Exit
     }
    }

workflow IOOPM-Install {
    #
    # Download files
    #
    
    New-Item "$env:TEMP\ioopm" -Force -ItemType directory

    InlineScript {
        $powerline_url = "https://github.com/powerline/fonts/archive/master.zip"
        $powerline_output = "$env:TEMP\ioopm\powerline.zip"

        $ubuntu_url = "https://aka.ms/wsl-ubuntu-1804"
        $ubuntu_output = "$env:TEMP\ioopm\Ubuntu.appx"

        Import-Module BitsTransfer
        
        # Download and extract powerline fonts from repo
        Start-BitsTransfer -Source $powerline_url -Destination $powerline_output
        Expand-Archive -Force -Path $powerline_output -Destination "$env:TEMP\ioopm\powerline"

        # Download Ubuntu appx from Microsoft
        Start-BitsTransfer -Source $ubuntu_url -Destination $ubuntu_output
        
        # Download resume script (from gist)
        Start-BitsTransfer -Source "https://gist.githubusercontent.com/novium/fa877a4b2cd8013dfde2d8739a80bdcb/raw/ede86e2a6c9574f5f03e695ceb891390ac593f79/resume.ps1" -Destination "$env:TEMP\ioopm\resume.ps1"
    }

    #
    # Install
    #

    # Install powerline fonts
    Invoke-Expression "$env:TEMP\ioopm\powerline\fonts-master\install.ps1 DejaVu*"
    
    # Allows app sideloading (so that we can install the Ubuntu app
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowAllTrustedApps" /d "1"
    # Allows us to execute the resume-script
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

    # WSL (-NoRestart since ps workflows don't support user interaction)
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux
    Restart-Computer # Restart is required to continue
}

# Before we begin, remind user to exit everything
Write-Host
Write-Host "Remember to save and exit all your applications" -BackgroundColor DarkRed
Write-Host "Your computer will restart during the installation" -BackgroundColor DarkRed
Write-Host
Read-Host -Prompt "Press ENTER to continue"

# This is to resume the install after restart
# Check that task doesn't exist
Get-ScheduledTask -TaskName IOOPMInstallResume | Unregister-ScheduledTask -Confirm:$false
# Build the command to run powershell from a task
# We need it since a powershell job again doesn't allow user interaction
    $scriptPath = "$env:TEMP\ioopm\resume.ps1"
$actionscript = "-WindowStyle Normal -NoLogo -NoProfile -executionpolicy bypass -NoExit -file $scriptPath"
$pstart =  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$act = New-ScheduledTaskAction -Execute $pstart -Argument $actionscript
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName IOOPMInstallResume `
                      -RunLevel Highest `
                      -Trigger $trigger `
                      -Action $act `
                      -Force

# Install!
IOOPM-Install -JobName IOOPMInstall