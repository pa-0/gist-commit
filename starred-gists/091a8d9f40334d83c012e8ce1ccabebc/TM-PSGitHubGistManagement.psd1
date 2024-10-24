@{
# Script module or binary module file associated with this manifest.
RootModule = 'TM-PSGitHubGistManagement.psm1'

# Version number of this module.
ModuleVersion = '0.0.6'

# Supported PSEditions
CompatiblePSEditions = @('Desktop','Core')

# ID used to uniquely identify this module
GUID = '429cacf0-6b52-4e7c-a86a-ddbb7fae4b88'

# Author of this module
Author = 'Taylor Marvin'

# Company or vendor of this module
CompanyName = 'N/A'

# Copyright statement for this module
Copyright = 'Taylor Marvin (2023)'

# Description of the functionality provided by this module
Description = 'Provides github "gist" related utility functions.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(@{ModuleName='TM-ValidationUtility'; ModuleVersion='0.0.4'; GUID='1f1eebe8-7a0b-49ae-901e-c877f090a7fc'})

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-GistScript',
    'Update-GistScript',
    'Start-BackgroundGistScriptUpdate'
)

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Profile', 'GitHub', 'Gist')

        # A URL to the license for this module.
        LicenseUri = 'https://gist.github.com/tsmarvin/c28208e85409e914c7009c336d123a71#file-license'

        # A URL to the main website for this project.
        ProjectUri = 'https://gist.github.com/tsmarvin/c28208e85409e914c7009c336d123a71'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false
    }
}

}
