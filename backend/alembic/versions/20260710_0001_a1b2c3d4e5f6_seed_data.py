"""seed data: owner, boutique, manager, 8 categories, 50 products

Revision ID: a1b2c3d4e5f6
Revises: d36b710d125f
Create Date: 2026-07-10 00:01:00.000000

"""
import uuid
from typing import Sequence, Union

import bcrypt
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "a1b2c3d4e5f6"
down_revision: Union[str, None] = "d36b710d125f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_BCRYPT_ROUNDS = 12

OWNER_ID = uuid.UUID("00000000-0000-0000-0000-000000000001")
BOUTIQUE_ID = uuid.UUID("00000000-0000-0000-0000-000000000002")
MANAGER_ID = uuid.UUID("00000000-0000-0000-0000-000000000003")

CATEGORIES_PRODUITS = {
    "Boissons": [
        ("Eau minérale 1.5L", 200, 300, 120),
        ("Eau minérale 0.5L", 100, 150, 200),
        ("Coca-Cola 33cl", 250, 400, 80),
        ("Fanta Orange 33cl", 250, 400, 75),
        ("Sprite 33cl", 250, 400, 60),
        ("Jus de bissap 1L", 500, 800, 30),
        ("Bière Flag 65cl", 600, 900, 50),
    ],
    "Hygiène & Beauté": [
        ("Savon de Marseille", 300, 500, 100),
        ("Dentifrice Colgate 100ml", 500, 800, 60),
        ("Éponge de bain", 100, 200, 150),
        ("Déodorant spray 150ml", 800, 1200, 40),
        ("Crème nivea 100ml", 700, 1100, 35),
        ("Shampooing sachet", 50, 100, 300),
        ("Papier hygiénique x4", 600, 900, 80),
    ],
    "Alimentaire": [
        ("Riz parfumé 1kg", 700, 1000, 90),
        ("Huile de palme 1L", 800, 1200, 50),
        ("Sucre en morceaux 1kg", 600, 900, 70),
        ("Sel iodé 1kg", 200, 350, 100),
        ("Pâtes spaghetti 500g", 400, 600, 60),
        ("Lait concentré 400g", 500, 750, 55),
        ("Tomate concentrée 400g", 350, 550, 65),
    ],
    "Biscuits & Snacks": [
        ("Biscuit Sablé x10", 200, 350, 120),
        ("Chips Pringles 40g", 300, 500, 80),
        ("Bonbons menthe sachet", 50, 100, 250),
        ("Chewing-gum x5", 50, 100, 300),
        ("Chocolat tablette 100g", 500, 800, 40),
        ("Cacahuètes grillées 200g", 300, 500, 60),
    ],
    "Petit-déjeuner": [
        ("Café Nescafé sachet", 50, 100, 400),
        ("Thé Lipton sachet", 25, 50, 500),
        ("Lait en poudre 400g", 1500, 2200, 30),
        ("Cacao en poudre 200g", 800, 1200, 25),
        ("Pain de mie tranché", 500, 750, 40),
        ("Confiture fraise 250g", 700, 1100, 20),
    ],
    "Électronique & Téléphonie": [
        ("Chargeur USB universel", 1000, 1500, 30),
        ("Écouteurs filaires", 500, 1000, 50),
        ("Carte mémoire 16Go", 2000, 3500, 20),
        ("Coque téléphone", 300, 700, 60),
        ("Lampe torche LED", 800, 1500, 25),
        ("Pile AA x2", 200, 400, 100),
    ],
    "Papeterie": [
        ("Cahier 200 pages", 400, 700, 80),
        ("Stylo BIC bleu", 50, 100, 300),
        ("Crayon à papier HB", 25, 50, 400),
        ("Gomme blanche", 50, 100, 200),
        ("Règle 30cm", 100, 200, 100),
        ("Colle en bâton", 150, 300, 80),
    ],
    "Ménage & Entretien": [
        ("Javel 1L", 300, 500, 60),
        ("Éponge vaisselle x3", 150, 300, 100),
        ("Détergent poudre 500g", 500, 800, 50),
        ("Sac poubelle x10", 200, 400, 80),
        ("Balai plastique", 1000, 1800, 20),
        ("Insecticide spray", 1200, 2000, 25),
    ],
}


def _hash(value: str) -> str:
    return bcrypt.hashpw(value.encode(), bcrypt.gensalt(_BCRYPT_ROUNDS)).decode()


