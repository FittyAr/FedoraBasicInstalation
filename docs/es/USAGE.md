# Guía de Uso 📖

## Navegación Básica
El instalador utiliza `whiptail` para la interfaz.
- **Flechas Arriba/Abajo**: Navegar por las opciones.
- **Espacio**: Marcar o desmarcar aplicaciones en las listas.
- **Enter**: Confirmar selección o entrar en una categoría.
- **Tab**: Cambiar entre las opciones del menú y los botones de acción.

## Secciones del Menú

### 1. Categorías de Software
Aquí encontrarás todas las aplicaciones disponibles divididas por funcionalidad (Desarrollo, Gaming, Internet, etc.). Al entrar en una categoría:
- Las aplicaciones ya instaladas aparecerán marcadas con `[INSTALADA]`.
- Puedes seleccionar las que desees instalar.
- Al confirmar, volverás al menú principal y verás el contador de aplicaciones seleccionadas actualizado.

### 2. Gestión de Presets
- **💾 GUARDAR PRESET**: Guarda tu selección actual en un archivo JSON. Se te pedirá un nombre. Si el nombre ya existe, el script preguntará si deseas sobreescribirlo.
- **📂 CARGAR PRESET**: Carga una configuración guardada previamente. El script verificará si las aplicaciones del preset existen en la versión actual del instalador.

### 3. Acciones del Sistema
- **🔧 REPARACIONES**: Abre un menú con herramientas para reparar aplicaciones instaladas o realizar mantenimiento general.
- **🚀 INICIAR PROCESO**: Comienza la instalación secuencial de todas las aplicaciones seleccionadas.
- **❌ Salir**: Cierra el instalador.

## Inicio Automático de Presets
Si el script detecta archivos en la carpeta `presets/` al iniciar, te preguntará automáticamente si deseas cargar uno antes de mostrar el menú principal.
