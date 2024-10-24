#!/usr/bin/env bash

__main() {
    declare -a fonts=("Hack")

    gh_release=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest")

    if [[ "${fonts[0]}" = "all" ]]; then
        # Project all font names into source array
        echo "$gh_release" | \
            jq -r '.assets | .[].name | rtrimstr(".zip")' | \
            while IFS="" read -r font; do fonts+=($font); done
    else
        fonts=("$@")
    fi

    version=$(echo "$gh_release" | jq -r '.tag_name | ltrimstr("v")')
    fonts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    mkdir -p "$fonts_dir"

    for font in "${fonts[@]}"; do
        download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/$version/$font.zip"
        echo "Downloading $download_url"
        curl -fsSL "$download_url" -o "/tmp/$font.zip"
        unzip "/tmp/$font.zip" -d "$fonts_dir"
        rm -f "/tmp/$font.zip"
    done

    find "$fonts_dir" -name '*Windows Compatible*' -delete
    fc-cache -fv
}

__main "$@"
