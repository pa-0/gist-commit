param ($key)

<#
# sample package.ps1
@{
    start = {1..10}
    stuff = "this is stuff"
}
#>

$defaultPackageName = ".\package.ps1"

if(Test-Path $defaultPackageName) {
    
    $package = & $defaultPackageName
    
    if(!$key) {$key="start"}

    if(!$package.ContainsKey($key)) {
        Write-Error "Cannot find $($key)"
        Return
    }

    $value = $package.$key
    
    switch ($value) {
        {$_ -is [Scriptblock]} {&$_}
        default {$_}
    }
}