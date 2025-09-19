#!/bin/bash

# ===================================================================================
#   TERMUX DEVELOPMENT ENVIRONMENT SETUP v6.0 - PROFESSIONAL EDITION
# ===================================================================================
#   Script robusto para configurar entornos de desarrollo completos en Android
#   Soporta: Web Development (Next.js, Node.js, Biome), Mobile (Flutter), AI CLIs
#   Autor: Basado en mejores prácticas de termux-packages y comunidad
# ===================================================================================

set -euo pipefail  # Modo strict para mejor manejo de errores
export LANG=C.UTF-8  # Fija locale para evitar problemas

# ===================================================================================
# CONFIGURACIÓN Y VARIABLES GLOBALES
# ===================================================================================

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Directorio de logs
readonly LOG_DIR="$HOME/.termux-dev-setup"
readonly LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"

# URLs y versiones
readonly NODEJS_VERSION="22.19.0"
readonly FLUTTER_VERSION="stable"
readonly CODE_SERVER_VERSION="4.92.2"
readonly BIOME_VERSION="latest"

# ===================================================================================
# FUNCIONES DE UTILIDAD
# ===================================================================================

# Función para logging
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Funciones de output con colores
info() {
    echo -e "\n${CYAN}[INFO]${RESET} $1"
    log "INFO" "$1"
}

success() {
    echo -e "\n${GREEN}[SUCCESS]${RESET} $1"
    log "SUCCESS" "$1"
}

warning() {
    echo -e "\n${YELLOW}[WARNING]${RESET} $1"
    log "WARNING" "$1"
}

error() {
    echo -e "\n${RED}[ERROR]${RESET} $1"
    log "ERROR" "$1"
}

