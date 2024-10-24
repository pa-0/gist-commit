$t=@"
<![LOG[CScanAgent::ScanComplete- Scan completion received.]LOG]!><time="14:38:21.182+300" date="05-06-2016" component="ScanAgent" context="" type="1" thread="5316" file="cscanagent.cpp:1504">
"@

$r=$t.split("<")[-1]
$r=$r.Substring(0,$r.length-1) -replace ' ',';'
"@{$($r)}" | Invoke-Expression

Name                           Value                                                                                              
----                           -----                                                                                              
component                      ScanAgent                                                                                          
file                           cscanagent.cpp:1504                                                                                
type                           1                                                                                                  
date                           05-06-2016                                                                                         
context                                                                                                                           
time                           14:38:21.182+300                                                                                   
thread                         5316                                                                                               