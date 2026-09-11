"""add boutique shop (produits + commandes)

Ajoute les tables ``shop_produits``, ``commandes_shop`` et
``commandes_shop_lignes`` pour la boutique « Matériel & accessoires », puis
insère le catalogue initial (les 7 produits déjà visibles dans l'app).

Cette migration fait également office de merge : l'historique Alembic possédait
deux têtes (``d5e6f7a8b9c2`` et ``e7f8g9h0i1j2``) ; elle les fusionne en une
seule branche.

Revision ID: f6a7b8c9d0e1
Revises: d5e6f7a8b9c2, e7f8g9h0i1j2
Create Date: 2026-09-08 09:00:00.000000

"""
import uuid
from decimal import Decimal

from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "f6a7b8c9d0e1"
down_revision: Union[str, Sequence[str], None] = ("d5e6f7a8b9c2", "e7f8g9h0i1j2")
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _seed() -> list[dict]:
    def _uid(suffix: str) -> uuid.UUID:
        return uuid.UUID(f"b1b2c3d4-0000-4000-8000-{suffix:012d}")

    return [
        {
            "id": _uid(1),
            "nom": "Imprimante thermique 58 mm",
            "description": (
                "Connexion Bluetooth, batterie longue autonomie, idéale pour "
                "les reçus en boutique."
            ),
            "tagline": "Bluetooth · Batterie",
            "prix": Decimal("25000.00"),
            "ancien_prix": Decimal("30000.00"),
            "categorie": "IMPRIMANTES",
            "icone": "print",
            "specs": ["Bluetooth", "58 mm", "Batterie incluse", "Impression rapide"],
            "stock": 12,
            "stock_alerte": 5,
            "en_vente": True,
            "is_new": False,
            "is_populaire": True,
            "position": 10,
        },
        {
            "id": _uid(2),
            "nom": "Imprimante thermique 80 mm",
            "description": (
                "Plus rapide et plus silencieuse, pensée pour les points de "
                "vente à fort volume."
            ),
            "tagline": "Débit rapide · Silencieuse",
            "prix": Decimal("45000.00"),
            "ancien_prix": None,
            "categorie": "IMPRIMANTES",
            "icone": "print",
            "specs": ["USB + Bluetooth", "80 mm", "Silencieuse", "Haute vitesse"],
            "stock": 8,
            "stock_alerte": 3,
            "en_vente": True,
            "is_new": True,
            "is_populaire": False,
            "position": 20,
        },
        {
            "id": _uid(3),
            "nom": "Rouleaux 58 mm x 10",
            "description": "Papier thermique de qualité supérieure, 10 rouleaux de 14 m.",
            "tagline": "Qualité supérieure · 14 m",
            "prix": Decimal("2500.00"),
            "ancien_prix": Decimal("3000.00"),
            "categorie": "ROULEAUX",
            "icone": "receipt",
            "specs": ["10 rouleaux", "14 m", "Papier thermique"],
            "stock": 50,
            "stock_alerte": 10,
            "en_vente": True,
            "is_new": False,
            "is_populaire": True,
            "position": 30,
        },
        {
            "id": _uid(4),
            "nom": "Rouleaux 80 mm x 10",
            "description": "Papier thermique 80 mm haute densité, 10 rouleaux de 25 m.",
            "tagline": "Haute densité · 25 m",
            "prix": Decimal("4000.00"),
            "ancien_prix": Decimal("5000.00"),
            "categorie": "ROULEAUX",
            "icone": "receipt",
            "specs": ["10 rouleaux", "25 m", "Haute densité"],
            "stock": 40,
            "stock_alerte": 10,
            "en_vente": True,
            "is_new": False,
            "is_populaire": False,
            "position": 40,
        },
        {
            "id": _uid(5),
            "nom": "Support tablette / smartphone",
            "description": (
                "Support antivol orientable pour caisse mobile, fixe ou de "
                "comptoir."
            ),
            "tagline": "Antivol · Orientable",
            "prix": Decimal("12000.00"),
            "ancien_prix": None,
            "categorie": "ACCESSOIRES",
            "icone": "tablet_mac",
            "specs": ["Antivol", "Rotation 360°", "Compatible tablette & téléphone"],
            "stock": 15,
            "stock_alerte": 5,
            "en_vente": True,
            "is_new": True,
            "is_populaire": False,
            "position": 50,
        },
        {
            "id": _uid(6),
            "nom": "Lecteur code-barres Bluetooth",
            "description": (
                "Scan rapide des produits en boutique et réduction des erreurs "
                "de saisie."
            ),
            "tagline": "Scan rapide · Sans fil",
            "prix": Decimal("18000.00"),
            "ancien_prix": None,
            "categorie": "ACCESSOIRES",
            "icone": "barcode_scanner",
            "specs": ["Bluetooth", "Scan rapide", "Batterie longue durée"],
            "stock": 10,
            "stock_alerte": 4,
            "en_vente": True,
            "is_new": False,
            "is_populaire": True,
            "position": 60,
        },
        {
            "id": _uid(7),
            "nom": "Tiroir-caisse connecté",
            "description": (
                "S'ouvre automatiquement à l'impression du reçu. Compatible "
                "avec tous les modèles BabiCash."
            ),
            "tagline": "Ouverture auto à chaque reçu",
            "prix": Decimal("22000.00"),
            "ancien_prix": Decimal("25000.00"),
            "categorie": "ACCESSOIRES",
            "icone": "payments",
            "specs": ["Ouverture auto", "Compatible 58 / 80 mm"],
            "stock": 6,
            "stock_alerte": 3,
            "en_vente": True,
            "is_new": False,
            "is_populaire": False,
            "position": 70,
        },
    ]