section() {
    echo -e "\n${BLUE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BLUE}${BOLD} $1${RESET}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${RESET}\n"
    log "SECTION" "$1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar espacio en disco
check_disk_space() {
    local required_space=5242880  # 5GB en KB
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')

    if [ "$available_space" -lt "$required_space" ]; then
        error "Espacio insuficiente en disco. Se requieren al menos 5GB libres."
        return 1
    fi
}

# Función para crear backup de configuraciones
create_backup() {
    local backup_dir="$HOME/.termux-dev-setup/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Backup de configuraciones importantes
    [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$backup_dir/"
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$backup_dir/"
    [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$backup_dir/" 2>/dev/null || true

    info "Backup creado en: $backup_dir"
}

# Función para manejo de errores y cleanup
cleanup_on_error() {
    error "Se produjo un error durante la instalación"
    info "Logs disponibles en: $LOG_FILE"
    info "Ejecuta: 'tail -n 50 $LOG_FILE' para ver los últimos errores"
    exit 1
}

# ===================================================================================
# FUNCIONES DE INSTALACIÓN BASE
# ===================================================================================

# Preparación inicial de Termux
setup_termux_basics() {
    section "PREPARACIÓN INICIAL DE TERMUX"

    info "Configurando almacenamiento..."
    termux-setup-storage || true

    info "Actualizando repositorios..."
    termux-change-repo || true

    info "Actualizando paquetes base..."
    pkg update -y && pkg upgrade -y

    info "Instalando dependencias fundamentales..."
    pkg install -y \
        git curl wget unzip \
        build-essential python \
        openssh rsync \
        termux-tools termux-api \
        proot-distro x11-repo \
        termux-x11-nightly virglrenderer-android \
        zsh neofetch htop

    success "Preparación inicial completada"
}

# Configuración de shell mejorado
setup_enhanced_shell() {
    section "CONFIGURACIÓN DE SHELL AVANZADO"

    info "Instalando Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    info "Configurando plugins útiles..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true

    # Configurar .zshrc
    cat > "$HOME/.zshrc" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases útiles para desarrollo
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias dev='cd $HOME/development'
alias ports='netstat -tuln'

# Variables de entorno para desarrollo
export EDITOR=nano
export BROWSER=termux-open
export PAGER=less

# Prompt mejorado
export PS1="%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[green]%}%~%{$reset_color%}$ "

# Path para herramientas de desarrollo
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/development/tools:$PATH"

# Mensaje de bienvenida
echo "🚀 Entorno de desarrollo Termux listo!"
neofetch
EOF

    success "Shell avanzado configurado"
}

# Configuración del entorno gráfico X11
setup_x11_environment() {
    section "CONFIGURACIÓN DEL ENTORNO GRÁFICO X11"

    info "Descargando Termux:X11 APK..."
    local x11_apk_url="https://github.com/termux/termux-x11/releases/latest/download/app-arm64-v8a-debug.apk"
    local apk_file="$HOME/termux-x11.apk"

    if curl -L -o "$apk_file" "$x11_apk_url"; then
        success "APK descargado: $apk_file"
        info "Por favor, instala manualmente el APK desde el administrador de archivos"
        termux-open "$apk_file" || true

        read -p "Presiona Enter cuando hayas instalado la aplicación Termux:X11..."
    else
        warning "No se pudo descargar el APK. Instálalo manualmente desde F-Droid."
    fi

    info "Configurando scripts de inicio X11..."
    mkdir -p "$HOME/development/tools"

    # Script mejorado de inicio de X11
    cat > "$PREFIX/bin/startx11" << 'EOF'
#!/bin/bash
# Script profesional para iniciar entorno X11

set -e

# Cleanup de procesos previos
cleanup() {
    pkill -9 -f "proot-distro" 2>/dev/null || true
    pkill -9 -f "virgl_test_server_android" 2>/dev/null || true
    pkill -9 -f "termux-x11" 2>/dev/null || true
    rm -f $TMPDIR/.X11-unix/X* 2>/dev/null || true
}

echo "🧹 Limpiando procesos previos..."
cleanup

echo "🎮 Iniciando servidor GPU (VirGL)..."
virgl_test_server_android &
sleep 3

echo "🖥️  Iniciando Termux:X11..."
termux-x11 :0 &
sleep 2

echo "📱 Abre la aplicación Termux:X11 para ver el escritorio"
echo "🛑 Presiona Ctrl+C para detener el servidor"

# Esperar señal de interrupción
trap cleanup EXIT
wait
EOF

    chmod +x "$PREFIX/bin/startx11"
    success "Entorno X11 configurado. Usa 'startx11' para iniciarlo"
}

# ===================================================================================
# FUNCIONES DE INSTALACIÓN DE ENTORNOS ESPECÍFICOS
# ===================================================================================

# Instalación de entorno Web Development
install_web_development() {
    section "INSTALACIÓN DEL ENTORNO WEB DEVELOPMENT"

    info "Instalando Node.js ${NODEJS_VERSION}..."
    # Usar el método oficial de Termux
    pkg install -y nodejs npm

    info "Configurando npm globalmente..."
    npm config set prefix "$HOME/.npm-global"
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.zshrc"
    export PATH="$HOME/.npm-global/bin:$PATH"

    info "Instalando herramientas esenciales de desarrollo web..."
    npm install -g \
        @biomejs/biome \
        next \
        create-next-app \
        typescript \
        @types/node \
        eslint \
        prettier \
        nodemon \
        pm2 \
        serve \
        http-server \
        live-server

    info "Instalando pnpm y yarn..."
    npm install -g pnpm yarn

    info "Creando estructura de proyectos..."
    mkdir -p "$HOME/development/web"
    mkdir -p "$HOME/development/web/templates"

    # Crear template básico de Next.js
    cd "$HOME/development/web/templates"
    if [ ! -d "nextjs-template" ]; then
        npx create-next-app@latest nextjs-template --typescript --tailwind --eslint --app --no-src-dir --import-alias="@/*"
    fi

    success "Entorno Web Development instalado"
    info "Directorio de proyectos: ~/development/web"
    info "Template Next.js disponible en: ~/development/web/templates/nextjs-template"
}

# Instalación de entorno Mobile Development (Flutter)
install_mobile_development() {
    section "INSTALACIÓN DEL ENTORNO MOBILE DEVELOPMENT (FLUTTER)"

    info "Configurando prerequisitos para Flutter..."
    pkg install -y openjdk-17 gradle cmake ninja

    info "Descargando Flutter SDK..."
    local flutter_dir="$HOME/development/flutter"
    if [ ! -d "$flutter_dir" ]; then
        git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" "$flutter_dir"
    fi

    info "Configurando variables de entorno para Flutter..."
    cat >> "$HOME/.zshrc" << EOF

# Flutter Configuration
export FLUTTER_ROOT="$flutter_dir"
export PATH="\$FLUTTER_ROOT/bin:\$PATH"
export ANDROID_HOME="\$HOME/development/android-sdk"
export PATH="\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools:\$PATH"
export JAVA_HOME="$PREFIX/opt/openjdk"
EOF

    source "$HOME/.zshrc"

    info "Ejecutando flutter doctor..."
    "$flutter_dir/bin/flutter" doctor || true

    info "Creando estructura de proyectos móviles..."
    mkdir -p "$HOME/development/mobile"
    mkdir -p "$HOME/development/mobile/templates"

    # Crear template básico de Flutter
    cd "$HOME/development/mobile/templates"
    if [ ! -d "flutter-template" ]; then
        "$flutter_dir/bin/flutter" create flutter-template
    fi

    success "Entorno Mobile Development instalado"
    info "Directorio de proyectos: ~/development/mobile"
    info "Ejecuta 'flutter doctor' para verificar la configuración"
}

# Instalación de VS Code y Code Server
install_vscode_environment() {
    section "INSTALACIÓN DE VS CODE Y CODE SERVER"

    info "Instalando Code Server ${CODE_SERVER_VERSION}..."
    local code_server_dir="$HOME/.local/code-server"
    mkdir -p "$code_server_dir"

    # Detectar arquitectura
    local arch
    case "$(uname -m)" in
        aarch64) arch="arm64" ;;
        armv7l) arch="armv7l" ;;
        x86_64) arch="amd64" ;;
        *) error "Arquitectura no soportada: $(uname -m)"; return 1 ;;
    esac

    local download_url="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-${arch}.tar.gz"

    info "Descargando Code Server para arquitectura: $arch"
    cd "$HOME/.local"
    curl -L "$download_url" | tar xz
    mv "code-server-${CODE_SERVER_VERSION}-linux-${arch}" code-server

    info "Configurando Code Server..."
    mkdir -p "$HOME/.config/code-server"
    cat > "$HOME/.config/code-server/config.yaml" << EOF
