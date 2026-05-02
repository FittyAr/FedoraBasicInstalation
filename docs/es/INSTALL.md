# Instalación y Requisitos 🛠

## Requisitos del Sistema
- **Sistema Operativo**: Fedora (Workstation, Silverblue, etc.) o Nobara.
- **Conexión a Internet**: Necesaria para descargar los paquetes.
- **Privilegios**: Se requieren permisos de `sudo` para instalar paquetes.

## Dependencias Automáticas
El script intentará instalar automáticamente las siguientes dependencias si no están presentes:
- `whiptail` (parte de `newt`): Para la interfaz gráfica de terminal.
- `jq`: Para el procesamiento de archivos JSON.
- `curl`: Para la comunicación con repositorios externos.

## Instalación del Script

1. **Descargar el proyecto**:
   ```bash
   git clone https://github.com/FittyAr/FedoraBasicInstalation.git
   ```

2. **Otorgar permisos de ejecución**:
   ```bash
   cd FedoraBasicInstalation
   chmod +x install.sh
   ```

3. **Ejecutar**:
   ```bash
   ./install.sh
   ```

## Parámetros de Línea de Comandos
Puedes saltar la selección de idioma o cargar un preset directamente:
- `./install.sh --lang es`: Inicia en español.
- `./install.sh --preset mis_apps.json`: Carga el preset especificado al iniciar.
