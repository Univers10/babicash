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
    __table_args__ = (
        UniqueConstraint(
            "oauth_provider", "oauth_id", name="uq_users_oauth_provider_id"
        ),
    )

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
    role: Mapped[str] = mapped_column(
        String(20), nullable=False
    )  # OWNER | MANAGER | AMBASSADEUR
    boutique_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=True
    )
    actif: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    token_version: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    # Connexion sociale (Google / Apple) : optionnelle, coexiste avec email+mdp
    oauth_provider: Mapped[str | None] = mapped_column(String(20), nullable=True)
    oauth_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    # Parrainage : ambassadeur ayant parrainé ce propriétaire (figé à
    # l'inscription, jamais modifié). NULL si inscription sans code.
    parraine_par_ambassadeur_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("ambassadeurs.id"), nullable=True
    )


class Boutique(Base):
    __tablename__ = "boutiques"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    nom: Mapped[str] = mapped_column(String(255), nullable=False)
    proprietaire_id: Mapped[str] = mapped_column(String(255), nullable=False)
    adresse: Mapped[str | None] = mapped_column(String(255), nullable=True)
    telephone: Mapped[str | None] = mapped_column(String(30), nullable=True)
    type_commerce: Mapped[str | None] = mapped_column(String(100), nullable=True)
    # URL du logo de la boutique (upload serveur, servi via /static).
    logo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
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
    # URL de l'image du produit (upload serveur, servie via /static).
    image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

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
    # Statut de la vente
    statut: Mapped[str] = mapped_column(
        String(20), nullable=False, default="ACTIVE"
    )  # ACTIVE | RETOURNEE
    date_retour: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
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
    # Lot (prix de groupe) : lignes vendues ensemble à un prix négocié réparti.
    # NULL = ligne normale (toutes les ventes existantes).
    lot_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), nullable=True
    )
    lot_nom: Mapped[str | None] = mapped_column(String(120), nullable=True)

    vente: Mapped["Vente"] = relationship(back_populates="lignes")


class Abonnement(Base):
    __tablename__ = "abonnements"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    proprietaire_id: Mapped[str] = mapped_column(
        String(255), nullable=False, unique=True
    )
    plan: Mapped[str] = mapped_column(
        String(20), nullable=False, default="FREE"
    )  # FREE | KIOSQUE | BOUTIQUE | COMMERCE | ENTREPRISE | EMPIRE
    prix_base: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("0.00")
    )
    quota_ventes_par_boutique: Mapped[int] = mapped_column(
        Integer, nullable=False, default=20
    )
    nb_boutiques_max: Mapped[int] = mapped_column(
        Integer, nullable=False, default=1
    )
    nb_gerants_max: Mapped[int] = mapped_column(
        Integer, nullable=False, default=1
    )
    date_debut: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    date_fin: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    actif: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)


class MouvementStock(Base):
    """Journal des mouvements de stock (entrées / sorties manuelles)."""

    __tablename__ = "mouvements_stock"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("boutiques.id"), nullable=False
    )
    produit_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("produits.id", ondelete="SET NULL"),
        nullable=True,
    )
    produit_nom: Mapped[str] = mapped_column(String(255), nullable=False, default="")
    type_mouvement: Mapped[str] = mapped_column(
        String(10), nullable=False
    )  # ENTREE | SORTIE
    quantite: Mapped[int] = mapped_column(Integer, nullable=False)
    motif: Mapped[str] = mapped_column(String(255), nullable=False)
    auteur_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    auteur_nom: Mapped[str] = mapped_column(String(255), nullable=False, default="")
    date_mouvement: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    # Empêche les doublons de synchronisation (idempotence)
    id_local_smartphone: Mapped[str | None] = mapped_column(
        String(255), unique=True, nullable=True
    )
    synced: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)


class RecuConfig(Base):
    """Personnalisation du reçu de caisse, une ligne par boutique (1:1).

    Persistée côté serveur pour survivre à la réinstallation et se synchroniser
    entre appareils. Côté smartphone, elle est mise en cache dans Drift
    (`LocalRecuConfigs`) pour rester disponible hors-ligne au moment de la vente.
    Réconciliation en dernier-écrivain-gagne via `updated_at`.
    """

    __tablename__ = "recu_configs"

    boutique_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("boutiques.id", ondelete="CASCADE"),
        primary_key=True,
    )
    # Infos boutique affichées en tête du reçu (surcharges facultatives : vides
    # => repli sur les infos de la boutique côté client).
    nom_boutique: Mapped[str] = mapped_column(String(255), nullable=False, default="")
    adresse: Mapped[str] = mapped_column(String(255), nullable=False, default="")
    telephone: Mapped[str] = mapped_column(String(30), nullable=False, default="")
    # En-tête libre multi-lignes (slogan / RCCM / NCC).
    entete: Mapped[str] = mapped_column(String(500), nullable=False, default="")
    # Message de pied de reçu.
    pied_message: Mapped[str] = mapped_column(
        String(500), nullable=False, default="Merci pour votre achat !"
    )
    afficher_logo: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    afficher_vendeur: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )


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


