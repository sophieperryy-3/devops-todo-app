# AWS Learner Lab - Complete Deployment Script
# This script deploys the entire application to AWS

param(
    [string]$KeyFile = "",
    [switch]$UseS3 = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AWS Learner Lab Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Step 1: Verify Prerequisites
Write-Host "[1/8] Checking prerequisites..." -ForegroundColor Yellow

if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: AWS CLI not found" -ForegroundColor Red
    Write-Host "Run: .\scripts\install-aws-cli-user.ps1" -ForegroundColor Yellow
    exit 1
}

if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Terraform not found" -ForegroundColor Red
    Write-Host "Run: .\scripts\install-terraform-user.ps1" -ForegroundColor Yellow
    exit 1
}

if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js not found" -ForegroundColor Red
    exit 1
}

Write-Host "  All tools found" -ForegroundColor Green

# Step 2: Verify AWS Credentials
Write-Host ""
Write-Host "[2/8] Verifying AWS credentials..." -ForegroundColor Yellow

$identity = aws sts get-caller-identity 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS credentials not configured" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please set your credentials first:" -ForegroundColor Yellow
    Write-Host '  $env:AWS_ACCESS_KEY_ID="your-key"' -ForegroundColor Cyan
    Write-Host '  $env:AWS_SECRET_ACCESS_KEY="your-secret"' -ForegroundColor Cyan
    Write-Host '  $env:AWS_SESSION_TOKEN="your-token"' -ForegroundColor Cyan
    Write-Host '  $env:AWS_DEFAULT_REGION="us-east-1"' -ForegroundColor Cyan
    exit 1
}

Write-Host "  Credentials verified" -ForegroundColor Green
Write-Host "  Account: $($identity | ConvertFrom-Json | Select-Object -ExpandProperty Account)" -ForegroundColor Cyan

# Step 3: Build Frontend
Write-Host ""
Write-Host "[3/8] Building frontend..." -ForegroundColor Yellow

Set-Location frontend
if (!(Test-Path "node_modules")) {
    Write-Host "  Installing dependencies..." -ForegroundColor Cyan
    npm install --silent
}
Write-Host "  Building..." -ForegroundColor Cyan
npm run build --silent
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Frontend build failed" -ForegroundColor Red
    exit 1
}
Set-Location ..

Write-Host "  Frontend built successfully" -ForegroundColor Green

# Step 4: Build Backend
Write-Host ""
Write-Host "[4/8] Building backend..." -ForegroundColor Yellow

Set-Location backend
if (!(Test-Path "node_modules")) {
    Write-Host "  Installing dependencies..." -ForegroundColor Cyan
    npm install --silent
}
Write-Host "  Building..." -ForegroundColor Cyan
npm run build --silent
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Backend build failed" -ForegroundColor Red
    exit 1
}
Set-Location ..

Write-Host "  Backend built successfully" -ForegroundColor Green

# Step 5: Deploy Infrastructure
Write-Host ""
Write-Host "[5/8] Deploying infrastructure with Terraform..." -ForegroundColor Yellow

Set-Location infrastructure/learner-lab

Write-Host "  Initializing Terraform..." -ForegroundColor Cyan
terraform init -input=false | Out-Null

Write-Host "  Planning deployment..." -ForegroundColor Cyan
terraform plan -out=tfplan -input=false | Out-Null

Write-Host "  Creating EC2 instance (this takes 2-3 minutes)..." -ForegroundColor Cyan
terraform apply -auto-approve -input=false

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform deployment failed" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

# Get outputs
$publicIp = terraform output -raw public_ip
$instanceId = terraform output -raw instance_id

Set-Location ../..

Write-Host "  Infrastructure deployed" -ForegroundColor Green
Write-Host "  Instance ID: $instanceId" -ForegroundColor Cyan
Write-Host "  Public IP: $publicIp" -ForegroundColor Cyan

# Step 6: Create Deployment Package
Write-Host ""
Write-Host "[6/8] Creating deployment package..." -ForegroundColor Yellow

$tempDir = "temp-deploy"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

Copy-Item -Recurse frontend/dist "$tempDir/frontend-dist"
Copy-Item -Recurse backend/dist "$tempDir/backend-dist"
Copy-Item backend/package.json "$tempDir/"
if (Test-Path backend/package-lock.json) {
    Copy-Item backend/package-lock.json "$tempDir/"
}

Write-Host "  Package created" -ForegroundColor Green

# Step 7: Wait for Instance
Write-Host ""
Write-Host "[7/8] Waiting for EC2 instance to be ready..." -ForegroundColor Yellow
Write-Host "  This takes about 2 minutes..." -ForegroundColor Cyan

Start-Sleep -Seconds 120

# Step 8: Deploy Application
Write-Host ""
Write-Host "[8/8] Deploying application..." -ForegroundColor Yellow

