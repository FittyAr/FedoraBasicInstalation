#!/bin/bash
BASE_DIR="$(pwd)/setup_scripts"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/detection.sh"
refresh_package_cache
is_installed "gimp" && echo "GIMP IS INSTALLED" || echo "GIMP IS NOT INSTALLED"
is_installed "handbrake" && echo "HANDBRAKE IS INSTALLED" || echo "HANDBRAKE IS NOT INSTALLED"
