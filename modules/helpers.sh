#!/usr/bin/env bash

# ----------------------------- invoke subcommand ---------------------------- #

invoke_subcommand() {
    if [ ! "$ERP_API_CLI_ENVIRONMENT" ]; then
        print_cli_error_message 17
        return
    fi

    export ERP_API_URL="${ERP_API_URLS[$ERP_API_CLI_ENVIRONMENT]}"

    if [ ! "$ERP_API_CLI_TOKEN" ]; then
        print_cli_error_message 18
        return
    fi

    if [ "$1" = "" ]; then
        print_cli_error_message 16
        return
    fi

    if [ "$(type -t "$1")" = function ]; then
        eval "$1" "${*:2}"
    else
        eval "${1}_${*:2}"
    fi
}

# ---------------------------- response functions ---------------------------- #

check_response_error() {
    RESPONSE="$*"
    ERROR=$(echo "$RESPONSE" | jq .error)

    if [ "$ERROR" == true ]; then
        return 20
    fi

    return 0
}

print_response_errors() {
    echo "$*" | jq -r ".errors | @tsv" | tr "\t" "\n"
}

print_response_messages() {
    echo "$*" | jq -r ".messages | @tsv" | tr "\t" "\n"
}

print_response_data() {
    echo "$*" | jq -r ".data"
}

format_response() {
    local RESPONSE
    RESPONSE=$(check_response_error "$*")
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        _cn r "$(print_response_errors "$*")"
        return $RETVAL
    else
        _cn g "$(print_response_messages "$*")"
        print_response_data "$*"
    fi
}

# ------------------------- error handling functions ------------------------- #

print_cli_error_message() {
    if [ "$1" != 0 ]; then
        _c r "Error code [$1]. "
        if [ "${EACE_MESSAGES[$1]+keyexists}" ]; then
            _c y "${EACE_MESSAGES[$1]}"
        fi
        echo
    fi

    return "$1"
}

execute_and_check() {
    RESPONSE=$(eval "$*")
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        print_cli_error_message $RETVAL
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

_c() {
    color=${COLORS[$1]}
    echo -ne "$color${*:2}$RESET"
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
