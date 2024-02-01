#!/usr/bin/env bash

do_hash() {
    echo -n "$*" | sha256sum | cut -d ' ' -f1
}

check_credentials() {
    [ -f "$CREDENTIALS_FILE" ]
}

read_credentials() {
    if ! check_credentials; then
        print_cli_error_message 19
        return 19
    fi

    cat "$CREDENTIALS_FILE"
}

save_credentials_from_response() {
    RESPONSE="$*"
    echo "$RESPONSE" >"$CREDENTIALS_FILE"
}

rm_credentials_file() {
    rm "$CREDENTIALS_FILE"
}

get_user_id_from_credentials_file() {
    check_credentials && read_credentials | jq --raw-output .data.usuario.id
}

get_user_token_from_credentials_file() {
    check_credentials && read_credentials | jq --raw-output .data.usuario.token
}

get_user_name() {
    check_credentials && read_credentials | jq --raw-output .data.usuario.nombre
}

get_hash_from_credentials_file() {
    check_credentials && (
        USER_TOKEN=$(get_user_token_from_credentials_file)
        do_hash "$ERP_API_CLI_TOKEN$USER_TOKEN"
    )
}

login() {
    if [ "$1" == "" ]; then
        read -r -p "Username:" USERNAME
    else
        USERNAME="$1"
    fi

    PASSWORD=$(_read_password "Password:" "*")
    echo
    RESPONSE=$(api_authcheck "$USERNAME" "$PASSWORD")
    format_response "$RESPONSE" && save_credentials_from_response "$RESPONSE"
}

sessioncheck() {
    USER_TOKEN=$(get_user_token_from_credentials_file)
    USER_HASH=$(get_hash_from_credentials_file)
    api_sessioncheck "$USER_TOKEN" "$USER_HASH"
}

logout() {
    rm_credentials_file
}

info() {
    echo "App path   : [$APP_PATH]"
    echo "Modules dir: [$MODULES_PATH]"

    echo "Environment: [$ERP_API_CLI_ENVIRONMENT]"
    echo "API URL    : [$ERP_API_URL]"
    echo "API Token  : [$ERP_API_CLI_TOKEN]"
    echo "Credentials: [$CREDENTIALS_FILE]"
    echo "User Id    : [$(get_user_id_from_credentials_file)]"
    echo "User Name  : [$(get_user_name)]"
    echo "User Token : [$(get_user_token_from_credentials_file)]"
    echo "User Hash  : [$(get_hash_from_credentials_file)]"
    echo "LANG       : [$LANG]"
    echo "LC_CTYPE   : [$LC_CTYPE]"

    echo "Echo 'test': [$(api_echo "test" | jq .data.response)]"
}
