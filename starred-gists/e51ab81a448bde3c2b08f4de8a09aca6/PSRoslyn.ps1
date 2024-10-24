function Invoke-Csx {
    param($script = 'System.Console.WriteLine("Hello World");')

    foreach($dll in (dir .\lib)) { Add-Type -Path $dll.FullName}

    $engine = New-Object Roslyn.Scripting.CSharp.ScriptEngine $null, $null
    $engine.AddReference("System")
    $engine.AddReference("System.Core")

    $session = $engine.CreateSession()

    if(Test-Path $script -ErrorAction SilentlyContinue) {
        $script = [System.IO.File]::ReadAllText( (Resolve-Path $script) )
    } 

    $session.Execute($script)        
}

PS C:\> Invoke-Csx @"
using System.Linq;
Enumerable.Range(1, 10).Select(x => x * x);
"@ | Where {$_ % 2 -eq 0} | ForEach {$_*2}

# Results
8
32
72
128
200
