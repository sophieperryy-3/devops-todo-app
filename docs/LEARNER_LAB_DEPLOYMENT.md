# AWS Learner Lab Deployment Guide

This guide is specifically for deploying the Interactive To-Do List application to AWS Learner Lab, which has certain restrictions compared to regular AWS accounts.

## 🎯 Overview

This deployment uses a simplified architecture suitable for AWS Learner Lab:
- **Single EC2 instance** running both frontend and backend
- **Nginx** serving frontend static files and proxying API requests
- **In-memory database** (no RDS to reduce costs)
- **Elastic IP** for stable public access

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│         EC2 Instance (t2.micro)     │
│                                     │
│  ┌──────────┐      ┌────────────┐  │
│  │  Nginx   │──────│  Frontend  │  │
│  │  (Port   │      │  (Static)  │  │
│  │   80)    │      └────────────┘  │
│  └──────────┘                       │
│       │                             │
│       │ (proxy)                     │
│       ▼                             │
│  ┌──────────┐                       │
│  │ Backend  │                       │
│  │ Node.js  │                       │
│  │ (Port    │                       │
│  │  3001)   │                       │
│  └──────────┘                       │
│       │                             │
│       ▼                             │
│  ┌──────────┐                       │
│  │ In-Memory│                       │
│  │ Database │                       │
│  └──────────┘                       │
└─────────────────────────────────────┘
```

## 📋 Prerequisites

1. **AWS Learner Lab Access**
   - Active AWS Academy Learner Lab session
   - AWS CLI credentials configured

2. **Local Tools**
   - AWS CLI installed and configured
   - Terraform >= 1.0
   - Node.js >= 18
   - PowerShell (Windows) or Bash (Linux/Mac)

3. **Key Pair**
   - Download your `labsuser.pem` or `vockey.pem` from Learner Lab
   - Save it in the project root directory

## 🚀 Quick Deployment

### Step 1: Start AWS Learner Lab

1. Go to your AWS Academy course
2. Click on "Modules" → "Learner Lab"
3. Click "Start Lab" and wait for it to turn green
4. Click "AWS Details" → "Show" to see credentials

### Step 2: Configure AWS CLI

```powershell
# Set AWS credentials from Learner Lab
$env:AWS_ACCESS_KEY_ID="your-access-key"
$env:AWS_SECRET_ACCESS_KEY="your-secret-key"
$env:AWS_SESSION_TOKEN="your-session-token"
$env:AWS_DEFAULT_REGION="us-east-1"

# Verify credentials
aws sts get-caller-identity
```

### Step 3: Run Deployment Script

```powershell
# Make sure you're in the project root
.\scripts\deploy-learner-lab.ps1
```

The script will:
1. ✅ Check prerequisites
2. ✅ Build frontend and backend
3. ✅ Deploy infrastructure with Terraform
4. ✅ Upload application files to EC2
5. ✅ Configure and start services

### Step 4: Access Your Application

After deployment completes, you'll see:
```
Frontend: http://YOUR-PUBLIC-IP
Backend API: http://YOUR-PUBLIC-IP:3001
```

Open the frontend URL in your browser to use the application!

## 🔧 Manual Deployment (If Script Fails)

### 1. Deploy Infrastructure

```powershell
cd infrastructure/learner-lab

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply (creates EC2 instance)
terraform apply

# Get public IP
$publicIp = terraform output -raw public_ip
Write-Host "Public IP: $publicIp"

cd ../..
```

### 2. Build Applications

```powershell
# Build frontend
cd frontend
npm install
npm run build
cd ..

# Build backend
cd backend
npm install
npm run build
cd ..
```

### 3. Deploy to EC2

```powershell
# Set your public IP
$publicIp = "YOUR-EC2-PUBLIC-IP"
$keyFile = "labsuser.pem"

# Create deployment package
mkdir temp-deploy
Copy-Item -Recurse frontend/dist temp-deploy/frontend-dist
Copy-Item -Recurse backend/dist temp-deploy/backend-dist
Copy-Item backend/package*.json temp-deploy/

