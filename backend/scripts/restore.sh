#!/bin/bash
set -e

# ── BabiCash — Restore PostgreSQL ─────────────────────────────────────
# Usage: ./restore.sh [backup_file]
#   Sans argument : liste les backups disponibles
#   Avec argument : restaure le fichier sélectionné

BACKUP_DIR="/backups"

if [ -z "$1" ]; then
  echo "📋 Backups disponibles :"
  echo ""
  ls -lh "${BACKUP_DIR}"/babicash_*.sql.gz 2>/dev/null | awk '{print NR". " $9 " (" $5 ")"}'
  echo ""
  echo "Usage: ./restore.sh <fichier>"
  echo "   ou: ./restore.sh latest"
  exit 0
fi

if [ "$1" = "latest" ]; then
  FILEPATH=$(ls -1t "${BACKUP_DIR}"/babicash_*.sql.gz | head -1)
  if [ -z "$FILEPATH" ]; then
    echo "❌ Aucun backup trouvé"
    exit 1
  fi
else
  FILEPATH="$1"
  if [ ! -f "$FILEPATH" ]; then
    # Chercher dans le dossier backups
    FILEPATH="${BACKUP_DIR}/$1"
  fi
fi

if [ ! -f "$FILEPATH" ]; then
  echo "❌ Fichier non trouvé : $1"
  exit 1
fi

echo "⚠️  ATTENTION : Cette opération va ÉCRASER la base de données actuelle!"
echo "   Fichier : $(basename $FILEPATH)"
echo "   Taille  : $(du -h "$FILEPATH" | cut -f1)"
echo ""
read -p "Confirmer ? (oui/non) : " CONFIRM

if [ "$CONFIRM" != "oui" ]; then
  echo "❌ Annulé"
  exit 1
fi

echo "🔄 Restauration en cours..."

# Supprimer les tables existantes
echo "   → Suppression des tables existantes..."
psql \
  --host="$POSTGRES_HOST" \
  --port="$POSTGRES_PORT" \
  --username="$POSTGRES_USER" \
  --dbname="$POSTGRES_DB" \
  --no-password \
  -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" \
  2>/dev/null

# Restaurer
gunzip -c "$FILEPATH" | psql \
  --host="$POSTGRES_HOST" \
  --port="$POSTGRES_PORT" \
  --username="$POSTGRES_USER" \
  --dbname="$POSTGRES_DB" \
  --no-password \
  --quiet \
  2>/dev/null

echo "✅ Restauration terminée depuis $(basename $FILEPATH)"
