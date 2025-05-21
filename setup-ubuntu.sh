#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Create minecraft directories
MINECRAFT_ROOT="/var/www/minecraft"
mkdir -p "$MINECRAFT_ROOT"/{web,server,backups}

# Copy web files
cp -r web/* "$MINECRAFT_ROOT/web/"

# Set up nginx configuration
cp web/nginx.conf /etc/nginx/nginx.conf

# Create htpasswd file if it doesn't exist
if [ ! -f /etc/nginx/.htpasswd ]; then
    echo "Creating admin user for web interface..."
    apt-get install -y apache2-utils
    htpasswd -c /etc/nginx/.htpasswd admin
fi

# Set proper permissions
chown -R www-data:www-data "$MINECRAFT_ROOT"
chmod -R 755 "$MINECRAFT_ROOT"
find "$MINECRAFT_ROOT" -type f -exec chmod 644 {} \;

# Create necessary log directories
mkdir -p /var/log/nginx
chown -R www-data:adm /var/log/nginx
chmod -R 755 /var/log/nginx

# Test nginx configuration
nginx -t

if [ $? -eq 0 ]; then
    # Restart nginx
    systemctl restart nginx
    echo "Setup completed successfully!"
    echo "Access the web interface at http://localhost"
else
    echo "Error: nginx configuration test failed"
    exit 1
fi 