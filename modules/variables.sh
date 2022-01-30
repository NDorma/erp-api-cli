#!/usr/bin/env bash

export EACE_SUBCOMMAND_MISSING=16
export EACE_ENV_API_URL_NOT_DEFINED=17
export EACE_ENV_API_TOKEN_NOT_DEFINED=18
export EACE_CREDENTIALS=19
export EACE_API_RESPONSE_ERROR=20

declare -A EACE_MESSAGES

EACE_MESSAGES[$EACE_SUBCOMMAND_MISSING]="No sub-command provided"
EACE_MESSAGES[$EACE_CREDENTIALS]="Error de credenciales, ejectuta '$0 ui login' nuevamente"
EACE_MESSAGES[$EACE_API_RESPONSE_ERROR]="Error en la respuesta de la API"

EACE_MESSAGES[$EACE_ENV_API_URL_NOT_DEFINED]="env ERP_API_URL not defined"
EACE_MESSAGES[$EACE_ENV_API_TOKEN_NOT_DEFINED]="env ERP_API_TOKEN not defined"

export EACE_MESSAGES