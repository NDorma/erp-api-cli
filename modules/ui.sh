#!/usr/bin/env bash

ui_login() {
    read -r -p "Username:" USERNAME
    PASSWORD=$(_read_password "Password:" "*")
    echo
    RESPONSE=$(plain_request "user/authcheck" -d "'{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}'")

    format_response "$RESPONSE" && save_credentials_from_response "$RESPONSE"
}

ui_logout() {
    rm "$CREDENTIALS_FILE"
}

ui_sitios() {
    execute_and_check_oneliner "api_sitios" "jq -r \".data.sitios[] | [.id, .nombre] | @tsv\" | do_fzf"
}

ui_repertorio-search() {
    execute_and_check_oneliner "remember_content repertorio api_repertorio" "jq -r \".data.piezas[] | [.id, .nombre, .autor] | @tsv\" | sed 's/\t/@|@/g' | column -s '@' -t | fzf --multi"
}

ui_servicio-create() {
    if ! ID_SITIO=$(execute_and_check_oneliner "api_sitios" "jq -r \".data.sitios[] | [.id, .nombre] | @tsv\" | do_fzf 'Seleccione el sitio' | cut -f1"); then
        echo "$ID_SITIO"
        return 1
    fi

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

    RESPONSE=$(auth_request "servicio/create" "-d '{
        \"fecha\": \"$FECHA\", 
        \"hora\": \"$HORA\", 
        \"id_interpretes\": \"$ID_INTERPRETES\", 
        \"id_rito\": \"$ID_RITO\", 
        \"id_sitio\": \"$ID_SITIO\", 
        \"id_sala\": \"$ID_SALA\", 
        \"lugar_ceremonia\": \"$LUGAR_CEREMONIA\", 
        \"nombre_difunto\": \"$DIFUNTO\"
    }'")

    format_response "$RESPONSE"
}

ui_cache-flush() {
    flush_cache
}
