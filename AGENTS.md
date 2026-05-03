Los Walkthroughs, Task e Implementation Plan deben ser redactados en español.

# Agentic Configuration - FedoraBasicInstalation

Este archivo define las reglas y el contexto para que los agentes de IA (como Antigravity, Cursor, etc) operen dentro de este repositorio de forma segura y consistente.

## Reglas de Comportamiento

1.  **Modularidad Primero**: No agregues lógica pesada directamente en `install.sh`. Usa la estructura de librerías en `setup_scripts/lib/`.
2.  **Configuración via JSON**: Todas las aplicaciones deben estar definidas en `config/software.json`. Si una app requiere un repositorio especial, agrégalo a `repos.sh`.
3.  **No Placeholders**: Al proponer cambios, asegúrate de que los IDs de Flatpak y los nombres de paquetes DNF sean correctos y verificados.
4.  **Logging Estándar**: Usa las funciones `log_info`, `log_warn`, `log_success` y `log_error` para mantener al usuario informado.
5.  **Seguridad de Sudo**: El script está diseñado para ejecutarse sin privilegios de root inicialmente y pedir sudo solo cuando sea necesario. No asumas persistencia de sudo.
6.  **Validación de Instalación**: Siempre verifica si una herramienta ya existe antes de intentar una instalación "custom".
7.  **Jerarquía de Instalación**:
    - **Nivel 1**: Fedora/Nobara nativo (DNF).
    - **Nivel 2**: Repositorio oficial del desarrollador (DNF).
    - **Nivel 3**: Flatpak de la distribución.
    - **Nivel 4**: Flathub.
    - **Nivel 5**: COPR, Snap o AppImage (Requiere confirmación).
8.  **Repositorios Oficiales**: Utilizar siempre la fuente original del proyecto.
9.  **Confirmación Obligatoria**: Cualquier instalación que use COPR o métodos externos debe solicitar confirmación vía UI.

## Contexto del Proyecto

- **Objetivo**: Proveer una instalación modular y mantenible para Fedora y Nobara.
- **Arquitectura**: Basada en componentes (repositorios, instalador, gestor de reparación) cargados dinámicamente.
- **Agente Principal**: Antigravity (Google DeepMind).

## Comandos Útiles para Agentes

- `bash -n install.sh`: Verificar sintaxis del script principal.
- `cat config/software.json | jq .`: Validar integridad del archivo de configuración.
