<#
 .Synopsis
    Glossary Module
 .DESCRIPTION
    A Powershell Module that includes a function for searching a CSV file which is a Glossary of terms and presents the results in a variety of formats.
 .EXAMPLE
    Search-Glossary MyTerm
 .EXAMPLE
    Search-Glossary MyTerm -PassThru | Export-CSV MyTerms.csv
 #>
 
Function Search-Glossary
{
    [CmdletBinding()]
    Param
    (
        $Term,
        [switch]$PassThru = $False
    )
    Process{
        $Matches = (Import-CSV "$PSScriptRoot\Glossary.csv") | Where-Object {$_.Term -like "$Term*"}
        
        If (($Matches | Measure-Object).Count -eq 1){

            Write-Host "`n    TERM"
            Write-Host "`t$($Matches.Term)`n"
            
            If ($Matches.Category){
                Write-Host "    CATEGORY"
                Write-Host "`t$($Matches.Category)`n"
            }
            If ($Matches.Description){
                Write-Host "    DESCRIPTION"
                Write-Host "$(wrapText($Matches.Description))`n"
            }
            If ($Matches.Link){
                Write-Host "    LINK"
                Write-Host "`t$($Matches.Link)`n"
            }
            
        }ElseIf(!$PassThru){
            Return $Matches | FL
        }Else{
            Return $Matches
        }
    }
}

Function wrapText( $text, $width=($host.UI.RawUI.BufferSize.Width-10) )
{
    $words = $text -split "\s+"
    $col = 0
    Write-Host -NoNewline "`t"

    foreach ( $word in $words )
    {
        $col += $word.Length + 1
        if ( $col -gt $width )
        {
            Write-Host ""
            $col = $word.Length + 1
            Write-Host -NoNewline "`t"
        }
        Write-Host -NoNewline "$word "
    }
}