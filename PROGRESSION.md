# BabiCash — Rapport de Progression

> Dernière mise à jour : 04 juillet 2026  
> Environnement : Python 3.14.6 · PostgreSQL 18 · FastAPI · SQLAlchemy 2.0 async

---

## État général

| Composant | État |
|---|---|
| Backend API | ✅ Stable — 35/35 tests passent |
| Base de données | ✅ PostgreSQL 18 local, migrations appliquées |
| Tests | ✅ pytest · SQLite in-memory |
| GitHub | ✅ https://github.com/Univers10/babicash |
| Frontend Flutter | ⏳ Non commencé |

---

## Corrections effectuées

### Priorité 1 — Bugs critiques

| # | Problème | Fichier(s) | Solution |
|---|---|---|---|
| 1 | Stock pouvait devenir négatif sans avertissement | `sync_service.py` | Garde-fou + champ `avertissement` dans la réponse |
| 2 | Alertes stock bas absentes | `sync_service.py`, `schemas/sync.py` | `alertes_stock[]` retourné après chaque vente |
| 3 | Route `PUT /me/pin` en conflit avec `/{user_id}` | `api/v1/users.py` | Route déplacée avant les routes paramétrées |
| 4 | Aucun endpoint pour rembourser un crédit client | `api/v1/tiers.py`, `schemas/crud.py` | `POST /tiers/{id}/paiement` implémenté |

### Priorité 2 — Sécurité & qualité

| # | Problème | Fichier(s) | Solution |
|---|---|---|---|
| 5 | `SECRET_KEY` par défaut non sécurisée silencieuse | `core/config.py` | `UserWarning` au démarrage si valeur par défaut |
| 6 | CORS `allow_origins=["*"]` hardcodé | `core/config.py`, `main.py` | `ALLOWED_ORIGINS` configurable via `.env` |
| 7 | `_get_managed_user` retournait 404 au lieu de 403 | `api/v1/users.py` | 403 distinct si `boutique_id=None` |
| 8 | Analytics `GROUP BY` invalide en PostgreSQL strict | `services/analytics_service.py` | `func.max(Produit.nom)` + `GROUP BY produit_id` seul |
| 9 | `python-jose` déprécié (`datetime.utcnow`) | `core/security.py`, `requirements.txt` | Remplacé par `PyJWT >= 2.9.0` |
| 10 | `passlib 1.7.4` incompatible avec `bcrypt >= 4.0` | `core/security.py`, `requirements.txt` | Remplacé par `bcrypt` direct (`hashpw`/`checkpw`) |
| 11 | Pas de pagination sur les listes | `api/v1/produits.py`, `tiers.py`, `sessions.py` | Paramètres `?limit=&offset=` ajoutés |

### Priorité 3 — Nouvelles fonctionnalités

| # | Fonctionnalité | Fichier(s) | Détails |
|---|---|---|---|
| 12 | Entrées de stock via sync/push | `schemas/sync.py`, `sync_service.py` | `entrees_stock[]` dans le payload sync |

**Détail entrées de stock :**
- Calcul automatique du **Coût Moyen Pondéré (CMP)** à chaque réception
- **Dette fournisseur** créée si `mode_paiement=CREDIT` + `fournisseur_id`
- **Idempotence** garantie via `id_local_smartphone` (même clé unique que les ventes)
- **Traçabilité** : enregistré comme `TransactionCaisse(type_transaction="ENTREE_STOCK")`
- **Pas d'alerte stock** générée sur les produits venant d'être réapprovisionnés

---

## Corrections environnement Python 3.14

| Problème | Solution |
|---|---|
| `greenlet` DLL manquante | Installation **Visual C++ Redistributable 2022** (25MB) |
| `passlib` incompatible `bcrypt 5.x` | Supprimé → `bcrypt` direct |
| `python-jose` déprécié | Remplacé par `PyJWT >= 2.9.0` |
| `requirements.txt` versions trop strictes | Versions flexibles `>=` compatibles Python 3.14 |

---

## Couverture de tests

| Fichier | Tests | Statut |
|---|---|---|
| `test_auth.py` | 4 | ✅ |
| `test_auth_pin.py` | 7 | ✅ |
| `test_crud.py` | 6 | ✅ |
| `test_sessions.py` | 6 | ✅ |
| `test_sync.py` | 6 | ✅ |
| `test_analytics.py` | 1 | ✅ |
| `test_entrees_stock.py` | 5 | ✅ |
| **Total** | **35** | ✅ **35/35** |

---

## Données de test (seed)

| Rôle | Identifiant | Mot de passe |
|---|---|---|
| OWNER | `boss@babicash.ci` | `boss1234` |
| OWNER (PIN) | `0700000000` | PIN `1234` |
| MANAGER (PIN) | `0700000001` | PIN `4321` |

**boutique_id** : `af86782b-5802-4bbd-92bf-f4a8af7e8107`

---

## Reste à faire

### 🔴 Haute priorité

- [ ] **Modèle Freemium** — quota 20 ventes/mois pour le plan gratuit
  - Table `abonnements` (plan, date_debut, date_fin, quota_ventes)
  - Middleware de vérification du quota avant chaque sync/push
  - Endpoint upgrade de plan

### 🟡 Priorité moyenne

- [ ] **Dashboard reporting** (endpoints propriétaire)
  - Chiffre d'affaires par période (jour / semaine / mois)
  - Évolution du stock dans le temps
  - Résumé des dettes clients et fournisseurs
  - Résumé de caisse consolidé multi-boutique

### 🟢 Basse priorité

- [ ] **Frontend Flutter**
  - Architecture offline-first (SQLite local + Drift)
  - Synchronisation avec l'API (push/pull)
  - UI ventes, stock, caisse
  - Génération reçu WhatsApp (PDF)

---

## Stack technique finale

```
Backend  : FastAPI 0.115+ · Python 3.14.6 · SQLAlchemy 2.0 async
Auth     : PyJWT 2.13 · bcrypt 5.0
DB       : PostgreSQL 18 (prod) · SQLite in-memory (tests)
Migrations : Alembic 1.15+
Tests    : pytest 9.1 · pytest-asyncio · httpx · aiosqlite
```
