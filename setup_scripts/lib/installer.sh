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
    ["appimagelauncher"]="add_appimagelauncher_repo"
    ["dotnet-sdk-10.0"]="add_microsoft_repo"
    ["vscodium"]="add_vscodium_repo"
    ["warp-terminal"]="add_warp_repo"
    ["tailscale"]="add_tailscale_repo"
    ["anydesk"]="add_anydesk_repo"
    ["teamviewer"]="add_teamviewer_repo"
)


install_docker_full() {
    log_info "Instalando Docker Engine & Docker Desktop components..."
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    log_warn "Docker instalado. Debes cerrar sesión para usarlo sin sudo."
}

install_tailscale_full() {
    log_info "Instalando y configurando Tailscale..."
    add_tailscale_repo
    sudo dnf install -y tailscale
    sudo systemctl enable --now tailscaled
    log_warn "Tailscale listo. Ejecuta 'sudo tailscale up' para iniciar sesión."
}

install_waydroid_full() {
    log_info "Instalando y preparando Waydroid..."
    sudo dnf install -y waydroid
    log_warn "Waydroid instalado. Requiere inicializacion manual: 'sudo waydroid init'."
}

install_photogimp() {
    log_info "Instalando parche PhotoGIMP para GIMP Flatpak..."
    if ! flatpak list | grep -q "org.gimp.GIMP"; then
        log_info "Instalando GIMP via Flatpak primero..."
        sudo flatpak install -y flathub org.gimp.GIMP
    fi
    
    local temp_dir=$(mktemp -d)
    log_info "Descargando PhotoGIMP..."
    curl -L https://github.com/Diolinux/PhotoGIMP/archive/master.tar.gz -o "$temp_dir/photogimp.tar.gz"
    tar -xzf "$temp_dir/photogimp.tar.gz" -C "$temp_dir"
    
    local config_dir="$HOME/.var/app/org.gimp.GIMP/config/GIMP/2.10"
    mkdir -p "$config_dir"
    cp -r "$temp_dir/PhotoGIMP-master/.icons" "$HOME/"
    cp -r "$temp_dir/PhotoGIMP-master/.local" "$HOME/"
    cp -r "$temp_dir/PhotoGIMP-master/.var/app/org.gimp.GIMP/config/GIMP/2.10/." "$config_dir/"
    
    rm -rf "$temp_dir"
    log_success "PhotoGIMP aplicado correctamente."
}

install_ollama() {
    log_info "Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    sudo systemctl enable --now ollama
}

install_dotnet_full() {
    log_info "Instalando .NET 10 SDK completo..."
    sudo dnf install -y dotnet-sdk-10.0 aspnetcore-runtime-10.0 dotnet-runtime-10.0
    sudo dotnet workload install android wasm-tools
}

install_cursor() {
    log_info "Preparando Cursor AI..."
    mkdir -p ~/Applications
    log_warn "Descarga Cursor AI desde cursor.com y muévelo a ~/Applications."
}

install_codecs() {
    log_info "Instalando codecs multimedia completos..."
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-libav mesa-va-drivers-freeworld intel-media-driver
}

install_pkg() {
    local pkg=$1
    log_info "Instalando $pkg via DNF..."
    sudo dnf install -y "$pkg"
}

setup_antigravity() {
    log_info "Configurando entorno para Antigravity Agent..."
    if [ ! -f "agents.md" ]; then
        log_warn "Archivo agents.md no encontrado. Asegúrate de que exista en la raíz."
    fi
    log_success "Antigravity Agent listo para operar."
}

install_lazydocker_custom() {
    log_info "Instalando LazyDocker mediante script oficial..."
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}
