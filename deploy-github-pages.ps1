# Simple GitHub Pages Deployment

Write-Host "=== Deploying to GitHub Pages ===" -ForegroundColor Cyan
Write-Host ""

# Build frontend
Write-Host "Building frontend..." -ForegroundColor Yellow
cd frontend
npm install
npm run build
cd ..

Write-Host "Frontend built!" -ForegroundColor Green
Write-Host ""

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your site will be available at:" -ForegroundColor Cyan
Write-Host "https://sophieperryy-3.github.io/devops-todo-app-1/" -ForegroundColor White
Write-Host ""
Write-Host "It may take 2-3 minutes to go live." -ForegroundColor Yellow
Write-Host ""
