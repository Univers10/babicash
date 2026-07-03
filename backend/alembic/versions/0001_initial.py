"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-06-22

"""
from typing import Sequence, Union

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "0001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "boutiques",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("nom", sa.String(length=255), nullable=False),
        sa.Column("proprietaire_id", sa.String(length=255), nullable=False),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("nom", sa.String(length=255), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("mot_de_passe_hash", sa.String(length=255), nullable=False),
        sa.Column("role", sa.String(length=20), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("actif", sa.Boolean(), nullable=False),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    op.create_table(
        "categories",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("nom", sa.String(length=100), nullable=False),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "produits",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("categorie_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("nom", sa.String(length=255), nullable=False),
        sa.Column("prix_achat_moyen", sa.Numeric(12, 2), nullable=False),
        sa.Column("prix_vente_suggere", sa.Numeric(12, 2), nullable=False),
        sa.Column("stock_actuel", sa.Integer(), nullable=False),
        sa.Column("stock_alerte", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.ForeignKeyConstraint(["categorie_id"], ["categories.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "comptes_tiers",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("nom", sa.String(length=255), nullable=False),
        sa.Column("telephone", sa.String(length=50), nullable=True),
        sa.Column("type_tiers", sa.String(length=20), nullable=False),
        sa.Column("solde_du", sa.Numeric(12, 2), nullable=False),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "sessions_caisse",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("utilisateur_nom", sa.String(length=255), nullable=False),
        sa.Column(
            "date_ouverture",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("date_fermeture", sa.DateTime(timezone=True), nullable=True),
        sa.Column("montant_initial", sa.Numeric(12, 2), nullable=False),
        sa.Column("montant_final_declare", sa.Numeric(12, 2), nullable=True),
        sa.Column("statut", sa.String(length=20), nullable=True),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "ventes",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("tier_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column(
            "date_vente",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("montant_total", sa.Numeric(12, 2), nullable=False),
        sa.Column("mode_paiement", sa.String(length=50), nullable=False),
        sa.Column("id_local_smartphone", sa.String(length=255), nullable=True),
        sa.Column("signale_proprietaire", sa.Boolean(), nullable=False),
        sa.Column("synced", sa.Boolean(), nullable=False),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.ForeignKeyConstraint(["session_id"], ["sessions_caisse.id"]),
        sa.ForeignKeyConstraint(["tier_id"], ["comptes_tiers.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("id_local_smartphone"),
    )

    op.create_table(
        "lignes_vente",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("vente_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("produit_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("quantite", sa.Integer(), nullable=False),
        sa.Column("prix_vendu_reel", sa.Numeric(12, 2), nullable=False),
        sa.Column("marge_calculee", sa.Numeric(12, 2), nullable=False),
        sa.Column("vente_a_perte", sa.Boolean(), nullable=False),
        sa.ForeignKeyConstraint(["vente_id"], ["ventes.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["produit_id"], ["produits.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "transactions_caisse",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("boutique_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("type_transaction", sa.String(length=20), nullable=False),
        sa.Column("montant", sa.Numeric(12, 2), nullable=False),
        sa.Column("motif", sa.String(length=255), nullable=False),
        sa.Column("id_local_smartphone", sa.String(length=255), nullable=True),
        sa.Column(
            "date_transaction",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("synced", sa.Boolean(), nullable=False),
        sa.ForeignKeyConstraint(["boutique_id"], ["boutiques.id"]),
        sa.ForeignKeyConstraint(["session_id"], ["sessions_caisse.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("id_local_smartphone"),
    )


def downgrade() -> None:
    op.drop_table("transactions_caisse")
    op.drop_table("lignes_vente")
    op.drop_table("ventes")
    op.drop_table("sessions_caisse")
    op.drop_table("comptes_tiers")
    op.drop_table("produits")
    op.drop_table("categories")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")
    op.drop_table("boutiques")
