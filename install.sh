#!/bin/bash

# Directorio base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup_scripts"

# Cargar librerias base
source "$BASE_DIR/lib/utils.sh"

# --- PARSEAR ARGUMENTOS ---
show_help() {
    source "$BASE_DIR/locales/es.sh"
    echo -e "$STR_HELP_TEXT"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--lang) export LANG_CODE="$2"; shift 2 ;;
        -p|--preset) PRESET_FILE="$2"; shift 2 ;;
        -d|--preset-dir) export PRESET_DIR="$2"; shift 2 ;;
        -g|--debug) export DEBUG_MODE=true; shift ;;
        -f|--force) export FORCE_INSTALL=true; shift ;;
        -h|--help) show_help ;;
        *) shift ;;
    esac
done

# --- SELECCIÓN DE IDIOMA ---
if [ -z "$LANG_CODE" ]; then
    tmp_lang=$(mktemp)
    whiptail --title "🌐 Language / Idioma" --menu \
        "Select Language / Seleccione el idioma\n  ──────────────────────────────" \
        --nocancel \
        15 60 2 \
        "es" "Espanol" \
        "en" "English" 2>"$tmp_lang"

    exit_status=$?
    LANG_CHOICE=$(cat "$tmp_lang")
    rm -f "$tmp_lang"

    if [ $exit_status -ne 0 ]; then
        exit 0
    fi
    export LANG_CODE="$LANG_CHOICE"
fi

source "$BASE_DIR/locales/$LANG_CODE.sh"

# --- CARGAR RESTO DE LIBRERIAS ---
source "$BASE_DIR/lib/json_parser.sh"
source "$BASE_DIR/lib/detection.sh"
source "$BASE_DIR/lib/repos.sh"
source "$BASE_DIR/lib/installer.sh"
source "$BASE_DIR/lib/package_manager.sh"
source "$BASE_DIR/lib/repair_manager.sh"
source "$BASE_DIR/lib/presets.sh"
source "$BASE_DIR/lib/uninstaller.sh"

# Inicializar entorno
mkdir -p "$LOG_DIR"
echo "$(printf -- "$STR_LOG_SESSION_START" "$(date)")" > "$SUMMARY_LOG"

# EMERGENCIA: Corregir repositorios rotos de sesiones previas que impiden ejecutar DNF
log_info "$STR_VERIFYING_REPOS"
if [ -f "/etc/yum.repos.d/vscodium.repo" ]; then
    sudo sed -i 's/\[ vscodium \]/\[vscodium\]/g' /etc/yum.repos.d/vscodium.repo
fi
if [ -f "/etc/yum.repos.d/ vscodium .repo" ]; then
    sudo rm -f "/etc/yum.repos.d/ vscodium .repo"
fi
# Limpiar repositorios para forzar regeneración limpia y evitar errores de GPG
sudo rm -f /etc/yum.repos.d/shiftkey-desktop.repo /etc/yum.repos.d/unityhub.repo /etc/yum.repos.d/teamviewer.repo /etc/yum.repos.d/AnyDesk-Fedora.repo

# Sincronizar metadatos y aceptar llaves GPG de repositorios existentes automáticamente
check_dnf_lock
log_info "$STR_SYNC_REPOS"
sudo dnf makecache -y

# Inicializar caches
if ! build_master_json; then
    log_error "$STR_ERR_DB_BUILD"
    exit 1
fi
refresh_package_cache

# 1. OPTIMIZACION DE DNF
if [[ "$DISTRO" != "unknown" ]]; then
    log_info "$STR_OPTIMIZING_DNF"
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        echo -e "max_parallel_downloads=10\nfastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
    fi
fi

# 2. UI DINAMICA
declare -A SELECTED_STATE
declare -A CAT_NAME_MAP
declare -A CAT_COUNTS

# Deteccion dinamica de terminal
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
TERM_LINES=$(tput lines 2>/dev/null || echo 24)

