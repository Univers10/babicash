"""add recu_configs (personnalisation du reçu, 1:1 boutique)

Cette révision fusionne aussi les deux têtes existantes
(``a1b2c3d4e5f7`` — lot sur lignes de vente — et ``0003_images_produit_logo``
— images produit/logo) afin que ``alembic upgrade head`` retrouve une tête
unique.

Revision ID: a2b3c4d5e6f8
Revises: a1b2c3d4e5f7, 0003_images_produit_logo
Create Date: 2026-07-23 12:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "a2b3c4d5e6f8"
down_revision: Union[str, Sequence[str], None] = (
    "a1b2c3d4e5f7",
    "0003_images_produit_logo",
)
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "recu_configs",
        sa.Column("boutique_id", sa.Uuid(), nullable=False),
        sa.Column(
            "nom_boutique",
            sa.String(length=255),
            nullable=False,
            server_default="",
        ),
        sa.Column(
            "adresse", sa.String(length=255), nullable=False, server_default=""
        ),
        sa.Column(
            "telephone", sa.String(length=30), nullable=False, server_default=""
        ),
        sa.Column(
            "entete", sa.String(length=500), nullable=False, server_default=""
        ),
        sa.Column(
            "pied_message",
            sa.String(length=500),
            nullable=False,
            server_default="Merci pour votre achat !",
        ),
        sa.Column(
            "afficher_logo",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
        ),
        sa.Column(
            "afficher_vendeur",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["boutique_id"], ["boutiques.id"], ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("boutique_id"),
    )


def downgrade() -> None:
    op.drop_table("recu_configs")
