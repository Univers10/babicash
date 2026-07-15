#!/bin/bash
set -e

# ── BabiCash — Backup PostgreSQL ──────────────────────────────────────
# Usage: ./backup.sh [--keep N]
#   --keep N : garder les N derniers backups (défaut: 30)

BACKUP_DIR="/backups"
KEEP=30

while [[ $# -gt 0 ]]; do
  case $1 in
    --keep) KEEP="$2"; shift 2;;
    *) shift;;
  esac
done

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="babicash_${TIMESTAMP}.sql.gz"
FILEPATH="${BACKUP_DIR}/${FILENAME}"

echo "🔄 Backup en cours..."

pg_dump \
  --host="$POSTGRES_HOST" \
  --port="$POSTGRES_PORT" \
  --username="$POSTGRES_USER" \
  --dbname="$POSTGRES_DB" \
  --no-password \
  --format=plain \
  --verbose \
  2>/dev/null | gzip > "$FILEPATH"

SIZE=$(du -h "$FILEPATH" | cut -f1)
echo "✅ Backup terminée : ${FILENAME} (${SIZE})"

# Rotation : supprimer les anciens backups
COUNT=$(ls -1 "${BACKUP_DIR}"/babicash_*.sql.gz 2>/dev/null | wc -l)
if [ "$COUNT" -gt "$KEEP" ]; then
  DELETE_COUNT=$((COUNT - KEEP))
  ls -1t "${BACKUP_DIR}"/babicash_*.sql.gz | tail -n "$DELETE_COUNT" | xargs rm -f
  echo "🗑️  ${DELETE_COUNT} ancien(s) backup(s) supprimé(s) (conservation : ${KEEP})"
fi

# Lister les backups restantes
echo ""
echo "📋 Backups disponibles :"
ls -lh "${BACKUP_DIR}"/babicash_*.sql.gz 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'
