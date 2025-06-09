#!/bin/bash
set -e

echo "Creating cron"

env | grep -E 'POSTGRES_|^BACKUP_RETENTION_COUNT=' > /etc/environment

echo "SHELL=/bin/bash" > /etc/cron.d/backup
echo "BASH_ENV=/etc/environment" >> /etc/cron.d/backup
echo "$BACKUP_INTERVAL_CRON root /backup.sh >> /var/log/cron.log 2>&1" | envsubst >> /etc/cron.d/backup

chmod 0644 /etc/cron.d/backup

touch /var/log/cron.log
cron
tail -f /var/log/cron.log