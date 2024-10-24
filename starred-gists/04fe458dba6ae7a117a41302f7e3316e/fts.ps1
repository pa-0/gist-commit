function fts {
    param($find)

    if($find) {
        Get-ChildItem . -Recurse *.ts | Select-String $find
    } else {
        Get-ChildItem . -Recurse *.ts
    }
}
