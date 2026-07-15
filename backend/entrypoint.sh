#!/bin/sh
set -e

echo "🔄 Running database migrations..."
alembic upgrade head

echo "👤 Seeding admin account..."
python -m scripts.seed_admin

echo "💾 Backup initial de la base..."
mkdir -p /backups /app/logs
/app/scripts/backup.sh --keep 30 || echo "⚠️  Backup initial ignoré (pas critique)"

echo "🚀 Starting BabiCash API..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers ${WORKERS:-2}
