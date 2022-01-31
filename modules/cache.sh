#!/usr/bin/env bash

get_cache_filename() {
    echo "$TMP_DIR/$CACHE_FILENAME_PREFIX.$1.tmp"
}

get_cached_content() {
    CACHE_FILENAME=$(get_cache_filename "$KEY")

    if [ -f "$CACHE_FILENAME" ]; then
        cat "$CACHE_FILENAME"
    fi
}

set_cached_content() {
    KEY="$1"
    CONTENT="${*:2}"
    CACHE_FILENAME=$(get_cache_filename "$KEY")
    echo "$CONTENT" >"$CACHE_FILENAME"
}

remember_content() {
    KEY="$1"
    CALLABLE="${*:2}"

    CONTENT=$(get_cached_content "$KEY")
    if [ ! "$CONTENT" ]; then
        if CONTENT="$($CALLABLE)"; then
            set_cached_content "$KEY" "$CONTENT"
        else
            return $?
        fi
    fi

    echo "$CONTENT"
}

flush_cache() {
    find "$TMP_DIR/" -name "$CACHE_FILENAME_PREFIX.*" -print -delete 2>/dev/null
    return 0
}
