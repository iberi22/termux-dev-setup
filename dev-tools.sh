#!/bin/bash

# ===================================================================================
#   TERMUX DEV TOOLS - UTILIDADES ADICIONALES
# ===================================================================================
#   Herramientas de mantenimiento y utilidades para el entorno de desarrollo
# ===================================================================================

set -euo pipefail

# Colores
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

info() { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# Función para mostrar estado del sistema
show_system_status() {
    echo -e "${CYAN}🖥️  ESTADO DEL SISTEMA${RESET}"
    echo "════════════════════════"

    # Información básica
    echo "📱 Dispositivo: $(getprop ro.product.model 2>/dev/null || echo 'Desconocido')"
    echo "🐧 Kernel: $(uname -r)"
    echo "💾 Arquitectura: $(uname -m)"

    # Espacio en disco
    echo
    echo "💽 ESPACIO EN DISCO:"
    df -h "$HOME" | tail -1 | awk '{printf "   Usado: %s/%s (%s)\n", $3, $2, $5}'

    # Memoria
    echo
    echo "🧠 MEMORIA:"
    free -h | grep Mem | awk '{printf "   RAM: %s/%s\n", $3, $2}'

    # Procesos de desarrollo activos
    echo
    echo "⚡ PROCESOS ACTIVOS:"
    pgrep -f "code-server" >/dev/null && echo "   ✅ VS Code Server" || echo "   ❌ VS Code Server"
    pgrep -f "node" >/dev/null && echo "   ✅ Node.js processes" || echo "   ❌ Node.js processes"
    pgrep -f "termux-x11" >/dev/null && echo "   ✅ X11 Server" || echo "   ❌ X11 Server"
    pgrep -f "proot-distro" >/dev/null && echo "   ✅ Ubuntu (proot)" || echo "   ❌ Ubuntu (proot)"
}

# Función para limpiar el sistema
cleanup_system() {
    echo -e "${CYAN}🧹 LIMPIEZA DEL SISTEMA${RESET}"
    echo "═══════════════════════"

    info "Limpiando cache de paquetes..."
    pkg autoclean

    info "Limpiando cache de npm..."
    npm cache clean --force 2>/dev/null || true

    info "Limpiando cache de yarn..."
    yarn cache clean 2>/dev/null || true

    info "Limpiando archivos temporales..."
    rm -rf "$TMPDIR"/* 2>/dev/null || true
    rm -rf "$HOME/.cache" 2>/dev/null || true

    info "Limpiando logs antiguos..."
    find "$HOME/.termux-dev-setup" -name "*.log" -mtime +7 -delete 2>/dev/null || true

    success "Limpieza completada"
}

# Función para actualizar herramientas
update_tools() {
    echo -e "${CYAN}🔄 ACTUALIZANDO HERRAMIENTAS${RESET}"
    echo "═══════════════════════════"

    info "Actualizando paquetes de Termux..."
    pkg update && pkg upgrade -y

    info "Actualizando herramientas globales de npm..."
    npm update -g 2>/dev/null || true

    info "Actualizando Flutter..."
    if command -v flutter >/dev/null 2>&1; then
        flutter upgrade
    fi

    info "Actualizando Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        cd "$HOME/.oh-my-zsh" && git pull
    fi

    success "Actualizaciones completadas"
}

# Función para verificar la instalación
verify_installation() {
    echo -e "${CYAN}🔍 VERIFICANDO INSTALACIÓN${RESET}"
    echo "═══════════════════════════"

    local errors=0

    # Verificar Node.js
    if command -v node >/dev/null 2>&1; then
        echo "✅ Node.js: $(node --version)"
    else
        echo "❌ Node.js no encontrado"
        ((errors++))
    fi

    # Verificar npm
    if command -v npm >/dev/null 2>&1; then
        echo "✅ npm: $(npm --version)"
    else
        echo "❌ npm no encontrado"
        ((errors++))
    fi

    # Verificar Flutter
    if command -v flutter >/dev/null 2>&1; then
        echo "✅ Flutter: $(flutter --version | head -1)"
    else
        echo "❌ Flutter no encontrado"
    fi

    # Verificar VS Code Server
    if [ -f "$HOME/.local/code-server/bin/code-server" ]; then
        echo "✅ VS Code Server instalado"
    else
        echo "❌ VS Code Server no encontrado"
    fi

    # Verificar X11
    if command -v termux-x11 >/dev/null 2>&1; then
        echo "✅ Termux X11 disponible"
    else
        echo "❌ Termux X11 no encontrado"
        ((errors++))
    fi

    # Verificar proot-distro
    if command -v proot-distro >/dev/null 2>&1; then
        echo "✅ proot-distro disponible"
        proot-distro list | grep ubuntu >/dev/null && echo "   ✅ Ubuntu instalado" || echo "   ❌ Ubuntu no instalado"
    else
        echo "❌ proot-distro no encontrado"
    fi

    echo
    if [ $errors -eq 0 ]; then
        success "Instalación verificada correctamente"
    else
        warning "$errors errores encontrados. Considera re-ejecutar la instalación."
    fi
}

# Función para crear un nuevo proyecto
create_project() {
    local project_type="$1"
    local project_name="$2"

    case "$project_type" in
        "web")
            mkdir -p "$HOME/development/web/$project_name"
            cd "$HOME/development/web/$project_name"

            echo "Creando proyecto web: $project_name"
            echo "1) Next.js + TypeScript"
            echo "2) React + Vite"
            echo "3) Node.js simple"
            read -p "Selecciona tipo (1-3): " web_type

            case "$web_type" in
                1) npx create-next-app@latest . --typescript --tailwind --eslint --app ;;
                2) npm create vite@latest . -- --template react-ts ;;
                3) npm init -y && npm install express ;;
                *) echo "Tipo inválido" ;;
            esac
            ;;
        "mobile")
            mkdir -p "$HOME/development/mobile/$project_name"
            cd "$HOME/development/mobile/$project_name"

            echo "Creando proyecto Flutter: $project_name"
            flutter create . --org com.example --project-name "$project_name"
            ;;
        *)
            error "Tipo de proyecto no soportado: $project_type"
            echo "Tipos disponibles: web, mobile"
            return 1
            ;;
    esac

    success "Proyecto $project_name creado en $(pwd)"
}

# Función para mostrar información de desarrollo
show_dev_info() {
    echo -e "${CYAN}📋 INFORMACIÓN DE DESARROLLO${RESET}"
    echo "══════════════════════════════"

    echo "🌐 URLs Locales:"
    echo "   VS Code Server: http://localhost:8080"
    echo "   Next.js dev: http://localhost:3000"
    echo "   React dev: http://localhost:5173"
    echo

    echo "📁 Directorios importantes:"
    echo "   Proyectos web: ~/development/web/"
    echo "   Proyectos móviles: ~/development/mobile/"
    echo "   Templates: ~/development/*/templates/"
    echo

    echo "🔧 Comandos útiles:"
    echo "   startx11 - Iniciar entorno gráfico"
    echo "   startubuntu - Iniciar Ubuntu desktop"
    echo "   code-server-start - Iniciar VS Code"
    echo "   dev - Ir a directorio desarrollo"
    echo

    echo "📊 Puertos comúnmente usados:"
    netstat -tuln 2>/dev/null | grep LISTEN | head -10 || echo "   (netstat no disponible)"
}

# Función principal del menú
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║     TERMUX DEV TOOLS v1.0      ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════╝${RESET}"
    echo
    echo "1) 📊 Estado del sistema"
    echo "2) 🧹 Limpiar sistema"
    echo "3) 🔄 Actualizar herramientas"
    echo "4) 🔍 Verificar instalación"
    echo "5) 📋 Información de desarrollo"
    echo "6) 🆕 Crear nuevo proyecto"
    echo "7) 🔧 Herramientas avanzadas"
    echo "0) ❌ Salir"
    echo
}

