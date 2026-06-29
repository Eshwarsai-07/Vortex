# Terraform Infrastructure Architecture — Vortex

This document details the modular Terraform resources in `infra/terraform/`.

---

## Resource Modules Overview

| File | Provisioned Resources | Description |
| :--- | :--- | :--- |
| `provider.tf` | AWS Provider | HashiCorp AWS provider configuration (version ~> 5.0). |
| `variables.tf` | Inputs | Input parameters (`aws_region`, `instance_type`, `key_name`). |
| `networking.tf` | VPC, Subnet, IGW, Route Table | Isolated cloud network (`10.0.0.0/16`) and public subnet (`10.0.1.0/24`). |
| `security.tf` | Security Group | Firewall rules allowing ports 22 (SSH), 80/443 (HTTP/S), 5000 (API), 8080 (Console). |
| `iam.tf` | IAM Role & Profile | Grants EC2 instances full access to AWS S3 for build artifacts. |
| `ec2.tf` | EC2 & Elastic IP | Ubuntu 22.04 LTS compute instance with attached Elastic IP. |
| `user_data.sh` | Bootstrap Script | Automated startup script installing Docker Engine, Compose, and Git. |
| `outputs.tf` | Outputs | Public IP address and SSH connection strings. |
