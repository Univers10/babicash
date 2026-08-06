# Design — Système d'ambassadeurs & parrainage

> Statut : **spécifié, prêt à implémenter** · Rédigé le 2026-07-28
> Périmètre : backend (FastAPI) + admin + **nouvelle PWA ambassadeur** (React/Vite)

## Décisions verrouillées

| Sujet | Décision |
|---|---|
| Qui est ambassadeur | **Inscription volontaire** — toute personne (même non-commerçante) crée un compte ambassadeur |
| Le code | **Choisi par l'ambassadeur** (vanity code), unicité vérifiée en temps réel |
| Récompense | **Commission cash = 20 % du montant payé par le filleul**, pendant **12 mois** |
| Versement | **Hebdomadaire**, par **Mobile Money** (lot admin) |
| Déclencheur de commission | **Validation admin** du paiement (pas de passerelle pour l'instant) |
| Front ambassadeur | **PWA légère React + Vite** (installable, rapide en bas débit, look « genre Wave ») |

---

## 1. Vision

Inciter les gens à promouvoir BabiCash. Un **ambassadeur** s'inscrit, choisit son **code de parrainage**, le partage. Quand un commerçant crée son compte avec ce code (le **filleul**) puis **paie un abonnement**, l'ambassadeur touche **20 % de chaque paiement du filleul pendant 12 mois**, **versé chaque semaine** sur son Mobile Money.

L'ambassadeur suit tout depuis **son espace perso façon appli bancaire** : solde à recevoir, liste de ses filleuls et de leurs abonnements, historique des commissions et des versements.

## 2. Acteurs & rôles

| Acteur | Description |
|---|---|
| **Ambassadeur** | Nouveau rôle `AMBASSADEUR` sur `User`. Peut n'avoir aucune boutique. Se connecte à la **PWA ambassadeur**. |
| **Filleul** | Un `OWNER` inscrit avec un code de parrainage. Rattaché **définitivement** à un ambassadeur. |
| **Admin** | Confirme les paiements (déclenche les commissions) et exécute les versements hebdo. Interface admin existante (Jinja2). |

> Un commerçant (`OWNER`) existant peut **aussi** devenir ambassadeur : on crée un profil `Ambassadeur` lié à son `User`. Il ne peut pas utiliser son propre code sur son propre compte.

## 3. Règles métier

### 3.1 Le code de parrainage
- Choisi par l'ambassadeur, **4 à 20 caractères** `A–Z 0–9` (option : tiret interne). Insensible à la casse, **stocké en majuscules**.
- **Unique** sur toute la plateforme. Endpoint de disponibilité en temps réel (« ✅ libre » / « ❌ déjà pris »).
- **Liste noire** : `BABICASH`, `ADMIN`, `SUPPORT`, `WAVE`, insultes, tentatives d'usurpation.
- Désactivable par l'admin (fraude) sans casser les rattachements déjà faits.

### 3.2 La commission
- **Assiette** = montant **réellement payé** par le filleul pour son abonnement, c.-à-d. le **prix mensuel total** (multi-boutique inclus : `prix_base × (1 + 0,75 × (N−1))`, cf. [`calculer_prix_total`](../backend/app/services/abonnement_service.py)). Pas le seul `prix_base`.
- **Taux** = **20 %**.
- **Le plan FREE ne génère rien** (0 FCFA). La commission n'existe que sur un plan payant (KIOSQUE → EMPIRE).
- **Fenêtre de droits = 12 mois** à compter du **1er paiement** du filleul. Chaque paiement/renouvellement confirmé dans cette fenêtre crée une commission ; après 12 mois, plus rien pour ce filleul.

Exemples (1 boutique) :

| Plan filleul | Payé / mois | Commission ambassadeur |
|---|---|---|
| KIOSQUE | 2 000 FCFA | **400 FCFA** |
| BOUTIQUE | 5 000 FCFA | **1 000 FCFA** |
| COMMERCE | 10 000 FCFA | **2 000 FCFA** |
| ENTREPRISE | 15 000 FCFA | **3 000 FCFA** |
| EMPIRE | 20 000 FCFA | **4 000 FCFA** |

### 3.3 Le versement hebdomadaire
- Chaque commission naît en statut `VALIDÉE` (le paiement filleul étant confirmé par l'admin — voir 3.5).
- **Une fois par semaine** (ex. lundi), un lot **`Payout`** agrège toutes les commissions `VALIDÉE` non encore versées d'un ambassadeur → un montant total à payer sur son Mobile Money.
- **Seuil minimum** (option, ex. 1 000 FCFA) : en dessous, le solde est reporté à la semaine suivante.
- L'admin exécute le transfert MoMo (manuel), saisit la référence → le `Payout` passe `PAYÉ` et les commissions liées passent `PAYÉE`.

### 3.4 Anti-abus
- **Pas d'auto-parrainage** : refus si le filleul partage email / téléphone / n° MoMo avec l'ambassadeur.
- **1 parrain définitif** par filleul (rattachement figé au premier enregistrement, jamais modifiable).
- Commission créée **seulement au paiement confirmé** — jamais à la simple inscription, ni au self-serve `/abonnements/upgrade` (qui n'implique aucun paiement réel aujourd'hui).
- Code désactivable ; ambassadeur désactivable.

### 3.5 Déclencheur (validation admin)
Aujourd'hui il n'existe **aucune passerelle de paiement**. Le paiement est confirmé **par l'admin** :
- L'admin, après réception du paiement (MoMo/espèces), utilise l'action « **Confirmer le paiement** » (extension de [`owner_change_plan`](../backend/app/admin/routes.py)).
- Cette action : (1) active/renouvelle le plan, (2) **crée un `PaiementAbonnement`** (traçabilité + revenus réels), (3) si l'owner a un parrain dans sa fenêtre 12 mois → **crée la `CommissionParrainage`** (`VALIDÉE`).

---

## 4. Modèle de données (backend)

### 4.1 Modifications de tables existantes

**`User`** ([models.py](../backend/app/models/models.py)) :
- `role` : ajouter la valeur **`AMBASSADEUR`** (actuel : `OWNER | MANAGER`).
- `parraine_par_ambassadeur_id : uuid | None` — FK `ambassadeurs.id`, **nullable, figé** à l'inscription.

### 4.2 Nouvelles tables

**`ambassadeurs`** (profil 1-1 vers `User`)

| Colonne | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `user_id` | uuid FK users, unique | le compte de connexion |
| `code` | str(20) unique, index | vanity code, majuscules |
| `momo_numero` | str(30) | n° de versement |
| `momo_operateur` | str(20) | WAVE / ORANGE / MTN / MOOV |
| `actif` | bool | désactivable par admin |
| `date_creation` | datetime | |

**`paiements_abonnement`** (journal des paiements confirmés)

| Colonne | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `proprietaire_id` | str(255) | l'owner qui paie |
| `abonnement_id` | uuid FK abonnements | |
| `plan` | str(20) | plan payé |
| `montant` | Numeric(12,2) | montant réellement payé |
| `periode_debut` / `periode_fin` | datetime | couverture |
| `confirme_par` | uuid FK users | admin |
| `date_paiement` | datetime | |

**`commissions_parrainage`**

| Colonne | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `ambassadeur_id` | uuid FK ambassadeurs, index | le parrain |
| `filleul_id` | uuid FK users | l'owner filleul |
| `paiement_id` | uuid FK paiements_abonnement | source |
| `montant_paye` | Numeric(12,2) | assiette |
| `taux` | Numeric(4,3) | 0.200 |
| `montant_commission` | Numeric(12,2) | = montant_paye × taux |
| `statut` | str(15) | `VALIDÉE \| PAYÉE \| ANNULÉE` |
| `payout_id` | uuid FK payouts, nullable | lot de versement |
| `date_creation` | datetime | |

**`payouts`** (lots hebdomadaires)

| Colonne | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `ambassadeur_id` | uuid FK ambassadeurs, index | |
| `semaine` | str(10) | ex. `2026-W31` |
| `montant_total` | Numeric(12,2) | somme des commissions du lot |
| `momo_numero` | str(30) | figé au moment du lot |
| `statut` | str(10) | `A_PAYER \| PAYÉ` |
| `reference_transfert` | str(100), nullable | réf MoMo saisie par l'admin |
| `date_creation` / `date_execution` | datetime | |

### 4.3 Migration
Une migration Alembic sur le modèle de [`20260723_..._add_recu_configs.py`](../backend/alembic/versions/20260723_1200_a2b3c4d5e6f8_add_recu_configs.py) : 4 tables + la colonne `parraine_par_ambassadeur_id` + acceptation du rôle `AMBASSADEUR`. Pas de backfill (aucun ambassadeur existant).

---

## 5. API backend

Base : `/api/v1`. Réutilise l'auth JWT existante (le `sub` du token = `User.id`, `role` embarqué).

### 5.1 Ambassadeur — auth & profil
| Méthode | Route | Rôle | Description |
|---|---|---|---|
| POST | `/ambassadeurs/register` | public | Crée `User(role=AMBASSADEUR)` **sans** boutique/abonnement + profil `Ambassadeur`. Body : nom, email/tel, mot de passe, code choisi, momo_numero, momo_operateur. |
| POST | `/ambassadeurs/login` | public | Connexion (réutilise le flux existant / rate-limit). |
| GET | `/ambassadeurs/code-disponible?code=XXX` | public | Vérif temps réel (format + unicité + liste noire). |
| GET | `/ambassadeurs/moi` | AMBASSADEUR | Synthèse : code, solde à recevoir, prochain versement, totaux. |

### 5.2 Ambassadeur — données du dashboard
| Méthode | Route | Description |
|---|---|---|
| GET | `/ambassadeurs/filleuls` | Liste des filleuls + leur abonnement (plan, statut, date) + commission cumulée par filleul. |
| GET | `/ambassadeurs/commissions` | Historique des commissions (activité, style « transactions »). |
| GET | `/ambassadeurs/versements` | Historique des `Payout` (payés / à payer). |
| PATCH | `/ambassadeurs/moi` | Modifier n° MoMo / opérateur. |

### 5.3 Filleul (inscription owner modifiée)
- [`RegisterRequest`](../backend/app/schemas/auth.py) : ajouter `code_parrainage: str | None`.
- [`register`](../backend/app/api/v1/auth.py) + [`provision_owner_with_boutique`](../backend/app/api/v1/auth.py) : résoudre le code → poser `parraine_par_ambassadeur_id`. Code inconnu/inactif = inscription **quand même OK**, sans parrain (log discret).

### 5.4 Admin
- Extension de [`owner_change_plan`](../backend/app/admin/routes.py) → action « **Confirmer paiement** » : active le plan + crée `PaiementAbonnement` + crée la commission si éligible.
- Nouvelle page admin **« Ambassadeurs »** : liste, filleuls, commissions, désactivation d'un code.
- Nouvelle page admin **« Versements de la semaine »** : lots `A_PAYER`, marquer `PAYÉ` (saisie référence).
- Génération des lots : commande/tâche hebdo (`generer_payouts_semaine`) ou bouton admin « Générer le lot ».

---

## 6. Flux

**Inscription ambassadeur**
1. PWA → choix du code (check dispo live) + infos MoMo → `POST /ambassadeurs/register` → JWT → dashboard.

**Rattachement filleul**
2. Owner s'inscrit avec `code_parrainage` → `parraine_par_ambassadeur_id` posé (définitif).

**Génération de commission**
3. Admin confirme un paiement d'abonnement → `PaiementAbonnement` créé → si filleul a un parrain **et** dans les 12 mois → `CommissionParrainage(VALIDÉE)`.

**Versement hebdo**
4. Lundi : `generer_payouts_semaine` agrège les commissions `VALIDÉE` sans `payout_id` par ambassadeur (≥ seuil) → `Payout(A_PAYER)`.
5. Admin fait le transfert MoMo, saisit la réf → `Payout(PAYÉ)` + commissions → `PAYÉE`. Le dashboard ambassadeur se met à jour.

---

## 7. PWA Ambassadeur (React + Vite)

### 7.1 Stack & structure
Nouveau dossier à la racine, ex. `ambassadeur-pwa/` (séparé de `frontend/` Flutter) :
- **React + Vite + TypeScript**, `vite-plugin-pwa` (manifest + service worker Workbox).
- State/serveur : React Query (cache + revalidation), Zustand pour l'auth token.
- Client HTTP : `fetch`/axios vers `https://business.babicash.ci/api/v1`.
- Léger, mobile-first, une seule colonne. Objectif : bundle initial de l'ordre de ~150 Ko gzip.

### 7.2 Écrans (look « genre Wave »)
- **Connexion / Inscription ambassadeur** (choix du code avec indicateur de disponibilité).
- **Accueil** : grand montant *« Commission à recevoir »* + *« Prochain versement : … »* ; carte **code de parrainage** (Copier / Partager via Web Share API) ; 3 stats (filleuls, filleuls payants, total gagné à vie) ; aperçu activité récente.
- **Filleuls** : liste, chacun avec son abonnement (plan, actif/expiré, depuis) et sa commission.
- **Gains** : activité (commissions) + historique des versements hebdo.
- **Profil** : n° Mobile Money + opérateur, déconnexion.
- **Navigation basse** : Accueil · Filleuls · Gains · Profil.

### 7.3 PWA & thème
- `manifest.json` : nom « BabiCash Ambassadeur », `display: standalone`, `theme_color: #1B6B2F`, `background_color`, icônes 192/512 + maskable.
- Service worker : precache du shell (ouverture instantanée), runtime cache des dernières données (affichage hors-ligne, montants revalidés à la reconnexion).
- Design system aligné BabiCash : vert `#1B6B2F`, orange `#F5A623`, police Inter, coins arrondis, boutons ~52 px.

### 7.4 Déploiement
Build statique (`vite build`) servi en site statique (le backend a déjà `/static`, ou hébergement statique dédié). À câbler dans le CI plus tard (pas d'auto-deploy front aujourd'hui).

---

## 8. Sécurité
- Endpoints ambassadeur protégés par un garde de rôle `AMBASSADEUR` (comme `require_owner`).
- Un ambassadeur ne voit **que ses** filleuls/commissions/versements.
- Données filleul exposées **minimales** : nom + plan + statut + date. Pas d'infos sensibles (téléphone, CA, ventes).
- Anti-auto-parrainage vérifié à la confirmation de paiement.
- `momo_numero` = donnée de contact (pas un secret), stockée en clair, modifiable par l'ambassadeur uniquement.

## 9. Découpage en phases

1. **Backend — socle** : modèle + migration (4 tables + colonne), rôle `AMBASSADEUR`, inscription/login ambassadeur, `code-disponible`.
2. **Rattachement** : `code_parrainage` à l'inscription owner + résolution.
3. **Commissions** : `PaiementAbonnement` + hook dans la confirmation admin + endpoints `filleuls`/`commissions`.
4. **Versements** : `Payout`, génération hebdo, pages admin (ambassadeurs + versements).
5. **PWA** : projet React/Vite, auth, dashboard Wave-style, PWA/manifest/SW.
6. **Finitions** : partage (Web Share), seuil de versement, liste noire, tests.

## 10. Points ouverts / évolutions futures
- **Bonus filleul** (parrainage à double face : -X % ou jours offerts au filleul) — non retenu pour l'instant, fort levier de conversion.
- **Seuil minimum** de versement : valeur à fixer (proposé 1 000 FCFA).
- **Deep-link** de partage pré-remplissant le code à l'inscription.
- **Passerelle de paiement** (Wave/CinetPay/MoMo) : migrera le déclencheur de « validation admin » vers un webhook.
- Automatisation du transfert MoMo (aujourd'hui manuel).
