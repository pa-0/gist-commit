function Test-Email {
    param($targetEmail)
    
    $targetEmail -match "^([a-z]{1,10})\.([a-z]{1,10})@[a-z]+\.com$"
}

$tests=$(
"robert.houtenbrink@domain.com"
"doug.finke@hotmail.com"
"1doug.finke@hotmail.com"
"doug1.finke@hotmail.com"
"doug.1finke@hotmail.com"
"doug.finke@hotmail1.com"
"doug.finke@hotmail.com1"
"doug.finke@microsoft.com"

"aaaaaaaaaaa.finke@microsoft.com"
"doug.aaaaaaaaaaa@microsoft.com"
"abcdefghij.abcdefghij@microsoft.com"
)

$tests | % { 
    [PSCustomObject]@{
        Test=$_
        Match=Test-Email $_
    }
} 