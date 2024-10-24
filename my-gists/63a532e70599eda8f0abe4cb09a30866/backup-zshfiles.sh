#!/usr/bin/env bash
setopt extended_glob
set +e
export ZDOTDIR=$HOME/.config/zsh
zfiles=( "$HOME/.zlogin" "$HOME/.zlogout" "$HOME/.zpreztorc" "$HOME/.zprofile" "$HOME/.zsh_history" "$HOME/.zshenv" "$HOME/.zshrc" )
echo "$zfiles"
mkdir -p ~/.bak
for zfile in "${zfiles[@]}"; do
echo "backing up $zfile"
  (cp $zfile ~/.bak 2>/dev/null || true)
done

for zfile in "${zfiles[@]}"; do
echo "removed original $zfile"
  rm $zfile
done

unset zfile zfiles

