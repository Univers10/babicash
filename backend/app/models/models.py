import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    UniqueConstraint,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    nom: Mapped[str] = mapped_column(String(255), nullable=False)
    # Email + mot de passe: optionnels (surtout pour le propriétaire / tableau de bord)
    email: Mapped[str | None] = mapped_column(
        String(255), unique=True, index=True, nullable=True
    )
    mot_de_passe_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)
    # Téléphone + code PIN: connexion simplifiée (surtout pour les gérants)
    telephone: Mapped[str | None] = mapped_column(
        String(30), unique=True, index=True, nullable=True
    )
    code_pin_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)
    role: Mapped[str] = mapped_column(String(20), nullable=False)  # OWNER | MANAGER
    boutique_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=True
    )
    actif: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Boutique(Base):
    __tablename__ = "boutiques"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    nom: Mapped[str] = mapped_column(String(255), nullable=False)
    proprietaire_id: Mapped[str] = mapped_column(String(255), nullable=False)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    categories: Mapped[list["Categorie"]] = relationship(
        back_populates="boutique", cascade="all, delete-orphan"
    )
    produits: Mapped[list["Produit"]] = relationship(
        back_populates="boutique", cascade="all, delete-orphan"
    )


class Categorie(Base):
    __tablename__ = "categories"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    nom: Mapped[str] = mapped_column(String(100), nullable=False)

    boutique: Mapped["Boutique"] = relationship(back_populates="categories")


class Produit(Base):
    __tablename__ = "produits"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    categorie_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("categories.id"), nullable=True
    )
    nom: Mapped[str] = mapped_column(String(255), nullable=False)
    prix_achat_moyen: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("0.00")
    )
    prix_vente_suggere: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("0.00")
    )
    stock_actuel: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    stock_alerte: Mapped[int] = mapped_column(Integer, nullable=False, default=5)

    boutique: Mapped["Boutique"] = relationship(back_populates="produits")


class CompteTiers(Base):
    __tablename__ = "comptes_tiers"
    __table_args__ = (
        UniqueConstraint("boutique_id", "telephone", name="uq_tiers_boutique_telephone"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    nom: Mapped[str] = mapped_column(String(255), nullable=False)
    telephone: Mapped[str | None] = mapped_column(String(50), nullable=True)
    type_tiers: Mapped[str] = mapped_column(
        String(20), nullable=False
    )  # CLIENT | FOURNISSEUR
    solde_du: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("0.00")
    )


class SessionCaisse(Base):
    __tablename__ = "sessions_caisse"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    utilisateur_nom: Mapped[str] = mapped_column(String(255), nullable=False)
    date_ouverture: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    date_fermeture: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    montant_initial: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("0.00")
    )
    montant_final_declare: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=Decimal("0.00")
    )
    statut: Mapped[str] = mapped_column(
        String(20), default="OUVERT"
    )  # OUVERT | FERME


class Vente(Base):
    __tablename__ = "ventes"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    session_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("sessions_caisse.id"), nullable=True
    )
    tier_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("comptes_tiers.id"), nullable=True
    )
    date_vente: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    montant_total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    mode_paiement: Mapped[str] = mapped_column(
        String(50), nullable=False
    )  # ESPECES | MOBILE_MONEY | CREDIT
    # Empêche les doublons de synchronisation (idempotence)
    id_local_smartphone: Mapped[str | None] = mapped_column(
        String(255), unique=True, nullable=True
    )
    # Caissier qui a effectué la vente
    caissier_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    # Signalement propriétaire si au moins une ligne est vendue à perte
    signale_proprietaire: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False
    )
    synced: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    lignes: Mapped[list["LigneVente"]] = relationship(
        back_populates="vente", cascade="all, delete-orphan"
    )


class LigneVente(Base):
    __tablename__ = "lignes_vente"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    vente_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("ventes.id", ondelete="CASCADE"),
        nullable=False,
    )
    produit_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("produits.id"), nullable=True
    )
    quantite: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    prix_vendu_reel: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    marge_calculee: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    # Marqueur de vente à perte (prix_vendu_reel < prix_achat_moyen)
    vente_a_perte: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False
    )

    vente: Mapped["Vente"] = relationship(back_populates="lignes")


class Abonnement(Base):
    __tablename__ = "abonnements"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    # 1 abonnement par propriétaire (OWNER), couvre toutes ses boutiques
    proprietaire_id: Mapped[str] = mapped_column(
        String(255), nullable=False, unique=True
    )
    plan: Mapped[str] = mapped_column(
        String(20), nullable=False, default="FREE"
    )  # FREE | PRO
    # Prix de base mensuel en FCFA (boutique 1)
    prix_base: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("5000.00")
    )
    # Quota ventes/mois par boutique (FREE=20, PRO=illimité)
    quota_ventes_par_boutique: Mapped[int] = mapped_column(
        Integer, nullable=False, default=20
    )
    date_debut: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    date_fin: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )  # None = pas d'expiration (PRO actif)
    actif: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)


class TransactionCaisse(Base):
    __tablename__ = "transactions_caisse"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    session_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("sessions_caisse.id"), nullable=True
    )
    type_transaction: Mapped[str] = mapped_column(
        String(20), nullable=False
    )  # ENTREE | SORTIE_DEPENSE
    montant: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    motif: Mapped[str] = mapped_column(String(255), nullable=False)
    id_local_smartphone: Mapped[str | None] = mapped_column(
        String(255), unique=True, nullable=True
    )
    date_transaction: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    synced: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
