#!/bin/bash

# Directorio base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup_scripts"

# Cargar librerias
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/json_parser.sh"
source "$BASE_DIR/lib/repos.sh"
source "$BASE_DIR/lib/installer.sh"
source "$BASE_DIR/lib/package_manager.sh"

# 1. OPTIMIZACIÓN DE DNF (Solo si es Fedora/Nobara)
if [[ "$DISTRO" != "unknown" ]]; then
    log_info "Optimizando DNF..."
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        echo -e "max_parallel_downloads=10\nfastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
    fi
    
    if [[ "$DISTRO" == "fedora" ]]; then
        log_info "Configurando RPM Fusion..."
        add_rpm_fusion
        sudo dnf upgrade -y
    fi
fi

# 2. UI DINÁMICA
declare -A SELECTED_STATE

# Detección dinámica de terminal
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
TERM_LINES=$(tput lines 2>/dev/null || echo 24)
WIDTH=$((TERM_COLS - 6)); [ $WIDTH -gt 100 ] && WIDTH=100
HEIGHT=$((TERM_LINES - 4)); [ $HEIGHT -gt 24 ] && HEIGHT=24
LIST_HEIGHT=$((HEIGHT - 10))

# Cargar todas las apps y su estado inicial
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
    
    while IFS="|" read -r app_id app_name app_desc; do
        local state="${SELECTED_STATE[$app_id]}"
        local name_fmt=$(printf "%-20s" "$app_name")
        args+=("$app_id" "$name_fmt | $app_desc" "$state")
    done < <(get_apps_by_category "$cat_id")

    local selected=$(whiptail --title "$cat_name" --checklist \
        "Selecciona aplicaciones (Espacio para marcar):" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        # Limpiar solo las de esta categoría
        while IFS="|" read -r app_id rest; do
            SELECTED_STATE["$app_id"]="OFF"
        done < <(get_apps_by_category "$cat_id")
        # Marcar seleccionadas
        for id in $selected; do
            id=$(echo $id | tr -d '"')
            SELECTED_STATE["$id"]="ON"
        done
    fi
}

# Inicio del script
log_info "Analizando sistema y cargando configuracion..."
init_apps_state

while true; do
    # Generar menú principal basado en categorías
    menu_args=()
    while IFS="|" read -r cid cname; do
        count=0
        while IFS="|" read -r aid rest; do
            [[ "${SELECTED_STATE[$aid]}" == "ON" ]] && ((count++))
        done < <(get_apps_by_category "$cid")
        menu_args+=("$cid" "$cname [$count]")
    done < <(get_categories)
    
    menu_args+=("INSTALL" "🚀 INICIAR INSTALACION" "EXIT" "❌ Salir")

    CHOICE=$(whiptail --title "Setup Modular JSON" --menu \
        "Gestiona tu software de forma modular y escalable:" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${menu_args[@]}" 3>&1 1>&2 2>&3)

    case "$CHOICE" in
        "INSTALL") break ;;
        "EXIT"|"") exit 0 ;;
        *) 
            cat_name=$(jq -r ".categories[] | select(.id==\"$CHOICE\") | .name" "$BASE_DIR/../config/software.json")
            show_category_ui "$CHOICE" "$cat_name" 
            ;;
    esac
done

# 3. PROCESAR INSTALACIÓN
for app_id in "${!SELECTED_STATE[@]}"; do
    if [[ "${SELECTED_STATE[$app_id]}" == "ON" ]]; then
        # Solo instalar si NO está instalado (o si quieres forzar)
        if ! is_installed "$app_id"; then
            install_tiered "$app_id"
        else
            log_success "$app_id ya esta presente en el sistema."
        fi
    fi
done

log_success "Proceso completado."
