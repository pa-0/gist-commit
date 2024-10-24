Import-Module TabExpansionPlusPlus

function SuggestCompletion {
    param($wordToComplete, $commandAst)

    Set-Alias -Name nct -Value New-CommandTree

    $commandTree = & {
        nct {
            param($wordToComplete, $commandAst)

            if($wordToComplete) {
                (Invoke-RestMethod -Uri "http://api.bing.com/qsml.aspx?query=$($wordToComplete)").searchsuggestion.section.item |
                    % {
                        if($_.text.IndexOf(' ') -ge 0) {
                            "'{0}'" -f $_.text
                        } else {
                            $_.text
                        }                        
                    }                
            }    
        }                        
    }

    Get-CommandTreeCompletion $wordToComplete $commandAst $commandTree
}

Register-ArgumentCompleter -Command 'suggest' -native -ScriptBlock $function:SuggestCompletion -Description 'Bing Suggestions'