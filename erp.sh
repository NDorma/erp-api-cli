#!/usr/bin/env bash

# shellcheck disable=SC1091
source ./modules/variables.sh
source ./modules/helpers.sh

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
