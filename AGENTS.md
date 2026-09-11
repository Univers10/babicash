# AGENTS.md — Guide de contexte IA pour BabiCash

> Ce fichier est la **source canonique** de contexte pour les outils IA (opencode, Codex, Gemini, Cursor, Copilot, Claude). `CLAUDE.md`, `CURSOR.md`, `GEMINI.md`, `.cursorrules`, `.windsurfrules` et `.github/copilot-instructions.md` pointent tous vers lui. Documentez ici toute évolution du projet.

---

## 1. Vue d'ensemble

**BabiCash** est une plateforme de gestion commerciale **multi-boutique** (POS) destinée aux commerçants de proximité en Côte d'Ivoire. Elle couvre : la caisse (POS), le stock, les clients/fournisseurs, les sessions de caisse anti-fraude, les crédits, les abonnements freemium, un programme d'ambassadeurs (parrainage) et une boutique en ligne par commerce.

- **Architecture offline-first** : toutes les écritures vont d'abord dans SQLite local (Drift), puis se synchronisent vers le backend dès que le réseau revient.
- **Multi-tenant** : cloisonnement strict des données par `boutique_id`.
- **Appétence terrain** : marchandage (prix négocié), vente à crédit, connectivité faible, reçus WhatsApp, impression thermique Bluetooth.

### Repo & domaines

| Élément | Valeur |
|---|---|
| Repo | `https://github.com/Univers10/babicash` |
| POS (app Flutter) + API | `https://pos.babicash.ci` |
| PWA Ambassadeurs + API | `https://business.babicash.ci` |
| Site vitrine | `https://babicash.ci` |

> ⚠️ Les docs `*.md` à la racine (DOSSIER_TECHNIQUE, PROGRESSION…) sont en partie **historiques**. Ce fichier décrit l'état **actuel** du code. En cas de contradiction, le code source fait foi.

---

## 2. Carte du dépôt (monorepo)

```
babicash/
├── frontend/          # App mobile Flutter (POS) — offline-first
├── backend/           # API FastAPI (Python) + admin backoffice + PWA backend
│   ├── app/
│   │   ├── api/v1/    # Routeurs de l'API mobile/PWA (auth, sync, shop, ambassadeurs…)
│   │   ├── admin/     # Backoffice web (Jinja templates, sessions cookie)
│   │   ├── core/      # config, db (async), security (JWT), csrf, rate_limit
│   │   ├── models/    # Modèles SQLAlchemy 2.0 (models.py)
│   │   ├── schemas/   # Schémas Pydantic
│   │   ├── services/  # Logique métier (sync, dashboard, ambassadeur, paiement…)
│   │   └── templates/ # Backoffice admin
│   ├── alembic/       # Migrations de base
│   ├── tests/         # ~22 fichiers pytest (SQLite in-memory)
│   ├── scripts/       # seed_owner, seed_admin
│   ├── Dockerfile / docker-compose.yml / entrypoint.sh
│   └── requirements.txt
├── ambassadeur-pwa/   # PWA React + Vite + TS (espace ambassadeur « genre Wave »)
├── landing/           # Site vitrine statique (HTML/JS/CSS + SEO)
├── docs/              # Docs de conception (design-*.md, retours-beta-v1.md)
├── AGENTS.md          # ← ce fichier (contexte IA canonique)
├── CLAUDE.md, CURSOR.md, GEMINI.md, .cursorrules, .windsurfrules
└── .github/copilot-instructions.md, .github/workflows/
```

---

## 3. Backend (FastAPI)

### Stack

FastAPI ≥0.115 · Python 3.13 · SQLAlchemy 2.0 async · asyncpg · PostgreSQL 16 (prod) · Alembic · PyJWT · bcrypt · Pydantic v2 + pydantic-settings · Docker · pytest + httpx + aiosqlite (tests SQLite in-memory)

### Commandes (depuis `backend/`)

