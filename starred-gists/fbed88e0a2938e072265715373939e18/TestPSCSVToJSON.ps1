$body = @"
{
  "rowsToSkip": 0,
  "fileName": "MyTestCSVFile.csv",
  "csv":"ID,Name,Score
1,Aaron,99
2,Dave,55
3,Susy,77
"
}
"@

$r=Invoke-RestMethod https://csvtojsonps.azurewebsites.net/api/DoConvert -Method Post -Body $body
$r.fileName
$r.rows