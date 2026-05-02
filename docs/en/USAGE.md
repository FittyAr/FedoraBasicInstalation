# Usage Guide 📖

## Basic Navigation
The installer uses `whiptail` for the interface.
- **Up/Down Arrows**: Navigate through options.
- **Space**: Mark or unmark apps in checklists.
- **Enter**: Confirm selection or enter a category.
- **Tab**: Switch between menu options and action buttons.

## Menu Sections

### 1. Software Categories
Here you will find all available apps divided by functionality (Development, Gaming, Internet, etc.). When entering a category:
- Already installed apps will be marked with `[INSTALLED]`.
- You can select the ones you want to install.
- Upon confirmation, you will return to the main menu and see the updated selected apps count.

### 2. Preset Management
- **💾 SAVE PRESET**: Saves your current selection to a JSON file. You will be asked for a name. If the name already exists, the script will ask if you want to overwrite it.
- **📂 LOAD PRESET**: Loads a previously saved configuration. The script will verify if the apps in the preset exist in the current version of the installer.

### 3. System Actions
- **🔧 REPAIRS**: Opens a menu with tools to repair installed apps or perform general maintenance.
- **🚀 START PROCESS**: Begins the sequential installation of all selected apps.
- **❌ Exit**: Closes the installer.

## Automatic Preset Detection
If the script detects files in the `presets/` folder upon startup, it will automatically ask if you want to load one before showing the main menu.
