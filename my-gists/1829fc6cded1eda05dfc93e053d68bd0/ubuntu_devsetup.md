# Setup Ubuntu Linux Dev Environment

**Terminator, ZSH (+ .zshrc) + Oh My Zsh + Powerlevel9k + plugins, Rust, FNM + VSCode (+ext) and Nerd Font**

> To setup Linux for WSL2, [see this gist](https://gist.github.com/leodutra/a6cebe11db5414cdaedc6e75ad194a00)

![Preview](https://gist.githubusercontent.com/leodutra/d3b770377bb9188c105b21751bf47e75/raw/img-preview.png)

### Requirements

- Ubuntu 20.04 (as reference)

### Steps

```bash
sudo apt update && sudo apt upgrade -y

# Install Terminator
sudo apt install terminator -y

# Install cURL
sudo apt install curl git -y

# Install VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install apt-transport-https    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
sudo apt-get update
sudo apt-get install code # or code-insiders


# Zsh ===================================
# Install Zsh
sudo apt install zsh -y

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# LOG OUT and LOG in

# Install Oh My Zsh plugins
# zsh-completions pĺugin
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
# zsh-autosuggestions pĺugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# fasd pĺugin
sudo apt install fasd -y

# Install Powerlevel9k theme for Oh My Zsh
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# Install Powerlevel9k fonts
sudo apt-get install fonts-powerline -y

# Install Nerd Fonts
# - download and install manually from: https://github.com/ryanoasis/nerd-fonts/releases
# - recommended:
#   - FuraMono
#   - FiraCode
#   - Menlo
#   - DejaVu Sans
#   - Hack
#   - HeavyData


# NODE ==================================
# Install FNM for Zsh
SHELL=/usr/bin/zsh curl -fsSL https://fnm.vercel.app/install | bash

# Reload .zshrc with FNM
source .zshrc

# Install Node (latest) using FNM
fnm install --lts
fnm default "lts/*"

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --no-install-recommends yarn -y

# Install Nodemon, PM2, ESLint, Pug, TypeScript
npm i -g nodemon pm2 eslint pug typescript

# RUST ==================================
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable
rustup component add rls
rustup component add rust-analysis
rustup component add rust-src
rustup component add rustfmt
rustup component add clippy

# Install cargo extensions
# cargo-edit requires libssl-dev
sudo apt install libssl-dev build-essential -y
cargo install cargo-edit
cargo install cargo-cache

# run cargo with sccache
cargo install sccache
echo 'RUSTC_WRAPPER=sccache' >> ~/.zshrc

# Install nightly for/and Racer
rustup toolchain add nightly
cargo +nightly install racer
racer complete std::io::B

# Install neofetch
sudo apt install neofetch -y
echo 'neofetch' >> ~/.zshrc

# Install onefetch
sudo snap install onefetch

# Install starship
curl -fsSL https://starship.rs/install.sh | bash
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

#### Change Zsh theme to Powerlevel9k

Change your `~/.zshrc`, replacing variable names and plugins:

```bash
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE='nerdfont-complete'

# VSCode specific styling (+usage):
# "terminal.integrated.env.linux": {
#     "ZSHRC_VSCODE_MODE": "true"
# }
if [ "$ZSHRC_VSCODE_MODE" = "true" ]; then
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
else
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
fi

# [...]

plugins=(
    ansible
    aws
    command-not-found
    docker
    fasd
    git
    golang
    gradle
    npm
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

*More POWERLEVEL9K options and styling on* https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt

#### Change Terminator font

Using Gnome Tweak, change default monospace font to "FuraMono Nerd Font Mono" (size: 11)
Terminator will automatically be updated, +VSCode integrated terminal and some other emulators.

#### Change Terminator colors

Use "Gray on black" and a variation of "Solarized" (make some colors brighter)
![Terminator color sample](https://gist.githubusercontent.com/leodutra/d3b770377bb9188c105b21751bf47e75/raw/img-terminator-color-scheme.png)

##### ~/.config/terminator/config

```toml
[profiles]
  [[default]]
    background_darkness = 0.9
    background_type = transparent
    cursor_color = "#aaaaaa"
    font = FuraCode Nerd Font Mono Medium 11
    palette = "#073642:#a40000:#5bc00c:#b58900:#2d9be8:#d33682:#2aa198:#eee8d5:#555753:#cb4b16:#586e75:#657b83:#2096a3:#6c71c4:#93a1a1:#fdf6e3"
    show_titlebar = False
    use_system_font = False
```

You can also install the TerminatorThemes plugin:
https://github.com/EliverLara/terminator-themes

#### Install VSCode extensions

https://gist.github.com/leodutra/941345a39d1f3b1e13e16a860c3385e0

#### Visual Studio Code Font and Terminal

```json
{
    "terminal.integrated.fontFamily": "'FuraMono Nerd Font'",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.fontWeight": 500,
    "editor.fontFamily": "'FuraMono Nerd Font'",
    "editor.fontSize": 13,
    "editor.fontWeight": 400,
    "git.autofetch": true,
    "git.enableSmartCommit": true,
    "workbench.iconTheme": "material-icon-theme",
    "workbench.colorTheme": "Material Theme High Contrast",
    "rust-client.engine": "rust-analyzer",
    "javascript.updateImportsOnFileMove.enabled": "always",
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[json]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "window.menuBarVisibility": "toggle",
}
```

#### Latest .zshrc Reference

https://gist.github.com/leodutra/3ae0a87ee20d3c57a9040e06c2d71341