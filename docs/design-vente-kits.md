# Conception — Vente en groupe / kits (C6)

> **Statut : conception uniquement — aucun code implémenté.**
> Retour bêta : dans un maquis, la bière est à 700 F l'unité, mais le « kit de 3 »
> se vend 2 000 F au lieu de 2 100 F, et le client peut panacher 3 marques
> différentes. Il faut vendre ce kit en un geste, avec le bon prix et le bon
> décrément de stock par marque réellement servie.

## 1. Besoin et contraintes

- **Prix de lot** : N unités pour un prix fixe inférieur à N × prix unitaire.
- **Panachage** : les N unités peuvent venir de produits différents, tant qu'ils
  appartiennent au périmètre du kit (ex. « toute bière 700 F », ou une liste
  explicite de marques).
- **Stock** : le stock doit être décrémenté **par composant réel** (2 Flag +
  1 Castel), jamais sur un pseudo-produit « kit ».
- **Offline-first** : la définition des kits doit être disponible hors ligne
  (table locale Drift synchronisée), la vente suit le flux existant
  (`synced = false` → push).
- **Quota** : un kit vendu = **une vente** (une seule `LocalVentes`), quel que
  soit le nombre de composants — cohérent avec le quota mensuel par boutique.

## 2. Modèle de données proposé

Deux nouvelles tables (backend + miroir Drift local, `synced` non nécessaire côté
local car catalogue en lecture seule, alimenté par le pull) :

### `kits`

| Champ | Type | Rôle |
|---|---|---|
| `id` | UUID | PK |
| `boutique_id` | UUID | multi-tenant, comme partout |
| `nom` | str | « Kit 3 bières » |
| `prix_kit` | Decimal | 2000 — prix total fixe du kit |
| `quantite_totale` | int | 3 — nombre d'unités à choisir |
| `actif` | bool | masquer sans supprimer |
| `updated_at` | datetime | pull incrémental |

### `kit_composants` — périmètre d'éligibilité (flexible)

| Champ | Type | Rôle |
|---|---|---|
| `id` | UUID | PK |
| `kit_id` | UUID | FK `kits` |
| `produit_id` | UUID? | éligibilité par produit précis… |
| `categorie_id` | UUID? | …ou par catégorie entière (exclusif : un seul des deux renseigné) |
| `quantite_min` / `quantite_max` | int? | quotas optionnels par composant (ex. max 1 « premium ») |

Un kit « 3 bières panachées » = 1 ligne `kit_composants` avec
`categorie_id = Bières` ; un kit fermé « 2 Flag + 1 Castel » = 2 lignes
`produit_id` avec `quantite_min = quantite_max`.

### Vente d'un kit

Pas de nouveau type de vente. La vente porte :

- `LocalLignesVente` **par composant réel choisi** (2 × Flag, 1 × Castel) avec
  `prix_vendu_reel` **réparti au prorata** du prix unitaire de chaque composant
  (2000 × 700/2100 ≈ 666,67 F par bière ici, arrondi au franc avec ajustement du
  dernier composant pour que la somme fasse exactement 2000). La marge par ligne
  reste donc calculable avec la mécanique existante.
- Un champ `kit_id` (nullable) + `kit_instance` (int, pour distinguer 2 kits
  identiques dans la même vente) sur `lignes_vente` afin de regrouper les lignes
  sur le ticket (« Kit 3 bières — 2 000 F » avec le détail en dessous).

**Stock** : décrément composant par composant via les lignes de vente — aucun
changement du moteur de stock.

**Sync/backend** : `SyncPushRequest` transporte déjà les lignes ; il s'enrichit
de `kit_id`/`kit_instance` (rétro-compatible, champs optionnels). Le backend
valide que la somme des lignes d'un même kit = `prix_kit` et que la composition
respecte `kit_composants`. Le pull catalogue ajoute `kits` + `kit_composants`.

## 3. UX en caisse (composition rapide)

1. Les kits apparaissent comme des **tuiles dédiées en tête du catalogue**
   (bandeau « Kits » ou puce de catégorie virtuelle « Kits », visuellement
   distinctes : bordure accent + prix barré 2 100 F → 2 000 F).
2. Tap sur la tuile → **feuille de composition** : la grille des produits
   éligibles (filtrée par `kit_composants`), un compteur « 0/3 », chaque tap
   ajoute 1 unité d'une marque (re-tap sur la même marque = +1). Raccourci
   « Tout pareil » : remplit les 3 avec la marque tapée.
3. À 3/3 le bouton « Ajouter au panier » s'active ; le panier affiche **une
   ligne pliable** « Kit 3 bières — 2 000 F » avec le détail des marques,
   décrément/suppression au niveau du kit entier (pas d'un composant isolé,
   sinon le prix de lot n'a plus de sens).
4. Cas ultra-fréquent (même marque) : appui long sur un produit éligible
   pourrait proposer « Ajouter en kit ×3 » — optimisation v2.

## 4. Alternatives envisagées

| Option | Avantages | Inconvénients |
|---|---|---|
| **A. Produit « kit » dédié** (un produit à 2 000 F par combinaison) | zéro dev | explosion combinatoire du panachage, stock faux (pas de décrément des composants) — c'est le contournement actuel des testeurs |
| **B. Remise automatique par paliers** (3 articles d'une catégorie → −100 F) | pas de nouvelle table de composition | règle de prix implicite, illisible sur le ticket ; difficile de limiter à « exactement 3 » ; marge par ligne ambiguë |
| **C. Tables `kits` + composition + répartition prorata (proposée)** | prix exact, stock exact par marque, ticket lisible, marge correcte, offline | 2 tables + écran de composition à développer |

**Recommandation : option C**, en réutilisant intégralement le flux de vente et
de stock existants (le kit n'est qu'un « assistant de saisie + contrat de
prix », pas un nouveau type d'objet vendu). Prévoir l'option B comme évolution
future pour les promos générales, mais elle ne couvre pas le panachage contrôlé.

## 5. Découpage prévisionnel (hors périmètre v1.1)

1. Backend : tables + endpoints CRUD kits + validation au push (migration Alembic — réservé à l'agent STOCK/backend).
2. Drift : tables miroir + pull catalogue (idem, schéma réservé).
3. Caisse : tuiles kits + feuille de composition + regroupement panier/ticket.
4. Rapports : agréger les lignes par `kit_id` dans les tickets et rapports de session.
