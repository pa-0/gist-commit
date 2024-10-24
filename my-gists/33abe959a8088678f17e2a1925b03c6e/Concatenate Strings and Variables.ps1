# When we're scripting solutions, we need to understand how to concatenate strings and variables in PowerShell.  "Concatenate" is just a posh word for joining/linking together.

# There are many ways to concatenate strings and variables in PowerShell – below are a few examples:

$join1 = -join ("Join", " ", "me", " ", "together")
Write-Host $join1

$join2 = "{0} {1} {2}" -f "Join", "me", "together"
Write-Host $join2

$join3 = [System.String]::Concat("Join", " ", "Me", " ", "Together")
Write-Host $join3

# The first example uses the join operator (-join), the second example uses the format operator (-f) and the third example uses the .Net Concat method.

# We can apply the same examples above by substituting the strings of text with variables like so:

$word1 = "Join"
$word2 = "me"
$word3 = "together"

$join1 = -join ($word1, " ", $word2, " ", $word3)
Write-Host $join1

$join2 = "{0} {1} {2}" -f $word1, $word2, $word3
Write-Host $join2

$join3 = [System.String]::Concat($word1, " ", $word2, " ", $word3)
Write-Host $join3

$join4 = "$word1 $word2 $word3"
Write-Host $join4

# Note above that we also added a “Join 4” example, where we merely inject the three variables into a string using double quotes to join them together.  This method of substitution works slightly differently when we’re dealing with object properties. Consider this example where, for example, we’re grabbing the ID or a process called ‘explorer’:

#get process ID of first process called 'explorer'
$proc = Get-Process -Name "explorer" | Select-Object -First 1

$join4 = "$word1 $word2 $word3 and the process ID is $proc.id"
Write-Host $join4

# You will notice that that the output is:

# Join me together and the process ID is System.Diagnostics.Process (explorer).id
# Which is not what we want!  What we need to do in these instances is to ask PowerShell to resolve the value of $proc.id by enclosing it inside $() like so:

$proc = Get-Process -Name "explorer" | Select-Object -First 1
$proc.id

$join4 = "$word1 $word2 $word3 and the process ID is $($proc.id)"
Write-Host $join4

And the output is now:

# Join me together and the process ID is 3648
