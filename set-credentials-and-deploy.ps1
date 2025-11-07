# Set AWS Credentials and Deploy
# This script helps you set credentials and then runs the deployment

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AWS Credentials Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Get your credentials from:" -ForegroundColor Yellow
Write-Host "  AWS Academy -> Learner Lab -> AWS Details -> Show" -ForegroundColor White
Write-Host ""

# Prompt for credentials
$accessKey = Read-Host "Paste AWS_ACCESS_KEY_ID"
$secretKey = Read-Host "Paste AWS_SECRET_ACCESS_KEY" 
$sessionToken = Read-Host "Paste AWS_SESSION_TOKEN"

# Set environment variables
$env:AWS_ACCESS_KEY_ID = $accessKey
$env:AWS_SECRET_ACCESS_KEY = $secretKey
$env:AWS_SESSION_TOKEN = $sessionToken
$env:AWS_DEFAULT_REGION = "us-east-1"

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host ""
Write-Host "Testing credentials..." -ForegroundColor Yellow

try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    Write-Host "Credentials verified!" -ForegroundColor Green
    Write-Host "  Account: $($identity.Account)" -ForegroundColor Cyan
    Write-Host "  User: $($identity.Arn)" -ForegroundColor Cyan
    Write-Host ""
    
    # Ask if they want to deploy now
    $deploy = Read-Host "Start deployment now? (yes/no)"
    
    if ($deploy -eq "yes" -or $deploy -eq "y") {
        Write-Host ""
        Write-Host "Starting deployment..." -ForegroundColor Cyan
        Write-Host ""
        
        # Ask about key file
        $hasKey = Read-Host "Do you have vockey.pem or labsuser.pem key file? (yes/no)"
        
        if ($hasKey -eq "yes" -or $hasKey -eq "y") {
            $keyFile = Read-Host "Enter key file name (e.g., vockey.pem)"
            if (Test-Path $keyFile) {
                & .\deploy-to-aws.ps1 -KeyFile $keyFile
            } else {
                Write-Host "Key file not found. Using S3 method instead..." -ForegroundColor Yellow
                & .\deploy-to-aws.ps1 -UseS3
            }
        } else {
            & .\deploy-to-aws.ps1 -UseS3
        }
    } else {
        Write-Host ""
        Write-Host "Credentials are set. You can now run:" -ForegroundColor Cyan
        Write-Host "  .\deploy-to-aws.ps1 -UseS3" -ForegroundColor White
        Write-Host "or" -ForegroundColor Cyan
        Write-Host "  .\deploy-to-aws.ps1 -KeyFile vockey.pem" -ForegroundColor White
    }
    
} catch {
    Write-Host "ERROR: Credential verification failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check your credentials and try again." -ForegroundColor Yellow
}
