#!/bin/bash

# Directorios de configuración
CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../../config"
APPS_DIR="$CONFIG_DIR/apps"
REPAIR_FILE="$CONFIG_DIR/repair_tools.json"

# El idioma se debe definir en install.sh (es, en, etc.)
# Si no está definido, por defecto es 'es'
export LANG_CODE="${LANG_CODE:-es}"


# Archivo temporal para el JSON consolidado
export MASTER_JSON_FILE="/tmp/fedora_installer_master_$USER.json"

build_master_json() {
    # Combinar todos los archivos en uno solo para consultas rápidas
    local tmp_dir=$(mktemp -d)
    for f in "$APPS_DIR/"*.json; do
        [ -e "$f" ] || continue
        local id=$(basename "$f" .json)
        jq --arg id "$id" '. + {id: $id}' "$f" > "$tmp_dir/$id.json"
    done
    jq -s 'reduce .[] as $item ({}; .categories[$item.id] = $item)' "$tmp_dir/"*.json > "$MASTER_JSON_FILE" 2>/tmp/jq_err.log
    if [ $? -ne 0 ]; then
        echo "$STR_ERR_MASTER_JSON"
        rm -rf "$tmp_dir"
        return 1
    fi
    rm -rf "$tmp_dir"
}

get_categories() {
    [ ! -f "$MASTER_JSON_FILE" ] && return 1
    local name_field="name"
    [ "$LANG_CODE" != "es" ] && name_field="name_$LANG_CODE"
    jq -r ".categories[] | \"\(.id)|\(.$name_field // .name)\"" "$MASTER_JSON_FILE" 2>/dev/null
}

get_apps_by_category() {
    local cat_id=$1
    jq -r ".categories[\"$cat_id\"].apps[]? | \"\(.id)|\(.name)|\(.description.$LANG_CODE // .description.es)\"" "$MASTER_JSON_FILE"
}

get_app_data() {
    local app_id=$1
    local field=$2
    
    # Query optimizada sobre el master file
    if [[ "$field" == "description" ]]; then
        jq -r ".categories[].apps[]? | select(.id==\"$app_id\") | .description.$LANG_CODE // .description.es" "$MASTER_JSON_FILE" | head -n 1
    else
        jq -r ".categories[].apps[]? | select(.id==\"$app_id\") | .$field" "$MASTER_JSON_FILE" | head -n 1
    fi
}

get_app_priority() {
    local app_id=$1
    jq -r ".categories[].apps[]? | select(.id==\"$app_id\") | .priority[]?" "$MASTER_JSON_FILE"
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

get_app_category_id() {
    local app_id=$1
    # Buscamos en qué categoría está la app de forma segura
    jq -r ".categories[] | select(any(.apps[]?; .id == \"$app_id\")) | .id" "$MASTER_JSON_FILE" 2>/dev/null | head -n 1
}
