# Déploiement Backend BabiCash

> Déploiement Docker sur VPS Ubuntu/Debian avec Nginx + HTTPS  
> Domaines : `pos.babicash.ci` (API/app POS) + `business.babicash.ci` (PWA ambassadeur)

---

## Prérequis

- VPS Ubuntu 22.04+ ou Debian 12+ avec accès root SSH
- Domaine pointant vers l'IP du VPS (enregistrement DNS A)
- Port 80 et 443 ouverts (firewall)

---

## 1. Installation des dépendances

```bash
ssh root@VOTRE_IP

# Mise à jour
apt update && apt upgrade -y

# Docker
curl -fsSL https://get.docker.com | sh

# Docker Compose plugin
apt install -y docker-compose-plugin

# Nginx + Certbot
apt install -y nginx certbot python3-certbot-nginx git

# Vérification
docker --version
docker compose version
nginx -v
```

---

## 2. Transfert du code

```bash
mkdir -p /opt/babicash && cd /opt/babicash

# Option A — Git
git clone <URL_REPO> .

# Option B — SCP (depuis votre machine)
# scp -r ./backend root@VOTRE_IP:/opt/babicash/backend
```

---

## 3. Configuration

```bash
cd /opt/babicash/backend
cp .env.production .env
nano .env
```

Remplir les valeurs :

| Variable | Description | Exemple |
|----------|-------------|---------|
| `POSTGRES_PASSWORD` | Mot de passe BDD fort | `xK9$mP2vL...` |
| `SECRET_KEY` | Clé JWT (64 hex) | Générer ci-dessous |
| `ALLOWED_ORIGINS` | URL frontend autorisées | `https://pos.babicash.ci,https://business.babicash.ci` |
| `API_PORT` | Port local de l'API | `8000` |
| `WORKERS` | Nombre de workers uvicorn | `2` |

**Générer une SECRET_KEY :**

```bash
openssl rand -hex 64
```

---

## 4. Lancement

```bash
cd /opt/babicash/backend
docker compose up -d --build
```

**Vérifier :**

```bash
docker compose ps
# Les 2 services (db, api) doivent être "Up (healthy)"

curl http://localhost:8000/health
# → {"status":"ok","service":"BabiCash API"}
```

---

## 5. Nginx — Reverse Proxy

```bash
nano /etc/nginx/sites-available/babicash
```

Deux blocs `server` séparés — un pour l'API (`pos.babicash.ci`), un pour la
PWA ambassadeur (`business.babicash.ci`) :

```nginx
# ── pos.babicash.ci → API / Backend ──────────────────────────────────
server {
    server_name pos.babicash.ci;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        client_max_body_size 10M;
    }
}

# ── business.babicash.ci → PWA Ambassadeur + API ────────────────────
server {
    server_name business.babicash.ci;

    # Fichiers statiques de la PWA React (build Vite)
    root /opt/babicash/ambassadeur-pwa/dist;
    index index.html;

    # Les appels API sont proxyés vers le backend
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        client_max_body_size 10M;
    }

    # SPA : toutes les routes non trouvées retournent index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache long pour les assets hashés par Vite (js, css, images)
    location ~* \.(?:js|css|woff2|ico|png|svg|jpg|jpeg|gif|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Activer :

```bash
ln -s /etc/nginx/sites-available/babicash /etc/nginx/sites-enabled/
# Retirer la config par défaut si elle conflite
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
```

---

## 6. HTTPS — Let's Encrypt

```bash
certbot --nginx -d pos.babicash.ci -d business.babicash.ci
```

Le renouvellement est automatique (cron certbot).

---

## 7. Déploiement de la PWA Ambassadeur

La PWA React (`ambassadeur-pwa/`) doit être buildée et copiée sur le VPS.

### Build local

```bash
cd ambassadeur-pwa
npm install
npm run build          # génère dist/
```

### Copie sur le VPS

```bash
# Depuis votre machine locale
scp -r dist/ root@VOTRE_IP:/opt/babicash/ambassadeur-pwa/dist
```

### Ou directement sur le VPS

```bash
cd /opt/babicash/ambassadeur-pwa
npm install
npm run build
# Les fichiers sont déjà dans /opt/babicash/ambassadeur-pwa/dist
nginx -t && systemctl restart nginx
```

### Script de déploiement rapide

```bash
cat > /opt/babicash/deploy-pwa.sh << 'EOF'
#!/bin/bash
set -euo pipefail
cd /opt/babicash/ambassadeur-pwa
echo "🔨 Building PWA ambassadeur..."
npm ci --prefer-offline
npm run build
echo "🔄 Redémarrage Nginx..."
nginx -t && systemctl restart nginx
echo "✅ PWA déployée sur business.babicash.ci"
EOF
chmod +x /opt/babicash/deploy-pwa.sh
```

---

## 8. DNS

Chez votre registrar ou panel DNS :

| Type | Nom | Valeur |
|------|-----|--------|
| A | `babicash` | `IP_DU_VPS` |

> Attendre la propagation (quelques minutes à 24h).

---

## 9. Vérification finale

```bash
# API (pos.babicash.ci)
curl https://pos.babicash.ci/health
# → {"status":"ok","service":"BabiCash API"}

curl https://pos.babicash.ci/api/v1/auth/me
# → 401 Unauthorized (normal sans token)

# PWA Ambassadeur (business.babicash.ci)
curl -s https://business.babicash.ci/ | head -5
# → <!doctype html> ... (le HTML de la PWA React)

# API Ambassadeur via le même domaine
curl https://business.babicash.ci/api/v1/ambassadeurs/me
# → 401 Unauthorized (normal sans token)
```

---

## Commandes utiles

| Action | Commande |
|--------|----------|
| Voir les logs API | `docker compose logs -f api` |
| Redémarrer l'API | `docker compose restart api` |
| Rebuild après update | `docker compose up -d --build api` |
| Shell dans le container | `docker compose exec api sh` |
| Lancer une migration | `docker compose exec api alembic upgrade head` |
| Arrêter tout | `docker compose down` |
| Arrêter + supprimer données | `docker compose down -v` |
| **Rebuild PWA ambassadeur** | `/opt/babicash/deploy-pwa.sh` |
| **Vérifier Nginx** | `nginx -t && systemctl restart nginx` |

---

## Mises à jour

```bash
cd /opt/babicash
git pull origin main

# Backend
cd backend
docker compose up -d --build api

# PWA Ambassadeur
cd /opt/babicash/ambassadeur-pwa
npm ci --prefer-offline && npm run build
nginx -t && systemctl restart nginx
```

Ou via le script tout-en-un : `./deploy-pwa.sh`

---

## Structure Docker

```
backend/
├── Dockerfile          # Image multi-stage Python 3.13
├── entrypoint.sh       # Migrations + démarrage uvicorn
├── docker-compose.yml  # Stack : PostgreSQL 16 + API
├── .dockerignore       # Fichiers exclus du build
├── .env.production     # Template variables (ne pas commiter .env)
└── app/                # Code source FastAPI
```

---

## Sécurité

- [ ] `SECRET_KEY` changée (pas la valeur par défaut)
- [ ] `POSTGRES_PASSWORD` fort et unique
- [ ] `ALLOWED_ORIGINS` restreint au domaine frontend
- [ ] Firewall : seuls ports 22, 80, 443 ouverts
- [ ] `.env` **jamais** commité dans git