bind-addr: 127.0.0.1:8080
auth: password
password: $(openssl rand -base64 32)
cert: false
EOF

    info "Creando scripts de inicio..."
    cat > "$PREFIX/bin/code-server-start" << 'EOF'
#!/bin/bash
echo "🚀 Iniciando Code Server..."
echo "📡 URL: http://localhost:8080"
echo "🔑 Password en: ~/.config/code-server/config.yaml"
echo "🛑 Presiona Ctrl+C para detener"

cd "$HOME/development"
"$HOME/.local/code-server/bin/code-server" "$@"
EOF

    chmod +x "$PREFIX/bin/code-server-start"

    # Instalar extensiones esenciales
    info "Instalando extensiones de VS Code..."
    local extensions=(
        "ms-python.python"
        "bradlc.vscode-tailwindcss"
        "esbenp.prettier-vscode"
        "biomejs.biome"
        "dart-code.flutter"
        "ms-vscode.vscode-typescript-next"
        "github.copilot"
        "ms-vscode.vscode-json"
        "redhat.vscode-yaml"
    )

    for ext in "${extensions[@]}"; do
        "$HOME/.local/code-server/bin/code-server" --install-extension "$ext" || true
    done

    success "VS Code Server instalado"
    info "Inicia con: code-server-start"
    info "Accede en: http://localhost:8080"
}

# ===================================================================================
# INSTALACIÓN DE ASISTENTES DE IA
# ===================================================================================

