function Get-FuzzyMatch {
    <#
        could also just add-type the entire class.
        https://gist.github.com/trackd/b08fb22692637c08bb8e3e97f0c63a90

        this uses reflection to get the method and invoke it.
        obviously this is not supported and could break at any time.
        adapted from
        https://gist.github.com/SteveL-MSFT/2b21240a4532eaa57631c07e31a4a916
    #>
    param (
        [Parameter(Mandatory)]
        [string]$String1,
        [Parameter(Mandatory)]
        [string]$String2
    )
    $fz = [System.Reflection.Assembly]::GetAssembly([System.Management.Automation.PowerShell]).GetType("System.Management.Automation.FuzzyMatcher")
    $fzmatch = $fz.GetMethod("GetDamerauLevenshteinDistance", [System.Reflection.BindingFlags]'NonPublic,Static')
    if ($null -eq $fzmatch) {
        throw 'Unable to find GetDamerauLevenshteinDistance method'
    }
    return $fzmatch.Invoke($null, @($String1, $String2))
}
