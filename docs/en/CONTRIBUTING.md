# Contributing Guide 🤝

Thank you for your interest in improving this project! Here is a guide on how you can help.

## How to add new applications
Applications are managed via JSON files in the `config/apps/` folder.

1. **Locate the appropriate category** (or create a new one).
2. **Add an object** to the `apps` array:
   ```json
   {
     "id": "unique-id",
     "name": "Display Name",
     "description": {
       "es": "Spanish description",
       "en": "English description"
     },
     "priority": ["dnf", "flatpak"],
     "dnf_name": "dnf-package",
     "flatpak_id": "org.flatpak.App",
     "repair": "optional repair command"
   }
   ```

## Code Structure
- `setup_scripts/lib/installer.sh`: Hierarchical installation logic (DNF -> Flatpak).
- `setup_scripts/lib/json_parser.sh`: Metadata handling and JSON queries.
- `setup_scripts/lib/presets.sh`: Management of saving and loading configurations.
- `setup_scripts/locales/`: If you add new text to the interface, make sure to add it to both files (`es.sh` and `en.sh`).

## Reporting Bugs
If you find a bug, please open an *Issue* on GitHub describing:
1. What you were doing.
2. What you expected to happen.
3. What actually happened (attach the log from `logs/summary.log` if relevant).

## Pull Requests
1. *Fork* the repository.
2. Create a branch for your improvement (`git checkout -b feature/improvement`).
3. Make your changes and *commit*.
4. Submit the *Pull Request*.
