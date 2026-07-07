#!/bin/bash
# Vortex EC2 Bootstrap Script
set -e

# Redirect output for troubleshooting
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "========================================="
echo "🚀 Starting Vortex Node Bootstrapping..."
echo "========================================="

# Allocate swap space to protect against OOM during container builds
if [ ! -f /swapfile ]; then
  echo "💾 Allocating 4GB Swap Space..."
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
  echo "✅ Swap space allocated successfully."
fi

# Helper function to run a command with retries on failure (crucial for apt/curl operations)
retry_cmd() {
  local max_attempts=5
  local delay=5
  local attempt=1
  until "$@"; do
    if (( attempt == max_attempts )); then
      echo "❌ Command failed after $max_attempts attempts: '$*'"
      return 1
    fi
    echo "⚠️ Command failed: '$*'. Retrying in $delay seconds (Attempt $attempt/$max_attempts)..."
    sleep $delay
    ((attempt++))
  done
}

echo "Updating package lists..."
retry_cmd apt-get update -y

echo "Installing prerequisites..."
retry_cmd apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    git \
    software-properties-common

echo "Adding Docker's official GPG key..."
mkdir -p /etc/apt/keyrings
retry_cmd curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository source..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package lists with Docker repository..."
retry_cmd apt-get update -y

echo "Installing Docker engine and plugins..."
retry_cmd apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "Enabling and starting Docker services..."
systemctl start docker
systemctl enable docker

echo "Adding 'ubuntu' user to 'docker' group..."
usermod -aG docker ubuntu

# Post-installation validations to ensure subsequent deployment phases don't fail silently
echo "🔎 Verifying installations..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker installation check failed."
    exit 1
fi
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose plugin check failed."
    exit 1
fi
if ! command -v git &> /dev/null; then
    echo "❌ Git installation check failed."
    exit 1
fi

echo "========================================="
echo "✅ Bootstrapping Completed Successfully!"
echo "========================================="
