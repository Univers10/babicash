"""ambassadeurs & parrainage (comptes ambassadeurs, paiements, commissions, payouts)

Ajoute le socle du système d'ambassadeurs :
- table ``ambassadeurs`` (profil + code de parrainage choisi + coordonnées MoMo)
- table ``paiements_abonnement`` (journal des paiements confirmés)
- table ``payouts`` (lots de versement hebdomadaires)
- table ``commissions_parrainage`` (commissions dues aux ambassadeurs)
- colonne ``users.parraine_par_ambassadeur_id`` (rattachement du filleul)

Revision ID: b3c4d5e6f7a9
Revises: a2b3c4d5e6f8
Create Date: 2026-07-28 10:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision: str = "b3c4d5e6f7a9"
down_revision: Union[str, Sequence[str], None] = "a2b3c4d5e6f8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "ambassadeurs",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(length=20), nullable=False),
        sa.Column(
            "momo_numero", sa.String(length=30), nullable=False, server_default=""
        ),
        sa.Column(
            "momo_operateur", sa.String(length=20), nullable=False, server_default=""
        ),
        sa.Column(
            "actif", sa.Boolean(), nullable=False, server_default=sa.text("true")
        ),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id"),
        sa.UniqueConstraint("code"),
    )
    op.create_index(
        op.f("ix_ambassadeurs_code"), "ambassadeurs", ["code"], unique=True
    )

    op.create_table(
        "paiements_abonnement",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("proprietaire_id", sa.String(length=255), nullable=False),
        sa.Column("abonnement_id", sa.Uuid(), nullable=True),
        sa.Column("plan", sa.String(length=20), nullable=False),
        sa.Column("montant", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("periode_debut", sa.DateTime(timezone=True), nullable=True),
        sa.Column("periode_fin", sa.DateTime(timezone=True), nullable=True),
        sa.Column("confirme_par", sa.Uuid(), nullable=True),
        sa.Column(
            "date_paiement",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["abonnement_id"], ["abonnements.id"]),
        sa.ForeignKeyConstraint(
            ["confirme_par"], ["users.id"], ondelete="SET NULL"
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_paiements_abonnement_proprietaire_id"),
        "paiements_abonnement",
        ["proprietaire_id"],
    )

    op.create_table(
        "payouts",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ambassadeur_id", sa.Uuid(), nullable=False),
        sa.Column("semaine", sa.String(length=10), nullable=False),
        sa.Column(
            "montant_total",
            sa.Numeric(precision=12, scale=2),
            nullable=False,
            server_default="0.00",
        ),
        sa.Column(
            "momo_numero", sa.String(length=30), nullable=False, server_default=""
        ),
        sa.Column(
            "statut",
            sa.String(length=10),
            nullable=False,
            server_default="A_PAYER",
        ),
        sa.Column("reference_transfert", sa.String(length=100), nullable=True),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("date_execution", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["ambassadeur_id"], ["ambassadeurs.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_payouts_ambassadeur_id"), "payouts", ["ambassadeur_id"]
    )

    op.create_table(
        "commissions_parrainage",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ambassadeur_id", sa.Uuid(), nullable=False),
        sa.Column("filleul_id", sa.Uuid(), nullable=False),
        sa.Column("paiement_id", sa.Uuid(), nullable=True),
        sa.Column("montant_paye", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column(
            "taux",
            sa.Numeric(precision=4, scale=3),
            nullable=False,
            server_default="0.200",
        ),
        sa.Column(
            "montant_commission",
            sa.Numeric(precision=12, scale=2),
            nullable=False,
        ),
        sa.Column(
            "statut",
            sa.String(length=15),
            nullable=False,
            server_default="VALIDEE",
        ),
        sa.Column("payout_id", sa.Uuid(), nullable=True),
        sa.Column(
            "date_creation",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["ambassadeur_id"], ["ambassadeurs.id"]),
        sa.ForeignKeyConstraint(
            ["filleul_id"], ["users.id"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(
            ["paiement_id"], ["paiements_abonnement.id"], ondelete="SET NULL"
        ),
        sa.ForeignKeyConstraint(
            ["payout_id"], ["payouts.id"], ondelete="SET NULL"
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_commissions_parrainage_ambassadeur_id"),
        "commissions_parrainage",
        ["ambassadeur_id"],
    )

    op.add_column(
        "users",
        sa.Column("parraine_par_ambassadeur_id", sa.Uuid(), nullable=True),
    )
    op.create_foreign_key(
        "fk_users_parraine_par_ambassadeur",
        "users",
        "ambassadeurs",
        ["parraine_par_ambassadeur_id"],
        ["id"],
    )


def downgrade() -> None:
    op.drop_constraint(
        "fk_users_parraine_par_ambassadeur", "users", type_="foreignkey"
    )
    op.drop_column("users", "parraine_par_ambassadeur_id")

    op.drop_index(
        op.f("ix_commissions_parrainage_ambassadeur_id"),
        table_name="commissions_parrainage",
    )
    op.drop_table("commissions_parrainage")

    op.drop_index(op.f("ix_payouts_ambassadeur_id"), table_name="payouts")
    op.drop_table("payouts")

    op.drop_index(
        op.f("ix_paiements_abonnement_proprietaire_id"),
        table_name="paiements_abonnement",
    )
    op.drop_table("paiements_abonnement")

    op.drop_index(op.f("ix_ambassadeurs_code"), table_name="ambassadeurs")
    op.drop_table("ambassadeurs")
