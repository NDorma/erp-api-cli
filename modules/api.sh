#!/usr/bin/env bash

if [ ! "$ERP_API_URL" ]; then
    _cn r "env ERP_API_URL not defined"
    return 1
fi

if [ ! "$ERP_API_TOKEN" ]; then
    _cn r "env ERP_API_TOKEN not defined"
    return 1
fi

plain_request() {
    URL_PATH="$1"
    EXTRA_PARAMS="${*:2}"
    eval "curl --silent -X POST $ERP_API_URL/$URL_PATH -H 'accept: application/json' -H 'Content-Type: application/json' $EXTRA_PARAMS"
}

auth_request() {
    if ! check_credentials; then
        return "$ERROR_CREDENTIALS"
    fi

    USER_ID=$(get_user_id_from_credentials_file)
    HASH=$(get_hash_from_credentials_file)
    URL_PATH="$1"
    EXTRA_PARAMS="${*:2}"
    plain_request "$URL_PATH" "-H 'usuario: $USER_ID' -H 'hash: $HASH' $EXTRA_PARAMS"
}

api_authcheck() {
    plain_request "user/authcheck" -d "'{\"username\": \"$1\", \"password\": \"$2\"}'"
}

api_repertorio() {
    auth_request "repertorio"
}

api_sitios() {
    auth_request "servicio/get/sitios"
}

api_salas() {
    ID_SITIO="$1"
    auth_request "servicio/get/salas/$ID_SITIO"
}

api_interpretes() {
    auth_request "servicio/get/interpretes"
}

api_ritos() {
    auth_request "servicio/get/ritos"
}
