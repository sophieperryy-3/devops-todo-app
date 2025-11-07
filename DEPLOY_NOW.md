# Deploy to AWS Learner Lab - Quick Guide

Follow these steps in order. Copy and paste each command into PowerShell.

## Step 1: Set AWS Credentials

```powershell
# Get these from: AWS Academy -> Learner Lab -> AWS Details -> Show
$env:AWS_ACCESS_KEY_ID="paste-your-access-key-here"
$env:AWS_SECRET_ACCESS_KEY="paste-your-secret-key-here"
$env:AWS_SESSION_TOKEN="paste-your-session-token-here"
$env:AWS_DEFAULT_REGION="us-east-1"

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

## Step 2: Verify Credentials

```powershell
aws sts get-caller-identity
```

You should see your AWS account info. If not, check your credentials.

## Step 3: Build Frontend

```powershell
cd frontend
npm install
npm run build
cd ..
```

## Step 4: Build Backend

```powershell
cd backend
npm install
npm run build
cd ..
```

## Step 5: Deploy Infrastructure with Terraform

```powershell
cd infrastructure/learner-lab

# Initialize Terraform
terraform init

# Plan deployment (review what will be created)
terraform plan

# Apply deployment (creates EC2 instance)
terraform apply -auto-approve

# Get the public IP
$publicIp = terraform output -raw public_ip
Write-Host "Public IP: $publicIp" -ForegroundColor Green

cd ../..
```

## Step 6: Create Deployment Package

```powershell
# Create temp directory
$tempDir = "temp-deploy"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy frontend
Copy-Item -Recurse frontend/dist "$tempDir/frontend-dist"

# Copy backend
Copy-Item -Recurse backend/dist "$tempDir/backend-dist"
Copy-Item backend/package.json "$tempDir/"
Copy-Item backend/package-lock.json "$tempDir/" -ErrorAction SilentlyContinue

Write-Host "Deployment package created!" -ForegroundColor Green
```

## Step 7: Upload to EC2

### Option A: If you have the key file (vockey.pem or labsuser.pem)

```powershell
# Set your public IP from Step 5
$publicIp = "YOUR-EC2-PUBLIC-IP"
$keyFile = "vockey.pem"  # or "labsuser.pem"

# Wait for instance to be ready
Write-Host "Waiting for instance to initialize (2 minutes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

# Upload files
scp -i $keyFile -o StrictHostKeyChecking=no -r temp-deploy "ec2-user@${publicIp}:/tmp/"

# Deploy on EC2
ssh -i $keyFile -o StrictHostKeyChecking=no "ec2-user@${publicIp}" @"
sudo systemctl stop todo-backend 2>/dev/null || true
sudo mkdir -p /opt/todo-app/frontend/dist
sudo mkdir -p /opt/todo-app/backend
sudo rm -rf /opt/todo-app/frontend/dist/*
sudo cp -r /tmp/temp-deploy/frontend-dist/* /opt/todo-app/frontend/dist/
sudo rm -rf /opt/todo-app/backend/dist
sudo cp -r /tmp/temp-deploy/backend-dist /opt/todo-app/backend/dist
sudo cp /tmp/temp-deploy/package*.json /opt/todo-app/backend/
cd /opt/todo-app/backend
sudo npm install --production
sudo chown -R ec2-user:ec2-user /opt/todo-app
sudo systemctl daemon-reload
sudo systemctl start todo-backend
sudo systemctl enable todo-backend
sudo systemctl restart nginx
echo 'Deployment complete!'
"@
```

### Option B: If you don't have the key file - Use S3

```powershell
# Create S3 bucket for deployment
$bucketName = "todo-deploy-$(Get-Random -Maximum 9999)"
aws s3 mb "s3://$bucketName"

# Upload deployment package
aws s3 cp temp-deploy "s3://$bucketName/deploy/" --recursive

Write-Host "Files uploaded to S3: $bucketName" -ForegroundColor Green
Write-Host ""
Write-Host "Now connect to EC2 via AWS Console (Instance Connect) and run:" -ForegroundColor Cyan
Write-Host ""
Write-Host "aws s3 cp s3://$bucketName/deploy /tmp/deploy --recursive" -ForegroundColor White
Write-Host "sudo systemctl stop todo-backend 2>/dev/null || true" -ForegroundColor White
Write-Host "sudo mkdir -p /opt/todo-app/frontend/dist" -ForegroundColor White
Write-Host "sudo mkdir -p /opt/todo-app/backend" -ForegroundColor White
Write-Host "sudo cp -r /tmp/deploy/frontend-dist/* /opt/todo-app/frontend/dist/" -ForegroundColor White
Write-Host "sudo cp -r /tmp/deploy/backend-dist /opt/todo-app/backend/dist" -ForegroundColor White
Write-Host "sudo cp /tmp/deploy/package*.json /opt/todo-app/backend/" -ForegroundColor White
Write-Host "cd /opt/todo-app/backend && sudo npm install --production" -ForegroundColor White
Write-Host "sudo chown -R ec2-user:ec2-user /opt/todo-app" -ForegroundColor White
Write-Host "sudo systemctl start todo-backend && sudo systemctl enable todo-backend" -ForegroundColor White
Write-Host "sudo systemctl restart nginx" -ForegroundColor White
```

## Step 8: Access Your Application

```powershell
# Get your public IP
cd infrastructure/learner-lab
$publicIp = terraform output -raw public_ip
Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is running at:" -ForegroundColor Cyan
Write-Host "  http://$publicIp" -ForegroundColor White
Write-Host ""
Write-Host "Open this URL in your browser!" -ForegroundColor Yellow
```

## Troubleshooting

### Check if services are running (via Instance Connect in AWS Console)

```bash
sudo systemctl status todo-backend
sudo systemctl status nginx
sudo journalctl -u todo-backend -n 50
```

### Restart services

```bash
sudo systemctl restart todo-backend
sudo systemctl restart nginx
```

### Test backend directly

```bash
curl http://localhost:3001/health
```

## Cleanup (After Demo)

```powershell
cd infrastructure/learner-lab
terraform destroy -auto-approve
cd ../..

# If you created S3 bucket
aws s3 rb "s3://your-bucket-name" --force
```

---

## Quick Reference

**Your EC2 Public IP**: (Get from terraform output)
**Frontend URL**: http://YOUR-IP
**Backend API**: http://YOUR-IP:3001

**SSH Command**: `ssh -i vockey.pem ec2-user@YOUR-IP`
**Instance Connect**: AWS Console -> EC2 -> Connect -> EC2 Instance Connect
