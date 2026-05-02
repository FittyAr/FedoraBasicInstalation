#!/bin/bash

# Directorio base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup_scripts"

# Cargar librerias
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/json_parser.sh"
source "$BASE_DIR/lib/repos.sh"
source "$BASE_DIR/lib/installer.sh"
source "$BASE_DIR/lib/package_manager.sh"
source "$BASE_DIR/lib/repair_manager.sh"

# 1. OPTIMIZACIÓN DE DNF
if [[ "$DISTRO" != "unknown" ]]; then
    log_info "Optimizando DNF..."
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        echo -e "max_parallel_downloads=10\nfastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
    fi
fi

# 2. UI DINÁMICA
declare -A SELECTED_STATE
declare -A NAME_TO_ID_MAP

# Detección dinámica de terminal
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
TERM_LINES=$(tput lines 2>/dev/null || echo 24)
WIDTH=$((TERM_COLS - 4)); [ $WIDTH -gt 120 ] && WIDTH=120
[ $WIDTH -lt 80 ] && WIDTH=80
HEIGHT=$((TERM_LINES - 4)); [ $HEIGHT -gt 30 ] && HEIGHT=30
LIST_HEIGHT=$((HEIGHT - 10))

init_apps_state() {
    while IFS="|" read -r cat_id cat_name; do
        while IFS="|" read -r app_id app_name app_desc; do
            if is_installed "$app_id"; then
                SELECTED_STATE["$app_id"]="ON"
            else
                SELECTED_STATE["$app_id"]="OFF"
            fi
        done < <(get_apps_by_category "$cat_id")
    done < <(get_categories)
}

show_category_ui() {
    local cat_id=$1
    local cat_name=$2
    local args=()
    
    # Limpiar mapa para esta ventana
    NAME_TO_ID_MAP=()
    
    while IFS="|" read -r app_id app_name app_desc; do
        local state="${SELECTED_STATE[$app_id]}"
        local display_name="$app_name"
        
        # Corregido: Llamada directa a la función
        if is_installed "$app_id"; then
            display_name="[INSTALADA] $app_name"
        fi
        
        local name_tag=$(printf "%-30s" "$display_name")
        NAME_TO_ID_MAP["$name_tag"]="$app_id"
        args+=("$name_tag" "$app_desc" "$state")
    done < <(get_apps_by_category "$cat_id")

    local selected=$(whiptail --title "$cat_name" --checklist \
        "Seleccion: ESPACIO para marcar/desmarcar, ENTER para confirmar." \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        while IFS="|" read -r aid rest; do SELECTED_STATE["$aid"]="OFF"; done < <(get_apps_by_category "$cat_id")
        for tag in $selected; do
            tag=$(echo $tag | tr -d '"')
            local real_id="${NAME_TO_ID_MAP["$tag"]}"
            [ -n "$real_id" ] && SELECTED_STATE["$real_id"]="ON"
        done
    fi
}

show_repair_menu() {
    local args=()
    while IFS="|" read -r rid rname; do args+=("$rid" "$rname"); done < <(get_global_repair_tools)
    while IFS="|" read -r aid rest; do
        if is_installed "$aid"; then
            local r_cmd=$(jq -r ".categories[].apps[] | select(.id==\"$aid\") | .repair" "$JSON_FILE")
            if [ "$r_cmd" != "null" ]; then
                args+=("$aid" "Reparar $(get_app_data "$aid" "name")")
            fi
        fi
    done < <(jq -r '.categories[].apps[] | .id' "$JSON_FILE")

    local choice=$(whiptail --title "Reparaciones" --menu "Elige una tarea:" $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    [ $? -eq 0 ] && run_repair "$choice" "$choice"
}

# Inicio
log_info "Analizando sistema..."
init_apps_state

while true; do
    menu_args=()
    while IFS="|" read -r cid cname; do
        count=0
        while IFS="|" read -r aid rest; do [[ "${SELECTED_STATE[$aid]}" == "ON" ]] && ((count++)); done < <(get_apps_by_category "$cid")
        menu_args+=("$cid" "$cname [$count]")
    done < <(get_categories)
    
    menu_args+=("REPAIR" "🔧 REPARACIONES Y MANTENIMIENTO" "INSTALL" "🚀 INICIAR PROCESO" "EXIT" "❌ Salir")

    total_sel=$(for i in "${SELECTED_STATE[@]}"; do [[ $i == "ON" ]] && echo 1; done | wc -l)
    CHOICE=$(whiptail --title "Setup Avanzado Modular" --menu "Seleccionados: $total_sel" $HEIGHT $WIDTH $LIST_HEIGHT "${menu_args[@]}" 3>&1 1>&2 2>&3)

    case "$CHOICE" in
        "INSTALL") break ;;
        "REPAIR") show_repair_menu ;;
        "EXIT"|"") exit 0 ;;
        *) 
            # Corregido: Eliminado 'local' (fuera de función)
            cat_n=$(jq -r ".categories[] | select(.id==\"$CHOICE\") | .name" "$JSON_FILE")
            show_category_ui "$CHOICE" "$cat_n" 
            ;;
    esac
done

for app_id in "${!SELECTED_STATE[@]}"; do
    if [[ "${SELECTED_STATE[$app_id]}" == "ON" ]] && ! is_installed "$app_id"; then
        install_tiered "$app_id"
    fi
done

log_success "Proceso completado."
