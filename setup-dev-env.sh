#!/bin/bash

# ===================================================================================
#   SCRIPT DE INSTALACIÓN TOTAL v5.0 (Todo en Uno)
# ===================================================================================
#   Inspirado en los flujos de trabajo profesionales y diseñado para una
#   instalación desde cero, este script configura un entorno de desarrollo
#   completo con aceleración por GPU y un comando de inicio único.
# ===================================================================================

# --- Colores y Funciones de Mensajes ---
GREEN="\e[1;32m"; YELLOW="\e[1;33m"; CYAN="\e[1;36m"; RESET="\e[0m"
info() { echo -e "\n${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "\n${GREEN}[SUCCESS]${RESET} $1"; }
warning() { echo -e "\n${YELLOW}[WARNING]${RESET} $1"; }

# --- Fase 1: Preparación de Termux ---
info "Iniciando la Fase 1: Preparación y actualización de Termux..."
termux-setup-storage
info "Cambiando repositorios para asegurar la máxima compatibilidad..."
termux-change-repo
info "Actualizando y mejorando todos los paquetes base. Esto puede tardar..."
pkg update -y && pkg upgrade -y
info "Instalando dependencias clave de Termux..."
pkg install -y git zsh wget curl proot-distro x11-repo termux-x11-nightly virglrenderer-android

# --- Fase 2: Descarga e Instalación de la App Gráfica ---
info "Iniciando la Fase 2: Descarga de la aplicación Termux:X11..."
X11_APK_URL="https://github.com/termux/termux-x11/releases/latest/download/app-arm64-v8a-debug.apk"
curl -L -o $HOME/termux-x11.apk "$X11_APK_URL"
if [ -f "$HOME/termux-x11.apk" ]; then
    success "Descarga completada. Se abrirá el instalador de Android."
    warning "Por favor, acepta la instalación y luego vuelve a Termux."
    sleep 4
    termux-open $HOME/termux-x11.apk
    warning "Esperando 15 segundos para que la instalación finalice..."
    sleep 15
else
    warning "La descarga de Termux:X11 falló. Por favor, instálala manualmente desde F-Droid."
fi

# --- Fase 3: Instalación y Configuración de Ubuntu ---
info "Iniciando la Fase 3: Instalación de Ubuntu 24.04 LTS..."
proot-distro install ubuntu
info "Creando script de configuración para el entorno interno de Ubuntu..."
cat <<'EOF' > $HOME/ubuntu-dev-setup.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
info_ubuntu() { echo -e "\n\e[1;36m[Ubuntu Setup]\e[0m $1"; }

info_ubuntu "Actualizando lista de paquetes..."
apt update && apt upgrade -y

info_ubuntu "Instalando entorno de escritorio XFCE4 y utilidades..."
apt install -y sudo nano curl wget git xfce4 xfce4-goodies dbus-x11 \
mesa-utils-extra libegl1-mesa libgl1-mesa-dri libgles2-mesa zsh

info_ubuntu "Instalando Oh My Zsh para una mejor terminal..."
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

info_ubuntu "Instalando VS Code (code-server)..."
wget -q https://github.com/coder/code-server/releases/download/v4.16.1/code-server-4.16.1-linux-arm64.tar.gz
tar -xf code-server-*-linux-arm64.tar.gz && mv code-server-*-linux-arm64 /opt/code-server
rm code-server-*-linux-arm64.tar.gz

info_ubuntu "Instalando Node.js (via NVM) y Flutter SDK..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter

info_ubuntu "Configurando Zsh como shell por defecto y añadiendo variables de entorno..."
chsh -s $(which zsh) root
echo '
# --- Variables de Entorno para Desarrollo ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
export PATH="$PATH:/opt/flutter/bin"
# --- Fin Variables ---
' >> /root/.zshrc
EOF

info "Ejecutando la configuración dentro de Ubuntu..."
proot-distro login ubuntu -- bash $HOME/ubuntu-dev-setup.sh

# --- Fase 4: Creación del Comando de Inicio Profesional 'startubuntu' ---
info "Iniciando la Fase 4: Creando el comando de inicio 'startubuntu'..."
cat <<'EOF' > $PREFIX/bin/startubuntu
#!/bin/bash
# Script para iniciar el entorno Ubuntu con aceleración GPU.

# 1. Limpieza agresiva de procesos y archivos de bloqueo.
pkill -9 -f "proot-distro"
pkill -9 -f "virgl_test_server_android"
pkill -9 -f "termux-x11"
rm -f $TMPDIR/.X11-unix/X0 # Elimina el archivo de bloqueo del servidor X
echo "✅ Entorno previo limpiado."
sleep 1

# 2. Inicia el servidor VirGL (GPU) en segundo plano.
echo "🚀 Iniciando servidor GPU (VirGL)..."
virgl_test_server_android &
sleep 3 # Espera a que el servidor se levante

# 3. Inicia el escritorio XFCE4 dentro de Ubuntu en segundo plano.
echo "🖥️  Iniciando escritorio XFCE4..."
proot-distro login ubuntu --shared-tmp -- \
  /bin/bash -c 'export DISPLAY=:0 PULSE_SERVER=127.0.0.1; dbus-launch --exit-with-session startxfce4' &

# 4. Lanza el cliente Termux:X11 en primer plano.
# El script se pausará aquí hasta que cierres la ventana de Termux:X11.
echo "📱 Lanzando cliente gráfico. Abre la app Termux:X11 para ver tu escritorio."
termux-x11 :0

# 5. Limpieza final al cerrar la sesión.
echo "🛑 Sesión cerrada. Deteniendo todos los procesos..."
pkill -9 -f "proot-distro"
pkill -9 -f "virgl_test_server_android"
echo "✅ Entorno finalizado limpiamente."
EOF
chmod +x $PREFIX/bin/startubuntu

# --- Finalización ---
success "¡INSTALACIÓN COMPLETA!"
warning "Cierra y vuelve a abrir Termux, luego ejecuta el comando:"
echo -e "${GREEN}startubuntu${RESET}"