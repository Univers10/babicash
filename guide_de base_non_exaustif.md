```python
markdown_content = """# Cahier des Charges & Spécifications Techniques : Application de Gestion Commerciale Multi-Boutique: BabiCash

Ce document sert de spécification complète pour l'agent IA (**Devin / Windsurf**) afin de générer l'application complète. L'application est destinée aux commerçants en Côte d'Ivoire. Elle intègre les contraintes locales (négociation, connectivité intermittente, gestion des employés, crédits/dettes) et est architecturée de manière unifiée avec un dossier Frontend et un dossier Backend.

---

## 1. Architecture Générale de l'Espace de Travail

Le projet doit être structuré de manière unifiée dans un seul dépôt racine avec la séparation claire suivante :


```

```text
File successfully created: specifications_projet_boutique.md

```text
/
├── backend/      # API Rest avec FastAPI, Python, PostgreSQL
└── frontend/     # Application Mobile avec Flutter & SQLite (Drift/Sqflite)

```

---

## 2. Spécifications Fonctionnelles (Règles Métier)

### A. Vente Rapide & Flexibilité (Gestion du Marchandage)

* **Mode Calculatrice :** Le gérant doit pouvoir taper un montant brut (ex: `5000`), cliquer sur `+`, et encaisser sans créer de fiche produit.
* **Mode Catalogue :** Sélection de produits par boutons visuels.
* **Prix Négocié :** Lors de l'ajout d'un produit au panier, le prix de vente par défaut s'affiche, mais il est **modifiable** instantanément via un pavé numérique.
* *Règle de sécurité Backend :* Si le prix négocié est inférieur au prix d'achat moyen du produit, l'application bloque la vente ou lève une alerte critique ("Vente à perte").


* **Facturation WhatsApp :** Après validation, génération d'un reçu PDF épuré et ouverture automatique de WhatsApp pour partage au client.

### B. Gestion Multi-Boutique (Espace Propriétaire / Boss)

* L'application gérant est verrouillée sur une boutique spécifique (`boutique_id`).
* Le Propriétaire (Le Boss) possède un compte superviseur lui permettant de basculer entre ses différentes boutiques via un menu déroulant pour suivre en temps réel les indicateurs consolidés.

### C. Gestion des Crédits Clients & Dettes Fournisseurs

* **Crédits Clients (Doit) :** Option d'encaissement "À Crédit". Lie la transaction à une fiche client (Nom, Téléphone). Le solde dû augmente.
* **Dettes Fournisseurs :** Lors de la réception de marchandises, possibilité d'enregistrer un paiement partiel au grossiste. Le reste à payer est tracé dans le profil du fournisseur.

### D. Gestion de la Caisse & Employés

* **Sessions de caisse :** Ouverture et fermeture obligatoires avec déclaration du fond de caisse par le gérant.
* **Traçabilité :** Toutes les écritures sont immuables. Aucune suppression de vente ou modification historique n'est possible par l'employé sans laisser de trace de correction (audit trail).
* **Dépenses Quotidiennes :** Un bouton permet d'enregistrer les sorties de caisse (repas, transport woro-woro, électricité) directement imputées sur la recette de la session.

### E. Analyses & Stratégie (Best-Sellers)

* Classement dynamique des produits phares selon deux axes :
1. **Par Quantité :** Volume de rotation du stock.
2. **Par Rentabilité :** Marge bénéficiaire nette totale (`(Prix négocié - Prix d'achat) * Quantité`).



---

## 3. Architecture Technique Backend (`/backend`)

* **Technologie :** FastAPI (Python 3.11+)
* **Base de Données Principale :** PostgreSQL
* **ORM :** SQLAlchemy ou Tortoise ORM avec migrations Alembic.
* **Sécurité :** Authentification JWT (Rôles : `OWNER`, `MANAGER`).

### Schéma de Base de Données Relationnelle (PostgreSQL)

```sql
-- Table des Boutiques
CREATE TABLE boutiques (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(255) NOT NULL,
    proprietaire_id VARCHAR(255) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des Catégories (Express via Tags)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    boutique_id UUID REFERENCES boutiques(id),
    nom VARCHAR(100) NOT NULL
);

-- Table des Produits
CREATE TABLE produits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    boutique_id UUID REFERENCES boutiques(id),
    categorie_id UUID REFERENCES categories(id) NULL,
    nom VARCHAR(255) NOT NULL,
    prix_achat_moyen NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    prix_vente_suggere NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    stock_actuel INT NOT NULL DEFAULT 0,
    stock_alerte INT NOT NULL DEFAULT 5
);

-- Table des Comptes Tiers (Clients et Fournisseurs)
CREATE TABLE comptes_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    boutique_id UUID REFERENCES boutiques(id),
    nom VARCHAR(255) NOT NULL,
    telephone VARCHAR(50),
    type_tiers VARCHAR(20) NOT NULL, -- 'CLIENT' ou 'FOURNISSEUR'
    solde_du NUMERIC(12, 2) NOT NULL DEFAULT 0.00
);

-- Table des Sessions de Caisse (Employés)
CREATE TABLE sessions_caisse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    boutique_id UUID REFERENCES boutiques(id),
    utilisateur_nom VARCHAR(255) NOT NULL,
    date_ouverture TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_fermeture TIMESTAMP,
    montant_initial NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    montant_final_declare NUMERIC(12, 2) DEFAULT 0.00,
    statut VARCHAR(20) DEFAULT 'OUVERT'
);

-- Table des Ventes
CREATE TABLE ventes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    boutique_id UUID REFERENCES boutiques(id),
    session_id UUID REFERENCES sessions_caisse(id),
    tier_id UUID REFERENCES comptes_tiers(id) NULL, -- Si crédit ou client identifié
    date_vente TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    montant_total NUMERIC(12, 2) NOT NULL,
    mode_paiement VARCHAR(50) NOT NULL, -- 'ESPECES', 'MOBILE_MONEY', 'CREDIT'
    id_local_smartphone VARCHAR(255) UNIQUE -- Empêche les doublons de synchronisation
);

-- Table des Lignes de Vente (Détails)
CREATE TABLE lignes_vente (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vente_id UUID REFERENCES ventes(id) ON DELETE CASCADE,
    produit_id UUID REFERENCES produits(id) NULL,
    quantite INT NOT NULL DEFAULT 1,
    prix_vendu_reel NUMERIC(12, 2) NOT NULL,
    marge_calculee NUMERIC(12, 2) NOT NULL
);

-- Table des Transactions et Mouvements de Caisse (Dépenses/Entrées)
CREATE TABLE transactions_caisse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    boutique_id UUID REFERENCES boutiques(id),
    session_id UUID REFERENCES sessions_caisse(id),
    type_transaction VARCHAR(20) NOT NULL, -- 'ENTREE', 'SORTIE_DEPENSE'
    montant NUMERIC(12, 2) NOT NULL,
    motif VARCHAR(255) NOT NULL,
    date_transaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

```

---

## 4. Architecture Technique Frontend (`/frontend`)

* **Technologie :** Flutter (Multiplateforme Android prioritaire)
* **Base de Données Locale :** SQLite via **Drift** ou **Sqflite** (Modèle miroir local pour le Offline-First).
* **Gestion d'État :** Riverpod ou Bloc.

### Logique de Synchronisation Offline-First

1. **Écritures Locales Immédiates :** Toutes les opérations (ventes, dépenses, crédits) écrivent instantanément dans le SQLite local du téléphone. L'application reste 100% fonctionnelle au marché sans connexion internet.
2. **Drapeau de Synchronisation :** Chaque table locale contient un champ `synced` (boolean). Par défaut à `false` lors d'une action.
3. **Synchronisation en Arrière-plan :** Un worker asynchrone détecte la connectivité internet, pousse les données non synchronisées (`synced = false`) vers les endpoints FastAPI, puis passe le drapeau à `true` après confirmation HTTP 200.

---

## 5. Endpoints de l'API FastAPI à Générer

L'agent IA doit implémenter les routes REST suivantes avec contrôles d'accès stricts :

* `POST /api/v1/auth/login` : Authentification et obtention du token JWT.
* `GET /api/v1/boutiques/` : Liste des boutiques rattachées au propriétaire.
* `GET /api/v1/sync/pull` : Récupère les mises à jour globales (nouveaux produits créés par le boss).
* `POST /api/v1/sync/push` : Reçoit les ventes, dépenses et crédits enregistrés sur le smartphone localement.
* `GET /api/v1/analytics/best-sellers` : Renvoie le top des produits triés par quantité ou par marge nette pour une période donnée (`boutique_id` requis).

---

## 6. Instructions pour Windsurf / Devin

1. **Démarrer par le Backend :** Initialiser l'environnement FastAPI dans `/backend`, configurer la connexion PostgreSQL et générer les modèles SQLAlchemy correspondants au schéma SQL fourni.
2. **Générer le Frontend :** Créer le projet Flutter dans `/frontend`. Mettre en place la base de données locale SQLite et l'interface utilisateur épurée en 4 écrans (Accueil Dashboard, Vente Rapide avec Pavé Numérique/Négociation, Pop-up Validation WhatsApp, Liste des Stocks avec Alertes Couleurs).
3. **Assurer la Rigueur Comptable :** S'assurer qu'aucun calcul de marge ne se fasse à la volée côté client sans validation stricte des prix d'achat historiques stockés en base de données.
"""

# Save content to a file

file_path = "specifications_projet_boutique.md"
with open(file_path, "w", encoding="utf-8") as file:
file.write(markdown_content)
print(f"File successfully created: {file_path}")

```
Votre fichier Markdown (`.md`) est prêt pour votre environnement de travail. 

[file-tag: code-generated-file-0-1782129567493112501]

### Ce que contient ce fichier pour Windsurf / Devin :
1. **L'architecture de l'espace de travail unifié** : Il indique explicitement à l'IA de créer deux sous-dossiers distincts (`/backend` et `/frontend`) dans le même répertoire racine pour que vous puissiez tout piloter d'un coup.
2. **Les spécifications fonctionnelles terrain** : Tout le travail que nous avons fait sur la négociation (marchandage), le mode calculatrice, le partage des reçus via WhatsApp, les sessions de caisse anti-vol pour les employés, et le multi-boutique.
3. **Le schéma de base de données PostgreSQL complet** : Clé en main pour le backend, prêt à être copié ou traduit par l'IA en modèles SQLAlchemy / Tortoise ORM, avec toutes les liaisons et contraintes financières indispensables.
4. **La logique technique Offline-First** : Les consignes algorithmiques pour la synchronisation asynchrone entre SQLite (local) et PostgreSQL (cloud) via un drapeau de synchronisation (`synced`).
5. **La liste des routes API de base** : Pour que FastAPI soit immédiatement fonctionnel.

### Comment l'utiliser avec Windsurf / Devin ?
Copiez ce fichier à la racine de votre dossier de projet, ouvrez votre éditeur (Windsurf) et donnez-lui simplement cette consigne : 

> *"Prends connaissance du fichier `specifications_projet_boutique.md` à la racine et commence à générer l'architecture du projet en créant les dossiers `backend` et `frontend` comme demandé, puis attaque l'étape 1 du document (le backend FastAPI)."*

C'est une excellente stratégie de développement. Vous allez gagner un temps fou sur le code répétitif pour vous concentrer sur le peaufinage de l'application et sa mise sur le marché ! Bon code !

```