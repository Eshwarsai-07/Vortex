#!/bin/bash
set -e

# Redirect output to user-data log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1

echo "Beginning Vortex Server Bootstrap..."

# Update System Packages
apt-get update -y
apt-get upgrade -y
apt-get install -y curl git jq unzip apt-transport-https ca-certificates gnupg lsb-release

# Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable Docker Service
systemctl enable docker
systemctl start docker

# Configure SSH Authorized Keys for Ubuntu user
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPh43g/zlagQQPFQBPK88D36g6oSpw/UkJVgacaCZIoO eshwar@qcecuring" >> /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

echo "Vortex Server Bootstrap Completed Successfully!"
