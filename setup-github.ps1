# GitHub Setup Script for DevOps Demo
Write-Host "🐙 GitHub Setup for DevOps Demonstration" -ForegroundColor Blue
Write-Host "=========================================" -ForegroundColor Blue

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "✅ Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git not found. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Initialize git repository
Write-Host "`n📁 Initializing Git repository..." -ForegroundColor Yellow

if (Test-Path ".git") {
    Write-Host "Git repository already exists." -ForegroundColor Yellow
} else {
    git init
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
}

# Create .gitignore if it doesn't exist
if (-not (Test-Path ".gitignore")) {
    Write-Host "Creating .gitignore..." -ForegroundColor Yellow
    
    @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build outputs
dist/
build/
*.tsbuildinfo

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Coverage reports
coverage/
.nyc_output/

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfplan

# AWS
.aws/
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
    
    Write-Host "✅ .gitignore created" -ForegroundColor Green
}

# Add all files
Write-Host "`n📦 Adding files to Git..." -ForegroundColor Yellow
git add .

# Check git status
Write-Host "`n📊 Git Status:" -ForegroundColor Yellow
git status --short

# Commit files
Write-Host "`n💾 Committing files..." -ForegroundColor Yellow
git commit -m "Initial commit: DevOps Interactive Todo App

Features:
- Full-stack React + Node.js application
- Infrastructure as Code with Terraform
- CI/CD pipeline with GitHub Actions
- Comprehensive testing strategy
- Security scanning and monitoring
- AWS cloud deployment ready

This project demonstrates modern DevOps practices including:
✅ Infrastructure as Code
✅ Automated CI/CD pipeline
✅ Security integration
✅ Monitoring and logging
✅ Auto scaling and load balancing
✅ Database management"

Write-Host "✅ Files committed successfully" -ForegroundColor Green

# Instructions for GitHub
Write-Host "`n🐙 GitHub Repository Setup" -ForegroundColor Blue
Write-Host "===========================" -ForegroundColor Blue

Write-Host "`n1. Create a new repository on GitHub:" -ForegroundColor Yellow
Write-Host "   - Go to https://github.com/new" -ForegroundColor White
Write-Host "   - Repository name: devops-todo-app (or your preferred name)" -ForegroundColor White
Write-Host "   - Description: DevOps demonstration with Interactive Todo App" -ForegroundColor White
Write-Host "   - Make it Public (for demonstration purposes)" -ForegroundColor White
Write-Host "   - Don't initialize with README (we already have files)" -ForegroundColor White

Write-Host "`n2. Connect your local repository to GitHub:" -ForegroundColor Yellow
$repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/username/devops-todo-app.git)"

if ($repoUrl) {
    Write-Host "`nSetting up remote origin..." -ForegroundColor Yellow
    git branch -M main
    git remote add origin $repoUrl
    
    Write-Host "`n🚀 Pushing to GitHub..." -ForegroundColor Yellow
    try {
        git push -u origin main
        Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
        
        Write-Host "`n🎯 Next Steps:" -ForegroundColor Blue
        Write-Host "1. Go to your GitHub repository: $repoUrl" -ForegroundColor White
        Write-Host "2. Navigate to Settings > Secrets and variables > Actions" -ForegroundColor White
        Write-Host "3. Add these repository secrets:" -ForegroundColor White
        Write-Host "   - AWS_ACCESS_KEY_ID" -ForegroundColor Cyan
        Write-Host "   - AWS_SECRET_ACCESS_KEY" -ForegroundColor Cyan
        Write-Host "   - DB_PASSWORD (use: todopass123!)" -ForegroundColor Cyan
        
        Write-Host "`n4. Make a small change to trigger the CI/CD pipeline:" -ForegroundColor White
        Write-Host "   - Edit README.md or any file" -ForegroundColor Cyan
        Write-Host "   - Commit and push the change" -ForegroundColor Cyan
        Write-Host "   - Watch the Actions tab for the pipeline execution" -ForegroundColor Cyan
        
        Write-Host "`n🎉 Your DevOps project is now on GitHub!" -ForegroundColor Green
        Write-Host "The CI/CD pipeline will automatically run on every push to main branch." -ForegroundColor White
        
    } catch {
        Write-Host "❌ Failed to push to GitHub. Please check:" -ForegroundColor Red
        Write-Host "   - Repository URL is correct" -ForegroundColor Yellow
        Write-Host "   - You have push access to the repository" -ForegroundColor Yellow
        Write-Host "   - Your Git credentials are configured" -ForegroundColor Yellow
        
        Write-Host "`nManual push command:" -ForegroundColor Yellow
        Write-Host "git push -u origin main" -ForegroundColor Cyan
    }
} else {
    Write-Host "`nManual setup commands:" -ForegroundColor Yellow
    Write-Host "git branch -M main" -ForegroundColor Cyan
    Write-Host "git remote add origin YOUR_REPO_URL" -ForegroundColor Cyan
    Write-Host "git push -u origin main" -ForegroundColor Cyan
}

Write-Host "`n📚 Documentation Available:" -ForegroundColor Blue
Write-Host "- README.md - Project overview and setup" -ForegroundColor White
Write-Host "- docs/DEPLOYMENT.md - Detailed deployment guide" -ForegroundColor White
Write-Host "- docs/DEMO_SCRIPT.md - 20-minute presentation script" -ForegroundColor White

Write-Host "`n🎓 Ready for your DevOps demonstration!" -ForegroundColor Green