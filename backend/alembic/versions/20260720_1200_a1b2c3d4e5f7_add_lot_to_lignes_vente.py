"""add_lot_to_lignes_vente

Colonnes de lot (prix de groupe) sur lignes_vente. Strictement additif et
nullable : les lignes existantes gardent lot_id/lot_nom = NULL et restent des
ventes normales. Aucune réécriture de table, aucune donnée touchée.

Revision ID: a1b2c3d4e5f7
Revises: f7a8b9c0d1e2
Create Date: 2026-07-20 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f7'
down_revision: Union[str, None] = 'f7a8b9c0d1e2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('lignes_vente', sa.Column('lot_id', sa.Uuid(), nullable=True))
    op.add_column(
        'lignes_vente', sa.Column('lot_nom', sa.String(length=120), nullable=True)
    )


def downgrade() -> None:
    op.drop_column('lignes_vente', 'lot_nom')
    op.drop_column('lignes_vente', 'lot_id')