# ── Parrainage / ambassadeurs ────────────────────────────────────────


class Ambassadeur(Base):
    """Profil ambassadeur (parrainage), lié 1:1 à un ``User``.

    Toute personne peut créer un compte ambassadeur (``role = AMBASSADEUR``,
    sans boutique) ; un ``OWNER`` existant peut aussi en avoir un. L'ambassadeur
    choisit lui-même son ``code`` de parrainage. Il perçoit une commission sur
    les abonnements payés par ses filleuls (voir :class:`CommissionParrainage`),
    versée chaque semaine par Mobile Money (voir :class:`Payout`).
    """

    __tablename__ = "ambassadeurs"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )
    # Code de parrainage choisi par l'ambassadeur (normalisé en majuscules).
    code: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    # Coordonnées de versement (Mobile Money).
    momo_numero: Mapped[str] = mapped_column(String(30), nullable=False, default="")
    momo_operateur: Mapped[str] = mapped_column(
        String(20), nullable=False, default=""
    )  # WAVE | ORANGE | MTN | MOOV
    actif: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    # Compte validé (vérification d'identité effectuée). Tant que le compte n'est
    # pas validé, ses versements sont plafonnés à
    # ``settings.AMBASSADEUR_PLAFOND_MENSUEL`` par mois (le solde est reporté).
    valide: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Notification(Base):
    """Notification in-app pour un ambassadeur (nouveau filleul, commission, versement)."""

    __tablename__ = "notifications"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ambassadeur_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("ambassadeurs.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )
    type: Mapped[str] = mapped_column(
        String(30), nullable=False
    )  # NOUVEAU_FILLEUL | COMMISSION | VERSEMENT
    titre: Mapped[str] = mapped_column(String(120), nullable=False)
    message: Mapped[str] = mapped_column(String(500), nullable=False)
    lu: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class PushSubscription(Base):
    """Abonnement Web Push (navigateur) d'un ambassadeur, pour les notifications push."""

    __tablename__ = "push_subscriptions"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ambassadeur_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("ambassadeurs.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )
    endpoint: Mapped[str] = mapped_column(String(500), unique=True, nullable=False)
    p256dh: Mapped[str] = mapped_column(String(255), nullable=False)
    auth: Mapped[str] = mapped_column(String(255), nullable=False)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class PaiementAbonnement(Base):
    """Journal des paiements d'abonnement confirmés (par l'admin).

    Source de vérité du chiffre d'affaires réel et déclencheur des commissions
    de parrainage (le paiement n'étant pas automatisé, un admin le confirme).
    """

    __tablename__ = "paiements_abonnement"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    proprietaire_id: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    abonnement_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("abonnements.id"), nullable=True
    )
    plan: Mapped[str] = mapped_column(String(20), nullable=False)
    montant: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    periode_debut: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    periode_fin: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    confirme_par: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    date_paiement: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class Payout(Base):
    """Lot de versement hebdomadaire des commissions à un ambassadeur."""

    __tablename__ = "payouts"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ambassadeur_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("ambassadeurs.id"), index=True, nullable=False
    )
    semaine: Mapped[str] = mapped_column(String(10), nullable=False)  # ex. 2026-W31
    montant_total: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), nullable=False, default=Decimal("0.00")
    )
    momo_numero: Mapped[str] = mapped_column(String(30), nullable=False, default="")
    statut: Mapped[str] = mapped_column(
        String(10), nullable=False, default="A_PAYER"
    )  # A_PAYER | PAYE
    reference_transfert: Mapped[str | None] = mapped_column(String(100), nullable=True)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    date_execution: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )


class CommissionParrainage(Base):
    """Commission due à un ambassadeur sur un paiement d'un de ses filleuls."""

    __tablename__ = "commissions_parrainage"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ambassadeur_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("ambassadeurs.id"), index=True, nullable=False
    )
    filleul_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    paiement_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("paiements_abonnement.id", ondelete="SET NULL"),
        nullable=True,
    )
    montant_paye: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    taux: Mapped[Decimal] = mapped_column(
        Numeric(4, 3), nullable=False, default=Decimal("0.200")
    )
    montant_commission: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    statut: Mapped[str] = mapped_column(
        String(15), nullable=False, default="VALIDEE"
    )  # VALIDEE | PAYEE | ANNULEE
    payout_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("payouts.id", ondelete="SET NULL"), nullable=True
    )
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class LandingLead(Base):
    """Demande de contact ou d'essai issue du site landing."""

    __tablename__ = "landing_leads"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    nom: Mapped[str | None] = mapped_column(String(255), nullable=True)
    contact: Mapped[str | None] = mapped_column(String(255), nullable=True)
    message: Mapped[str | None] = mapped_column(String(2000), nullable=True)
    traite: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    date_creation: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
