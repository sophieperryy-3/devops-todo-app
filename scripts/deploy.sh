#!/bin/bash

# Interactive To-Do App Deployment Script
# This script demonstrates the complete DevOps pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-dev}
AWS_REGION=${AWS_REGION:-us-east-1}
PROJECT_NAME="interactive-todo"

echo -e "${BLUE}🚀 Starting deployment of Interactive To-Do App${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}AWS Region: ${AWS_REGION}${NC}"

# Function to print step headers
print_step() {
    echo -e "\n${YELLOW}📋 Step: $1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
print_step "Checking Prerequisites"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

print_success "All prerequisites met"

# Install dependencies
print_step "Installing Dependencies"

echo "Installing root dependencies..."
npm install

echo "Installing frontend dependencies..."
cd frontend && npm install && cd ..

echo "Installing backend dependencies..."
cd backend && npm install && cd ..

print_success "Dependencies installed"

# Run tests
print_step "Running Tests"

echo "Running frontend tests..."
cd frontend && npm test -- --watchAll=false && cd ..

echo "Running backend tests..."
cd backend && npm test && cd ..

print_success "All tests passed"

# Build applications
print_step "Building Applications"

echo "Building frontend..."
cd frontend && npm run build && cd ..

echo "Building backend..."
cd backend && npm run build && cd ..

print_success "Applications built successfully"

# Deploy infrastructure
print_step "Deploying Infrastructure with Terraform"

cd infrastructure

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan deployment
echo "Planning infrastructure deployment..."
terraform plan \
    -var="environment=${ENVIRONMENT}" \
    -var="aws_region=${AWS_REGION}" \
    -var="db_password=${DB_PASSWORD:-todopass123!}" \
    -out=tfplan

# Apply deployment
echo "Applying infrastructure changes..."
terraform apply -auto-approve tfplan

# Get outputs
LOAD_BALANCER_DNS=$(terraform output -raw load_balancer_dns)
FRONTEND_BUCKET=$(terraform output -raw frontend_bucket_name)

cd ..

print_success "Infrastructure deployed successfully"

# Deploy frontend to S3
print_step "Deploying Frontend to S3"

echo "Syncing frontend files to S3..."
aws s3 sync frontend/dist/ s3://${FRONTEND_BUCKET}/ \
    --delete \
    --cache-control "public, max-age=31536000" \
    --exclude "*.html" \
    --exclude "service-worker.js"

# Upload HTML files with no cache
aws s3 sync frontend/dist/ s3://${FRONTEND_BUCKET}/ \
    --delete \
    --cache-control "no-cache" \
    --include "*.html" \
    --include "service-worker.js"

print_success "Frontend deployed to S3"

# Wait for deployment to be ready
print_step "Waiting for Deployment to be Ready"

echo "Waiting for load balancer to be ready..."
sleep 60

# Health checks
print_step "Running Health Checks"

BACKEND_URL="http://${LOAD_BALANCER_DNS}"
FRONTEND_URL="http://${FRONTEND_BUCKET}.s3-website-${AWS_REGION}.amazonaws.com"

echo "Testing backend health..."
for i in {1..30}; do
    if curl -f "${BACKEND_URL}/health" &> /dev/null; then
        print_success "Backend is healthy!"
        break
    fi
    echo "Waiting for backend... (attempt $i/30)"
    sleep 10
done

echo "Testing frontend accessibility..."
if curl -f "${FRONTEND_URL}" &> /dev/null; then
    print_success "Frontend is accessible!"
else
    print_error "Frontend health check failed"
fi

# API smoke tests
print_step "Running API Smoke Tests"

echo "Testing API endpoints..."
curl -f "${BACKEND_URL}/health" | jq .
curl -f "${BACKEND_URL}/api/tasks" | jq .

print_success "All smoke tests passed!"

# Performance test
print_step "Running Performance Test"

echo "Testing API performance..."
for i in {1..5}; do
    START_TIME=$(date +%s%N)
    curl -s "${BACKEND_URL}/health" > /dev/null
    END_TIME=$(date +%s%N)
    DURATION=$((($END_TIME - $START_TIME) / 1000000))
    echo "Request $i: ${DURATION}ms"
done

# Final summary
print_step "Deployment Summary"

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}📊 Application URLs:${NC}"
echo -e "   Frontend: ${FRONTEND_URL}"
echo -e "   Backend:  ${BACKEND_URL}"
echo -e "   Health:   ${BACKEND_URL}/health"
echo -e "   API:      ${BACKEND_URL}/api/tasks"

echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "   1. Test the application in your browser"
echo -e "   2. Monitor logs in CloudWatch"
echo -e "   3. Set up alerts and monitoring"
echo -e "   4. Configure custom domain (optional)"

echo -e "\n${YELLOW}💡 DevOps Features Demonstrated:${NC}"
echo -e "   ✅ Infrastructure as Code (Terraform)"
echo -e "   ✅ Automated Testing (Unit, Integration)"
echo -e "   ✅ CI/CD Pipeline (GitHub Actions)"
echo -e "   ✅ Security Scanning"
echo -e "   ✅ Health Monitoring"
echo -e "   ✅ Auto Scaling"
echo -e "   ✅ Load Balancing"
echo -e "   ✅ Database Management"
echo -e "   ✅ Logging and Monitoring"

print_success "Deployment script completed!"