FROM shellspec/shellspec:kcov

RUN apk add --no-cache \
    fzf \
    jq \
    # ncurses for tput
    ncurses
