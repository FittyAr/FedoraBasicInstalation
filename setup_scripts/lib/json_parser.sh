#!/bin/bash

# Directorios de configuración
CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../../config"
APPS_DIR="$CONFIG_DIR/apps"
REPAIR_FILE="$CONFIG_DIR/repair_tools.json"

# El idioma se debe definir en install.sh (es, en, etc.)
# Si no está definido, por defecto es 'es'
export LANG_CODE="${LANG_CODE:-es}"

get_categories() {
    for f in "$APPS_DIR/"*.json; do
        [ -e "$f" ] || continue
        local id=$(basename "$f" .json)
        # Seleccionar nombre según idioma
        local name_field="name"
        [ "$LANG_CODE" != "es" ] && name_field="name_$LANG_CODE"
        local name=$(jq -r ".$name_field // .name" "$f")
        echo "$id|$name"
    done
}

get_apps_by_category() {
    local cat_id=$1
    local f="$APPS_DIR/$cat_id.json"
    if [ -f "$f" ]; then
        jq -r ".apps[] | \"\(.id)|\(.name)|\(.description.$LANG_CODE // .description.es)\"" "$f"
    fi
}

get_app_data() {
    local app_id=$1
    local field=$2
    
    # Buscar en todos los archivos de apps
    for f in "$APPS_DIR/"*.json; do
        [ -e "$f" ] || continue
        local res=$(jq -r ".apps[] | select(.id==\"$app_id\") | .$field" "$f" 2>/dev/null)
        if [ "$res" != "null" ] && [ -n "$res" ]; then
            # Si el campo es un objeto (como description), devolver el idioma correcto
            if [[ "$field" == "description" ]]; then
                 jq -r ".apps[] | select(.id==\"$app_id\") | .description.$LANG_CODE // .description.es" "$f"
                 return
            fi
            echo "$res"
            return
        fi
    done
}

get_app_priority() {
    local app_id=$1
    for f in "$APPS_DIR/"*.json; do
        [ -e "$f" ] || continue
        local res=$(jq -r ".apps[] | select(.id==\"$app_id\") | .priority[]" "$f" 2>/dev/null)
        if [ -n "$res" ]; then
            echo "$res"
            return
        fi
    done
}

get_global_repair_tools() {
    jq -r ".repair_tools[] | \"\(.id)|\(.name.$LANG_CODE // .name.es)\"" "$REPAIR_FILE"
}

get_repair_command() {
    local rid=$1
    # Buscar en herramientas globales
    local cmd=$(jq -r ".repair_tools[] | select(.id==\"$rid\") | .command" "$REPAIR_FILE" 2>/dev/null)
    if [ "$cmd" != "null" ] && [ -n "$cmd" ]; then
        echo "$cmd"
        return
    fi
    # Buscar en apps
    get_app_data "$rid" "repair"
}
