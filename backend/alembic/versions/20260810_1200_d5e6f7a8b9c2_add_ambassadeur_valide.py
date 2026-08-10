"""validation compte ambassadeur (plafond de versement mensuel)

Ajoute la colonne ``ambassadeurs.valide`` : le compte est « non validé » tant
que l'ambassadeur n'a pas fourni son justificatif d'identité. Les versements
d'un compte non validé sont plafonnés à 200 000 FCFA par mois.

Revision ID: d5e6f7a8b9c2
Revises: c4d5e6f7a8b1
Create Date: 2026-08-10 12:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "d5e6f7a8b9c2"
down_revision: Union[str, Sequence[str], None] = "c4d5e6f7a8b1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "ambassadeurs",
        sa.Column(
            "valide", sa.Boolean(), nullable=False, server_default=sa.text("false")
        ),
    )


def downgrade() -> None:
    op.drop_column("ambassadeurs", "valide")
