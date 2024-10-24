```ps1
$path = "repo_path"
$dirs = Get-ChildItem -Directory $path | Select-Object FullName

foreach ($dir in $dirs)
{
    # Write-Host  $dir.FullName
    Set-Location -Path $dir.FullName -PassThru

    git clean -f -x -d

    Set-Location -Path .. -PassThru
}
```