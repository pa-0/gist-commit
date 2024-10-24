# TM-ProfileUtility Module

## Introduction
`TM-ProfileUtility` is a PowerShell module designed to provide various profile-related utility functions. 
Specifically this module is designed for use with my [PowerShell Profile](https://gist.github.com/tsmarvin/3ec5df59e030886a9f81a693ba01f785).  

This module is part of a suite of tools designed to improve and streamline the PowerShell commandline and scripting experience.  
Check out the rest of the modules by visiting [my page on the PowerShell Gallery](https://www.powershellgallery.com/profiles/tmarvin).  

## Features
- **Get-CurrentPath**: Retrieves the current path.
- **Get-LastExecutionDuration**: Gets the duration of the last executed command.
- **Get-PSProfileEditionString**: Determines the "plain english" PSEdition string.
- **Get-PSVersionString**: Determines the "plain english" PowerShell version string.
- **Get-ShellPath**: Creates a `.shell` directory in the users home and returns the directoryinfo object to the user.
- **Initialize-ProfileModule**: Attempts to import a module and will automatically install it if it doesn't exist.
- **New-UserProcessEnvVar**: Creates a new environment variable in the user and process scopes.
- **Set-ProfileLinks**: Consolidates all editions of your PowerShell profile by linking them to a common profile file.
- **Set-WindowTitle**: Sets the window title for the PowerShell window.
- **Test-Admin**: Tests if the current user has administrative privileges.
- **Update-ProfileScriptFromGist**: Updates the profile script from a GitHub Gist.

## Requirements
- Windows PowerShell 5.1+, or PowerShell Core 7+.
- Required modules: [TM-ValidationUtility](https://www.powershellgallery.com/packages/TM-ValidationUtility), [TM-RandomUtility](https://www.powershellgallery.com/packages/TM-RandomUtility), [TM-GitUtility](https://www.powershellgallery.com/packages/TM-GitUtility), and [TM-PSGitHubGistManagement](https://www.powershellgallery.com/packages/TM-PSGitHubGistManagement).

## Installation
Install `TM-ProfileUtility` from the [PowerShell Gallery](https://www.powershellgallery.com/packages/TM-ProfileUtility):
```powershell
Install-Module TM-ProfileUtility -Scope CurrentUser -Repository PSGallery
```

For manual installation, download the module files and place them in a "TM-ProfileUtility" folder in your PowerShell modules directory (`$Env:PSModulePath`).