def upgrade() -> None:
    conn = op.get_bind()
    existing_owner = conn.execute(
        sa.text("SELECT 1 FROM users WHERE id = :id"), {"id": OWNER_ID}
    ).scalar()
    if existing_owner:
        return

    # --- Owner ---
    conn.execute(
        sa.text(
            "INSERT INTO users (id, nom, email, mot_de_passe_hash, telephone, code_pin_hash, role, actif)"
            " VALUES (:id, :nom, :email, :mdp, :tel, :pin, :role, true)"
        ),
        {
            "id": OWNER_ID,
            "nom": "Le Boss",
            "email": "boss@babicash.ci",
            "mdp": _hash("boss1234"),
            "tel": "0700000000",
            "pin": _hash("1234"),
            "role": "OWNER",
        },
    )

    # --- Boutique ---
    conn.execute(
        sa.text(
            "INSERT INTO boutiques (id, nom, proprietaire_id)"
            " VALUES (:id, :nom, :prop_id)"
        ),
        {"id": BOUTIQUE_ID, "nom": "Boutique Adjamé", "prop_id": str(OWNER_ID)},
    )

    # --- Manager ---
    conn.execute(
        sa.text(
            "INSERT INTO users (id, nom, telephone, code_pin_hash, role, boutique_id, actif)"
            " VALUES (:id, :nom, :tel, :pin, :role, :boutique_id, true)"
        ),
        {
            "id": MANAGER_ID,
            "nom": "Gérant Adjamé",
            "tel": "0700000001",
            "pin": _hash("4321"),
            "role": "MANAGER",
            "boutique_id": BOUTIQUE_ID,
        },
    )

    # --- Catégories & Produits ---
    cat_counter = 1
    prod_counter = 1
    for cat_nom, produits in CATEGORIES_PRODUITS.items():
        cat_id = uuid.UUID(f"00000000-0000-0000-0000-{cat_counter:012d}")
        conn.execute(
            sa.text(
                "INSERT INTO categories (id, boutique_id, nom)"
                " VALUES (:id, :boutique_id, :nom)"
            ),
            {"id": cat_id, "boutique_id": BOUTIQUE_ID, "nom": cat_nom},
        )

        for nom, achat, vente, stock in produits:
            prod_id = uuid.UUID(f"00000000-0000-0000-0001-{prod_counter:012d}")
            conn.execute(
                sa.text(
                    "INSERT INTO produits"
                    " (id, boutique_id, categorie_id, nom, prix_achat_moyen, prix_vente_suggere, stock_actuel, stock_alerte)"
                    " VALUES (:id, :boutique_id, :categorie_id, :nom, :achat, :vente, :stock, 5)"
                ),
                {
                    "id": prod_id,
                    "boutique_id": BOUTIQUE_ID,
                    "categorie_id": cat_id,
                    "nom": nom,
                    "achat": str(achat) + ".00",
                    "vente": str(vente) + ".00",
                    "stock": stock,
                },
            )
            prod_counter += 1
        cat_counter += 1

    # --- Abonnement FREE pour le owner ---
    conn.execute(
        sa.text(
            "INSERT INTO abonnements (id, proprietaire_id, plan, prix_base, quota_ventes_par_boutique, actif)"
            " VALUES (:id, :prop_id, 'FREE', 5000.00, 20, true)"
        ),
        {"id": uuid.uuid4(), "prop_id": str(OWNER_ID)},
    )


def downgrade() -> None:
    conn = op.get_bind()
    conn.execute(
        sa.text("DELETE FROM abonnements WHERE proprietaire_id = :prop_id"),
        {"prop_id": str(OWNER_ID)},
    )
    conn.execute(
        sa.text("DELETE FROM produits WHERE boutique_id = :bid"),
        {"bid": BOUTIQUE_ID},
    )
    conn.execute(
        sa.text("DELETE FROM categories WHERE boutique_id = :bid"),
        {"bid": BOUTIQUE_ID},
    )
    conn.execute(
        sa.text("DELETE FROM users WHERE id IN (:manager_id, :owner_id)"),
        {"manager_id": MANAGER_ID, "owner_id": OWNER_ID},
    )
    conn.execute(
        sa.text("DELETE FROM boutiques WHERE id = :bid"),
        {"bid": BOUTIQUE_ID},
    )
