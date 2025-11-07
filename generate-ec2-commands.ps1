# Generate commands to create files directly on EC2

Write-Host ""
Write-Host "=== Generating EC2 Deployment Commands ===" -ForegroundColor Cyan
Write-Host ""

# Check if builds exist
if (!(Test-Path "frontend/dist") -or !(Test-Path "backend/dist")) {
    Write-Host "Building applications first..." -ForegroundColor Yellow
    
    Set-Location frontend
    npm install
    npm run build
    Set-Location ..
    
    Set-Location backend
    npm install
    npm run build
    Set-Location ..
}

Write-Host "Creating deployment commands..." -ForegroundColor Yellow
Write-Host ""

$outputFile = "EC2-PASTE-THESE-COMMANDS.txt"

$commands = @"
# ============================================
# PASTE THESE COMMANDS IN EC2 TERMINAL
# ============================================

# Install git (if needed)
sudo yum install -y git

# Go to home directory
cd ~

# Create a simple deployment using wget/curl
# We'll create the files manually

echo "Creating deployment structure..."

# Create frontend index.html
sudo mkdir -p /opt/todo-app/frontend
sudo tee /opt/todo-app/frontend/index.html > /dev/null <<'HTMLEOF'
"@

# Read and add frontend index.html
$indexHtml = Get-Content "frontend/dist/index.html" -Raw
$commands += $indexHtml
$commands += @"

HTMLEOF

# Create frontend assets directory
sudo mkdir -p /opt/todo-app/frontend/assets

"@

# Get all asset files
$assetFiles = Get-ChildItem "frontend/dist/assets" -File
foreach ($file in $assetFiles) {
    $content = Get-Content $file.FullName -Raw
    $fileName = $file.Name
    
    $commands += @"
# Create $fileName
sudo tee /opt/todo-app/frontend/assets/$fileName > /dev/null <<'ASSETEOF'
$content
ASSETEOF

"@
}

$commands += @"

# Set permissions
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Create backend package.json
sudo mkdir -p /opt/todo-app/backend
sudo tee /opt/todo-app/backend/package.json > /dev/null <<'PKGEOF'
"@

$packageJson = Get-Content "backend/package.json" -Raw
$commands += $packageJson
$commands += @"

PKGEOF

# Install backend dependencies
cd /opt/todo-app/backend
sudo npm install --production

echo "Deployment complete!"
echo "Starting services..."

# Start services
sudo systemctl daemon-reload
sudo systemctl start todo-backend
sudo systemctl enable todo-backend
sudo systemctl restart nginx

echo ""
echo "========================================="
echo "  Application Deployed!"
echo "========================================="
echo ""
echo "Check status:"
echo "  sudo systemctl status todo-backend"
echo "  sudo systemctl status nginx"
echo ""

"@

Set-Content -Path $outputFile -Value $commands

Write-Host "Commands generated!" -ForegroundColor Green
Write-Host ""
Write-Host "File created: $outputFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "This file is too large to paste directly." -ForegroundColor Yellow
Write-Host "Let me create a better solution..." -ForegroundColor Yellow
Write-Host ""
