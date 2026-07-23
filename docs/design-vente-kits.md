# Conception — Vente en groupe / kits (C6) — v2

> **Statut : conception uniquement — aucun code implémenté.**
> Retour bêta : dans un maquis, la bière est à 700 F l'unité, mais le « kit de 3 »
> se vend 2 000 F au lieu de 2 100 F, et le client peut panacher 3 marques
> différentes. Il faut vendre ce kit en un geste, avec le bon prix et le bon
> décrément de stock par marque réellement servie.

---

## 0. Le retournement

La v1 de ce doc partait sur un **catalogue de kits géré** (tables `kits` +
`kit_composants`, validation de composition au backend, répartition au prorata).
C'est lourd, et ça crée une **tension frontale avec l'ADN de BabiCash** : les
ventes sont **négociables**. Le backend qui « rejette si somme des lignes ≠
prix_kit » contredirait le principe même du produit, et en offline-first
rejetterait au push une vente déjà encaissée.

**Réinterprétation.** Un kit n'est pas un objet vendu. C'est une **négociation de
groupe** : « ces N lignes partagent un prix total ». Or BabiCash sait déjà
vendre chaque ligne à un prix négocié arbitraire. Le kit ne demande donc **aucun
nouveau type de vente, aucune validation bloquante, aucun risque de rejet au
sync** — juste un mécanisme pour **répartir un prix cible sur un groupe de
lignes**, et (optionnellement) **sauver ce geste comme modèle réutilisable**.

Le catalogue de kits redevient ce qu'il aurait dû être depuis le début : du
**sucre** par-dessus une primitive, pas le cœur du système.

---

## 1. La primitive : le « lot » (prix de groupe)

Dans le panier, un sous-ensemble de lignes peut être groupé en **lot** doté d'un
**prix total cible**. L'app répartit ce total sur les lignes ; chaque ligne
**garde son `produit_id` réel** (donc le stock se décrémente par marque, sans
rien changer au moteur de stock) et reçoit un prix unitaire ajusté.

- **Une seule vente, N lignes** → quota inchangé.
- **100 % offline** : le total du lot n'est que la somme des prix négociés des
  lignes, que le backend accepte déjà. **Zéro nouvelle validation serveur.**
- Le lot est purement une **façon de saisir** une négociation courante vite.

### Schéma — impact minimal

Rien de neuf côté catalogue pour la primitive. On ajoute seulement sur
`lignes_vente` (backend + miroir Drift `LocalLignesVente`), en **champs
optionnels rétro-compatibles** :

| Champ | Type | Rôle |
|---|---|---|
| `lot_id` | UUID? | regroupe les lignes d'un même lot (une valeur par lot posé) |
| `lot_nom` | str? | libellé dénormalisé pour le ticket hors ligne (« Kit 3 bières ») |
| `lot_prix_total` | Decimal? | intention de prix du lot, pour l'affichage/rapports |

`lot_id` remplace avantageusement le `kit_id` + `kit_instance` (int) de la v1 :
deux lots identiques dans une vente = deux UUID, pas de calcul d'index.

Le `SyncPushRequest` transporte déjà les lignes → il embarque ces 3 champs sans
changement de contrat. Le backend les **stocke**, il ne les **juge pas**.

### L'algorithme de répartition (précis, déterministe)

Entrées : lignes-unités de prix unitaires `p₁…pₙ`, prix cible du lot `T`.
Total « naturel » `N = Σ pᵢ`.

1. Part brute de chaque unité : `raw_i = pᵢ × T / N`.
2. Arrondi au franc par la **méthode du plus fort reste** (Hamilton) :
   on prend `floor(raw_i)` pour tous, puis on distribue les
   `T − Σ floor(raw_i)` francs restants **+1 par +1** aux unités de plus forte
   partie fractionnaire. La somme fait **exactement `T`**, sans biais systématique.

> **Cas maquis (homogène — le cas réel).** 3 bières à 700, T = 2 000.
> `raw = 666,67` chacune → floors `666,666,666` (=1 998), reste 2 →
> **667 / 667 / 666**. Somme = 2 000. ✓ Quand tous les prix sont égaux, la
> répartition dégénère en simple partage équitable : aucune complexité.

> **Cas panaché à prix mixtes (dégradation gracieuse).** 2 bières à 700 +
> 1 premium à 1 000, T = 2 200. `N = 2 400`. Parts : `641,67 ; 641,67 ; 916,67`
> → floors `641,641,916` (=2 198), reste 2 → **642 / 642 / 916**. Somme = 2 200.
> La remise se répartit au prorata du prix : le premium garde proportionnellement
> sa valeur, la marge par ligne reste calculable par la mécanique existante.

Si `T ≥ N` (pas de remise, voire majoration), le même calcul s'applique — c'est
une négociation comme une autre, on ne l'interdit pas.

