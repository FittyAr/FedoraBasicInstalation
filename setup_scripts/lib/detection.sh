#!/bin/bash

# --- MODULO DE DETECCION DE APLICACIONES ---
# Este modulo se encarga de verificar si una aplicacion ya existe en el sistema
# independientemente de su metodo de instalacion (DNF, Flatpak, Snap, Manual).

is_dnf_installed() {
    local pkg=$1
    [ -z "$pkg" ] && return 1
    # Limpiar el nombre del paquete (quitar extensiones si las hay)
    local base_pkg="${pkg%%.*}"
    [[ -n "${INSTALLED_DNF[$base_pkg]}" ]] && return 0
    return 1
}

is_flatpak_installed() {
    local fid=$1
    [ -z "$fid" ] && return 1
    [[ -n "${INSTALLED_FLATPAK[$fid]}" ]] && return 0
    return 1
}

is_snap_installed() {
    local sid=$1
    [ -z "$sid" ] && return 1
    [[ -n "${INSTALLED_SNAP[$sid]}" ]] && return 0
    return 1
}

is_binary_in_path() {
    local bin=$1
    [ -z "$bin" ] && return 1
    command -v "$bin" &> /dev/null && return 0
    return 1
}

has_desktop_file() {
    local app_id=$1
    [ -z "$app_id" ] && return 1
    
    # Buscar en rutas estandar de archivos .desktop
    local paths=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
        "/var/lib/flatpak/exports/share/applications"
        "$HOME/.var/app/*/desktop" # Para algunos flatpaks especificos
    )
    
    for path in "${paths[@]}"; do
        # Buscar por id exacto o patrones comunes
        if ls "$path"/*"$app_id"*.desktop &> /dev/null; then
            return 0
        fi
    done
    return 1
}

# Funcion principal de deteccion
check_app_status() {
    local app_id=$1
    
    # 1. Obtener datos de la aplicacion desde el JSON
    local dnf_pkg=$(get_app_data "$app_id" "dnf_pkg")
    local flatpak_id=$(get_app_data "$app_id" "flatpak_id")
    local snap_id=$(get_app_data "$app_id" "snap_id") # Por si se añade en el futuro
    
    # 2. Verificacion por DNF
    if [ "$dnf_pkg" != "null" ] && [ -n "$dnf_pkg" ]; then
        # Puede haber varios paquetes separados por espacio
        for p in $dnf_pkg; do
            if is_dnf_installed "$p"; then
                return 0
            fi
        done
    fi
    
    # 3. Verificacion por Flatpak
    if [ "$flatpak_id" != "null" ] && [ -n "$flatpak_id" ]; then
        if is_flatpak_installed "$flatpak_id"; then
            return 0
        fi
    fi
    
    # 4. Verificacion por Snap
    if [ "$snap_id" != "null" ] && [ -n "$snap_id" ]; then
        if is_snap_installed "$snap_id"; then
            return 0
        fi
    fi
    
    # 5. Verificacion por Binario (usando app_id o el primer paquete dnf como pista)
    if is_binary_in_path "$app_id"; then
        return 0
    fi
    
    if [ "$dnf_pkg" != "null" ] && [ -n "$dnf_pkg" ]; then
        local first_pkg=$(echo "$dnf_pkg" | awk '{print $1}')
        if is_binary_in_path "$first_pkg"; then
            return 0
        fi
    fi
    
    # 6. Verificacion por archivo .desktop
    if has_desktop_file "$app_id"; then
        return 0
    fi

    return 1
}

# Alias para mantener compatibilidad si es necesario, pero lo ideal es refactorizar
is_installed() {
    check_app_status "$1"
}
