#!/usr/bin/env bash

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

rm_credentials_file() {
    rm "$CREDENTIALS_FILE"
}

get_user_id_from_credentials_file() {
    cat <"$CREDENTIALS_FILE" | head -n1 | cut -d '|' -f1
}

get_hash_from_credentials_file() {
    USER_TOKEN=$(cat <"$CREDENTIALS_FILE" | head -n1 | cut -d '|' -f2)
    do_hash "$ERP_API_CLI_TOKEN$USER_TOKEN"
}
