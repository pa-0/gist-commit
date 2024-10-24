
using namespace System.IO
using namespace Lucene.Net.Analysis
using namespace Lucene.Net.Analysis.Standard
using namespace Lucene.Net.Documents
using namespace Lucene.Net.Index
using namespace Lucene.Net.QueryParsers
using namespace Lucene.Net.Store
using namespace Lucene.Net.Util
using namespace Lucene.Net.Search

cls

rd "C:\Temp\testindex" -Force -Recurse -ErrorAction Ignore

$null=[System.Reflection.Assembly]::LoadFile("$pwd\Lucene.Net.dll")

$analyzer = [StandardAnalyzer]::new("LUCENE_CURRENT")
$directory=[FSDirectory]::Open("C:\Temp\testindex")
$iwriter=[IndexWriter]::new($directory,$analyzer,$true,[IndexWriter+MaxFieldLength]::new(25000))
$count=0

#foreach ($file in ls -r -filter *.txt $PSHOME | % FullName) {    
#foreach ($file in ls -r -filter *.ps1 c:\posh | % FullName) {    
#foreach ($file in ls -r -filter *.cs 'C:\Users\Douglas\Documents\GitHub\PowerShellEditorServices' | % FullName) {    
foreach ($file in ls -r -filter *.ts 'C:\Users\Douglas\Documents\GitHub\vscode' | % FullName) {

    $doc = [Document]::new()
    $text=[io.file]::ReadAllText($file)

    $doc.Add([Field]::new("fulltext",$text,"YES","ANALYZED"))
    $iwriter.AddDocument($doc)
    $count++
}

$iwriter.close()

$isearcher = [IndexSearcher]::new($directory, $true) # read-only-true
$parser = [QueryParser]::new("LUCENE_CURRENT", "fulltext", $analyzer)

while(1) {
    $q = Read-Host "[Docs indexed $($count)] Enter search query (or q to quit)"

    if($q -eq 'q') {break}
    if(!$q) {continue}

    cls

    $query = $parser.Parse($q)

    Write-Host "Query WAS"
    $query|fl|Out-Host
    
    $hits=$isearcher.Search($query,$null,1000).ScoreDocs

    for ($i = 0; $i -lt $hits.Length; $i++) { 
        $hitDoc = $isearcher.Doc($hits[$i].Doc)
        $resText = $hitDoc.Get("fulltext")
        if($resText.Length -gt 120) {
            $resText=$resText.Substring(0,220)
        }
        "$resText`n`n"
    }
}

$isearcher.Close()