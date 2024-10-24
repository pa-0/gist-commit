#!/usr/bin/env bash

# Использование:
#
# 1. Установить GitHub Cli версии 2.5.2 или выше: https://github.com/cli/cli/releases
# 2. Авторизоваться: 
#        gh auth login 
# 2.1. При создании токена для авторизации https://github.com/settings/tokens выдать права read и read:org
# 3. Создать папку для хранения репозиториев.
# 4. Зайти в неё.
# 5. Запустить скрипт /path/to/script/download-my-github-repos.sh OWNER
#        где OWNER - ваш логин на github или название организации
#        например: /tmp/download-my-github-repos.sh cronfy
# 
# Произойдет клонирование репозиториев. При повторном запуске происходит обновление (git pull).

# Убедитесь, что склонировались приватные репозитории.

set -eu -o pipefail

OWNER="$1"

function listRepos() {
        local owner="$1"

#       gh repo list "$owner" | awk '{ print $1 }'
        gh repo list "$owner" --json owner,name -t '{{range .}}{{tablerow (printf "%v" .name) .title}}{{end}}'
}

function createDirs() {
        listRepos "$OWNER" | while read repo ; do
                mkdir -p "$repo"
        done
}

function sync() {
        listRepos "$OWNER" | while read repo ; do
                echo "Syncing $repo..."

                mkdir -p "$repo"
                cd "$repo"

                if [ -d '.git' ] ; then
                        git pull
                else
                        git clone git@github.com:"$OWNER"/"$repo".git .
                fi
                cd ../
        done
}

echo "Repos:"
listRepos "$OWNER"

sync
