@{
# Script module or binary module file associated with this manifest.
RootModule = 'TM-ProfileUtility.psm1'

# Version number of this module.
ModuleVersion = '0.0.14'

# Supported PSEditions
CompatiblePSEditions = @('Desktop','Core')

# ID used to uniquely identify this module
GUID = '82c4123f-77ae-497f-849c-a9a549d42984'

# Author of this module
Author = 'Taylor Marvin'

# Company or vendor of this module
CompanyName = 'N/A'

# Copyright statement for this module
Copyright = 'Taylor Marvin (2023)'

# Description of the functionality provided by this module
Description = 'Provides various profile related utilty functionality.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    @{ModuleName='TM-PSGitHubGistManagement'; ModuleVersion='0.0.6'; GUID='429cacf0-6b52-4e7c-a86a-ddbb7fae4b88'},
    @{ModuleName='TM-RandomUtility'; ModuleVersion='0.0.7'; GUID='c07a9da5-9562-42b6-8aba-1279fdb25a8e'},
    @{ModuleName='TM-GitUtility'; ModuleVersion='0.0.7'; GUID='a0331b25-5435-4ee7-9638-6729d75afe88'},
    @{ModuleName='TM-ValidationUtility'; ModuleVersion='0.0.4'; GUID='1f1eebe8-7a0b-49ae-901e-c877f090a7fc'}
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-CurrentPath',
    'Get-LastExecutionDuration',
    'Get-PSProfileEditionString',
    'Get-PSVersionString',
    'Get-ShellPath',
    'Initialize-ProfileModule',
    'New-UserProcessEnvVar',
    'Set-ProfileLinks',
    'Set-WindowTitle',
    'Test-Admin',
    'Update-ProfileScriptFromGist'
)

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Profile', 'Utility')

        # A URL to the license for this module.
        LicenseUri = 'https://gist.github.com/tsmarvin/fe2d09ed245e6951f77937febfe5bba9#file-license'

        # A URL to the main website for this project.
        ProjectUri = 'https://gist.github.com/tsmarvin/fe2d09ed245e6951f77937febfe5bba9'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false
    }
}

}
