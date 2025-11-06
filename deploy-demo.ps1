# Interactive To-Do App - Demo Deployment Script
# This script demonstrates DevOps pipeline for your assignment

Write-Host "🚀 Interactive To-Do App - DevOps Demonstration" -ForegroundColor Blue
Write-Host "=================================================" -ForegroundColor Blue

# Check prerequisites
Write-Host "`n📋 Checking Prerequisites..." -ForegroundColor Yellow

# Check AWS CLI
try {
    $awsVersion = aws --version 2>$null
    Write-Host "✅ AWS CLI: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Check Terraform
try {
    $terraformVersion = terraform --version | Select-Object -First 1
    Write-Host "✅ Terraform: $terraformVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform not found. Please install Terraform first." -ForegroundColor Red
    exit 1
}

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js first." -ForegroundColor Red
    exit 1
}

# Check AWS credentials
Write-Host "`n🔑 Checking AWS Credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    Write-Host "✅ AWS Account: $($identity.Account)" -ForegroundColor Green
    Write-Host "✅ AWS User: $($identity.Arn)" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not configured." -ForegroundColor Red
    Write-Host "Please run: aws configure" -ForegroundColor Yellow
    Write-Host "You'll need:" -ForegroundColor Yellow
    Write-Host "  - AWS Access Key ID" -ForegroundColor Yellow
    Write-Host "  - AWS Secret Access Key" -ForegroundColor Yellow
    Write-Host "  - Default region (e.g., us-east-1)" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n🎯 All prerequisites met! Ready for deployment." -ForegroundColor Green

# Build applications
Write-Host "`n🔨 Building Applications..." -ForegroundColor Yellow

Write-Host "Installing dependencies..."
npm install

Write-Host "Building frontend..."
Set-Location frontend
npm install
npm run build
Set-Location ..

Write-Host "Building backend..."
Set-Location backend
npm install
npm run build
Set-Location ..

Write-Host "✅ Applications built successfully!" -ForegroundColor Green

# Initialize Terraform
Write-Host "`n🏗️ Initializing Infrastructure..." -ForegroundColor Yellow
Set-Location infrastructure

Write-Host "Initializing Terraform..."
terraform init

Write-Host "Validating Terraform configuration..."
terraform validate

Write-Host "✅ Infrastructure ready for deployment!" -ForegroundColor Green

Set-Location ..

# GitHub setup instructions
Write-Host "`n📚 GitHub Setup Instructions" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue

Write-Host "`nTo demonstrate the CI/CD pipeline:" -ForegroundColor Yellow
Write-Host "1. Create a new GitHub repository" -ForegroundColor White
Write-Host "2. Push this code to your repository:" -ForegroundColor White
Write-Host "   git init" -ForegroundColor Cyan
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'Initial commit: DevOps Todo App'" -ForegroundColor Cyan
Write-Host "   git branch -M main" -ForegroundColor Cyan
Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor Cyan
Write-Host "   git push -u origin main" -ForegroundColor Cyan

Write-Host "`n3. Configure GitHub Secrets (Settings > Secrets and variables > Actions):" -ForegroundColor White
Write-Host "   AWS_ACCESS_KEY_ID = [Your AWS Access Key]" -ForegroundColor Cyan
Write-Host "   AWS_SECRET_ACCESS_KEY = [Your AWS Secret Key]" -ForegroundColor Cyan
Write-Host "   DB_PASSWORD = todopass123!" -ForegroundColor Cyan

Write-Host "`n4. The CI/CD pipeline will automatically:" -ForegroundColor White
Write-Host "   ✅ Run tests on every commit" -ForegroundColor Green
Write-Host "   ✅ Perform security scanning" -ForegroundColor Green
Write-Host "   ✅ Deploy infrastructure with Terraform" -ForegroundColor Green
Write-Host "   ✅ Deploy applications to AWS" -ForegroundColor Green
Write-Host "   ✅ Run post-deployment health checks" -ForegroundColor Green

# Manual deployment option
Write-Host "`n🚀 Manual Deployment Option" -ForegroundColor Blue
Write-Host "============================" -ForegroundColor Blue

$deploy = Read-Host "`nWould you like to deploy manually now for testing? (y/N)"

if ($deploy -eq 'y' -or $deploy -eq 'Y') {
    Write-Host "`n🚀 Starting manual deployment..." -ForegroundColor Yellow
    
    Set-Location infrastructure
    
    # Set environment variables
    $env:TF_VAR_environment = "demo"
    $env:TF_VAR_db_password = "todopass123!"
    
    Write-Host "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    $confirm = Read-Host "`nDo you want to apply this Terraform plan? (y/N)"
    
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        Write-Host "Applying Terraform configuration..."
        terraform apply tfplan
        
        Write-Host "`n🎉 Deployment completed!" -ForegroundColor Green
        
        # Get outputs
        try {
            $loadBalancerDns = terraform output -raw load_balancer_dns
            $frontendBucket = terraform output -raw frontend_bucket_name
            
            Write-Host "`n📊 Application URLs:" -ForegroundColor Blue
            Write-Host "Frontend: http://$frontendBucket.s3-website-us-east-1.amazonaws.com" -ForegroundColor Cyan
            Write-Host "Backend:  http://$loadBalancerDns" -ForegroundColor Cyan
            Write-Host "Health:   http://$loadBalancerDns/health" -ForegroundColor Cyan
            Write-Host "API:      http://$loadBalancerDns/api/tasks" -ForegroundColor Cyan
        } catch {
            Write-Host "Deployment in progress. URLs will be available shortly." -ForegroundColor Yellow
        }
    }
    
    Set-Location ..
}
    }
    
    Set-Location ..
}

Write-Host "`n🎓 DevOps Features Demonstrated:" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue
Write-Host "✅ Infrastructure as Code (Terraform)" -ForegroundColor Green
Write-Host "✅ CI/CD Pipeline (GitHub Actions)" -ForegroundColor Green
Write-Host "✅ Automated Testing (Jest, Cypress)" -ForegroundColor Green
Write-Host "✅ Security Scanning (npm audit, tfsec)" -ForegroundColor Green
Write-Host "✅ Containerization (Docker)" -ForegroundColor Green
Write-Host "✅ Cloud Deployment (AWS)" -ForegroundColor Green
Write-Host "✅ Monitoring & Logging (CloudWatch)" -ForegroundColor Green
Write-Host "✅ Auto Scaling & Load Balancing" -ForegroundColor Green
Write-Host "✅ Database Management (PostgreSQL)" -ForegroundColor Green

Write-Host "`n🎯 Ready for your DevOps demonstration!" -ForegroundColor Green
Write-Host "Your project showcases industry-standard DevOps practices." -ForegroundColor White