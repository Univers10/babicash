# Retours bêta-testeurs — Corrections v1.1

> Source : première vague de bêta-test (juillet 2026). Chaque section est traitée
> par un agent dédié sur une branche isolée, puis fusionnée dans `main`.

## Règles transverses

- **Offline-first** : toute écriture passe d'abord par Drift (`synced = false`), puis sync.
- **Design system** : couleurs/espacements de `lib/core/theme/` et `app_spacing.dart`, pas de valeurs ad hoc.
- **Un seul agent (STOCK) est autorisé à modifier le schéma Drift et le backend** (migration Alembic), pour éviter les conflits de `schemaVersion` et de têtes de migration.
- La notion **« Sans catégorie »** est un regroupement *virtuel* à l'affichage (produits avec `categorieId == null`), jamais une catégorie créée en base.
- Tri alphabétique des catégories : insensible à la casse et aux accents (`compareTo` sur une clé normalisée).

---

## 1. PRODUIT — gestion des catégories

**Contexte** : `lib/features/stock/` (produits & catégories partagent la feature stock) — `produit_form_dialog.dart`, `produits_crud_provider.dart`, `categories_crud_provider.dart`.

| # | Tâche | Critère d'acceptation |
|---|---|---|
| P1 | **Bug de mise à jour** : la catégorie est mal gérée lors de la modification d'un produit | Modifier un produit et changer sa catégorie → la nouvelle catégorie est persistée localement (`synced=false`) puis synchronisée ; aucune régression sur les autres champs |
| P2 | Catégories triées par **ordre alphabétique** | Partout où une liste de catégories s'affiche (dropdown, filtres, écran catégories) |
| P3 | **Précharger la catégorie actuelle** dans le formulaire d'édition | Ouvrir l'édition d'un produit → sa catégorie est présélectionnée dans le dropdown |
| P4 | **Recherche dans le dropdown** catégorie | Saisie texte filtre la liste (type Autocomplete) ; utilisable avec 50+ catégories |
| P5 | Regrouper les produits sans catégorie sous **« Sans catégorie »** | Groupe virtuel affiché en dernier ; aucun enregistrement créé en base |

## 2. STOCK — vrai système de gestion de stock

**Contexte** : `stock_screen.dart`, `stock_provider.dart`. Seul agent autorisé à toucher schéma Drift + backend.

| # | Tâche | Critère d'acceptation |
|---|---|---|
| S1 | **Rafraîchir l'interface stock** à chaque ouverture de l'écran | Les quantités affichées reflètent toujours l'état local (stream Drift ou invalidation à l'entrée) |
| S2 | **Mouvements de stock entrée/sortie** au lieu d'une édition directe de quantité | Dialog « Entrée / Sortie » avec quantité + motif ; la quantité produit est recalculée ; l'édition brute disparaît |
| S3 | **Journal des mouvements** avec le nom de l'auteur | Table `LocalMouvementsStock` (produit, type, quantité, motif, auteur, date, `synced`) + table/endpoint backend + sync ; écran ou onglet « Historique » |
| S4 | **Notification de modification de stock** | v1 : évènement visible dans le journal + indicateur (badge) ; le push serveur est documenté comme itération future, pas implémenté |
| S5 | Afficher les produits **dans la couleur de leur catégorie** | La carte produit reprend la couleur de la catégorie (bordure/pastille), lisible en clair et sombre |

## 3. CAISSE — ergonomie du panier

**Contexte** : `caisse_screen.dart`, `panier_widget.dart`, `catalogue_grid.dart`, `caisse_provider.dart`.

| # | Tâche | Critère d'acceptation |
|---|---|---|
| C1 | **Retirer un seul produit** du panier | Décrémenter ligne par ligne et supprimer une ligne entière, sans vider tout le panier |
| C2 | **Bouton client visible en portrait** | Le bouton d'association client est accessible en mode portrait sur petit écran |
| C3 | **Badge quantité** sur le produit du catalogue | Un produit présent dans le panier affiche un badge avec sa quantité, mis à jour en temps réel |
| C4 | Déplacer la **barre de recherche** du titre vers juste au-dessus des catégories | AppBar allégée ; la recherche filtre toujours le catalogue |
| C5 | Regrouper les produits sans catégorie sous **« Sans catégorie »** | Même règle virtuelle que P5, appliquée au filtre catégories de la caisse |
| C6 | **Vente en groupe / kits** (ex : bière 700 F l'unité, kit de 3 à 2 000 F, marques panachables) | **Conception uniquement** : document `docs/design-vente-kits.md` (modèle de données, UX caisse, impact sync/backend, quotas) — pas de code |

## 4. SESSION — historique et rapports

**Contexte** : `sessions_screen.dart`, `sessions_provider.dart`, table `LocalSessions`, impression via `thermal_print_service.dart` (réutiliser, ne pas modifier la config imprimante).

| # | Tâche | Critère d'acceptation |
|---|---|---|
| SE1 | **Historique des sessions** fermées | Liste chronologique (date, caissier, totaux) filtrée par boutique |
| SE2 | **Détail d'une session** | Écran détail : fond de caisse, ventes, dépenses, écart, ventes rattachées |
| SE3 | **Régénérer + imprimer le rapport** | Bouton depuis le détail → rapport regénéré à partir des données locales et imprimable sur l'imprimante thermique |

## 5. AUTH — verrouillage et reconnexion

**Contexte** : `auth_provider.dart`, `login_pin_screen.dart`, `app_router.dart`, `secure_storage.dart`.

| # | Tâche | Critère d'acceptation |
|---|---|---|
| A1 | **Verrouillage après 1 min hors de l'app** | App en arrière-plan > 60 s → au retour, écran de verrouillage PIN (comptes PIN) ; saisie correcte → retour à l'écran quitté ; les données locales restent intactes |
| A2 | **Session expirée → login PIN prérempli** | Sur 401/expiration, rediriger vers l'écran PIN avec le numéro de téléphone préchargé (depuis le secure storage), l'utilisateur ne ressaisit que son PIN |

> Ambiguïté tranchée : A1 est lu comme une **exigence de sécurité** (caisse partagée) et non comme une plainte. Le verrouillage concerne les comptes connectés par PIN (MANAGER) ; un OWNER connecté par email/Google n'est pas verrouillé par PIN.

## 6. PARAMÈTRES — configuration imprimante

**Contexte** : `settings_screen.dart`, `thermal_print_service.dart`, permissions Bluetooth déjà déclarées dans le manifest.

| # | Tâche | Critère d'acceptation |
|---|---|---|
| PA1 | **Écran « Configurer l'imprimante »** | Scan des imprimantes Bluetooth, sélection, mémorisation (persistée), bouton « Test d'impression » ; l'imprimante mémorisée est utilisée par la caisse et les rapports de session |

---

## Chevauchements connus (à réconcilier au merge)

- « Sans catégorie » : PRODUIT (P5) et CAISSE (C5) l'implémentent chacun dans leurs écrans — factoriser en un helper partagé au merge si dupliqué.
- Impression : PARAMÈTRES possède la sélection/config de l'imprimante ; SESSION ne fait que consommer le service d'impression.
