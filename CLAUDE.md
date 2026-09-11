# CLAUDE.md

> Ce fichier guide Claude Code sur le dépôt BabiCash. La **source canonique** complète est `AGENTS.md` (contexte partagé par tous les outils IA) — si une de ses informations contredit ce fichier, suivre `AGENTS.md` / le code source.

## Vue d'ensemble

BabiCash est une **plateforme de gestion commerciale multi-boutique (POS) offline-first** pour le commerce de proximité en Côte d'Ivoire : caisse (POS), stock, clients/fournisseurs, sessions de caisse anti-fraude, crédits, abonnements freemium, programme d'ambassadeurs (parrainage) et boutique en ligne par commerce.

- Toutes les écritures vont d'abord dans **SQLite local (Drift)** puis se synchronisent au backend dès que le réseau revient.
- **Multi-tenant** : cloisonnement strict par `boutique_id`.
- Monorepo : `frontend/` (Flutter), `backend/` (FastAPI + admin web), `ambassadeur-pwa/` (React), `landing/` (site statique), `docs/`.

## Commandes

### Backend (depuis `backend/`)
```bash
.venv/Scripts/python.exe -m pytest tests/        # tests (SQLite in-memory, Windows)
.venv/Scripts/python.exe -m alembic upgrade head # migrations
.venv/Scripts/python.exe -m uvicorn app.main:app --reload
docker compose up -d --build                    # stack Docker PostgreSQL + API
```
Push sur `main` → auto-deploy backend (SSH + Docker via GitHub Actions). Pas d'auto-deploy Flutter ni PWA.

### Frontend (depuis `frontend/`)
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # OBLIGATOIRE après modif Drift/Freezed
flutter run
flutter analyze --no-fatal-infos
flutter test --coverage
flutter build apk --release
```
> ⚠️ Ne jamais éditer `*.g.dart`, `*.freezed.dart`, `*.drift.dart` — re-run `build_runner`.

## Architecture

```
UI (Screens + Widgets)
   ↓
State (Riverpod AsyncNotifier / StateNotifier)
   ↓
Data — Local (Drift/SQLite) + Remote (Dio REST)
   ↓
Core (theme, router, network, storage, errors)
```

- `lib/core/` — Dio client, go_router, secure storage, Material 3 theme, erreurs.
- `lib/data/` — base Drift (`local/`), modèles Freezed (`models/`), clients Dio (`remote/`).
- `lib/features/` — un dossier par feature : `auth`, `caisse`, `stock`, `tiers`, `sessions`, `ventes`, `dashboard`, `users` (gérants), `abonnements`, `settings`, `shop` (boutique en ligne), `boutiques`, `sync`.
- `lib/shared/` — shell bottom-nav, widgets réutilisables.

### State & sync
- Providers notables : `authStateProvider`, `currentBoutiqueIdProvider`, `syncInitProvider`, `syncServiceProvider` (`pushPending()` / `pullCatalogue()`), `caisseProvider`, `sessionsProvider`.
- **Offline-first** : écriture SQLite `synced = false` → reconnexion `connectivity_plus` → push → `synced = true` ; `pullCatalogue()` met à jour produits/catégories.

### API client (Dio)
Base URL prod : `https://pos.babicash.ci/api/v1`. Overrides dev : `http://192.168.x.x:8000` (LAN) / `http://10.0.2.2:8000` (émulateur). JWT injecté par interceptor ; 401 → session nettoyée (tables Drift vidées).

## Backend (hors `frontend/`)
- FastAPI · SQLAlchemy 2 async · PostgreSQL 16 · Alembic · PyJWT (24 h, claim `token_version`) · bcrypt · rate limiting · CSRF/cookie secure sur l'admin.
- Rôles API : `OWNER` / `MANAGER` ; backoffice admin séparé (`app/admin/` : Jinja + sessions cookie).
- Tables : `users`, `boutiques`, `categories`, `produits`, `comptes_tiers`, `sessions_caisse`, `ventes`, `lignes_vente`, `abonnements`, `mouvements_stock`, `recu_configs`, `transactions_caisse`, `ambassadeurs`, `notifications`, `push_subscriptions`, `paiements_abonnement`, `payouts`, `commissions_parrainage`, `landing_leads`, `shop_produits`, `commandes_shop`, `commandes_shop_lignes`.
- Règle : marge côté serveur, `Decimal` pour l'argent, idempotence via `id_local_smartphone`, CMP pour entrées de stock.

## Design System
- **Primaire** `#1B6B2F` (vert) · **Accent** `#F5A623` (orange) · fond `#F7F7F5` · texte `#3D1F00`.
- **Font** Inter (400/500/600/700). Boutons 52 px, radius cartes 16 px / inputs 8 px.
- Constantes de spacing dans `lib/core/theme/app_spacing.dart` — pas de `SizedBox` ad-hoc. Utiliser les constantes/valeurs existantes.

## CI/CD
`.github/workflows/` : `backend-ci.yml` (pytest + ruff + build Docker), `backend-deploy.yml` (main → VPS), `frontend-ci.yml` (analyze + test + coverage + build APK/Web).

## Règles pour l'agent
1. Ne jamais éditer les fichiers générés ; re-run `build_runner`.
2. Toujours récupérer `boutique_id` du contexte (token/`currentBoutiqueIdProvider`), cloisonnement multi-tenant.
3. Offline-first : écriture locale d'abord, jamais de blocage réseau en UI.
4. Montants : `Decimal` côté backend, jamais de float.
5. Après backend : `pytest`. Après Flutter : `flutter analyze --no-fatal-infos`. Après Drift/Freezed : `build_runner`.
6. Commits conventionnels (`feat:`, `fix:`, `docs:`, `refactor:`), branche `main`.
7. Consulter avant de coder : `docs/design-*.md`, `backend/DEPLOY.md`.