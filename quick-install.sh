#!/bin/bash

# ===================================================================================
#   QUICK INSTALLER - VERSIÓN RÁPIDA DEL SETUP
# ===================================================================================
#   Instalación express con configuraciones predeterminadas
# ===================================================================================

set -euo pipefail

# Colores
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly RESET='\033[0m'

info() { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }

echo -e "${CYAN}🚀 TERMUX DEV SETUP - QUICK INSTALLER${RESET}"
echo "════════════════════════════════════════"

# Verificar que estamos en Android
if [ "$(uname -o)" != "Android" ]; then
    echo "❌ Este script debe ejecutarse en Termux (Android)"
    exit 1
fi

info "Configurando almacenamiento..."
termux-setup-storage

info "Actualizando repositorios..."
termux-change-repo
pkg update -y && pkg upgrade -y

info "Instalando paquetes esenciales..."
pkg install -y \
    git curl wget unzip \
    nodejs npm \
    python \
    zsh \
    build-essential \
    termux-tools \
    proot-distro \
    x11-repo \
    termux-x11-nightly

info "Configurando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

info "Instalando herramientas de desarrollo web..."
npm install -g \
    @biomejs/biome \
    next \
    create-next-app \
    typescript \
    nodemon \
    serve

info "Creando estructura de directorios..."
mkdir -p "$HOME/development/web"
mkdir -p "$HOME/development/mobile"
mkdir -p "$HOME/development/tools"

info "Configurando aliases útiles..."
cat >> "$HOME/.zshrc" << 'EOF'

# Development aliases
alias dev='cd $HOME/development'
alias web='cd $HOME/development/web'
alias mobile='cd $HOME/development/mobile'
alias ll='ls -alF'
alias ..='cd ..'

# Environment variables
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nano

echo "🚀 Entorno de desarrollo listo!"
EOF

info "Descargando Termux:X11..."
curl -L -o "$HOME/termux-x11.apk" "https://github.com/termux/termux-x11/releases/latest/download/app-arm64-v8a-debug.apk"

success "¡Instalación rápida completada!"
echo
echo "📋 PASOS SIGUIENTES:"
echo "1. Reinicia Termux"
echo "2. Instala manualmente: $HOME/termux-x11.apk"
echo "3. Ejecuta: dev (para ir al directorio de desarrollo)"
echo
echo "📁 Directorios creados:"
echo "   ~/development/web - Para proyectos web"
echo "   ~/development/mobile - Para proyectos móviles"
echo
echo "🔧 Para instalación completa, ejecuta:"
echo "   ./setup-dev-env-v6.sh"