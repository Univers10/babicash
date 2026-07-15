"""add_boutique_info_fields

Revision ID: b3f7c9a12e04
Revises: d36b710d125f
Create Date: 2026-07-15 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b3f7c9a12e04'
down_revision: Union[str, None] = 'd36b710d125f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('boutiques', sa.Column('adresse', sa.String(length=255), nullable=True))
    op.add_column('boutiques', sa.Column('telephone', sa.String(length=30), nullable=True))
    op.add_column('boutiques', sa.Column('type_commerce', sa.String(length=100), nullable=True))


def downgrade() -> None:
    op.drop_column('boutiques', 'type_commerce')
    op.drop_column('boutiques', 'telephone')
    op.drop_column('boutiques', 'adresse')
