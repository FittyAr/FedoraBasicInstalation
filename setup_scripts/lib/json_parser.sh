#!/bin/bash

JSON_FILE="$(dirname "${BASH_SOURCE[0]}")/../../config/software.json"

get_categories() {
    jq -r '.categories[] | "\(.id)|\(.name)"' "$JSON_FILE"
}

get_apps_by_category() {
    local cat_id=$1
    jq -r ".categories[] | select(.id==\"$cat_id\") | .apps[] | \"\(.id)|\(.name)|\(.description)\"" "$JSON_FILE"
}

get_app_data() {
    local app_id=$1
    local field=$2
    jq -r ".categories[].apps[] | select(.id==\"$app_id\") | .$field" "$JSON_FILE"
}

get_app_priority() {
    local app_id=$1
    jq -r ".categories[].apps[] | select(.id==\"$app_id\") | .priority[]" "$JSON_FILE"
}
