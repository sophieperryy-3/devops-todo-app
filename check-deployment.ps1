# Check AWS Deployment Status

Write-Host "Checking deployment status..." -ForegroundColor Cyan
Write-Host ""

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if Terraform state exists
if (Test-Path "infrastructure/learner-lab/terraform.tfstate") {
    Write-Host "Found Terraform state. Checking resources..." -ForegroundColor Yellow
    
    Set-Location infrastructure/learner-lab
    
    # Get public IP
    try {
        $publicIp = terraform output -raw public_ip 2>$null
        $instanceId = terraform output -raw instance_id 2>$null
        
        if ($publicIp) {
            Write-Host ""
            Write-Host "=== EC2 Instance Found ===" -ForegroundColor Green
            Write-Host "Instance ID: $instanceId" -ForegroundColor Cyan
            Write-Host "Public IP: $publicIp" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Your application URL should be:" -ForegroundColor Yellow
            Write-Host "  http://$publicIp" -ForegroundColor White
            Write-Host ""
            
            # Check if instance is running
            Write-Host "Checking instance status..." -ForegroundColor Yellow
            $status = aws ec2 describe-instances --instance-ids $instanceId --query 'Reservations[0].Instances[0].State.Name' --output text 2>$null
            
            if ($status -eq "running") {
                Write-Host "  Instance is RUNNING" -ForegroundColor Green
                
                # Try to ping the instance
                Write-Host ""
                Write-Host "Testing connectivity..." -ForegroundColor Yellow
                $response = Test-NetConnection -ComputerName $publicIp -Port 80 -WarningAction SilentlyContinue
                
                if ($response.TcpTestSucceeded) {
                    Write-Host "  Port 80 is OPEN and accessible" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "The application should be working at: http://$publicIp" -ForegroundColor Green
                } else {
                    Write-Host "  Port 80 is NOT accessible yet" -ForegroundColor Red
                    Write-Host ""
                    Write-Host "Possible reasons:" -ForegroundColor Yellow
                    Write-Host "  1. Instance is still initializing (wait 2-3 minutes)" -ForegroundColor White
                    Write-Host "  2. Application not deployed yet" -ForegroundColor White
                    Write-Host "  3. Services not started" -ForegroundColor White
                    Write-Host ""
                    Write-Host "To check logs, connect via Instance Connect:" -ForegroundColor Cyan
                    Write-Host "  1. Go to AWS Console -> EC2" -ForegroundColor White
                    Write-Host "  2. Select instance: $instanceId" -ForegroundColor White
                    Write-Host "  3. Click Connect -> EC2 Instance Connect" -ForegroundColor White
                    Write-Host "  4. Run: sudo systemctl status nginx todo-backend" -ForegroundColor White
                }
            } else {
                Write-Host "  Instance status: $status" -ForegroundColor Yellow
                Write-Host "  Wait for instance to be 'running'" -ForegroundColor Yellow
            }
            
        } else {
            Write-Host "No public IP found in Terraform state" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error reading Terraform outputs: $_" -ForegroundColor Red
    }
    
    Set-Location ../..
    
} else {
    Write-Host "No Terraform state found." -ForegroundColor Red
    Write-Host "The infrastructure hasn't been deployed yet." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To deploy, run:" -ForegroundColor Cyan
    Write-Host "  .\set-credentials-and-deploy.ps1" -ForegroundColor White
}

Write-Host ""
