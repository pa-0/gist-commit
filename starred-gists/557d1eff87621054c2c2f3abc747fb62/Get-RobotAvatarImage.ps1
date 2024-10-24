[CmdletBinding(DefaultParameterSetName="Interactive")]
param (
    # Parameter help description
    [Parameter(ParameterSetName="Interactive")]
    [switch]
    $Interactive,
    [Parameter(ParameterSetName="InputString")]
    [string]
    $InputString,
    # Set
    [Parameter()]
    [string]
    [ValidateSet("HeadShoulder","Monster","Head","Cat","Human")]
    $Set = "Head",
    # OutFile
    [Parameter()]
    [string]
    $OutFileDirectory = "~/Downloads"
)

function Get-RobotAvatar {
    [CmdletBinding()]
    param (
        # Seed
        [Parameter()]
        [string]
        $Seed,
        # Set
        [Parameter(Mandatory)]
        [string]
        [ValidateSet("HeadShoulder","Monster","Head","Cat","Human")]
        $Set,
        # OutFile
        [Parameter(Mandatory)]
        [string]
        $OutFileDirectory
    )
    
    begin {
        $SetMatcher = @{
            HeadShoulder = "set1"
            Monster = "set2"
            Head = "set3"
            Cat = "set4"
            Human = "set5"
        }
    }
    
    process {
        $FileName = "{0}_{1}.png" -f $Seed, $Set

        $invokeWebRequestSplat = @{
            Uri = "https://robohash.org/set_{1}/{0}.png" -f $Seed, $SetMatcher[$Set]
            OutFile = (Join-Path -Path $OutFileDirectory -ChildPath $FileName)
        }

        Invoke-WebRequest @invokeWebRequestSplat
        $invokeWebRequestSplat.OutFile
    }
    
    end {
        
    }
}

# This function is from https://gist.github.com/WalternativE/450b155c45f81b14290f8ded8324a283
function Get-StringHash {
    param (
        # Input String
        [Parameter(Mandatory)]
        [string]
        $InputString
    )
    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
    $hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($InputString))

    $hashString = [System.BitConverter]::ToString($hash)
    $hashString.Replace('-', '').ToLower()
}

$SeedString = switch ($PSCmdlet.ParameterSetName) {
    "Interactive" { 
        Read-Host -Prompt "Enter your prompt to generate a random robot"
    }
    "InputString" {
        $InputString
    }
    Default {
        Read-Host -Prompt "Enter your prompt to generate a random robot"
    }
}

$CreatedFile = Get-RobotAvatar -Seed $(Get-StringHash -InputString $SeedString) -Set $Set -OutFileDirectory $OutFileDirectory
Start-Process $CreatedFile # Opens the image