#!/bin/bash

# UI Strings - Espanol
export STR_OPTIMIZING_DNF="[!] Optimizando DNF..."
export STR_ANALYZING_SYSTEM="[*] Analizando sistema..."
export STR_SELECTION_HINT="ESPACIO: marcar/desmarcar | ENTER: confirmar"
export STR_REPAIRS_TITLE="REPARACIONES"
export STR_REPAIRS_MENU="Seleccione una tarea de mantenimiento:"
export STR_REPAIR_APP="Reparar"
export STR_MAIN_MENU_TITLE="FEDORA MODULAR INSTALLER"
export STR_SELECTED_COUNT="Seleccionados: "
export STR_MENU_REPAIR="REPARACIONES Y MANTENIMIENTO"
export STR_MENU_INSTALL="INICIAR PROCESO DE INSTALACION"
export STR_MENU_EXIT="Salir"

export STR_PROCESS_COMPLETED="Proceso completado."
export STR_MISSING_DEPS="Instalando dependencias: "
export STR_INSTALLING_APP="Instalando: "
export STR_INSTALLED_VIA_DNF="instalado via DNF."
export STR_INSTALLED_VIA_FLATPAK="instalado via Flatpak."
export STR_INSTALL_FAILED="Error en la instalacion."
export STR_EXECUTING_REPAIR="Ejecutando: "
export STR_REPAIR_SUCCESS="Reparacion finalizada."
export STR_REPAIR_FAILED="Fallo en la reparacion."
export STR_REPAIR_NOT_FOUND="No hay comando para "
export STR_INSTALLED_TAG="[INSTALADA]"
export STR_SELECT_LANG="Seleccione el Idioma"
export STR_MENU_SAVE_PRESET="GUARDAR CONFIGURACION (PRESET)"
export STR_MENU_LOAD_PRESET="CARGAR CONFIGURACION (PRESET)"

export STR_ENTER_PRESET_NAME="Nombre del archivo (sin .json):"
export STR_PRESET_SAVED="Preset guardado en: "
export STR_SELECT_PRESET="Seleccione un preset:"
export STR_SUMMARY_LOG_CREATED="Resumen: "
export STR_HELP_TITLE="Ayuda"
export STR_HELP_TEXT="Uso: ./install.sh [OPCIONES]\n\nOpciones:\n  -l, --lang CODE       Idioma (es, en)\n  -p, --preset FILE     Cargar preset JSON\n  -d, --preset-dir DIR  Directorio de presets\n  -g, --debug           Modo debug\n  -h, --help            Ayuda"
export STR_OK="Seleccionar"
export STR_CANCEL="Volver"
export STR_CONTINUE="Continuar"
export STR_ACCEPT="Aceptar"
export STR_OVERWRITE_CONFIRM="Desea sobreescribir el archivo?"
export STR_STARTUP_LOAD_PRESET="Desea cargar un preset existente?"
export STR_INCOMPATIBLE_PRESET="Aviso: Preset incompatible o incompleto."
export STR_APPS_NOT_FOUND="No encontradas:"
export STR_MENU_SECTION_SOFTWARE="--- CATEGORIAS DE SOFTWARE ---"

export STR_COPR_CONFIRM_TITLE="Repositorio de Terceros (COPR)"
export STR_COPR_CONFIRM_MSG="Se requiere habilitar el repositorio COPR '%s'. ¿Desea proceder?"

export STR_BTRFS_EXPLANATION="Se ha detectado Btrfs. El script creara un snapshot (respaldo instantaneo) de tu sistema para que puedas restaurarlo facilmente en caso de error durante la instalacion."
export STR_BTRFS_FAIL_TITLE="Fallo de Snapshot"
export STR_BTRFS_FAIL_MSG="No se pudo crear el snapshot de seguridad. ¿Deseas continuar la instalacion SIN respaldo o prefieres abortar para investigar la causa?"
export STR_BTRFS_ABORTED="Instalacion abortada por seguridad."

