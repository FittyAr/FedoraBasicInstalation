#!/bin/bash

# Directorios de configuración
CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../../config"
APPS_DIR="$CONFIG_DIR/apps"
REPAIR_FILE="$CONFIG_DIR/repair_tools.json"

# El idioma se debe definir en install.sh (es, en, etc.)
# Si no está definido, por defecto es 'es'
export LANG_CODE="${LANG_CODE:-es}"


# Archivo temporal para el JSON consolidado
export MASTER_JSON_FILE="/tmp/fedora_installer_master.json"

build_master_json() {
    # Combinar todos los archivos en uno solo para consultas rápidas
    local tmp_dir=$(mktemp -d)
    for f in "$APPS_DIR/"*.json; do
        [ -e "$f" ] || continue
        local id=$(basename "$f" .json)
        jq --arg id "$id" '. + {id: $id}' "$f" > "$tmp_dir/$id.json"
    done
    jq -s 'reduce .[] as $item ({}; .categories[$item.id] = $item)' "$tmp_dir/"*.json > "$MASTER_JSON_FILE"
    rm -rf "$tmp_dir"
}

get_categories() {
    local name_field="name"
    [ "$LANG_CODE" != "es" ] && name_field="name_$LANG_CODE"
    jq -r ".categories[] | \"\(.id)|\(.$name_field // .name)\"" "$MASTER_JSON_FILE"
}

get_apps_by_category() {
    local cat_id=$1
    jq -r ".categories[\"$cat_id\"].apps[] | \"\(.id)|\(.name)|\(.description.$LANG_CODE // .description.es)\"" "$MASTER_JSON_FILE"
}

get_app_data() {
    local app_id=$1
    local field=$2
    
    # Query optimizada sobre el master file
    if [[ "$field" == "description" ]]; then
        jq -r ".categories[].apps[] | select(.id==\"$app_id\") | .description.$LANG_CODE // .description.es" "$MASTER_JSON_FILE" | head -n 1
    else
        jq -r ".categories[].apps[] | select(.id==\"$app_id\") | .$field" "$MASTER_JSON_FILE" | head -n 1
    fi
}

get_app_priority() {
    local app_id=$1
    jq -r ".categories[].apps[] | select(.id==\"$app_id\") | .priority[]" "$MASTER_JSON_FILE"
}

get_global_repair_tools() {
    jq -r ".repair_tools[] | \"\(.id)|\(.name.$LANG_CODE // .name.es)\"" "$REPAIR_FILE"
}

get_repair_command() {
    local rid=$1
    local cmd=$(jq -r ".repair_tools[] | select(.id==\"$rid\") | .command" "$REPAIR_FILE" 2>/dev/null)
    [ "$cmd" != "null" ] && [ -n "$cmd" ] && echo "$cmd" && return
    get_app_data "$rid" "repair"
}

