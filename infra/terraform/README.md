# Terraform Infrastructure for Vortex Platform

This directory contains production-ready Infrastructure-as-Code (IaC) templates using HashiCorp Terraform to provision AWS resources for Vortex.

---

## Provisioned Resources
- **VPC & Networking**: Custom VPC (`10.0.0.0/16`), Public Subnet (`10.0.1.0/24`), Internet Gateway, Route Table.
- **Security Group**: Ingress rules for SSH (22), HTTP (80), HTTPS (443), Express Backend (5000), and Redpanda Console (8080).
- **IAM Role & Profile**: Grants EC2 instances `AmazonS3FullAccess` to store static deployment artifacts.
- **EC2 Compute**: Ubuntu 22.04 LTS instance (`t3.medium` default) with 30GB gp3 storage and Elastic IP assignment.
- **Bootstrap (`user_data.sh`)**: Automates installation of Docker, Docker Compose, and dependencies.

---

## Usage Instructions

```bash
# 1. Initialize Terraform working directory
terraform init

# 2. Copy and customize terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS key pair name

# 3. Preview resource changes
terraform plan

# 4. Apply infrastructure configuration
terraform apply -auto-approve
```
