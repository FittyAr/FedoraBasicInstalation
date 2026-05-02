# Guía de Contribución 🤝

¡Gracias por tu interés en mejorar este proyecto! Aquí tienes una guía sobre cómo puedes ayudar.

## Cómo añadir nuevas aplicaciones
Las aplicaciones se gestionan mediante archivos JSON en la carpeta `config/apps/`.

1. **Localiza la categoría adecuada** (o crea una nueva).
2. **Añade un objeto** al array `apps`:
   ```json
   {
     "id": "nombre-unico",
     "name": "Nombre Visual",
     "description": {
       "es": "Descripción en español",
       "en": "English description"
     },
     "priority": ["dnf", "flatpak"],
     "dnf_name": "paquete-dnf",
     "flatpak_id": "org.flatpak.App",
     "repair": "comando de reparacion opcional"
   }
   ```

## Estructura del Código
- `setup_scripts/lib/installer.sh`: Lógica de instalación jerárquica (DNF -> Flatpak).
- `setup_scripts/lib/json_parser.sh`: Manejo de metadatos y consultas JSON.
- `setup_scripts/lib/presets.sh`: Gestión de guardado y carga de configuraciones.
- `setup_scripts/locales/`: Si añades un nuevo texto a la interfaz, asegúrate de añadirlo en ambos archivos (`es.sh` y `en.sh`).

## Reportar Errores
Si encuentras un fallo, por favor abre un *Issue* en GitHub describiendo:
1. Qué estabas haciendo.
2. Qué esperabas que ocurriera.
3. Qué ocurrió realmente (adjunta el log de `logs/summary.log` si es relevante).

## Pull Requests
1. Haz un *fork* del repositorio.
2. Crea una rama para tu mejora (`git checkout -b feature/mejora`).
3. Realiza tus cambios y haz *commit*.
4. Envía el *Pull Request*.