# Función para herramientas avanzadas
advanced_tools() {
    echo -e "${CYAN}🔧 HERRAMIENTAS AVANZADAS${RESET}"
    echo "════════════════════════"

    echo "1) Ver logs de instalación"
    echo "2) Backup de configuraciones"
    echo "3) Restaurar configuraciones"
    echo "4) Monitorear procesos"
    echo "5) Configurar variables de entorno"

    read -p "Selecciona opción: " adv_choice

    case "$adv_choice" in
        1)
            latest_log=$(ls -t "$HOME/.termux-dev-setup"/*.log 2>/dev/null | head -1)
            if [ -n "$latest_log" ]; then
                less "$latest_log"
            else
                warning "No se encontraron logs"
            fi
            ;;
        2)
            backup_dir="$HOME/.termux-dev-setup/manual-backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$backup_dir"
            cp -r "$HOME/.config" "$backup_dir/" 2>/dev/null || true
            cp "$HOME/.zshrc" "$backup_dir/" 2>/dev/null || true
            success "Backup creado en: $backup_dir"
            ;;
        3)
            echo "Función de restauración no implementada aún"
            ;;
        4)
            htop
            ;;
        5)
            echo "Variables de entorno actuales:"
            env | grep -E "(NODE|FLUTTER|ANDROID|JAVA)" | sort
            ;;
        *)
            warning "Opción inválida"
            ;;
    esac
}

# Función principal
main() {
    while true; do
        show_menu
        read -p "Selecciona una opción (0-7): " choice

        case "$choice" in
            1) show_system_status ;;
            2) cleanup_system ;;
            3) update_tools ;;
            4) verify_installation ;;
            5) show_dev_info ;;
            6)
                read -p "Tipo de proyecto (web/mobile): " proj_type
                read -p "Nombre del proyecto: " proj_name
                create_project "$proj_type" "$proj_name"
                ;;
            7) advanced_tools ;;
            0)
                info "¡Hasta luego!"
                exit 0
                ;;
            *)
                error "Opción inválida"
                ;;
        esac

        echo
        read -p "Presiona Enter para continuar..." -r
    done
}

# Verificar si se ejecuta con argumentos
if [ $# -gt 0 ]; then
    case "$1" in
        "status") show_system_status ;;
        "clean") cleanup_system ;;
        "update") update_tools ;;
        "verify") verify_installation ;;
        "info") show_dev_info ;;
        *)
            echo "Uso: $0 [status|clean|update|verify|info]"
            exit 1
            ;;
    esac
else
    main
fi