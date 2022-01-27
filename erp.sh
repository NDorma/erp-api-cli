#!/usr/bin/env bash

reset=$(tput sgr0)

declare -A COLORS
COLORS[r]=$(tput setaf 1)
COLORS[g]=$(tput setaf 2)
COLORS[y]=$(tput setaf 3)
COLORS[b]=$(tput setaf 4)

# ----------------------------- helper functions ----------------------------- #

_c() {
    color=${COLORS[$1]}
    echo -ne "$color${*:2}$reset"
}

_cn() {
    # shellcheck disable=SC2005
    echo "$(_c "$1" "${*:2}")"
}

_sudo-exec() {
    command="${*:1}"
    _header "$(echo "executing sudo command " && _c b "$command")"
    eval "sudo $command"
}

_confirm() {
    message=$(_c y "- $1" && echo " [y/N]")
    read -r -p "$message" response
    [ "$response" = "y" ]
}

# ----------------------------- invoke subcommand ---------------------------- #

if [ "$1" = "" ]; then
    _cn r "no subcommand provided"
    exit 1
fi

if [ "$(type -t "$1")" = function ]; then
    eval "$1" "${*:2}"
else
    # shellcheck disable=SC1090
    source "./modules/$1.sh"
    eval "${1}_${*:2}"
fi
