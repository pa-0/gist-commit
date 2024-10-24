# Using Pyenv in WSL Ubuntu 22.04 LTS to install Python 3.8

## Env
- Windows 10
- Ubuntu 22.04 WSL
- zsh

## Requirements
- git

## Install pyenv
```
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

## Install deps
```
sudo apt-get install -y \
  make \
  build-essential \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  wget \
  curl \
  llvm \
  libncurses5-dev \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  liblzma-dev
```

## Install Python 3.8
```
> pyenv install 3.8
pyenv: /home/bryancs/.pyenv/versions/3.8.16 already exists
continue with installation? (y/N) y
Downloading Python-3.8.16.tar.xz...
-> https://www.python.org/ftp/python/3.8.16/Python-3.8.16.tar.xz
Installing Python-3.8.16...
Installed Python-3.8.16 to /home/bryancs/.pyenv/versions/3.8.16
```
