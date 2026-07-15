"""add_plan_catalog_and_limits

Revision ID: c7d8e9f0a123
Revises: b3f7c9a12e04
Create Date: 2026-07-15 14:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c7d8e9f0a123'
down_revision: Union[str, None] = 'b3f7c9a12e04'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('abonnements', sa.Column('nb_boutiques_max', sa.Integer(), nullable=False, server_default='1'))
    op.add_column('abonnements', sa.Column('nb_gerants_max', sa.Integer(), nullable=False, server_default='1'))
    op.execute("UPDATE abonnements SET prix_base = 0.00 WHERE plan = 'FREE'")


def downgrade() -> None:
    op.drop_column('abonnements', 'nb_gerants_max')
    op.drop_column('abonnements', 'nb_boutiques_max')
