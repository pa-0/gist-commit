# How do I download URL content using Get-Content in PowerShell Script?
# Assumes that you have a URL on each line in C:\Urls.txt. It will put the files in a folder at C:\UrlOutput. If that’s not where you want them, just change the $OutputFolder variable value appropriately.

$Urls = Get-Content "C:\Urls.txt"
$OutputFolder = "C:\UrlOutput"
 
if(!(Test-Path $OutputFolder)){ New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null }
 
for ($x = 0; $x -lt ($Urls | measure | select -expand Count); $x++)
{
  $OutputPath = Join-Path $OutputFolder "$x.txt"
  Invoke-WebRequest $Urls[$x] | select -Expand Content | Set-Content $OutputPath -Force
}


# Invoke-WebRequest or create an Internet Explorer COM object and drive it like a human driven web browser.
# The latter may work better on difficult web sights that require human like interaction and JavaScript that you can’t bypass.

$webContent = Invoke-WebRequest -Uri 'Your URL'
$webContent.Content

# You can also use Credentials and Sessions if you want to.

# Also note Invoke-RestMethod.


To download files, remember Start-BitsTransfer:

Start-BitsTransfer -Source "URL" -Destination "D:\Temp"
