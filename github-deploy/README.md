# Todo App Deployment Package

## Quick Deploy

Run this command on your EC2 instance:

\\\ash
bash deploy.sh
\\\

## What This Does

1. Stops the backend service if running
2. Copies frontend files to /opt/todo-app/frontend
3. Copies backend files to /opt/todo-app/backend
4. Installs Node.js dependencies
5. Starts the backend service
6. Restarts nginx

## After Deployment

Your app will be available at: http://YOUR-EC2-IP

## Troubleshooting

Check if services are running:
\\\ash
sudo systemctl status todo-backend
sudo systemctl status nginx
\\\

View backend logs:
\\\ash
sudo journalctl -u todo-backend -f
\\\

Restart services:
\\\ash
sudo systemctl restart todo-backend
sudo systemctl restart nginx
\\\
