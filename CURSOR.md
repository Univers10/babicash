# CURSOR.md — Contexte Cursor pour BabiCash

> Source canonique : **`AGENTS.md`** (à la racine). Lis-le avant toute modification ; il décrit l'état actuel du code, les commandes et les règles (offline-first, multi-tenant, montants en Decimal, ne jamais éditer les fichiers générés `*.g.dart`).

## Résumé rapide

- **Monorepo** : `frontend/` (Flutter + Drift offline-first), `backend/` (FastAPI + PostgreSQL + admin web), `ambassadeur-pwa/` (React + Vite), `landing/` (site statique SEO).
- **Contraintes clés** :
  - Après une modification Drift/Freezed dans `frontend/` → `dart run build_runner build --delete-conflicting-outputs`.
  - Toujours cloisonner les requêtes par `boutique_id` (multi-tenant).
  - Écriture locale d'abord (offline-first) ; jamais de blocage réseau en UI.
  - Jamais de float pour de l'argent (Decimal côté backend).
  - Valider : `pytest` (backend), `flutter analyze --no-fatal-infos` (frontend).
- **URLs** : POS + API `https://pos.babicash.ci`, PWA ambassadeur + API `https://business.babicash.ci`, vitrine `https://babicash.ci`, repo `https://github.com/Univers10/babicash`.