#!/usr/bin/env bash

COMMAND=$(basename "$0")
declare -A EACE_MESSAGES
EACE_MESSAGES[16]="No sub-command provided"
EACE_MESSAGES[19]="Error de credenciales, ejectuta el comando '$COMMAND login'"
EACE_MESSAGES[20]="Error en la respuesta de la API"
EACE_MESSAGES[17]="env ERP_API_CLI_ENVIRONMENT not defined"
EACE_MESSAGES[18]="env ERP_API_CLI_TOKEN not defined"
export EACE_MESSAGES

declare -A ERP_API_URLS
ERP_API_URLS["localhost"]=https://localhost.erp.ndorma.com/api
ERP_API_URLS["testing"]=https://test.erp.ndorma.com/api
ERP_API_URLS["staging"]=https://derp.ndorma.com/api
ERP_API_URLS["production"]=https://erp.ndorma.com/api
export ERP_API_URLS

TMP_DIR=$(dirname "$(mktemp -u)")
export TMP_DIR

declare -A COLORS
if [ "$(command -v tput)" ]; then
    RESET=$(tput sgr0)
    COLORS[r]=$(tput setaf 1)
    COLORS[g]=$(tput setaf 2)
    COLORS[y]=$(tput setaf 3)
    COLORS[b]=$(tput setaf 4)
else
    RESET=""
    COLORS[r]=""
    COLORS[g]=""
    COLORS[y]=""
    COLORS[b]=""
fi
export COLORS
export RESET

export CACHE_FILENAME_PREFIX="erp-api-cli.cache"
export CREDENTIALS_FILE="$TMP_DIR/erp-api-cli.session.json"