install_ai_assistants() {
    section "INSTALACIÓN DE ASISTENTES DE IA"

    local install_codex=false
    local install_qwen=false
    local install_gemini=false

    echo "¿Qué asistentes de IA deseas instalar?"
    echo "1) Codex CLI (GitHub Copilot CLI)"
    echo "2) Qwen Code CLI"
    echo "3) Gemini CLI (Google)"
    echo "4) Todos"
    echo "5) Ninguno"

    read -p "Selecciona una opción (1-5): " ai_choice

    case $ai_choice in
        1) install_codex=true ;;
        2) install_qwen=true ;;
        3) install_gemini=true ;;
        4) install_codex=true; install_qwen=true; install_gemini=true ;;
        5) info "Saltando instalación de asistentes IA"; return 0 ;;
        *) warning "Opción inválida, saltando asistentes IA"; return 0 ;;
    esac

    # GitHub Copilot CLI
    if [ "$install_codex" = true ]; then
        info "Instalando GitHub Copilot CLI..."
        npm install -g @githubnext/github-copilot-cli
        success "GitHub Copilot CLI instalado. Usa: github-copilot-cli"
    fi

    # Qwen Code CLI (simulado - adaptable según disponibilidad)
    if [ "$install_qwen" = true ]; then
        info "Configurando Qwen Code CLI..."
        mkdir -p "$HOME/.local/bin"
        cat > "$HOME/.local/bin/qwen-code" << 'EOF'
#!/bin/bash
echo "🤖 Qwen Code CLI"
echo "Esta es una implementación de ejemplo."
echo "Configura tu API key en ~/.config/qwen/config"
echo "Uso: qwen-code <consulta>"
EOF
        chmod +x "$HOME/.local/bin/qwen-code"
        success "Qwen Code CLI configurado (template)"
    fi

    # Gemini CLI
    if [ "$install_gemini" = true ]; then
        info "Instalando dependencias para Gemini CLI..."
        pip install google-generativeai

        cat > "$HOME/.local/bin/gemini-cli" << 'EOF'
#!/usr/bin/env python3
import os
import sys
import google.generativeai as genai

def main():
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("❌ Error: Define GEMINI_API_KEY en tu entorno")
        sys.exit(1)

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-pro')

    if len(sys.argv) < 2:
        print("Uso: gemini-cli <consulta>")
        sys.exit(1)

    query = ' '.join(sys.argv[1:])
    response = model.generate_content(query)
    print(response.text)

if __name__ == "__main__":
    main()
EOF
        chmod +x "$HOME/.local/bin/gemini-cli"

        info "Configura tu API key: export GEMINI_API_KEY='tu-key'"
        success "Gemini CLI instalado"
    fi
}

# ===================================================================================
# CONFIGURACIÓN DE UBUNTU EN PROOT
# ===================================================================================

setup_ubuntu_proot() {
    section "CONFIGURACIÓN DE UBUNTU EN PROOT-DISTRO"

    info "Instalando Ubuntu 24.04 LTS..."
    proot-distro install ubuntu

    info "Configurando Ubuntu para desarrollo..."
    cat > "$HOME/ubuntu-setup-dev.sh" << 'EOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "🔄 Actualizando paquetes..."
apt update && apt upgrade -y

echo "🖥️ Instalando entorno de escritorio XFCE4..."
apt install -y \
    sudo nano curl wget git \
    xfce4 xfce4-goodies \
    dbus-x11 mesa-utils-extra \
    libegl1-mesa libgl1-mesa-dri libgles2-mesa \
    firefox-esr \
    thunar-archive-plugin \
    zsh

echo "🐚 Configurando Oh My Zsh en Ubuntu..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh) root

echo "📝 Instalando editores y herramientas..."
apt install -y \
    neovim \
    tree \
    htop \
    neofetch \
    zip unzip \
    build-essential

echo "✅ Ubuntu configurado para desarrollo"
EOF

    info "Ejecutando configuración en Ubuntu..."
    proot-distro login ubuntu -- bash "$HOME/ubuntu-setup-dev.sh"

    # Script mejorado de inicio de Ubuntu
    cat > "$PREFIX/bin/startubuntu" << 'EOF'
#!/bin/bash
# Script profesional para Ubuntu en proot

set -e

cleanup() {
    echo "🧹 Limpiando procesos..."
    pkill -9 -f "proot-distro" 2>/dev/null || true
    pkill -9 -f "virgl_test_server_android" 2>/dev/null || true
    pkill -9 -f "termux-x11" 2>/dev/null || true
    rm -f $TMPDIR/.X11-unix/X* 2>/dev/null || true
}

echo "🧹 Preparando entorno..."
cleanup
sleep 2

echo "🎮 Iniciando servidor GPU..."
virgl_test_server_android &
sleep 3

echo "🖥️ Iniciando escritorio XFCE4 en Ubuntu..."
proot-distro login ubuntu --shared-tmp -- \
    /bin/bash -c 'export DISPLAY=:0 PULSE_SERVER=127.0.0.1; dbus-launch --exit-with-session startxfce4' &

echo "📱 Iniciando cliente X11..."
echo "🔥 Abre la app Termux:X11 para ver Ubuntu"
termux-x11 :0

cleanup
echo "✅ Sesión Ubuntu finalizada"
EOF

    chmod +x "$PREFIX/bin/startubuntu"
    success "Ubuntu en proot configurado. Usa 'startubuntu' para iniciarlo"
}

