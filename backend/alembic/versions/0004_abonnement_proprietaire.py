"""abonnement par proprietaire (multi-boutique)

Revision ID: 0004
Revises: 0003
Create Date: 2026-07-04

"""
from alembic import op
import sqlalchemy as sa

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.drop_index("ix_abonnements_boutique_id", "abonnements")
    op.drop_table("abonnements")

    op.create_table(
        "abonnements",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("proprietaire_id", sa.String(255), nullable=False, unique=True),
        sa.Column("plan", sa.String(20), nullable=False, server_default="FREE"),
        sa.Column(
            "prix_base",
            sa.Numeric(12, 2),
            nullable=False,
            server_default="5000.00",
        ),
        sa.Column(
            "quota_ventes_par_boutique",
            sa.Integer,
            nullable=False,
            server_default="20",
        ),
        sa.Column(
            "date_debut",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column("date_fin", sa.DateTime(timezone=True), nullable=True),
        sa.Column("actif", sa.Boolean, nullable=False, server_default="true"),
    )
    op.create_index(
        "ix_abonnements_proprietaire_id", "abonnements", ["proprietaire_id"]
    )


def downgrade() -> None:
    op.drop_index("ix_abonnements_proprietaire_id", "abonnements")
    op.drop_table("abonnements")

    op.create_table(
        "abonnements",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "boutique_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("boutiques.id"),
            nullable=False,
            unique=True,
        ),
        sa.Column("plan", sa.String(20), nullable=False, server_default="FREE"),
        sa.Column(
            "quota_ventes_mois", sa.Integer, nullable=False, server_default="20"
        ),
        sa.Column(
            "date_debut",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column("date_fin", sa.DateTime(timezone=True), nullable=True),
        sa.Column("actif", sa.Boolean, nullable=False, server_default="true"),
    )
    op.create_index("ix_abonnements_boutique_id", "abonnements", ["boutique_id"])
