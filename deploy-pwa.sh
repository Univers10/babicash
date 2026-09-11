#!/bin/bash
set -euo pipefail

cd /opt/babicash/ambassadeur-pwa

echo "🔨 Building PWA ambassadeur..."
npm ci --prefer-offline
npm run build

echo "🔄 Redémarrage Nginx..."
nginx -t && systemctl restart nginx

echo "✅ PWA déployée sur business.babicash.ci"
