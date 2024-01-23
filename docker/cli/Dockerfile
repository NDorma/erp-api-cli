FROM buildpack-deps

RUN apt-get update && apt-get install -y \
    locales locales-all \
    fzf \
    # bdsmainutils for "column" command
    bsdmainutils \ 
    jq

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /src

CMD [ "./bin/eac" ]
