A lot of comments were written in the original.
Here is an example how to download the latest release (binary) of Gitea to keep your installation up-to-date.

### Used software:

curl
jq
wget

### Download latest release of Gitea based on ending -linux-amd64

#### in `bash`
```shell
curl -s https://api.github.com/repos/go-gitea/gitea/releases/latest | jq -r ".assets[] | select(.name | endswith(\"-linux-amd64\")) | .browser_download_url" | wget -i - -O gitea
```

```shell
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest
| grep "browser_download_url.*deb"
| cut -d '"' -f 4
| wget -qi -
```

Wildcard didn't work on Docker ubuntu:latest But this did. just broke out the greps. 

```shell
curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest
| grep browser_download_url
| grep linux64
| cut -d '"' -f 4
| wget -qi -
```

Shorter PCRE grep: (just get's the version number) 

```shell
curl -s https://api.github.com/repos/USER/REPO/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' curl -sL https://api.github.com/repos/USER/REPO/releases/latest | jq -r '.assets[].browser_download_url'
```

```shell
curl -s https://api.github.com/repos/USER/REPO/releases/latest | jq -r ".assets[] | select(.name | contains("search param for specific download url")) | .browser_download_url" | wget -i -
```

```shell
curl --silent "https://api.github.com/repos/USER/REPO/releases/latest" | # Get latest release from GitHub api grep '"tag_name":' | # Get tag line sed -E 's/."([^"]+)"./\1/' | xargs -I {} curl -sOL "https://github.com/USER/REPO/archive/"{}'.tar.gz'
```

#### windows `batchfiles`

* __Replace__ `OWNERNAME` and `REPONAME` with the Owner's username and Repository name respectively
* __Change__ `"browser_download_url.*zip"` to the appropriate regex match pattern
____
* Use `curl` to get the JSON response for the latest release
* Use `findstr` to find the line containing file URL
* Use `set` and `:=` to extract the URL
* Use `curl` to download it (alternatives are OK, but curl is built-in)

#### Single file ####

`gethub.bat`

```batch
@echo off
FOR /F "tokens=* USEBACKQ" %%F IN (`curl -s "https://api.github.com/repos/OWNERNAME/REPONAME/releases/latest" | findstr "browser_download_url.*zip"`) DO ( SET asset=%%F )
set asset=%asset: =%
set asset=%asset:"=%
set asset=%asset:browser_download_url:=%
curl -L -O %asset%
```
#### Two Files ####

`EXAMPLEAPP-ghu.bat`

```batch
@echo off
set gh_source="https://api.github.com/repos/OWNERNAME/REPONAME/releases/latest"
set asset_match="browser_download_url.*64.*zip"
gethub %gh_source% %asset_match%
pause
```
`gethub.bat` (would recommend adding to PATH)
```batch
set comm="curl -s %1 | findstr %2"
FOR /F "tokens=* USEBACKQ" %%F IN (`%comm%`) DO ( SET asset=%%F )
set asset=%asset: =%
set asset=%asset:"=%
set asset=%asset:browser_download_url:=%
curl -L -O %asset%
```