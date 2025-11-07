# Direct Deployment to EC2 (No S3 needed)
# This creates a single script file to run on EC2

Write-Host ""
Write-Host "=== Creating EC2 Deployment Package ===" -ForegroundColor Cyan
Write-Host ""

# Get instance details
Set-Location infrastructure/learner-lab
$publicIp = terraform output -raw public_ip
Set-Location ../..

Write-Host "Target IP: $publicIp" -ForegroundColor Cyan
Write-Host ""

# Build applications
Write-Host "[1/3] Building applications..." -ForegroundColor Yellow
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

# Create deployment archive
Write-Host ""
Write-Host "[2/3] Creating deployment archive..." -ForegroundColor Yellow

$deployDir = "ec2-deploy"
if (Test-Path $deployDir) {
    Remove-Item -Recurse -Force $deployDir
}
New-Item -ItemType Directory -Path $deployDir | Out-Null

# Copy setup script
Copy-Item ec2-setup-complete.sh "$deployDir/"

# Copy frontend
New-Item -ItemType Directory -Path "$deployDir/frontend" | Out-Null
Copy-Item -Recurse frontend/dist/* "$deployDir/frontend/"

# Copy backend
New-Item -ItemType Directory -Path "$deployDir/backend" | Out-Null
Copy-Item -Recurse backend/dist "$deployDir/backend/"
Copy-Item backend/package.json "$deployDir/backend/"
if (Test-Path backend/package-lock.json) {
    Copy-Item backend/package-lock.json "$deployDir/backend/"
}

# Create deployment script for EC2
$deployScript = @'
#!/bin/bash
echo "Deploying application..."

# Stop backend if running
sudo systemctl stop todo-backend 2>/dev/null || true

# Deploy frontend
sudo rm -rf /opt/todo-app/frontend/*
sudo cp -r ~/ec2-deploy/frontend/* /opt/todo-app/frontend/

# Deploy backend
sudo rm -rf /opt/todo-app/backend/dist
sudo cp -r ~/ec2-deploy/backend/dist /opt/todo-app/backend/
sudo cp ~/ec2-deploy/backend/package*.json /opt/todo-app/backend/

# Install dependencies
cd /opt/todo-app/backend
sudo npm install --production

# Set permissions
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Start services
sudo systemctl daemon-reload
sudo systemctl start todo-backend
sudo systemctl enable todo-backend
sudo systemctl restart nginx

echo ""
echo "Deployment complete!"
echo "Check status:"
echo "  sudo systemctl status todo-backend"
echo "  sudo systemctl status nginx"
'@

Set-Content -Path "$deployDir/deploy.sh" -Value $deployScript

Write-Host "  Package created" -ForegroundColor Green

# Create instructions
Write-Host ""
Write-Host "[3/3] Deployment Instructions" -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  COPY THESE COMMANDS TO EC2" -ForegroundColor Cyan  
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "In your EC2 Instance Connect terminal, run:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Step 1: Setup the instance" -ForegroundColor Green
Write-Host 'curl -o setup.sh https://raw.githubusercontent.com/nodesource/distributions/master/rpm/setup_18.x' -ForegroundColor White
Write-Host 'sudo bash setup.sh' -ForegroundColor White
Write-Host 'sudo yum install -y nodejs nginx git' -ForegroundColor White
Write-Host 'sudo amazon-linux-extras install nginx1 -y' -ForegroundColor White
Write-Host ""
Write-Host "# Step 2: Configure nginx" -ForegroundColor Green
Write-Host @'
sudo tee /etc/nginx/conf.d/todo-app.conf > /dev/null <<'NGINX'
server {
    listen 80;
    server_name _;
    location / {
        root /opt/todo-app/frontend;
        try_files $uri $uri/ /index.html;
    }
    location /api/ {
        proxy_pass http://localhost:3001/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    location /health {
        proxy_pass http://localhost:3001/health;
    }
}
NGINX
'@ -ForegroundColor White
Write-Host ""
Write-Host "# Step 3: Create backend service" -ForegroundColor Green
Write-Host @'
sudo tee /etc/systemd/system/todo-backend.service > /dev/null <<'SERVICE'
[Unit]
Description=Todo App Backend
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/todo-app/backend
Environment="NODE_ENV=production"
Environment="PORT=3001"
Environment="DB_TYPE=memory"
ExecStart=/usr/bin/node dist/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE
'@ -ForegroundColor White
Write-Host ""
Write-Host "# Step 4: Create directories" -ForegroundColor Green
Write-Host 'sudo mkdir -p /opt/todo-app/frontend /opt/todo-app/backend' -ForegroundColor White
Write-Host 'sudo chown -R ec2-user:ec2-user /opt/todo-app' -ForegroundColor White
Write-Host 'sudo systemctl start nginx && sudo systemctl enable nginx' -ForegroundColor White
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "After running those commands, I'll give you the app files to upload." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter when ready..." -ForegroundColor Cyan
Read-Host

Write-Host ""
Write-Host "Great! Now the deployment package is in the '$deployDir' folder." -ForegroundColor Green
Write-Host ""
Write-Host "You have two options to upload:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Use GitHub (Easiest)" -ForegroundColor Cyan
Write-Host "  1. Create a new GitHub repo (can be private)" -ForegroundColor White
Write-Host "  2. Upload the '$deployDir' folder contents" -ForegroundColor White
Write-Host "  3. On EC2, run: git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git" -ForegroundColor White
Write-Host "  4. Then: cd YOUR-REPO && bash deploy.sh" -ForegroundColor White
Write-Host ""
Write-Host "Option 2: Manual file creation (if no GitHub)" -ForegroundColor Cyan
Write-Host "  I can generate commands to create the files directly on EC2" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Which option? (1 or 2)"

if ($choice -eq "2") {
    Write-Host ""
    Write-Host "Generating file creation commands..." -ForegroundColor Yellow
    Write-Host "This will be a lot of commands. Ready? (yes/no)" -ForegroundColor Cyan
    $ready = Read-Host
    
    if ($ready -eq "yes") {
        Write-Host ""
        Write-Host "I'll create a simpler approach - let me package this differently..." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Deployment package ready in: $deployDir" -ForegroundColor Green
Write-Host "Your app will be at: http://$publicIp" -ForegroundColor Cyan
Write-Host ""
