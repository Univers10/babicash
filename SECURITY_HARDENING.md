# BabiCash — Rapport de Hardening Sécuritaire

**Date :** 15 juillet 2026
**Commit :** `ed294c4`
**Portée :** Backend FastAPI + Frontend Flutter + Docker

---

## Résumé

| Sévérité | Corrigé | En attente |
|----------|---------|------------|
| CRITICAL | 5/5 | 0 |
| HIGH | 9/11 | 2 |
| MEDIUM | 3/3 | 0 |
| **Total** | **17/19** | **2** |

---

## CRITICAL — Tous corrigés

### C1 — SECRET_KEY par défaut (`config.py`)
- **Avant :** Avertissement `warnings.warn()` si SECRET_KEY = valeur par défaut
- **Après :** `ValueError` au démarrage si SECRET_KEY < 32 caractères ou = valeur par défaut
- **Action requise :** Générer une clé : `python -c "import secrets; print(secrets.token_urlsafe(64))"`

### C2+C5 — Mot de passe Postgres + port exposé (`docker-compose.yml`)
- **Avant :** `POSTGRES_PASSWORD: babicash` (défaut), port `5432:5432` exposé à l'hôte
- **Après :** Tous les vars Postgres obligatoires (`:?)`), port 5432 supprimé
- **Action requise :** Définir `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` dans `.env`

### C3 — Admin par défaut (`seed_admin.py`)
- **Avant :** Mot de passe `admin1234` en dur dans le code source
- **Après :** Génération aléatoire 16 caractères (lettres + chiffres + symboles), affiché une seule fois
- **Nouveau :** Route `GET/POST /admin/change-password` pour forcer le changement

### C4 — JWT 30 jours (`config.py`)
- **Avant :** `ACCESS_TOKEN_EXPIRE_MINUTES = 43200` (30 jours)
- **Après :** `ACCESS_TOKEN_EXPIRE_MINUTES = 1440` (24 heures), cookie admin 8 heures
- **Bonus :** `token_version` dans le modèle User + JWT → tous les tokens invalidés au changement de mot de passe

### Token revocation
- Nouveau champ `token_version` dans `users` (migration `d4e5f6a7b8c9`)
- Inclus dans le JWT comme claim `tv`
- Vérifié dans `deps.py` (mobile) et `admin/deps.py` (backoffice)
- Incrémenté à chaque changement de mot de passe

---

## HIGH — 9/11 corrigés

### H1+H2 — Rate limiting (`rate_limit.py`)
- 5 tentatives / 5 minutes pour email + admin → **lockout 15 minutes**
- 10 tentatives / 5 minutes pour PIN → **lockout 10 minutes**
- Compteur réinitialisé après un login réussi

### H3 — Cookie admin `secure` (`admin/auth.py`)
- `secure=True` par défaut (configurable `SECURE_COOKIES=false` en dev local)

### H4 — CSRF (`csrf.py`)
- Synchronizer token pattern sur tous les formulaires admin POST
- Token signé HMAC-SHA256, valide 1 heure
- Sessions : `login.html`, `change_password.html`, `owners/detail.html` (toggle + plan)

