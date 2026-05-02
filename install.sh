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

# Configuración de UI Dinámica
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
TERM_LINES=$(tput lines 2>/dev/null || echo 24)

WIDTH=$((TERM_COLS - 6))
[ $WIDTH -gt 100 ] && WIDTH=100
[ $WIDTH -lt 60 ] && WIDTH=60

HEIGHT=$((TERM_LINES - 4))
[ $HEIGHT -gt 24 ] && HEIGHT=24
[ $HEIGHT -lt 15 ] && HEIGHT=15

LIST_HEIGHT=$((HEIGHT - 10))

# Estado global de aplicaciones seleccionadas
declare -A SELECTED_STATE

# Definición de software por categorías
apps_hardware=(
    "nvidia" "Drivers NVIDIA" "OFF" "nvidia" "Drivers oficiales privativos para maximo rendimiento 3D."
    "tlp" "TLP Bateria" "OFF" "tlp" "Optimizacion avanzada de energia para laptops."
    "codecs" "Codecs Multimedia" "ON" "codecs" "Soporte para formatos propietarios (H.264, AAC, etc.)."
    "appimagelauncher" "AppImageLauncher" "ON" "appimagelauncher" "Integracion facil de archivos .AppImage en el sistema."
    "timeshift" "Timeshift Snapshots" "OFF" "timeshift" "Puntos de restauracion para revertir cambios del sistema."
)

apps_dev=(
    "code" "VS Code" "OFF" "code" "Editor de Microsoft con gran ecosistema de extensiones."
    "vscodium" "VSCodium" "OFF" "vscodium" "Version de VS Code 100% libre, sin telemetria."
    "cursor" "Cursor AI" "OFF" "cursor" "Editor de codigo optimizado para programar con IA."
    "github-desktop" "GitHub Desktop" "OFF" "GitHubDesktop" "Interfaz grafica intuitiva para gestionar Git y GitHub."
    "android-studio" "Android Studio" "OFF" "android-studio" "Entorno oficial para apps moviles Android."
    "unityhub" "Unity Hub" "OFF" "unityhub" "Gestor oficial para versiones y proyectos del motor Unity."
    "godot-net" "Godot Engine .NET" "OFF" "godot-net" "Motor de juegos ligero con soporte para C# (Flatpak)."
    "dotnet-full" ".NET 10 SDK" "ON" "dotnet-full" "Kit de desarrollo completo de Microsoft para apps modernas."
    "docker" "Docker Desktop" "OFF" "docker-ce" "Contenedores para desarrollar y ejecutar aplicaciones."
    "nodejs" "Node.js & NPM" "OFF" "nodejs" "Entorno de ejecucion para JS en servidor y NPM."
)

apps_net=(
    "brave-browser" "Brave Browser" "OFF" "brave-browser" "Navegador veloz con bloqueo de anuncios integrado."
    "google-chrome" "Google Chrome" "OFF" "google-chrome-stable" "El navegador mas usado, con sincronizacion de Google."
    "telegram" "Telegram Desktop" "OFF" "telegram" "Mensajeria rapida, segura y multidispositivo."
    "discord" "Discord" "OFF" "discord" "Plataforma de comunicacion para comunidades y gamers."
    "qbittorrent" "qBittorrent" "OFF" "qbittorrent" "Cliente BitTorrent libre, ligero y potente."
)

apps_gaming=(
    "steam" "Steam" "OFF" "steam" "La plataforma de videojuegos mas grande disponible."
    "lutris" "Lutris" "OFF" "lutris" "Gestor de juegos todo-en-uno (Epic, GOG, Steam, etc.)."
    "heroic" "Heroic Launcher" "OFF" "heroic-games-launcher-bin" "Cliente abierto para Epic Games, GOG y Amazon."
    "gimp" "GIMP Editor" "OFF" "gimp" "Editor de imagenes profesional y libre (tipo Photoshop)."
    "inkscape" "Inkscape" "OFF" "inkscape" "Herramienta de diseño vectorial profesional (tipo Illustrator)."
    "onlyoffice" "OnlyOffice" "OFF" "onlyoffice" "Suite ofimatica con gran compatibilidad MS Office."
)

