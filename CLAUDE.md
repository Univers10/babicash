# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BabiCash is a multi-tenant POS (point-of-sale) and commercial management Flutter app targeting small businesses in West Africa. It follows an **offline-first architecture**: all writes go to local SQLite (Drift) immediately, then sync to the backend when connectivity is available.

The Flutter frontend lives in `frontend/`. The backend lives in `backend/` (FastAPI + SQLAlchemy 2 async + Alembic, PostgreSQL in production, SQLite/aiosqlite in tests).

## Common Commands

### Backend (from `backend/`)

```bash
# Virtualenv: backend/.venv (hidden directory)
.venv/Scripts/python.exe -m pytest tests/     # run tests (Windows)

# Migrations
.venv/Scripts/python.exe -m alembic upgrade head

# Dev server
.venv/Scripts/python.exe -m uvicorn app.main:app --reload
```

> **Deploy**: push to `main` auto-deploys the backend (SSH + Docker via GitHub Actions). The frontend has no auto-deploy.

### Frontend (from `frontend/`)

```bash
# Install dependencies
flutter pub get

# Code generation — REQUIRED after modifying Drift tables or Freezed models
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Lint
flutter analyze --no-fatal-infos

# Tests
flutter test --coverage

# Build
flutter build apk --release
flutter build web --release
```

> **Important**: Never edit `*.g.dart` or `*.freezed.dart` files manually — they are generated. Re-run `build_runner` instead.

## Architecture

### Layer overview

```
UI (Screens + Widgets)
       ↓
State (Riverpod AsyncNotifierProviders)
       ↓
Data — Local (Drift/SQLite) + Remote (Dio REST API)
       ↓
Core (theme, router, network, storage, errors)
```

### Key directories

- `lib/core/` — Dio client, go_router, secure storage, Material 3 theme, error types
- `lib/data/` — Drift database (`local/`), Freezed models (`models/`), Dio API services (`remote/`)
- `lib/features/` — One folder per feature (`auth`, `caisse`, `dashboard`, `stock`, `tiers`, `sessions`, `ventes`, `sync`, `abonnements`)
- `lib/shared/` — Bottom-nav shell screen, shared providers, reusable widgets

### State management — Riverpod

Each feature exposes `AsyncNotifierProvider`(s) in its own `providers/` folder. Notable providers:

| Provider | Purpose |
|---|---|
| `authStateProvider` | Session state, login/register, role-based redirect |
| `currentBoutiqueIdProvider` | Active shop context (all DB queries filter by this) |
| `syncInitProvider` | Auto-initializes sync, listens for connectivity changes |
| `syncServiceProvider` | `pushPending()` / `pullCatalogue()` logic |
| `caisseProvider` | Cart state, sale recording |
| `sessionsProvider` | Cash session open/close |

### Routing (go_router)

Defined in `lib/core/router/app_router.dart`. After login, the router redirects based on `SessionUser.role`:
- `OWNER` → `/dashboard`
- `MANAGER` → `/caisse`

### Database (Drift)

Tables: `LocalProduits`, `LocalCategories`, `LocalVentes`, `LocalLignesVente`, `LocalDepenses`, `LocalSessions`, `LocalTiers`. Every table has a `synced` boolean. All queries are scoped by `boutique_id`.

### Offline-first sync flow

1. Write to SQLite with `synced = false`
2. On connectivity restore (or app init), `SyncService.pushPending()` sends unsynced records
3. Backend confirms → mark `synced = true`
4. `SyncService.pullCatalogue()` fetches updated catalog

### API client (Dio)

Base URL: `https://babicash.ecomotionafricaci.com/api/v1`
Dev overrides: `http://192.168.1.29:8000` (LAN) / `http://10.0.2.2:8000` (emulator)

JWT is injected automatically by an interceptor. 401 responses clear the session.

## Design System

- **Primary**: `#1B6B2F` (green), **Accent**: `#F5A623` (orange)
- **Font**: Inter (400/500/600/700) — defined in `lib/core/theme/`
- **Button height**: 52 px, **border radius**: 16 px (cards) / 8 px (inputs)
- Spacing constants live in `app_spacing.dart`; do not use ad-hoc `SizedBox` sizes

## CI/CD

GitHub Actions (`.github/workflows/frontend-ci.yml`):
- **PR**: `flutter analyze --no-fatal-infos` + `flutter test --coverage` + Codecov
- **main**: above + build APK + build web, both uploaded as artifacts
