#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Set installation directory
INSTALL_DIR="/opt/minecraft-server"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy files
cp mc-ui "$INSTALL_DIR/"
cp -r web "$INSTALL_DIR/"

# Create required directories
mkdir -p "$INSTALL_DIR/server"
mkdir -p "$INSTALL_DIR/backups"

# Set permissions
chmod +x "$INSTALL_DIR/mc-ui"
chown -R root:root "$INSTALL_DIR"

# Create symlink
ln -sf "$INSTALL_DIR/mc-ui" /usr/local/bin/mc-ui

echo "Installation complete! You can now use the 'mc-ui' command."
echo "Visit http://localhost:8080 to access the web interface after starting the server." 