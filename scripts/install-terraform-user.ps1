# Install Terraform for current user only (no admin required)

Write-Host "=== Installing Terraform (User Mode) ===" -ForegroundColor Cyan
Write-Host ""

$version = "1.6.6"
$downloadUrl = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_windows_amd64.zip"
$installDir = "$env:USERPROFILE\terraform"
$zipPath = "$env:TEMP\terraform.zip"

Write-Host "Downloading Terraform $version..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

Write-Host "Extracting Terraform..." -ForegroundColor Yellow
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force

Write-Host "Adding Terraform to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "User")
}

Write-Host "Terraform installed to: $installDir" -ForegroundColor Green
Write-Host ""
Write-Host "Please close and reopen PowerShell for changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "To verify installation, run:" -ForegroundColor Cyan
Write-Host "  terraform --version" -ForegroundColor White
