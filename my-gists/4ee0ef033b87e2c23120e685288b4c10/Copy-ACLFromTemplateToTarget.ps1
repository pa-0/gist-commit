
<#
.SYNOPSIS
To add the File Shares Operators in the ACL with the template permissions on a single directory

.DESCRIPTION
Ce script ajoute l'entrée pour le groupe 'File Shares Operators'(ou le groupe spécifié) dans les ACL du répertoire choisi
afin que celui-ci puis gérer les permissions sans lire le contenu.
This Script adds ACEs that allows a FileSharesOperators Group to manages the ACL on the directory without allowing
the group to read the content of files.

Le script va copier les entrée du groupe du répertoire "Template" sur le répertoire "Target"
This script copies the ACEs on the "Template" directory on the "Target" directory

Use `-Help` for the full Help

.PARAMETER Help
Gets the full help

.PARAMETER Wizard
Executes with the wizard, using defaults (unless you specify) and using a form to select the target directory.

.PARAMETER Group
The group to look for in the Template ACL
Default: "CONTOSO\File Shares Operators"

.PARAMETER TemplatePath
The Path to use as Template
Default: "\\localhost\datatemplate$"

.PARAMETER TargetDirectoryPath
This is where you want the ACE added. This parameter is not compatible with -Wizard
If the path specified is not accessible, the script will fail.

.PARAMETER Depth
Recursive Depth. This will also apply on the descendant that don't inherit
Default: 0

Max recommended : 3

.PARAMETER IgnoreBackupFailure
Switch to ignore a Backup File failure. Be sure of what you're doing!!

.INPUTS
None

.OUTPUTS
BackupObject File. Use `Import-CLIXML and Get-Member` to explore it

.EXAMPLE
PS> .\Copy-ACLFromTemplateToTarget.ps1 -Wizard

This will run the script with the defaults parameters.

.NOTES

This script has been made to run inside the "Template" directory, in a subfolder called "ACLScript"
There is one hard-coded value, but it is not 100% necessary to be accessible.
`$sharedBackupDir = Join-Path -Path $TemplatePath -ChildPath "ACLScript\acl_backups"`

The idea is that the script could be called by multiple operators at different times, and all the backups would end up at the same place.



#>

[CmdletBinding(DefaultParameterSetName = "Help")]
param (
    [Parameter(ParameterSetName = "Help")]
    [switch]
    $Help,

    # Wizard Switch
    [Parameter(ParameterSetName = "Wizard")]
    [switch]
    $Wizard,

    # Template Path for ACL
    [Parameter(ParameterSetName = "SpecifyTarget")]
    [Parameter(ParameterSetName = "Wizard")]
    [string]
    $TemplatePath = "\\localhost\datatemplate$",

    # Group on the ACL to copy
    [Parameter(ParameterSetName = "SpecifyTarget")]
    [Parameter(ParameterSetName = "Wizard")]
    [string]
    $Group = "CONTOSO\File Shares Operators",

    [Parameter(ParameterSetName = "SpecifyTarget")]
    [string]
    $TargetDirectoryPath,

    # Ignore Backup Failure
    [Parameter(ParameterSetName = "Wizard")]
    [Parameter(ParameterSetName = "SpecifyTarget")]
    [switch]
    $IgnoreBackupFailure,

    # Depth
    [Parameter(ParameterSetName = "Wizard")]
    [Parameter(ParameterSetName = "SpecifyTarget")]
    [int]
    $Depth = 0
)


