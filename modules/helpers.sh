#!/usr/bin/env bash

TMP_DIR=$(dirname "$(mktemp -u)")

# ---------------------------- response functions ---------------------------- #

check_response_error() {
    RESPONSE="$*"
    ERROR=$(echo "$RESPONSE" | jq .error)

    [ "$ERROR" == false ]
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

format_response() {
    local RESPONSE
    RESPONSE=$(check_response_error "$*")
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        print_response_errors "$*"
        return $RETVAL
    else
        print_response_messages "$*"
        print_response_data "$*"
    fi
}

# --------------------------- credentials functions -------------------------- #

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

# ------------------------------ cache functions ----------------------------- #

get_cached_content() {
    KEY="$1"
    CACHE_FILENAME="$TMP_DIR/erp-api-cache.$KEY.tmp"

    if [ -f "$CACHE_FILENAME" ]; then
        cat "$CACHE_FILENAME"
    fi
}

set_cached_content() {
    KEY="$1"
    CONTENT="${*:2}"
    CACHE_FILENAME="$TMP_DIR/erp-api-cache.$KEY.tmp"
    echo "$CONTENT" >"$CACHE_FILENAME"
}

remember_content() {
    KEY="$1"
    CALLABLE="${*:2}"
    CACHE_FILENAME="$TMP_DIR/erp-api-cache.$KEY.tmp"

    CONTENT=$(get_cached_content "$KEY")
    if [ ! "$CONTENT" ]; then
        if CONTENT="$($CALLABLE)"; then
            set_cached_content "$KEY" "$CONTENT"
        else
            return $?
        fi
    fi

    echo "$CONTENT"
}

flush_cache() {
    find "$TMP_DIR/" -name "erp-api-cache.*" -print -delete 2>/dev/null
}

# ------------------------- error handling functions ------------------------- #

execute_and_check() {
    RESPONSE=$(eval "$*")
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        if [ $RETVAL == "$ERROR_CREDENTIALS" ]; then
            echo "Error de credenciales, ejectuta 'api auth' nuevamente"
        fi

        echo "Error code [$RETVAL]"
        return $RETVAL
    else
        echo "$RESPONSE"
    fi
}

execute_and_check_oneliner() {
    RESPONSE=$(execute_and_check "$1")
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        echo "$RESPONSE"
        return $RETVAL
    else
        echo "$RESPONSE" | eval "${*:2}"
    fi
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

_read_password() {
    unset password
    prompt="$1"
    character="$2"
    while IFS= read -p "$prompt" -r -s -n 1 char; do
        if [[ $char == $'\0' ]]; then
            break
        fi
        prompt="$character"
        password+="$char"
    done
    echo "$password"
}

_confirm() {
    message=$(_c y "- $1" && echo " [y/N]")
    read -r -p "$message" response
    [ "$response" = "y" ]
}

do_fzf() {
    fzf --height 10 --header "$1" --reverse
}
