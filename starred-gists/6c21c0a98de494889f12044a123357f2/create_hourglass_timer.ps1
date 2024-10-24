# Creates a new timer in Hourglass Timer 1.1 using Powershell
# This simple script can run on any modern Windows OS.
# Version: 1.0b
# Author: Deanoman
# Source App: http://chris.dziemborowicz.com/apps/hourglass/

# (Powershell is installed by default on Windows Server 2012 R2, Windows 8, 8.1, 10)
# Powershell Requirements: https://technet.microsoft.com/en-au/library/hh847769.aspx

# 1) The title/name of the timer
$title = 'title'
# 2) The duration of the timer (value)
$timevalue = '1h'
# 3) The color for the progress status
# Allowed Colors: red, orange, yellow, green, blue, purple, gray or black 
$color = 'orange'
# 4A) The full path of the Hourglass .EXE (set once)
$process = 'C:\PortableApps\PortableApps\Hourglass Timer\HourglassPortable.exe'

# Run command with arguments
$args = '--title "'+$title+'" --color "'+$color+'" "'+$timevalue+'"'
Start-Process $process -ArgumentList $args
#Write-Host $args

Write-Host
$message = 'Created New Timer: "'+$title+'" for '+$timevalue
Write-Host $message -ForegroundColor Yellow