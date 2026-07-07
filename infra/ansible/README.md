# Vortex Application Deployment Playbook

This directory contains production-ready Ansible playbooks and roles to automate the deployment of the **Vortex** application suite (Frontend, Backend, Nginx, MongoDB, Kafka, ClickHouse) onto your AWS EC2 host instance.

The playbook is fully **idempotent**, meaning you can execute it repeatedly without breaking configuration states.

---

## 📂 Directory Structure

*   **`ansible.cfg`**: Configures default settings (inventory path, remote ssh user, host key checks bypass).
*   **`inventory.ini`**: Lists target deployment environments and hosts (e.g. `vortex-production`).
*   **`playbook.yml`**: Root playbook tying the target hosts to the deployment roles.
*   **`group_vars/`**: Contains global variables (`all.yml`) shared across all hosts.
*   **`roles/vortex/`**: The deployment role encapsulating tasks, templates, defaults, and handlers:
    *   **`defaults/main.yml`**: Role variables containing default credentials, JWT secrets, and regions.
    *   **`templates/.env.j2`**: Jinja2 template dynamically generating the application `.env` file.
    *   **`handlers/main.yml`**: Listens for `.env` updates to restart Docker Compose services.
    *   **`tasks/main.yml`**: Sequentially calls tasks files.
    *   **`tasks/repository.yml`**: Handles git directory and cloning using the git module.
    *   **`tasks/env.yml`**: Renders the environment variables file on the host.
    *   **`tasks/deploy.yml`**: Pulls Docker base images and executes `docker compose up -d --build`.
    *   **`tasks/health.yml`**: Asserts container states and performs HTTP API status checks.

---

## ⚙️ Configuration Variables

Configuration values are mapped under `group_vars/all.yml` and `roles/vortex/defaults/main.yml`:

| Variable | Scope | Purpose |
| :--- | :--- | :--- |
| `repository_url` | Global | URL of the GitHub source code repository |
| `repository_branch` | Global | Branch to pull and build (defaults to `devops-redesign`) |
| `project_directory` | Global | Absolute directory path on the EC2 host |
| `health_endpoint` | Global | Target URL of backend/Nginx edge status page |
| `node_env` | Role | Target Node system environment stage (`production`) |
| `jwt_secret` | Role | Application JWT authentication signature key |
| `aws_s3_region` | Role | Target bucket AWS region for static storage uploads |
| `s3_bucket` | Role | Target S3 bucket name |

---

## 🚀 Execution Guide

### 1. Prerequisites
Ensure you have Ansible installed on your controller (your local machine):
```bash
# MacOS
brew install ansible
```

Ensure your SSH key permissions are secure:
```bash
chmod 400 ~/.ssh/vortex-keypair.pem
```

### 2. Run the Playbook
To run the playbook and deploy Vortex:
```bash
cd infra/ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 3. Overriding Variables at Runtime
To override configuration variables (such as updating the Git branch or changing secrets) without modifying files, pass them as extra variables:
```bash
ansible-playbook -i inventory.ini playbook.yml \
  --extra-vars "repository_branch=main jwt_secret=my_custom_secret_key_1234"
```

---

## 📈 Scaling: Adding More Hosts

To deploy Vortex to additional EC2 instances or separate development environments:
1. Open `inventory.ini`.
2. Add a new hostname and its credentials under the target group:
   ```ini
   [vortex_hosts]
   vortex-prod-1 ansible_host=13.235.26.67 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/vortex-keypair.pem
   vortex-prod-2 ansible_host=15.120.35.42 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/vortex-keypair.pem
   ```
3. Execute the playbook. Ansible will deploy to all listed hosts in parallel.

---

## 🔍 Troubleshooting

### Host Inaccessibility (SSH connection drops)
If you get connection timeout errors:
* Double-check that your Elastic IP is correct in `inventory.ini`.
* Ensure that the Security Group associated with the EC2 instance allows incoming SSH connections (port 22) from your IP.
* Verify the location of your private SSH key file.

### OOM (Out-of-Memory) Container Crashes
If ClickHouse or Kafka containers exit immediately on startup:
* Inspect host RAM using `free -h`.
* Vortex databases require substantial memory. If your EC2 instance is configured with `t2.micro` (1 GiB RAM), ClickHouse and Kafka will fail to start. Upgrade the instance size (e.g. `t3.large` or `t3.xlarge`).

### Bootstrapping Logs
To check execution logs on the target EC2 host:
```bash
tail -n 100 /var/log/user-data.log
```
