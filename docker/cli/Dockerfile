FROM buildpack-deps

RUN apt-get update && apt-get install -y \
    fzf \
    # bdsmainutils for "column" command
    bsdmainutils \ 
    jq

WORKDIR /src

ENV ERP_API_URLS[testing]=https://test.erp.ndorma.com/api
ENV ERP_API_URLS[staging]=https://derp.ndorma.com/api
ENV ERP_API_URLS[production]=https://erp.ndorma.com/api

ENV ERP_API_URL=ERP_API_URLS[$ERP_API_CLI_ENVIRONMENT]

ENTRYPOINT [ "./cli" ]