function Convert-BinaryToString {
  param (
    [Parameter(Mandatory)]
    [string]
    $Path
  )

  $Path = [System.IO.Path]::GetFullPath($Path)

  $Bytes = [System.IO.File]::ReadAllBytes($Path)
  $Options = [System.Base64FormattingOptions]::InsertLineBreaks
  [System.Convert]::ToBase64String($Bytes, $Options)
}

function Convert-StringToBinary {
  param (
    [Parameter(Mandatory)]
    [string]
    $String
    ,
    [Parameter(Mandatory)]
    [string]
    $Path
  )

  $Path = [System.IO.Path]::GetFullPath($Path)

  $Bytes = [System.Convert]::FromBase64String($String)
  [System.IO.File]::WriteAllBytes($Path, $Bytes)
}

$MicrosoftSharePointClient_dll = ''
$OutputFilePath = ".\Microsoft.SharePoint.Client.dll"
$BinaryData = $null
if ( (Test-Path -Path $OutputFilePath -PathType Leaf) -eq $true ) {
    $BinaryData = Convert-BinaryToString -Path $OutputFilePath
}
$Exists = $BinaryData -eq $MicrosoftSharePointClient_dll
if ( $Exists -eq $false ) {
    Write-Host "Creating file. $($OutputFilePath)"
    Convert-StringToBinary -String $MicrosoftSharePointClient_dll -Path $OutputFilePath
} else {
    Write-Host "File already exists. $($OutputFilePath)"
}

$MicrosoftSharePointClientRuntime_dll = ''
$OutputFilePath = ".\Microsoft.SharePoint.Client.Runtime.dll"
$BinaryData = $null
if ( (Test-Path -Path $OutputFilePath -PathType Leaf) -eq $true ) {
    $BinaryData = Convert-BinaryToString -Path $OutputFilePath
}
$Exists = $BinaryData -eq $MicrosoftSharePointClientRuntime_dll
if ( $Exists -eq $false ) {
    Write-Host "Creating file. $($OutputFilePath)"
    Convert-StringToBinary -String $MicrosoftSharePointClientRuntime_dll -Path $OutputFilePath
} else {
    Write-Host "File already exists. $($OutputFilePath)"
}