begin {
    #region Function Declarations

    function Get-DescendantNotInheritingACL {
        [CmdletBinding()]
        param (
            # Depth
            [Parameter()]
            [int]
            $Depth = 2,

            # Target Path
            [Parameter(Mandatory)]
            [string]
            $TargetDirectoryPath

            # Operation Reference
            #[Parameter(Mandatory)]
            #[ref]
            #$Operation
        )
        
        begin {
            
        }
        
        process {
            # $folders = [System.Collections.Generic.List[PSObject]]@()
            $getChildItemSplat = @{
                Path = $TargetDirectoryPath
                Recurse = $true
                Depth = $Depth
                Directory = $true
            }
            Get-ChildItem @getChildItemSplat | ForEach-Object {
                $item = Get-Item -PSPath $_.PSPath
                $curACL = Get-Acl -Path $item.PSPath
                if ($curACL.AreAccessRulesProtected) {
                    # inheritance is blocked
                    $item
                    # $Operation.Value.AddTargetPath($item)
                    Write-Verbose -Message $("{0} -> ACL Not inherited, we need to update them" -f $item.FullName)
                } else {
                    Write-Verbose -Message $("{0} -> ACL inherited, no need to update them" -f $item.FullName)
                }
            }
        }
        
        end {
        }
    }

    function Add-TemplateACEToTarget {
        [CmdletBinding()]
        param (
            # Template ACE
            [Parameter(ValueFromPipeline)]
            [System.Security.AccessControl.FileSystemAccessRule]
            $TemplateACE,

            # Current Target Directory
            [Parameter(Mandatory)]
            [string]
            $CurrentTargetDirectory
        )
        
        begin {
            Write-Verbose -Message $("Getting the ACL of {0}" -f $CurrentTargetDirectory)
            $TargetACL = Get-Acl -Path $CurrentTargetDirectory
        }
        
        process {
            foreach ($curACE in $TemplateACE) {
                Write-Verbose $("Giving {0} to {1}, based on {2}" -f $curACE.FileSystemRights, $curACE.IdentityReference, $curACE.InheritanceFlags)
                $TargetACL.AddAccessRule($curACE)
            }
        }
        
        end {
            Write-Verbose -Message $("Setting the ACL on {0}`n`r" -f $CurrentTargetDirectory)
            $TargetACL | Set-ACL -Path $CurrentTargetDirectory
        }
    }

    function Write-ACLOpBackupObjFile {
        [CmdletBinding()]
        param (
            # BackupObject
            [Parameter(Mandatory)]
            [PSOBject]
            $Operation
        )
        
        begin {
        }
        
        process {
            try {

                $BackupFilePath = $Operation.BackupPath + ".xml"

                $exportClixmlSplat = @{
                    Path = $BackupFilePath
                    InputObject = $Operation
                    Depth = 4
                    Verbose = $false
                }

                Export-Clixml @exportClixmlSplat 4> $null # Redirection of the VerboseStream because there are some weird CIM calls that are verbose in there.

                
                Write-Information $("BackupObject written to {0}" -f $BackupFilePath) -InformationAction Continue

            } catch {
                if (-not $ignoreBackupFailure) {
                Write-Error "Could not write backup file, critical error" -ErrorAction Stop
                }
            }
            if ($isLocalBackupDir){
                $exportClixmlSplat.Path = Join-Path -Path $env:TMP -ChildPath $($Operation.Name + ".xml")
                Write-Verbose -Message $("Local Backup written to: {0}" -f $exportClixmlSplat.Path)
                Export-Clixml @exportClixmlSplat
            }
        }
        
        end {
            
        }
    }

    function New-Operation {
        param (
            $TargetDirectory,
            $Depth = 0,
            $TemplatePath,
            $TemplateACEs,
            $Group,
            # Backup Path
            [Parameter(Mandatory)]
            [string]
            $BackupPath
        )

        

        $Obj = [PSCustomObject]@{
            Name = $("{0}_{1}" -f (Get-Date -Format 'FileDateTime'), $TargetDirectory.Name)
            TopTargetDir = $TargetDirectory.FullName
            Depth = $Depth
            TemplatePath = $TemplatePath
            TemplateACEs = $TemplateACEs
            Group = $Group
            Targets = [System.Collections.Generic.List[PSObject]]@()
        }

        $addBackupPathMemberSplat = @{
            MemberType = 'NoteProperty'
            Name = 'BackupPath'
            Value = $(Join-Path -Path $BackupPath -ChildPath $Obj.Name)
            PassThru = $true
        }

        $addAddTargetPathMemberSplat = @{
            MemberType = 'ScriptMethod'
            Name = 'AddTargetPath'
            Value = {
                    param (
                        $Path
                    )
                    $acl = Get-ACL -Path $Path
                    $o = [pscustomobject]@{
                        Path = $Path
                        PreviousACL = $acl
                    }
                    Write-Verbose -Message $("Adding {0}" -f $Path)
                    $this.Targets.Add($o)
            }
            PassThru = $true
        }
        $Obj = $Obj | Add-Member @addAddTargetPathMemberSplat | Add-Member @addBackupPathMemberSplat
        $Obj.AddTargetPath($TargetDirectory)
        $Obj
    }
    #endregion

    switch ($PSCmdlet.ParameterSetName) {
        "Help" { 
            Write-Verbose "Getting help"
            if ($Help.IsPresent) {
                Get-Help -Name $MyInvocation.MyCommand.Path -Full
            } else {
                Get-Help -Name $MyInvocation.MyCommand.Path
            }
        }
    }

    #region Variables

    #endregion



}

