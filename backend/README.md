# BabiCash — Backend (FastAPI)

API REST + backoffice admin de la plateforme de gestion commerciale multi-boutique BabiCash.

> Contexte IA et règles globales : voir `AGENTS.md` à la racine du repo.

## Stack
- **FastAPI** (Python 3.13), **Uvicorn**
- **SQLAlchemy 2.0** (async) + **Alembic** (migrations)
- **PostgreSQL 16** (prod) / SQLite in-memory (tests)
- **PyJWT** (JWT 24 h, claim `token_version`), **bcrypt**, **rate limiting**, **CSRF**
- Rôles API : `OWNER` / `MANAGER` ; backoffice admin séparé (`app/admin/`, Jinja + sessions cookie)
- **Docker** (multi-stage, non-root) + GitHub Actions CI/CD

## Architecture
```
app/
├── main.py            # App FastAPI + /health
├── deps.py            # Dépendances auth/rôles
├── access.py          # Cloisonnement multi-tenant (get_authorized_boutique)
├── core/              # config, db (async), security (JWT), csrf, rate_limit
├── models/            # Modèles SQLAlchemy 2.0 (models.py)
├── schemas/           # Modèles Pydantic (auth, sync, recu, shop, ambassadeur…)
├── api/v1/            # Routeurs : auth, oauth, users, boutiques, produits, categories,
│                      #   tiers, sessions, sync, ventes, dashboard, analytics, abonnements,
│                      #   mouvements_stock, shop, ambassadeurs, landing_leads, uploads
├── services/          # Logique métier (sync, dashboard, session, abonnement,
│                      #   analytics, ambassadeur, parrainage, paiement, notification)
├── admin/             # Backoffice web (routes, deps, templates Jinja)
└── templates/         # Templates du backoffice
alembic/               # Migrations
tests/                 # Tests pytest (SQLite in-memory)
```

## Démarrage

### 1. Environnement
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env   # définir SECRET_KEY (≥32 caractères) avant le boot
```

### 2. Base de données (Docker)
```powershell
docker compose up -d
```

### 3. Migrations
```powershell
.venv\Scripts\python.exe -m alembic upgrade head
```

### 4. Données de démo (optionnel)
```powershell
.venv\Scripts\python.exe -m app.seed
```
Identifiants :
- **OWNER** : email `boss@babicash.ci` / `boss1234` (ou téléphone `0700000000` + PIN `1234`)
- **MANAGER** : téléphone `0700000001` + PIN `4321`

### 5. Lancer l'API
```powershell
.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```
Docs interactives : http://localhost:8000/docs

## Endpoints principaux (`/api/v1`)

| Groupe | Routes principales |
|---|---|
| `auth` | `POST /auth/login` (email+mdp) · `POST /auth/login-pin` (téléphone+PIN) · `GET /auth/me` · OAuth Google/Apple |
| `users` | `GET/POST /users/managers` (OWNER) · `PUT /users/me/pin` · `PATCH /users/{id}` |
| `boutiques` | CRUD boutiques (OWNER pour les écritures) |
| `produits` / `categories` | CRUD (paginé, filtre `boutique_id`) |
| `tiers` | CRUD clients/fournisseurs + `POST /tiers/{id}/paiement` |
| `sessions` | `POST /sessions/ouvrir` · `GET /sessions/active` · `POST /sessions/{id}/fermer` · résumé/réconciliation |
| `sync` | `POST /sync/push` (idempotent) · `GET /sync/pull` |
| `ventes` | Historique, détail, `POST /ventes/{id}/retour`, reçu |
| `dashboard` | `consolide`, `ca`, `caisse`, `dettes`, `stock` (OWNER) |
| `analytics` | `GET /analytics/best-sellers` |
| `abonnements` | `mon-plan`, `quota/{boutique_id}`, `upgrade` |
| `mouvements_stock` | Mouvements, CMP, dettes fournisseurs |
| `shop` | Catalogue boutique en ligne + commandes |
| `ambassadeurs` | Inscription, filleuls, commissions, versements, notifications |
| `landing_leads` | `POST /landing-leads` (vitrine) |
| `uploads` | Médias (images produits/shop) |
| — | `GET /health` (public) |

> **Cloisonnement multi-tenant** : tout accès à une ressource passe par `app/access.py`
> (`get_authorized_boutique`). Un OWNER n'accède qu'à ses boutiques ; un MANAGER est
> verrouillé sur sa boutique.

## Connexion simplifiée & hors-ligne
- **Gérants** : connexion par **numéro de téléphone + code PIN à 4 chiffres** (`/auth/login-pin`).
  Le propriétaire crée le gérant (`POST /users/` téléphone + PIN).
- **Propriétaire** : connexion **email + mot de passe** (ou Google), peut aussi avoir un PIN.
- **App Flutter** : première connexion en ligne → token JWT (24 h) + hash local du PIN stockés ;
  ensuite l'app valide le PIN **localement** hors-ligne et autorise la vente. Le serveur n'expose
  jamais le hash du PIN.

## Règles métier clés
- **Marge calculée côté serveur** uniquement.
- **Vente à perte** (`prix_vendu_reel < prix_achat_moyen`) : acceptée, marquée
  `vente_a_perte` / `signale_proprietaire` + avertissement au vendeur.
- **Idempotence de sync** via `id_local_smartphone` (UNIQUE) — un push rejoué ne duplique pas.
- **Reçu structuré** (`schemas/recu.py`) renvoyé par `sync/push` → partage WhatsApp + impression thermique.
- Montants en `Decimal`/`Numeric(12,2)` — jamais de float.

## Tests
```powershell
.venv\Scripts\python.exe -m pytest tests/ -v
```
Tests sur SQLite in-memory (aucune base externe requise). ~22 fichiers : auth, crud, sessions,
sync, analytics, dashboard, freemium, shop, ambassadeurs, parrainage, commissions, payouts,
notifications, admin…

## Déploiement
Voir [DEPLOY.md](DEPLOY.md) (Docker + Nginx + HTTPS sur VPS). CI/CD : `.github/workflows/`.