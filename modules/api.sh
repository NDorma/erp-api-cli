#!/usr/bin/env bash

if [ ! "$ERP_API_URL" ]; then
    _cn r "env ERP_API_URL not defined"
    return 1
fi

if [ ! "$ERP_API_TOKEN" ]; then
    _cn r "env ERP_API_TOKEN not defined"
    return 1
fi

auth_request() {
    if ! check_credentials; then
        echo "run api auth first!"
        return 1
    fi

    USER_ID=$(get_user_id_from_credentials_file)
    HASH=$(get_hash_from_credentials_file)
    URL_PATH="$1"
    EXTRA_PARAMS="${*:2}"
    if [ "$EXTRA_PARAMS" ]; then
        curl --silent -X POST "$ERP_API_URL/$URL_PATH" -H 'accept: application/json' -H 'Content-Type: application/json' -H "usuario: $USER_ID" -H "hash: $HASH" "$EXTRA_PARAMS"
    else
        curl --silent -X POST "$ERP_API_URL/$URL_PATH" -H 'accept: application/json' -H 'Content-Type: application/json' -H "usuario: $USER_ID" -H "hash: $HASH"
    fi
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

api_logout() {
    rm "$CREDENTIALS_FILE"
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
    ID_SITIO=$(api_sitios | jq -r ".data.sitios[] | [.id, .nombre] | @tsv" | do_fzf "Seleccione el sitio" | cut -f1)

    SALA_SELECTION=$(api_salas "$ID_SITIO" | jq -r ".data.salas[] | [.id, .has_texto_adicional, .nombre] | @tsv" | do_fzf "Seleccione la sala")
    ID_SALA=$(echo "$SALA_SELECTION" | cut -f1)
    HTA=$(echo "$SALA_SELECTION" | cut -f2)
    LUGAR_CEREMONIA=""
    if [ "$HTA" == true ]; then
        read -r -p "Lugar de ceremonia: " LUGAR_CEREMONIA
    fi

    ID_INTERPRETES=$(api_interpretes | jq -r ".data.interpretes[] | [.id, .nombre] | @tsv" | do_fzf "Seleccione el tipo de servicio" | cut -f1)
    ID_RITO=$(api_ritos | jq -r ".data.ritos[] | [.id, .nombre] | @tsv" | do_fzf "Seleccione el rito" | cut -f1)

    DFECHA=$(date +'%Y-%m-%d')
    DHORA=$(date +'%H:%M')
    read -r -p "Fecha (yyyy-mm-dd) [$DFECHA]: " FECHA
    read -r -p "Hora (hh:mm) [$DHORA]: " HORA
    FECHA=${FECHA:-$DFECHA}
    HORA=${HORA:-$DHORA}

    read -r -p "Difunto: " DIFUNTO

    _cn y "Creando servicio..."

    RESPONSE=$(auth_request "servicio/create" "-d {
        \"fecha\": \"$FECHA\", 
        \"hora\": \"$HORA\", 
        \"id_interpretes\": \"$ID_INTERPRETES\", 
        \"id_rito\": \"$ID_RITO\", 
        \"id_sitio\": \"$ID_SITIO\", 
        \"id_sala\": \"$ID_SALA\", 
        \"lugar_ceremonia\": \"$LUGAR_CEREMONIA\", 
        \"nombre_difunto\": \"$DIFUNTO\"
    }")

    format_response "$RESPONSE"
}

api_repertorio-search() {
    remember_content "repertorio" "api_repertorio" | jq -r ".data.piezas[] | [.id, .nombre, .autor] | @tsv" | sed 's/\t/@|@/g' | column -s '@' -t | fzf
}

api_cache-flush() {
    flush_cache
}
