foreach ($InstalledModule in Get-InstalledModule) {
    $latest=Find-Module $InstalledModule.name
    if($latest.Version -gt $InstalledModule.Version) {
        [PSCustomObject]@{
            Module=$InstalledModule.Name
            Current=$InstalledModule.Version
            Latest=$latest.Version
            Location=$latest.Repository
        }
    }
}