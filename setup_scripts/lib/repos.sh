#!/bin/bash

add_rpm_fusion() {
    if rpm -q rpmfusion-free-release &>/dev/null; then
        return 0
    fi
    log_info "Añadiendo repositorios RPM Fusion (Free & Non-Free)..."
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || log_warn "Error al instalar RPM Fusion."
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
    log_info "Añadiendo repositorio de Unity Hub (Oficial)..."
    sudo rpm --import https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key
    sudo tee /etc/yum.repos.d/unityhub.repo <<EOF
[unityhub]
name=Unity Hub
baseurl=https://hub.unity3d.com/linux/repos/rpm/stable
enabled=1
gpgcheck=1
gpgkey=https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key
repo_gpgcheck=0
EOF
}

add_google_chrome_repo() {
    log_info "Añadiendo repositorio de Google Chrome..."
    sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
    sudo tee /etc/yum.repos.d/google-chrome.repo <<EOF
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
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
    log_info "Añadiendo repositorio de GitHub Desktop (Mirror Estable)..."
    sudo rpm --import https://mirror.mwt.me/shiftkey-desktop/gpgkey
    sudo tee /etc/yum.repos.d/mwt-packages.repo <<EOF
[mwt-packages]
name=GitHub Desktop
baseurl=https://mirror.mwt.me/shiftkey-desktop/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirror.mwt.me/shiftkey-desktop/gpgkey
EOF
}

add_docker_repo() {
    log_info "Añadiendo repositorio de Docker..."
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
}

add_appimagelauncher_repo() {
    if confirm_copr "atim/appimagelauncher"; then
        log_info "Añadiendo repositorio de AppImageLauncher (COPR)..."
        sudo dnf copr enable -y atim/appimagelauncher
    else
        return 1
    fi
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


add_teamviewer_repo() {
    log_info "Añadiendo repositorio de TeamViewer (Oficial)..."
    sudo rpm --import https://linux.teamviewer.com/pubkey/currentkey.asc
    sudo tee /etc/yum.repos.d/teamviewer.repo <<EOF
[teamviewer]
name=TeamViewer - stable
baseurl=https://linux.teamviewer.com/yum/stable/main/binary-\$basearch/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://linux.teamviewer.com/pubkey/TeamViewer2017.asc
EOF
}

add_anydesk_repo() {
    log_info "Añadiendo repositorio de AnyDesk..."
    sudo rpm --import https://keys.anydesk.com/repos/RPM-GPG-KEY
    sudo tee /etc/yum.repos.d/AnyDesk-Fedora.repo <<EOF
[anydesk]
name=AnyDesk Fedora - stable
baseurl=http://rpm.anydesk.com/fedora/\$basearch/
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF
}

add_vscodium_repo() {
    log_info "Añadiendo repositorio de VSCodium..."
    sudo rm -f "/etc/yum.repos.d/ vscodium .repo"
    sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    sudo sh -c 'echo -e "[vscodium]\nname=vscodium\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg" > /etc/yum.repos.d/vscodium.repo'
}
