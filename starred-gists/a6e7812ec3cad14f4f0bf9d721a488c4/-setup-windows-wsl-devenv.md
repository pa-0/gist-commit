# Setup Windows Subsystem 2 for Linux

**Windows Subsystem 2 for Linux, Hyper, ZSH + Oh My Zsh + Powerlevel9k + plugins, FNM + VSCode (+ext) and Nerd Font**

> To setup native Linux, [see this gist](https://gist.github.com/leodutra/d3b770377bb9188c105b21751bf47e75)

![Preview](https://gist.githubusercontent.com/leodutra/d3b770377bb9188c105b21751bf47e75/raw/img-preview.png)

### Requirements

- Windows 10 Build 18917+ (only as [Windows Insider](https://insider.windows.com/en-us/how-to-pc/) 09/2019)

### Steps

#### 1. Enable WSL2

Run in PowerShell, as admin (elevated):

```ps1
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

#### 2. Install a Linux distro for WSL2

- open Microsoft Store on Windows;
- search for Linux;
- install Ubuntu 18.04 (recommended).

#### 3. Install Chocolatey

Run in CMD, as admin:

```cmd
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
```

#### 4. Install Hyper and VSCode using Chocolatey

Run in CMD, as admin:

```cmd
choco install hyper vscode -y
```

#### 5. Set Hyper to use WSL

- Hyper (icon) > Properties > Compatibility > check "Run as adminstrator";
- open Hyper;
- Edit > Preferences
- change lines:

```json
    shell: 'C:\\Windows\\System32\\wsl.exe',
    shellArgs: [~],
```

- save preferences;
- restart Hyper.

#### 6. Install ZSH and Oh My Zsh

Run in Hyper:

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

#### 7. Install NVM using ZSH


```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
echo "export NVM_DIR=\"$HOME/.nvm\"\n[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"\n[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> ~/.zshrc
source ~/.zshrc
```

#### 8. Install Node (latest) using NVM


```bash
nvm install node
nvm alias default node
```

#### 9. Install Yarn

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --no-install-recommends yarn
```

#### 10. Install Nodemon, PM2, ESLint, Pug

```bash
npm i -g nodemon pm2 eslint pug
```

#### 11. Install neofetch

```bash
sudo apt install neofetch
echo 'neofetch' >> ~/.zshrc
```

#### 12. Install VSCode extensions

[Reference](https://gist.github.com/leodutra/941345a39d1f3b1e13e16a860c3385e0)

#### 13. Install Powerline9k theme for Oh My Zsh

```bash
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
```

Then, add to your `~/.zshrc`:

```bash
ZSH_THEME="powerlevel9k/powerlevel9k"
```

#### 14. Install Powerline specific fonts (Nerd Font or Powerline Fonts)

##### Nerd Fonts

For Windows, download and install manually from:
https://github.com/ryanoasis/nerd-fonts/releases

##### Powerline Fonts

Run in Powershell:

```ps1
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
Set-ExecutionPolicy Bypass
./install.ps1
cd ..
Remove-Item fonts -Recurse -Force
```

##### Recommended fonts

- FuraMono
- FiraCode
- Menlo
- DejaVu Sans
- Hack
- HeavyData

#### 15. Change Hyper font config

- back to Hyper, open Edit > Preferences;
- give font name (`fontFamily: '"FuraMono Nerd Font Mono", "FuraMono Nerd Font", Menlo, "DejaVu Sans Mono", Consolas, "Lucida Console", monospace'`)
- (optional) set `webGLRenderer: false` if you see 1px spaces in Powerline stripes (causes small performance degradation).

#### 16. Setup POWERLEVEL9K_MODE and more variables

Change your `~/.zshrc` and include:

```bash
POWERLEVEL9K_MODE='nerdfont-complete'
```

More options and styling on
https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt

#### 17. Install Hyper plugins

```bash
hyper i hyper-statusline hyper-search hyper-oceanic-next
```


#### 18. Upgrade Ubuntu

```bash
sudo apt upgrade -y
```

#### 19. Install ZSH plugins

##### Install plugins

Run in Hyper:

```bash
# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# fasd
sudo apt install fasd -y
```

##### Edit `~/.zshrc` in WSL

```bash
plugins=(
    ansible
    aws
    command-not-found
    docker
    fasd
    git
    golang
    npm
    nvm
    react-native
    rust
    sudo
    systemd
    ubuntu
    vscode
    web-search
    yarn
    zsh-autosuggestions
    zsh-completions
)
```



#### 21. Recommended VSCode extensions + theme

https://gist.github.com/leodutra/941345a39d1f3b1e13e16a860c3385e0

#### 20. Set VSCode integrated terminal font

```json
{
    "workbench.colorTheme": "Community Material Theme High Contrast",
    "rust-client.engine": "rust-analyzer",
    "terminal.integrated.fontFamily": "'FuraMono Nerd Font'",
    "terminal.integrated.fontSize": 14,
    "terminal.integrated.fontWeight": 600,
    "editor.fontFamily": "'FuraMono Nerd Font'",
    "editor.fontSize": 13,
    "editor.fontWeight": 500,
    "editor.suggestSelection": "first",
}
```

#### 22. Exit Hyper

```bash
exit
```

#### 23. Final .zshrc reference

```bash
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/home/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="nerdfont-complete"

# VSCode specific styling
# "terminal.integrated.env.linux": {
#     "ZSHRC_VSCODE_MODE": "true"
# }
if [ "$ZSHRC_VSCODE_MODE" = "true" ]; then
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
else
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
fi
#POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#POWERLEVEL9K_RPROMPT_ON_NEWLINE=false


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    ansible
    aws
    command-not-found
    docker
    fasd
    git
    golang
    npm
    nvm
    react-native
    rust
    sudo
    systemd
    ubuntu
    vscode
    web-search
    yarn
    zsh-autosuggestions
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

neofetch
```
