# TM-PSGitHubGistManagement Module

## Introduction
`TM-PSGitHubGistManagement` is a PowerShell module that provides GitHub Gist-related utility functions. It allows you to download a script hosted in a gist, as well as allowing you to update it again from that gist later.  

This module is part of a suite of tools designed to improve and streamline the PowerShell commandline and scripting experience.  
Check out the rest of the modules by visiting [my page on the PowerShell Gallery](https://www.powershellgallery.com/profiles/tmarvin).  

## Features
- **Get-GistScript**: Retrieves scripts from a Gist.
- **Update-GistScript**: Updates the content of a Gist script.
- **Start-BackgroundGistScriptUpdate**: Initiates a background process to update a Gist script.

## Requirements
- Windows PowerShell 5.1+, or PowerShell Core 7+.
- Required module: [TM-ValidationUtility](https://www.powershellgallery.com/packages/TM-ValidationUtility).

## Installation
Install `TM-PSGitHubGistManagement` from the [PowerShell Gallery](https://www.powershellgallery.com/packages/TM-PSGitHubGistManagement):
```powershell
Install-Module TM-PSGitHubGistManagement -Scope CurrentUser -Repository PSGallery
```

For manual installation, download the module files and place them in a "TM-PSGitHubGistManagement" folder in your PowerShell modules directory (`$Env:PSModulePath`).
