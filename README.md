# Fedora Advanced Modular Installer 🚀

Un instalador modular y extensible para Fedora y Nobara, diseñado para facilitar la configuración inicial del sistema mediante una interfaz CLI intuitiva y presets personalizables.

[English Version Below]

## 🌟 Características

- **Modularidad Total**: Aplicaciones categorizadas y cargadas dinámicamente desde archivos JSON.
- **Detección Inteligente**: Identifica aplicaciones ya instaladas en el sistema.
- **Sistema de Presets**: Guarda y carga tus configuraciones favoritas. Ahora con versionado y control de compatibilidad.
- **Multi-idioma**: Soporte completo para Español e Inglés.
- **Herramientas de Reparación**: Menú integrado para mantenimiento rápido del sistema.
- **Optimización Automática**: Configura DNF para descargas más rápidas al iniciar.

## 🚀 Inicio Rápido

```bash
git clone https://github.com/FittyAr/FedoraBasicInstalation.git
cd FedoraBasicInstalation
chmod +x install.sh
./install.sh
```

## 📚 Documentación / Documentation

### Español 🇪🇸
- [Guía de Uso](docs/es/USAGE.md)
- [Instalación y Requisitos](docs/es/INSTALL.md)
- [Cómo Contribuir](docs/es/CONTRIBUTING.md)

### English 🇺🇸
- [Usage Guide](docs/en/USAGE.md)
- [Installation and Prerequisites](docs/en/INSTALL.md)
- [Contributing Guide](docs/en/CONTRIBUTING.md)

---

## 🛠 Estructura del Proyecto

- `install.sh`: Script principal de entrada.
- `config/`: Archivos JSON con la configuración de aplicaciones y herramientas.
- `setup_scripts/lib/`: Librerías core (instalador, presets, utilidades).
- `setup_scripts/locales/`: Archivos de traducción.
- `presets/`: Tus configuraciones guardadas.

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si deseas añadir una aplicación, mejorar la interfaz o reportar un error, consulta nuestra [Guía de Contribución](docs/es/CONTRIBUTING.md).

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

---

# English Description

A modular and extensible installer for Fedora and Nobara, designed to simplify initial system setup via an intuitive CLI interface and customizable presets.

## 🌟 Features

- **Full Modularity**: Apps categorized and dynamically loaded from JSON files.
- **Smart Detection**: Identifies apps already installed on the system.
- **Preset System**: Save and load your favorite configurations. Now with versioning and compatibility checks.
- **Multi-language**: Full support for Spanish and English.
- **Repair Tools**: Integrated menu for quick system maintenance.
- **Auto Optimization**: Configures DNF for faster downloads on startup.
