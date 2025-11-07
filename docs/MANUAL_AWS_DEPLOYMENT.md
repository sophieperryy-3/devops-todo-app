# Manual AWS Learner Lab Deployment (No CLI Required)

This guide walks you through deploying the application using only the AWS Console - no CLI or Terraform needed!

## 🎯 Overview

We'll create everything manually through the AWS Console:
1. Launch an EC2 instance
2. Configure security groups
3. Upload and run the application

## 📋 Step 1: Launch EC2 Instance

1. **Go to AWS Console**
   - In Learner Lab, click "AWS" button to open console
   - Navigate to EC2 service

2. **Launch Instance**
   - Click "Launch Instance"
   - **Name**: `interactive-todo-app`
   - **AMI**: Amazon Linux 2 AMI (HVM)
   - **Instance Type**: t2.micro (free tier)
   - **Key Pair**: Select `vockey` (or create new if needed)
   
3. **Network Settings**
   - Click "Edit" on Network settings
   - **Auto-assign public IP**: Enable
   - **Firewall (security groups)**: Create new security group
   - **Security group name**: `todo-app-sg`
   - Add these rules:
     - SSH (22) - Source: Anywhere (0.0.0.0/0)
     - HTTP (80) - Source: Anywhere (0.0.0.0/0)
     - Custom TCP (3001) - Source: Anywhere (0.0.0.0/0)

4. **Storage**: 20 GB gp2 (default is fine)

5. **Advanced Details** - User Data (paste this):

```bash
#!/bin/bash
yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git nginx
amazon-linux-extras install nginx1 -y

mkdir -p /opt/todo-app
chown -R ec2-user:ec2-user /opt/todo-app

cat > /etc/nginx/conf.d/todo-app.conf <<'EOF'
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
EOF

systemctl start nginx
systemctl enable nginx

cat > /etc/systemd/system/todo-backend.service <<'EOF'
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
EOF

systemctl daemon-reload
```

6. **Launch Instance**
   - Click "Launch Instance"
   - Wait for instance to be running
   - Note the **Public IPv4 address**

## 📋 Step 2: Build Application Locally

Open PowerShell in your project directory:

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

# Create deployment package
mkdir deploy-package
Copy-Item -Recurse frontend/dist deploy-package/frontend
Copy-Item -Recurse backend/dist deploy-package/backend-dist
Copy-Item backend/package*.json deploy-package/
```

## 📋 Step 3: Upload Files to EC2

### Option A: Using SCP (if you have SSH client)

```powershell
# Replace with your instance's public IP
$publicIp = "YOUR-EC2-PUBLIC-IP"

# Upload files
scp -i vockey.pem -r deploy-package "ec2-user@${publicIp}:/tmp/"
```

### Option B: Using EC2 Instance Connect (Browser-based)

1. In AWS Console, go to your EC2 instance
2. Click "Connect" → "EC2 Instance Connect"
3. Click "Connect" (opens browser terminal)

4. In the browser terminal, run:
```bash
# We'll upload files using a different method
# First, let's prepare the directories
mkdir -p /opt/todo-app/frontend
mkdir -p /opt/todo-app/backend
```

5. **For small deployments**, you can use this workaround:
   - Create a GitHub repository (private or public)
   - Push your built files there
   - Clone on EC2:
   ```bash
   cd /tmp
   git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
   ```

### Option C: Using S3 as Transfer (Recommended for Learner Lab)

1. **Create S3 Bucket** (in AWS Console):
   - Go to S3 service
   - Create bucket: `todo-app-deploy-YOURNAME`
   - Keep all defaults (private bucket is fine)

2. **Upload from Local** (using AWS Console):
   - Open the bucket
   - Click "Upload"
   - Drag and drop your `deploy-package` folder
   - Click "Upload"

3. **Download on EC2**:
   ```bash
   # Connect to EC2 via Instance Connect
   
   # Download from S3
   aws s3 cp s3://todo-app-deploy-YOURNAME/deploy-package /tmp/deploy-package --recursive
   ```

## 📋 Step 4: Deploy on EC2

Connect to your EC2 instance (Instance Connect or SSH) and run:

```bash
# Navigate to deployment files
cd /tmp/deploy-package

# Deploy frontend
sudo cp -r frontend/* /opt/todo-app/frontend/

# Deploy backend
sudo mkdir -p /opt/todo-app/backend/dist
sudo cp -r backend-dist/* /opt/todo-app/backend/dist/
sudo cp package*.json /opt/todo-app/backend/

# Install backend dependencies
cd /opt/todo-app/backend
sudo npm install --production

# Set permissions
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Start backend service
sudo systemctl start todo-backend
sudo systemctl enable todo-backend

# Restart nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status todo-backend
sudo systemctl status nginx
```

## 📋 Step 5: Test Your Application

1. Open browser and go to: `http://YOUR-EC2-PUBLIC-IP`
2. You should see your todo application!
3. Test creating, completing, and deleting tasks

## 🔍 Troubleshooting

### Check Backend Status
```bash
sudo systemctl status todo-backend
sudo journalctl -u todo-backend -n 50
```

### Check Nginx Status
```bash
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

### Check if Backend is Running
```bash
curl http://localhost:3001/health
```

### Restart Services
```bash
sudo systemctl restart todo-backend
sudo systemctl restart nginx
```

### View Backend Logs
```bash
sudo journalctl -u todo-backend -f
```

## 🎓 For Your Demo

**What to Show**:
1. ✅ Live application running on AWS
2. ✅ EC2 instance in AWS Console
3. ✅ Security groups configuration
4. ✅ Application logs and monitoring
5. ✅ Creating and managing tasks

**Talking Points**:
- "Deployed on AWS EC2 with Amazon Linux 2"
- "Using Nginx as reverse proxy for frontend and API"
- "Systemd service for backend process management"
- "Security groups for network access control"
- "Auto-restart on failure for high availability"

## 🧹 Cleanup

When done with demo:
1. Go to EC2 Console
2. Select your instance
3. Instance State → Terminate Instance
4. Delete S3 bucket if created
5. Delete security group if needed

## 💡 Tips

- **Save your Public IP** - write it down for your presentation
- **Test before demo** - deploy at least 1 hour before presentation
- **Take screenshots** - in case something goes wrong during demo
- **Have backup** - run locally with Docker as fallback

## 📞 Quick Commands Reference

```bash
# Check everything is running
sudo systemctl status todo-backend nginx

# View logs
sudo journalctl -u todo-backend -f

# Restart everything
sudo systemctl restart todo-backend nginx

# Test backend
curl http://localhost:3001/health

# Check disk space
df -h

# Check memory
free -m

# Check processes
ps aux | grep node
```
