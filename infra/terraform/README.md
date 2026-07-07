# Vortex AWS Infrastructure Provisioning

This directory contains HashiCorp Terraform configuration templates to provision the AWS cloud resources required for the **Vortex** deployment service.

The infrastructure consists of a single public subnet VPC with an EC2 host instance running Ubuntu 24.04 LTS. The host is configured with an Elastic IP and is bootstrapped automatically with Docker, Docker Compose, Git, and system level security groups.

---

## 📂 Folder Structure

Each file in this folder has a single, dedicated responsibility:

*   **`versions.tf`**: Restricts the Terraform CLI version (`>= 1.6.0`) and the AWS provider version (`~> 5.0`).
*   **`provider.tf`**: Sets up the AWS provider and binds it to the target deployment region.
*   **`variables.tf`**: Declares all configurable inputs (VPC CIDRs, availability zones, instance sizing, key pairs, firewall IP scopes).
*   **`networking.tf`**: Configures the Virtual Private Cloud (VPC), Public Subnet (bound to a pinned Availability Zone), Internet Gateway (IGW), and Route Tables.
*   **`security.tf`**: Sets up the Security Group and detailed port definitions (SSH, HTTP/HTTPS, DBs, Brokers), securing databases to internal VPC and trusted IP ranges.
*   **`iam.tf`**: Declares the IAM EC2 Role, SSM core policy attachment, and the EC2 Instance Profile.
*   **`ec2.tf`**: Handles Ubuntu AMI queries, EC2 server instantiation with enforced IMDSv2, Elastic IP association, and root block storage.
*   **`user_data.sh`**: The bootstrap script executing on instance boot to install Git, Curl, Docker, and Docker Compose with retry logic and health verifications.
*   **`outputs.tf`**: Exposes the provisioned IP addresses, instance ID, and formatted SSH connect strings.

---

## 🛠️ Prerequisites

1.  **Terraform CLI**: Install Terraform `1.6.0` or higher.
2.  **AWS CLI & Credentials**: Install the AWS CLI. Ensure your local terminal environment has active credentials. You can set them via:
    ```bash
    export AWS_ACCESS_KEY_ID="your_access_key"
    export AWS_SECRET_ACCESS_KEY="your_secret_key"
    export AWS_DEFAULT_REGION="ap-south-1"
    ```
    *Alternatively, configure them using the profile wizard: `aws configure`*
3.  **SSH Key Pair**: Ensure you have created a Key Pair in your target AWS region's EC2 console (e.g., named `vortex-keypair` in `ap-south-1`) and have saved the corresponding `.pem` file locally.

---

## 🚀 Quick Start Guide

### 1. Initialize Configuration
Navigate to this directory and initialize Terraform to download the AWS provider plugins:
```bash
cd infra/terraform
terraform init
```

### 2. Configure Input Variables
Copy the template variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Open `terraform.tfvars` in your editor and specify your EC2 key pair name and any source IP restrictions:
```hcl
key_name         = "vortex-keypair"
allowed_ssh_cidr = "203.0.113.50/32" # Highly recommended to lock SSH to your IP
```

### 3. Generate Execution Plan
Run a plan comparison to verify AWS resources to be created:
```bash
terraform plan
```

### 4. Deploy Infrastructure
Apply the configurations to AWS (this will prompt for confirmation):
```bash
terraform apply
```
*To automate execution without interactive prompts:*
```bash
terraform apply -auto-approve
```

### 5. Establish SSH Access
Once provisioning completes, Terraform outputs a direct SSH command. Copy and run it:
```bash
ssh -i ~/.ssh/vortex-keypair.pem ubuntu@<ELASTIC_IP>
```

### 6. Clean Up Resources
To destroy all provisioned AWS resources when they are no longer needed:
```bash
terraform destroy
```

---

## 🔒 Security & Ingress Port Rules

The security group configurations inside `security.tf` isolate services according to production security guidelines:

*   **Public Internet Ports (80/443)**: Permitted to receive connections from any source (`0.0.0.0/0`) to allow frontend website access and backend API integration through the Nginx gateway.
*   **SSH Administration Port (22)**: Parameterized via `allowed_ssh_cidr`. Defaults to a secure non-routable range (`192.0.2.0/24`) to prevent public brute force attacks.
*   **Database and Queue Ports (MongoDB, ClickHouse, Kafka, Redpanda)**:
    *   **VPC Internal Traffic**: Always permitted from inside the VPC range (`var.vpc_cidr` which defaults to `10.0.0.0/16`). This allows application components to securely talk to database services.
    *   **External Access**: Restricted to a trusted CIDR variable (`allowed_app_ports_cidr`) which defaults to the non-routable TEST-NET range (`192.0.2.0/24`). You must override this in `terraform.tfvars` if direct external connection is needed.
*   **IMDSv2 Enforcement**: The EC2 instance requires Session Tokens for accessing host metadata (prevents SSRF attacks extracting IAM credentials).

| Port | Protocol | Purpose / Service | Ingress Source |
| :--- | :--- | :--- | :--- |
| **22** | TCP | SSH Administration Console | `allowed_ssh_cidr` (Secure default: `192.0.2.0/24`) |
| **80** | TCP | HTTP web access (Nginx Proxy) | Public (`0.0.0.0/0` default) |
| **443** | TCP | HTTPS secure web access (Nginx Proxy) | Public (`0.0.0.0/0` default) |
| **3005** | TCP | Frontend Server direct access | VPC (`10.0.0.0/16`) & `allowed_app_ports_cidr` |
| **5005** | TCP | Backend API server direct access | VPC (`10.0.0.0/16`) & `allowed_app_ports_cidr` |
| **8080** | TCP | Redpanda Kafka Console UI | VPC (`10.0.0.0/16`) & `allowed_app_ports_cidr` |
| **19092, 29092, 39092** | TCP | Kafka Brokers (Cluster nodes) | VPC (`10.0.0.0/16`) & `allowed_app_ports_cidr` |
| **8123, 9000** | TCP | ClickHouse HTTP & native TCP endpoints | VPC (`10.0.0.0/16`) & `allowed_app_ports_cidr` |
| **27017** | TCP | MongoDB database engine connection | VPC (`10.0.0.0/16`) & `allowed_app_ports_cidr` |
