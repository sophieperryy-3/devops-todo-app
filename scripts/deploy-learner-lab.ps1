# AWS Learner Lab Deployment Script
# This script deploys the todo app to AWS Learner Lab

param(
    [string]$KeyPairName = "vockey",
    [string]$Region = "us-east-1"
)

Write-Host "=== AWS Learner Lab Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check AWS CLI
if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: AWS CLI not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Check Terraform
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Terraform not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Check Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js not found. Please install it first." -ForegroundColor Red
    exit 1
}

Write-Host "✓ All prerequisites found" -ForegroundColor Green
Write-Host ""

# Verify AWS credentials
Write-Host "Verifying AWS credentials..." -ForegroundColor Yellow
$identity = aws sts get-caller-identity 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS credentials not configured." -ForegroundColor Red
    Write-Host "Please configure AWS CLI with your Learner Lab credentials:" -ForegroundColor Yellow
    Write-Host "  aws configure" -ForegroundColor Cyan
    exit 1
}
Write-Host "✓ AWS credentials verified" -ForegroundColor Green
Write-Host ""

# Build applications
Write-Host "Building applications..." -ForegroundColor Yellow

# Build frontend
Write-Host "  Building frontend..." -ForegroundColor Cyan
Set-Location frontend
if (!(Test-Path "node_modules")) {
    npm install
}
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Frontend build failed" -ForegroundColor Red
    exit 1
}
Set-Location ..

# Build backend
Write-Host "  Building backend..." -ForegroundColor Cyan
Set-Location backend
if (!(Test-Path "node_modules")) {
    npm install
}
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Backend build failed" -ForegroundColor Red
    exit 1
}
Set-Location ..

Write-Host "✓ Applications built successfully" -ForegroundColor Green
Write-Host ""

# Deploy infrastructure
Write-Host "Deploying infrastructure with Terraform..." -ForegroundColor Yellow
Set-Location infrastructure/learner-lab

terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform init failed" -ForegroundColor Red
    exit 1
}

terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform plan failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Review the plan above. Press Enter to apply or Ctrl+C to cancel..." -ForegroundColor Yellow
Read-Host

terraform apply tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform apply failed" -ForegroundColor Red
    exit 1
}

# Get outputs
$publicIp = terraform output -raw public_ip
$instanceId = terraform output -raw instance_id

Set-Location ../..

Write-Host "✓ Infrastructure deployed" -ForegroundColor Green
Write-Host "  Instance ID: $instanceId" -ForegroundColor Cyan
Write-Host "  Public IP: $publicIp" -ForegroundColor Cyan
Write-Host ""

# Wait for instance to be ready
Write-Host "Waiting for instance to be ready (this may take 2-3 minutes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

# Deploy application files
Write-Host "Deploying application files..." -ForegroundColor Yellow

# Create deployment package
Write-Host "  Creating deployment package..." -ForegroundColor Cyan
$tempDir = "temp-deploy"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy frontend build
Copy-Item -Recurse frontend/dist "$tempDir/frontend-dist"

# Copy backend build and dependencies
Copy-Item -Recurse backend/dist "$tempDir/backend-dist"
Copy-Item backend/package.json "$tempDir/"
Copy-Item backend/package-lock.json "$tempDir/" -ErrorAction SilentlyContinue

# Create deployment script
$deployScript = @"
#!/bin/bash
set -e

echo "Deploying application..."

# Stop backend service if running
sudo systemctl stop todo-backend 2>/dev/null || true

# Create directories
sudo mkdir -p /opt/todo-app/frontend/dist
sudo mkdir -p /opt/todo-app/backend

# Deploy frontend
sudo rm -rf /opt/todo-app/frontend/dist/*
sudo cp -r /tmp/deploy/frontend-dist/* /opt/todo-app/frontend/dist/

# Deploy backend
sudo rm -rf /opt/todo-app/backend/dist
sudo cp -r /tmp/deploy/backend-dist /opt/todo-app/backend/dist
sudo cp /tmp/deploy/package*.json /opt/todo-app/backend/

# Install backend dependencies
cd /opt/todo-app/backend
sudo npm install --production

# Set permissions
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Start backend service
sudo systemctl daemon-reload
sudo systemctl start todo-backend
sudo systemctl enable todo-backend

# Restart nginx
sudo systemctl restart nginx

echo "Deployment complete!"
"@

Set-Content -Path "$tempDir/deploy.sh" -Value $deployScript

# Upload to EC2
Write-Host "  Uploading files to EC2..." -ForegroundColor Cyan
$keyPath = "labsuser.pem"
if (!(Test-Path $keyPath)) {
    Write-Host "WARNING: Key file '$keyPath' not found." -ForegroundColor Yellow
    Write-Host "Please ensure you have the correct key file for SSH access." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual deployment steps:" -ForegroundColor Cyan
    Write-Host "1. Download your key pair from AWS Learner Lab" -ForegroundColor White
    Write-Host "2. Run: scp -i your-key.pem -r $tempDir ec2-user@${publicIp}:/tmp/deploy" -ForegroundColor White
    Write-Host "3. Run: ssh -i your-key.pem ec2-user@${publicIp} 'bash /tmp/deploy/deploy.sh'" -ForegroundColor White
} else {
    # Upload files
    scp -i $keyPath -o StrictHostKeyChecking=no -r $tempDir "ec2-user@${publicIp}:/tmp/deploy"
    
    # Run deployment script
    ssh -i $keyPath -o StrictHostKeyChecking=no "ec2-user@${publicIp}" "bash /tmp/deploy/deploy.sh"
    
    Write-Host "✓ Application deployed" -ForegroundColor Green
}

# Cleanup
Remove-Item -Recurse -Force $tempDir

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is now running at:" -ForegroundColor Cyan
Write-Host "  Frontend: http://$publicIp" -ForegroundColor White
Write-Host "  Backend API: http://${publicIp}:3001" -ForegroundColor White
Write-Host ""
Write-Host "To check status:" -ForegroundColor Yellow
Write-Host "  ssh -i $keyPath ec2-user@$publicIp" -ForegroundColor White
Write-Host "  sudo systemctl status todo-backend" -ForegroundColor White
Write-Host "  sudo systemctl status nginx" -ForegroundColor White
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "  sudo journalctl -u todo-backend -f" -ForegroundColor White
Write-Host ""
