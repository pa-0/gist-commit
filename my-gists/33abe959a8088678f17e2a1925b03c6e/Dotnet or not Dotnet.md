# Dotnet or not Dotnet this is the question we will ask in this post

Lets find out if the .NET .Where() method is significantly faster than their equivalent in native PowerShell
In this post, we'll compare the performance of native PowerShell methods with their .NET counterparts, specifically focusing on the .Where() method. We'll also use the ```.net[Linq.Enumerable]``` class to analyze a different dataset - passenger data from the Titanic - instead of the usual Active Directory user data.

The Code
We'll be using three different methods to compare performance:

```powershell
# Define a collection of objects
$Import = @( 
    [PSCustomObject]@{ Name = "John"; Sex = "male" },
    [PSCustomObject]@{ Name = "Mary"; Sex = "female" },
    [PSCustomObject]@{ Name = "Peter"; Sex = "male" }
)

# .NET LINQ method
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()
$delegate = [Func[object,bool]] { $args[0].Sex -eq "male" }
$Result = [Linq.Enumerable]::Where($Import, $delegate)
$Result = [Linq.Enumerable]::ToList($Result)
$StopWatch.Stop()
$TestList.add([PSCustomObject]@{
    Method = "Linq Where-Method"
    ResultCounter = $Result.Count
    TimeElapsed = $StopWatch.Elapsed
    TimeElapsedMS = $StopWatch.ElapsedMilliseconds
})
 
# PowerShell pipeline with Where-Object
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()
$Result = $Import | Where-Object{$_.Sex -eq "male"}
$StopWatch.Stop()
$TestList.add([PSCustomObject]@{
    Method = "Piped Where-Method"
    ResultCounter = $Result.Count
    TimeElapsed = $StopWatch.Elapsed
    TimeElapsedMS = $StopWatch.ElapsedMilliseconds
})

# .NET Where() method
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()
$Result = $Import.Where({$_.Sex -eq "male"})
$StopWatch.Stop()
$TestList.add([PSCustomObject]@{
    Method = ".where()-Method"
    ResultCounter = $Result.Count
    TimeElapsed = $StopWatch.Elapsed
    TimeElapsedMS = $StopWatch.ElapsedMilliseconds
})
```

A Scary Realization: Inconsistent Execution Times
As I was checking the results and testing the reliability of my code, I executed my code segments multiple times. I noticed that there were times when there was another winner when it comes to execution time, and the results were somewhat different each time I ran the code. I was wondering how this could happen, so I decided to switch from PowerShell Version 7.x to 5.1, but the results were nearly the same.

To investigate this further, I performed the same action 101 times for each version of PowerShell on my machine and took the average of each 101 runs, and put them into a table.

The Results: Comparing PowerShell Versions 7.X and 5.1

Here are the results of my tests:

AverageOf101ms | Method | PSVersion
---------|----------|---------
3,0495049504950495 | Linq Where-Method | 7
5,851485148514851 | Piped Where-Method | 7
1,3465346534653466 | .where()-Method | 7

PowerShell Version 5.1
AverageOf101ms | Method | PSVersion
---------|----------|---------
6,88118811881188 | Linq Where-Method | 5
11,2871287128713 | Piped Where-Method | 5
3,88118811881188 | .where()-Method | 5

```powershell
$myArray = 1..1000

# Using ForEach-Object
Measure-Command {
    $myArray | ForEach-Object {
        # Do something with the array element
        $result = $_ * 2
    }
}

# Using .ForEach() method
Measure-Command {
    $myArray.ForEach({
        # Do something with the array element
        $result = $_ * 2
    })
}
```

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 13
Ticks             : 136114
TotalDays         : 1.57539351851852E-07
TotalHours        : 3.78094444444444E-06
TotalMinutes      : 0.000226856666666667
TotalSeconds      : 0.0136114
TotalMilliseconds : 13.6114

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 16
Ticks             : 162860
TotalDays         : 1.8849537037037E-07
TotalHours        : 4.52388888888889E-06
TotalMinutes      : 0.000271433333333333
TotalSeconds      : 0.016286
TotalMilliseconds : 16.286

```powershell
function Compare-NetVsPowerShell {
    param(
        [string]$Path
    )

    # .NET LINQ method
    $dotNetLinqStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    [System.IO.Directory]::EnumerateFiles($Path, "*", [System.IO.SearchOption]::AllDirectories) | Where-Object { $_.EndsWith('.txt') }
    $dotNetLinqStopwatch.Stop()
    $dotNetLinqTime = $dotNetLinqStopwatch.Elapsed.TotalSeconds

    # PowerShell pipeline with Where-Object
    $powershellPipeStopwatch = Measure-Command {
        Get-ChildItem -Path $Path -Recurse -File | Where-Object { $_.Extension -eq '.txt' }
    }
    $powershellPipeTime = $powershellPipeStopwatch.TotalSeconds

    # .NET Where() method
    $dotNetWhereStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    [System.IO.Directory]::GetFiles($Path, "*", [System.IO.SearchOption]::AllDirectories).Where({ $_.EndsWith('.txt') })
    $dotNetWhereStopwatch.Stop()
    $dotNetWhereTime = $dotNetWhereStopwatch.Elapsed.TotalSeconds

    Write-Host "Time taken by .NET LINQ method: $dotNetLinqTime seconds"
    Write-Host "Time taken by PowerShell pipeline with Where-Object: $powershellPipeTime seconds"
    Write-Host "Time taken by .NET Where() method: $dotNetWhereTime seconds"
}

Compare-NetVsPowerShell -Path "C:\Windows\System32"
```
