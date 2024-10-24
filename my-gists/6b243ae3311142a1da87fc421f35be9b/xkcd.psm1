Function Get-XKCD{
    [cmdletbinding(DefaultParameterSetName=’Specific’)]
    Param (
        [Parameter(ParameterSetName=’Specific’,ValueFromPipeline=$True,Position=0)][int[]]$Num,
        [Parameter(ParameterSetName=’Random’)][switch]$Random,
        [Parameter(ParameterSetName=’Random’)][int]$Min = 1,
        [Parameter(ParameterSetName=’Random’)]
            [int]$Max = ((Invoke-WebRequest "http://xkcd.com/info.0.json").Content | ConvertFrom-Json).num,        
        [Parameter(ParameterSetName=’Newest’)][int]$Newest,
        [switch]$Download
    )
    Begin{
        If (!$Num) {$Num = $Max}
        If ($Random) { $Num = get-random -min $Min -max $Max }
        If ($Newest) { $Num = (($Max - $Newest)+1)..$Max }
    }
    Process{
        $Num | ForEach-Object { 
            $Comic = (Invoke-WebRequest "http://xkcd.com/$_/info.0.json").Content | ConvertFrom-Json
            If ($Download) { Try{ Invoke-WebRequest $Comic.img -OutFile "$_.jpg" }Catch{ $Download = $False } }
            
            $Comic | Add-Member -membertype NoteProperty -name Downloaded -value $Download
            $Comic
        }
    }
}

#Examples:

#Get the latest comic
Get-XKCD

#Get comic number 1
Get-XKCD 1

#Get any random comic
Get-XKCD -Random

#Get the latest 5 comics
Get-XKCD -Newest 5

#Get comics 10 - 20 and return their number and title as a table
Get-XKCD (10..20) | select num,title | ft

#Get 10 random comics from the first 100 comics and return their number and URLs as an autosized table
1..10 | % { Get-XKCD -Random -min 1 -max 100 | select num,img } | FT -AutoSize