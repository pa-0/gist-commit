# `GitHub release one-liner`

* Use `curl` to get the JSON response for the latest release
* Use `grep` to find the line containing file URL
* Use `cut` and `tr` to extract the URL
* Use `wget` to download it

```bash
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
| grep "browser_download_url.*deb" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
```