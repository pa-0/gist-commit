$json="
{
    'name': 'john doe', 
    'age':10,
    'pets': []    
}
"

$json | 
    ConvertFrom-Json | 
    Get-Member -MemberType NoteProperty | ForEach {
    [PSCustomObject]@{
        Name = $_.Name
        Type = (($_.Definition -split ' ')[0] -split '\.')[1]
    }
} | ForEach {$property=@()} {
    $property += "`tpublic {0} {1} {{get; set;}}`r`n" -f $_.Type, $_.Name
} {
@"
public class RootObject 
{
$property
}
"@
}