process {
    if ($PSCmdlet.ParameterSetName -ne "Help") {

        $TemplateACEs = (Get-Acl -Path $TemplatePath).Access.Where({$_.Identityreference -eq $group})
        Write-Verbose -Message $("Found {0} template ACEs" -f $TemplateACEs.Count)

        #region BackupDir

        $sharedBackupDir = Join-Path -Path $TemplatePath -ChildPath "ACLScript\acl_backups"
        $isLocalBackupDir = $false
        $BackupDir = if (Test-Path $sharedBackupDir) { 
            $sharedBackupDir 
            Write-Verbose -Message $("We will be using the shared backtup Directory since it is available at {0}" -f $sharedBackupDir)
        } else { 
            Write-Warning -Message $("{0} isn't available, using current Desktop for the backup ACL file" -f $sharedBackupDir)
            $isLocalBackupDir = $true
            Join-Path -Path $env:USERPROFILE -ChildPath "Desktop" 
        }        
        #endregion

        $TargetDirectory = switch ($PSCmdlet.ParameterSetName) {
            "Wizard" { 
                
                Write-Information "Select the directory where we need to add the ACE for File Shares Operators" -InformationAction Continue

                Add-Type -AssemblyName 'System.Windows.Forms'
                $dialog = New-Object System.Windows.Forms.FolderBrowserDialog

                if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $directoryName = $dialog.SelectedPath
                    Write-Information "Directory selected is $directoryName" -InformationAction Continue
                } else {
                    Write-Error "please select a path next time" -ErrorAction Stop
                }
                Get-Item -path $directoryName
            }
            "SpecifyTarget" { 
                if (Test-Path $TargetDirectoryPath) {
                    Get-Item $TargetDirectoryPath
                }
            }
            Default {}
        }
        Write-Verbose -Message $("Target Directory: {0}" -f $TargetDirectory.FullName)

        $newOperationSplat = @{
            TargetDirectory = $TargetDirectory
            Depth = $Depth
            TemplatePath = $TemplatePath
            TemplateACEs = $TemplateACEs
            Group = $Group
            BackupPath = $BackupDir
        }
        $Operation = New-Operation @newOperationSplat
        Write-Verbose -Message "Operation Prepared"

        if ($Depth -ge 1) {
            Write-Verbose "Recursive targets"
            Get-DescendantNotInheritingACL -Depth $Depth -TargetDirectoryPath $TargetDirectory.FullName | ForEach-Object {
                $Operation.AddTargetPath($_)
            }
        }
        Write-Verbose -Message "Target Selected"
        
        Write-ACLOpBackupObjFile -Operation $Operation

        Write-Information -MessageData $("{0} Targets selected" -f $Operation.Targets.Count) -InformationAction Continue
        Write-Verbose -Message $("Target Paths: `r`n`t- {0}" -f $($Operation.Targets.Path -join "`r`n`t- "))

        $Operation.Targets | ForEach-Object {
            $TemplateACEs | Add-TemplateACEToTarget -CurrentTargetDirectory $_.Path
        }


        Write-Information "Done" -InformationAction Continue
    }
}

end {
}

