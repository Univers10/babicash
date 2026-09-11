# GEMINI.md — Contexte Gemini pour BabiCash

> Source canonique : **`AGENTS.md`** (à la racine). Lis-le avant toute modification.

## Points essentiels

- **Monorepo** BabiCash : `frontend/` (Flutter + Drift/SQLite offline-first + Riverpod), `backend/` (FastAPI + SQLAlchemy async + PostgreSQL + admin web Jinja), `ambassadeur-pwa/` (React + Vite + TS), `landing/` (statique SEO).
- **Règles** :
  1. Jamais d'édition des fichiers générés (`*.g.dart`, `*.freezed.dart`, `*_database.g.dart`) → `dart run build_runner build --delete-conflicting-outputs`.
  2. Cloisonnement multi-tenant par `boutique_id` (toujours dérivé du token/provider).
  3. Offline-first : écriture locale en premier, pas de blocage réseau en UI.
  4. Montants en `Decimal`/`Numeric(12,2)` côté backend, jamais de float.
  5. Validation : `pytest` (backend) et `flutter analyze --no-fatal-infos` (frontend).
- **Domaines** : POS/API `https://pos.babicash.ci` · PWA ambassadeur/API `https://business.babicash.ci` · vitrine `https://babicash.ci`.
- Commits conventionnels (`feat:`, `fix:`, `docs:`, `refactor:`), branche `main`.