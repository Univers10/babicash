"""add_mouvements_stock

Revision ID: f7a8b9c0d1e2
Revises: e5f6a7b8c9d0
Create Date: 2026-07-19 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f7a8b9c0d1e2'
down_revision: Union[str, None] = 'e5f6a7b8c9d0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'mouvements_stock',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('boutique_id', sa.Uuid(), nullable=False),
        sa.Column('produit_id', sa.Uuid(), nullable=True),
        sa.Column('produit_nom', sa.String(length=255), nullable=False, server_default=''),
        sa.Column('type_mouvement', sa.String(length=10), nullable=False),
        sa.Column('quantite', sa.Integer(), nullable=False),
        sa.Column('motif', sa.String(length=255), nullable=False),
        sa.Column('auteur_id', sa.Uuid(), nullable=True),
        sa.Column('auteur_nom', sa.String(length=255), nullable=False, server_default=''),
        sa.Column(
            'date_mouvement',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False,
        ),
        sa.Column('id_local_smartphone', sa.String(length=255), nullable=True),
        sa.Column('synced', sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.ForeignKeyConstraint(['boutique_id'], ['boutiques.id']),
        sa.ForeignKeyConstraint(['produit_id'], ['produits.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['auteur_id'], ['users.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('id_local_smartphone'),
    )
    op.create_index(
        'ix_mouvements_stock_boutique_id', 'mouvements_stock', ['boutique_id']
    )


def downgrade() -> None:
    op.drop_index('ix_mouvements_stock_boutique_id', table_name='mouvements_stock')
    op.drop_table('mouvements_stock')
