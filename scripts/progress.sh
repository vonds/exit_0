#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUCCESS_JSON="$SCRIPT_DIR/../data/.challenge_success.json"

[ ! -f "$SUCCESS_JSON" ] && echo "{}" > "$SUCCESS_JSON"

get_success_count() {
    local num=$1
    jq -r --arg num "$num" '.[$num] // 0' "$SUCCESS_JSON"
}

update_success_log() {
    local num=$1
    local current=$(get_success_count "$num")
    local next=$((current + 1))

    cp "$SUCCESS_JSON" "$SUCCESS_JSON.bak"

    tmp=$(mktemp)
    jq --arg num "$num" --argjson val "$next" \
       '. + {($num): $val}' "$SUCCESS_JSON" > "$tmp" && mv "$tmp" "$SUCCESS_JSON"
}
