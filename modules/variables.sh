#!/usr/bin/env bash

declare -A EACE_MESSAGES

EACE_MESSAGES[16]="No sub-command provided"
EACE_MESSAGES[19]="Error de credenciales, ejectuta '$0 ui login' nuevamente"
EACE_MESSAGES[20]="Error en la respuesta de la API"

EACE_MESSAGES[17]="env ERP_API_CLI_ENVIRONMENT not defined"
EACE_MESSAGES[18]="env ERP_API_CLI_TOKEN not defined"

export EACE_MESSAGES

declare -A ERP_API_URLS

ERP_API_URLS["testing"]=https://test.erp.ndorma.com/api
ERP_API_URLS["staging"]=https://derp.ndorma.com/api
ERP_API_URLS["production"]=https://erp.ndorma.com/api

export ERP_API_URLS