# Inicializar estado
init_state() {
    local -n category=$1
    for ((i=0; i<${#category[@]}; i+=5)); do
        SELECTED_STATE["${category[i]}"]="${category[i+2]}"
    done
}

init_state apps_hardware
init_state apps_dev
init_state apps_net
init_state apps_gaming

# Contar seleccionados por categoría
count_selected() {
    local -n category=$1
    local count=0
    for ((i=0; i<${#category[@]}; i+=5)); do
        if [[ "${SELECTED_STATE["${category[i]}"]}" == "ON" ]]; then
            ((count++))
        fi
    done
    echo $count
}

# Mostrar checklist con formato de tabla
show_category() {
    local title=$1
    local -n category=$2
    local args=()
    local num_items=$((${#category[@]} / 5))
    
    # Ajuste dinámico de altura local
    local box_h=$((num_items + 12))
    [ $box_h -gt $HEIGHT ] && box_h=$HEIGHT
    local list_h=$((box_h - 10))

    # Cabecera simulada
    local h_name="APLICACION"
    local h_desc="DESCRIPCION"
    local instruction="Espacio para marcar, Enter para confirmar.\n\n$h_name | $h_desc\n--------------------------------------------------"

    for ((i=0; i<${#category[@]}; i+=5)); do
        local id="${category[i]}"
        local name="${category[i+1]}"
        local desc="${category[i+4]}"
        local state="${SELECTED_STATE[$id]}"
        
        local name_fmt=$(printf "%-20s" "$name")
        args+=("$id" "$name_fmt | $desc" "$state")
    done

    local selected=$(whiptail --title "$title" --checklist \
        "$instruction" \
        $box_h $WIDTH $list_h "${args[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        for ((i=0; i<${#category[@]}; i+=5)); do
            SELECTED_STATE["${category[i]}"]="OFF"
        done
        for id in $selected; do
            id=$(echo $id | tr -d '"')
            SELECTED_STATE["$id"]="ON"
        done
    fi
}

# Bucle principal
while true; do
    c_hw=$(count_selected apps_hardware)
    c_dev=$(count_selected apps_dev)
    c_net=$(count_selected apps_net)
    c_gam=$(count_selected apps_gaming)
    total=$((c_hw + c_dev + c_net + c_gam))

    CHOICE=$(whiptail --title "Setup Fedora/Nobara" --menu \
        "Seleccionados: $total. Elige una categoria para configurar:" \
        $HEIGHT $WIDTH $LIST_HEIGHT \
        "1" "Hardware y Sistema      [$c_hw]" \
        "2" "Desarrollo e IA          [$c_dev]" \
        "3" "Internet y Comunicacion  [$c_net]" \
        "4" "Gaming y Creatividad     [$c_gam]" \
        "5" "INICIAR INSTALACION" \
        "6" "Salir" 3>&1 1>&2 2>&3)

    case "$CHOICE" in
        "1") show_category "Hardware" apps_hardware ;;
        "2") show_category "Desarrollo" apps_dev ;;
        "3") show_category "Internet" apps_net ;;
        "4") show_category "Gaming" apps_gaming ;;
        "5") break ;;
        "6") exit 0 ;;
        *) continue ;;
    esac
done

# Recopilar apps
FINAL_APPS=""
for id in "${!SELECTED_STATE[@]}"; do
    [[ "${SELECTED_STATE[$id]}" == "ON" ]] && FINAL_APPS+="$id "
done

if [[ -z "$FINAL_APPS" ]]; then
    log_warn "No se selecciono ninguna aplicacion."
else
    log_info "Iniciando instalacion masiva..."
    
    for APP in $FINAL_APPS; do
        REAL_PKG=""
        all_apps=("${apps_hardware[@]}" "${apps_dev[@]}" "${apps_net[@]}" "${apps_gaming[@]}")
        for ((i=0; i<${#all_apps[@]}; i+=5)); do
            [[ "${all_apps[i]}" == "$APP" ]] && REAL_PKG="${all_apps[i+3]}" && break
        done
        
        case "$REAL_PKG" in
            "nvidia") install_nvidia ;;
            "tlp") install_tlp ;;
            "codecs") install_codecs ;;
            *) install_pkg "$REAL_PKG" ;;
        esac
    done
fi

# Limpieza
log_info "Finalizando procesos..."
sudo dnf autoremove -y
sudo dnf clean all

log_success "¡Setup completado con éxito!"
echo -e "${BLUE}Recuerda reiniciar tu equipo para aplicar todos los cambios.${NC}"
