# Installation and Prerequisites 🛠

## System Requirements
- **Operating System**: Fedora (Workstation, Silverblue, etc.) or Nobara.
- **Internet Connection**: Required to download packages.
- **Privileges**: `sudo` permissions are required to install packages.

## Automatic Dependencies
The script will attempt to automatically install the following dependencies if they are not present:
- `whiptail` (part of `newt`): For the terminal graphical interface.
- `jq`: For processing JSON files.
- `curl`: For communicating with external repositories.

## Script Installation

1. **Download the project**:
   ```bash
   git clone https://github.com/FittyAr/FedoraBasicInstalation.git
   ```

2. **Grant execution permissions**:
   ```bash
   cd FedoraBasicInstalation
   chmod +x install.sh
   ```

3. **Execute**:
   ```bash
   ./install.sh
   ```

## Command Line Parameters
You can skip language selection or load a preset directly:
- `./install.sh --lang en`: Starts in English.
- `./install.sh --preset my_apps.json`: Loads the specified preset on startup.
