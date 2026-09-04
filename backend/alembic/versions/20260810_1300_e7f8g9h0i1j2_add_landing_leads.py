"""add landing_leads

Ajoute la table ``landing_leads`` pour stocker les demandes de contact
provenant du formulaire de la landing page.

Revision ID: e7f8g9h0i1j2
Revises: d5e6f7a8b9c2
Create Date: 2026-08-10 13:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "e7f8g9h0i1j2"
down_revision: Union[str, Sequence[str], None] = "d5e6f7a8b9c2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "landing_leads",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("nom", sa.String(length=255), nullable=True),
        sa.Column("contact", sa.String(length=255), nullable=True),
        sa.Column("message", sa.String(length=2000), nullable=True),
        sa.Column(
            "traite", sa.Boolean(), nullable=False, server_default=sa.text("false")
        ),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("landing_leads")
