#!/bin/bash

# --- MODULO DE DETECCION DE APLICACIONES ---
# Este modulo se encarga de verificar si una aplicacion ya existe en el sistema
# independientemente de su metodo de instalacion (DNF, Flatpak, Snap, Manual).

is_dnf_installed() {
    local pkg=$1
    [ -z "$pkg" ] && return 1
    # Limpiar el nombre del paquete (quitar extensión de arquitectura si existe, ej: .x86_64)
    # Usamos %. en lugar de %%. para no romper nombres con puntos (ej: dotnet-sdk-10.0)
    local base_pkg="${pkg%.*}"
    [[ -n "${INSTALLED_DNF[$base_pkg]}" ]] && return 0
    # Caso secundario: si el paquete exacto está en el hash
    [[ -n "${INSTALLED_DNF[$pkg]}" ]] && return 0
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
        "$HOME/.var/app/*/desktop" 
    )
    
    local search_pattern="*$app_id*.desktop"
    if [[ "$app_id" == "cursor" ]]; then
        search_pattern="cursor*.desktop"
    fi

    for path in "${paths[@]}"; do
        [ ! -d "$path" ] && continue
        # Búsqueda insensible a mayúsculas para mayor compatibilidad y exclusión de componentes del sistema
        if find "$path" -maxdepth 1 -iname "$search_pattern" -not -name "kcm_*" -not -name "gnome-*" | grep -q "."; then
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

    # 7. Casos Especiales (Heuristica avanzada para apps problematicas)
    case "$app_id" in
        "rpmfusion")
            # Verificar si los repositorios estan habilitados
            if [ -f "/etc/yum.repos.d/rpmfusion-free.repo" ] || [ -f "/etc/yum.repos.d/rpmfusion-nonfree.repo" ]; then
                return 0
            fi
            ;;
        "codecs")
            # Si ffmpeg (version completa de rpmfusion) esta, asumimos codecs instalados
            if is_dnf_installed "ffmpeg" || is_binary_in_path "ffmpeg"; then
                # Pero dnf-free tambien tiene ffmpeg-free, asi que mejor verificar si viene de rpmfusion
                if dnf list installed ffmpeg 2>/dev/null | grep -qi "rpmfusion" || [ -f "/usr/bin/ffmpeg" ]; then
                    return 0
                fi
            fi
            ;;
        "github-desktop")
            # A veces el binario se llama diferente o esta en /opt
            if is_binary_in_path "github-desktop" || [ -f "/usr/bin/github-desktop" ] || [ -f "/opt/GitHubDesktop/github-desktop" ]; then
                return 0
            fi
            ;;
        "dotnet-full")
            # Verificar si el comando dotnet existe y es version 10+ (o simplemente si existe)
            if is_binary_in_path "dotnet"; then
                return 0
            fi
            ;;
        "photogimp")
            # PhotoGIMP instala un archivo .desktop local para GIMP
            if [ -f "$HOME/.local/share/applications/org.gimp.GIMP.desktop" ]; then
                # Verificar si el archivo contiene referencias a PhotoGIMP o si simplemente existe (GIMP flatpak no lo crea ahi)
                if grep -qi "PhotoGIMP" "$HOME/.local/share/applications/org.gimp.GIMP.desktop" 2>/dev/null; then
                    return 0
                fi
                # Si no tiene el string, el simple hecho de estar en ~/.local/ para GIMP flatpak es sospechoso de PhotoGIMP
                return 0
            fi
            # Backup: verificar directorios de plug-ins que PhotoGIMP suele crear
            if [ -d "$HOME/.var/app/org.gimp.GIMP/config/GIMP/2.10/plug-ins" ]; then
                # Si hay muchos archivos ahi, es probable que sea PhotoGIMP
                local count=$(ls "$HOME/.var/app/org.gimp.GIMP/config/GIMP/2.10/plug-ins" 2>/dev/null | wc -l)
                if [ $count -gt 5 ]; then
                    return 0
                fi
            fi
            ;;
        "nodejs")
            # Verificar binarios estándar de Node y NPM
            if is_binary_in_path "node" || is_binary_in_path "npm"; then
                return 0
            fi
            ;;
        "obs-studio")
            # El binario de OBS Studio suele llamarse simplemente 'obs'
            if is_binary_in_path "obs"; then
                return 0
            fi
            ;;
        "handbrake")
            # En Fedora/RPMFusion, el GUI es 'ghb' y el CLI es 'HandBrakeCLI'
            if is_binary_in_path "ghb" || is_binary_in_path "HandBrakeCLI"; then
                return 0
            fi
            ;;
        "barrier")
            # Barrier ha sido reemplazado por Input Leap en muchas distros
            if is_binary_in_path "barrier" || is_binary_in_path "input-leap" || is_binary_in_path "barrierc"; then
                return 0
            fi
            ;;
        "flatseal")
            # El binario de Flatseal en DNF suele ser el ID de Flatpak
            if is_binary_in_path "flatseal" || is_binary_in_path "com.github.tchx84.Flatseal"; then
                return 0
            fi
            ;;
    esac

    return 1
}

# Alias para mantener compatibilidad si es necesario, pero lo ideal es refactorizar
is_installed() {
    check_app_status "$1"
}
