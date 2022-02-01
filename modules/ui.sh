#!/usr/bin/env bash

do_fzf() {
    fzf --height 10 --header "$1" --reverse
}

ui_login() {
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

ui_sessioncheck() {
    USER_TOKEN=$(get_user_token_from_credentials_file)
    USER_HASH=$(get_hash_from_credentials_file)
    api_sessioncheck "$USER_TOKEN" "$USER_HASH"
}

ui_logout() {
    rm_credentials_file
}

ui_sitios() {
    execute_and_check_oneliner "api_sitios" "jq -r \".data.sitios[] | [.id, .nombre] | @tsv\" | do_fzf"
}

ui_repertorio() {
    execute_and_check_oneliner \
        "remember_content repertorio api_repertorio" \
        "jq -r \".data.piezas[] | [.id, .nombre, .autor] | @tsv\" \
            | sed 's/\t/@|@/g' | column -s '@' -t \
            | fzf --multi --reverse --preview \"echo Repertorio seleccionado:; cat {+f}\" --header 'multiselección con TAB' \
            | cut -d '|' -f1 | xargs | sed -e 's/ /,/g'"
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

    if _confirm "Repertorio?"; then
        REPERTORIO=$(ui_repertorio)
    fi

    _cn y "Creando servicio..."

    RESPONSE=$(
        api_servicio-create \
            -f "$FECHA" \
            -h "$HORA" \
            -i "$ID_INTERPRETES" \
            -r "$ID_RITO" \
            -s "$ID_SITIO" \
            -t "$ID_SALA" \
            -l "$LUGAR_CEREMONIA" \
            -d "$DIFUNTO" \
            -q "$REPERTORIO"
    )

    format_response "$RESPONSE"
}

ui_cache-flush() {
    flush_cache
}

ui_info() {
    echo "Environment: [$ERP_API_CLI_ENVIRONMENT]"
    echo "API URL    : [$ERP_API_URL]"
    echo "API Token  : [$ERP_API_CLI_TOKEN]"
    echo "User Id    : [$(get_user_id_from_credentials_file)]"
    echo "User Token : [$(get_user_token_from_credentials_file)]"
    echo "User Hash  : [$(get_hash_from_credentials_file)]"
    echo "LANG       : [$LANG]"
    echo "LC_CTYPE   : [$LC_CTYPE]"
}
