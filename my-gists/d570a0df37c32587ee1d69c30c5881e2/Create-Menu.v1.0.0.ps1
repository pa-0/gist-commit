Function Create-Menu () {
    <#
        .SYNOPSIS
            Shows strings as a table to be selectable by navigating with arrow keys

        .DESCRIPTION
            Version 1.0.0
            Author: Nabil Redmann (BananaAcid)
            License: ISC
        
        .LINK
            https://gist.githubusercontent.com/BananaAcid/b8efca90cc6ca873fa22a7f9b98d918a/raw/Create-Menu.ps1

        .INPUTS
            array of strings

        .PARAMETER MenuOptions <String[]>
            Takes an array with selections (must be more then one)
        .PARAMETER Title <Null|ScriptBlock|String>
            Takes a string or a scriptblock (available vars: $Selection, $SelectionValue)
        .PARAMETER Selected <Null|Integer>
            Initial string to select
        .PARAMETER Columns <"Auto"|Integer>
            Define how many columns should be shown (default: "Auto")
        .PARAMETER MaximumColumnWidth <"Auto"|Integer>
            The maximum amount of chars in a cell should be displayed, if to large, '...' will be appended 
            (default: "Auto" if Columns is a number, results in "20" if Columns is "Auto")
        .PARAMETER ShowCurrentSelection <Boolean>
            Shows the current selection text in full length in the console title (default: $True)
        .PARAMETER PassThrou
            Without, will output the index of the selection, otherwise the selected string (default: $False)
        .PARAMETER BackgroundColor <Cyan|ConsoleColor>
            Color for the selection (default: Cyan)
        .PARAMETER ForegroundColor <Black|ConsoleColor>
            Color for the selection (default: Black)

        .OUTPUTS
            Default is the index of the selected string, using -PassThrou it will be the selected string

        .EXAMPLE
            $check = Create-Menu no,yes "Want it?" 1
                Shortest version. "no" first, becuase index 0 is equal to false. the "1" selects index 1 initially
        .EXAMPLE
            $check = Create-Menu @("no","yes") -Title "Want it?" -Selected 1
                Longer version
        .EXAMPLE
             ls | create-menu -passthrou -T "Show:" |% {cat $_}
                Outputs a filename after selecting
        .EXAMPLE
            echo "Select a letter"; $sel = @("a","b","c") | Create-Menu -PassThrou; echo "Selected: $sel"
                Usage for -MenuOptions by piping in
        .EXAMPLE
            ls ../ | Create-Menu -Title "abc`n-----"
                A simple string as title
        .EXAMPLE
            ls ../ | Create-Menu -Title {"SEL: $SelectionValue`n-----"}
                A scriptblock with an internal variable
        .EXAMPLE
            ls ../ | Create-Menu -Title {Write-Host -ForegroundColor Green "SEL: $SelectionValue`n-----"}
                A scriptblock with colored title

        .NOTES
            Based on: https://community.spiceworks.com/scripts/show/4785-create-menu-2-0-arrow-key-driven-powershell-menu-for-scripts
     #>

    #Start-Transcript "C:\Create-Menu.log"
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True ,Mandatory=$True )][String[]]$MenuOptions,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Object]$Title = $Null, # ScriptBlock or String
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][int]$Selected = $Null,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][String]$Columns = "Auto",
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][String]$MaximumColumnWidth = "Auto",
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][bool]$ShowCurrentSelection = $True, # ... in console title
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][switch]$PassThrou = $False,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][ConsoleColor]$BackgroundColor = [ConsoleColor]::Cyan,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][ConsoleColor]$ForegroundColor = [ConsoleColor]::Black
    )

    # in case items were pipelined
    $all = @($Input)
    if ($all) {
        $MenuOptions = [array]$all
    }

    $ExtraRow = @{}
    $MaxValue = $MenuOptions.count-1
    $Selection = $selected ? $Selected : 0
    $EnterPressed = $False
    $WindowTitleBackup = $Host.UI.RawUI.WindowTitle

    If ($Columns -eq "Auto") {
        If ($MaximumColumnWidth -eq "Auto") {
            $MaximumColumnWidth = 20
        }

        $WindowWidth = $Host.UI.RawUI.MaxWindowSize.Width
        $Columns = [Math]::Floor($WindowWidth / ([int]$MaximumColumnWidth +2))
    }
    else {
        If ($MaximumColumnWidth -eq "Auto") {
            $MaximumColumnWidth = [Math]::Floor(($Host.UI.RawUI.MaxWindowSize.Width - [int]$Columns) / [int]$Columns)
        }
    }

    If ([int]$Columns -gt $MenuOptions.count) {
        $Columns = $MenuOptions.count
    }

    $RowQty = ([Math]::Ceiling(($MaxValue +1) / [int]$Columns))

    $consoleTop = $False
    Function ClearHost () {
        if ($consoleTop -eq $False) {
            $consoleTop = [Console]::CursorTop - $RowQty
        }
        [Console]::SetCursorPosition(0, $consoleTop - ($ExtraRow.Values |Measure-Object -sum).sum) # extra rows needed, set: $ExtraRow["uniqueKey"] = 2
    }

        
    $MenuListing = @()

    For ($i=0; $i -lt $Columns; $i++) {
            
        $ScratchArray = @()

        For ($j=($RowQty*$i); $j -lt ($RowQty*($i+1)); $j++) {

            $ScratchArray += $MenuOptions[$j]
        }

        $ColWidth = ($ScratchArray |Measure-Object -Maximum -Property length).Maximum

        If ($ColWidth -gt [int]$MaximumColumnWidth) {
            $ColWidth = [int]$MaximumColumnWidth-1
        }

        For ($j=0; $j -lt $ScratchArray.count; $j++) {
            
            If (($ScratchArray[$j]).length -gt $([int]$MaximumColumnWidth -2)) {
                $ScratchArray[$j] = $($ScratchArray[$j]).Substring(0,$([int]$MaximumColumnWidth-4))
                $ScratchArray[$j] = "$($ScratchArray[$j])..."
            } Else {
            
                For ($k=$ScratchArray[$j].length; $k -lt $ColWidth; $k++) {
                    $ScratchArray[$j] = "$($ScratchArray[$j]) "
                }

            }
            
            $ScratchArray[$j] = " $($ScratchArray[$j]) "
        }
        $MenuListing += $ScratchArray
    }
    
    While ($EnterPressed -eq $False){
        
        If ($ShowCurrentSelection) {
            $Host.UI.RawUI.WindowTitle = "CURRENT SELECTION: $($MenuOptions[$Selection])"
        }

        # Write-Host -ForegroundColor Green "TITLE: $Selection`n----"; $ExtraRow["title"] = 2
        if ($Title) {
            if ($Title -is [String]) {
                Write-Host $Title
                $ExtraRow["title"] = ($Title | Measure-Object -Line).lines
            }
            else {
                Invoke-Command -ScriptBlock { param($Selection, $SelectionValue) # supply usable variables
                    # write title, scroll down if needed, and get size
                    Invoke-Command -ScriptBlock $Title 6>&1 | Tee-Object -Variable Lines
                    $ExtraRow["title"] = ($Lines | Measure-Object -Line).lines

                    # get title position
                    $TitlePos = [Console]::CursorTop - $ExtraRow["title"]

                    # reset title position
                    [Console]::SetCursorPosition(0, $TitlePos)
                    $maxLineLength = $Host.UI.RawUI.MaxWindowSize.Width
                    Write-Host ((" " * $maxLineLength + "`n") * $ExtraRow["title"]) -NoNewline # clear the lines with NO COLOR

                    # reset position and final output
                    [Console]::SetCursorPosition(0, $TitlePos)
                    Invoke-Command -ScriptBlock $Title

                } -ArgumentList $Selection, $MenuOptions[$Selection]
            }
        }

        # output selections
        For ($i=0; $i -lt $RowQty; $i++) {

            For ($j=0; $j -le (($Columns-1)*$RowQty);$j+=$RowQty) {

                If ($j -eq (($Columns-1)*$RowQty)) {
                    If(($i+$j) -eq $Selection){
                        Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor "$($MenuListing[$i+$j])" -NoNewline
                        Write-Host "" # this fixes the color overflow
                    } Else {
                        Write-Host "$($MenuListing[$i+$j])"
                    }
                } Else {
                    If (($i+$j) -eq $Selection) {
                        Write-Host -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor "$($MenuListing[$i+$j])" -NoNewline
                    } Else {
                        Write-Host "$($MenuListing[$i+$j])" -NoNewline
                    }
                }
                
            }

        }

        #Uncomment the below line if you need to do live debugging of the current index selection. It will put it in green below the selection listing.
        # Write-Host -ForegroundColor Green "$Selection"; $ExtraRow["debug"] = 1

        $KeyInput = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").virtualkeycode

        Switch ($KeyInput) {
            13 { #Enter
                # ignore empty fields
                if ($MenuOptions[$Selection]) {
                    $EnterPressed = $True

                    # set title to before menu
                    If ($ShowCurrentSelection) {
                        $Host.UI.RawUI.WindowTitle = $WindowTitleBackup
                    }

                    if ($PassThrou) {
                        Return $MenuOptions[$Selection]
                    }
                    else {
                        Return $Selection
                    }   
                }
                ClearHost
                break
            }

            37 { #Left
                If ($Selection -ge $RowQty){
                    $Selection -= $RowQty
                } Else {
                    $Selection += ($Columns-1)*$RowQty
                }
                ClearHost
                break
            }

            38 { #Up
                If ((($Selection+$RowQty)%$RowQty) -eq 0) {
                    $Selection += $RowQty - 1
                } Else {
                    $Selection -= 1
                }
                ClearHost
                break
            }

            39{ #Right
                If ([Math]::Ceiling($Selection/$RowQty) -eq $Columns -or ($Selection/$RowQty)+1 -eq $Columns){
                    $Selection -= ($Columns-1)*$RowQty
                } Else {
                    $Selection += $RowQty
                }
                ClearHost
                break
            }

            40 { #Down
                If ((($Selection+1)%$RowQty) -eq 0 -or $Selection -eq $MaxValue){
                    $Selection = ([Math]::Floor(($Selection)/$RowQty))*$RowQty
                    
                } Else {
                    $Selection += 1
                }
                ClearHost
                break
            }

            Default {
                ClearHost
            }
        }
    }
}