#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

DATA_KEY=$1

curl -s http://supervisor/info -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" | jq -r ".data.${DATA_KEY}"
