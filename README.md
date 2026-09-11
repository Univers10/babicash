# BabiCash 💰

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](frontend/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-009688?logo=fastapi)](backend/)
[![Python](https://img.shields.io/badge/Python-3.13-3776AB?logo=python)](backend/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)](backend/)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)](backend/)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](ambassadeur-pwa/)
[![License](https://img.shields.io/badge/License-propri%C3%A9taire-orange)]()

**La plateforme de gestion commerciale multi-boutique des commerçants de proximité en Côte d'Ivoire.**

BabiCash aide les petits commerces (cosmétiques, quincailleries, dépôts, grossistes) à tenir leur caisse, leur stock et leurs crédits — même **sans connexion internet** — tout en donnant aux propriétaires une vue consolidée de toutes leurs boutiques.

> *English:* Multi-shop POS & business management for West-African merchants. 100 % offline-first, fraud-resistant cash sessions, WhatsApp receipts, thermal printing, freemium subscriptions, referral ambassador program and an online store per shop.

---

## 🎯 Pourquoi BabiCash

| Problème terrain | Solution BabiCash |
|---|---|
| Marchandage (prix négocié) | Prix modifiable à la vente, marge recalculée côté serveur, alerte **vente à perte** |
| Connectivité faible / pas d'internet | **Offline-first** : SQLite local (Drift) + sync auto dès reconnexion |
| Coulage de caisse des employés | **Sessions de caisse** ouvertes/fermées avec réconciliation tiroir |
| Crédits clients ("Doit") & dettes fournisseurs | Soldes suivis, paiements/remboursements tracés |
| Propriétaires multi-boutiques | Dashboard consolidé multi-boutique + performance par boutique |
| Papier & habitudes locales | Reçu PDF + partage **WhatsApp**, impression thermique Bluetooth |

---

## 🧱 Architecture (offline-first)

```
App Flutter (POS)                         React PWA (ambassadeur)        Site vitrine
┌────────────────────────┐                ┌──────────────────┐           ┌──────────┐
│ UI (Riverpod, Material 3)              │   business.      │           │  babi-   │
│ ┌────────┐  ┌────────┐                 │   babicash.ci    │           │  cash.ci │
│ │ Drift/ │  │ Dio    │                 └────────┬─────────┘           └────┬─────┘
│ │ SQLite │  │ (JWT)  │                        │ HTTPS                     │ leads
│ └────┬───┘  └────┬───┘                        ▼                           ▼
│      │ sync push/pull                        ┌─────────────────────────────────┐
│      └───────────► │ POST /sync/push ◄───────┤   Backend FastAPI (Docker)       │
│                    │ GET  /sync/pull │       │  SQLAlchemy 2 async · Alembic     │
│                    └───────┬─────────┘       │  JWT · rate limiting · CSRF       │
│                            ▼                 │  Admin backoffice (Jinja)         │
│                    PostgreSQL 16 (multi-tenant par boutique_id)                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

- **Multi-tenant** : cloisonnement strict par `boutique_id` (un OWNER n'accède qu'à ses boutiques, un MANAGER est verrouillé sur la sienne).
- **Idempotence** de la sync par `id_local_smartphone` (UNIQUE) — un push rejoué ne duplique rien.

---

## 🧩 Écosystème

| Boutique | Techno | Cible | URL |
|---|---|---|---|
| [`frontend/`](frontend/) | Flutter + Riverpod + Drift + Dio | App POS Android/iOS | `pos.babicash.ci` |
| [`backend/`](backend/) | FastAPI + SQLAlchemy async + PostgreSQL + admin Jinja | API + backoffice | — |
| [`ambassadeur-pwa/`](ambassadeur-pwa/) | React 18 + Vite + TS | PWA ambassadeurs (parrainage) | `business.babicash.ci` |
| [`landing/`](landing/) | HTML/JS/CSS statique | Site vitrine SEO + leads | `babicash.ci` |

---

## 📦 Démarrage rapide

### Backend (développement local)

```bash
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env          # (ou .env.production comme template)
docker compose up -d            # PostgreSQL 16
.venv\Scripts\python.exe -m alembic upgrade head
.venv\Scripts\python.exe -m app.seed    # données de démo
.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

> Docs : [backend/README.md](backend/README.md) · [backend/DEPLOY.md](backend/DEPLOY.md)

### Frontend Flutter

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère les fichiers *.g.dart
flutter run
```

> Docs : [frontend/README.md](frontend/README.md)

### PWA Ambassadeur

```bash
cd ambassadeur-pwa
npm install
cp .env.example .env
npm run dev                     # http://localhost:5173
```

> Docs : [ambassadeur-pwa/README.md](ambassadeur-pwa/README.md)

---

## 🔑 Rôles & authentification

| Rôle | Accès | Connexion |
|---|---|---|
| **OWNER** (Le Boss) | Dashboard consolidé, toutes ses boutiques | Email + mot de passe · Google · PIN (téléphone) |
| **MANAGER** (Gérant) | Verrouillé sur une boutique (caisse, stock, sessions) | Téléphone + **code PIN 4 chiffres** |
| **Admin** (BabiCash) | Backoffice web séparé (`app/admin/`) | Sessions cookie + CSRF |

Hors-ligne : après la première connexion, le PIN est validé **localement** (hash), l'app se verrouille/déverrouille sans réseau.

---

## ✨ Principales fonctionnalités

- **Caisse (POS)** : catalogue, mode calculatrice, numpad, prix négocié, lots, panier, ticket.
- **Stock** : produits, catégories colorées, mouvements, alertes rupture/stock bas, CMP à la réception.
- **Clients & fournisseurs** : soldes "Doit", paiements, remboursements.
- **Sessions de caisse** : ouverture/fermeture, réconciliation (théorique vs déclaré), rapport.
- **Multi-boutique OWNER** : dashboard consolidé, performance par boutique.
- **Freemium** : plan FREE (20 ventes/mois) / PRO (illimité), catalogue des offres.
- **Boutique en ligne** : chaque commerce peut exposer son catalogue et recevoir des commandes.
- **Ambassadeurs** : parrainage, commissions, versements (plafond 200 k FCFA), notifications push.
- **Reçus** : PDF + partage WhatsApp + impression thermique ESC/POS Bluetooth.

---

## 📚 Documentation

| Doc | Contenu |
|---|---|
| [AGENTS.md](AGENTS.md) | Contexte IA canonique (état actuel du code, commandes, règles) |
| [DOSSIER_TECHNIQUE.md](DOSSIER_TECHNIQUE.md) | Dossier technique global (partiellement historique) |
| [SECURITY_HARDENING.md](SECURITY_HARDENING.md) | Audit sécurité (JWT, rate limiting, CSRF, non-root…) |
| [CI_CD.md](CI_CD.md) | Pipelines GitHub Actions |
| [backend/DEPLOY.md](backend/DEPLOY.md) | Déploiement Docker + Nginx + HTTPS |
| [tdr.md](tdr.md) | Termes de référence du projet |
| [docs/](docs/) | Docs de conception (`design-*.md`, retour bêta) |

Pour les agents IA : `AGENTS.md` est la **source canonique** ; `CLAUDE.md`, `CURSOR.md`, `GEMINI.md`, `.cursorrules`, `.windsurfrules` et `.github/copilot-instructions.md` pointent vers lui.

---

## 🧪 Qualité & CI

- Backend : **pytest** (~22 fichiers, SQLite in-memory) + **ruff** → `.github/workflows/backend-ci.yml`
- Frontend : **flutter analyze** + **flutter test --coverage** (Codecov) + build APK/Web → `frontend-ci.yml`
- Déploiement backend auto sur `main` → VPS Docker (`backend-deploy.yml`)
- Règles de dev : jamais de float pour l'argent (Decimal), UUID partout, `id_local_smartphone` UNIQUE, commits conventionnels sur `main`.

---

## 🗺️ Roadmap

- [x] Caisse, stock, tiers, sessions, sync offline-first, dashboard multi-boutique
- [x] Gestion des gérants, abonnements FREE/PRO, boutique en ligne, programme ambassadeurs
- [ ] Paiement Mobile Money (Wave/Orange/MTN) pour les abonnements
- [ ] Mot de passe/rappel PIN, notifications stock bas
- [ ] iOS + internationalisation + mode sombre

---

© BabiCash · Côte d'Ivoire 🇨🇮 · [pos.babicash.ci](https://pos.babicash.ci) · [business.babicash.ci](https://business.babicash.ci) · [babicash.ci](https://babicash.ci)