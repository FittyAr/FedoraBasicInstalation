#!/bin/bash

# Colores
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m'
export DEBUG_MODE=false
export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export PRESET_DIR="$REPO_ROOT/presets"
export LOG_DIR="$REPO_ROOT/logs"
export SUMMARY_LOG="$LOG_DIR/summary.log"
export PRESET_VERSION="1.0"


# Iconos (solo para terminal, no para whiptail)
export CHECK="✔"
export CROSS="✖"
export INFO="ℹ"
export WARN="⚠"
export ROCKET="🚀"

log_info() { echo -e "${BLUE}${INFO} $1${NC}"; }
log_success() { echo -e "${GREEN}${CHECK} $1${NC}"; }
log_warn() { echo -e "${YELLOW}${WARN} $1${NC}"; }
log_error() { echo -e "${RED}${CROSS} $1${NC}"; }

log_to_file() {
    local file=$1
    local msg=$2
    mkdir -p "$(dirname "$file")"
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $msg" >> "$file"
}

# Verificación de dependencias críticas
check_dependencies() {
    local deps=("whiptail" "jq" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        # Nota: STR_MISSING_DEPS podría no estar cargado aún si whiptail no está
        # pero como whiptail se instala aquí, usamos un texto base si no existe la var
        echo -e "${BLUE}${INFO} $msg ${missing[*]}...${NC}"
        sudo dnf install -y newt jq curl dnf-plugins-core
    fi
}

check_distro() {
    if grep -qi "nobara" /etc/os-release; then
        echo "nobara"
    elif grep -qi "fedora" /etc/os-release; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

is_laptop() {
    ls /sys/class/power_supply/ | grep -q "BAT"
}

has_nvidia() {
    lspci | grep -qi "nvidia"
}

has_amd() {
    lspci | grep -qi -E "amd|ati"
}

create_btrfs_snapshot() {
    # Verificar si el sistema de archivos de la raíz es Btrfs
    if findmnt -n -o FSTYPE / | grep -q "btrfs"; then
        log_info "$STR_BTRFS_EXPLANATION"
        log_info "Btrfs detectado. Generando snapshot de seguridad..."
        
        local timestamp=$(date +'%Y%m%d_%H%M%S')
        local snap_name="/.snapshot_pre_install_$timestamp"
        
        # Intentar crear el snapshot
        if sudo btrfs subvolume snapshot / "$snap_name" &>/dev/null; then
            log_success "Snapshot de seguridad creado en: $snap_name"
            log_to_file "$SUMMARY_LOG" "Btrfs snapshot created: $snap_name"
        else
            log_error "ERROR: $STR_BTRFS_FAIL_TITLE"
            # Preguntar al usuario si desea continuar vía whiptail
            if whiptail --title "$STR_BTRFS_FAIL_TITLE" --yesno \
                "$STR_BTRFS_FAIL_MSG" \
                12 70; then
                log_warn "Continuando instalacion sin snapshot de seguridad (bajo riesgo del usuario)."
            else
                log_error "$STR_BTRFS_ABORTED"
                exit 1
            fi
        fi
    fi
}


# Cache de paquetes instalados
declare -g -A INSTALLED_DNF
declare -g -A INSTALLED_FLATPAK

refresh_package_cache() {
    unset INSTALLED_DNF
    declare -g -A INSTALLED_DNF
    unset INSTALLED_FLATPAK
    declare -g -A INSTALLED_FLATPAK
    
    # Cache DNF (solo nombres de paquetes)
    # Usamos dnf repoquery para mayor rapidez o awk sobre dnf list
    while read -r pkg; do
        INSTALLED_DNF["${pkg%%.*}"]=1
    done < <(dnf list installed --quiet | awk '{print $1}' | tail -n +2)

    # Cache Flatpak
    if command -v flatpak &> /dev/null; then
        while read -r fid; do
            INSTALLED_FLATPAK["$fid"]=1
        done < <(flatpak list --columns=application 2>/dev/null)
    fi
}

# Inicializar entorno
check_dependencies
DISTRO=$(check_distro)

confirm_copr() {
    local repo=$1
    if [ "$NON_INTERACTIVE" = true ]; then
        return 0
    fi
    local msg=$(printf "${STR_COPR_CONFIRM_MSG:-Se requiere el repositorio COPR %s. ¿Proceder?}" "$repo")
    echo -e "${YELLOW}${WARN} $msg${NC}" > /dev/tty
    echo -ne "${CYAN}¿Desea proceder? (s/n): ${NC}" > /dev/tty
    read -r response < /dev/tty
    if [[ "$response" =~ ^[sSyY]$ ]]; then
        return 0
    else
        log_warn "Omitiendo repositorio COPR: $repo"
        return 1
    fi
}
export -f confirm_copr
