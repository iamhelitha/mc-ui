# Requires -RunAsAdministrator

# Function to write colored output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Check for Git Bash
$gitBash = Get-Command "bash.exe" -ErrorAction SilentlyContinue
if (-not $gitBash) {
    # Download and install Git for Windows if not present
    Write-ColorOutput Yellow "Git Bash not found. Installing Git for Windows..."
    
    $gitInstaller = Join-Path $env:TEMP "git-installer.exe"
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/Git-2.41.0.3-64-bit.exe" -OutFile $gitInstaller
    
    Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT" -Wait
    Remove-Item $gitInstaller
    
    # Add Git to PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $gitBash = Get-Command "bash.exe" -ErrorAction SilentlyContinue
}

if ($gitBash) {
    Write-ColorOutput Green "Starting installation..."
    # Run the bash installation script
    & $gitBash.Source .\install.sh
} else {
    Write-ColorOutput Red "Failed to install Git Bash. Please install it manually and try again."
    exit 1
} 