def upgrade() -> None:
    op.create_table(
        "shop_produits",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("nom", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=False, server_default=""),
        sa.Column("tagline", sa.String(length=255), nullable=False, server_default=""),
        sa.Column("prix", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("ancien_prix", sa.Numeric(12, 2), nullable=True),
        sa.Column("categorie", sa.String(length=20), nullable=False, server_default="ACCESSOIRES"),
        sa.Column("icone", sa.String(length=50), nullable=False, server_default="print"),
        sa.Column("specs", sa.JSON(), nullable=False, server_default=sa.text("'[]'")),
        sa.Column("stock", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("stock_alerte", sa.Integer(), nullable=False, server_default="5"),
        sa.Column("en_vente", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("is_new", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("is_populaire", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("position", sa.Integer(), nullable=False, server_default="0"),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "date_modification",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "commandes_shop",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("client_nom", sa.String(length=255), nullable=False),
        sa.Column("client_telephone", sa.String(length=30), nullable=True),
        sa.Column("client_adresse", sa.String(length=255), nullable=True),
        sa.Column("statut", sa.String(length=20), nullable=False, server_default="NOUVELLE"),
        sa.Column("source", sa.String(length=20), nullable=False, server_default="APP"),
        sa.Column("total", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("notes", sa.String(length=2000), nullable=True),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "date_modification",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_commandes_shop_statut", "commandes_shop", ["statut"])
    op.create_index(
        "ix_commandes_shop_date_creation", "commandes_shop", ["date_creation"]
    )

    op.create_table(
        "commandes_shop_lignes",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("commande_id", sa.Uuid(), nullable=False),
        sa.Column("produit_id", sa.Uuid(), nullable=True),
        sa.Column("nom", sa.String(length=255), nullable=False),
        sa.Column("prix_unitaire", sa.Numeric(12, 2), nullable=False),
        sa.Column("quantite", sa.Integer(), nullable=False, server_default="1"),
        sa.ForeignKeyConstraint(["commande_id"], ["commandes_shop.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["produit_id"], ["shop_produits.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_commandes_shop_lignes_commande_id",
        "commandes_shop_lignes",
        ["commande_id"],
    )

    shop_produits = sa.table(
        "shop_produits",
        sa.column("id", sa.Uuid()),
        sa.column("nom", sa.String(255)),
        sa.column("description", sa.Text()),
        sa.column("tagline", sa.String(255)),
        sa.column("prix", sa.Numeric(12, 2)),
        sa.column("ancien_prix", sa.Numeric(12, 2)),
        sa.column("categorie", sa.String(20)),
        sa.column("icone", sa.String(50)),
        sa.column("specs", sa.JSON()),
        sa.column("stock", sa.Integer()),
        sa.column("stock_alerte", sa.Integer()),
        sa.column("en_vente", sa.Boolean()),
        sa.column("is_new", sa.Boolean()),
        sa.column("is_populaire", sa.Boolean()),
        sa.column("position", sa.Integer()),
    )
    op.bulk_insert(shop_produits, _seed())


def downgrade() -> None:
    op.drop_table("commandes_shop_lignes")
    op.drop_table("commandes_shop")
    op.drop_table("shop_produits")