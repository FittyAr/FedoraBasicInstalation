#!/bin/bash

# UI Strings - English
export STR_OPTIMIZING_DNF="[!] Optimizing DNF..."
export STR_ANALYZING_SYSTEM="[*] Analyzing system..."
export STR_SELECTION_HINT="SPACE: mark/unmark | ENTER: confirm"
export STR_REPAIRS_TITLE="REPAIRS"
export STR_REPAIRS_MENU="Choose a maintenance task:"
export STR_REPAIR_APP="Repair"
export STR_MAIN_MENU_TITLE="FEDORA MODULAR INSTALLER"
export STR_SELECTED_COUNT="Selected: "
export STR_MENU_REPAIR="REPAIRS AND MAINTENANCE"
export STR_MENU_INSTALL="START INSTALLATION PROCESS"
export STR_MENU_UNINSTALL="APPLICATION UNINSTALLER"
export STR_MENU_EXIT="Exit"

export STR_PROCESS_COMPLETED="Process completed."
export STR_MISSING_DEPS="Installing dependencies: "
export STR_INSTALLING_APP="Installing: "
export STR_INSTALLED_VIA_DNF="installed via DNF."
export STR_INSTALLED_VIA_FLATPAK="installed via Flatpak."
export STR_INSTALL_FAILED="Installation error."
export STR_EXECUTING_REPAIR="Executing: "
export STR_REPAIR_SUCCESS="Repair finished."
export STR_REPAIR_FAILED="Repair failed."
export STR_REPAIR_NOT_FOUND="No repair command found for "
export STR_INSTALLED_TAG="[INSTALLED]"
export STR_UNINSTALLER_TITLE="UNINSTALLER"
export STR_UNINSTALL_HINT="Select the installed applications you want to remove:"
export STR_UNINSTALL_SUCCESS="[+] %s uninstalled successfully."
export STR_UNINSTALL_FAILED="[!] Error uninstalling %s."
export STR_SELECT_LANG="Select Language"
export STR_MENU_SAVE_PRESET="SAVE CONFIGURATION (PRESET)"
export STR_MENU_LOAD_PRESET="LOAD CONFIGURATION (PRESET)"

export STR_ENTER_PRESET_NAME="Preset name (without .json):"
export STR_PRESET_SAVED="Preset saved successfully at: "
export STR_SELECT_PRESET="Select a preset to load:"
export STR_SUMMARY_LOG_CREATED="Summary created at: "
export STR_HELP_TITLE="Installer Help"
export STR_HELP_TEXT="Usage: ./install.sh [OPTIONS]\n\nOptions:\n  -l, --lang CODE       Language (es, en)\n  -p, --preset FILE     Load specific JSON preset\n  -d, --preset-dir DIR  Preset directory\n  -g, --debug           Debug mode\n  -h, --help            Show help"
export STR_OK="Select"
export STR_CANCEL="Back"
export STR_CONTINUE="Continue"
export STR_ACCEPT="Accept"
export STR_OVERWRITE_CONFIRM="Do you want to overwrite it?"
export STR_STARTUP_LOAD_PRESET="Existing presets detected. Load one now?"
export STR_INCOMPATIBLE_PRESET="Warning: Incompatible or incomplete preset."
export STR_APPS_NOT_FOUND="Not found:"
export STR_MENU_SECTION_SOFTWARE="--- SOFTWARE CATEGORIES ---"

export STR_COPR_CONFIRM_TITLE="Third-Party Repository (COPR)"
export STR_COPR_CONFIRM_MSG="Enabling the COPR repository '%s' is required. Do you want to proceed?"

export STR_BTRFS_EXPLANATION="Btrfs detected. The script will create a snapshot (instant backup) of your system so you can easily restore it if something goes wrong during installation."
export STR_BTRFS_FAIL_TITLE="Snapshot Failed"
export STR_BTRFS_FAIL_MSG="Failed to create the security snapshot. Do you want to continue the installation WITHOUT a backup, or would you rather abort to investigate?"
export STR_BTRFS_ABORTED="Installation aborted for security reasons."

# Snapshot Snapper
export STR_SNAPPER_DETECTED="[*] Snapper detected (config: %s). Generating 'pre' snapshot..."
export STR_SNAPPER_PRE_SUCCESS="[+] Pre-installation snapshot created (ID: %s)"
export STR_SNAPPER_POST_START="[*] Closing Snapper snapshot..."
export STR_SNAPPER_POST_SUCCESS="[+] Post-installation snapshot created."
export STR_BTRFS_DIRECT_START="[*] Generating security snapshot (direct btrfs)..."

# New strings for total i18n
export STR_LOG_SESSION_START="--- Starting Session: %s ---"
export STR_VERIFYING_REPOS="[*] Verifying repository integrity..."
export STR_SYNC_REPOS="[*] Synchronizing repositories and accepting GPG keys..."
export STR_ERR_DB_BUILD="[!] Critical failure while building the application database."
export STR_APP_STATE_INIT="[*] Application state initialized."
export STR_MAIN_LOOP_START="[*] Entering the main loop..."
export STR_ERR_EMPTY_MENU="[!] The software menu is empty. Check the files in config/apps/"
export STR_ERR_ODD_MENU="[!] Internal error: menu_args has an odd number of elements"
export STR_WHIPTAIL_ESC="[!] Whiptail interrupted (ESC)"
export STR_WHIPTAIL_NO_SEL="[!] Whiptail returned no selection."
export STR_ALREADY_INSTALLED="%s is already installed. Skipping..."

# Repositories
export STR_ADDING_REPO="[*] Adding repository for %s..."
export STR_ADDING_RPM_FUSION="[*] Adding RPM Fusion repositories (Free & Non-Free)..."
export STR_ERR_RPM_FUSION="[!] Error while installing RPM Fusion."

