# Install AWS CLI and Terraform for Windows
# Run this script as Administrator

Write-Host "=== Installing Deployment Tools ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "WARNING: This script should be run as Administrator for best results." -ForegroundColor Yellow
    Write-Host "Some installations may fail without admin privileges." -ForegroundColor Yellow
    Write-Host ""
}

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey package manager..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Write-Host "✓ Chocolatey installed" -ForegroundColor Green
Write-Host ""

# Install AWS CLI
Write-Host "Installing AWS CLI..." -ForegroundColor Yellow
if (Get-Command aws -ErrorAction SilentlyContinue) {
    Write-Host "  AWS CLI already installed" -ForegroundColor Cyan
} else {
    choco install awscli -y
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
Write-Host "✓ AWS CLI ready" -ForegroundColor Green
Write-Host ""

# Install Terraform
Write-Host "Installing Terraform..." -ForegroundColor Yellow
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Host "  Terraform already installed" -ForegroundColor Cyan
} else {
    choco install terraform -y
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
Write-Host "✓ Terraform ready" -ForegroundColor Green
Write-Host ""

Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Please close and reopen PowerShell, then run:" -ForegroundColor Cyan
Write-Host "  .\scripts\deploy-learner-lab.ps1" -ForegroundColor White
Write-Host ""
