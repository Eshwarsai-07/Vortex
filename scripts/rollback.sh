#!/bin/bash
set -e

echo "=== Vortex Emergency Rollback Script ==="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="$PROJECT_ROOT/services"

echo "Navigating to project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

echo "Rolling back git repository to HEAD~1..."
git reset --hard HEAD~1

echo "Rebuilding container infrastructure from previous commit..."
cd "$SERVICES_DIR"
docker compose down --remove-orphans || true
docker compose up -d --build

echo "Executing health check verification..."
bash "$PROJECT_ROOT/scripts/health-check.sh"

echo "=== Rollback Execution Completed ==="
