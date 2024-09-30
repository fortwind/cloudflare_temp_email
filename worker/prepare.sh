#!/bin/bash

function replace_value() {
    declare -A replace_mapping
    replace_mapping['database_name']="\"$DB_NAME\""
    replace_mapping['database_id']="\"$DB_ID\""

    ln=0
    while IFS= read -r line; do
        ln=$((ln+1))
        key=$(echo "$line" | awk -F '=' '{ gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1); print $1; }')
        if [ -z "$key" ];then
            continue
        fi
        value="${replace_mapping[$key]:-}"
        if [ ! -z "$value" ];then
            sed -i "${ln}s@.*@${key} = ${value}@" "wrangler.toml"
        fi
    done < "wrangler.toml"
}

replace_value
