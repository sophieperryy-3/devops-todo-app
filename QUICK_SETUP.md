# 🚀 Quick Setup Guide for DevOps Demo

## Step 1: Restart Your Terminal
Close and reopen your terminal/PowerShell to get the updated PATH for AWS CLI and Terraform.

## Step 2: Configure AWS Credentials

### Option A: AWS Learner Lab (If Available)
1. Start your AWS Learner Lab
2. Click "AWS Details" and copy the credentials
3. Run in terminal:
```bash
aws configure
```
Enter:
- AWS Access Key ID: [from learner lab]
- AWS Secret Access Key: [from learner lab]
- Default region: us-east-1
- Default output format: json

### Option B: Personal AWS Account
1. Go to AWS Console → IAM → Users → Your User → Security Credentials
2. Create Access Key
3. Run `aws configure` and enter the credentials

## Step 3: Test AWS Connection
```bash
aws sts get-caller-identity
```

## Step 4: Create GitHub Repository

1. **Go to GitHub.com** and create a new repository:
   - Name: `devops-todo-app`
   - Description: `DevOps demonstration with Interactive Todo App`
   - Make it **Public** (for demo purposes)
   - **Don't** initialize with README

2. **Connect your local repo to GitHub:**
```bash
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/devops-todo-app.git
git push -u origin main
```

## Step 5: Configure GitHub Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add these secrets:
   - `AWS_ACCESS_KEY_ID` = [Your AWS Access Key]
   - `AWS_SECRET_ACCESS_KEY` = [Your AWS Secret Key]
   - `DB_PASSWORD` = `todopass123!`

## Step 6: Trigger the CI/CD Pipeline

1. Make any small change to a file (e.g., edit README.md)
2. Commit and push:
```bash
git add .
git commit -m "Trigger CI/CD pipeline demo"
git push
```

3. **Watch the magic happen!**
   - Go to your GitHub repo → Actions tab
   - You'll see the CI/CD pipeline running automatically
   - It will run tests, security scans, and deploy to AWS

## Step 7: Manual Deployment (Optional)

If you want to deploy manually for testing:

```bash
# Restart terminal first, then:
cd infrastructure
terraform init
terraform plan -var="environment=demo" -var="db_password=todopass123!"
terraform apply -auto-approve -var="environment=demo" -var="db_password=todopass123!"
```

## 🎯 What You'll Demonstrate

✅ **Infrastructure as Code**: Live Terraform deployment
✅ **CI/CD Pipeline**: Automated GitHub Actions workflow
✅ **Security Scanning**: Automated vulnerability detection
✅ **Testing**: Unit, integration, and E2E tests
✅ **Monitoring**: CloudWatch integration
✅ **Auto Scaling**: Load balancer and auto scaling groups
✅ **Database Management**: PostgreSQL with automated backups

## 🎓 For Your 20-Minute Demo

Use the script in `docs/DEMO_SCRIPT.md` which includes:
- 2 min: Project overview
- 5 min: Live infrastructure deployment
- 5 min: CI/CD pipeline demonstration
- 3 min: Security and testing features
- 3 min: Monitoring and application functionality
- 2 min: Reflection and industry relevance

## 🆘 Troubleshooting

**AWS CLI not found after install:**
- Restart your terminal/PowerShell
- Or run: `refreshenv` (if you have Chocolatey)

**Terraform not found:**
- Restart your terminal/PowerShell
- Check PATH: `$env:PATH -split ';' | Select-String terraform`

**GitHub push fails:**
- Check repository URL is correct
- Ensure you have push access
- Try: `git remote -v` to verify remote URL

**AWS credentials issues:**
- Run: `aws sts get-caller-identity` to test
- Check: `aws configure list` to see current config
- For Learner Lab: credentials expire, get new ones

## 🎉 Success!

Once set up, you'll have:
- A live web application running on AWS
- Automated CI/CD pipeline triggered by Git commits
- Comprehensive DevOps demonstration ready for your assessment

Your application URLs will be:
- Frontend: `http://[bucket-name].s3-website-us-east-1.amazonaws.com`
- Backend: `http://[load-balancer-dns]`
- Health Check: `http://[load-balancer-dns]/health`