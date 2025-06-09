#!/bin/bash
set -eo pipefail

export PGPASSWORD="$POSTGRES_PASSWORD"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/backups"
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"

echo "Starting backup for [$(date)]"
pg_dump -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" > "$BACKUP_FILE"
echo "Backup created"

echo "cleaning old backups now"
cd "$BACKUP_DIR"
BACKUPS_KEEPED=$((BACKUP_RETENTION_COUNT + 1))
ls -t | grep 'backup_.*\.sql' | tail -n +$BACKUPS_KEEPED | xargs -r rm -fv
echo "CLINING FINISHED"