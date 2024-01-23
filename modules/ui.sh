#!/usr/bin/env bash

do_fzf() {
    fzf --height 10 --header "$1" --reverse
}

ui_sitios() {
    execute_and_check_oneliner "api_sitios" "jq -r \".data.sitios[] | [.id, .nombre] | @tsv\" | do_fzf"
}

ui_repertorio() {
    execute_and_check_oneliner \
        "remember_content repertorio.json api_repertorio" \
        "jq -r \".data.piezas[] | [.id, .nombre, .autor] | @tsv\" \
            | sed 's/\t/@|@/g' | column -s '@' -t \
            | fzf --multi --reverse --preview \"echo Repertorio seleccionado:; cat {+f}\" --header 'multiselección con TAB' \
        | cut -d '|' -f1 | xargs | sed -e 's/ /,/g'"
}

ui_servicio-info() {
    execute_and_check_oneliner "api_servicio-info $1" "jq -r \".data.servicio | {uuid: .uuid, expediente: .expediente, fecha: .fecha, hora: .hora, sitio: .sitio.nombre, sala: .sala.nombre, interpretes: .interpretes.nombre, rito: .rito.nombre, estado: .estado.nombre, difunto: .nombre_difunto, repertorio: [.repertorio[].nombre], obervaciones: .observaciones, observaciones_comercial: .observaciones_comercial, entornos: [.sitio.entornos[].nombre]}\""
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
