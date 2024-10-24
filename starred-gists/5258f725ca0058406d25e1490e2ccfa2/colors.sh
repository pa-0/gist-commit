#!/usr/bin/env bash

function bake_fg_color {
    BLACK="\033[0;30m"
    BLACK_BOLD="\033[1;30m"
    WHITE="\033[0;37m"
    WHITE_BOLD="\033[1;37m"
    RED="\033[0;31m"
    RED_BOLD="\033[1;31m"
    GREEN="\033[0;32m"
    GREEN_BOLD="\033[1;32m"
    YELLOW="\033[0;33m"
    YELLOW_BOLD="\033[1;33m"
    BLUE="\033[0;34m"
    BLUE_BOLD="\033[1;34m"
    PURPLE="\033[0;35m"
    PURPLE_BOLD="\033[1;35m"
    CYAN="\033[0;36m"
    CYAN_BOLD="\033[1;36m"
    NO_COLOR="\033[0m"

    CHOSEN_COLOR="${1}"
    ARGV_INPUT="${2}"

    COLOR="${!CHOSEN_COLOR}"

    if [ -z "$ARGV_INPUT" ]; then
        read -r INPUT
    else
        INPUT="$ARGV_INPUT"
    fi
    echo -e "${COLOR}${INPUT}${NO_COLOR}"
}

function red {
    bake_fg_color 'RED' "$1"
}
