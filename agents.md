# Agentic Configuration - FedoraBasicInstalation

Este archivo define las reglas y el contexto para que los agentes de IA (como Antigravity, Cursor, etc) operen dentro de este repositorio de forma segura y consistente.

## Reglas de Comportamiento

1.  **Modularidad Primero**: No agregues lógica pesada directamente en `install.sh`. Usa la estructura de librerías en `setup_scripts/lib/`.
2.  **Configuración via JSON**: Todas las aplicaciones deben estar definidas en `config/software.json`. Si una app requiere un repositorio especial, agrégalo a `repos.sh`.
3.  **No Placeholders**: Al proponer cambios, asegúrate de que los IDs de Flatpak y los nombres de paquetes DNF sean correctos y verificados.
4.  **Logging Estándar**: Usa las funciones `log_info`, `log_warn`, `log_success` y `log_error` para mantener al usuario informado.
5.  **Seguridad de Sudo**: El script está diseñado para ejecutarse sin privilegios de root inicialmente y pedir sudo solo cuando sea necesario. No asumas persistencia de sudo.
6.  **Validación de Instalación**: Siempre verifica si una herramienta ya existe antes de intentar una instalación "custom".
7.  **Prioridad DNF**: Siempre da prioridad a la instalación vía DNF sobre Flatpak.
8.  **Repositorios Oficiales**: Busca y utiliza los repositorios oficiales de cada proyecto navegando a sus páginas de documentación.
9.  **Confirmación de COPR**: Para aplicaciones que requieran el uso de repositorios COPR, el script debe pedir confirmación explícita al usuario antes de proceder.

## Contexto del Proyecto

- **Objetivo**: Proveer una instalación modular y mantenible para Fedora y Nobara.
- **Arquitectura**: Basada en componentes (repositorios, instalador, gestor de reparación) cargados dinámicamente.
- **Agente Principal**: Antigravity (Google DeepMind).

## Comandos Útiles para Agentes

- `bash -n install.sh`: Verificar sintaxis del script principal.
- `cat config/software.json | jq .`: Validar integridad del archivo de configuración.
