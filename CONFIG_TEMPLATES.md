# Termux Development Environment - Configuration Templates

## Environment Variables Template

```bash
# ~/.zshrc additions for development environment

# ==================== DEVELOPMENT ENVIRONMENT ====================

# Node.js Configuration
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

# Flutter Configuration
export FLUTTER_ROOT="$HOME/development/flutter"
export PATH="$FLUTTER_ROOT/bin:$PATH"

# Android Development
export ANDROID_HOME="$HOME/development/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"

# Java Configuration
export JAVA_HOME="$PREFIX/opt/openjdk"

# Python Configuration
export PYTHONPATH="$HOME/development/python:$PYTHONPATH"

# Development Tools
export PATH="$HOME/development/tools:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Editor Configuration
export EDITOR=nano
export VISUAL=nano

# Development Aliases
alias dev='cd $HOME/development'
alias web='cd $HOME/development/web'
alias mobile='cd $HOME/development/mobile'
alias tools='cd $HOME/development/tools'
alias ll='ls -alF'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias ports='netstat -tuln'
alias psg='ps aux | grep'

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Development Server Aliases
alias serve='npx serve'
alias dev-server='npx live-server'
alias next-dev='npx next dev'
alias flutter-run='flutter run'

# System Maintenance
alias update-system='pkg update && pkg upgrade'
alias clean-npm='npm cache clean --force'
alias clean-yarn='yarn cache clean'

# X11 and GUI
alias startx='startx11'
alias ubuntu='startubuntu'
alias code='code-server-start'

# ==================== PROMPT CUSTOMIZATION ====================

# Custom prompt with git branch
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%n@%m%f:%F{green}%~%f %F{yellow}${vcs_info_msg_0_}%f$ '

# Welcome message
echo "🚀 Termux Development Environment Ready!"
echo "📁 Use 'dev' to go to development directory"
echo "🔧 Use 'dev-tools.sh' for maintenance utilities"
```

## VS Code Server Configuration

```yaml
# ~/.config/code-server/config.yaml
bind-addr: 127.0.0.1:8080
auth: password
password: your-secure-password-here
cert: false
user-data-dir: ~/.local/share/code-server
extensions-dir: ~/.local/share/code-server/extensions
```

## Package.json Template for Web Projects

```json
{
  "name": "termux-web-project",
  "version": "1.0.0",
  "description": "Web project created in Termux",
  "main": "index.js",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "biome check .",
    "lint:fix": "biome check --apply .",
    "format": "biome format --write .",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "@biomejs/biome": "latest",
    "@types/node": "^20.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^5.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

## Flutter Project Configuration

```yaml
# pubspec.yaml template additions for Termux
name: termux_flutter_project
description: Flutter project created in Termux

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^1.1.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

## Biome Configuration

```json
{
  "$schema": "https://biomejs.dev/schemas/1.4.1/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "style": {
        "noUnusedTemplateLiteral": "off"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 80
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "trailingComma": "es5"
    }
  },
  "json": {
    "formatter": {
      "indentWidth": 2
    }
  }
}
```

## X11 Startup Script

```bash
#!/bin/bash
# ~/.local/bin/startx11-enhanced

set -e

# Enhanced X11 startup with error handling
cleanup() {
    echo "🧹 Cleaning up processes..."
    pkill -9 -f "proot-distro" 2>/dev/null || true
    pkill -9 -f "virgl_test_server_android" 2>/dev/null || true
    pkill -9 -f "termux-x11" 2>/dev/null || true
    rm -f $TMPDIR/.X11-unix/X* 2>/dev/null || true
}

check_dependencies() {
    command -v virgl_test_server_android >/dev/null || {
        echo "❌ virgl_test_server_android not found"
        exit 1
    }
    command -v termux-x11 >/dev/null || {
        echo "❌ termux-x11 not found"
        exit 1
    }
}

echo "🔍 Checking dependencies..."
check_dependencies

echo "🧹 Cleaning previous sessions..."
cleanup
sleep 2

echo "🎮 Starting GPU server..."
virgl_test_server_android &
sleep 3

echo "🖥️ Starting X11 server..."
echo "📱 Open Termux:X11 app to see the display"
termux-x11 :0 &

# Wait for interrupt
trap cleanup EXIT
echo "🛑 Press Ctrl+C to stop X11 server"
wait
```