# Snapshot Snapper
export STR_SNAPPER_DETECTED="[*] Snapper detectado (config: %s). Generando snapshot 'pre'..."
export STR_SNAPPER_PRE_SUCCESS="[+] Snapshot pre-instalación creado (ID: %s)"
export STR_SNAPPER_POST_START="[*] Cerrando snapshot de Snapper..."
export STR_SNAPPER_POST_SUCCESS="[+] Snapshot post-instalación creado."
export STR_BTRFS_DIRECT_START="[*] Generando snapshot de seguridad (btrfs directo)..."

# Nuevas cadenas para i18n total
export STR_LOG_SESSION_START="--- Iniciando Sesion: %s ---"
export STR_VERIFYING_REPOS="[*] Verificando integridad de repositorios..."
export STR_SYNC_REPOS="[*] Sincronizando repositorios y aceptando llaves GPG..."
export STR_ERR_DB_BUILD="[!] Fallo critico al construir la base de datos de aplicaciones."
export STR_APP_STATE_INIT="[*] Estado de aplicaciones inicializado."
export STR_MAIN_LOOP_START="[*] Entrando en el bucle principal..."
export STR_ERR_EMPTY_MENU="[!] El menu de software esta vacio. Verifica los archivos en config/apps/"
export STR_ERR_ODD_MENU="[!] Error interno: menu_args tiene un numero impar de elementos"
export STR_WHIPTAIL_ESC="[!] Whiptail interrumpido (ESC)"
export STR_WHIPTAIL_NO_SEL="[!] Whiptail no retorno ninguna seleccion."
export STR_ALREADY_INSTALLED="%s ya esta instalado. Omitiendo..."

# Repositorios
export STR_ADDING_REPO="[*] Añadiendo repositorio de %s..."
export STR_ADDING_RPM_FUSION="[*] Añadiendo repositorios RPM Fusion (Free & Non-Free)..."
export STR_ERR_RPM_FUSION="[!] Error al instalar RPM Fusion."

# Instaladores Especificos
export STR_INSTALL_DOCKER_GNOME="[*] Instalando Docker Desktop (Requiere GNOME)..."
export STR_INSTALL_GNOME_DEPS="[*] Instalando componentes de GNOME y dependencias..."
export STR_CONFIG_DOCKER_REPO="[*] Configurando repositorio de Docker..."
export STR_DOWNLOAD_DOCKER_RPM="[*] Descargando Docker Desktop RPM..."
export STR_ERR_DOCKER_DOWNLOAD="[!] No se pudo descargar el RPM de Docker Desktop."
export STR_DOCKER_SUCCESS="[+] Docker Desktop instalado correctamente."
export STR_DOCKER_LOGOUT="[!] Debes cerrar sesion e iniciar sesion en GNOME para usar Docker Desktop."

export STR_INSTALL_TAILSCALE="[*] Instalando y configurando Tailscale..."
export STR_TAILSCALE_READY="[+] Tailscale listo. Ejecuta 'sudo tailscale up' para iniciar sesion."

export STR_INSTALL_WAYDROID="[*] Instalando y preparando Waydroid..."
export STR_WAYDROID_INIT="[!] Waydroid instalado. Requiere inicializacion manual: 'sudo waydroid init'."

export STR_INSTALL_PHOTOGIMP="[*] Instalando parche PhotoGIMP para GIMP Flatpak..."
export STR_INSTALL_GIMP_FIRST="[*] Instalando GIMP via Flatpak primero..."
export STR_DOWNLOAD_PHOTOGIMP="[*] Descargando PhotoGIMP..."
export STR_PHOTOGIMP_SUCCESS="[+] PhotoGIMP aplicado correctamente."

export STR_INSTALL_OLLAMA="[*] Instalando Ollama..."
export STR_GPU_NVIDIA_DETECTED="[*] GPU NVIDIA detectada. Ollama utilizara aceleracion CUDA."
export STR_GPU_AMD_DETECTED="[*] GPU AMD detectada. Asegurate de tener ROCm instalado para aceleracion."
export STR_GPU_AMD_ROCM_WARN="[!] Ollama soporta AMD via ROCm v6+. Consultar docs.ollama.com si hay problemas."
export STR_GPU_NOT_FOUND="[!] No se detecto GPU dedicada compatible. Ollama se ejecutara en modo CPU."

