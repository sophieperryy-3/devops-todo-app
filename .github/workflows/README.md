# CI/CD Workflows

This directory contains GitHub Actions workflows for automated testing and deployment.

## Workflows

- `ci.yml` - Continuous Integration (testing, linting, security scans)
- `cd.yml` - Continuous Deployment (infrastructure and application deployment)
- `security.yml` - Security scanning and vulnerability assessment

## Secrets Required

Configure these secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `DB_PASSWORD` - Database password
- `JWT_SECRET` - JWT signing secret