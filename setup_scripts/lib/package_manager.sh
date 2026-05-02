#!/bin/bash

is_installed() {
    local app_id=$1
    local dnf_pkg=$(get_app_data "$app_id" "dnf_pkg")
    local flatpak_id=$(get_app_data "$app_id" "flatpak_id")

    # Verificar DNF
    if [ "$dnf_pkg" != "null" ]; then
        if dnf list --installed "$dnf_pkg" &> /dev/null; then
            return 0
        fi
    fi

    # Verificar Flatpak
    if [ "$flatpak_id" != "null" ]; then
        if flatpak list --columns=application | grep -q "^$flatpak_id$"; then
            return 0
        fi
    fi

    return 1
}

install_tiered() {
    local app_id=$1
    local priority=($(get_app_priority "$app_id"))
    
    log_info "Procesando instalacion para: $app_id..."

    for method in "${priority[@]}"; do
        case "$method" in
            "dnf")
                local pkg=$(get_app_data "$app_id" "dnf_pkg")
                local repo_func=$(get_app_data "$app_id" "repo_func")
                local requires_repo=$(get_app_data "$app_id" "requires_repo")
                
                # Repositorios especiales
                [ "$repo_func" != "null" ] && $repo_func
                [ "$requires_repo" == "rpm-fusion" ] && add_rpm_fusion
                
                if sudo dnf install -y "$pkg"; then
                    log_success "$app_id instalado via DNF."
                    return 0
                fi
                ;;
            "flatpak")
                local fid=$(get_app_data "$app_id" "flatpak_id")
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                if sudo flatpak install -y flathub "$fid"; then
                    log_success "$app_id instalado via Flatpak."
                    return 0
                fi
                ;;
            "custom")
                local func=$(get_app_data "$app_id" "custom_func")
                if [ "$func" != "null" ]; then
                    $func
                    return 0
                fi
                ;;
        esac
    done

    log_error "No se pudo instalar $app_id por ningun medio definido."
    return 1
}
