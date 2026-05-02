#!/bin/bash

# Directorio base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup_scripts"

# Cargar librerias base para el selector de idioma
source "$BASE_DIR/lib/utils.sh"

# --- SELECCIÓN DE IDIOMA ---
LANG_CHOICE=$(whiptail --title "Language / Idioma" --menu "Select Language / Seleccione el idioma" 15 60 2 \
    "es" "Español" \
    "en" "English" 3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
    exit 0
fi

export LANG_CODE="$LANG_CHOICE"
source "$BASE_DIR/locales/$LANG_CODE.sh"


# --- CARGAR RESTO DE LIBRERIAS ---
source "$BASE_DIR/lib/json_parser.sh"
source "$BASE_DIR/lib/repos.sh"
source "$BASE_DIR/lib/installer.sh"
source "$BASE_DIR/lib/package_manager.sh"
source "$BASE_DIR/lib/repair_manager.sh"


# Inicializar caches
build_master_json
refresh_package_cache


# 1. OPTIMIZACIÓN DE DNF
if [[ "$DISTRO" != "unknown" ]]; then
    log_info "$STR_OPTIMIZING_DNF"
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        echo -e "max_parallel_downloads=10\nfastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
    fi
fi

# 2. UI DINÁMICA
declare -A SELECTED_STATE
declare -A NAME_TO_ID_MAP
declare -A CAT_NAME_MAP
declare -A CAT_COUNTS


# Detección dinámica de terminal
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
TERM_LINES=$(tput lines 2>/dev/null || echo 24)
WIDTH=$((TERM_COLS - 4)); [ $WIDTH -gt 120 ] && WIDTH=120
[ $WIDTH -lt 80 ] && WIDTH=80
HEIGHT=$((TERM_LINES - 4)); [ $HEIGHT -gt 30 ] && HEIGHT=30
LIST_HEIGHT=$((HEIGHT - 10))

init_apps_state() {
    while IFS="|" read -r cat_id cat_name; do
        CAT_NAME_MAP["$cat_id"]="$cat_name"
        CAT_COUNTS["$cat_id"]=0
        while IFS="|" read -r app_id app_name app_desc; do
            if is_installed "$app_id"; then
                # Apps ya instaladas no cuentan como "seleccionadas para instalar" 
                # pero podemos marcarlas si queremos. En el diseño actual, 
                # SELECTED_STATE se usa para la checklist de whiptail.
                SELECTED_STATE["$app_id"]="OFF"
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
        
        if is_installed "$app_id"; then
            display_name="$STR_INSTALLED_TAG $app_name"
        fi
        
        local name_tag=$(printf "%-30s" "$display_name")
        NAME_TO_ID_MAP["$name_tag"]="$app_id"
        args+=("$name_tag" "$app_desc" "$state")
    done < <(get_apps_by_category "$cat_id")

    local selected=$(whiptail --title "$cat_name" --checklist \
        "$STR_SELECTION_HINT" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        # Reset count for this category
        CAT_COUNTS["$cat_id"]=0
        # Reset state for apps in this category
        while IFS="|" read -r aid rest; do SELECTED_STATE["$aid"]="OFF"; done < <(get_apps_by_category "$cat_id")
        
        for tag in $selected; do
            tag=$(echo $tag | tr -d '"')
            local real_id="${NAME_TO_ID_MAP["$tag"]}"
            if [ -n "$real_id" ]; then
                SELECTED_STATE["$real_id"]="ON"
                ((CAT_COUNTS["$cat_id"]++))
            fi
        done
    fi
}


show_repair_menu() {
    local args=()
    while IFS="|" read -r rid rname; do args+=("$rid" "$rname"); done < <(get_global_repair_tools)
    
    # Agregar reparaciones individuales de apps instaladas
    for app_id in "${!SELECTED_STATE[@]}"; do
        if is_installed "$app_id"; then
            local r_cmd=$(get_app_data "$app_id" "repair")
            if [ "$r_cmd" != "null" ] && [ -n "$r_cmd" ]; then
                local app_name=$(get_app_data "$app_id" "name")
                args+=("$app_id" "$STR_REPAIR_APP $app_name")
            fi
        fi
    done

    local choice=$(whiptail --title "$STR_REPAIRS_TITLE" --menu "$STR_REPAIRS_MENU" $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    [ $? -eq 0 ] && run_repair "$choice" "$choice"
}

# Inicio
log_info "$STR_ANALYZING_SYSTEM"
init_apps_state

while true; do
    menu_args=()
    while IFS="|" read -r cid cname; do
        count=${CAT_COUNTS[$cid]:-0}
        menu_args+=("$cid" "$cname [$count]")
    done < <(get_categories)
    
    menu_args+=("REPAIR" "$STR_MENU_REPAIR" "INSTALL" "$STR_MENU_INSTALL" "EXIT" "$STR_MENU_EXIT")

    total_sel=0
    for c in "${CAT_COUNTS[@]}"; do ((total_sel += c)); done
    CHOICE=$(whiptail --title "$STR_MAIN_MENU_TITLE" --menu "$STR_SELECTED_COUNT $total_sel" $HEIGHT $WIDTH $LIST_HEIGHT "${menu_args[@]}" 3>&1 1>&2 2>&3)


    case "$CHOICE" in
        "INSTALL") break ;;
        "REPAIR") show_repair_menu ;;
        "EXIT"|"") exit 0 ;;
        *) 
            cat_n="${CAT_NAME_MAP[$CHOICE]}"
            show_category_ui "$CHOICE" "$cat_n" 
            ;;
    esac
done

for app_id in "${!SELECTED_STATE[@]}"; do
    if [[ "${SELECTED_STATE[$app_id]}" == "ON" ]] && ! is_installed "$app_id"; then
        install_tiered "$app_id"
    fi
done

log_success "$STR_PROCESS_COMPLETED"
