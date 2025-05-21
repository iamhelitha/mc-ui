#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_message "Please run as root" "$RED"
    exit 1
fi

# Check system requirements
check_requirements() {
    print_message "Checking system requirements..." "$YELLOW"
    
    # Check RAM
    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -lt 2048 ]; then
        print_message "Warning: Less than 2GB RAM available. Server might not perform well." "$YELLOW"
    fi
    
    # Check disk space
    FREE_SPACE=$(df -m / | awk 'NR==2 {print $4}')
    if [ "$FREE_SPACE" -lt 10240 ]; then
        print_message "Error: Insufficient disk space. At least 10GB free space required." "$RED"
        exit 1
    fi
}

# Install required packages
install_dependencies() {
    print_message "Installing dependencies..." "$YELLOW"
    
    # Update package list
    apt-get update
    
    # Install git and curl if not present
    apt-get install -y git curl
}

# Clone repository
clone_repository() {
    print_message "Downloading mc-ui..." "$YELLOW"
    
    # Set temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Clone repository
    git clone https://github.com/your-username/mc-ui.git
    
    if [ $? -ne 0 ]; then
        print_message "Failed to download mc-ui" "$RED"
        exit 1
    fi
}

# Run installation
run_installation() {
    print_message "Installing mc-ui..." "$YELLOW"
    
    cd "$TMP_DIR/mc-ui"
    bash install.sh
    
    if [ $? -ne 0 ]; then
        print_message "Installation failed" "$RED"
        exit 1
    fi
}

# Cleanup
cleanup() {
    print_message "Cleaning up..." "$YELLOW"
    rm -rf "$TMP_DIR"
}

# Main installation process
main() {
    print_message "Starting Minecraft Server Manager (mc-ui) installation..." "$GREEN"
    
    check_requirements
    install_dependencies
    clone_repository
    run_installation
    cleanup
    
    print_message "Installation completed successfully!" "$GREEN"
    print_message "\nYou can now use 'mc-ui' command to manage your Minecraft server." "$GREEN"
    print_message "Access the web interface at http://localhost:8080" "$GREEN"
    print_message "\nFor more information, visit: https://github.com/your-username/mc-ui" "$GREEN"
}

# Start installation
main 