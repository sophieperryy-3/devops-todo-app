# Install AWS CLI for current user only (no admin required)

Write-Host "=== Installing AWS CLI (User Mode) ===" -ForegroundColor Cyan
Write-Host ""

$downloadUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$installerPath = "$env:TEMP\AWSCLIV2.msi"

Write-Host "Downloading AWS CLI..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

Write-Host "Installing AWS CLI..." -ForegroundColor Yellow
Write-Host "This will open an installer window. Please complete the installation." -ForegroundColor Cyan
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /qn" -Wait

Write-Host "AWS CLI installed" -ForegroundColor Green
Write-Host ""
Write-Host "Please close and reopen PowerShell for changes to take effect." -ForegroundColor Yellow
