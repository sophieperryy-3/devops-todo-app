# Deployment Guide - Interactive To-Do List

This guide demonstrates how to deploy the Interactive To-Do List application to AWS using DevOps best practices.

## 🎯 Overview

This deployment showcases:
- **Infrastructure as Code** with Terraform
- **CI/CD Pipeline** with GitHub Actions
- **Security Best Practices** throughout the stack
- **Monitoring and Logging** with CloudWatch
- **Auto Scaling** and **Load Balancing**
- **Database Management** with RDS PostgreSQL

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudFront    │    │   Load Balancer │    │   Auto Scaling  │
│   (Frontend)    │    │   (ALB)         │    │   Group         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   S3 Bucket     │    │   EC2 Instances │    │   RDS PostgreSQL│
│   (Static Site) │    │   (Backend API) │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   CloudWatch    │
                    │   (Monitoring)  │
                    └─────────────────┘
```

## 🚀 Quick Deployment

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.0 installed
4. **Node.js** >= 18 installed
5. **Git** for version control

### One-Command Deployment

```bash
# Make the script executable
chmod +x scripts/deploy.sh

# Deploy to development environment
./scripts/deploy.sh dev

# Deploy to production environment
./scripts/deploy.sh prod
```

## 📋 Step-by-Step Deployment

### 1. Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Verify credentials
aws sts get-caller-identity
```

### 2. Set Environment Variables

```bash
export AWS_REGION=us-east-1
export DB_PASSWORD=your-secure-password
export ENVIRONMENT=dev
```

### 3. Deploy Infrastructure

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var="environment=dev" -var="db_password=$DB_PASSWORD"

# Apply changes
terraform apply -auto-approve
```

### 4. Deploy Applications

```bash
# Build frontend
cd frontend
npm install
npm run build

# Build backend
cd ../backend
npm install
npm run build

# Deploy frontend to S3
aws s3 sync ../frontend/dist/ s3://your-bucket-name/ --delete

