# Create GitHub Deployment Package

Write-Host ""
Write-Host "=== Creating GitHub Deployment Package ===" -ForegroundColor Cyan
Write-Host ""

# Build applications
Write-Host "Building applications..." -ForegroundColor Yellow

Set-Location frontend
if (!(Test-Path "dist")) {
    npm install
    npm run build
}
Set-Location ..

Set-Location backend  
if (!(Test-Path "dist")) {
    npm install
    npm run build
}
Set-Location ..

Write-Host "  Build complete" -ForegroundColor Green
Write-Host ""

# Create deployment folder
$deployFolder = "github-deploy"
if (Test-Path $deployFolder) {
    Remove-Item -Recurse -Force $deployFolder
}
New-Item -ItemType Directory -Path $deployFolder | Out-Null

# Copy frontend
Write-Host "Packaging frontend..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$deployFolder/frontend" | Out-Null
Copy-Item -Recurse frontend/dist/* "$deployFolder/frontend/"

# Copy backend
Write-Host "Packaging backend..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$deployFolder/backend" | Out-Null
Copy-Item -Recurse backend/dist "$deployFolder/backend/"
Copy-Item backend/package.json "$deployFolder/backend/"
if (Test-Path backend/package-lock.json) {
    Copy-Item backend/package-lock.json "$deployFolder/backend/"
}

# Create deployment script
$deployScript = @'
#!/bin/bash
echo "Deploying Todo App..."

# Stop backend if running
sudo systemctl stop todo-backend 2>/dev/null || true

# Deploy frontend
sudo rm -rf /opt/todo-app/frontend/*
sudo cp -r frontend/* /opt/todo-app/frontend/

# Deploy backend
sudo rm -rf /opt/todo-app/backend/dist
sudo cp -r backend/dist /opt/todo-app/backend/
sudo cp backend/package*.json /opt/todo-app/backend/

# Install dependencies
cd /opt/todo-app/backend
sudo npm install --production --silent

# Set permissions
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Start services
sudo systemctl daemon-reload
sudo systemctl start todo-backend
sudo systemctl enable todo-backend
sudo systemctl restart nginx

echo ""
echo "========================================="
echo "  Deployment Complete!"
echo "========================================="
echo ""
echo "Check status:"
echo "  sudo systemctl status todo-backend"
echo "  sudo systemctl status nginx"
echo ""
echo "View logs:"
echo "  sudo journalctl -u todo-backend -f"
echo ""
'@

Set-Content -Path "$deployFolder/deploy.sh" -Value $deployScript

# Create README
$readme = @"
# Todo App Deployment Package

## Quick Deploy

Run this command on your EC2 instance:

\`\`\`bash
bash deploy.sh
\`\`\`

## What This Does

1. Stops the backend service if running
2. Copies frontend files to /opt/todo-app/frontend
3. Copies backend files to /opt/todo-app/backend
4. Installs Node.js dependencies
5. Starts the backend service
6. Restarts nginx

## After Deployment

Your app will be available at: http://YOUR-EC2-IP

## Troubleshooting

Check if services are running:
\`\`\`bash
sudo systemctl status todo-backend
sudo systemctl status nginx
\`\`\`

View backend logs:
\`\`\`bash
sudo journalctl -u todo-backend -f
\`\`\`

Restart services:
\`\`\`bash
sudo systemctl restart todo-backend
sudo systemctl restart nginx
\`\`\`
"@

Set-Content -Path "$deployFolder/README.md" -Value $readme

Write-Host "  Package created" -ForegroundColor Green
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "  NEXT STEPS" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. Create a new GitHub repository:" -ForegroundColor Yellow
Write-Host "   - Go to https://github.com/new" -ForegroundColor White
Write-Host "   - Name it: todo-deploy" -ForegroundColor White
Write-Host "   - Make it Public (easier) or Private" -ForegroundColor White
Write-Host "   - Don't add README, .gitignore, or license" -ForegroundColor White
Write-Host "   - Click 'Create repository'" -ForegroundColor White
Write-Host ""
Write-Host "2. Upload the files:" -ForegroundColor Yellow
Write-Host "   - Click 'uploading an existing file'" -ForegroundColor White
Write-Host "   - Drag the entire '$deployFolder' folder contents" -ForegroundColor White
Write-Host "   - Click 'Commit changes'" -ForegroundColor White
Write-Host ""
Write-Host "3. On your EC2 instance, run:" -ForegroundColor Yellow
Write-Host "   git clone https://github.com/YOUR-USERNAME/todo-deploy.git" -ForegroundColor Cyan
Write-Host "   cd todo-deploy" -ForegroundColor Cyan
Write-Host "   bash deploy.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Wait 30 seconds, then visit:" -ForegroundColor Yellow
Write-Host "   http://52.200.153.80" -ForegroundColor Cyan
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Deployment package is ready in: $deployFolder" -ForegroundColor White
Write-Host ""
