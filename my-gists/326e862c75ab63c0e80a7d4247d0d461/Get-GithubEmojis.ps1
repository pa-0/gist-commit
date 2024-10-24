workflow Get-GithubEmojis {

    param($TargetPath="c:\temp\emojis")
    
    if(!(Test-Path -Path $TargetPath)) {
        $null= New-Item -ItemType Directory -Path $TargetPath
    }

    $emojis = Invoke-RestMethod -Uri https://api.github.com/emojis 

    $names = ($emojis | Get-Member -MemberType NoteProperty).name

    $records = $names | ForEach {
        $target=$emojis.$PSItem
        [PSCustomObject]@{
            FileName=(Split-Path -Leaf $target) -replace "\?v5", ""
            Url=$target
        }
    }

    ForEach -Parallel ($record in $records) 
    {
        try {
            Invoke-RestMethod -Uri $record.Url -OutFile (Join-Path -Path $TargetPath -ChildPath $record.FileName)
        } catch {}
    }
}