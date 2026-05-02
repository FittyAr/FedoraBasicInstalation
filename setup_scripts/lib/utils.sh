#!/bin/bash

# Colores
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m'

# Iconos
export CHECK="✔"
export CROSS="✖"
export INFO="ℹ"
export WARN="⚠"
export ROCKET="🚀"

log_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

log_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}${WARN} $1${NC}"
}

log_error() {
    echo -e "${RED}${CROSS} $1${NC}"
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
    if ls /sys/class/power_supply/ | grep -q "BAT"; then
        return 0
    else
        return 1
    fi
}

has_nvidia() {
    if lspci | grep -qi "nvidia"; then
        return 0
    else
        return 1
    fi
}