# Check if we should use S3 or SCP
if ($UseS3 -or $KeyFile -eq "") {
    Write-Host "  Using S3 for file transfer..." -ForegroundColor Cyan
    
    # Create S3 bucket
    $bucketName = "todo-deploy-$(Get-Random -Maximum 99999)"
    aws s3 mb "s3://$bucketName" 2>&1 | Out-Null
    
    # Upload files
    Write-Host "  Uploading to S3..." -ForegroundColor Cyan
    aws s3 cp $tempDir "s3://$bucketName/deploy/" --recursive --quiet
    
    Write-Host ""
    Write-Host "Files uploaded to S3 bucket: $bucketName" -ForegroundColor Green
    Write-Host ""
    Write-Host "MANUAL STEP REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Go to AWS Console -> EC2 -> Instances" -ForegroundColor White
    Write-Host "2. Select your instance: $instanceId" -ForegroundColor White
    Write-Host "3. Click 'Connect' -> 'EC2 Instance Connect' -> 'Connect'" -ForegroundColor White
    Write-Host "4. In the browser terminal, copy and paste these commands:" -ForegroundColor White
    Write-Host ""
    Write-Host "aws s3 cp s3://$bucketName/deploy /tmp/deploy --recursive" -ForegroundColor Cyan
    Write-Host "sudo systemctl stop todo-backend 2>/dev/null || true" -ForegroundColor Cyan
    Write-Host "sudo mkdir -p /opt/todo-app/frontend/dist /opt/todo-app/backend" -ForegroundColor Cyan
    Write-Host "sudo cp -r /tmp/deploy/frontend-dist/* /opt/todo-app/frontend/dist/" -ForegroundColor Cyan
    Write-Host "sudo cp -r /tmp/deploy/backend-dist /opt/todo-app/backend/dist" -ForegroundColor Cyan
    Write-Host "sudo cp /tmp/deploy/package*.json /opt/todo-app/backend/" -ForegroundColor Cyan
    Write-Host "cd /opt/todo-app/backend && sudo npm install --production" -ForegroundColor Cyan
    Write-Host "sudo chown -R ec2-user:ec2-user /opt/todo-app" -ForegroundColor Cyan
    Write-Host "sudo systemctl start todo-backend && sudo systemctl enable todo-backend" -ForegroundColor Cyan
    Write-Host "sudo systemctl restart nginx" -ForegroundColor Cyan
    Write-Host "echo 'Deployment complete!'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After running these commands, clean up S3:" -ForegroundColor Yellow
    Write-Host "aws s3 rb s3://$bucketName --force" -ForegroundColor Cyan
    
} else {
    Write-Host "  Using SCP for file transfer..." -ForegroundColor Cyan
    
    if (!(Test-Path $KeyFile)) {
        Write-Host "ERROR: Key file not found: $KeyFile" -ForegroundColor Red
        exit 1
    }
    
    # Upload files
    Write-Host "  Uploading files to EC2..." -ForegroundColor Cyan
    scp -i $KeyFile -o StrictHostKeyChecking=no -r $tempDir "ec2-user@${publicIp}:/tmp/" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: File upload failed" -ForegroundColor Red
        Write-Host "Try using -UseS3 flag instead" -ForegroundColor Yellow
        exit 1
    }
    
    # Deploy on EC2
    Write-Host "  Configuring application on EC2..." -ForegroundColor Cyan
    
    $deployCommands = @"
sudo systemctl stop todo-backend 2>/dev/null || true
sudo mkdir -p /opt/todo-app/frontend/dist /opt/todo-app/backend
sudo rm -rf /opt/todo-app/frontend/dist/*
sudo cp -r /tmp/$tempDir/frontend-dist/* /opt/todo-app/frontend/dist/
sudo rm -rf /opt/todo-app/backend/dist
sudo cp -r /tmp/$tempDir/backend-dist /opt/todo-app/backend/dist
sudo cp /tmp/$tempDir/package*.json /opt/todo-app/backend/
cd /opt/todo-app/backend && sudo npm install --production
sudo chown -R ec2-user:ec2-user /opt/todo-app
sudo systemctl daemon-reload
sudo systemctl start todo-backend
sudo systemctl enable todo-backend
sudo systemctl restart nginx
echo 'Deployment complete!'
"@
    
    ssh -i $KeyFile -o StrictHostKeyChecking=no "ec2-user@${publicIp}" $deployCommands
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Deployment commands may have failed" -ForegroundColor Yellow
    } else {
        Write-Host "  Application deployed successfully" -ForegroundColor Green
    }
}

# Cleanup
Remove-Item -Recurse -Force $tempDir

# Final Output
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is running at:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Frontend:    http://$publicIp" -ForegroundColor White
Write-Host "  Backend API: http://${publicIp}:3001" -ForegroundColor White
Write-Host ""
Write-Host "Open the frontend URL in your browser to test!" -ForegroundColor Yellow
Write-Host ""

if ($KeyFile -ne "") {
    Write-Host "To check status, SSH into the instance:" -ForegroundColor Cyan
    Write-Host "  ssh -i $KeyFile ec2-user@$publicIp" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run:" -ForegroundColor Cyan
    Write-Host "  sudo systemctl status todo-backend" -ForegroundColor White
    Write-Host "  sudo systemctl status nginx" -ForegroundColor White
    Write-Host "  sudo journalctl -u todo-backend -n 50" -ForegroundColor White
}

Write-Host ""
Write-Host "To destroy resources when done:" -ForegroundColor Yellow
Write-Host "  cd infrastructure/learner-lab" -ForegroundColor White
Write-Host "  terraform destroy -auto-approve" -ForegroundColor White
Write-Host ""
