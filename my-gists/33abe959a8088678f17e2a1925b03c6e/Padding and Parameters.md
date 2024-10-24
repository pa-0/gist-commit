
# Padding and Parameters

My logging function hat a $Type parameter with different types of logging: Info, Success, Error, Warning.. The output in the console looked like this:

```log
20.03.2023|04:00:33|Error|Test message [Error]
20.03.2023|04:00:33|Warning|Test message [Warning]
20.03.2023|04:00:33|Info|Test message [Info]
20.03.2023|04:00:33|Success|Test message [Success]
```

As you can see the selected type parameter was not beautiful aligned by the dividing dash/pipe to the message, which makes reading a bit harder in my opinion. So I decided to work with padding. Padding in a string as Method can add one or multiple extra characters to the left or the right of the string, like:

```powershell
$Samplestrings = ("1","13","156")
$Samplestrings.foreach({
    $_.PadLeft(3,"0")
})
```

The output looks like this:

```powershell
001
013
156
```

back to the starting topic my function looked a way like this:

```powershell
function Write-Log {
    [CmdletBinding()]
    param (
        [string] $Message,
        [Validateset("Warning","Info","Error","Success")]
        $Type
    )
    
    begin {
        
    }
    
    process {
        Write-Host "$(Get-Date -format 'dd.MM.yyyy')|$(Get-Date -format 'hh:mm:ss')|$Type|$Message"
    }
    
    end {
        
    }
}
```

And if we now would align the divider properly, we have to find out what is the length of the longest string in the $type parameter to add dynamically whitespaces via padding. My attempt looks like this:

```powershell
function Write-Log {
    [CmdletBinding()]
    param (
        [string] $Message,
        [Validateset("Warning","Info","Error","Success")]
        $Type
    )
    
    begin {
        $MaxLengthType = 0
        (Get-Variable -Name "Type").Attributes.ValidValues.foreach({
            if($MaxLengthType -lt $_.tostring().length){
                $MaxLengthType = [int]$_.tostring().length
            }
        })
        $TypeToDisplay = $Type.PadRight($MaxLengthType," ")
    }
    
    process {
        Write-Host "$(Get-Date -format 'dd.MM.yyyy')|$(Get-Date -format 'hh:mm:ss')|$TypeToDisplay|$Message"
    }
    
    end {
        
    }
}
```

Our console now looks like this:

```log
20.03.2023|04:00:33|Error  |Test message [Error]
20.03.2023|04:00:33|Warning|Test message [Warning]
20.03.2023|04:00:33|Info   |Test message [Info]
20.03.2023|04:00:33|Success|Test message [Success]
```

It is a way more static and increases the readability a lot

<https://devdojo.com/hcritter/padding-and-parameters>
