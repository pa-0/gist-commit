# File Organizer Script
## Overview
This PowerShell script helps organize files in the "Downloads" folder by grouping them based on their file extensions.:
1. It creates subfolders for each file extension in a specified destination folder.
2. Checks for existing folders.
3. And moves files to their respective extension folders.
4. Additionally, the script ensures that files with the same name are renamed to prevent overwriting.

## How to Use
1. Create a file and copy the script in OrganizeDownloads.ps1 to it:
2. Right-click the script filename and then select Run with PowerShell.

### Or
1. Copy the script in OrganizeDownloads.ps1
2. Open PowerShell and paste (it will run)

## Important Notes
The script assumes the "Downloads" folder as the source directory and destination folder. \
The script can be scheduled to run at intervals using the Windows Task Scheduler.