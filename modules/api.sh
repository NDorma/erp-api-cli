#!/usr/bin/env bash

if [ ! "$ERP_API_URL" ]; then
    _cn r "env ERP_API_URL not defined"
    exit 1
fi

if [ ! "$ERP_API_TOKEN" ]; then
    _cn r "env ERP_API_TOKEN not defined"
    exit 1
fi

auth_request() {
    if ! check_credentials; then
        echo "run api auth first!"
        return 1
    fi

    USER_ID=$(get_user_id_from_credentials_file)
    HASH=$(get_hash_from_credentials_file)
    URL_PATH="$1"
    curl -X POST "$ERP_API_URL/$URL_PATH" \
        --silent \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "usuario: $USER_ID" \
        -H "hash: $HASH" \
        "${*:2}"
}

api_auth() {
    read -r -p "Username:" USERNAME
    echo -n "Password:"
    read -r -s PASSWORD
    echo
    RESPONSE=$(curl -X POST "$ERP_API_URL/user/authcheck" \
        --silent \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}")

    if check_response_error "$RESPONSE"; then
        print_response_errors "$RESPONSE"
    else
        print_response_messages "$RESPONSE"
        print_response_data "$RESPONSE"
        save_credentials_from_response "$RESPONSE"
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

    process_response "$RESPONSE"
}
