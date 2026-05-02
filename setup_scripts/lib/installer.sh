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
)

add_vscodium_repo() {
    log_info "Añadiendo repositorio de VSCodium (OpenCode)..."
    sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    sudo sh -c 'echo -e "[ vscodium ]\nname=vscodium\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg" > /etc/yum.repos.d/vscodium.repo'
}

install_docker_full() {
    log_info "Instalando Docker Engine & Docker Desktop components..."
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    log_warn "Docker instalado. Debes cerrar sesión y volver a entrar para usar docker sin sudo."
}

install_ollama() {
    log_info "Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
}

install_dotnet_full() {
    log_info "Instalando .NET 10 SDK completo..."
    install_pkg "dotnet-sdk-10.0"
    sudo dnf install -y aspnetcore-runtime-10.0 dotnet-runtime-10.0
    log_info "Instalando workloads de .NET (Android, WASM)..."
    sudo dotnet workload install android wasm-tools
}

install_flatpak_app() {
    local app_id=$1
    log_info "Instalando Flatpak: $app_id..."
    # Asegurar que flathub esté habilitado
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub "$app_id"
}

install_pkg() {
    local pkg=$1
    # Casos especiales
    case "$pkg" in
        "ollama") install_ollama; return ;;
        "dotnet-full") install_dotnet_full; return ;;
        "docker-ce") install_docker_full; return ;;
        "android-studio") install_flatpak_app "com.google.AndroidStudio"; return ;;
        "godot") install_flatpak_app "org.godotengine.Godot"; return ;;
        "godot-net") install_flatpak_app "org.godotengine.GodotSharp"; return ;;
        "pixelorama") install_flatpak_app "com.orama_interactive.Pixelorama"; return ;;
        "sqlitestudio") install_flatpak_app "com.sqlitestudio.SQLiteStudio"; return ;;
        "heroic-games-launcher-bin") install_flatpak_app "com.heroicgameslauncher.hgl"; return ;;
        "onlyoffice") install_flatpak_app "org.onlyoffice.desktopeditors"; return ;;
        "telegram") install_pkg "telegram-desktop"; return ;;
    esac

    # Verificar si el paquete está disponible
    if ! dnf list "$pkg" > /dev/null 2>&1; then
        log_warn "El paquete '$pkg' no está en los repositorios actuales."
        
        # Buscar si tenemos una función para añadir su repo
        if [[ -v REPO_MAPPING["$pkg"] ]]; then
            local repo_func=${REPO_MAPPING["$pkg"]}
            $repo_func
        else
            log_error "No se encontró un repositorio conocido para '$pkg'."
            return 1
        fi
    fi

    log_info "Instalando $pkg..."
    sudo dnf install -y "$pkg"
    
    if [ $? -eq 0 ]; then
        log_success "$pkg instalado correctamente."
    else
        log_error "Error al instalar $pkg."
    fi
}

install_nvidia() {
    log_info "Instalando drivers privativos de NVIDIA..."
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda kernel-devel
}

install_tlp() {
    log_info "Instalando TLP para optimización de batería..."
    # TLP conflict with tuned-ppd / power-profiles-daemon in Fedora 41+
    log_warn "Eliminando conflictos (tuned-ppd / power-profiles-daemon)..."
    sudo dnf remove -y tuned-ppd power-profiles-daemon
    sudo dnf install -y tlp tlp-rdw
    sudo systemctl enable --now tlp
}

install_codecs() {
    log_info "Instalando codecs multimedia completos..."
    # DNF5 compatible commands
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-libav mesa-va-drivers-freeworld intel-media-driver
}
