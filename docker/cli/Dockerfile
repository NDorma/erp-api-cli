FROM buildpack-deps

RUN apt-get update && apt-get install -y \
    fzf \
    # bdsmainutils for "column" command
    bsdmainutils \ 
    jq

WORKDIR /src

ENTRYPOINT [ "./cli" ]