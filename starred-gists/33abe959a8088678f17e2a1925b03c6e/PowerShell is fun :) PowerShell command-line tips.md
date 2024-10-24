# PowerShell is fun :) PowerShell command-line tips

1. Count the number of items found.
2. Finding the cmdlet that you need.
3. Display your command-line history.
4. Searching your command-line history.
5. Keep running a command until pressing CTRL-C/Break.
6. Use Out-GridView to display and filter results.

# Count the number of items found

When searching for items, users, or folders, for example, you sometimes just need to count them. You can copy/paste the results in notepad and see how many lines but you can also use this

```PowerShell
C:\Users\HarmV> (Get-ChildItem -Path c:\temp -Filter *.exe -Recurse).count
39
```

You can wrap your command with parentheses and use the  ‘(‘ and ‘)’  signs around it and add ".count" behind it. This way the output will not be shown on screen but it will just show you the amount found

# Finding the cmdlet that you need

Sometimes you want to search for a cmdlet, but you're not sure if it exists or how it's formatted, you can search for it using

```PowerShell
C:\Users\HarmV> Get-Help *json*
Name Category Module Synopsis
---- -------- ------ --------
ConvertFrom-Json Cmdlet Microsoft.PowerShell.Uti… …
ConvertTo-Json Cmdlet Microsoft.PowerShell.Uti… …
Test-Json Cmdlet Microsoft.PowerShell.Uti… …
ConvertTo-AutopilotConfiguration… Function WindowsAutoPilotIntune …
Write-M365DocJson Function M365Documentation …
Update-M365DSCExchangeResourcesS… Function Microsoft365DSC …
New-M365DSCConfigurationToJSON Function Microsoft365DSC …
Update-M365DSCSharePointResource… Function Microsoft365DSC …
Update-M365DSCResourcesSettingsJ… Function Microsoft365DSC …
C:\Users\HarmV> Get-Help *json* Name Category Module Synopsis ---- -------- ------ -------- ConvertFrom-Json Cmdlet Microsoft.PowerShell.Uti… … ConvertTo-Json Cmdlet Microsoft.PowerShell.Uti… … Test-Json Cmdlet Microsoft.PowerShell.Uti… … ConvertTo-AutopilotConfiguration… Function WindowsAutoPilotIntune … Write-M365DocJson Function M365Documentation … Update-M365DSCExchangeResourcesS… Function Microsoft365DSC … New-M365DSCConfigurationToJSON Function Microsoft365DSC … Update-M365DSCSharePointResource… Function Microsoft365DSC … Update-M365DSCResourcesSettingsJ… Function Microsoft365DSC …
C:\Users\HarmV> Get-Help *json*

Name                              Category  Module                    Synopsis
----                              --------  ------                    --------
ConvertFrom-Json                  Cmdlet    Microsoft.PowerShell.Uti… …
ConvertTo-Json                    Cmdlet    Microsoft.PowerShell.Uti… …
Test-Json                         Cmdlet    Microsoft.PowerShell.Uti… …
ConvertTo-AutopilotConfiguration… Function  WindowsAutoPilotIntune    …
Write-M365DocJson                 Function  M365Documentation         …
Update-M365DSCExchangeResourcesS… Function  Microsoft365DSC           …
New-M365DSCConfigurationToJSON    Function  Microsoft365DSC           …
Update-M365DSCSharePointResource… Function  Microsoft365DSC           …
Update-M365DSCResourcesSettingsJ… Function  Microsoft365DSC           …

```

By using the Get-Help cmdlet you can search using wildcard through all your installed modules, it will show you if it's a cmdlet or a function and in which module it's present

# Display your command-line history

You can browse through your previous commands using the up-and-down arrow, but you can also show it using:

```PowerShell
C:\Users\HarmV> get-history
1 2.910 Get-ChildItem -Path c:\temp -Filter *.exe -Recurse
2 0.172 (Get-ChildItem -Path c:\temp -Filter*.exe -Recurse).count
C:\Users\HarmV> get-history Id Duration CommandLine -- -------- ----------- 1 2.910 Get-ChildItem -Path c:\temp -Filter *.exe -Recurse 2 0.172 (Get-ChildItem -Path c:\temp -Filter*.exe -Recurse).count 3 0.036 Get-History 4 3.396 help *history* 5 1.116 help *json* 6 1.190 Get-Help *json*
C:\Users\HarmV> get-history

  Id     Duration CommandLine
  --     -------- -----------
   1        2.910 Get-ChildItem -Path c:\temp -Filter *.exe -Recurse
   2        0.172 (Get-ChildItem -Path c:\temp -Filter*.exe -Recurse).count
   3        0.036 Get-History
   4        3.396 help *history*
   5        1.116 help *json*
   6        1.190 Get-Help *json*
```

But that's just the history from your current session, the complete command-line history is saved in your profile in a text file. You can retrieve the path by using:

```PowerShell
C:\Users\HarmV> Get-PSReadLineOption | Select-Object HistorySavePath
C:\Users\HarmV\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
C:\Users\HarmV> Get-PSReadLineOption | Select-Object HistorySavePath HistorySavePath --------------- C:\Users\HarmV\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
C:\Users\HarmV> Get-PSReadLineOption | Select-Object HistorySavePath

HistorySavePath
---------------

C:\Users\HarmV\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```

In this text file, you will find the complete history of every command you entered, my file is 14921 lines long

Searching your command-line history
In the chapter above I showed you how to retrieve your history. If you want to search your history without opening the text file, you can use CTRL+R and start typing a part of the command that you are searching for:

```PowerShell
C:\Users\HarmV> foreach ($line in $csv){
>> $groupname = $line.GroupName
>> $objectid = (Get-AzureADGroup | Where-Object {$_.DisplayName -eq $groupname}).ObjectId
>> Get-AzureADGroupMember -ObjectId $objectid | select DisplayName,UserPrincipalName | Export-Csv -Path "C:\Temp\Groups\testmembers.csv" -NoTypeInformation -Append
>> }
bck-i-search: get-azureadgroupm_
```

I started typing “Get-Azureadgroupm” and it retrieve it from my command-line history and it highlights the part found.

# Keep running a command until pressing CTRL-C/Break
I'm a bit impatient sometimes and want to check a status a lot but don’t want to repeat the same command the whole time, you can use a while $true loop to keep on executing a command until you stop it by typing CTRL-C. For example:

```PowerShell
while ($true) {
Clear-Host
Get-Date
Get-MoveRequest | Where-Object {$_.Status -ne "Suspended" -and $_.Status -ne "Failed"}
Start-Sleep -Seconds 600
}
```

In this example, the screen is cleared, and the date is shown so that you know from what timestamp the Get-MoveRequest (Exchange migration cmdlet) is. It will wait 10 minutes and keep on repeating the steps until you type CTRL-C to break it. You can use any command between the curly brackets and interval time you want.

# Use Out-GridView to display and filter results
If PowerShell_ISE is installed on your system you can use the Out-GridView cmdlet to output results in a pop-up window with a filter field. You can do this by running:

```PowerShell
Get-ChildItem -Path c:\temp -Recurse | Out-GridView
```

This will output all files in c:\temp and you can then filter the results by typing a few letters of the word you want to search for.
