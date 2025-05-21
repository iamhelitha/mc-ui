#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to log messages
log() {
    echo -e "${2:-$NC}$1${NC}"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_NAME=$NAME
            OS_TYPE="linux"
        else
            OS_NAME="Unknown Linux"
            OS_TYPE="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macOS"
        OS_TYPE="mac"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OS" == "Windows_NT" ]]; then
        OS_NAME="Windows"
        OS_TYPE="windows"
    else
        OS_NAME="Unknown"
        OS_TYPE="unknown"
    fi
}

# Function to check if running with admin privileges
check_admin() {
    case $OS_TYPE in
        linux)
            if [ "$EUID" -ne 0 ]; then
                log "Please run as root" "$RED"
                exit 1
            fi
            ;;
        windows)
            if ! net session >/dev/null 2>&1; then
                log "Please run as administrator" "$RED"
                exit 1
            fi
            ;;
    esac
}

# Function to setup Ubuntu
setup_ubuntu() {
    log "Setting up for Ubuntu..." "$GREEN"
    
    # Install required packages
    apt-get update
    apt-get install -y nginx apache2-utils
    
    # Create minecraft directories
    MINECRAFT_ROOT="/var/www/minecraft"
    mkdir -p "$MINECRAFT_ROOT"/{web,server,backups}
    
    # Copy web files
    cp -r web/* "$MINECRAFT_ROOT/web/"
    
    # Set up nginx configuration
    cp web/nginx.conf /etc/nginx/nginx.conf
    
    # Create htpasswd file
    if [ ! -f /etc/nginx/.htpasswd ]; then
        log "Creating admin user for web interface..." "$YELLOW"
        htpasswd -c /etc/nginx/.htpasswd admin
    fi
    
    # Set proper permissions
    chown -R www-data:www-data "$MINECRAFT_ROOT"
    chmod -R 755 "$MINECRAFT_ROOT"
    find "$MINECRAFT_ROOT" -type f -exec chmod 644 {} \;
    
    # Create log directories
    mkdir -p /var/log/nginx
    chown -R www-data:adm /var/log/nginx
    chmod -R 755 /var/log/nginx
    
    # Test and restart nginx
    nginx -t && systemctl restart nginx
}

# Function to setup Windows
setup_windows() {
    log "Setting up for Windows..." "$GREEN"
    
    # Set paths
    NGINX_PATH="C:\nginx"
    WORKSPACE_PATH=$PWD
    WEB_PATH="$WORKSPACE_PATH\web"
    SERVER_PATH="$WORKSPACE_PATH\server"
    BACKUP_PATH="$WORKSPACE_PATH\backups"
    
    # Create directories
    mkdir -p "$SERVER_PATH" "$BACKUP_PATH"
    
    # Download and install nginx if not present
    if [ ! -d "$NGINX_PATH" ]; then
        log "Installing nginx..." "$YELLOW"
        
        # Download nginx
        curl -o nginx.zip http://nginx.org/download/nginx-1.24.0.zip
        
        # Extract nginx
        unzip -q nginx.zip -d C:/
        mv C:/nginx-1.24.0 "$NGINX_PATH"
        rm nginx.zip
    fi
    
    # Copy nginx configuration
    cp "$WEB_PATH/nginx.conf" "$NGINX_PATH/conf/nginx.conf"
    
    # Start nginx
    "$NGINX_PATH/nginx.exe" -s stop 2>/dev/null || true
    "$NGINX_PATH/nginx.exe"
}

# Main installation process
main() {
    log "Starting Minecraft Server Manager installation..." "$GREEN"
    
    # Detect OS
    detect_os
    log "Detected OS: $OS_NAME" "$YELLOW"
    
    # Check admin privileges
    check_admin
    
    # Run appropriate setup based on OS
    case $OS_TYPE in
        linux)
            if [[ $OS_NAME == *"Ubuntu"* ]]; then
                setup_ubuntu
            else
                log "This Linux distribution is not fully supported. Attempting Ubuntu-compatible setup..." "$YELLOW"
                setup_ubuntu
            fi
            ;;
        windows)
            setup_windows
            ;;
        *)
            log "Unsupported operating system: $OS_NAME" "$RED"
            exit 1
            ;;
    esac
    
    log "Installation completed successfully!" "$GREEN"
    log "Access the web interface at http://localhost" "$GREEN"
}

# Start installation
main 