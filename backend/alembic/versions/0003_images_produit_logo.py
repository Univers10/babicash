"""images : produits.image_url + boutiques.logo_url

Revision ID: 0003_images_produit_logo
Revises: 0002_telephone_pin
Create Date: 2026-07-23

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

revision: str = "0003_images_produit_logo"
down_revision: Union[str, None] = "0002_telephone_pin"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "produits", sa.Column("image_url", sa.String(length=500), nullable=True)
    )
    op.add_column(
        "boutiques", sa.Column("logo_url", sa.String(length=500), nullable=True)
    )


def downgrade() -> None:
    op.drop_column("boutiques", "logo_url")
    op.drop_column("produits", "image_url")
