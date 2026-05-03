#!/bin/bash

# --- MODULO DE DESINSTALACION ---
# Este modulo gestiona la eliminacion de aplicaciones detectando su origen.

show_uninstaller_menu() {
    while true; do
        local menu_args=()
        local tmp_cats=$(mktemp)
        
        get_categories > "$tmp_cats"
        while IFS="|" read -r cid cname; do
            [ -z "$cid" ] && continue
            
            # Contar cuantas apps de esta categoria estan instaladas
            local installed_count=0
            while IFS="|" read -r app_id app_name app_desc; do
                if is_installed "$app_id"; then
                    ((installed_count++))
                fi
            done < <(get_apps_by_category "$cid")
            
            if [ $installed_count -gt 0 ]; then
                menu_args+=("$cid" "$cname ($installed_count)")
            fi
        done < "$tmp_cats"
        rm -f "$tmp_cats"

        if [ ${#menu_args[@]} -eq 0 ]; then
            whiptail --title "$STR_UNINSTALLER_TITLE" --msgbox "No hay aplicaciones instaladas detectadas para desinstalar." 10 60
            return
        fi

        menu_args+=("BACK" "$STR_CANCEL")

        local tmp_choice=$(mktemp)
        whiptail --title "$STR_UNINSTALLER_TITLE" --menu "$STR_SELECTION_HINT" \
            --ok-button "$STR_OK" --cancel-button "$STR_CANCEL" \
            $HEIGHT $WIDTH $LIST_HEIGHT "${menu_args[@]}" 2>"$tmp_choice"
        
        local exit_status=$?
        local choice=$(cat "$tmp_choice")
        rm -f "$tmp_choice"

        if [ $exit_status -ne 0 ] || [ "$choice" == "BACK" ]; then
            return
        fi

        local cat_n="${CAT_NAME_MAP[$choice]}"
        show_uninstaller_category_ui "$choice" "$cat_n"
    done
}

show_uninstaller_category_ui() {
    local cat_id=$1
    local cat_name=$2
    local args=()
    declare -A LOCAL_NAME_MAP
    
    while IFS="|" read -r app_id app_name app_desc; do
        if is_installed "$app_id"; then
            args+=("$app_id" "$app_name" "OFF")
            LOCAL_NAME_MAP["$app_id"]="$app_name"
        fi
    done < <(get_apps_by_category "$cat_id")

    if [ ${#args[@]} -eq 0 ]; then
        return
    fi

    local tmp_sel=$(mktemp)
    whiptail --title "$STR_UNINSTALLER_TITLE - $cat_name" --checklist \
        "$STR_UNINSTALL_HINT" \
        --ok-button "$STR_OK" --cancel-button "$STR_CANCEL" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 2>"$tmp_sel"
    
    local exit_status=$?
    local selected=$(cat "$tmp_sel")
    rm -f "$tmp_sel"

    if [ $exit_status -eq 0 ] && [ -n "$selected" ]; then
        eval set -- "$selected"
        
        # Generar Snapshot antes de proceder
        create_btrfs_snapshot
        
        # Listar apps seleccionadas (especialmente para debug)
        log_info "Aplicaciones seleccionadas para desinstalar:"
        for aid in "$@"; do
            local name=$(get_app_data "$aid" "name")
            echo "  - $name ($aid)"
        done
        echo ""

        for aid in "$@"; do
            uninstall_app "$aid"
        done
        
        # Cerrar Snapshot
        finish_btrfs_snapshot

        # Refrescar cache despues de desinstalar
        refresh_package_cache
    fi
}

uninstall_app() {
    local app_id=$1
    local app_name=$(get_app_data "$app_id" "name")
    local log_file="/tmp/fedora_uninstall_${app_id}.log"
    
    # Redirigir salida a log si estamos en modo debug
    if [[ "$DEBUG_MODE" == "true" ]]; then
        exec 3>&1 4>&2
        exec > >(tee -a "$log_file") 2> >(tee -a "$log_file" >&2)
        log_info "--- Iniciando desinstalacion de $app_name ---" >> "$log_file"
    fi

    # Verificar si ya está desinstalado para evitar errores (por ejemplo si se borró por dependencias)
    if ! is_installed "$app_id"; then
        log_success "$(printf -- "$STR_UNINSTALL_SUCCESS" "$app_name")"
        [ "$DEBUG_MODE" == "true" ] && exec 1>&3 2>&4 3>&- 4>&-
        return 0
    fi
    
    log_info "$(printf -- "$STR_UNINSTALLING_APP" "$app_name")"
    
    local dnf_pkg=$(get_app_data "$app_id" "dnf_pkg")
    local flatpak_id=$(get_app_data "$app_id" "flatpak_id")
    local custom_un=$(get_app_data "$app_id" "custom_uninstall_func")
    
    local success=false
    
    # 1. Intentar desinstalacion personalizada si existe
    if [ "$custom_un" != "null" ] && [ -n "$custom_un" ]; then
        if $custom_un; then
            success=true
        fi
    fi
    
    # 2. Desinstalacion Flatpak
    if [ "$success" = false ] && [ "$flatpak_id" != "null" ] && is_flatpak_installed "$flatpak_id"; then
        if flatpak uninstall -y "$flatpak_id"; then
            success=true
        fi
    fi
    
    # 3. Desinstalacion DNF
    if [ "$success" = false ] && [ "$dnf_pkg" != "null" ]; then
        local any_uninstalled=false
        # Intentar con los paquetes listados y con el app_id
        for p in $dnf_pkg $app_id; do
            [ "$p" == "null" ] && continue
            local target_pkg="$p"
            
            # PROTECCIÓN: No permitir desinstalar paquetes críticos
            if [[ " $CRITICAL_PACKAGES " =~ " $target_pkg " ]]; then
                log_warn "Omitiendo desinstalacion del paquete critico: $target_pkg"
                continue
            fi

            if ! is_dnf_installed "$p"; then
                # Intentar encontrar el paquete que provee el binario
                local bin_path=$(which "$p" 2>/dev/null)
                # Si p no es un binario, probar con nombres comunes si es nodejs
                if [ -z "$bin_path" ] && [ "$p" == "nodejs" ]; then
                    bin_path=$(which node 2>/dev/null)
                fi

                if [ -n "$bin_path" ]; then
                    local prov=$(rpm -qf "$bin_path" --queryformat '%{NAME}' 2>/dev/null)
                    if [ -n "$prov" ] && [[ ! "$prov" =~ "is not owned" ]]; then
                        # Proteccion contra borrado de flatpak o dnf accidental
                        if [[ "$prov" =~ ^(flatpak|dnf|dnf5|sudo|bash|coreutils|kernel|glibc|systemd)$ ]]; then
                            log_warn "Ignorando paquete critico detectado: $prov (proviene de $bin_path)"
                        else
                            target_pkg="$prov"
                            log_info "Detectado paquete real: $target_pkg (provee $p)"
                        fi
                    fi
                fi
            fi

            if is_dnf_installed "$target_pkg"; then
                if sudo dnf remove -y "$target_pkg"; then
                    any_uninstalled=true
                elif ! is_dnf_installed "$target_pkg"; then
                    # Si fallo pero ya no esta, es que se borró por dependencia (exito)
                    any_uninstalled=true
                fi
            elif [ "$target_pkg" != "$p" ] && [ -n "$target_pkg" ]; then
                 # Si target_pkg es distinto, intentar borrarlo igual
                 sudo dnf remove -y "$target_pkg" && any_uninstalled=true
            fi
        done
        [ "$any_uninstalled" = true ] && success=true
    fi
    
    # 4. Intento desesperado via Desktop File
    if [ "$success" = false ]; then
        local search_pattern="*${app_id}*.desktop"
        if [[ "$app_id" == "cursor" ]]; then search_pattern="cursor*.desktop"; fi
        
        local desktop_file=$(find /usr/share/applications /usr/local/share/applications $HOME/.local/share/applications -maxdepth 2 -iname "$search_pattern" -not -name "kcm_*" -not -name "gnome-*" -print -quit 2>/dev/null)
        if [ -n "$desktop_file" ]; then
            local target_pkg="null"
            # 4.1. Intentar identificar paquete via RPM directo del desktop file
            local prov=$(rpm -qf "$desktop_file" --queryformat '%{NAME}' 2>/dev/null)
            if [ -n "$prov" ] && [[ ! "$prov" =~ "is not owned" ]]; then
                target_pkg="$prov"
            else
                # 4.2. Si no es un RPM directo, buscar el binario en Exec=
                local exec_path=$(grep "^Exec=" "$desktop_file" | head -n1 | cut -d'=' -f2- | awk '{print $1}')
                exec_path=$(echo "$exec_path" | sed 's/["'\'']//g')
                [[ "$exec_path" != /* ]] && exec_path=$(which "$exec_path" 2>/dev/null)
                
                if [ -f "$exec_path" ]; then
                    prov=$(rpm -qf "$exec_path" --queryformat '%{NAME}' 2>/dev/null)
                    if [ -n "$prov" ] && [[ ! "$prov" =~ "is not owned" ]]; then
                        target_pkg="$prov"
                    fi
                fi
            fi

            # Proteccion contra borrado de flatpak o dnf accidental
            if [[ " $CRITICAL_PACKAGES " =~ " $target_pkg " ]]; then
                log_warn "Ignorando paquete critico detectado via desktop file: $target_pkg"
            elif [ "$target_pkg" != "null" ]; then
                log_info "Identificado paquete $target_pkg a traves de $desktop_file"
                if sudo dnf remove -y "$target_pkg"; then
                    success=true
                fi
            fi
        fi
    fi

    # 5. Limpieza de Binarios Huérfanos (si todo lo anterior falló pero el binario sigue ahí)
    if [ "$success" = false ]; then
        local bin_to_clean=""
        if is_binary_in_path "$app_id"; then bin_to_clean=$(which "$app_id"); fi
        
        if [ -n "$bin_to_clean" ] && [ -f "$bin_to_clean" ]; then
            # Verificar de nuevo que NO sea un paquete RPM (por seguridad extrema)
            if ! rpm -qf "$bin_to_clean" &>/dev/null; then
                log_info "Detectado binario huérfano: $bin_to_clean. Eliminando..."
                sudo rm -f "$bin_to_clean"
                success=true
            fi
        fi
    fi

    if [ "$success" = true ]; then
        log_success "$(printf -- "$STR_UNINSTALL_SUCCESS" "$app_name")"
        log_to_file "$SUMMARY_LOG" "Successfully uninstalled: $app_name ($app_id)"
    else
        log_error "$(printf -- "$STR_UNINSTALL_FAILED" "$app_name")"
        log_warn "No se encontro un metodo de desinstalacion valido para $app_id (DNF/Flatpak/Custom)."
        log_to_file "$SUMMARY_LOG" "Failed to uninstall: $app_name ($app_id)"
    fi

    # Restaurar descriptores si estaban redirigidos
    if [[ "$DEBUG_MODE" == "true" ]]; then
        exec 1>&3 2>&4 3>&- 4>&-
    fi

    return 0
}
