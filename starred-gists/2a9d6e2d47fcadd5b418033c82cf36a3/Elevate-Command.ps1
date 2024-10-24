[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    # The path to an executable program.
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'FilePath')]
    [ValidateScript({Test-Path -Path $_})]
    [System.String]
    $FilePath,

    # The script block to execute in an elevated context.
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ScriptBlock')]
    [System.Management.Automation.ScriptBlock]
    $ScriptBlock,

    # Optional argument list for the program or the script block.
    [Parameter(Mandatory = $false, Position = 1)]
    [System.Object[]]
    $ArgumentList,

    [Parameter(ValueFromPipeline)]
    [pscustomobject]
    $InputObject
)

Function Serialize-Command
{
    param(
        [scriptblock]$Scriptblock
    )
    $rxp = '(?<!`)\$using:(?<var>\w+)'
    $ssb = $Scriptblock.ToString()
    $cb = {
        $v = (Get-Variable -Name $args[0].Groups['var'] -ValueOnly)
        $ser = [System.Management.Automation.PSSerializer]::Serialize($v)
        "`$([System.Management.Automation.PSSerializer]::Deserialize('{0}'))" -f $ser
    }
    $sb = [RegEx]::Replace($ssb, $rxp, $cb, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $Serialized = [System.Management.Automation.PSSerializer]::Serialize($sb)
    #$Serialized
    #[System.Text.Encoding]::UTF8.GetBytes($Serialized)
    [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Serialized))
}

$debug = if ($PSBoundParameters['Debug']) {$true} else {$false};
if($debug) { "Executing Elevate-Command in Debug Mode" }

$serializedArgs = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Management.Automation.PSSerializer]::Serialize($ArgumentList)));
$serializedInputObject = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Management.Automation.PSSerializer]::Serialize($InputObject)));

if($debug) {
    echo "" "Passing this ArgumentList to the elevated instance = $ArgumentList" "Serialized=$serializedArgs" ""
    echo "Passing this InputObject to the elevated instance = $InputObject" "Serialized=$serializedInputObject" ""
}

$cmd = @"
`$Debug = `$$Debug;

`$argumentList = [System.Management.Automation.PSSerializer]::Deserialize([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$serializedArgs')))
if (`$argumentList) { `$argumentList=`$argumentList.ToArray() } # Deserialize as Object[] instead of ArrayList.

`$inputObject = [System.Management.Automation.PSSerializer]::Deserialize([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$serializedInputObject')))

if (`$Debug) { 
    echo "Received ArgumentList: (Count=`$(`$argumentList.Count)): `$argumentList"
    echo "Received InputObject: `$InputObject"
}

`$sb = [Scriptblock]::Create(
    [System.Management.Automation.PSSerializer]::Deserialize(
        [System.Text.Encoding]::UTF8.GetString(
            [System.Convert]::FromBase64String("$(Serialize-Command($ScriptBlock))")
        )
    )).GetNewClosure();

if (`$Debug) {echo "SB created"}

Invoke-Command `$sb -Input $InputObject -ArgumentList `$argumentList;
"@


if ($Debug) { echo "--- The following script will run elevated: `n$cmd`n---`n"}

if ($psISE) # Running inside Powershell ISE? Then gsudo won't be able to detect PS version, so use Windows PS.
{
    if ($Debug) 
        { $result = $cmd | gsudo --debug powershell -NoLogo -NoProfile -Command - }
    else 
        { $result = $cmd | gsudo powershell -NoLogo -NoProfile -Command - }
}
elseif ($Debug) { 
    $result = $cmd | gsudo --debug run -
}
else {
    $result = $cmd | gsudo run -
}

$result
