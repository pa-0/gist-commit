1. The following should be run beforehand:
    ```powershell
    [void] (Check-prequisites)
    ```
2. **TIP:** 
    Rather than just amending the `$env:Path` environment variable, it's better practice to replace it entirely. Otherwise you risk facing issues with the build scripts unexpectedly using tools or libraries from all kinds of other toolchains.
    ```diff
    -    $env:Path += "$MingwDir\bin;$MingwDir\opt\bin;$env:SystemRoot\system32;$env:SystemRoot;$env:SystemRoot\system32\WindowsPowerShell\v1.0\;"
    +    $perlPath = Split-Path -parent (get-command perl).Path
    +    $pythonPath = Split-Path -parent (get-command python).Path
    +    $rubyPath = Split-Path -parent (get-command ruby).Path
    +    $env:Path = "$MingwDir\bin;$MingwDir\opt\bin;$env:SystemRoot\system32;$env:SystemRoot;$env:SystemRoot\system32\WindowsPowerShell\v1.0\;$perlPath;$pythonPath;$rubyPath"
    ```