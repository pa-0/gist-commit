function mywt {
    [CmdletBinding()]
    param($d)
    
    DynamicParam {
        $p = New-Object System.Management.Automation.ParameterAttribute
        $p.Position = 2
        $p.Mandatory = $false
        
        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($p)

        function Get-WTProfileNames {
            $r = (ls "$env:LOCALAPPDATA\Packages" Microsoft.WindowsTerminal*).FullName
            $wtProfile = ls "$r\LocalState"
            $data = Get-Content $wtProfile.FullName | ConvertFrom-Json
            $data.profiles.name
        }
        
        $attributeCollection.Add((New-Object  System.Management.Automation.ValidateSetAttribute((Get-WTProfileNames))))        
        
        $profileNameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('profile', [string], $attributeCollection)

        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('profile', $profileNameParam)

        return $paramDictionary
    }

    end {        
        $bp=@{}+$PSBoundParameters
        
        $finalParams = $(switch($bp.Keys) {
            'profile' {"-p {0}" -f $bp.$_}            
            default {"-{0} {1}" -f $_,$bp.$_}
        }) -join ' '
 

        "wt $finalParams"|iex        
   }
}