# ===================================================================================
# MENÚ PRINCIPAL INTERACTIVO
# ===================================================================================

show_main_menu() {
    clear
    echo -e "${BLUE}${BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                   TERMUX DEVELOPMENT ENVIRONMENT SETUP v6.0                 ║
║                              PROFESSIONAL EDITION                           ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"

    echo "Selecciona los entornos de desarrollo que deseas instalar:"
    echo
    echo "  ${GREEN}1)${RESET} Configuración Base (Termux + Shell + X11)"
    echo "  ${GREEN}2)${RESET} Entorno Web Development (Node.js, Next.js, Biome)"
    echo "  ${GREEN}3)${RESET} Entorno Mobile Development (Flutter)"
    echo "  ${GREEN}4)${RESET} VS Code Server + Extensiones"
    echo "  ${GREEN}5)${RESET} Asistentes de IA (Copilot, Qwen, Gemini)"
    echo "  ${GREEN}6)${RESET} Ubuntu Desktop en Proot"
    echo "  ${GREEN}7)${RESET} Instalación Completa (Todo)"
    echo "  ${GREEN}8)${RESET} Configuración Personalizada"
    echo "  ${RED}0)${RESET} Salir"
    echo
}

process_selection() {
    local choice="$1"

    case $choice in
        1)
            setup_termux_basics
            setup_enhanced_shell
            setup_x11_environment
            ;;
        2)
            install_web_development
            ;;
        3)
            install_mobile_development
            ;;
        4)
            install_vscode_environment
            ;;
        5)
            install_ai_assistants
            ;;
        6)
            setup_ubuntu_proot
            ;;
        7)
            setup_termux_basics
            setup_enhanced_shell
            setup_x11_environment
            install_web_development
            install_mobile_development
            install_vscode_environment
            install_ai_assistants
            setup_ubuntu_proot
            ;;
        8)
            custom_installation
            ;;
        0)
            info "Saliendo del instalador..."
            exit 0
            ;;
        *)
            error "Opción inválida: $choice"
            return 1
            ;;
    esac
}

custom_installation() {
    section "CONFIGURACIÓN PERSONALIZADA"

    echo "Selecciona los componentes que deseas instalar:"

    local components=()

    read -p "¿Instalar configuración base? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && components+=("base")

    read -p "¿Instalar entorno web? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && components+=("web")

    read -p "¿Instalar entorno móvil? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && components+=("mobile")

    read -p "¿Instalar VS Code Server? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && components+=("vscode")

    read -p "¿Instalar asistentes IA? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && components+=("ai")

    read -p "¿Instalar Ubuntu en proot? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && components+=("ubuntu")

    info "Instalando componentes seleccionados..."

    for component in "${components[@]}"; do
        case $component in
            "base")
                setup_termux_basics
                setup_enhanced_shell
                setup_x11_environment
                ;;
            "web") install_web_development ;;
            "mobile") install_mobile_development ;;
            "vscode") install_vscode_environment ;;
            "ai") install_ai_assistants ;;
            "ubuntu") setup_ubuntu_proot ;;
        esac
    done
}

# ===================================================================================
# FUNCIÓN PRINCIPAL
# ===================================================================================

