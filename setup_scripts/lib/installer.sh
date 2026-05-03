#!/bin/bash

# Mapeo de paquetes a funciones de repo
declare -A REPO_MAPPING=(
    ["code"]="add_vscode_repo"
    ["brave-browser"]="add_brave_repo"
    ["microsoft-edge-stable"]="add_edge_repo"
    ["unityhub"]="add_unity_repo"
    ["google-chrome-stable"]="add_google_chrome_repo"
    ["GitHubDesktop"]="add_github_desktop_repo"
    ["docker-ce"]="add_docker_repo"
    ["dotnet-sdk-10.0"]="add_microsoft_repo"
    ["vscodium"]="add_vscodium_repo"
    ["warp-terminal"]="add_warp_repo"
    ["tailscale"]="add_tailscale_repo"
    ["anydesk"]="add_anydesk_repo"
    ["teamviewer"]="add_teamviewer_repo"
    ["antigravity"]="add_antigravity_repo"
    ["cursor"]="add_cursor_repo"
)


install_docker_full() {
    log_info "$STR_INSTALL_DOCKER_GNOME"
    
    # 1. Asegurar GNOME y dependencias (pedido por el usuario)
    log_info "$STR_INSTALL_GNOME_DEPS"
    sudo dnf groupinstall -y "GNOME"
    sudo dnf install -y gnome-terminal dnf-plugins-core
    
    # 2. Configurar repositorio de Docker (necesario para dependencias del RPM)
    log_info "$STR_CONFIG_DOCKER_REPO"
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    
    # 3. Descargar e instalar Docker Desktop
    local temp_dir=$(mktemp -d)
    log_info "$STR_DOWNLOAD_DOCKER_RPM"
    # URL genérica para la última versión estable en x86_64
    if curl -L https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm -o "$temp_dir/docker-desktop.rpm"; then
        log_info "$STR_INSTALL_DOCKER_GNOME"
        sudo dnf install -y "$temp_dir/docker-desktop.rpm"
    else
        log_error "$STR_ERR_DOCKER_DOWNLOAD"
        return 1
    fi
    
    # 4. Post-instalación
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    
    rm -rf "$temp_dir"
    log_success "$STR_DOCKER_SUCCESS"
    log_warn "$STR_DOCKER_LOGOUT"
}

uninstall_docker_full() {
    log_info "Eliminando Docker Desktop..."
    if rpm -q docker-desktop &>/dev/null; then
        sudo dnf remove -y docker-desktop
    fi
    sudo systemctl disable --now docker 2>/dev/null || true
    return 0
}

install_tailscale_full() {
    log_info "$STR_INSTALL_TAILSCALE"
    add_tailscale_repo
    sudo dnf install -y tailscale
    sudo systemctl enable --now tailscaled
    log_warn "$STR_TAILSCALE_READY"
}

uninstall_tailscale_full() {
    log_info "Eliminando Tailscale..."
    sudo systemctl stop tailscaled
    sudo systemctl disable tailscaled
    sudo dnf remove -y tailscale
}

install_waydroid_full() {
    log_info "$STR_INSTALL_WAYDROID"
    sudo dnf install -y waydroid
    log_warn "$STR_WAYDROID_INIT"
}

install_photogimp() {
    log_info "$STR_INSTALL_PHOTOGIMP"
    if ! flatpak list | grep -q "org.gimp.GIMP"; then
        log_info "$STR_INSTALL_GIMP_FIRST"
        sudo flatpak install -y flathub org.gimp.GIMP
    fi
    
    local temp_dir=$(mktemp -d)
    log_info "$STR_DOWNLOAD_PHOTOGIMP"
    curl -L https://github.com/Diolinux/PhotoGIMP/archive/master.tar.gz -o "$temp_dir/photogimp.tar.gz"
    tar -xzf "$temp_dir/photogimp.tar.gz" -C "$temp_dir"
    
    local config_dir="$HOME/.var/app/org.gimp.GIMP/config/GIMP/2.10"
    mkdir -p "$config_dir"
    cp -r "$temp_dir/PhotoGIMP-master/.icons" "$HOME/"
    cp -r "$temp_dir/PhotoGIMP-master/.local" "$HOME/"
    cp -r "$temp_dir/PhotoGIMP-master/.var/app/org.gimp.GIMP/config/GIMP/2.10/." "$config_dir/"
    
    rm -rf "$temp_dir"
    log_success "$STR_PHOTOGIMP_SUCCESS"
}

uninstall_photogimp() {
    log_info "Eliminando PhotoGIMP y GIMP al completo..."
    # Eliminar iconos y accesos directos
    rm -f "$HOME/.local/share/applications/org.gimp.GIMP.desktop"
    rm -rf "$HOME/.icons/PhotoGIMP"
    
    # Desinstalar GIMP Flatpak si existe
    if command -v flatpak &>/dev/null; then
        flatpak uninstall -y org.gimp.GIMP
    fi
    
    # Eliminar toda la configuración de GIMP (incluye los parches de PhotoGIMP)
    rm -rf "$HOME/.var/app/org.gimp.GIMP"
    log_success "GIMP y PhotoGIMP eliminados al completo (incluyendo configuración)."
}

install_ollama() {
    log_info "$STR_INSTALL_OLLAMA"
    
    if has_nvidia; then
        log_info "$STR_GPU_NVIDIA_DETECTED"
        # El script oficial de Ollama detecta y configura NVIDIA automáticamente
    elif has_amd; then
        log_info "$STR_GPU_AMD_DETECTED"
        log_warn "$STR_GPU_AMD_ROCM_WARN"
    else
        log_warn "$STR_GPU_NOT_FOUND"
    fi

    curl -fsSL https://ollama.com/install.sh | sh
    sudo systemctl enable --now ollama
}

