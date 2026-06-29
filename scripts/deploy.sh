#!/bin/bash
set -e

echo "=== Vortex Production Deployment Script ==="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="$PROJECT_ROOT/services"

echo "Navigating to services directory: $SERVICES_DIR"
cd "$SERVICES_DIR"

echo "Pulling latest git changes..."
git pull origin main || true

echo "Rebuilding and restarting container infrastructure..."
docker compose down --remove-orphans || true
docker compose up -d --build

echo "Waiting for services to initialize..."
sleep 15

echo "Executing health check verification..."
bash "$PROJECT_ROOT/scripts/health-check.sh"

echo "=== Deployment Completed Successfully ==="
