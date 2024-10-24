export ZSH="/home/sean/.oh-my-zsh"

ZSH_THEME=""

COMPLETION_WAITING_DOTS="true"

plugins=(
  aws
  docker
  dotnet
  # git
  # kube-ps1
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

HISTORY_IGNORE='(bg|fg|clear|exit|h|history|l|l[als]|pwd)'
HISTSIZE=10000

export AWS_PAGER=
export EDITOR=vi
export KUBECONFIG=$(find ~/.kube -maxdepth 1 -type f 2>/dev/null | grep -E 'config[^.]*$' | xargs -I{} -r echo -n ':{}')
export PATH=$HOME/.dotnet/tools:$PATH

alias h='history'
alias l='ls -aF'
alias ll='ls -ahlF'
alias ls='ls --color=auto --group-directories-first'

alias cake='_cake() { local args="$@"; bash -c "dotnet tool restore && dotnet cake --verbosity=verbose $args"; }; _cake'
alias cake-docker='_cake() { local args="$@"; docker run -it --rm --user user -w /build -v "$(pwd):/build" -v /var/run/docker.sock:/var/run/docker.sock -v /home/sean/.nuget:/home/user/.nuget -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION dockfool/cake-docker bash -c "dotnet tool restore && dotnet cake --verbosity=verbose $args"; }; _cake'

setopt SH_WORD_SPLIT

eval "$(starship init zsh)"
