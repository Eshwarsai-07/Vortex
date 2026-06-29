# Vortex Deployment Guide — AWS EC2 & Docker Compose

This guide explains how to deploy the Vortex backend and supporting infrastructure services to an AWS EC2 instance using Docker Compose and Nginx.

---

## 1. Prerequisites
- Active AWS Account with permissions to provision VPC, EC2, Elastic IP, and IAM Roles.
- Domain name or Elastic IP assigned to EC2 instance.
- Installed Terraform CLI (v1.3.0+) and AWS CLI.

---

## 2. Infrastructure Provisioning with Terraform
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set your key_name

terraform init
terraform apply -auto-approve
```

---

## 3. Containerized Deployment on EC2
Once the server bootstraps via `user_data.sh`:
```bash
# SSH into the server
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Clone workspace
git clone https://github.com/your-username/vortex.git
cd vortex/services

# Launch production stack
docker compose up -d --build
```

---

## 4. Operational Recovery & Management
- **Verify Health**: `bash scripts/health-check.sh`
- **Rollback Commit**: `bash scripts/rollback.sh`
- **Database Backup**: `bash scripts/backup.sh`
