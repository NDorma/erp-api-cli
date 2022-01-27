#!/usr/bin/env bash

# ---------------------------- response functions ---------------------------- #

check_response_error() {
    RESPONSE="$*"
    ERROR=$(echo "$RESPONSE" | jq .error)

    [ "$ERROR" == true ]
}

print_response_errors() {
    _cn r "$(echo "$*" | jq -r ".errors | @tsv" | tr "\t" "\n")"
}

print_response_messages() {
    _cn g "$(echo "$*" | jq -r ".messages | @tsv" | tr "\t" "\n")"
}

print_response_data() {
    echo "$*" | jq -r ".data"
}

process_response() {
    if check_response_error "$*"; then
        print_response_errors "$*"
    else
        print_response_messages "$*"
        print_response_data "$*"
    fi
}

# --------------------------- credentials functions -------------------------- #

TMP_DIR=$(dirname "$(mktemp -u)")
CREDENTIALS_FILE="$TMP_DIR/erp-api-credentials.tmp"

do_hash() {
    echo -n "$*" | sha256sum | cut -d ' ' -f1
}

check_credentials() {
    [ -f "$CREDENTIALS_FILE" ]
}

save_credentials_from_response() {
    RESPONSE="$*"
    USER_TOKEN=$(echo "$RESPONSE" | jq --raw-output .data.usuario.token)
    USER_ID=$(echo "$RESPONSE" | jq --raw-output .data.usuario.id)
    echo "$USER_ID|$USER_TOKEN" >"$CREDENTIALS_FILE"
}

get_user_id_from_credentials_file() {
    cat <"$CREDENTIALS_FILE" | head -n1 | cut -d '|' -f1
}

get_hash_from_credentials_file() {
    USER_TOKEN=$(cat <"$CREDENTIALS_FILE" | head -n1 | cut -d '|' -f2)
    do_hash "$ERP_API_TOKEN$USER_TOKEN"
}

# -------------------------------- ui funtions ------------------------------- #

reset=$(tput sgr0)

declare -A COLORS
COLORS[r]=$(tput setaf 1)
COLORS[g]=$(tput setaf 2)
COLORS[y]=$(tput setaf 3)
COLORS[b]=$(tput setaf 4)

_c() {
    color=${COLORS[$1]}
    echo -ne "$color${*:2}$reset"
}

_cn() {
    # shellcheck disable=SC2005
    echo "$(_c "$1" "${*:2}")"
}

_confirm() {
    message=$(_c y "- $1" && echo " [y/N]")
    read -r -p "$message" response
    [ "$response" = "y" ]
}