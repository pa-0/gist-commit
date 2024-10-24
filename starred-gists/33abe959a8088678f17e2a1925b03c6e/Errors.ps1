# Powershell Errors


$Error
$Error | Group-Object | Sort-Object -Property Count -Descending | Format-Table -Property Count, Name -AutoSize
$Error[0] | Format-List *
$Error[0] | Format-Table *
$Error[0] | Format-List * -Force
$Error[0].Exception
$Error[0].Exception | Format-List *-Force
$Error[0].Exception.InnerException | Format-List* -Force
$Error[0].ScriptStackTrace #for locations in PowerShell functions/scripts
$Error[0].Exception.StackTrace #for locations in compiled cmdlets/dlls

try
{
    Start-Something -Path $path -ErrorAction Stop
}
catch [System.IO.DirectoryNotFoundException], [System.IO.FileNotFoundException]
{
    Write-Output "The path or file was not found: [$path]"
}
catch [System.IO.IOException]
{
    Write-Output "IO error with the file: [$path]"
}

try
{
    Start-Something -Path $path
}
catch [System.IO.FileNotFoundException]
{
    Write-Output "Could not find $path"
}
catch [System.IO.IOException]
{
    Write-Output "IO error with the file: $path"
}


$ErrorOutput = @($Global:Error) | ForEach-Object -Process {
    # Attempt to access properties, and only format if they exist
    try
    {
        $Timestamp = Get-Date -Format 'dd-MM-yyyy HH:mm:ss.ffff'
        $Severity = 'ERROR'
        $ErrorInFile = if ($_.InvocationInfo.PSCommandPath)
        {
            Split-Path -Path $_.InvocationInfo.PSCommandPath -Leaf
        }
        $LineNumber = $_.InvocationInfo.ScriptLineNumber
        $Line = $_.InvocationInfo.Line.Trim()
        $CommandName = $_.InvocationInfo.MyCommand.Name
        $Category = $_.CategoryInfo.Category
        $ExceptionType = $_.Exception.GetType().FullName
        $ExceptionMessage = $_.Exception.Message
        $StackTrace = $_.Exception.StackTrace
        $InnerExceptionMessage = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message }
        $FullyQualifiedErrorId = $_.FullyQualifiedErrorId

        $FormattedOutput = '[{0}] [{1}] [{2}] [{3}] [{4}] [{5}] [{6}] [{7}] [{8}] [{9}] [{10}]' -f $Timestamp, $Severity, $ErrorInFile, $LineNumber, $Line, $CommandName, $Category, $ExceptionType, $ExceptionMessage, $StackTrace, $InnerExceptionMessage
    }
    catch
    {
        # Ignore errors if properties don't exist
        $null
    }

    $FormattedOutput
}

$FormattedOutput = $ErrorOutput -join "`n"

Write-Host $FormattedOutput
