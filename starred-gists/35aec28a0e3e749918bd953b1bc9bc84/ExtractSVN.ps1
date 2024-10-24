$svninfo = @{}
svn help | 
    ?{$_ -match "^   "} | 
    %{($_.trim() -split " ")[0]} | 
    %{        
        $command = $_
        if(!$svninfo.ContainsKey($command)) {
            $svninfo.$command=@{SingleHyphen=@();DoubleHyphen=@()}
        }

        svn help $_ |
            ?{$_ -match "^\s+-"} | 
            %{
            $_.Trim() | % {
                $parameter = (($_ -split ":")[0] -split ' ')[0]                
                if($parameter.StartsWith("--")) {
                    $svninfo.$command.DoubleHyphen+=$parameter -replace '--', ''
                } else {
                    $svninfo.$command.SingleHyphen+=$parameter -replace '-', ''                   
                }
            }
        }
    } 

$svninfo 