if((get-command npm -ErrorAction SilentlyContinue) -eq $null ) {
  write-host "please install npm"
  return
}

$pkgjson = @"
{
  "name": "test",
  "version": "0.0.1",
  "scripts": {
    "simpleserver": "node_modules/.bin/http-server -c-1 ./ -p 8888"
  },
  "dependencies": {
    "http-server": "^0.9.0"
  }
}
"@

$pkgjson | Set-Content package.json -Encoding Ascii

write-host "Installing server"
$null=npm install
$null = start-job { sleep 1 ; start http://127.0.0.1:8888 }
write-host "Launching browser @ http://127.0.0.1:8888"
$null=npm run simpleserver