# Minecraft Server Manager (mc-ui)

A comprehensive Minecraft server management solution with both CLI and web interface.

## Features

- 🖥️ Easy-to-use command-line interface
- 🌐 Web-based management dashboard
- 📊 Real-time server status monitoring
- 💾 Backup and restore functionality
- 🔄 Automatic server restart on crash
- 📈 System resource monitoring
- 📝 Server log viewing
- ⚙️ Easy configuration

## Quick Installation

Install with one command:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/your-username/mc-ui/main/remote-install.sh)
```

## Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/mc-ui.git
cd mc-ui
```

2. Run the installation script:
```bash
sudo ./install.sh
```

## Usage

### Command Line Interface

```bash
mc-ui [command]

Commands:
  status   - Show server status and system information
  install  - Install Minecraft server and requirements
  start    - Start the server
  stop     - Stop the server
  restart  - Restart the server
  backup   - Create a backup
  restore  - Restore from a backup
  web      - Setup/update web interface
  help     - Show this help message
```

### Web Interface

Access the web interface at `http://localhost:8080` after starting the server.

Features:
- Server status monitoring
- Player management
- Backup controls
- Resource usage statistics
- Server logs

## System Requirements

- Operating System: Linux (Ubuntu/Debian recommended)
- RAM: Minimum 2GB (4GB recommended)
- Storage: Minimum 10GB free space
- Java: OpenJDK 17 (automatically installed)
- Root access for installation

## Configuration

Default configuration can be modified in `/opt/minecraft-server/config.conf`:

```conf
JAVA_VERSION="17"
MIN_RAM="1G"
MAX_RAM="4G"
SERVER_PORT=25565
WEB_PORT=8080
```

## Backup Management

Backups are stored in `/opt/minecraft-server/backups` with timestamp-based naming.

To create a backup:
```bash
mc-ui backup
```

To restore a backup:
```bash
mc-ui restore <backup_filename>
```

## Security Recommendations

1. Change default web interface port
2. Set up a firewall (allow ports 25565 and web interface port)
3. Use strong passwords
4. Regularly update the server
5. Make periodic backups

## Troubleshooting

1. If the server fails to start:
   - Check Java installation: `java -version`
   - Verify memory settings in config
   - Check server logs: `/opt/minecraft-server/mc-ui.log`

2. If web interface is inaccessible:
   - Verify nginx is running: `systemctl status nginx`
   - Check port availability: `netstat -tuln | grep 8080`
   - Review nginx logs: `/var/log/nginx/error.log`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 