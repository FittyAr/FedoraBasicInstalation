#!/bin/bash

add_rpm_fusion() {
    log_info "Añadiendo repositorios RPM Fusion (Free & Non-Free)..."
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}

add_vscode_repo() {
    log_info "Añadiendo repositorio de Visual Studio Code..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
}

add_brave_repo() {
    log_info "Añadiendo repositorio de Brave Browser..."
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
}

add_edge_repo() {
    log_info "Añadiendo repositorio de Microsoft Edge..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager addrepo --from-repofile=https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo
}

add_unity_repo() {
    log_info "Añadiendo repositorio de Unity Hub..."
    sudo sh -c 'echo -e "[unityhub]\nname=Unity Hub\nbaseurl=https://hub.unity3d.com/linux/repos/rpm\nenabled=1\ngpgcheck=1\ngpgkey=https://hub.unity3d.com/linux/repos/rpm/repodata/repomd.xml.key" > /etc/yum.repos.d/unityhub.repo'
}

add_google_chrome_repo() {
    log_info "Añadiendo repositorio de Google Chrome..."
    # Chrome doesn't provide a .repo file directly via URL usually, we use the baseurl format or skip if already there
    sudo dnf config-manager addrepo --name=google-chrome --baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
}

add_microsoft_repo() {
    log_info "Añadiendo repositorio de Microsoft (.NET/Edge)..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    # Fallback to Fedora 41 if 44 is not yet in Microsoft repos
    local fed_ver=$(rpm -E %fedora)
    [[ $fed_ver -gt 41 ]] && fed_ver=41
    sudo dnf config-manager addrepo --from-repofile=https://packages.microsoft.com/config/fedora/$fed_ver/prod.repo
}

add_github_desktop_repo() {
    log_info "Añadiendo repositorio de GitHub Desktop (COPR)..."
    sudo dnf copr enable -y shiftkey/desktop
}

add_docker_repo() {
    log_info "Añadiendo repositorio de Docker..."
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
}

add_appimagelauncher_repo() {
    log_info "Añadiendo repositorio de AppImageLauncher (COPR)..."
    sudo dnf copr enable -y allexj/AppImageLauncher
}

add_warp_repo() {
    log_info "Añadiendo repositorio de Warp Terminal..."
    sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc
    sudo sh -c 'echo -e "[warpdotdev]\nname=warpdotdev\nbaseurl=https://releases.warp.dev/linux/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://releases.warp.dev/linux/keys/warp.asc" > /etc/yum.repos.d/warpdotdev.repo'
}

add_tailscale_repo() {
    log_info "Añadiendo repositorio de Tailscale..."
    sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
}

add_lazydocker_repo() {
    log_info "Añadiendo repositorio de LazyDocker (COPR)..."
    sudo dnf copr enable -y atim/lazydocker
}

