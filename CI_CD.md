# BabiCash — CI/CD Configuration

> Fichiers `.yml` dans `.github/workflows/` du repo GitHub.
> Secrets GitHub (Settings → Secrets → Actions) à configurer en fin de fichier.

---

## 1. Backend CI — Tests & Lint

**Fichier :** `.github/workflows/backend-ci.yml`

```yaml
name: Backend CI

on:
  push:
    branches: [main, develop]
    paths:
      - "backend/**"
  pull_request:
    branches: [main, develop]
    paths:
      - "backend/**"

defaults:
  run:
    working-directory: backend

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: babicash
          POSTGRES_PASSWORD: babicash
          POSTGRES_DB: babicash
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U babicash"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 5

    env:
      DATABASE_URL: postgresql+asyncpg://babicash:babicash@localhost:5432/babicash
      SECRET_KEY: ci-test-secret-key-do-not-use-in-production

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.13"
          cache: pip

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Lint — ruff
        run: |
          pip install ruff
          ruff check .

      - name: Run migrations
        run: alembic upgrade head

      - name: Run tests
        run: pytest -v --tb=short

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t babicash-api:${{ github.sha }} backend/

      - name: Save image artifact
        run: docker save babicash-api:${{ github.sha }} | gzip > /tmp/babicash-api.tar.gz

      - uses: actions/upload-artifact@v4
        with:
          name: docker-image
          path: /tmp/babicash-api.tar.gz
          retention-days: 3
```

---

## 2. Backend CD — Deploy sur VPS

**Fichier :** `.github/workflows/backend-deploy.yml`

```yaml
name: Backend Deploy

on:
  push:
    branches: [main]
    paths:
      - "backend/**"
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_SSH_KEY }}
          script: |
            set -e
            cd /opt/babicash

            echo "📥 Pulling latest code..."
            git pull origin main

            echo "🔨 Building & restarting backend..."
            cd backend
            docker compose down
            docker compose build --no-cache api
            docker compose up -d db api

            echo "⏳ Waiting for API to be healthy..."
            sleep 15

            echo "🔄 Running migrations..."
            docker compose exec api alembic upgrade head

            echo "🧹 Cleaning up old images..."
            docker image prune -f

            echo "✅ Backend deploy complete"
```

---

## 3. Frontend CI — Flutter Test & Build

**Fichier :** `.github/workflows/frontend-ci.yml`

```yaml
name: Frontend CI

on:
  push:
    branches: [main, develop]
    paths:
      - "frontend/**"
  pull_request:
    branches: [main, develop]
    paths:
      - "frontend/**"

defaults:
  run:
    working-directory: frontend

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze --no-fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        if: github.event_name == 'pull_request'
        uses: codecov/codecov-action@v4
        with:
          files: frontend/coverage/lcov.info
          flags: flutter

  build-apk:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"
          channel: stable
          cache: true

      - name: Build APK
        run: flutter build apk --release

      - uses: actions/upload-artifact@v4
        with:
          name: babicash-apk
          path: frontend/build/app/outputs/flutter-apk/app-release.apk
          retention-days: 14

  build-web:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"
          channel: stable
          cache: true

      - name: Build Web
        run: flutter build web --release

      - uses: actions/upload-artifact@v4
        with:
          name: babicash-web
          path: frontend/build/web/
          retention-days: 14
```

---

## 4. Secrets GitHub à configurer

Aller dans **Settings → Secrets and variables → Actions** du repo GitHub.

| Secret | Description | Valeur |
|---|---|---|
| `DEPLOY_HOST` | IP du VPS de production | `195.110.35.224` |
| `DEPLOY_USER` | Utilisateur SSH du serveur | `root` |
| `DEPLOY_SSH_KEY` | Clé SSH privée (ed25519) | `-----BEGIN OPENSSH...` |

---

## 5. Arborescence

```
.github/
  workflows/
    backend-ci.yml        # Tests + lint + build Docker
    backend-deploy.yml    # Deploy SSH sur VPS
    frontend-ci.yml       # Analyse + tests + build APK/Web
```

---

## 6. Lancement manuel

```bash
# Backend — tests locaux
cd backend
DATABASE_URL=postgresql+asyncpg://babicash:babicash@localhost:5432/babicash \
SECRET_KEY=test \
pytest -v

# Frontend — tests locaux
cd frontend
flutter test

# Deploy manuel (via SSH)
ssh root@195.110.35.224 "cd /opt/babicash && git pull && cd backend && docker compose up -d --build"
```

---

## 7. Variables d'environnement (.env pour CI)

Le backend CI utilise les variables en dur dans le workflow. Pour la prod, garde le `.env.production` sur le serveur :

```
DATABASE_URL=postgresql+asyncpg://babicash:<password>@db:5432/babicash
SECRET_KEY=<64-hex-chars>
ALLOWED_ORIGINS=https://babicash.ecomotionafricaci.com
WORKERS=2
```
