[CmdletBinding()]
param
(
    [Parameter(ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(0, [int]::MaxValue)]
    [int[]] $Changelist,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({-not ($_.GetEnumerator() | where { $_.Name -isnot [string] -or $_.Value -isnot [string] })})]
    [hashtable] $User,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Root = $PWD
)

if (-not (test-path -pathtype 'Container' $Root))
{
    write-error "'$Root' is not a valid root directory." -category 'ObjectNotFound'
    break
}

# Check for and report all missing required commands
foreach ($cmd in 'tf', 'git')
{
    if (-not (get-command $cmd -ea 'SilentlyContinue'))
    {
        write-error "Could not find command '$cmd' in `$env:PATH" -category 'ObjectNotFound'
    }
}

if (-not $?)
{
    break
}

if (-not $Changelist)
{
    $message = "Querying for changelists under '$Root'"
    $regex = '^(\d+)'

    if ($User)
    {
        $message = $message + " for $($User.Keys -join ', ')"
        $regex = $regex + "\s+($($User.Keys -join '|'))"
    }

    write-verbose $message
    $Changelist = tf hist /noprompt /sort:ascending /recursive "$Root" | select-string $regex | foreach {
        [int] $_.Matches.Groups[1].Captures[0].Value
    }
}

foreach ($c in $Changelist)
{
    $regex = "^(?<changelist>\d+)\s+(?<username>$($User.Keys -join '|'))\s+(?<date>[\d\/]+)\s+(?<comment>.*)"

    write-verbose "Querying information for changelist $c"
    $hist = tf hist /noprompt /recursive "/version:C$c" /stopafter:1 "$Root" | select-string $regex | foreach {
        new-object PSObject -property @{
            'Changelist' = [int]($_.Matches.Captures[0].Groups['changelist'].Value);
            'Username' = [string]($_.Matches.Captures[0].Groups['username'].Value);
            'Date' = [datetime]($_.Matches.Captures[0].Groups['date'].Value);
            'Comment' = [string]($_.Matches.Captures[0].Groups['comment'].Value);
        }
    }

    if (-not $hist.Comment)
    {
        $hist.Comment = "(No comment provided)"
    }

    $username = $hist.Username
    $date = $hist.Date.ToString("d")

    write-verbose "Checking out changelist $($hist.Changelist) by '$username' on $($date): $($hist.Comment)"
    tf get "$Root" "/version:C$c" /overwrite /force /r /noprompt

    $date = $hist.Date.ToString("u")

    write-verbose "Commiting changes in changelist $c to Git repository"
    git add "$Root" -A
    git commit -am"$($hist.Comment)" --author "$username <$($User[$username])>" --date "$date"
}