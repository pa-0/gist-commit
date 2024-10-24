```bash
sudo apt upgrade && sudo apt update -y

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

wget -c "https://gist.github.com/e-cloud/34acbefe0597a02f9a081a01eff6dd24/raw/3bad7148f60ab70659b0be14ef07b0bd4d019f62/install-mysql8-on-wsl.sh" install-mysql8-on-wsl.sh

chmod 740 install-mysql8-on-wsl.sh

./install-mysql8-on-wsl.sh
```
