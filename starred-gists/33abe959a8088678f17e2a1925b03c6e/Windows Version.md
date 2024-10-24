
# Various Ways to Collect Windows Version  

## WindowsRelease

```powershell
function Get-WindowsRelease
{
    $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $WindowsRelease = $CurrentOSInfo.GetValue('ReleaseId')
    if ($WindowsRelease -eq "2009"){$WindowsRelease = $CurrentOSInfo.GetValue('DisplayVersion')}

    return $WindowsRelease
}
```

## Windows UBR

```powershell
function Get-WindowsUBR
{
    $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $BuildUBR_CurrentOS = $($CurrentOSInfo.GetValue('CurrentBuild'))+"."+$($CurrentOSInfo.GetValue('UBR'))

    return $BuildUBR_CurrentOS
}
```

## Window Build

```powershell
function Get-WindowsBuild
{
    $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    return $($CurrentOSInfo.GetValue('CurrentBuild'))
}
```

## OSVersion

```powershell
[System.Environment]::OSVersion
```

## Function Get-WindowsVersion

```powershell
function Get-WindowsVersion
{
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true
        )]
        [string[]]
        $ComputerName = $env:COMPUTERNAME
    )


    Begin
    {
        $Table = New-Object System.Data.DataTable
        $Table.Columns.AddRange(@("ComputerName", "Windows Edition", "Version", "OS Build"))
    }
    Process
    {
        Foreach ($Computer in $ComputerName)
        {
            $Code = {
                $ProductName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName).ProductName
                Try
                {
                    $Version = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseID -ErrorAction Stop).ReleaseID
                }
                Catch
                {
                    $Version = "N/A"
                }
                $CurrentBuild = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild).CurrentBuild
                $UBR = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name UBR).UBR
                $OSVersion = $CurrentBuild + "." + $UBR

                $TempTable = New-Object System.Data.DataTable
                $TempTable.Columns.AddRange(@("ComputerName", "Windows Edition", "Version", "OS Build"))
                [void]$TempTable.Rows.Add($env:COMPUTERNAME, $ProductName, $Version, $OSVersion)

                Return $TempTable
            }

            If ($Computer -eq $env:COMPUTERNAME)
            {
                $Result = Invoke-Command -ScriptBlock $Code
                [void]$Table.Rows.Add($Result.Computername, $Result.'Windows Edition', $Result.Version, $Result.'OS Build')
            }
            Else
            {
                Try
                {
                    $Result = Invoke-Command -ComputerName $Computer -ScriptBlock $Code -ErrorAction Stop
                    [void]$Table.Rows.Add($Result.Computername, $Result.'Windows Edition', $Result.Version, $Result.'OS Build')
                }
                Catch
                {
                    $_
                }
            }

        }
    }
    End
    {
        Return $Table
    }
}
```