```bash
.venv/Scripts/python.exe -m pytest tests/        # tests (Windows)
.venv/Scripts/python.exe -m alembic upgrade head # migrations
.venv/Scripts/python.exe -m uvicorn app.main:app --reload
python -m app.seed                              # données de démo (dev)
docker compose up -d --build                    # prod locale (Docker)
```

- Bonnes pratiques : toutes les routes/services sont `async` ; UUID partout ; montants financiers en `Decimal`/`Numeric(12,2)` (jamais float) ; nommage BDD snake_case français ; idempotence par `id_local_smartphone` (UNIQUE).
- **Sécurité** : `SECRET_KEY` obligatoire ≥32 caractères dans `.env` (erreur au boot sinon), JWT 24 h (`ACCESS_TOKEN_EXPIRE_MINUTES=1440`), claim `token_version` (invalidation au changement de mot de passe), rate limiting, CSRF et cookie secure sur l'admin, CORS configurable (`ALLOWED_ORIGINS`).

### Tables (modèle de référence — `app/models/models.py`)

`users`, `boutiques`, `categories`, `produits`, `comptes_tiers`, `sessions_caisse`, `ventes`, `lignes_vente`, `abonnements`, `mouvements_stock`, `recu_configs`, `transactions_caisse`, `ambassadeurs`, `notifications`, `push_subscriptions`, `paiements_abonnement`, `payouts`, `commissions_parrainage`, `landing_leads`, `shop_produits`, `commandes_shop`, `commandes_shop_lignes`.

### Modules API (`app/api/v1/`)

`auth`, `oauth` (Google), `users`, `boutiques`, `produits`, `categories`, `tiers`, `sessions`, `sync`, `ventes`, `dashboard`, `analytics`, `abonnements`, `mouvements_stock`, `shop`, `ambassadeurs`, `landing_leads`, `uploads`, `router` (agrégateur). Rôles : `OWNER` (propriétaire) et `MANAGER` (gérant verrouillé sur une boutique) ; le backoffice admin (`app/admin/`) est séparé.

### Règles métier clés

- Marge calculée uniquement côté serveur ; vente à perte acceptée mais marquée `signale_proprietaire` + avertissement.
- Push sync : idempotent, décrémente le stock, gère crédits (`solde_du`), CMP pour les entrées de stock, renvoie reçus + alertes stock bas.
- Sessions de caisse ouvertes/fermées avec réconciliation (montant théorique vs déclaré).

---

## 4. Frontend Flutter (`frontend/`)

### Stack & conventions

Flutter SDK ≥3.3 · flutter_riverpod ^2.5 (AsyncNotifier/StateNotifier, pas de ChangeNotifier) · go_router · Dio (`lib/core/network/api_client.dart`, `_baseUrl = https://pos.babicash.ci` + intercepteur JWT) · Drift/SQLite (`lib/data/local/database.dart`, flag `synced`) · Freezed + json_serializable · flutter_secure_storage (JWT) · connectivity_plus · pdf/printing/pos_universal_printer (reçus + impression ESC/POS) · Material 3.

