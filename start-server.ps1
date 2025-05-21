# Requires -RunAsAdministrator

# Configuration
$NGINX_PATH = "C:\nginx"
$WORKSPACE_PATH = $PSScriptRoot
$WEB_PATH = Join-Path $WORKSPACE_PATH "web"
$SERVER_PATH = Join-Path $WORKSPACE_PATH "server"

# Create required directories if they don't exist
New-Item -ItemType Directory -Force -Path $SERVER_PATH | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $WORKSPACE_PATH "backups") | Out-Null

# Function to check if a port is in use
function Test-PortInUse {
    param($port)
    $listener = [System.Net.Sockets.TcpListener]$port
    try {
        $listener.Start()
        $listener.Stop()
        return $false
    } catch {
        return $true
    }
}

# Check if ports are available
if (Test-PortInUse 80) {
    Write-Host "Error: Port 80 is already in use. Please stop any other web servers." -ForegroundColor Red
    exit 1
}

if (Test-PortInUse 8080) {
    Write-Host "Error: Port 8080 is already in use." -ForegroundColor Red
    exit 1
}

# Check if nginx is installed
if (-not (Test-Path $NGINX_PATH)) {
    Write-Host "Nginx not found. Installing nginx..." -ForegroundColor Yellow
    
    # Download nginx
    $nginxZip = Join-Path $env:TEMP "nginx.zip"
    Invoke-WebRequest -Uri "http://nginx.org/download/nginx-1.24.0.zip" -OutFile $nginxZip
    
    # Extract nginx
    Expand-Archive -Path $nginxZip -DestinationPath "C:\" -Force
    Rename-Item -Path "C:\nginx-1.24.0" -NewName "C:\nginx" -Force
    Remove-Item $nginxZip
    
    Write-Host "Nginx installed successfully." -ForegroundColor Green
}

# Copy our nginx configuration
Copy-Item -Path (Join-Path $WEB_PATH "nginx.conf") -Destination (Join-Path $NGINX_PATH "conf/nginx.conf") -Force

# Start nginx
$nginxProcess = Start-Process -FilePath (Join-Path $NGINX_PATH "nginx.exe") -PassThru -WindowStyle Hidden

Write-Host "Web interface started at http://localhost" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server..." -ForegroundColor Yellow

# Wait for Ctrl+C
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Stop nginx gracefully
    if ($nginxProcess) {
        Start-Process -FilePath (Join-Path $NGINX_PATH "nginx.exe") -ArgumentList "-s","quit" -Wait
    }
    Write-Host "`nServer stopped." -ForegroundColor Yellow
} 