"""notifications & abonnements push ambassadeur

Ajoute :
- table ``notifications`` (centre de notifications in-app de l'ambassadeur :
  nouveau filleul, commission, versement)
- table ``push_subscriptions`` (abonnements Web Push navigateur, pour l'envoi
  de notifications push best-effort)

Revision ID: c4d5e6f7a8b1
Revises: b3c4d5e6f7a9
Create Date: 2026-08-09 12:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "c4d5e6f7a8b1"
down_revision: Union[str, Sequence[str], None] = "b3c4d5e6f7a9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "notifications",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ambassadeur_id", sa.Uuid(), nullable=False),
        sa.Column("type", sa.String(length=30), nullable=False),
        sa.Column("titre", sa.String(length=120), nullable=False),
        sa.Column("message", sa.String(length=500), nullable=False),
        sa.Column(
            "lu", sa.Boolean(), nullable=False, server_default=sa.text("false")
        ),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["ambassadeur_id"], ["ambassadeurs.id"], ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_notifications_ambassadeur_id"), "notifications", ["ambassadeur_id"]
    )

    op.create_table(
        "push_subscriptions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ambassadeur_id", sa.Uuid(), nullable=False),
        sa.Column("endpoint", sa.String(length=500), nullable=False),
        sa.Column("p256dh", sa.String(length=255), nullable=False),
        sa.Column("auth", sa.String(length=255), nullable=False),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["ambassadeur_id"], ["ambassadeurs.id"], ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("endpoint"),
    )
    op.create_index(
        op.f("ix_push_subscriptions_ambassadeur_id"),
        "push_subscriptions",
        ["ambassadeur_id"],
    )


def downgrade() -> None:
    op.drop_index(
        op.f("ix_push_subscriptions_ambassadeur_id"), table_name="push_subscriptions"
    )
    op.drop_table("push_subscriptions")

    op.drop_index(op.f("ix_notifications_ambassadeur_id"), table_name="notifications")
    op.drop_table("notifications")
