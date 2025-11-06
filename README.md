# Interactive To-Do List - DevOps Demonstration

A comprehensive full-stack web application demonstrating modern DevOps practices, CI/CD pipelines, and cloud deployment strategies.

🚀 **Live Demo Ready!** This project showcases professional DevOps implementation.

## 🎯 Project Overview

This project serves as a practical demonstration of:
- **Infrastructure as Code (IaC)** with Terraform
- **CI/CD Pipeline** with automated testing and deployment
- **Security Best Practices** throughout the development lifecycle
- **Monitoring and Logging** for operational excellence
- **Cloud-Native Architecture** on AWS

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   Database      │
│   React + TS    │◄──►│   Node.js + TS  │◄──►│   PostgreSQL    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   CI/CD Pipeline │
                    │   GitHub Actions │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   AWS Cloud     │
                    │   Infrastructure │
                    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Docker & Docker Compose
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd interactive-todo-app
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start with Docker Compose**
   ```bash
   docker-compose up -d
   ```

4. **Or run manually**
   ```bash
   # Install dependencies
   npm install
   
   # Start development servers
   npm run dev
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001
   - API Health Check: http://localhost:3001/health

## 📁 Project Structure

```
interactive-todo-app/
├── frontend/                 # React TypeScript frontend
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── services/        # API services
│   │   ├── types/          # TypeScript types
│   │   └── utils/          # Utility functions
│   └── package.json
├── backend/                 # Node.js TypeScript backend
│   ├── src/
│   │   ├── controllers/    # API controllers
│   │   ├── services/       # Business logic
│   │   ├── models/         # Data models
│   │   ├── middleware/     # Express middleware
│   │   └── utils/          # Utility functions
│   └── package.json
├── infrastructure/          # Terraform IaC
│   ├── modules/            # Reusable Terraform modules
│   └── environments/       # Environment-specific configs
├── .github/                # GitHub Actions workflows
│   └── workflows/
├── docker-compose.yml      # Local development setup
└── README.md
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Run frontend tests
npm run test:frontend

# Run backend tests
npm run test:backend

# Run with coverage
npm run test:coverage
```

## 🔒 Security Features

- HTTPS enforcement
- Input validation and sanitization
- Rate limiting
- CORS configuration
- Security headers (Helmet.js)
- Dependency vulnerability scanning
- Infrastructure security scanning

## 📊 Monitoring & Logging

- Structured logging with Winston
- Health check endpoints
- CloudWatch integration
- Custom metrics and dashboards
- Automated alerting

## 🚀 Deployment

The application supports multiple deployment strategies:

### AWS Full Stack (Recommended)
- Terraform for infrastructure provisioning
- GitHub Actions for CI/CD
- EC2/ECS for application hosting
- RDS for database
- CloudWatch for monitoring

### AWS Learner Lab (Simplified)
- CloudFormation templates
- S3 + CloudFront for static hosting
- DynamoDB for data storage
- Manual deployment scripts

## 📈 CI/CD Pipeline

The pipeline includes:
1. **Code Quality**: Linting, type checking
2. **Security**: Dependency scanning, SAST
3. **Testing**: Unit, integration, E2E tests
4. **Infrastructure**: Terraform plan/apply
5. **Deployment**: Blue-green deployment
6. **Monitoring**: Health checks, rollback

## 🛠️ Development Commands

```bash
# Development
npm run dev              # Start all services
npm run dev:frontend     # Start frontend only
npm run dev:backend      # Start backend only

# Building
npm run build           # Build all
npm run build:frontend  # Build frontend
npm run build:backend   # Build backend

# Testing
npm test               # Run all tests
npm run test:watch     # Watch mode
npm run test:coverage  # With coverage

# Linting
npm run lint          # Lint all
npm run lint:fix      # Fix linting issues
```

## 📚 Documentation

- [API Documentation](./docs/api.md)
- [Deployment Guide](./docs/deployment.md)
- [Architecture Decisions](./docs/architecture.md)
- [Security Guidelines](./docs/security.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎓 Academic Context

This project was created as part of a DevOps assessment demonstrating:
- Modern deployment practices
- Infrastructure as Code principles
- CI/CD pipeline implementation
- Security integration
- Monitoring and observability
- Cloud-native architecture patterns