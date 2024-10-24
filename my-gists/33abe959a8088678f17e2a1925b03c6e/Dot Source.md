# what is dot-sourcing in Powershell

<https://dotnet-helpers.com/powershell/what-is-dot-sourcing-in-powershell/>

Dot-sourcing is a concept in PowerShell that allows you to reference code defined in one script.

When you writing large size of PowerShell scripts, then there always seems to come a time when a single script just isn’t enough.  If we working on large size of script then it important to keep your scripts Simple and Reusable, so you can keep your block of script as modular. The Dot-sourcing is a way to do just that. Making script as modular it also useful when requirment came for adding some more functionlaiyt in exting script. Other than building a module, dot-sourcing is a better way to make that code in another script available to you.

For example, let’s say I’ve got a script that has two functions in it. We’ll call this script CommunicateUser.ps1. Here i had created single module which contain the two functionality in single file which used for sending email and SMS to the customer.

```powershell
function SendEmail {
param($EmailContent)
#Write your Logic here
Write-Output "****************************************"
Write-Output "Sending Mail" $EmailContent
Write-Output "****************************************"
}`
function SentSMS {
param($SMSContent)
#Write your Logic here
Write-Output "****************************************"
Write-Output "Sending SMS" $SMSContent
Write-Output "****************************************"
}
```

```powershell
# Script-file JustAtest.ps1 with function

 function ABCDE{
     [CmdletBinding()]
     param (
         $ComputerName
     )
     Write-Output $ComputerName
 }

# Script Call-Script.ps1 calling another script "JustAtest.ps1" in the same folder

# relative path

 .\JustAtest.ps1
 ABCDE -ComputerName Computer12

# fullpath

 C:\Junk\JustAtest.ps1
 ABCDE -ComputerName Computer13

# fullpath

 & "C:\Junk\JustAtest.ps1"
 ABCDE -ComputerName Computer14

# fullpath

 . "C:\Junk\JustAtest.ps1"
 ABCDE -ComputerName Computer15
```
