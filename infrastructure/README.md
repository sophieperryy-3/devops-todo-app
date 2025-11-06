# Infrastructure as Code

This directory contains Terraform configurations for provisioning AWS infrastructure.

## Structure

- `modules/` - Reusable Terraform modules
- `environments/` - Environment-specific configurations
- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values

## Usage

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```