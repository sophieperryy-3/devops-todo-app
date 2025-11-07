# Deploy Application Files to Existing EC2 Instance
# Use this when infrastructure is already created

Write-Host ""
Write-Host "=== Deploying Application to EC2 ===" -ForegroundColor Cyan
Write-Host ""

# Get instance details
Set-Location infrastructure/learner-lab
$publicIp = terraform output -raw public_ip
$instanceId = terraform output -raw instance_id
Set-Location ../..

Write-Host "Target Instance: $instanceId" -ForegroundColor Cyan
Write-Host "Public IP: $publicIp" -ForegroundColor Cyan
Write-Host ""

# Build applications
Write-Host "[1/4] Building frontend..." -ForegroundColor Yellow
Set-Location frontend
if (!(Test-Path "dist")) {
    npm install --silent
    npm run build --silent
}
Set-Location ..
Write-Host "  Frontend ready" -ForegroundColor Green

Write-Host ""
Write-Host "[2/4] Building backend..." -ForegroundColor Yellow
Set-Location backend
if (!(Test-Path "dist")) {
    npm install --silent
    npm run build --silent
}
Set-Location ..
Write-Host "  Backend ready" -ForegroundColor Green

# Create deployment package
Write-Host ""
Write-Host "[3/4] Creating deployment package..." -ForegroundColor Yellow
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

# Upload via S3
Write-Host ""
Write-Host "[4/4] Uploading to EC2 via S3..." -ForegroundColor Yellow

$bucketName = "todo-deploy-$(Get-Random -Maximum 99999)"
Write-Host "  Creating S3 bucket: $bucketName" -ForegroundColor Cyan
aws s3 mb "s3://$bucketName" 2>&1 | Out-Null

Write-Host "  Uploading files..." -ForegroundColor Cyan
aws s3 cp $tempDir "s3://$bucketName/deploy/" --recursive --quiet

Write-Host "  Files uploaded" -ForegroundColor Green

# Cleanup local temp
Remove-Item -Recurse -Force $tempDir

Write-Host ""
Write-Host "=== FINAL STEP ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Connect to your EC2 instance and run these commands:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to AWS Console -> EC2 -> Instances" -ForegroundColor White
Write-Host "2. Select instance: $instanceId" -ForegroundColor White
Write-Host "3. Click 'Connect' -> 'EC2 Instance Connect' -> 'Connect'" -ForegroundColor White
Write-Host "4. Copy and paste ALL these commands in the terminal:" -ForegroundColor White
Write-Host ""
Write-Host "--- COPY FROM HERE ---" -ForegroundColor Yellow
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
Write-Host "aws s3 rb s3://$bucketName --force" -ForegroundColor Cyan
Write-Host "--- COPY UNTIL HERE ---" -ForegroundColor Yellow
Write-Host ""
Write-Host "After running these commands, your app will be live at:" -ForegroundColor Green
Write-Host "  http://$publicIp" -ForegroundColor White
Write-Host ""