# Specific Installers
export STR_INSTALL_DOCKER_GNOME="[*] Installing Docker Desktop (Requires GNOME)..."
export STR_INSTALL_GNOME_DEPS="[*] Installing GNOME components and dependencies..."
export STR_CONFIG_DOCKER_REPO="[*] Configuring Docker repository..."
export STR_DOWNLOAD_DOCKER_RPM="[*] Downloading Docker Desktop RPM..."
export STR_ERR_DOCKER_DOWNLOAD="[!] Could not download Docker Desktop RPM."
export STR_DOCKER_SUCCESS="[+] Docker Desktop installed successfully."
export STR_DOCKER_LOGOUT="[!] You must log out and log back in to GNOME to use Docker Desktop."

export STR_INSTALL_TAILSCALE="[*] Installing and configuring Tailscale..."
export STR_TAILSCALE_READY="[+] Tailscale ready. Run 'sudo tailscale up' to log in."

export STR_INSTALL_WAYDROID="[*] Installing and preparing Waydroid..."
export STR_WAYDROID_INIT="[!] Waydroid installed. Requires manual initialization: 'sudo waydroid init'."

export STR_INSTALL_PHOTOGIMP="[*] Installing PhotoGIMP patch for GIMP Flatpak..."
export STR_INSTALL_GIMP_FIRST="[*] Installing GIMP via Flatpak first..."
export STR_DOWNLOAD_PHOTOGIMP="[*] Downloading PhotoGIMP..."
export STR_PHOTOGIMP_SUCCESS="[+] PhotoGIMP applied successfully."

export STR_INSTALL_OLLAMA="[*] Installing Ollama..."
export STR_GPU_NVIDIA_DETECTED="[*] NVIDIA GPU detected. Ollama will use CUDA acceleration."
export STR_GPU_AMD_DETECTED="[*] AMD GPU detected. Make sure you have ROCm installed for acceleration."
export STR_GPU_AMD_ROCM_WARN="[!] Ollama supports AMD via ROCm v6+. Check docs.ollama.com if there are issues."
export STR_GPU_NOT_FOUND="[!] No compatible dedicated GPU detected. Ollama will run in CPU mode."

export STR_INSTALL_DOTNET_FULL="[*] Installing full .NET 10 SDK..."
export STR_INSTALL_DOTNET_WORKLOADS="[*] Installing .NET workloads (android, wasm)..."
export STR_ERR_DOTNET_WORKLOADS="[!] Could not install some workloads."

export STR_PREPARING_CURSOR="[*] Preparing Cursor AI..."
export STR_CURSOR_READY="[+] Cursor AI ready (installed via DNF)."

export STR_INSTALL_ZED="[*] Installing Zed Editor via official script..."
export STR_INSTALL_CODECS="[*] Installing full multimedia codecs..."
export STR_CONFIG_ANTIGRAVITY="[*] Configuring environment for Antigravity Agent..."
export STR_ERR_AG_MD_NOT_FOUND="[!] agents.md file not found. Make sure it exists in the root."
export STR_AG_READY="[+] Antigravity Agent ready to operate."

export STR_INSTALL_RUSTDESK="[*] Installing RustDesk via Flatpak (User Scope)..."
export STR_SEARCH_RUSTDESK_GH="[*] Searching for the latest RustDesk version on GitHub..."
export STR_DOWNLOAD_RUSTDESK_FLATPAK="[*] Downloading RustDesk Flatpak..."
export STR_INSTALL_FLATPAK_FILE="[*] Installing .flatpak file..."
export STR_ERR_RUSTDESK_GH="[!] Could not find .flatpak file on GitHub. Attempting direct installation..."
export STR_RUSTDESK_SUCCESS="[+] RustDesk configured successfully."

export STR_INSTALL_LAZYDOCKER="[*] Installing LazyDocker via official script..."
export STR_INSTALL_ZEROTIER="[*] Installing ZeroTier One via official script..."
export STR_INSTALL_DNF_PKG="[*] Installing %s via DNF..."

# DNF Locks
export STR_DNF_LOCKED_TITLE="DNF Busy / Locked"
export STR_DNF_LOCKED_MSG="Another process is currently using DNF (possibly an automatic update).\n\nDo you want to wait for it to finish or would you rather abort the installation to avoid conflicts?"
export STR_WAIT="Wait"
export STR_ABORT="Abort"
export STR_DNF_WAITING="[*] Waiting for DNF lock to be released..."
export STR_DNF_ABORTED="[!] Installation aborted to avoid DNF conflicts."

# Presets and System Logs
export STR_ERR_NO_APPS_SELECTED="[!] No apps selected. Saving empty preset."
export STR_LOG_PRESET_SAVED="Preset saved: %s (Version: %s)"
export STR_ERR_PRESET_NOT_FOUND="[!] Preset file not found: %s"
export STR_WARN_PRESET_VERSION="[!] Warning: Preset version mismatch (%s vs %s)"
export STR_LOG_PRESET_LOADED="Preset loaded: %s (%d apps)"
export STR_ERR_NO_PRESETS="No presets found in %s"

# Installation Logs
export STR_LOG_SUCCESS="[+] SUCCESS: %s installed via %s"
export STR_LOG_FAILED="[-] FAILED: %s could not be installed"
export STR_LOG_TRYING="[*] Trying method: %s for %s"
export STR_LOG_INSTALL_START="[*] Starting installation of %s"
export STR_LOG_INSTALL_LOG_HEADER="--- Installation Log for %s ---"

# Parser
export STR_ERR_MASTER_JSON="[!] Error building master JSON. Check /tmp/jq_err.log"
