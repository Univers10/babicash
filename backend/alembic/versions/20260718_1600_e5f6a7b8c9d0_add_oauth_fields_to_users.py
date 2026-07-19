"""add_oauth_fields_to_users

Revision ID: e5f6a7b8c9d0
Revises: d4e5f6a7b8c9
Create Date: 2026-07-18 16:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e5f6a7b8c9d0'
down_revision: Union[str, None] = 'd4e5f6a7b8c9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('users', sa.Column('oauth_provider', sa.String(length=20), nullable=True))
    op.add_column('users', sa.Column('oauth_id', sa.String(length=255), nullable=True))
    op.add_column('users', sa.Column('avatar_url', sa.String(length=500), nullable=True))
    op.create_unique_constraint('uq_users_oauth_provider_id', 'users', ['oauth_provider', 'oauth_id'])


def downgrade() -> None:
    op.drop_constraint('uq_users_oauth_provider_id', 'users', type_='unique')
    op.drop_column('users', 'avatar_url')
    op.drop_column('users', 'oauth_id')
    op.drop_column('users', 'oauth_provider')
