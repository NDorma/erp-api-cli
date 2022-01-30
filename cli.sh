#!/usr/bin/env bash

# shellcheck disable=SC1091
source ./modules/variables.sh
source ./modules/helpers.sh
source ./modules/api.sh
source ./modules/ui.sh

# ------------------------ environment variables check ----------------------- #

if [ ! "$ERP_API_URL" ]; then
    _cn r "env ERP_API_URL not defined"
    exit 1
fi

if [ ! "$ERP_API_TOKEN" ]; then
    _cn r "env ERP_API_TOKEN not defined"
    exit 1
fi

# ----------------------------- invoke subcommand ---------------------------- #

if [ "$1" = "" ]; then
    _cn r "no subcommand provided"
    exit 1
fi

if [ "$(type -t "$1")" = function ]; then
    eval "$1" "${*:2}"
else
    eval "${1}_${*:2}"
fi