## Systemd-style Service Scripts

```bash
# ~/.local/bin/service-manager

#!/bin/bash
# Simple service manager for Termux

SERVICE_DIR="$HOME/.local/services"
mkdir -p "$SERVICE_DIR"

start_service() {
    local service="$1"
    case "$service" in
        "code-server")
            nohup code-server-start > "$SERVICE_DIR/code-server.log" 2>&1 &
            echo $! > "$SERVICE_DIR/code-server.pid"
            echo "✅ Code Server started (PID: $(cat $SERVICE_DIR/code-server.pid))"
            ;;
        "x11")
            nohup startx11 > "$SERVICE_DIR/x11.log" 2>&1 &
            echo $! > "$SERVICE_DIR/x11.pid"
            echo "✅ X11 Server started (PID: $(cat $SERVICE_DIR/x11.pid))"
            ;;
        *)
            echo "❌ Unknown service: $service"
            return 1
            ;;
    esac
}

stop_service() {
    local service="$1"
    local pid_file="$SERVICE_DIR/$service.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null && echo "✅ $service stopped" || echo "❌ Failed to stop $service"
        rm -f "$pid_file"
    else
        echo "❌ $service is not running"
    fi
}

status_service() {
    local service="$1"
    local pid_file="$SERVICE_DIR/$service.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ $service is running (PID: $pid)"
        else
            echo "❌ $service is dead (stale PID file)"
            rm -f "$pid_file"
        fi
    else
        echo "❌ $service is not running"
    fi
}

case "${1:-}" in
    "start") start_service "$2" ;;
    "stop") stop_service "$2" ;;
    "status") status_service "$2" ;;
    "restart")
        stop_service "$2"
        sleep 2
        start_service "$2"
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart} {code-server|x11}"
        echo "Available services:"
        echo "  code-server - VS Code Server"
        echo "  x11         - X11 Display Server"
        ;;
esac
```

## Project Creation Templates

```bash
# ~/.local/bin/create-project

#!/bin/bash
# Project creation utility

create_nextjs_project() {
    local name="$1"
    local dir="$HOME/development/web/$name"

    echo "🚀 Creating Next.js project: $name"
    mkdir -p "$dir"
    cd "$dir"

    npx create-next-app@latest . \
        --typescript \
        --tailwind \
        --eslint \
        --app \
        --no-src-dir \
        --import-alias="@/*"

    # Add Biome configuration
    npm install --save-dev @biomejs/biome
    npx biome init

    echo "✅ Next.js project created at: $dir"
}

create_flutter_project() {
    local name="$1"
    local dir="$HOME/development/mobile/$name"

    echo "🚀 Creating Flutter project: $name"
    mkdir -p "$(dirname "$dir")"

    flutter create "$dir" \
        --org com.example \
        --project-name "$name" \
        --platforms android,web

    echo "✅ Flutter project created at: $dir"
}

create_python_project() {
    local name="$1"
    local dir="$HOME/development/python/$name"

    echo "🐍 Creating Python project: $name"
    mkdir -p "$dir"
    cd "$dir"

    # Create virtual environment
    python -m venv venv
    source venv/bin/activate

    # Create basic structure
    mkdir -p src tests docs
    touch src/__init__.py
    touch tests/__init__.py
    touch README.md
    touch requirements.txt

    # Create setup files
    cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$name"
version = "0.1.0"
description = "Python project created in Termux"
authors = [{name = "Developer", email = "dev@example.com"}]
requires-python = ">=3.8"
dependencies = []

[project.optional-dependencies]
dev = ["pytest", "black", "flake8"]
EOF

    echo "✅ Python project created at: $dir"
}

case "${1:-}" in
    "nextjs") create_nextjs_project "$2" ;;
    "flutter") create_flutter_project "$2" ;;
    "python") create_python_project "$2" ;;
    *)
        echo "Usage: $0 {nextjs|flutter|python} <project-name>"
        echo "Examples:"
        echo "  $0 nextjs my-web-app"
        echo "  $0 flutter my-mobile-app"
        echo "  $0 python my-python-app"
        ;;
esac
```