export STR_INSTALL_DOTNET_FULL="[*] Instalando .NET 10 SDK completo..."
export STR_INSTALL_DOTNET_WORKLOADS="[*] Instalando workloads de .NET (android, wasm)..."
export STR_ERR_DOTNET_WORKLOADS="[!] No se pudieron instalar algunos workloads."

export STR_PREPARING_CURSOR="[*] Preparando Cursor AI..."
export STR_CURSOR_READY="[+] Cursor AI listo (instalado via DNF)."

export STR_INSTALL_ZED="[*] Instalando Zed Editor via script oficial..."
export STR_INSTALL_CODECS="[*] Instalando codecs multimedia completos..."
export STR_CONFIG_ANTIGRAVITY="[*] Configurando entorno para Antigravity Agent..."
export STR_ERR_AG_MD_NOT_FOUND="[!] Archivo agents.md no encontrado. Asegurate de que exista en la raiz."
export STR_AG_READY="[+] Antigravity Agent listo para operar."

export STR_INSTALL_RUSTDESK="[*] Instalando RustDesk via Flatpak (Ambito de Usuario)..."
export STR_SEARCH_RUSTDESK_GH="[*] Buscando ultima version de RustDesk en GitHub..."
export STR_DOWNLOAD_RUSTDESK_FLATPAK="[*] Descargando RustDesk Flatpak..."
export STR_INSTALL_FLATPAK_FILE="[*] Instalando archivo .flatpak..."
export STR_ERR_RUSTDESK_GH="[!] No se pudo encontrar el archivo .flatpak en GitHub. Intentando instalacion directa..."
export STR_RUSTDESK_SUCCESS="[+] RustDesk configurado correctamente."

export STR_INSTALL_LAZYDOCKER="[*] Instalando LazyDocker mediante script oficial..."
export STR_INSTALL_DNF_PKG="[*] Instalando %s via DNF..."

# Bloqueos de DNF
export STR_DNF_LOCKED_TITLE="DNF Ocupado / Bloqueado"
export STR_DNF_LOCKED_MSG="Se ha detectado que otro proceso esta usando DNF (posiblemente una actualizacion automatica).\n\n¿Deseas esperar a que termine o prefieres abortar la instalacion para evitar conflictos?"
export STR_WAIT="Esperar"
export STR_ABORT="Abortar"
export STR_DNF_WAITING="[*] Esperando a que DNF se libere..."
export STR_DNF_ABORTED="[!] Instalacion abortada para evitar conflictos de DNF."

# Presets y Logs de sistema
export STR_ERR_NO_APPS_SELECTED="[!] No hay aplicaciones seleccionadas. Guardando preset vacio."
export STR_LOG_PRESET_SAVED="Preset guardado: %s (Version: %s)"
export STR_ERR_PRESET_NOT_FOUND="[!] Archivo de preset no encontrado: %s"
export STR_WARN_PRESET_VERSION="[!] Aviso: Version de preset no coincide (%s vs %s)"
export STR_LOG_PRESET_LOADED="Preset cargado: %s (%d apps)"
export STR_ERR_NO_PRESETS="No se encontraron presets en %s"

# Logs de instalacion
export STR_LOG_SUCCESS="[+] EXITO: %s instalado via %s"
export STR_LOG_FAILED="[-] FALLO: %s no pudo ser instalado"
export STR_LOG_TRYING="[*] Probando metodo: %s para %s"
export STR_LOG_INSTALL_START="[*] Iniciando instalacion de %s"
export STR_LOG_INSTALL_LOG_HEADER="--- Log de Instalacion para %s ---"

# Parser
export STR_ERR_MASTER_JSON="[!] Error construyendo el JSON maestro. Revisa /tmp/jq_err.log"
