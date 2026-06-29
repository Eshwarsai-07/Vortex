#!/bin/bash
set -e

echo "=== Vortex Container & Service Health Check ==="

HOST="http://localhost"
FAILED=0

check_service() {
    local name="$1"
    local url="$2"
    echo -n "Checking $name ($url)... "
    if curl -s -f "$url" > /dev/null; then
        echo "✅ UP"
    else
        echo "❌ DOWN"
        FAILED=1
    fi
}

check_service "Backend API Health" "$HOST:5000/health"
check_service "Nginx Gateway" "$HOST:80/health"
check_service "Redpanda Console UI" "$HOST:8080"
check_service "ClickHouse HTTP Ping" "$HOST:8123/ping"

if [ $FAILED -eq 0 ]; then
    echo "=== All Services Healthy! ==="
    exit 0
else
    echo "=== Health Check Failed for One or More Services ==="
    exit 1
fi
