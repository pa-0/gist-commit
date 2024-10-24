function Write-HostWithTimestamp {
    param($Message)

    Write-Host "[$((Get-Date).ToString('yyyyMMddhhmmss'))] $Message"
}

function Get-TestJS {
    param(
        [Parameter(Mandatory)]
        $LanguageIdentifier
    )

@"
var edge = require('edge');

var hello = edge.func('$($LanguageIdentifier)', function() {/*
<Your supported code here>
*/});

hello('Node.js', function (error, result) {
    if (error) throw error;
    console.log(result);
});
"@
}

function Get-EdgeCompilerCS {
    param(
        [Parameter(Mandatory)]
        $LanguageIdentifier
    )
@"
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public class EdgeCompiler
{
    public Func<object, Task<object>> CompileFunc(IDictionary<string, object> parameters)
    {
        string script = (string)parameters["source"];
        Console.WriteLine(script);
        return null;
    }
}
"@
}

function Get-CompilerJS {
    param(
        [Parameter(Mandatory)]
        $LanguageIdentifier
    )
@"
exports.getCompiler = function () {
  return __dirname + '\\edge-$($LanguageIdentifier).dll';
};

"@
}

function Get-PackageJson {
    param(
        [Parameter(Mandatory)]
        $LanguageIdentifier
    )

@"
{  "main": "./lib/edge-$($LanguageIdentifier).js" }
"@
}

function New-EdgeCompiler {
    param(
        [Parameter(Mandatory)]
        $LanguageIdentifier,
        [Switch]$Remove,
        [Switch]$TestInstall
    )

    Set-Location \
    $Path = "c:\EdgeCompiler$($LanguageIdentifier.ToUpper())"
    if($Remove) {
        Write-HostWithTimestamp "Removing $Path"
        rm -Recurse -Force $Path -ErrorAction SilentlyContinue
    }

    Write-HostWithTimestamp "Creating $Path"
    mkdir $Path | Out-Null
    Set-Location $Path

    Write-HostWithTimestamp "npm install edge "
    $r = npm install edge 2>&1

    $nodeModules = ".\node_modules"
    $edgeCompilerDirectory = "edge-$($LanguageIdentifier)"
    $edgeCompilerPath = Join-Path $nodeModules $edgeCompilerDirectory
    $edgeCompilerLibPath = Join-Path $edgeCompilerPath lib

    Write-HostWithTimestamp "Create $edgeCompilerPath"
    mkdir $edgeCompilerPath | Out-Null

    Write-HostWithTimestamp "Create $edgeCompilerLibPath"
    mkdir $edgeCompilerLibPath | Out-Null

    Write-HostWithTimestamp "Create test.js"
    Get-TestJS $LanguageIdentifier | Set-Content -Encoding Ascii test.js

    $edgeCompilerCS = Join-Path $edgeCompilerLibPath EdgeCompiler.cs
    Write-HostWithTimestamp "Create $($edgeCompilerCS)"
    Get-EdgeCompilerCS $LanguageIdentifier | Set-Content -Encoding Ascii $edgeCompilerCS

    Write-HostWithTimestamp "Compiling $($edgeCompilerCS)"
    $outputAssembly = Join-Path $edgeCompilerLibPath "edge-$($LanguageIdentifier).dll"
    Add-Type -Path $edgeCompilerCS -OutputAssembly $outputAssembly

    $edgeCompilerJS = Join-Path $edgeCompilerLibPath "edge-$($LanguageIdentifier).js"
    Write-HostWithTimestamp "Create $edgeCompilerJS"
    Get-CompilerJS $LanguageIdentifier | Set-Content -Encoding Ascii $edgeCompilerJS

    $packageJson = Join-Path $edgeCompilerPath package.json
    Write-HostWithTimestamp "Create $packageJson"
    Get-PackageJson $LanguageIdentifier | Set-Content -Encoding Ascii $packageJson

    if($TestInstall) {

        Write-HostWithTimestamp "Testing... "
        node .\test.js
    }
}