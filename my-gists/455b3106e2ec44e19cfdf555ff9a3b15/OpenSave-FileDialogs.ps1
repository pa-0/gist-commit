function Get-SaveFilePath {
    [CmdletBinding()]
    param (
        [string]
        $InitialDirectory = $PWD,
        [string]
        $Filter
    )

    begin {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    }

    process {
        $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{
            InitialDirectory = $initialDirectory
            Title            = "Save File"
            Filter           = if ($PSBoundParameters.ContainsKey('Filter')) {
                "$Filter|All Files (*.*)|*.*"
            } else {
                "All Files (*.*)|*.*"
            }
        }
        $FileBrowser.ShowDialog() | Out-Null
        Write-Output $FileBrowser.FileNames
    }

    end {

    }
}
function Get-OpenFilePath {
    [CmdletBinding()]
    param (
        [string]
        $InitialDirectory = $PWD,
        [string]
        $Filter = "All Files (*.*)|*.*"
    )

    begin {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    }

    process {
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = $initialDirectory
            Title            = "Select Files to open"
            Multiselect      = $true
            Filter           = if ($PSBoundParameters.ContainsKey('Filter')) {
                "$Filter|All Files (*.*)|*.*"
            } else {
                "All Files (*.*)|*.*"
            }
        }
        $FileBrowser.ShowDialog() | Out-Null

        Write-Output $( [PSCustomObject]@{
                FileName  = $FileBrowser.FileName
                FileNames = $FileBrowser.FileNames
            })
    }

    end {

    }
}
