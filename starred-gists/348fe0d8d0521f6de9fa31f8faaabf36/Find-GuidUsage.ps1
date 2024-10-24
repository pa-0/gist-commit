function Find-GuidUsage {
    param(
        [Parameter(Mandatory=$true)]
        $path,
        $filter="*.cs"
    )

    $GuidPattern = "({|\()?[A-Fa-f0-9]{8}-([A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12}(}|\))?"

    dir $path -Recurse $filter | 
        Select-String $GuidPattern 
}