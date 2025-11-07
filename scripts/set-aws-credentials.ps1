# Set AWS Learner Lab Credentials
# Get these from AWS Academy Learner Lab -> AWS Details -> Show

Write-Host "=== AWS Learner Lab Credentials Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Go to AWS Academy Learner Lab and click:" -ForegroundColor Yellow
Write-Host "  1. AWS Details" -ForegroundColor White
Write-Host "  2. Show (next to AWS CLI)" -ForegroundColor White
Write-Host "  3. Copy the credentials" -ForegroundColor White
Write-Host ""

$accessKey = Read-Host "Enter AWS_ACCESS_KEY_ID"
$secretKey = Read-Host "Enter AWS_SECRET_ACCESS_KEY"
$sessionToken = Read-Host "Enter AWS_SESSION_TOKEN"

$env:AWS_ACCESS_KEY_ID = $accessKey
$env:AWS_SECRET_ACCESS_KEY = $secretKey
$env:AWS_SESSION_TOKEN = $sessionToken
$env:AWS_DEFAULT_REGION = "us-east-1"

Write-Host ""
Write-Host "Verifying credentials..." -ForegroundColor Yellow

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

try {
    $identity = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Credentials verified successfully!" -ForegroundColor Green
        Write-Host $identity
        Write-Host ""
        Write-Host "You can now run the deployment:" -ForegroundColor Cyan
        Write-Host "  .\scripts\deploy-learner-lab.ps1" -ForegroundColor White
    } else {
        Write-Host "Credential verification failed" -ForegroundColor Red
        Write-Host $identity
    }
} catch {
    Write-Host "Error verifying credentials: $_" -ForegroundColor Red
}
