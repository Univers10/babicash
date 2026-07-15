#!/bin/bash
# ── BabiCash — Backup automatique cron ────────────────────────────────
# S'exécute via cron dans le container
# crontab: 0 2 * * * /app/scripts/cron_backup.sh

BACKUP_DIR="/backups"
LOG_FILE="/app/logs/backup.log"

mkdir -p /app/logs

echo "$(date '+%Y-%m-%d %H:%M:%S') — Début backup automatique" >> "$LOG_FILE"

/app/scripts/backup.sh --keep 30 >> "$LOG_FILE" 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') — Fin backup automatique" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
