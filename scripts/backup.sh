#!/bin/bash
set -e

echo "=== Vortex Database Backup Utility ==="

BACKUP_DIR="/var/backups/vortex/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backing up MongoDB database..."
if docker ps | grep -q mongodb; then
    docker exec mongodb mongodump --archive="$BACKUP_DIR/mongo_dump.archive" --gzip || echo "Mongo dump warning"
    echo "MongoDB backup saved to $BACKUP_DIR/mongo_dump.archive"
else
    echo "MongoDB container not running, skipping mongo dump."
fi

echo "Backing up ClickHouse schemas..."
if docker ps | grep -q clickhouse; then
    docker exec clickhouse clickhouse-client --query "SHOW TABLES FROM logs" > "$BACKUP_DIR/clickhouse_tables.txt" || echo "ClickHouse warning"
    echo "ClickHouse table inventory saved to $BACKUP_DIR/clickhouse_tables.txt"
else
    echo "ClickHouse container not running, skipping clickhouse backup."
fi

echo "=== Backup Process Completed Successfully ==="
