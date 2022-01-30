#!/usr/bin/env bash

# shellcheck disable=SC1091
source ./modules/variables.sh
source ./modules/helpers.sh
source ./modules/api.sh
source ./modules/ui.sh

# ------------------------ environment variables check ----------------------- #

if [ ! "$ERP_API_URL" ]; then
    print_cli_error_message "$EACE_ENV_API_URL_NOT_DEFINED"
    exit
fi

if [ ! "$ERP_API_TOKEN" ]; then
    print_cli_error_message "$EACE_ENV_API_TOKEN_NOT_DEFINED"
    exit
fi

# ----------------------------- invoke subcommand ---------------------------- #

if [ "$1" = "" ]; then
    print_cli_error_message "$EACE_SUBCOMMAND_MISSING"
    exit
fi

if [ "$(type -t "$1")" = function ]; then
    eval "$1" "${*:2}"
else
    eval "${1}_${*:2}"
fi
