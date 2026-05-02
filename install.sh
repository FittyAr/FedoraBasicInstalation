#!/bin/bash

# Directorio base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup_scripts"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/repos.sh"
source "$BASE_DIR/lib/installer.sh"

# 0. VERIFICACIÓN DE DEPENDENCIAS
if ! command -v whiptail &> /dev/null; then
    log_info "Whiptail no encontrado. Instalando dependencias necesarias (newt)..."
    sudo dnf install -y newt
fi

clear
echo -e "${CYAN}${ROCKET} Bienvenido al Setup Avanzado Fedora/Nobara${NC}"
echo "----------------------------------------------------"

# 1. OPTIMIZACIÓN DE DNF
log_info "Optimizando DNF para descargas más rápidas..."
if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
    echo -e "max_parallel_downloads=10\nfastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
fi

# 2. DETECCIÓN DE SISTEMA
DISTRO=$(check_distro)
log_info "Sistema detectado: ${DISTRO^}"

if [[ "$DISTRO" == "fedora" ]]; then
    log_info "Configurando RPM Fusion para Fedora..."
    add_rpm_fusion
    sudo dnf upgrade -y
elif [[ "$DISTRO" == "nobara" ]]; then
    log_info "Nobara detectado. Se recomienda usar 'nobara-sync' después de este script."
else
    log_warn "Distribución no reconocida oficialmente, pero se intentará continuar."
fi

# 3. MENÚ DE SELECCIÓN DE SOFTWARE
log_info "Preparando menú de aplicaciones..."

# Definición de software: "ID" "Descripción" "Estado(ON/OFF)" "Función/Paquete"
options=(
    # --- HARDWARE & SISTEMA ---
    "nvidia" "Drivers NVIDIA (Privativos)" OFF "nvidia"
    "tlp" "TLP (Batería - Laptop)" OFF "tlp"
    "codecs" "Codecs Multimedia (Completos)" ON "codecs"
    "onlyoffice" "OnlyOffice (Office Suite)" OFF "onlyoffice"
    "appimagelauncher" "AppImageLauncher" ON "appimagelauncher"
    "timeshift" "Timeshift (Snapshots)" OFF "timeshift"
    
    # --- DESARROLLO ---
    "dotnet-full" ".NET 10 SDK Full" ON "dotnet-full"
    "code" "VS Code (Microsoft)" OFF "code"
    "vscodium" "VSCodium (Open Source)" OFF "vscodium"
    "cursor" "Cursor IDE (AI)" OFF "appimagelauncher"
    "github-desktop" "GitHub Desktop" OFF "GitHubDesktop"
    "android-studio" "Android Studio" OFF "android-studio"
    "unityhub" "Unity Hub" OFF "unityhub"
    "godot-net" "Godot Engine (.NET)" OFF "godot-net"
    "docker" "Docker Desktop/Engine" OFF "docker-ce"
    "nodejs" "Node.js & NPM" OFF "nodejs"
    
    # --- INTERNET & COMUNICACIÓN ---
    "brave-browser" "Brave Browser" OFF "brave-browser"
    "google-chrome" "Google Chrome" OFF "google-chrome-stable"
    "telegram" "Telegram Desktop" OFF "telegram"
    "discord" "Discord" OFF "discord"
    "qbittorrent" "qBittorrent" OFF "qbittorrent"
    
    # --- GAMING & CREATIVIDAD ---
    "steam" "Steam (Gaming)" OFF "steam"
    "lutris" "Lutris" OFF "lutris"
    "heroic" "Heroic Games Launcher" OFF "heroic-games-launcher-bin"
    "gimp" "GIMP (Editor)" OFF "gimp"
    "inkscape" "Inkscape" OFF "inkscape"
)

# Generar argumentos para whiptail (ID, DESC, STATUS)
whiptail_args=()
for ((i=0; i<${#options[@]}; i+=4)); do
    whiptail_args+=("${options[i]}" "${options[i+1]}" "${options[i+2]}")
done

# Capturar selección
SELECTED_APPS=$(whiptail --title "Setup Avanzado Fedora/Nobara" \
    --checklist "Selecciona lo que deseas instalar:" \
    20 75 12 \
    "${whiptail_args[@]}" 3>&1 1>&2 2>&3)

exit_status=$?

if [[ $exit_status -ne 0 ]] || [[ -z "$SELECTED_APPS" ]]; then
    log_warn "No se seleccionó ninguna aplicación o se canceló."
else
    # Limpiar las comillas
    SELECTED_APPS=$(echo $SELECTED_APPS | tr -d '"')
    
    log_info "Iniciando instalación de seleccionados..."
    
    for APP in $SELECTED_APPS; do
        # Buscar el paquete/función
        REAL_PKG=""
        for ((i=0; i<${#options[@]}; i+=4)); do
            if [[ "${options[i]}" == "$APP" ]]; then
                REAL_PKG="${options[i+3]}"
                break
            fi
        done
        
        # Ejecutar instalador
        case "$REAL_PKG" in
            "nvidia") install_nvidia ;;
            "tlp") install_tlp ;;
            "codecs") install_codecs ;;
            *) install_pkg "$REAL_PKG" ;;
        esac
    done
fi

# 4. LIMPIEZA
log_info "Limpiando sistema..."
sudo dnf autoremove -y
sudo dnf clean all

log_success "¡Setup completado con éxito!"
echo -e "${BLUE}Recuerda reiniciar tu equipo para aplicar todos los cambios.${NC}"
