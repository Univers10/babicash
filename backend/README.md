# BabiCash — Backend (FastAPI)

API REST pour la plateforme de gestion commerciale multi-boutique BabiCash.

## Stack
- **FastAPI** (Python 3.11+), **Uvicorn**
- **SQLAlchemy 2.0** (async) + **Alembic** (migrations)
- **PostgreSQL** (driver `asyncpg`)
- **JWT** (rôles `OWNER` / `MANAGER`), hachage `bcrypt`

## Architecture
```
app/
├── main.py            # App FastAPI + /health
├── deps.py            # Dépendances auth/rôles
├── core/              # config, db (async), security (JWT)
├── models/            # Modèles SQLAlchemy
├── schemas/           # Modèles Pydantic (auth, sync, recu, analytics...)
├── api/v1/            # Routeurs: auth, boutiques, sync, analytics
└── services/          # Logique métier (sync, analytics)
alembic/               # Migrations
tests/                 # Tests pytest (SQLite en mémoire)
```

## Démarrage

### 1. Environnement
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

### 2. Base de données (Docker)
```powershell
docker compose up -d
```

### 3. Migrations
```powershell
alembic upgrade head
```

### 4. Données de démo (optionnel)
```powershell
python -m app.seed
```
Identifiants créés :
- **OWNER** : email `boss@babicash.ci` / `boss1234` (ou téléphone `0700000000` + PIN `1234`)
- **MANAGER** : téléphone `0700000001` + PIN `4321`

### 5. Lancer l'API
```powershell
uvicorn app.main:app --reload
```
Docs interactives : http://localhost:8000/docs

## Endpoints (`/api/v1`)
| Méthode | Route | Rôle | Description |
|---|---|---|---|
| POST | `/auth/login` | public | Connexion **email + mot de passe** (propriétaire) |
| POST | `/auth/login-pin` | public | Connexion **téléphone + code PIN** (gérants) |
| GET | `/auth/me` | connecté | Profil courant |
| PUT | `/users/me/pin` | connecté | Définir/changer son propre code PIN |
| GET | `/boutiques/` | connecté | Boutiques du propriétaire (ou celle du gérant) |
| POST | `/boutiques/` | OWNER | Crée une boutique |
| GET | `/boutiques/{id}` | connecté | Détail d'une boutique (cloisonné) |
| PATCH | `/boutiques/{id}` | OWNER | Modifie une boutique |
| GET | `/produits/?boutique_id=` | connecté | Liste les produits |
| POST | `/produits/` | OWNER | Crée un produit |
| PATCH | `/produits/{id}` | OWNER | Modifie un produit |
| DELETE | `/produits/{id}` | OWNER | Supprime un produit |
| GET/POST/PATCH/DELETE | `/categories/...` | OWNER (lecture: connecté) | CRUD catégories |
| GET | `/tiers/?boutique_id=&type_tiers=` | connecté | Liste clients/fournisseurs |
| POST | `/tiers/` | OWNER + MANAGER | Crée un client/fournisseur |
| PATCH | `/tiers/{id}` | OWNER + MANAGER | Modifie un tiers |
| GET | `/users/?boutique_id=` | OWNER | Liste les gérants d'une boutique |
| POST | `/users/` | OWNER | Crée un gérant (MANAGER) |
| PATCH | `/users/{id}` | OWNER | Modifie/désactive un gérant |
| POST | `/sessions/ouvrir` | connecté | Ouvre une session de caisse (1 seule active) |
| GET | `/sessions/active` | connecté | Session active avec réconciliation (theorique/écart) |
| GET | `/sessions/` | connecté | Historique des sessions |
| GET | `/sessions/{id}` | connecté | Détail + réconciliation d'une session |
| POST | `/sessions/{id}/fermer` | connecté | Ferme la session (immuabilité) |
| GET | `/sync/pull` | connecté | Produits + catégories à jour |
| POST | `/sync/push` | connecté | Pousse ventes/dépenses (idempotent) + renvoie le reçu |
| GET | `/analytics/best-sellers` | connecté | Top produits par `quantite` ou `marge` |

> **Cloisonnement multi-tenant** : tout accès à une ressource passe par `app/access.py`
> (`get_authorized_boutique`). Un OWNER n'accède qu'à ses propres boutiques ; un MANAGER
> est verrouillé sur sa boutique.

## Connexion simplifiée & hors-ligne
- **Gérants** : connexion par **numéro de téléphone + code PIN à 4 chiffres** (`/auth/login-pin`).
  Pas besoin d'email. Le propriétaire crée le gérant via `POST /users/` (téléphone + PIN).
- **Propriétaire** : connexion classique **email + mot de passe** (`/auth/login`), peut aussi
  se doter d'un téléphone + PIN.
- **Stratégie Offline-First (côté app Flutter)** : lors de la **première connexion en ligne**,
  l'app stocke de façon sécurisée le **token longue durée** (30 jours par défaut, voir
  `ACCESS_TOKEN_EXPIRE_MINUTES`) **et un hachage local du PIN**. Aux ouvertures suivantes
  **sans internet**, l'app valide le PIN **localement** et autorise la vente ; la
  synchronisation (`sync/push`) se fait dès le retour du réseau. Le serveur n'expose jamais
  le hachage du PIN.

## Règles métier clés
- **Marge calculée côté serveur** uniquement (jamais celle du client).
- **Vente à perte** (`prix_vendu_reel < prix_achat_moyen`) : la vente est **acceptée**,
  marquée `vente_a_perte` / `signale_proprietaire`, et l'API renvoie un **avertissement**
  indiquant au vendeur que la vente sera signalée au propriétaire.
- **Idempotence de synchro** via `id_local_smartphone` (UNIQUE) : un push rejoué ne duplique pas.
- **Reçu structuré** (`schemas/recu.py`) renvoyé par `sync/push`, réutilisable pour le
  partage WhatsApp et l'**impression thermique Bluetooth (ESC/POS)** côté Flutter.

## Tests
```powershell
pytest
```
Les tests utilisent SQLite en mémoire (aucune base externe requise).
