#!/bin/bash
# Complete EC2 Setup and Deployment Script
# Run this directly on the EC2 instance

set -e

echo "========================================="
echo "  EC2 Instance Setup and Deployment"
echo "========================================="
echo ""

# Update system
echo "[1/6] Updating system..."
sudo yum update -y

# Install Node.js
echo ""
echo "[2/6] Installing Node.js..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install nginx
echo ""
echo "[3/6] Installing nginx..."
sudo amazon-linux-extras install nginx1 -y

# Install git
echo ""
echo "[4/6] Installing git..."
sudo yum install -y git

# Configure nginx
echo ""
echo "[5/6] Configuring nginx..."
sudo tee /etc/nginx/conf.d/todo-app.conf > /dev/null <<'EOF'
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
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location /health {
        proxy_pass http://localhost:3001/health;
    }
}
EOF

# Create systemd service for backend
sudo tee /etc/systemd/system/todo-backend.service > /dev/null <<'EOF'
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

# Create app directories
sudo mkdir -p /opt/todo-app/frontend
sudo mkdir -p /opt/todo-app/backend
sudo chown -R ec2-user:ec2-user /opt/todo-app

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo ""
echo "[6/6] Setup complete!"
echo ""
echo "========================================="
echo "  Ready for Application Deployment"
echo "========================================="
echo ""
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "nginx status: $(sudo systemctl is-active nginx)"
echo ""
echo "Next: Upload your application files"
echo ""
