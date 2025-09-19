# 🚀 Termux Development Environment Setup v6.0

## Professional Edition - Script de Configuración Completo para Android

Este script profesional configura un entorno de desarrollo completo en Android usando Termux, basado en las mejores prácticas de la comunidad y los repositorios oficiales de Termux.

## ✨ Características Principales

### 🛠️ Entornos de Desarrollo Soportados

- **Web Development**: Node.js, Next.js, TypeScript, Biome, herramientas modernas
- **Mobile Development**: Flutter SDK completo con Android tools
- **VS Code Server**: Entorno de desarrollo web accesible desde navegador
- **Asistentes IA**: GitHub Copilot CLI, Gemini CLI, Qwen Code CLI
- **Ubuntu Desktop**: Entorno gráfico completo en proot-distro

### 🔧 Mejoras Técnicas

- **Manejo robusto de errores** con logging detallado
- **Verificaciones de sistema** (espacio en disco, dependencias)
- **Backup automático** de configuraciones existentes
- **Menú interactivo** para instalación personalizada
- **Scripts optimizados** basados en termux-packages oficiales
- **Arquitectura multiplataforma** (ARM64, ARM, x64)

## 📋 Prerequisitos

- **Android 7.0+** (API 24+)
- **Termux** instalado desde F-Droid
- **5GB+ de espacio libre** en almacenamiento interno
- **Conexión a internet** estable

## 🚀 Instalación Rápida

```bash
# Descargar y ejecutar
curl -fsSL https://raw.githubusercontent.com/tu-usuario/termux-dev-setup/main/setup-dev-env-v6.sh -o setup-dev-env-v6.sh
chmod +x setup-dev-env-v6.sh
./setup-dev-env-v6.sh
```

### Instalación Automática Completa
```bash
./setup-dev-env-v6.sh --auto
```

## 📱 Opciones de Instalación

### 1️⃣ Configuración Base
- Actualización completa de Termux
- Shell avanzado con Oh My Zsh
- Entorno gráfico X11 con aceleración GPU

### 2️⃣ Entorno Web Development
- **Node.js** (última versión LTS)
- **Gestores de paquetes**: npm, yarn, pnpm
- **Frameworks**: Next.js con TypeScript
- **Herramientas**: Biome, ESLint, Prettier
- **Servidores de desarrollo**: live-server, http-server

### 3️⃣ Entorno Mobile Development
- **Flutter SDK** (canal stable)
- **Android SDK** y herramientas
- **OpenJDK 17** configurado
- **Templates** de proyecto Flutter

### 4️⃣ VS Code Server
- **Code Server** optimizado para Android
- **Extensiones esenciales** preinstaladas
- **Configuración automática** de puertos y autenticación
- **Acceso web** en http://localhost:8080

### 5️⃣ Asistentes de IA
- **GitHub Copilot CLI**: Asistente de código con IA
- **Gemini CLI**: Integración con Google Gemini
- **Qwen Code CLI**: Template personalizable

### 6️⃣ Ubuntu Desktop
- **Ubuntu 24.04 LTS** en proot-distro
- **XFCE4** como entorno de escritorio
- **Firefox**, editores, herramientas de desarrollo
- **Integración completa** con X11

## 🎯 Comandos Principales

Una vez instalado, tendrás acceso a estos comandos:

```bash
# Entorno gráfico
startx11          # Iniciar servidor X11
startubuntu       # Iniciar Ubuntu desktop

# Desarrollo
code-server-start # Iniciar VS Code Server
dev               # Ir a directorio de desarrollo

# Asistentes IA
github-copilot-cli # GitHub Copilot
gemini-cli        # Google Gemini
qwen-code         # Qwen Assistant
```

## 📁 Estructura de Directorios

```
~/development/
├── web/
│   ├── templates/
│   │   └── nextjs-template/    # Template Next.js + TypeScript
│   └── projects/               # Tus proyectos web
├── mobile/
│   ├── templates/
│   │   └── flutter-template/   # Template Flutter básico
│   └── projects/               # Tus proyectos móviles
├── tools/                      # Herramientas personalizadas
└── README.md                   # Documentación completa
```

## ⚙️ Configuraciones Importantes

### Variables de Entorno Automáticas
```bash
# Node.js y npm
export PATH="$HOME/.npm-global/bin:$PATH"

# Flutter
export FLUTTER_ROOT="$HOME/development/flutter"
export PATH="$FLUTTER_ROOT/bin:$PATH"

# Android
export ANDROID_HOME="$HOME/development/android-sdk"
export JAVA_HOME="$PREFIX/opt/openjdk"
```

### Archivos de Configuración
- `~/.zshrc` - Configuración del shell
- `~/.config/code-server/config.yaml` - VS Code Server
- `~/.termux-dev-setup/` - Logs y backups

## 🔍 Verificación de Instalación

```bash
# Verificar Node.js
node --version
npm --version

# Verificar Flutter
flutter doctor

# Verificar VS Code Server
code-server-start --version

# Ver logs de instalación
tail -f ~/.termux-dev-setup/setup-*.log
```

## 🐛 Troubleshooting

### Problemas Comunes

**Error de espacio en disco:**
```bash
# Limpiar cache de npm
npm cache clean --force

# Limpiar paquetes no utilizados
pkg autoremove
```

**Problemas con X11:**
```bash
# Reinstalar aplicación Termux:X11
# Verificar permisos de almacenamiento
# Reiniciar Termux completamente
```

**Flutter doctor errores:**
```bash
# Verificar variables de entorno
echo $FLUTTER_ROOT
echo $ANDROID_HOME

# Aceptar licencias de Android
flutter doctor --android-licenses
```

### Logs Detallados

Todos los logs se guardan en `~/.termux-dev-setup/` con timestamp:
```bash
# Ver último log
ls -la ~/.termux-dev-setup/
tail -f ~/.termux-dev-setup/setup-YYYYMMDD-HHMMSS.log
```

## 🔄 Actualizaciones

Para actualizar herramientas instaladas:

```bash
# Actualizar Termux
pkg update && pkg upgrade

# Actualizar Node.js packages
npm update -g

# Actualizar Flutter
flutter upgrade

# Actualizar VS Code Server
# Re-ejecutar la opción 4 del script
```

## 🛡️ Seguridad

- **Backups automáticos** antes de cambios importantes
- **Contraseñas seguras** generadas automáticamente
- **Logs detallados** para auditoría
- **Verificaciones de integridad** de descargas

## 🤝 Contribución

Este script está basado en:
- [Termux Packages](https://github.com/termux/termux-packages)
- Mejores prácticas de la comunidad Android dev
- Scripts oficiales de configuración de herramientas

## 📄 Licencia

MIT License - Libre para usar, modificar y distribuir.

## 🆘 Soporte

Si encuentras problemas:

1. Revisa los logs en `~/.termux-dev-setup/`
2. Verifica que tengas suficiente espacio en disco
3. Asegúrate de tener una conexión estable a internet
4. Reinicia Termux completamente si es necesario

## 🎉 Agradecimientos

Gracias a la comunidad de Termux y los desarrolladores de todas las herramientas integradas en este script.

---

**¡Disfruta programando en Android! 🎉**