### Commandes (depuis `frontend/`)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # OBLIGATOIRE après modif Drift/Freezed
flutter run
flutter analyze --no-fatal-infos
flutter test --coverage
flutter build apk --release
```

> ⚠️ Ne jamais éditer les fichiers générés `*.g.dart`, `*.freezed.dart`, `*.drift.dart` — relancer `build_runner`.

### Architecture fonctionnelle (`lib/features/`)

| Feature | Rôle |
|---|---|
| `auth` | Login email/Google + PIN, inscription, `app_lock` (verrouillage hors-ligne par hash local du PIN) |
| `caisse` | POS : catalogue, numpad, panier, prix négocié, lots, ticket, impression thermique |
| `stock` | Produits, catégories (avec couleurs), mouvements de stock, alertes rupture/bas |
| `tiers` | Clients & fournisseurs, soldes "Doit", paiements |
| `sessions` | Ouverture/fermeture de caisse, historique, détail + réconciliation, rapport |
| `ventes` | Historique groupé par date, filtres, retour de vente, réimpression |
| `dashboard` | Vue propriétaire consolidée multi-boutique + performance par boutique |
| `users` | **Gestion des gérants (écran dédié)** |
| `abonnements` | Plan FREE/PRO, catalogue des offres (`plan_catalog.dart`), page tarifs |
| `settings` | Profil, boutique, reçu (en-tête/pied), imprimante |
| `shop` | Boutique en ligne du commerce (catalogue, panier) |
| `sync` | `SyncService` : `pushPending()` / `pullCatalogue()` |
| `boutiques` | Liste/création de boutiques (OWNER) |

### Sync offline-first (flux)

1. Écriture locale immédiate avec `synced = false`.
2. `syncInitProvider` au démarrage → `pullCatalogue()` puis `pushPending()`.
3. Reconnexion (`connectivity_plus`) → `pushPending()` automatique.
4. Backend confirme → marquage `synced = true` (+ `serverVenteId`).

### Design system

Vert `#1B6B2F`, Accent `#F5A623`, fond `#F7F7F5`, texte brun `#3D1F00`. Font Inter (400/500/600/700). Boutons 52 px, cartes radius 16 px, inputs 8 px. Constantes de spacing dans `lib/core/theme/app_spacing.dart` (pas de `SizedBox` arbitraires).

---

## 5. Ambassadeurs & Landing

- **`ambassadeur-pwa/`** (React 18 + Vite + TS) : inscription/parrainage, filleuls, gains, commissions, versements (plafond 200 k FCFA), notifications push (Web Push + VAPID). Constantes API dans `src/api/client.ts` (prod : `https://business.babicash.ci/api/v1`).
- **`landing/`** : site statique (HTML/JS/CSS) avec SEO complet (OG, Twitter Cards, JSON-LD, `robots.txt`, `sitemap.xml`), collecte de leads (`POST /api/v1/landing-leads`).

---

## 6. CI/CD

`.github/workflows/` :
- `backend-ci.yml` : tests pytest + ruff + build Docker (sur `main`/`develop`, chemin `backend/**`).
- `backend-deploy.yml` : push sur `main` → SSH + Docker sur le VPS.
- `frontend-ci.yml` : `flutter analyze --no-fatal-infos` + `flutter test --coverage` + Codecov, puis build APK + Web sur `main`.

Pas d'auto-deploy pour le frontend Flutter ni la PWA ambassadeur (voir `backend/DEPLOY.md`).

---

## 7. Règles globales pour tout agent IA

1. **Ne jamais éditer** les fichiers générés (`*.g.dart`, `*.freezed.dart`, `*_database.g.dart`). Relancer `dart run build_runner build --delete-conflicting-outputs`.
2. **Toujours obtenir le `boutique_id` du contexte utilisateur** (token/`currentBoutiqueIdProvider`) — ne jamais interroger sans cloisonnement multi-tenant.
3. **Offline-first** : toute écriture passe d'abord par la base locale, jamais de blocage réseau en UI.
4. **Montants** : Decimal Côté backend, ne jamais utiliser de float pour de l'argent.
5. Après modification Drift/Freezed/Riverpod : `build_runner`. Après modification backend : `pytest`. Valider avec `flutter analyze --no-fatal-infos`.
6. **Utiliser les constantes** de spacing/theme/valeurs existantes (pas de valeurs ad-hoc).
7. Commits : conventionnels (`feat:`, `fix:`, `docs:`, `refactor:`), branche `main`.
8. Documents officiels à consulter avant de coder : `docs/design-*.md`, `DOSSIER_TECHNIQUE.md` (référence globale, partiellement historique), `backend/DEPLOY.md`.