main() {
    # Configuración inicial
    mkdir -p "$LOG_DIR"
    trap cleanup_on_error ERR

    # Verificaciones preliminares
    if [ "$(uname -o)" != "Android" ]; then
        error "Este script está diseñado para ejecutarse en Termux (Android)"
        exit 1
    fi

    info "Iniciando Termux Development Environment Setup v6.0"
    log "STARTUP" "Script iniciado por usuario $(whoami)"

    check_disk_space
    create_backup

    # Menú principal
    while true; do
        show_main_menu
        read -p "Selecciona una opción (0-8): " choice

        if [[ "$choice" =~ ^[0-8]$ ]]; then
            process_selection "$choice"

            if [ "$choice" != "0" ]; then
                echo
                read -p "Presiona Enter para continuar..." -r
            fi
        else
            error "Opción inválida. Por favor selecciona un número del 0 al 8."
            sleep 2
        fi
    done
}

# Función de finalización
finalize_setup() {
    section "FINALIZACIÓN DE LA CONFIGURACIÓN"

    success "¡Instalación completada exitosamente!"

    echo -e "\n${BOLD}Comandos disponibles:${RESET}"
    echo "  • ${GREEN}startx11${RESET}        - Iniciar entorno X11"
    echo "  • ${GREEN}startubuntu${RESET}     - Iniciar Ubuntu desktop"
    echo "  • ${GREEN}code-server-start${RESET} - Iniciar VS Code Server"
    echo "  • ${GREEN}dev${RESET}             - Ir al directorio de desarrollo"

    echo -e "\n${BOLD}Directorios importantes:${RESET}"
    echo "  • ~/development/web     - Proyectos web"
    echo "  • ~/development/mobile  - Proyectos móviles"
    echo "  • ~/development/tools   - Herramientas personalizadas"

    echo -e "\n${BOLD}Archivos de configuración:${RESET}"
    echo "  • ~/.zshrc             - Configuración del shell"
    echo "  • $LOG_FILE - Log de instalación"

    info "Reinicia Termux para aplicar todos los cambios"
    info "Documentación completa en: ~/development/README.md"
}

# Crear documentación
create_documentation() {
    mkdir -p "$HOME/development"
    cat > "$HOME/development/README.md" << 'EOF'
# Termux Development Environment

## Entornos Instalados

### Web Development
- Node.js + npm/yarn/pnpm
- Next.js + TypeScript
- Biome (linting/formatting)
- Herramientas de desarrollo

### Mobile Development
- Flutter SDK
- Android development tools
- Dart SDK

### Herramientas de Código
- VS Code Server (puerto 8080)
- Extensiones esenciales instaladas

### Asistentes IA
- GitHub Copilot CLI
- Gemini CLI
- Qwen Code CLI

## Comandos Útiles

```bash
# Iniciar entorno gráfico
startx11

# Iniciar Ubuntu desktop
startubuntu

# Iniciar VS Code Server
code-server-start

# Ir al directorio de desarrollo
dev
```

## Estructura de Directorios

```
~/development/
├── web/          # Proyectos web
├── mobile/       # Proyectos móviles
├── tools/        # Herramientas personalizadas
└── templates/    # Templates de proyecto
```

## Configuración Adicional

Revisa y personaliza:
- ~/.zshrc (configuración del shell)
- ~/.config/code-server/config.yaml (VS Code Server)

## Troubleshooting

Logs disponibles en: ~/.termux-dev-setup/
EOF
}

# ===================================================================================
# PUNTO DE ENTRADA
# ===================================================================================

# Verificar argumentos de línea de comandos
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Termux Development Environment Setup v6.0"
    echo "Uso: $0 [opción]"
    echo "Opciones:"
    echo "  --help, -h    Mostrar esta ayuda"
    echo "  --version, -v Mostrar versión"
    echo "  --auto        Instalación automática completa"
    exit 0
fi

if [ "${1:-}" = "--version" ] || [ "${1:-}" = "-v" ]; then
    echo "Termux Development Environment Setup v6.0"
    exit 0
fi

if [ "${1:-}" = "--auto" ]; then
    info "Modo automático: Instalación completa"
    setup_termux_basics
    setup_enhanced_shell
    setup_x11_environment
    install_web_development
    install_mobile_development
    install_vscode_environment
    setup_ubuntu_proot
    create_documentation
    finalize_setup
    exit 0
fi

# Ejecutar función principal
main "$@"
create_documentation
finalize_setup
EOF