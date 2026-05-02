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
    log_info "Añadiendo repositorio de VSCodium..."
    sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    sudo sh -c 'echo -e "[ vscodium ]\nname=vscodium\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg" > /etc/yum.repos.d/vscodium.repo'
}

install_docker_full() {
    log_info "Instalando Docker Engine & Docker Desktop components..."
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    log_warn "Docker instalado. Debes cerrar sesión para usarlo sin sudo."
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
