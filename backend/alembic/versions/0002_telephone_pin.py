"""auth simplifiée: telephone + code PIN, email/mot de passe nullable

Revision ID: 0002_telephone_pin
Revises: 0001_initial
Create Date: 2026-06-22

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

revision: str = "0002_telephone_pin"
down_revision: Union[str, None] = "0001_initial"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "users", sa.Column("telephone", sa.String(length=30), nullable=True)
    )
    op.add_column(
        "users", sa.Column("code_pin_hash", sa.String(length=255), nullable=True)
    )
    op.create_index(
        "ix_users_telephone", "users", ["telephone"], unique=True
    )
    # Email et mot de passe deviennent optionnels
    op.alter_column("users", "email", existing_type=sa.String(255), nullable=True)
    op.alter_column(
        "users", "mot_de_passe_hash", existing_type=sa.String(255), nullable=True
    )


def downgrade() -> None:
    op.alter_column(
        "users", "mot_de_passe_hash", existing_type=sa.String(255), nullable=False
    )
    op.alter_column("users", "email", existing_type=sa.String(255), nullable=False)
    op.drop_index("ix_users_telephone", table_name="users")
    op.drop_column("users", "code_pin_hash")
    op.drop_column("users", "telephone")