# Backend deployment is handled by Auto Scaling Group
```

## 🔧 CI/CD Pipeline

### GitHub Actions Workflows

The project includes two main workflows:

#### Continuous Integration (`ci.yml`)
- **Frontend Tests**: Linting, type checking, unit tests
- **Backend Tests**: API tests, database integration tests
- **Security Scanning**: Dependency vulnerabilities, code analysis
- **Infrastructure Validation**: Terraform validation, security scanning
- **End-to-End Tests**: Full application workflow testing

#### Continuous Deployment (`cd.yml`)
- **Infrastructure Deployment**: Terraform apply
- **Application Deployment**: Frontend to S3, Backend to EC2
- **Post-Deployment Tests**: Health checks, smoke tests
- **Performance Testing**: API response time validation

### Setting Up CI/CD

1. **Fork the repository** to your GitHub account

2. **Configure GitHub Secrets**:
   ```
   AWS_ACCESS_KEY_ID=your-access-key
   AWS_SECRET_ACCESS_KEY=your-secret-key
   DB_PASSWORD=your-database-password
   SNYK_TOKEN=your-snyk-token (optional)
   ```

3. **Push to main branch** to trigger deployment

## 🔒 Security Features

### Infrastructure Security
- **VPC with private subnets** for database
- **Security Groups** with minimal required access
- **IAM roles** with least privilege principle
- **Encryption** at rest and in transit
- **SSL/TLS** termination at load balancer

### Application Security
- **Input validation** and sanitization
- **Rate limiting** to prevent abuse
- **Security headers** (Helmet.js)
- **CORS** configuration
- **Dependency scanning** in CI/CD

### Secrets Management
- **Environment variables** for configuration
- **AWS Secrets Manager** for sensitive data
- **No hardcoded credentials** in code

## 📊 Monitoring and Logging

### CloudWatch Integration
- **Application logs** from EC2 instances
- **System metrics** (CPU, memory, disk)
- **Custom metrics** for business logic
- **Alarms** for critical thresholds

### Health Checks
- **Load balancer health checks** for EC2 instances
- **Application health endpoints** (`/health`, `/ready`)
- **Database connectivity** monitoring
- **Automated recovery** for failed instances

### Dashboards
- **Infrastructure metrics** dashboard
- **Application performance** metrics
- **Error rate** and **response time** tracking
- **Business metrics** (task creation, completion rates)

## 🧪 Testing Strategy

### Automated Testing Levels

1. **Unit Tests**
   - Frontend components (React Testing Library)
   - Backend services (Jest + Supertest)
   - Minimum 80% code coverage

2. **Integration Tests**
   - API endpoint testing
   - Database integration
   - External service mocking

3. **End-to-End Tests**
   - Complete user workflows
   - Cross-browser testing
   - Visual regression testing

4. **Security Tests**
   - Dependency vulnerability scanning
   - Static code analysis
   - Infrastructure security scanning

5. **Performance Tests**
   - Load testing with Artillery
   - API response time validation
   - Database query performance

## 🔄 Deployment Strategies

### Blue-Green Deployment
- **Zero-downtime** deployments
- **Instant rollback** capability
- **Production traffic** validation

### Auto Scaling
- **Horizontal scaling** based on CPU/memory
- **Health check** based replacement
- **Multi-AZ** deployment for high availability

### Database Management
- **Automated backups** with point-in-time recovery
- **Multi-AZ** deployment for failover
- **Encryption** at rest and in transit
- **Connection pooling** for performance

## 🚨 Troubleshooting

### Common Issues

1. **Terraform State Lock**
   ```bash
   terraform force-unlock LOCK_ID
   ```

2. **EC2 Instance Health Check Failures**
   ```bash
   # Check application logs
   aws logs tail /aws/ec2/interactive-todo --follow
   
   # SSH into instance
   aws ssm start-session --target i-1234567890abcdef0
   ```

3. **Database Connection Issues**
   ```bash
   # Check security group rules
   aws ec2 describe-security-groups --group-ids sg-12345678
   
   # Test database connectivity
   psql -h your-db-endpoint -U todouser -d todoapp
   ```

### Monitoring Commands

```bash
# Check application health
curl http://your-load-balancer/health

# View recent logs
aws logs tail /aws/ec2/interactive-todo --since 1h

# Check auto scaling activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name interactive-todo-app-asg
```

## 📈 Performance Optimization

### Frontend Optimization
- **Static asset caching** with CloudFront
- **Gzip compression** for text files
- **Image optimization** and lazy loading
- **Bundle splitting** for faster loading

### Backend Optimization
- **Connection pooling** for database
- **Response caching** for frequent queries
- **Load balancing** across multiple instances
- **Auto scaling** based on demand

### Database Optimization
- **Proper indexing** for query performance
- **Connection pooling** to reduce overhead
- **Read replicas** for read-heavy workloads
- **Query optimization** and monitoring

## 🎓 DevOps Best Practices Demonstrated

### Infrastructure as Code
- ✅ **Version controlled** infrastructure
- ✅ **Reproducible** environments
- ✅ **Modular** Terraform configuration
- ✅ **Environment-specific** variables

### CI/CD Pipeline
- ✅ **Automated testing** at multiple levels
- ✅ **Security scanning** integration
- ✅ **Deployment automation**
- ✅ **Rollback capabilities**

### Monitoring and Observability
- ✅ **Comprehensive logging**
- ✅ **Metrics collection**
- ✅ **Alerting and notifications**
- ✅ **Health monitoring**

### Security
- ✅ **Security by design**
- ✅ **Automated security scanning**
- ✅ **Secrets management**
- ✅ **Network security**

## 🔗 Useful Links

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

## 📞 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review CloudWatch logs for errors
3. Verify AWS service limits and quotas
4. Ensure all prerequisites are met