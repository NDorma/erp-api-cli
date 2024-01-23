#!/usr/bin/env bash

do_hash() {
    echo -n "$*" | sha256sum | cut -d ' ' -f1
}

check_credentials() {
    [ -f "$CREDENTIALS_FILE" ]
}

save_credentials_from_response() {
    RESPONSE="$*"
    echo "$RESPONSE" >"$CREDENTIALS_FILE"
}

rm_credentials_file() {
    rm "$CREDENTIALS_FILE"
}

get_user_id_from_credentials_file() {
    cat <"$CREDENTIALS_FILE" | jq --raw-output .data.usuario.id
}

get_user_token_from_credentials_file() {
    cat <"$CREDENTIALS_FILE" | jq --raw-output .data.usuario.token
}

get_hash_from_credentials_file() {
    USER_TOKEN=$(get_user_token_from_credentials_file)
    do_hash "$ERP_API_CLI_TOKEN$USER_TOKEN"
}
