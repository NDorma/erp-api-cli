#!/usr/bin/env bash

# ERP_API_URL="https://test.erp.ndorma.com/api"
# ERP_API_TOKEN="421c76d77563afa1914846b010bd164f395bd34c2102e5e99e0cb9cf173c1d87"

if [ ! "$ERP_API_URL" ]; then
    _cn r "env ERP_API_URL not defined"
    exit 1
fi

if [ ! "$ERP_API_TOKEN" ]; then
    _cn r "env ERP_API_TOKEN not defined"
    exit 1
fi

TMP_DIR=$(dirname "$(mktemp -u)")
CREDENTIALS_FILE="$TMP_DIR/erp-api-credentials.tmp"

do_hash() {
    echo -n "$1" | sha256sum | cut -d ' ' -f1
}

check_response_error() {
    RESPONSE="$1"
    ERROR=$(echo "$RESPONSE" | jq .error)

    if [ "$ERROR" == true ]; then
        _cn r "$(echo "$RESPONSE" | jq -r ".errors | @tsv" | tr "\t" "\n")"
        return 1
    fi

    return 0
}

print_response_messages() {
    _cn g "$(echo "$1" | jq -r ".messages | @tsv" | tr "\t" "\n")"
}

print_response_data() {
    echo "$1" | jq -r ".data"
}

auth_request() {
    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo "run api auth first!"
        return 1
    fi

    USER_ID=$(cat <"$CREDENTIALS_FILE" | head -n1 | cut -d '|' -f1)
    USER_TOKEN=$(cat <"$CREDENTIALS_FILE" | head -n1 | cut -d '|' -f2)
    HASH=$(do_hash "$ERP_API_TOKEN$USER_TOKEN")
    # echo "hash:[$ERP_API_TOKEN$USER_TOKEN]>sha256>[$HASH]"
    # echo "user id:[$USER_ID]"
    # echo "user token:[$USER_TOKEN]"
    URL_PATH="$1"
    RESPONSE=$(curl -X POST "$ERP_API_URL/$URL_PATH" \
        --silent \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "usuario: $USER_ID" \
        -H "hash: $HASH" \
        "${*:2}")

    if check_response_error "$RESPONSE"; then
        echo "$RESPONSE"
    fi
}

api_auth() {
    read -r -p "Username:" USERNAME
    echo -n Password:
    read -r -s PASSWORD
    echo
    RESPONSE=$(curl -X POST "$ERP_API_URL/user/authcheck" \
        --silent \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}")

    if check_response_error "$RESPONSE"; then
        print_response_messages "$RESPONSE"
        print_response_data "$RESPONSE"
        USER_TOKEN=$(echo "$RESPONSE" | jq --raw-output .data.usuario.token)
        USER_ID=$(echo "$RESPONSE" | jq --raw-output .data.usuario.id)
        echo "$USER_ID|$USER_TOKEN" >"$CREDENTIALS_FILE"
    fi
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

api_servicio-create() {
    ID_SITIO=$(api_sitios | jq -r ".data.sitios[] | [.id, .nombre] | @tsv" | fzf --height 20 --header "Seleccione el sitio" | cut -f1)
    ID_SALA=$(api_salas "$ID_SITIO" | jq -r ".data.salas[] | [.id, .nombre] | @tsv" | fzf --height 20 --header "Seleccione la sala" | cut -f1)
    ID_INTERPRETES=$(api_interpretes | jq -r ".data.interpretes[] | [.id, .nombre] | @tsv" | fzf --height 20 --header "Seleccione el tipo de servicio" | cut -f1)
    ID_RITO=$(api_ritos | jq -r ".data.ritos[] | [.id, .nombre] | @tsv" | fzf --height 20 --header "Seleccione el rito" | cut -f1)

    DFECHA=$(date +'%Y-%m-%d')
    DHORA=$(date +'%H:%M')
    read -r -p "Fecha (yyyy-mm-dd) [$DFECHA]: " FECHA
    read -r -p "Hora (hh:mm) [$DHORA]: " HORA
    FECHA=${FECHA:-$DFECHA}
    HORA=${HORA:-$DHORA}

    read -r -p "Difunto: " DIFUNTO

    RESPONSE=$(auth_request "servicio/create" "-d {
        \"fecha\": \"$FECHA\", 
        \"hora\": \"$HORA\", 
        \"id_interpretes\": \"$ID_INTERPRETES\", 
        \"id_rito\": \"$ID_RITO\", 
        \"id_sitio\": \"$ID_SITIO\", 
        \"id_sala\": \"$ID_SALA\", 
        \"nombre_difunto\": \"$DIFUNTO\"
    }")

    if check_response_error "$RESPONSE"; then
        print_response_messages "$RESPONSE"
        print_response_data "$RESPONSE"
    fi
}