### UX (primitive)

1. Sélection multiple de lignes du panier (case à cocher, ou appui long sur une
   ligne → « Grouper avec… »).
2. « Prix de groupe » → saisie du total. Le panier affiche **une ligne pliable**
   « Lot — 2 000 F » avec le détail des marques dessous.
3. L'**économie** est affichée **calculée en direct** : `Σ pᵢ actuels − T`
   (jamais un « 2 100 » codé en dur — les prix bougent, y compris par
   négociation). Si les prix ont baissé et que le lot devient défavorable, on le
   signale au lieu d'afficher une fausse remise.
4. Décrément / suppression **au niveau du lot entier** (retirer une unité isolée
   d'un lot casse le sens du prix de groupe → interdit ; on dissout le lot pour
   revenir aux lignes libres).
5. **Rupture de stock** : la sélection grise les marques à 0 (données stock déjà
   disponibles via la feature mouvements), mais autorise l'override — réalité
   maquis : on vend ce qui est physiquement là.

---

## 2. Le sucre (phase 2) : modèles de kit réutilisables

Une fois la primitive en place, un **kit nommé** n'est qu'un **lot pré-rempli** :
une tuile qui, au tap, ouvre la feuille de composition avec le bon périmètre et
le bon prix cible déjà posés.

### `kits` (catalogue synchronisé, lecture seule en local)

| Champ | Type | Rôle |
|---|---|---|
| `id` / `boutique_id` | UUID | PK / multi-tenant |
| `nom` | str | « Kit 3 bières » |
| `prix_kit` | Decimal | prix cible pré-rempli |
| `quantite_totale` | int | nombre d'unités |
| `portee_categorie_id` | UUID? | périmètre = une catégorie (`null` = tout) |
| `actif` / `updated_at` | bool / datetime | masquage / pull incrémental |

**Volontairement, pas de table `kit_composants` ni de solveur de contraintes en
phase 2.** L'éligibilité = un simple **filtre de catégorie** (le panachage
« toutes bières » du maquis). Les compositions fermées (« 2 Flag + 1 Castel ») et
les quotas fins (« max 1 premium ») sont un **problème de satisfaction de
contraintes** qu'on programme mal facilement : reporté en **phase 3**, seulement
si des patrons le réclament vraiment. Le kit reste un **accélérateur de saisie**,
jamais un moteur de règles qui pourrait bloquer une vente.

Le kit n'ajoute **rien** au flux de vente : il produit un lot, exactement comme
le geste manuel. Tout ce qui suit (stock, sync, marge, quota) est déjà couvert
par la phase 1.

---

## 3. Rapports & ticket

Les lignes portent `lot_id` + `lot_nom`. Ticket de caisse et rapport de session
**regroupent par `lot_id`** : « Kit 3 bières — 2 000 F » puis le détail des
marques. Le rapport de session (feature déjà mergée) itère déjà les lignes → il
suffit d'agréger par `lot_id` à l'affichage. Aucun recalcul de totaux : la somme
des lignes = le total du lot, par construction.

---

## 4. Pourquoi ce design est meilleur que la v1

| Problème (v1) | Traitement (v2) |
|---|---|
| Validation backend « somme = prix_kit » qui rejette au sync | **Supprimée.** Le total du lot *est* la somme des prix négociés. Rien à valider. |
| Tension avec le prix négociable | **Devient la fondation** au lieu d'un conflit. |
| Solveur de composition (catégorie × produit × min/max) | **Repoussé en phase 3.** Phase 2 = simple filtre catégorie. |
| Prorata à prix mixtes fragile | **Isolé** dans un algorithme déterministe (Hamilton) ; trivial dans le cas homogène réel. |
| « Barré 2 100 » codé en dur | **Économie calculée en direct** sur les prix courants. |
| Rupture de marque | Sélection qui grise les ruptures, override assumé. |

---

## 5. Découpage recommandé

- **Phase 1 — la primitive « lot »** (petit, à haute valeur, sans catalogue) :
  3 champs sur `lignes_vente` (migration Alembic + Drift), l'algorithme de
  répartition, la sélection multiple + prix de groupe en caisse, le regroupement
  ticket/rapport. **Couvre déjà le besoin du maquis** (le patron connaît son
  deal et le pose à la volée).
- **Phase 2 — kits nommés** : table `kits` + pull catalogue + tuiles/feuille de
  composition pré-remplie. À faire quand des kits **récurrents** émergent.
- **Phase 3 — compositions fermées & quotas fins** : `kit_composants` + solveur,
  seulement sur demande terrain avérée.

**Recommandation : livrer la phase 1 seule d'abord.** C'est 20 % de l'effort de
la v1 pour l'essentiel de la valeur, sans dette de conception, et chaque phase
suivante est purement additive. (Hors périmètre v1.1 des corrections bêta.)
