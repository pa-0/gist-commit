function MyISE {
    param($File)

    if(!(Test-path $File)) {
        New-Item -name $File -itemtype "file"
    }

    ise $file
}