Function Create-Menu() {
    <#
        .SYNOPSIS
            Shows strings as a table to be selectable by navigating with arrow keys

        .DESCRIPTION
            Version 1.0.3
            Author: Nabil Redmann (BananaAcid)
            License: ISC
        
        .LINK
            https://gist.githubusercontent.com/BananaAcid/b8efca90cc6ca873fa22a7f9b98d918a/raw/Create-Menu.ps1

        .INPUTS
            array of strings

        .PARAMETER MenuOptions <String[]>
            Takes an array with selections (must be more then one)
        .PARAMETER Title <Null|ScriptBlock|String>
            Takes a string or a scriptblock, use $global:varname to link to Title, Footer or CallbackSelection (available vars: $Selection, $SelectionValue, $MenuOptions, $MenuOptionsInput, $global:*)
        .PARAMETER Selected <Null|Integer>
            Initial string to select
        .PARAMETER Footer <Null|ScriptBlock|String>
            Takes a string or a scriptblock (available vars: $Selection, $SelectionValue, $MenuOptions, $MenuOptionsInput, $global:*)
        .PARAMETER CallbackSelection <Null|ScriptBlock>
            If you want to trigger something on selection or a key, or change the $MenuOptions/$Selection, return $True to exit and return $False to exit and do -CleanHost  (available vars: $Selection, $SelectionValue, $MenuOptions, $MenuOptionsInput, $KeyInput, $global:*) (default: Null)
        .PARAMETER Columns <"Auto"|Integer>
            Define how many columns should be shown (default: "Auto")
        .PARAMETER MaximumColumnWidth <"Auto"|Integer>
            The maximum amount of chars in a cell should be displayed, if to large, '...' will be appended 
            (default: "Auto" if Columns is a number, results in "20" if Columns is "Auto")
        .PARAMETER ShowCurrentSelection <Boolean>
            Shows the current selection text in full length in the console title (default: $True)
        .PARAMETER PassThrou
            Without, will output the index of the selection, otherwise the selected string (default: $False)
        .PARAMETER ReturnObject
            Returns Selection index, SelectionValue string, MenuOptions string[] of maybe modified items, MenuOptionsInput string[] of input strings, Items object of {"Name" maybe modified,"Index","Input" originial string}  -- has a higher priority then PassThrou
        .PARAMETER BackgroundColor <Cyan|ConsoleColor>
            Color for the selection (default: Cyan)
        .PARAMETER ForegroundColor <Black|ConsoleColor>
            Color for the selection (default: Black)
        .PARAMETER ForegroundColorTitle <Cyan|ConsoleColor>
            Color for the title (default: Cyan)
        .PARAMETER ForegroundColorFooter <Black|ConsoleColor>
            Color for the footer (default: Black)

        .PARAMETER CleanHost <Boolean>
            Will clear the menu after selecting from the terminal (default: False)

        .OUTPUTS
            Default is the index of the selected string, using -PassThrou it will be the selected string

        .EXAMPLE
            import-module ./create-menu.ps1
            ls | Create-Menu
                show all files as a selection and return its index upon selecting
        .EXAMPLE
            New-Module -Name "Create Menu" -ScriptBlock ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString("https://gist.githubusercontent.com/BananaAcid/b8efca90cc6ca873fa22a7f9b98d918a/raw/Create-Menu.ps1"))) | Out-Null
            ls | Create-Menu
                show all files as a selection and return its index upon selecting. Loading from remote location.
        .EXAMPLE
            $check = Create-Menu no,yes "Want it?" 1
                Shortest version. "no" first, becuase index 0 is equal to false. the "1" selects index 1 initially
        .EXAMPLE
            $check = Create-Menu @("no","yes") -Title "Want it?" -Selected 1
                Longer version
        .EXAMPLE
             ls | create-menu -passthrou -T "Show Content:" |% {cat $_}
                Outputs a filename's contents after selecting
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
            ls ../ | Create-Menu -Title {"SEL: $SelectionValue`n-----"} -ReturnObject
                A scriptblock with an internal variable, returning the selection opens
        .EXAMPLE
            ls ../ | Create-Menu -Title {Write-Host Green "SEL: $SelectionValue`n-----"}
                A scriptblock with colored title
        .EXAMPLE
            Create-Menu a,b -CallbackSelection {if ($KeyInput -eq 27) { return $False } }
                ESC to cancel input
        .EXAMPLE
            Create-Menu 0,1,2,3 -t {"SEL: $global:ki`n-----"} -CallbackSelection { $global:ki = $KeyInput }
                Show code of pressed key
        .EXAMPLE
            $YesNoCB = { If ($KeyInput -eq 89) { $Selection = 0 ; Return $True } If ($KeyInput -eq 78) { $Selection = 1  ; Return $True } }
            Create-Menu Y,n -CallbackSelection $YesNoCb
                Show "Y" and "n", pressing y (89) or n (78) will select the specific index, exit and show the selected

        .EXAMPLE
            $SpacePressed = { If ($KeyInput -eq 32) { if ($SelectionValue -like '`* *') { $MenuOptions[$Selection] = $MenuOptionsInput[$Selection] } Else {$MenuOptions[$Selection] = '* ' + $SelectionValue } } }
            $ret = ls ~/ | Create-Menu -t {"Full Name: $SelectionValue`n-----"} -CallbackSelection $SpacePressed -ReturnObject
            $selected = $ret.Items |? { $_.Name -like '`* *' } |% Input

                Allows to select multiple files with the space key (Keycode 32), then gets their 

        .NOTES
            Based on: https://community.spiceworks.com/scripts/show/4785-create-menu-2-0-arrow-key-driven-powershell-menu-for-scripts
     #>

    #Start-Transcript "C:\Create-Menu.log"
    [CmdletBinding()]
    Param (                                                                                                         # SHORT:
        [Parameter(ValueFromPipeline=$True ,Mandatory=$True )][Alias("Options")][String[]]$MenuOptions,             # -O -Menu
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Object]$Title = $Null, # ScriptBlock or String       # -T
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Alias("Index")][int]$Selected = $Null,               # -Sel -I

        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Object]$Footer = $Null, # ScriptBlock or String      # -F
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Alias("CB")][ScriptBlock]$CallbackSelection = $Null, # -CB -Call
        
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][String]$Columns = "Auto",                            # -Col
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][String]$MaximumColumnWidth = "Auto",                 # -M -Max
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][bool]$ShowCurrentSelection = $True,                  # -Show
        
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][switch]$PassThrou = $False,                          # -P -Pass
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][switch]$ReturnObject = $False,                       # -R -Ret -Return
        
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Alias("bc")][ConsoleColor]$BackgroundColor = [ConsoleColor]::Cyan,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Alias("fc")][ConsoleColor]$ForegroundColor = [ConsoleColor]::Black,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Alias("ct")][ConsoleColor]$ForegroundColorTitle = [ConsoleColor]::Yellow,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][Alias("cf")][ConsoleColor]$ForegroundColorFooter = [ConsoleColor]::Green,
        
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)][switch]$CleanHost = $False                           # -Clean
    )

    # in case items were pipelined
    $all = @($Input)
    If ($all) {
        $MenuOptions = [array]$all
    }

    $MenuOptionsInput = $MenuOptions.psobject.copy() # | ConvertTo-Json -depth 100 | ConvertFrom-Json
    $ExtraRow = @{}
    $MaxValue = $MenuOptions.count-1
    If ($Selected) { $Selection = $Selected } else { $Selection = 0 }
    $EnterPressed = $False
    $WindowTitleBackup = $Host.UI.RawUI.WindowTitle
    $RowQty = 0

    If ($Columns -eq "Auto") {
        If ($MaximumColumnWidth -eq "Auto") {
            $MaximumColumnWidth = 20
        }

        $WindowWidth = $Host.UI.RawUI.MaxWindowSize.Width
        $Columns = [Math]::Floor($WindowWidth / ([int]$MaximumColumnWidth +2))
    }
    Else {
        If ($MaximumColumnWidth -eq "Auto") {
            $MaximumColumnWidth = [Math]::Floor(($Host.UI.RawUI.MaxWindowSize.Width - [int]$Columns) / [int]$Columns)
        }
    }

    #$consoleTop = $False
    Function ClearHost () {
        #if ($consoleTop -eq $False) {
            $consoleTop = [Console]::CursorTop - $RowQty
        #}
        $top = $consoleTop - ($ExtraRow.Values |Measure-Object -sum).sum # extra rows needed, set: $ExtraRow["uniqueKey"] = someNumOfRows => $ExtraRow["title"] = 2
        [Console]::SetCursorPosition(0, $top) 
    }

    Function CleanHost() {
        $consoleTop = [Console]::CursorTop - $RowQty
        $top = $consoleTop - ($ExtraRow.Values |Measure-Object -sum).sum
        [Console]::SetCursorPosition(0, $top)

        # amount of rows to clean
        $rows = $RowQty + ($ExtraRow.Values |Measure-Object -sum).sum

        # overwrite with clean lines
        $maxLineLength = $Host.UI.RawUI.MaxWindowSize.Width
        Write-Host ( (" " * $maxLineLength + "`n") * $rows ) -NoNewline # clear the lines with NO COLOR

        [Console]::SetCursorPosition(0, $top)
    }

        
    $MenuListing = @()
    Function New-MenuListing($MenuOptions) {
        If ([int]$Columns -gt $MenuOptions.count) {
            $Columns = $MenuOptions.count
        }

        $RowQty = ([Math]::Ceiling(($MaxValue +1) / [int]$Columns))

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
                    $ScratchArray[$j] = $($ScratchArray[$j]).Substring(0,$([int]$MaximumColumnWidth-2))
                    $ScratchArray[$j] = "$($ScratchArray[$j])…"
                }
                Else {
                    For ($k=$ScratchArray[$j].length; $k -lt $ColWidth; $k++) {
                        $ScratchArray[$j] = "$($ScratchArray[$j]) "
                    }
                }
                
                $ScratchArray[$j] = " $($ScratchArray[$j]) "
            }
            $MenuListing += $ScratchArray
        }
        return $MenuListing, $Columns, $RowQty
    }

    Function New-TextBlock ($Block, $BlockName, $ForegroundColor = -1) { # $host.UI.RawUI.ForegroundColor // (Get-Host).UI.RawUI.*
        if ($Block) {
            if ($Block -is [String]) {
                Write-Host $Block
                $ExtraRow[$BlockName] = ($Block | Measure-Object -Line).lines
            }
            else {
                Invoke-Command -ScriptBlock { param($Selection, $SelectionValue, $MenuOptions, $MenuOptionsInput) # supply usable variables
                    Invoke-Command -ScriptBlock $Block *>&1 -OutVariable Lines | Out-Null
                    $ExtraRow[$BlockName] = ($Lines | Measure-Object -Line).lines
                    #Invoke-Command -ScriptBlock $Block # output with color, breaks when using with $x = Create-Menu ... line count does not match anymore
                    #Write-Host $Lines # no color
                    Write-Host -ForegroundColor $ForegroundColor   $Lines # manual color

                    <# has line jumping error. this block was used with ClearHost() to only refresh the the title
                    # write title, scroll down if needed, and get size
                    Invoke-Command -ScriptBlock $Block 6>&1 | Tee-Object -Variable Lines
                    $ExtraRow[$BlockName] = ($Lines | Measure-Object -Line).lines
 
                    # get title position
                    $BlockPos = [Console]::CursorTop - $ExtraRow[$BlockName]

                    # reset title position
                    [Console]::SetCursorPosition(0, $BlockPos)
                    $maxLineLength = $Host.UI.RawUI.MaxWindowSize.Width
                    Write-Host ((" " * $maxLineLength + "`n") * $ExtraRow[$BlockName]) -NoNewline # clear the lines with NO COLOR

                    # reset position and final output
                    [Console]::SetCursorPosition(0, $BlockPos)
                    Invoke-Command -ScriptBlock $Block
#>

                } -ArgumentList $Selection, $MenuOptions[$Selection], $MenuOptions, $MenuOptionsInput
            }
        }
    }

    $MenuListing, $Columns, $RowQty = New-MenuListing $MenuOptions
    
    $clean = $False
    While ($True) {
        
        If ($ShowCurrentSelection) {
            $Host.UI.RawUI.WindowTitle = "CURRENT SELECTION: $($MenuOptions[$Selection])"
        }

        New-TextBlock $Title "title-block" $ForegroundColorTitle

        # output selections
        For ($i=0; $i -lt $RowQty; $i++) {

            For ($j=0; $j -le (($Columns-1)*$RowQty);$j+=$RowQty) {

                If ($j -eq (($Columns-1)*$RowQty)) {
                    If (($i+$j) -eq $Selection){
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
        #Write-Host -ForegroundColor Green "title $($global:title) - $($global:footer)"; $ExtraRow["debug"] = 1
        New-TextBlock $Footer "footer-block" $ForegroundColorFooter

        if ($EnterPressed) {
            If ($CleanHost) {
                CleanHost
            }

            Break
        }

        $KeyInput = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").virtualkeycode

        Switch ($KeyInput) {
            13 { #Enter
                # ignore empty fields
                If ($MenuOptions[$Selection]) {
                    $EnterPressed = $True

                    # set title to before menu
                    If ($ShowCurrentSelection) {
                        $Host.UI.RawUI.WindowTitle = $WindowTitleBackup
                    }

                    If ($CleanHost) {
                        CleanHost
                    }

                    
                    If ($ReturnObject) {

                        $items = @()

                        For ($i=0; $i -lt $MenuOptions.length; $i++) {
                            $items += @{
                                "Name" = $MenuOptions[$i];
                                "Index" = $i;
                                "Input" = $MenuOptionsInput[$i];
                            }
                        }

                        Return @{
                            "Selection" = $Selection;
                            "SelectionValue" = $MenuOptions[$Selection];
                            "MenuOptions" = $MenuOptions;
                            "MenuOptionsInput" = $MenuOptionsInput;
                            "Items" = $items;
                        }
                    }
                    ElseIf ($PassThrou) {
                        Return $MenuOptions[$Selection]
                    }
                    Else {
                        Return $Selection
                    }
                }
                # else:
                #CleanHost

                Break
            }

            37 { #Left
                If ($Selection -ge $RowQty){
                    $Selection -= $RowQty
                } Else {
                    $Selection += ($Columns-1)*$RowQty
                }
                #CleanHost
                Break
            }

            38 { #Up
                If ((($Selection+$RowQty)%$RowQty) -eq 0) {
                    $Selection += $RowQty - 1
                } Else {
                    $Selection -= 1
                }
                #CleanHost
                Break
            }

            39{ #Right
                If ([Math]::Ceiling($Selection/$RowQty) -eq $Columns -or ($Selection/$RowQty)+1 -eq $Columns){
                    $Selection -= ($Columns-1)*$RowQty
                } Else {
                    $Selection += $RowQty
                }
                #CleanHost
                Break
            }

            40 { #Down
                If ((($Selection+1)%$RowQty) -eq 0 -or $Selection -eq $MaxValue){
                    $Selection = ([Math]::Floor(($Selection)/$RowQty))*$RowQty
                    
                } Else {
                    $Selection += 1
                }
                #CleanHost
                Break
            }

            Default {
                #CleanHost
            }
        }

        if ($CallbackSelection -ne $Null) {
            # return new MenuOptions, if you want
            $ret,$sel,$res = Invoke-Command -ScriptBlock { param($Selection, $SelectionValue, $MenuOptions, $MenuOptionsInput, $KeyInput)
                $res = . $CallbackSelection
                
                Return $MenuOptions, $Selection, $res
            } -ArgumentList $Selection, $MenuOptions[$Selection], $MenuOptions, $MenuOptionsInput, $KeyInput

            If ($sel -is [Int]) {
                $Selection = $sel

            }

            If ($res -eq $False) {
                $EnterPressed = $True
                $clean = $True

                # set title to before menu
                If ($ShowCurrentSelection) {
                    $Host.UI.RawUI.WindowTitle = $WindowTitleBackup
                }
            }
            ElseIf ($res -eq $True) {
                $EnterPressed = $True

                # set title to before menu
                If ($ShowCurrentSelection) {
                    $Host.UI.RawUI.WindowTitle = $WindowTitleBackup
                }
            }
            ElseIf ($ret -is [Array]) {
                $MenuOptions = $ret
                $MenuListing, $Columns, $RowQty = New-MenuListing $MenuOptions
            }
        }

        
        CleanHost
    }
}