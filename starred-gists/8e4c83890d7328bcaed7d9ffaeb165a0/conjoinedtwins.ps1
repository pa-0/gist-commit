# Conjoined Twins
# IFTTT-style application actions using auditing and scheduled tasks under Windows

#TODO: Do something about Write-Host and Read-Host
#TODO: Write output for file selection and auditing setting

Function Get-FileName($initialDirectory, $Title) {
  [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.Title = $Title
  $OpenFileDialog.initialDirectory = $initialDirectory
  $OpenFileDialog.filter = "Executable Files(*.exe;*.bat;*.cmd)|*.exe;*.bat;*.cmd|All files (*.*)|*.*"
  $OpenFileDialog.ShowHelp = $true # Without ShowHelp set to true the dialog doesn't show up!
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.filename
} #end function Get-FileName

Function Audit-Executable($File) {
  if($File) {
    $AuditUser = "$env:UserName" # or "Everyone"
    $AuditRules = "ExecuteFile" 
    $AuditType = "Success"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$AuditType)

    $ACL = Get-Acl $File
    $ACL.SetAuditRule($AccessRule)
    $ACL | Set-Acl $File

    # Show the new auditing settings to confirm
    # Get-Acl -Audit $File | Select -Expand Audit
  }
} #end function Audit-Executable

# Choose trigger application to watch
$triggerapp = Read-Host "Select trigger application to watch... `n[Press Enter to browse]"
if(!$triggerapp) {
  $triggerapp = Get-FileName -initialDirectory "D:\Demo" -Title "Select trigger application to watch..."
}
if($triggerapp) { Write-Host "`n$triggerapp is the trigger`n" }
else { Exit }

# Audit ExecuteFile on trigger application executable
Audit-Executable($triggerapp)

# Craft XPath Query for scheduled task trigger
$triggerquery = "*[System[(EventID=4663)]] and *[EventData[Data[@Name='ObjectName'] and (Data='$triggerapp')]]"

# Choose action to run conjoined with trigger app
$action = Read-Host "Select action to run... `n[Press Enter to browse]"
if(!$action) {
  $action = Get-FileName -initialDirectory $env:SystemRoot\system32 -Title "Select action to run..."
}
if($action) { Write-Host "`n$action is the action `n" }

if($triggerapp -and $action) { 
  # Ask user for task name. No description param in schtasks :(
  $taskname = Read-Host -Prompt "Name the scheduled task" 
  
  # Register scheduled task, via http://serverfault.com/a/533660
  schtasks /Create /TN $taskname /TR $action /SC ONEVENT /EC Security /MO $triggerquery
}
