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
    log_info "Instalando Docker Desktop (Requiere GNOME)..."
    
    # 1. Asegurar GNOME y dependencias (pedido por el usuario)
    log_info "Instalando componentes de GNOME y dependencias..."
    sudo dnf groupinstall -y "GNOME"
    sudo dnf install -y gnome-terminal dnf-plugins-core
    
    # 2. Configurar repositorio de Docker (necesario para dependencias del RPM)
    log_info "Configurando repositorio de Docker..."
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    
    # 3. Descargar e instalar Docker Desktop
    local temp_dir=$(mktemp -d)
    log_info "Descargando Docker Desktop RPM..."
    # URL genérica para la última versión estable en x86_64
    if curl -L https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm -o "$temp_dir/docker-desktop.rpm"; then
        log_info "Instalando Docker Desktop..."
        sudo dnf install -y "$temp_dir/docker-desktop.rpm"
    else
        log_error "No se pudo descargar el RPM de Docker Desktop."
        return 1
    fi
    
    # 4. Post-instalación
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    
    rm -rf "$temp_dir"
    log_success "Docker Desktop instalado correctamente."
    log_warn "Debes cerrar sesión e iniciar sesión en GNOME para usar Docker Desktop."
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
    
    if has_nvidia; then
        log_info "GPU NVIDIA detectada. Ollama utilizará aceleración CUDA."
        # El script oficial de Ollama detecta y configura NVIDIA automáticamente
    elif has_amd; then
        log_info "GPU AMD detectada. Asegúrate de tener ROCm instalado para aceleración."
        log_warn "Ollama soporta AMD vía ROCm v6+. Consultar docs.ollama.com si hay problemas."
    else
        log_warn "No se detectó GPU dedicada compatible. Ollama se ejecutará en modo CPU."
    fi

    curl -fsSL https://ollama.com/install.sh | sh
    sudo systemctl enable --now ollama
}

install_dotnet_full() {
    log_info "Instalando .NET 10 SDK completo..."
    # Según docs de Microsoft para Fedora
    sudo dnf install -y dotnet-sdk-10.0 aspnetcore-runtime-10.0 dotnet-runtime-10.0
    
    # Instalación de workloads comunes si es necesario
    if command -v dotnet &> /dev/null; then
        log_info "Instalando workloads de .NET (android, wasm)..."
        sudo dotnet workload install android wasm-tools || log_warn "No se pudieron instalar algunos workloads."
    fi
}

install_cursor() {
    log_info "Preparando Cursor AI..."
    # Cursor ahora se instala vía DNF gracias al repositorio añadido.
    # Esta función queda como respaldo para configuraciones adicionales.
    log_success "Cursor AI listo (instalado vía DNF)."
}

install_zed() {
    log_info "Instalando Zed Editor vía script oficial..."
    curl -f https://zed.dev/install.sh | sh
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
    # Aquí se podrían añadir configuraciones post-instalación del paquete RPM
    log_success "Antigravity Agent listo para operar."
}

install_rustdesk_custom() {
    log_info "Instalando RustDesk vía Flatpak (Ámbito de Usuario)..."
    
    # 1. Añadir remoto Flathub en ámbito de usuario
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # 2. Descargar el archivo .flatpak (buscando la última versión en GitHub)
    local temp_dir=$(mktemp -d)
    log_info "Buscando última versión de RustDesk en GitHub..."
    local latest_url=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep "browser_download_url.*\.flatpak" | cut -d '"' -f 4 | head -n 1)
    
    if [ -n "$latest_url" ]; then
        log_info "Descargando RustDesk Flatpak..."
        curl -L "$latest_url" -o "$temp_dir/rustdesk.flatpak"
        
        # 3. Instalar
        log_info "Instalando archivo .flatpak..."
        flatpak --user install -y "$temp_dir/rustdesk.flatpak"
    else
        log_warn "No se pudo encontrar el archivo .flatpak en GitHub. Intentando instalación directa desde Flathub (si existe)..."
        flatpak --user install -y flathub com.rustdesk.RustDesk
    fi
    
    rm -rf "$temp_dir"
    log_success "RustDesk configurado correctamente."
}

install_lazydocker_custom() {
    log_info "Instalando LazyDocker mediante script oficial..."
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}

