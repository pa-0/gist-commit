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