# Upload to EC2
scp -i $keyFile -r temp-deploy "ec2-user@${publicIp}:/tmp/deploy"

# SSH into EC2 and deploy
ssh -i $keyFile "ec2-user@${publicIp}"
```

### 4. On EC2 Instance

```bash
# Stop backend if running
sudo systemctl stop todo-backend 2>/dev/null || true

# Create directories
sudo mkdir -p /opt/todo-app/frontend/dist
sudo mkdir -p /opt/todo-app/backend

# Deploy frontend
sudo cp -r /tmp/deploy/frontend-dist/* /opt/todo-app/frontend/dist/

# Deploy backend
sudo cp -r /tmp/deploy/backend-dist /opt/todo-app/backend/dist
sudo cp /tmp/deploy/package*.json /opt/todo-app/backend/

# Install dependencies
cd /opt/todo-app/backend
sudo npm install --production

# Set permissions
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Start services
sudo systemctl start todo-backend
sudo systemctl enable todo-backend
sudo systemctl restart nginx

# Check status
sudo systemctl status todo-backend
sudo systemctl status nginx
```

## 🔍 Troubleshooting

### Check Service Status

```bash
# SSH into EC2
ssh -i labsuser.pem ec2-user@YOUR-PUBLIC-IP

# Check backend service
sudo systemctl status todo-backend

# Check nginx
sudo systemctl status nginx

# View backend logs
sudo journalctl -u todo-backend -f

# View nginx logs
sudo tail -f /var/log/nginx/error.log
```

### Common Issues

#### 1. Cannot Connect to EC2

**Problem**: SSH connection refused or timeout

**Solution**:
- Verify security group allows port 22 (SSH)
- Check that you're using the correct key file
- Ensure Learner Lab session is still active (green)

```powershell
# Check security group
aws ec2 describe-security-groups --group-ids YOUR-SG-ID
```

#### 2. Frontend Not Loading

**Problem**: Getting 404 or blank page

**Solution**:
```bash
# Check nginx configuration
sudo nginx -t

# Check frontend files
ls -la /opt/todo-app/frontend/dist/

# Restart nginx
sudo systemctl restart nginx
```

#### 3. Backend API Not Working

**Problem**: API calls failing or 502 errors

**Solution**:
```bash
# Check if backend is running
sudo systemctl status todo-backend

# Check backend logs
sudo journalctl -u todo-backend -n 50

# Restart backend
sudo systemctl restart todo-backend

# Test backend directly
curl http://localhost:3001/health
```

#### 4. Learner Lab Session Expired

**Problem**: AWS credentials stopped working

**Solution**:
- Go back to Learner Lab and click "Start Lab"
- Get new credentials from "AWS Details"
- Re-run the deployment script with new credentials

## 📊 Monitoring

### Check Application Health

```bash
# Health check
curl http://YOUR-PUBLIC-IP/health

# Test API
curl http://YOUR-PUBLIC-IP/api/tasks

# Check system resources
top
df -h
free -m
```

### View Logs

```bash
# Backend application logs
sudo journalctl -u todo-backend -f

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log

# System logs
sudo tail -f /var/log/messages
```

## 🧹 Cleanup

When you're done with the demo:

```powershell
cd infrastructure/learner-lab
terraform destroy
```

This will delete all AWS resources and stop incurring charges.

## 💡 Tips for Demo Presentation

1. **Before Demo**:
   - Deploy at least 30 minutes before presentation
   - Test all features work correctly
   - Note down the public IP address
   - Take screenshots as backup

2. **During Demo**:
   - Show the live application first
   - Then show the infrastructure in AWS Console
   - Demonstrate the CI/CD pipeline
   - Show logs and monitoring

3. **Backup Plan**:
   - Have screenshots ready
   - Run locally with Docker if AWS fails
   - Record a video beforehand

## 🔗 Related Documentation

- [Main Deployment Guide](./DEPLOYMENT.md)
- [Demo Script](./DEMO_SCRIPT.md)
- [Quick Setup Guide](../QUICK_SETUP.md)

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the logs on EC2 instance
3. Verify Learner Lab session is active
4. Ensure all prerequisites are installed