uninstall_ollama() {
    log_info "Eliminando Ollama..."
    sudo systemctl stop ollama
    sudo systemctl disable ollama
    sudo rm -f /etc/systemd/system/ollama.service
    sudo rm -f $(which ollama)
    sudo userdel ollama
    sudo groupdel ollama
}

install_dotnet_full() {
    log_info "$STR_INSTALL_DOTNET_FULL"
    # Según docs de Microsoft para Fedora
    sudo dnf install -y dotnet-sdk-10.0 aspnetcore-runtime-10.0 dotnet-runtime-10.0
    
    # Instalación de workloads comunes si es necesario
    if command -v dotnet &> /dev/null; then
        log_info "$STR_INSTALL_DOTNET_WORKLOADS"
        sudo dotnet workload install android wasm-tools || log_warn "$STR_ERR_DOTNET_WORKLOADS"
    fi
}

install_cursor() {
    log_info "$STR_PREPARING_CURSOR"
    # Cursor ahora se instala vía DNF gracias al repositorio añadido.
    # Esta función queda como respaldo para configuraciones adicionales.
    log_success "$STR_CURSOR_READY"
}

install_zed() {
    log_info "$STR_INSTALL_ZED"
    curl -f https://zed.dev/install.sh | sh
}

uninstall_zed() {
    log_info "Eliminando Zed Editor..."
    rm -f "$HOME/.local/bin/zed"
    rm -rf "$HOME/.local/share/zed"
}

install_codecs() {
    log_info "$STR_INSTALL_CODECS"
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-libav mesa-va-drivers-freeworld intel-media-driver
}

install_pkg() {
    local pkg=$1
    log_info "$(printf -- "$STR_INSTALL_DNF_PKG" "$pkg")"
    sudo dnf install -y "$pkg"
}

setup_antigravity() {
    log_info "$STR_CONFIG_ANTIGRAVITY"
    if [ ! -f "agents.md" ]; then
        log_warn "$STR_ERR_AG_MD_NOT_FOUND"
    fi
    # Aquí se podrían añadir configuraciones post-instalación del paquete RPM
    log_success "$STR_AG_READY"
}

uninstall_antigravity() {
    log_info "Eliminando configuración de Antigravity..."
    # Por ahora solo logueamos, ya que es principalmente configuración
    return 0
}

install_rustdesk_custom() {
    log_info "$STR_INSTALL_RUSTDESK"
    
    # 1. Añadir remoto Flathub en ámbito de usuario
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # 2. Descargar el archivo .flatpak (buscando la última versión en GitHub)
    local temp_dir=$(mktemp -d)
    log_info "$STR_SEARCH_RUSTDESK_GH"
    local latest_url=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep "browser_download_url.*\.flatpak" | cut -d '"' -f 4 | head -n 1)
    
    if [ -n "$latest_url" ]; then
        log_info "$STR_DOWNLOAD_RUSTDESK_FLATPAK"
        curl -L "$latest_url" -o "$temp_dir/rustdesk.flatpak"
        
        # 3. Instalar
        log_info "$STR_INSTALL_FLATPAK_FILE"
        flatpak --user install -y "$temp_dir/rustdesk.flatpak"
    else
        log_warn "$STR_ERR_RUSTDESK_GH"
        flatpak --user install -y flathub com.rustdesk.RustDesk
    fi
    
    rm -rf "$temp_dir"
    log_success "$STR_RUSTDESK_SUCCESS"
}

uninstall_rustdesk_custom() {
    log_info "Eliminando RustDesk (Ambito de Usuario)..."
    flatpak --user uninstall -y com.rustdesk.RustDesk
}

install_lazydocker_custom() {
    log_info "$STR_INSTALL_LAZYDOCKER"
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}

uninstall_lazydocker_custom() {
    log_info "Eliminando LazyDocker..."
    sudo rm -f /usr/local/bin/lazydocker
}

install_tlp_full() {
    log_info "$STR_LOG_INSTALL_START tlp"
    
    # Eliminar paquetes en conflicto si existen
    if rpm -q tuned-ppd &>/dev/null; then
        log_warn "Detectado tuned-ppd (en conflicto). Eliminando para permitir la instalacion de TLP..."
        sudo dnf remove -y tuned-ppd
    fi
    
    # Desactivar power-profiles-daemon ya que TLP lo reemplaza y causa conflictos de servicios
    if systemctl is-active power-profiles-daemon &>/dev/null || systemctl is-enabled power-profiles-daemon &>/dev/null; then
        log_warn "Desactivando power-profiles-daemon para evitar conflictos con TLP..."
        sudo systemctl disable --now power-profiles-daemon
    fi

    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable --now tlp
    sudo tlp start
    log_success "TLP instalado y configurado correctamente."
}

uninstall_tlp_full() {
    log_info "Eliminando TLP..."
    sudo systemctl stop tlp &>/dev/null
    sudo systemctl disable --now tlp &>/dev/null
    sudo dnf remove -y tlp tlp-rdw
    # Intentar restaurar el perfil de energia por defecto de Fedora
    if ! systemctl is-active power-profiles-daemon &>/dev/null; then
        sudo dnf install -y power-profiles-daemon &>/dev/null
        sudo systemctl enable --now power-profiles-daemon &>/dev/null
    fi
}

uninstall_rpm_fusion() {
    log_info "Eliminando repositorios RPM Fusion..."
    sudo dnf remove -y rpmfusion-free-release rpmfusion-nonfree-release
    sudo dnf clean all
}

