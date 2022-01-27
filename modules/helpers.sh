#!/usr/bin/env bash

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

do_hash() {
    echo -n "$1" | sha256sum | cut -d ' ' -f1
}
