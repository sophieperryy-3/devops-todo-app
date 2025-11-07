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
