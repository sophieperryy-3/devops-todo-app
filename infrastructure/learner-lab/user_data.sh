#!/bin/bash
set -e

# Update system
dnf update -y

# Install Node.js 18
dnf install -y nodejs npm

# Install nginx
dnf install -y nginx

# Install git
dnf install -y git

# Create app directory
mkdir -p /opt/todo-app
cd /opt/todo-app

# Clone or setup application (placeholder - will be deployed separately)
echo "Application will be deployed via deployment script"

# Configure nginx
cat > /etc/nginx/conf.d/todo-app.conf <<'EOF'
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        root /opt/todo-app/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API proxy
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

    # Health check
    location /health {
        proxy_pass http://localhost:3001/health;
    }
}
EOF

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Create systemd service for backend
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

# Set permissions
chown -R ec2-user:ec2-user /opt/todo-app

echo "Setup complete. Ready for application deployment."
