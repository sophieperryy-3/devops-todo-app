#!/bin/bash

# Update system
yum update -y

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install Git
yum install -y git

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create application directory
mkdir -p /opt/todo-app
cd /opt/todo-app

# Clone the application (this would be your GitHub repo in real deployment)
# For demo purposes, we'll create the app structure
mkdir -p backend/src

# Create package.json
cat > backend/package.json << 'EOF'
{
  "name": "@local/todo-api",
  "version": "1.0.0",
  "description": "Backend API for Interactive To-Do List",
  "main": "dist/index.js",
  "scripts": {
    "start": "node dist/index.js",
    "build": "tsc"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5",
    "joi": "^17.11.0",
    "winston": "^3.11.0",
    "pg": "^8.11.3",
    "uuid": "^9.0.1",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/pg": "^8.10.7",
    "@types/uuid": "^9.0.7",
    "@types/node": "^20.9.0",
    "typescript": "^5.2.2"
  }
}
EOF

# Create TypeScript config
cat > backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true,
    "removeComments": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Create environment file
cat > backend/.env << EOF
NODE_ENV=production
PORT=3001
DB_HOST=${db_host}
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
LOG_LEVEL=info
FRONTEND_URL=*
EOF

# Install dependencies
cd backend
npm install

# Create a simple server (in real deployment, this would be from your repo)
mkdir -p src logs
cat > src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'production'
  });
});

app.get('/api/tasks', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: '1',
        title: 'Deploy to AWS',
        description: 'Successfully deployed to AWS using Terraform',
        completed: true,
        priority: 'high',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    ]
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'Interactive To-Do List API',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Create systemd service
cat > /etc/systemd/system/todo-app.service << EOF
[Unit]
Description=Interactive Todo App
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/todo-app/backend
Environment=NODE_ENV=production
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the service
systemctl daemon-reload
systemctl enable todo-app
systemctl start todo-app

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/todo-app/backend/logs/*.log",
            "log_group_name": "/aws/ec2/${project_name}",
            "log_stream_name": "{instance_id}/application"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${project_name}",
            "log_stream_name": "{instance_id}/system"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "TodoApp/EC2",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo "Todo app deployment completed successfully!"