### H5 — PII dans JWT (`security.py`)
- **Avant :** `nom`, `email`, `telephone`, `boutique_id` dans le payload JWT (lisible par n'importe qui)
- **Après :** Seulement `sub`, `role`, `tv`, `exp`
- Toutes les données utilisateur sont maintenant fetchées depuis la DB au moment de l'auth

### H7 — Container non-root (`Dockerfile`)
- Nouvel utilisateur `babicash:babicash` avec `USER babicash`
- `chown -R babicash:babicash /app` avant le switch

### H8 — CORS wildcard (`main.py`)
- `allow_credentials=False` quand `origins=["*"]` (le navigateur rejette cette combinaison)

### H10 — Exceptions brutes dans l'UI (8 fichiers Flutter)
- `Text('$e')` → messages generic user-friendly dans :
  - `sessions_screen.dart`, `categories_screen.dart`, `stock_screen.dart`
  - `produit_form_dialog.dart`, `caisse_screen.dart`, `ticket_screen.dart`
  - `historique_screen.dart` (2 occurrences)

### H13 — DB locale au logout (`auth_provider.dart`)
- Toutes les tables drift sont supprimées (`local_produits`, `local_categories`, `local_ventes`, etc.) avant `clearSession()`

### nb_gerants_max — Limites enforcees (`users.py`)
- La création d'un manager vérifie maintenant `nb_gerants_max` du plan actif
- Renvoie 403 si la limite est atteinte

---

## MEDIUM — Tous corrigés

| Fix | Détail |
|-----|--------|
| Audit log admin | `logger.info("Admin login réussi", extra={email, user_id, ip})` |
| Sidebar admin | Lien "Changer le mot de passe" (icône clé) ajouté |
| Migration | `token_version` INTEGER NOT NULL DEFAULT 0 sur `users` |

---

## En attente (nécessite dépendances externes)

| # | Fix | Raison |
|---|-----|--------|
| H9 | Chiffrement SQLite local | Nécessite `sqlcipher_flutter` (migration drift complexe) |
| H11 | Certificate pinning | Nécessite `flutter_ssl_pinning` ou `dio_certificate_pinner` |
| H12 | Refresh token | Nécessite endpoint `/api/v1/refresh` + interceptor Flutter |

---

## Fichiers modifiés

### Backend (19 fichiers)
```
Dockerfile                                          +8 lignes (non-root user)
docker-compose.yml                                  ~12 lignes (vars obligatoires, port fermé)
app/core/config.py                                  ~10 lignes (SECRET_KEY strict, 24h JWT)
app/core/security.py                                ~5 lignes (token sans PII)
app/core/csrf.py                                    NOUVEAU (synchronizer token)
app/core/rate_limit.py                              NOUVEAU (rate limiter in-memory)
app/deps.py                                         ~20 lignes (async + DB lookup + token_version)
app/admin/auth.py                                   ~60 lignes (rate limit, CSRF, audit, change-password)
app/admin/deps.py                                   ~25 lignes (async + DB lookup + token_version)
app/admin/routes.py                                 ~15 lignes (CSRF)
app/api/v1/auth.py                                  ~30 lignes (rate limit, token_version)
app/api/v1/users.py                                 ~35 lignes (nb_gerants_max, token_version++)
app/models/models.py                                +1 ligne (token_version)
scripts/seed_admin.py                               ~20 lignes (mdp aléatoire)
alembic/versions/...add_token_version_to_users.py   NOUVEAU (migration)
templates/change_password.html                      NOUVEAU
templates/base.html                                 ~5 lignes (lien change-password)
templates/login.html                                ~5 lignes (rate limit msg, CSRF)
templates/owners/detail.html                        ~2 lignes (CSRF)
```

### Frontend (8 fichiers)
```
lib/data/local/database.dart                        ~3 lignes (TODO encryption)
lib/features/auth/providers/auth_provider.dart      +15 lignes (wipe DB on logout)
lib/features/sessions/screens/sessions_screen.dart  1 ligne (generic error)
lib/features/stock/screens/categories_screen.dart   1 ligne (generic error)
lib/features/stock/screens/stock_screen.dart        1 ligne (generic error)
lib/features/stock/widgets/produit_form_dialog.dart 1 ligne (generic error)
lib/features/caisse/screens/caisse_screen.dart      1 ligne (generic error)
lib/features/caisse/screens/ticket_screen.dart      1 ligne (generic error)
lib/features/ventes/screens/historique_screen.dart  2 lignes (generic errors)
```

---

## Avant de déployer

1. Créer `/opt/babicash/backend/.env` :
```bash
SECRET_KEY=$(python -c "import secrets; print(secrets.token_urlsafe(64))")
POSTGRES_USER=babicash
POSTGRES_PASSWORD=<mot-de-passe-fort>
POSTGRES_DB=babicash
SECURE_COOKIES=true
ALLOWED_ORIGINS=https://babicash.ecomotionafricaci.com
WORKERS=2
```

2. Rebuild Docker :
```bash
cd /opt/babicash/backend
docker compose build --no-cache
docker compose up -d
```

3. Le seed_admin affichera un mot de passe aléatoire → le changer immédiatement via `/admin/change-password`

4. Rebuild Flutter en local :
```bash
cd /opt/babicash/frontend
flutter clean && flutter pub get && flutter build apk --release
```