# Asegurar que sean numeros
[[ "$TERM_COLS" =~ ^[0-9]+$ ]] || TERM_COLS=80
[[ "$TERM_LINES" =~ ^[0-9]+$ ]] || TERM_LINES=24

WIDTH=$((TERM_COLS - 4))
[ $WIDTH -gt 120 ] && WIDTH=120
[ $WIDTH -lt 70 ] && WIDTH=70

HEIGHT=$((TERM_LINES - 4))
[ $HEIGHT -gt 35 ] && HEIGHT=35
[ $HEIGHT -lt 20 ] && HEIGHT=20

LIST_HEIGHT=$((HEIGHT - 12))
[ $LIST_HEIGHT -lt 4 ] && LIST_HEIGHT=4

init_apps_state() {
    while IFS="|" read -r cat_id cat_name; do
        [ -z "$cat_id" ] && continue
        CAT_NAME_MAP["$cat_id"]="$cat_name"
        CAT_COUNTS["$cat_id"]=0
        while IFS="|" read -r app_id app_name app_desc; do
            [ -z "$app_id" ] && continue
            local is_mandatory=$(get_app_data "$app_id" "mandatory" 2>/dev/null)
            if [[ "$is_mandatory" == "true" ]]; then
                SELECTED_STATE["$app_id"]="ON"
                ((CAT_COUNTS["$cat_id"]++))
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
    declare -A LOCAL_NAME_MAP
    
    while IFS="|" read -r app_id app_name app_desc; do
        local state="${SELECTED_STATE[$app_id]}"
        local display_name="$app_name"
        local is_mandatory=$(get_app_data "$app_id" "mandatory" 2>/dev/null)
        if is_installed "$app_id"; then
            display_name="$STR_INSTALLED_TAG $app_name"
        fi
        # Las apps obligatorias se muestran siempre marcadas con una nota
        if [[ "$is_mandatory" == "true" ]]; then
            display_name="🔒 $app_name [ESENCIAL]"
            state="ON"
        fi
        
        args+=("$display_name" "$app_desc" "$state")
        LOCAL_NAME_MAP["$display_name"]="$app_id"
    done < <(get_apps_by_category "$cat_id")

    [ ${#args[@]} -eq 0 ] && return

    local tmp_sel=$(mktemp)
    local cat_desc="  $STR_SELECTION_HINT\n  ──────────────────────────────"
    whiptail --title "$cat_name" --checklist \
        "$cat_desc" \
        --ok-button "$STR_OK" --cancel-button "$STR_CANCEL" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 2>"$tmp_sel"
    
    local exit_status=$?
    local selected=$(cat "$tmp_sel")
    rm -f "$tmp_sel"

    if [ $exit_status -eq 0 ]; then
        CAT_COUNTS["$cat_id"]=0
        while IFS="|" read -r aid rest; do
            local m=$(get_app_data "$aid" "mandatory" 2>/dev/null)
            # Nunca poner OFF a las apps obligatorias
            [[ "$m" != "true" ]] && SELECTED_STATE["$aid"]="OFF"
        done < <(get_apps_by_category "$cat_id")
        eval set -- "$selected"
        for name in "$@"; do
            local aid="${LOCAL_NAME_MAP["$name"]}"
            if [ -n "$aid" ]; then
                SELECTED_STATE["$aid"]="ON"
                ((CAT_COUNTS["$cat_id"]++))
            fi
        done
        # Re-forzar apps obligatorias por si el usuario las desmarcó
        while IFS="|" read -r aid aname rest; do
            local m=$(get_app_data "$aid" "mandatory" 2>/dev/null)
            if [[ "$m" == "true" ]] && [[ "${SELECTED_STATE[$aid]}" != "ON" ]]; then
                SELECTED_STATE["$aid"]="ON"
                ((CAT_COUNTS["$cat_id"]++))
            fi
        done < <(get_apps_by_category "$cat_id")
    fi
}

show_repair_menu() {
    local args=()
    while IFS="|" read -r rid rname; do args+=("$rid" "$rname"); done < <(get_global_repair_tools)
    for app_id in "${!SELECTED_STATE[@]}"; do
        if is_installed "$app_id"; then
            local r_cmd=$(get_app_data "$app_id" "repair")
            if [ "$r_cmd" != "null" ] && [ -n "$r_cmd" ]; then
                local app_name=$(get_app_data "$app_id" "name")
                args+=("$app_id" "$STR_REPAIR_APP $app_name")
            fi
        fi
    done

    [ ${#args[@]} -eq 0 ] && return

    local tmp_choice=$(mktemp)
    local r_desc="  $STR_REPAIRS_MENU\n  ──────────────────────────────"
    whiptail --title "$STR_REPAIRS_TITLE" --menu "$r_desc" \
        --ok-button "$STR_OK" --cancel-button "$STR_CANCEL" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 2>"$tmp_choice"
    
    local exit_status=$?
    local choice=$(cat "$tmp_choice")
    rm -f "$tmp_choice"

    [ $exit_status -eq 0 ] && run_repair "$choice" "$choice"
}

# Inicio
log_info "$STR_ANALYZING_SYSTEM"
init_apps_state
log_info "$STR_APP_STATE_INIT"

if [ -z "$PRESET_FILE" ]; then
    mkdir -p "$PRESET_DIR"
    if ls "$PRESET_DIR"/*.json &>/dev/null; then
        if whiptail --title "$STR_MENU_LOAD_PRESET" --yesno "$STR_STARTUP_LOAD_PRESET" \
            --ok-button "$STR_ACCEPT" --cancel-button "$STR_CANCEL" 10 60; then
            choose_preset_ui
        fi
    fi
else
    load_preset "$PRESET_FILE"
fi

log_info "$STR_MAIN_LOOP_START"

while true; do
    menu_args=()
    
    # Grupo: Software
    tmp_cats=$(mktemp)
    get_categories > "$tmp_cats"
    while IFS="|" read -r cid cname; do
        [ -z "$cid" ] && continue
        count=${CAT_COUNTS[$cid]:-0}
        menu_args+=("$cid" "$cname ($count)")
    done < "$tmp_cats"
    rm -f "$tmp_cats"
    
    # Grupo: Sistema
    menu_args+=(
        "SAVE_PRESET" "$STR_MENU_SAVE_PRESET"
        "LOAD_PRESET" "$STR_MENU_LOAD_PRESET"
        "REPAIR"      "$STR_MENU_REPAIR"
        "UNINSTALL"   "$STR_MENU_UNINSTALL"
        "INSTALL"     "$STR_MENU_INSTALL"
        "EXIT"        "$STR_MENU_EXIT"
    )

    total_sel=0
    for cid in "${!CAT_COUNTS[@]}"; do
        ((total_sel += ${CAT_COUNTS[$cid]}))
    done
    
    # Debug: Guardar menu_args para inspección
    echo "Menu args (${#menu_args[@]}): ${menu_args[@]}" > /tmp/fedora_installer_debug.log
    
    if [ ${#menu_args[@]} -eq 0 ]; then
        log_error "$STR_ERR_EMPTY_MENU"
        exit 1
    fi
    
    if [ $((${#menu_args[@]} % 2)) -ne 0 ]; then
        log_error "$STR_ERR_ODD_MENU"
        exit 1
    fi

    tmp_choice=$(mktemp)
    
    # Preparar comando de whiptail
    wt_cmd=(whiptail --title "$STR_MAIN_MENU_TITLE - $STR_SELECTED_COUNT $total_sel" --menu "$STR_SELECTION_HINT" \
        --ok-button "$STR_OK" --cancel-button "$STR_MENU_EXIT" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${menu_args[@]}")

    if [ "$DEBUG_MODE" = true ]; then
        log_info "DEBUG: Whiptail command: ${wt_cmd[*]}"
    fi

    "${wt_cmd[@]}" 2>"$tmp_choice"
    
    exit_status=$?
    if [ -f "$tmp_choice" ]; then
        CHOICE=$(cat "$tmp_choice")
        rm -f "$tmp_choice"
    else
        CHOICE=""
    fi

    if [ $exit_status -ne 0 ] && [ $exit_status -ne 1 ]; then
        if [ $exit_status -eq 255 ]; then
            log_warn "$STR_WHIPTAIL_ESC"
            exit 0
        else
            log_error "Whiptail error: $exit_status"
            log_info "Params: H=$HEIGHT W=$WIDTH LH=$LIST_HEIGHT"
            log_info "Menu items: $((${#menu_args[@]} / 2))"
            log_to_file "$SUMMARY_LOG" "Whiptail error: $exit_status. H=$HEIGHT W=$WIDTH LH=$LIST_HEIGHT"
        fi
        exit 1
    fi

    # Si el usuario pulsa Cancelar o la X, tratamos como EXIT
    if [ $exit_status -eq 1 ]; then
        CHOICE="EXIT"
    elif [ -z "$CHOICE" ]; then
        log_warn "$STR_WHIPTAIL_NO_SEL"
        CHOICE="EXIT"
    fi

    case "$CHOICE" in
        "INSTALL") break ;;
        "REPAIR") show_repair_menu ;;
        "UNINSTALL") show_uninstaller_menu ;;
        "SAVE_PRESET")
            p_name=$(whiptail --title "$STR_MENU_SAVE_PRESET" --inputbox "$STR_ENTER_PRESET_NAME" \
                --ok-button "$STR_OK" --cancel-button "$STR_CANCEL" \
                10 60 3>&1 1>&2 2>&3)
            [ $? -eq 0 ] && save_preset "$p_name"
            ;;
        "LOAD_PRESET") choose_preset_ui ;;
        "EXIT") exit 0 ;;
        "HEAD_SOFT"|"HEAD_SYS") continue ;;
        *) 
            cat_n="${CAT_NAME_MAP[$CHOICE]}"
            if [ -n "$cat_n" ]; then
                show_category_ui "$CHOICE" "$cat_n"
            fi
            ;;
    esac
done

# Comprobar bloqueos antes de iniciar el bloque de instalación masiva
check_dnf_lock

# Generar Snapshot si es Btrfs antes de proceder
create_btrfs_snapshot

# PASO 0: Instalar RPM Fusion PRIMERO (es esencial para el resto de los paquetes)
# Se instala siempre, independientemente del estado SELECTED_STATE, ya que es obligatorio
if ! is_installed "rpmfusion"; then
    log_info "Instalando repositorios RPM Fusion (obligatorio, paso previo)..."
    install_tiered "rpmfusion"
else
    log_info "$(printf -- "$STR_ALREADY_INSTALLED" "rpmfusion")"
fi

for app_id in "${!SELECTED_STATE[@]}"; do
    # Omitir rpmfusion ya que ya fue instalado en el paso 0
    [[ "$app_id" == "rpmfusion" ]] && continue
    if [[ "${SELECTED_STATE[$app_id]}" == "ON" ]]; then
        if [[ "$FORCE_INSTALL" == "true" ]] || ! is_installed "$app_id"; then
            install_tiered "$app_id"
        else
            log_info "$(printf -- "$STR_ALREADY_INSTALLED" "$app_id")"
        fi
    fi
done
finish_btrfs_snapshot

# Refrescar metadatos de fwupd para evitar el error de LVFS en Discover/GNOME Software
# ("Failed to download metadata for lvfs: network is unreachable")
if command -v fwupdmgr &>/dev/null; then
    log_info "Actualizando metadatos de fwupd (LVFS) para evitar errores en Discover..."
    sudo fwupdmgr refresh --force &>/dev/null && \
        log_success "Metadatos de fwupd actualizados correctamente." || \
        log_warn "No se pudieron actualizar los metadatos de fwupd (verificar conexion a internet)."
fi

log_success "$STR_PROCESS_COMPLETED"
log_info "$STR_SUMMARY_LOG_CREATED $SUMMARY_LOG"
