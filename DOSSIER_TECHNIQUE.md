# BabiCash — Dossier Technique Complet

> **Version** : 1.0.0 · **Dernière mise à jour** : 10 juillet 2026  
> **Repo** : https://github.com/Univers10/babicash  
> **Domaine de test** : https://babicash.ecomotionafricaci.com

---

## Table des matières

1. [Présentation du projet](#1-présentation-du-projet)
2. [Architecture générale](#2-architecture-générale)
3. [Stack technique](#3-stack-technique)
4. [Structure du dépôt](#4-structure-du-dépôt)
5. [Backend — API FastAPI](#5-backend--api-fastapi)
   - [Configuration](#51-configuration)
   - [Modèles de données (ORM)](#52-modèles-de-données-orm)
   - [Schéma de base de données](#53-schéma-de-base-de-données)
   - [Endpoints API](#54-endpoints-api)
   - [Services métier](#55-services-métier)
   - [Sécurité & accès](#56-sécurité--accès)
   - [Migrations Alembic](#57-migrations-alembic)
   - [Tests](#58-tests)
6. [Frontend — Application Flutter](#6-frontend--application-flutter)
   - [Architecture](#61-architecture)
   - [Écrans](#62-écrans)
   - [State management (Riverpod)](#63-state-management-riverpod)
   - [Base de données locale (Drift/SQLite)](#64-base-de-données-locale-driftsqlite)
   - [Synchronisation Offline-First](#65-synchronisation-offline-first)
   - [Couche réseau (API clients)](#66-couche-réseau-api-clients)
   - [Modèles de données (Freezed)](#67-modèles-de-données-freezed)
   - [Thème & UI](#68-thème--ui)
7. [Déploiement](#7-déploiement)
8. [Conventions & règles de développement](#8-conventions--règles-de-développement)
9. [État d'avancement & TODO](#9-état-davancement--todo)
10. [Données de test (Seed)](#10-données-de-test-seed)

---

## 1. Présentation du projet

**BabiCash** est une application de gestion commerciale multi-boutique destinée aux commerçants de proximité en Côte d'Ivoire (cosmétiques, quincailleries, dépôts, grossistes).

### Problèmes résolus
- **Absence d'outils adaptés** aux réalités du terrain (marchandage, crédits, connectivité faible)
- **Fraude et coulage de caisse** des employés
- **Manque de visibilité** pour les propriétaires multi-boutiques

### Concepts clés
- **Offline-First** : l'app fonctionne 100% sans internet, synchronisation automatique dès reconnexion
- **Multi-tenant** : cloisonnement strict des données par `boutique_id`
- **Freemium** : 20 ventes/mois gratuites, plan PRO illimité
- **Sessions de caisse** : anti-fraude avec réconciliation du tiroir-caisse
- **Prix négociable** : le gérant peut modifier le prix de vente avec détection de vente à perte

### Rôles utilisateur
| Rôle | Description | Authentification |
|------|-------------|------------------|
| **OWNER** | Propriétaire, accès à toutes ses boutiques + dashboard | Email + mot de passe |
| **MANAGER** | Gérant, verrouillé sur une boutique | Téléphone + code PIN (4 chiffres) |

---

## 2. Architecture générale

```
┌─────────────────────────────────────────────────────────┐
│                   Application Flutter                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────────┐│
│  │ UI/Écrans│→ │ Riverpod │→ │ API Clients (Dio)      ││
│  └──────────┘  │ Providers│  └────────┬───────────────┘│
│                └──────┬───┘           │                 │
│                       │               │                 │
│  ┌────────────────────▼────┐          │                 │
│  │ SQLite local (Drift)    │          │                 │
│  │ Ventes, dépenses, stock │          │                 │
│  └─────────────────────────┘          │                 │
│          ↕ SyncService                │                 │
│  ┌─────────────────────────┐          │                 │
│  │ connectivity_plus       │          │                 │
│  │ (détection réseau)      │──────────┘                 │
│  └─────────────────────────┘                            │
└─────────────────────────────┬───────────────────────────┘
                              │ HTTPS
                              ▼
┌─────────────────────────────────────────────────────────┐
│              Backend FastAPI (Docker)                     │
│  ┌───────────┐  ┌──────────────┐  ┌──────────────────┐ │
│  │ API Routes│→ │ Services     │→ │ SQLAlchemy Async  │ │
│  │ (v1/)     │  │ (sync, dash) │  │ (PostgreSQL)      │ │
│  └───────────┘  └──────────────┘  └──────────────────┘ │
│  ┌───────────┐  ┌──────────────┐                        │
│  │ JWT Auth  │  │ Alembic      │                        │
│  │ (PyJWT)   │  │ (Migrations) │                        │
│  └───────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  PostgreSQL 16+  │
                    │  (Docker)        │
                    └──────────────────┘
```

---

## 3. Stack technique

### Backend
| Composant | Technologie | Version |
|-----------|-------------|---------|
| Framework | FastAPI | ≥ 0.115 |
| Langage | Python | 3.13+ |
| ORM | SQLAlchemy (async) | ≥ 2.0.41 |
| Driver BDD | asyncpg | ≥ 0.30 |
| BDD | PostgreSQL | 16+ |
| Migrations | Alembic | ≥ 1.15 |
| Auth (JWT) | PyJWT | ≥ 2.9 |
| Hashing | bcrypt | ≥ 4.3 |
| Validation | Pydantic + pydantic-settings | ≥ 2.11 |
| Tests | pytest + pytest-asyncio + httpx | SQLite in-memory |
| Container | Docker + Docker Compose | — |

### Frontend
| Composant | Technologie | Version |
|-----------|-------------|---------|
| Framework | Flutter | SDK ≥ 3.3 |
| State management | flutter_riverpod | ^2.5.1 |
| Navigation | go_router | ^14.2.0 |
| HTTP client | Dio + pretty_dio_logger | ^5.4.3 |
| BDD locale | Drift (SQLite) | ^2.18.0 |
| Stockage sécurisé | flutter_secure_storage | ^9.2.2 |
| Sérialisation | freezed + json_serializable | — |
| Connectivité | connectivity_plus | ^6.0.3 |
| Impression | pos_universal_printer | ^0.2.10 |
| PDF | pdf + printing | — |
| Icônes | material_symbols_icons | ^4.2719 |
| Partage | share_plus + url_launcher | — |

---

## 4. Structure du dépôt

```
babicash/
├── backend/
│   ├── app/
│   │   ├── api/v1/             # Routes API (12 modules)
│   │   ├── core/               # Config, DB engine, sécurité
│   │   ├── models/             # Modèles SQLAlchemy (models.py)
│   │   ├── schemas/            # Schémas Pydantic (DTOs)
│   │   ├── services/           # Logique métier (sync, dashboard, etc.)
│   │   ├── access.py           # Contrôle multi-tenant
│   │   ├── deps.py             # Dépendances FastAPI (get_current_user)
│   │   ├── main.py             # Point d'entrée FastAPI
│   │   └── seed.py             # Données de test (dev)
│   ├── alembic/                # Migrations de BDD
│   ├── scripts/
│   │   └── seed_owner.py       # Script pour initialiser la prod
│   ├── tests/                  # Tests pytest (8 fichiers)
│   ├── Dockerfile              # Image Docker multi-stage
│   ├── docker-compose.yml      # Stack PostgreSQL + API
│   ├── entrypoint.sh           # Migrations auto + démarrage uvicorn
│   ├── requirements.txt        # Dépendances Python
│   ├── .env.production         # Template variables de production
│   └── DEPLOY.md               # Guide de déploiement
├── frontend/
│   ├── lib/
│   │   ├── core/               # Config app (router, theme, network, storage)
│   │   ├── data/
│   │   │   ├── local/          # Base SQLite locale (Drift)
│   │   │   ├── models/         # Modèles Freezed (DTOs)
│   │   │   └── remote/         # Clients API (Dio)
│   │   ├── features/           # Modules fonctionnels
│   │   │   ├── auth/           # Login email + PIN
│   │   │   ├── caisse/         # Point de vente (POS)
│   │   │   ├── dashboard/      # Tableau de bord propriétaire
│   │   │   ├── sessions/       # Sessions de caisse
│   │   │   ├── settings/       # Paramètres (profil, boutique, abo)
│   │   │   ├── stock/          # Gestion produits + catégories
│   │   │   ├── sync/           # Service de synchronisation
│   │   │   ├── tiers/          # Clients et fournisseurs
│   │   │   └── ventes/         # Historique des ventes
│   │   ├── shared/             # Widgets réutilisables, shell
│   │   └── main.dart           # Point d'entrée Flutter
│   ├── pubspec.yaml            # Dépendances Flutter
│   └── assets/images/          # Logo animé (splash)
├── tdr.md                      # Termes de Référence du projet
├── PROGRESSION.md              # Journal de progression
└── DOSSIER_TECHNIQUE.md        # Ce document
```

---

## 5. Backend — API FastAPI

### 5.1 Configuration

Fichier : `app/core/config.py`

La configuration est gérée via `pydantic-settings` et charge automatiquement un fichier `.env` :

| Variable | Défaut | Description |
|----------|--------|-------------|
| `DATABASE_URL` | `postgresql+asyncpg://babicash:babicash@localhost:5432/babicash` | URL de connexion PostgreSQL async |
| `SECRET_KEY` | valeur non sécurisée (warning au boot) | Clé de signature JWT |
| `ALGORITHM` | `HS256` | Algorithme JWT |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `43200` (30 jours) | Durée de vie des tokens |
| `ALLOWED_ORIGINS` | `*` | CORS — virgule-séparés ou `*` |
| `API_V1_PREFIX` | `/api/v1` | Préfixe des routes |

**Point d'entrée** : `app/main.py` → `uvicorn app.main:app`

### 5.2 Modèles de données (ORM)

Tous les modèles sont dans `app/models/models.py` et utilisent SQLAlchemy 2.0 Mapped Columns :

| Modèle | Table | Description |
|--------|-------|-------------|
| `User` | `users` | Utilisateurs (OWNER / MANAGER) |
| `Boutique` | `boutiques` | Boutiques liées à un propriétaire |
| `Categorie` | `categories` | Catégories de produits par boutique |
| `Produit` | `produits` | Catalogue produits (prix, stock, alertes) |
| `CompteTiers` | `comptes_tiers` | Clients et fournisseurs (solde_du) |
| `SessionCaisse` | `sessions_caisse` | Sessions de caisse (ouverture/fermeture) |
| `Vente` | `ventes` | Ventes avec idempotence (id_local_smartphone) |
| `LigneVente` | `lignes_vente` | Détails d'une vente (produit, qté, marge) |
| `Abonnement` | `abonnements` | Plan FREE/PRO par propriétaire |
| `TransactionCaisse` | `transactions_caisse` | Mouvements caisse (dépenses, entrées stock) |

### 5.3 Schéma de base de données

```
users
├── id (UUID, PK)
├── nom (VARCHAR 255)
├── email (VARCHAR 255, UNIQUE, nullable)
├── mot_de_passe_hash (VARCHAR 255, nullable)
├── telephone (VARCHAR 30, UNIQUE, nullable)
├── code_pin_hash (VARCHAR 255, nullable)
├── role (VARCHAR 20) → OWNER | MANAGER
├── boutique_id (UUID, FK → boutiques.id, nullable)
├── actif (BOOLEAN)
└── date_creation (TIMESTAMP TZ)

boutiques
├── id (UUID, PK)
├── nom (VARCHAR 255)
├── proprietaire_id (VARCHAR 255)
└── date_creation (TIMESTAMP TZ)

produits
├── id (UUID, PK)
├── boutique_id (UUID, FK → boutiques.id)
├── categorie_id (UUID, FK → categories.id, nullable)
├── nom (VARCHAR 255)
├── prix_achat_moyen (NUMERIC 12,2)
├── prix_vente_suggere (NUMERIC 12,2)
├── stock_actuel (INT)
└── stock_alerte (INT)

comptes_tiers
├── id (UUID, PK)
├── boutique_id (UUID, FK → boutiques.id)
├── nom (VARCHAR 255)
├── telephone (VARCHAR 50, nullable)
├── type_tiers (VARCHAR 20) → CLIENT | FOURNISSEUR
├── solde_du (NUMERIC 12,2)
└── UNIQUE(boutique_id, telephone)

ventes
├── id (UUID, PK)
├── boutique_id (UUID, FK → boutiques.id)
├── session_id (UUID, FK → sessions_caisse.id, nullable)
├── tier_id (UUID, FK → comptes_tiers.id, nullable)
├── caissier_id (UUID, FK → users.id, nullable)
├── date_vente (TIMESTAMP TZ)
├── montant_total (NUMERIC 12,2)
├── mode_paiement (VARCHAR 50) → ESPECES | MOBILE_MONEY | CREDIT
├── id_local_smartphone (VARCHAR 255, UNIQUE) → idempotence
├── statut (VARCHAR 20) → ACTIVE | RETOURNEE
├── date_retour (TIMESTAMP TZ, nullable)
├── signale_proprietaire (BOOLEAN) → True si vente à perte
└── synced (BOOLEAN)

lignes_vente
├── id (UUID, PK)
├── vente_id (UUID, FK → ventes.id, CASCADE)
├── produit_id (UUID, FK → produits.id, nullable)
├── quantite (INT)
├── prix_vendu_reel (NUMERIC 12,2)
├── marge_calculee (NUMERIC 12,2)
└── vente_a_perte (BOOLEAN)

sessions_caisse
├── id (UUID, PK)
├── boutique_id (UUID, FK → boutiques.id)
├── utilisateur_nom (VARCHAR 255)
├── date_ouverture (TIMESTAMP TZ)
├── date_fermeture (TIMESTAMP TZ, nullable)
├── montant_initial (NUMERIC 12,2)
├── montant_final_declare (NUMERIC 12,2)
└── statut (VARCHAR 20) → OUVERT | FERME

abonnements
├── id (UUID, PK)
├── proprietaire_id (VARCHAR 255, UNIQUE)
├── plan (VARCHAR 20) → FREE | PRO
├── prix_base (NUMERIC 12,2) → 5000.00 FCFA
├── quota_ventes_par_boutique (INT) → FREE=20, PRO=illimité
├── date_debut (TIMESTAMP TZ)
├── date_fin (TIMESTAMP TZ, nullable)
└── actif (BOOLEAN)

transactions_caisse
├── id (UUID, PK)
├── boutique_id (UUID, FK → boutiques.id)
├── session_id (UUID, FK → sessions_caisse.id, nullable)
├── type_transaction (VARCHAR 20) → ENTREE | SORTIE_DEPENSE | ENTREE_STOCK
├── montant (NUMERIC 12,2)
├── motif (VARCHAR 255)
├── id_local_smartphone (VARCHAR 255, UNIQUE)
├── date_transaction (TIMESTAMP TZ)
└── synced (BOOLEAN)
```

### 5.4 Endpoints API

Base URL : `/api/v1`

#### Auth (`/auth`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| POST | `/auth/login` | Connexion email + mot de passe | ❌ |
| POST | `/auth/login-pin` | Connexion téléphone + PIN | ❌ |
| GET | `/auth/me` | Infos utilisateur courant | ✅ |

#### Boutiques (`/boutiques`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/boutiques/` | Liste des boutiques du propriétaire | ✅ OWNER |
| POST | `/boutiques/` | Créer une boutique | ✅ OWNER |
| GET | `/boutiques/{id}` | Détail d'une boutique | ✅ |
| PATCH | `/boutiques/{id}` | Modifier (renommer) une boutique | ✅ OWNER |

#### Produits (`/produits`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/produits/?boutique_id=` | Liste produits (paginé) | ✅ |
| POST | `/produits/` | Créer un produit | ✅ |
| PATCH | `/produits/{id}` | Modifier un produit | ✅ |
| DELETE | `/produits/{id}` | Supprimer un produit | ✅ |

#### Catégories (`/categories`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/categories/?boutique_id=` | Liste catégories | ✅ |
| POST | `/categories/` | Créer une catégorie | ✅ |
| PATCH | `/categories/{id}` | Modifier une catégorie | ✅ |
| DELETE | `/categories/{id}` | Supprimer une catégorie | ✅ |

#### Comptes Tiers (`/tiers`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/tiers/?boutique_id=&type=` | Liste clients/fournisseurs (paginé) | ✅ |
| POST | `/tiers/` | Créer un tiers | ✅ |
| PATCH | `/tiers/{id}` | Modifier un tiers | ✅ |
| DELETE | `/tiers/{id}` | Supprimer un tiers | ✅ |
| POST | `/tiers/{id}/paiement` | Enregistrer un paiement/remboursement | ✅ |

#### Utilisateurs/Gérants (`/users`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| PUT | `/users/me/pin` | Changer son propre code PIN | ✅ |
| GET | `/users/managers?boutique_id=` | Liste des gérants d'une boutique | ✅ OWNER |
| POST | `/users/managers` | Créer un gérant | ✅ OWNER |
| PATCH | `/users/{user_id}` | Modifier un gérant | ✅ OWNER |

#### Sessions de caisse (`/sessions`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/sessions/active?boutique_id=` | Session en cours | ✅ |
| GET | `/sessions/?boutique_id=` | Historique sessions (paginé) | ✅ |
| POST | `/sessions/ouvrir` | Ouvrir une session | ✅ |
| POST | `/sessions/{id}/fermer` | Fermer une session (déclaration montant) | ✅ |
| GET | `/sessions/{id}/resume` | Résumé détaillé (réconciliation caisse) | ✅ |

#### Synchronisation (`/sync`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| POST | `/sync/push` | Pousser ventes + dépenses + entrées stock | ✅ |
| GET | `/sync/pull?boutique_id=` | Tirer le catalogue (produits + catégories) | ✅ |

#### Ventes (`/ventes`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/ventes/?boutique_id=` | Historique des ventes (paginé, filtrable) | ✅ |
| GET | `/ventes/{id}` | Détail d'une vente | ✅ |
| POST | `/ventes/{id}/retour` | Retourner une vente (annulation) | ✅ |
| GET | `/ventes/{id}/recu` | Générer le reçu d'une vente | ✅ |

#### Analytics (`/analytics`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/analytics/best-sellers?boutique_id=&tri=` | Top produits (quantité ou marge) | ✅ |

#### Dashboard (`/dashboard`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/dashboard/consolide?granularite=` | Vue consolidée multi-boutique | ✅ OWNER |
| GET | `/dashboard/ca?boutique_id=&granularite=` | Chiffre d'affaires par période | ✅ |
| GET | `/dashboard/caisse?boutique_id=` | État de la caisse courante | ✅ |
| GET | `/dashboard/dettes?boutique_id=` | Résumé dettes clients/fournisseurs | ✅ |
| GET | `/dashboard/stock?boutique_id=` | Alertes stock bas et ruptures | ✅ |

#### Abonnements (`/abonnements`)
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/abonnements/mon-plan` | Plan actuel du propriétaire | ✅ OWNER |
| GET | `/abonnements/quota/{boutique_id}` | Quota restant ce mois | ✅ |
| POST | `/abonnements/upgrade` | Passer au plan PRO | ✅ OWNER |

#### Health Check
| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/health` | Statut du serveur | ❌ |

### 5.5 Services métier

| Service | Fichier | Responsabilité |
|---------|---------|----------------|
| **SyncService** | `services/sync_service.py` | Traitement push (ventes, dépenses, entrées stock), calcul des marges, idempotence, alertes stock, CMP, reçus |
| **DashboardService** | `services/dashboard_service.py` | CA, réconciliation caisse, dettes, alertes stock, vue consolidée multi-boutique |
| **SessionService** | `services/session_service.py` | Ouverture/fermeture sessions, calcul montant théorique, détection écarts |
| **AbonnementService** | `services/abonnement_service.py` | Vérification quota freemium, upgrade de plan |
| **AnalyticsService** | `services/analytics_service.py` | Classement best-sellers (par quantité ou marge nette) |

#### Logique sync/push détaillée
1. Réception d'un `SyncPushRequest` contenant `ventes[]`, `depenses[]`, `entrees_stock[]`
2. Pour chaque **vente** :
   - Vérification d'idempotence via `id_local_smartphone`
   - Calcul de la marge par ligne : `(prix_vendu - prix_achat_moyen) * quantité`
   - Détection de vente à perte → marquage `signale_proprietaire = True`
   - Décrément du stock → garde-fou si stock négatif (avertissement)
   - Si `mode_paiement = CREDIT` → incrémentation `solde_du` du client
   - Génération d'un **reçu** (`RecuOut`) pour chaque vente
3. Pour chaque **dépense** : enregistrement comme `TransactionCaisse(SORTIE_DEPENSE)`
4. Pour chaque **entrée de stock** :
   - Calcul du **Coût Moyen Pondéré (CMP)** : `((stock * CMP_ancien) + (qté * prix_achat)) / (stock + qté)`
   - Création de dette fournisseur si `mode_paiement = CREDIT`
5. Retour des `alertes_stock[]` si des produits sont en stock bas après les opérations

### 5.6 Sécurité & accès

**Authentification JWT** (`app/deps.py` + `app/core/security.py`) :
- Token Bearer dans le header `Authorization`
- Payload : `sub` (user_id), `role`, `boutique_id`, `nom`
- Durée : 30 jours par défaut

**Contrôle multi-tenant** (`app/access.py`) :
- Chaque requête avec `boutique_id` passe par `get_authorized_boutique()`
- **OWNER** : ne peut accéder qu'à ses propres boutiques (`proprietaire_id`)
- **MANAGER** : verrouillé sur sa `boutique_id` du token, 403 sur toute autre boutique
- Contrôle effectué AVANT l'accès BD (empêche la fuite d'existence de ressource)

**Hashing** :
- Mots de passe : `bcrypt.hashpw()` / `bcrypt.checkpw()`
- Codes PIN : même principe, hashés en base

### 5.7 Migrations Alembic

| # | Fichier | Description |
|---|---------|-------------|
| 1 | `0001_initial.py` | Tables initiales (users, boutiques, catégories, produits, tiers, sessions, ventes, lignes, transactions) |
| 2 | `0002_telephone_pin.py` | Ajout téléphone + code_pin_hash sur users |
| 3 | `0003_abonnements.py` | Table abonnements |
| 4 | `0004_abonnement_proprietaire.py` | Renommage user_id → proprietaire_id |
| 5 | `20260708_*_uq_tiers_boutique_telephone.py` | Contrainte UNIQUE (boutique_id, telephone) sur comptes_tiers |
| 6 | `20260709_*_add_caissier_id_to_ventes.py` | Ajout caissier_id (FK users) sur ventes |
| 7 | `20260709_*_add_statut_date_retour_to_ventes.py` | Ajout statut + date_retour sur ventes (retours) |

**Commande** : `alembic upgrade head` (exécuté automatiquement au démarrage Docker via `entrypoint.sh`)

### 5.8 Tests

| Fichier | Tests | Description |
|---------|-------|-------------|
| `test_auth.py` | 4 | Login email, login invalide, /me |
| `test_auth_pin.py` | 7 | Login PIN, PIN invalide, changement PIN |
| `test_crud.py` | 6 | CRUD produits, catégories, tiers |
| `test_sessions.py` | 6 | Ouverture/fermeture session, résumé, écart |
| `test_sync.py` | 6 | Push ventes/dépenses, idempotence, pull |
| `test_analytics.py` | 1 | Best-sellers |
| `test_entrees_stock.py` | 5 | Entrées stock, CMP, dette fournisseur |
| `test_freemium.py` | — | Quota ventes, blocage, upgrade |
| `test_dashboard.py` | — | CA, caisse, dettes, stock, consolidé |

**Exécution** :
```bash
cd backend
python -m pytest -v
# Ou dans Docker :
docker compose exec api python -m pytest -v
```

Les tests utilisent **SQLite in-memory** via un `conftest.py` qui remplace le moteur PostgreSQL.

---

## 6. Frontend — Application Flutter

### 6.1 Architecture

Le frontend suit une architecture **Feature-First** avec séparation claire :

```
lib/
├── core/           # Infrastructure transversale
│   ├── errors/     # AppException (gestion d'erreurs unifiée)
│   ├── network/    # ApiClient (Dio configuré, intercepteurs, dioProvider)
│   ├── router/     # GoRouter (routes + guards d'auth)
│   ├── storage/    # SecureStorage (JWT token persisté)
│   ├── theme/      # AppColors, AppTextStyles, AppSpacing, AppTheme
│   └── utils/      # Utilitaires
├── data/
│   ├── local/      # database.dart (Drift) — 7 tables SQLite
│   ├── models/     # DTOs Freezed (auth, boutique, produit, vente, etc.)
│   └── remote/     # Clients API Dio (9 fichiers)
├── features/       # Modules fonctionnels (1 dossier par feature)
│   ├── auth/       # screens/ + providers/
│   ├── caisse/     # screens/ + providers/
│   ├── ...
│   └── ventes/     # screens/
├── shared/
│   ├── providers/  # shellScaffoldKeyProvider
│   ├── screens/    # ShellScreen (layout principal, drawer + bottom nav)
│   └── widgets/    # AppButton, AppTextField, AppSnackbar, AmountText, MenuButton
└── main.dart       # Entrée app, splash vidéo, ProviderScope, SyncInitializer
```

### 6.2 Écrans

| Route | Écran | Fichier | Description |
|-------|-------|---------|-------------|
| `/login` | `LoginScreen` | `auth/screens/login_screen.dart` | Connexion email + mot de passe (OWNER) |
| `/login-pin` | `LoginPinScreen` | `auth/screens/login_pin_screen.dart` | Connexion téléphone + PIN (MANAGER) |
| `/caisse` | `CaisseScreen` | `caisse/screens/caisse_screen.dart` | Point de vente (POS) avec catalogue + panier |
| `/stock` | `StockScreen` | `stock/screens/stock_screen.dart` | Gestion du catalogue produits |
| `/categories` | `CategoriesScreen` | `stock/screens/categories_screen.dart` | Gestion des catégories |
| `/tiers` | `TiersScreen` | `tiers/screens/tiers_screen.dart` | Clients + fournisseurs (soldes, paiements) |
| `/sessions` | `SessionsScreen` | `sessions/screens/sessions_screen.dart` | Sessions de caisse (ouvrir/fermer) |
| `/historique` | `HistoriqueScreen` | `ventes/screens/historique_screen.dart` | Historique des ventes |
| `/dashboard` | `DashboardScreen` | `dashboard/screens/dashboard_screen.dart` | Tableau de bord propriétaire |
| `/settings` | `SettingsScreen` | `settings/screens/settings_screen.dart` | Profil, boutique, abonnement, paramètres |
| — | `TicketScreen` | `caisse/screens/ticket_screen.dart` | Aperçu du reçu/ticket |

**Navigation** :
- `ShellScreen` enveloppe toutes les routes authentifiées
- **Bottom Navigation** : 4 onglets (adapté selon OWNER/MANAGER)
- **Drawer** : menu complet groupé (Opérations, Gestion, Paramètres, Propriétaire)
- **Redirect** : si non connecté → `/login` ; si connecté et OWNER → `/dashboard` par défaut

### 6.3 State management (Riverpod)

| Provider | Type | Description |
|----------|------|-------------|
| `authStateProvider` | `AsyncNotifier` | État d'authentification (login/logout, SessionUser) |
| `currentBoutiqueIdProvider` | `FutureProvider<String?>` | ID de la boutique active (depuis token ou API) |
| `sessionNotifierProvider` | `AsyncNotifier` | Session de caisse active (ouvrir/fermer) |
| `panierProvider` | `StateNotifier` | Panier de la caisse (lignes de vente) |
| `caisseLoadingProvider` | `StateProvider<bool>` | État de chargement de la caisse |
| `stockProvider` | `FutureProvider` | Liste des produits de la boutique |
| `categoriesCrudProvider` | `AsyncNotifier` | CRUD catégories |
| `produitsCrudProvider` | `AsyncNotifier` | CRUD produits |
| `tiersProvider` | `AsyncNotifier` | CRUD clients/fournisseurs |
| `quotaProvider` | `FutureProvider` | Quota ventes du mois |
| `syncServiceProvider` | `Provider<SyncService>` | Service de synchronisation |
| `syncInitProvider` | `FutureProvider<void>` | Déclenche pull + push au démarrage |
| `boutiqueInfoProvider` | `FutureProvider` | Info boutique pour settings |
| `abonnementInfoProvider` | `FutureProvider` | Info abonnement pour settings |
| `quotaInfoProvider` | `FutureProvider` | Quota pour settings |
| `dioProvider` | `Provider<Dio>` | Instance Dio authentifiée |
| `appDatabaseProvider` | `Provider<AppDatabase>` | Instance base locale Drift |

### 6.4 Base de données locale (Drift/SQLite)

Fichier : `data/local/database.dart`  
Base : `babicash.db` dans le répertoire documents de l'app

| Table locale | Colonnes clés | Synced? |
|-------------|---------------|---------|
| `LocalProduits` | id, boutiqueId, nom, prixAchatMoyen, prixVenteSuggere, stockActuel, stockAlerte | Pull du serveur |
| `LocalCategories` | id, boutiqueId, nom | Pull du serveur |
| `LocalVentes` | idLocal, boutiqueId, sessionId, modePaiement, montantTotal, **synced**, serverVenteId | ✅ flag `synced` |
| `LocalLignesVente` | venteIdLocal, produitId, quantite, prixVenduReel, margeCalculee | Cascade via vente |
| `LocalDepenses` | idLocal, boutiqueId, sessionId, montant, motif, **synced** | ✅ flag `synced` |
| `LocalSessions` | id, boutiqueId, statut (OUVERT/FERME), montantInitial | Semi-sync |
| `LocalTiers` | id, boutiqueId, nom, telephone, typeTiers, soldeDu | Pull du serveur |

**Méthodes principales** :
- `getVentesNonSync(boutiqueId)` — ventes locales non encore pushées
- `marquerVenteSync(idLocal, serverVenteId)` — marquer comme synchronisée
- `upsertAllProduits(...)` / `upsertAllCategories(...)` — mise à jour catalogue après pull
- `getSessionOuverte(boutiqueId)` — session de caisse en cours

### 6.5 Synchronisation Offline-First

Fichier : `features/sync/sync_service.dart`

**Flux** :
1. **Au démarrage** (`syncInitProvider`) : `pullCatalogue()` puis `pushPending()`
2. **À la reconnexion réseau** : écoute `connectivity_plus` → `pushPending()` automatique
3. **Manuellement** : bouton "Synchroniser" dans les paramètres

**Push** :
1. Récupère toutes les ventes et dépenses locales avec `synced = false`
2. Construit un `SyncPushRequest` avec les lignes de vente associées
3. Appelle `POST /sync/push`
4. Marque chaque vente comme `synced = true` + stocke le `serverVenteId`

**Pull** :
1. Appelle `GET /sync/pull?boutique_id=`
2. Upsert (insert or update) les produits et catégories dans SQLite

**Résilience** :
- Toute erreur est silencieuse (`catch AppException`) — sera retentée
- La vérification de connectivité est faite AVANT toute requête
- L'écriture locale est toujours immédiate (pas de blocage sur le réseau)

### 6.6 Couche réseau (API clients)

Fichier central : `core/network/api_client.dart`

**URL de base** : `https://babicash.ecomotionafricaci.com/api/v1`  
*(configurable via `_baseUrl` dans `api_client.dart`)*

**Configuration Dio** :
- `connectTimeout` : 10 secondes
- `receiveTimeout` : 20 secondes
- Intercepteur : injection automatique du token JWT depuis `SecureStorage`
- Logger : `PrettyDioLogger` en mode debug

| Client API | Fichier | Endpoints couverts |
|------------|---------|-------------------|
| `AuthApi` | `auth_api.dart` | login, loginPin |
| `BoutiquesApi` | `boutiques_api.dart` | listBoutiques, createBoutique, renameBoutique |
| `ProduitsApi` | `produits_api.dart` | listProduits, createProduit, updateProduit, deleteProduit |
| `CategoriesApi` | `categories_api.dart` | listCategories, createCategorie, updateCategorie, deleteCategorie |
| `TiersApi` | `tiers_api.dart` | listTiers, createTier, updateTier, deleteTier |
| `SessionsApi` | `sessions_api.dart` | sessionActive, listSessions, ouvrirSession, fermerSession, getResume |
| `VentesApi` | `ventes_api.dart` | listVentes |
| `SyncApi` | `sync_api.dart` | push, pull |
| `AbonnementsApi` | `abonnements_api.dart` | monPlan, quotaBoutique, upgrade |

### 6.7 Modèles de données (Freezed)

Tous les DTOs sont dans `data/models/` et utilisent **Freezed + json_serializable** avec code généré (`.freezed.dart` + `.g.dart`).

| Modèle | Fichier | Champs principaux |
|--------|---------|-------------------|
| `SessionUser` | `auth_model.dart` | token, role, nom, boutiqueId + getters `isOwner`/`isManager` |
| `LoginRequest` | `auth_model.dart` | email, motDePasse |
| `LoginPinRequest` | `auth_model.dart` | telephone, codePin |
| `TokenResponse` | `auth_model.dart` | accessToken, role, boutiqueId, nom |
| `BoutiqueModel` | `boutique_model.dart` | id, nom, proprietaireId, dateCreation |
| `ProduitModel` | `produit_model.dart` | id, nom, prixAchatMoyen, prixVenteSuggere, stockActuel, stockAlerte |
| `CategorieModel` | `produit_model.dart` | id, boutiqueId, nom |
| `SessionModel` | `session_model.dart` | Session complète + SessionResumeModel (réconciliation) |
| `VenteHistorique` | `vente_model.dart` | Vente avec lignes pour l'historique |
| `TierModel` | `tier_model.dart` | Clients/fournisseurs avec solde |
| `AbonnementOut` | `abonnement_model.dart` | Plan, prix, quota |
| `QuotaInfo` | `abonnement_model.dart` | ventesUtilisees, quotaMax, ventesRestantes |
| `SyncPushRequest` | `sync_model.dart` | VenteIn[], DepenseIn[], payload de sync |
| `SyncPullResponse` | `sync_model.dart` | Produits + catégories du catalogue |

**Régénération du code** :
```bash
cd frontend
dart run build_runner build --delete-conflicting-outputs
```

### 6.8 Thème & UI

**Palette** (extraite du logo BabiCash) :
| Couleur | Hex | Usage |
|---------|-----|-------|
| Vert foncé | `#1B6B2F` | Primaire (boutons, accents) |
| Or/Orange | `#F5A623` | Accent (warning, highlights) |
| Brun | `#3D1F00` | Texte brun |
| Background | `#F7F7F5` | Fond d'écran |
| Surface | `#FFFFFF` | Cartes, bottom nav |

**Spacing** : `AppSpacing` → constantes de 2 à 48 px + `VGap`/`HGap` widgets  
**Typography** : `AppTextStyles` → display, headlines, body, labels, amounts, button, caption  
**Widgets partagés** :
- `AppButton` — bouton primaire avec variants et loading
- `AppTextField` — champ de saisie avec label et validation
- `AppSnackbar` — feedback (success/error)
- `AmountText` — formatage monétaire FCFA
- `MenuButton` — bouton hamburger pour le drawer

**Splash** : vidéo animée du logo (`anime_logo.mp4`) jouée au lancement, puis transition vers l'écran principal.

---

## 7. Déploiement

### Architecture Docker

```
docker-compose.yml
├── db       → postgres:16-alpine (healthcheck pg_isready)
└── api      → Dockerfile multi-stage (Python 3.13-slim)
               └── entrypoint.sh → alembic upgrade head + uvicorn
```

### Fichiers de déploiement
| Fichier | Rôle |
|---------|------|
| `Dockerfile` | Build multi-stage (builder + runtime léger) |
| `entrypoint.sh` | Exécute les migrations puis lance uvicorn |
| `docker-compose.yml` | Orchestre PostgreSQL + API |
| `.dockerignore` | Exclut .venv, tests, .env, __pycache__ |
| `.env.production` | Template variables de production |
| `DEPLOY.md` | Guide de déploiement pas à pas |

### Variables d'environnement (production)
| Variable | Obligatoire | Description |
|----------|-------------|-------------|
| `POSTGRES_PASSWORD` | ✅ | Mot de passe BDD fort |
| `SECRET_KEY` | ✅ | `openssl rand -hex 64` |
| `ALLOWED_ORIGINS` | ✅ | URL(s) du frontend |
| `POSTGRES_USER` | ❌ (babicash) | Utilisateur BDD |
| `POSTGRES_DB` | ❌ (babicash) | Nom de la BDD |
| `API_PORT` | ❌ (8000) | Port exposé |
| `WORKERS` | ❌ (2) | Workers uvicorn |

### Commandes de déploiement
```bash
# 1. Transférer et configurer
ssh root@VOTRE_IP
git clone <repo> /opt/babicash && cd /opt/babicash/backend
cp .env.production .env && nano .env

# 2. Lancer
docker compose up -d --build

# 3. Créer le premier utilisateur
docker compose exec api python -m scripts.seed_owner

# 4. Nginx reverse proxy + HTTPS
certbot --nginx -d babicash.ecomotionafricaci.com

# 5. Vérifier
curl https://babicash.ecomotionafricaci.com/health
```

### Mise à jour du frontend (URL de l'API)
Fichier : `frontend/lib/core/network/api_client.dart`
```dart
const String _baseUrl = 'https://babicash.ecomotionafricaci.com';
```

---

## 8. Conventions & règles de développement

### Backend
- **Python** : PEP 8, type hints systématiques
- **Async** : toutes les routes et services sont `async`
- **Nommage BDD** : snake_case français (`date_creation`, `montant_total`, `solde_du`)
- **Nommage routes** : kebab-case (`/login-pin`, `/mon-plan`)
- **UUID** partout comme clé primaire
- **Idempotence** : `id_local_smartphone` UNIQUE pour éviter les doublons de sync
- **Decimal** (`Numeric(12,2)`) pour tous les montants financiers — jamais de float
- **Pydantic** : `from_attributes=True` sur tous les modèles de sortie
- **Erreurs** : HTTPException avec codes HTTP standards (400, 401, 403, 404)

### Frontend
- **Dart** : suivi des conventions Dart/Flutter standard
- **Freezed** pour tous les DTOs (immutabilité, pattern matching)
- **Riverpod** pour l'état (pas de `ChangeNotifier`, pas de `StatefulWidget` sauf nécessité UI)
- **go_router** pour la navigation déclarative
- **Offline-First** : écriture locale d'abord, sync en background
- **Nommage providers** : `xyzProvider` ou `xyzNotifierProvider`
- **Code generation** : `dart run build_runner build --delete-conflicting-outputs`

### Git
- Branche principale : `main`
- Messages de commit : conventionnels (`feat:`, `fix:`, `docs:`, `refactor:`)

---

## 9. État d'avancement & TODO

### ✅ Terminé

| Module | Backend | Frontend |
|--------|---------|----------|
| Authentification (email + PIN) | ✅ | ✅ |
| CRUD Boutiques | ✅ | ✅ |
| CRUD Produits | ✅ | ✅ |
| CRUD Catégories | ✅ | ✅ |
| CRUD Tiers (clients/fournisseurs) | ✅ | ✅ |
| Sessions de caisse | ✅ | ✅ |
| Point de vente (POS) | ✅ | ✅ |
| Synchronisation offline-first | ✅ | ✅ |
| Historique des ventes | ✅ | ✅ |
| Dashboard propriétaire | ✅ | ✅ |
| Gestion gérants | ✅ | ❌ (pas d'écran dédié) |
| Abonnements / Quota freemium | ✅ | ✅ (affichage) |
| Best-sellers analytics | ✅ | ❌ (pas d'écran dédié) |
| Retours de vente | ✅ | ❌ |
| Entrées de stock via sync | ✅ | ❌ |
| Paramètres (profil, boutique, abo) | ✅ | ✅ |
| Dockerisation + déploiement | ✅ | — |

### 🔴 Haute priorité (à faire)

- [ ] **Écran gestion des gérants** (frontend) — le backend est prêt
- [ ] **Entrées de stock** (frontend) — écran de réception marchandises, le backend supporte déjà
- [ ] **Retours de vente** (frontend) — endpoint backend existe
- [ ] **Gestion des erreurs réseau** — actuellement les 401 en boucle ne sont pas gérés proprement ; ajouter une déconnexion automatique sur token expiré
- [ ] **Paiement Mobile Money** — intégration Wave/Orange Money pour les abonnements

### 🟡 Priorité moyenne

- [ ] **Écran Best-Sellers** (frontend) — visualisation graphique
- [ ] **Génération PDF reçu + partage WhatsApp** — les widgets PDF existent mais ne sont pas complètement intégrés
- [ ] **Entrées de stock via sync/push** côté Flutter
- [ ] **Dépenses de caisse** — écran dédié côté Flutter
- [ ] **Notifications stock bas** — push notifications
- [ ] **Multi-boutique switch** — dropdown pour OWNER dans le shell

### 🟢 Basse priorité

- [ ] **Tests unitaires Flutter**
- [ ] **CI/CD** (GitHub Actions)
- [ ] **iOS build** — actuellement Android uniquement
- [ ] **Internationalisation** (i18n)
- [ ] **Mode sombre**
- [ ] **Audit trail** — journal des modifications visible par l'OWNER

---

## 10. Données de test (Seed)

### Script de seed production
```bash
docker compose exec api python -m scripts.seed_owner
```

Crée :
| Élément | Valeur |
|---------|--------|
| Email | `boss@babicash.ci` |
| Mot de passe | `boss@1234` |
| Rôle | OWNER |
| Boutique | "Ma Boutique" |
| Plan | FREE |

### Seed développement (`app/seed.py`)
| Rôle | Identifiant | Authentification |
|------|-------------|------------------|
| OWNER | `boss@babicash.ci` | Mot de passe `boss1234` |
| OWNER | `0700000000` | PIN `1234` |
| MANAGER | `0700000001` | PIN `4321` |

---

## Annexe — Commandes utiles

### Backend (dev local)
```bash
cd backend
python -m venv .venv && .venv\Scripts\activate  # Windows
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000

# Tests
python -m pytest -v

# Nouvelle migration
alembic revision --autogenerate -m "description"
```

### Frontend
```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Régénérer Freezed/Drift

# Lancer sur device
flutter run -d <device_id>

# Build APK
flutter build apk --release
```

### Docker (production)
```bash
cd backend
docker compose up -d --build          # Démarrer
docker compose logs -f api            # Logs
docker compose exec api sh            # Shell
docker compose exec api alembic upgrade head  # Migrations
docker compose down                   # Arrêter
docker compose down -v                # Arrêter + supprimer données
```
