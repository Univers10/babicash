"""Schémas Pydantic pour les ambassadeurs (parrainage)."""
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, EmailStr, Field, field_validator

# Opérateurs Mobile Money acceptés pour le versement des commissions.
OPERATEURS_MOMO = {"WAVE", "ORANGE", "MTN", "MOOV"}


class AmbassadeurRegisterRequest(BaseModel):
    """Inscription d'un ambassadeur (compte + profil + code choisi)."""

    nom: str = Field(min_length=1, max_length=255)
    email: EmailStr
    mot_de_passe: str = Field(min_length=6, max_length=128)
    telephone: str | None = Field(default=None, max_length=30)
    # Code de parrainage choisi (validé/normalisé côté service).
    code: str = Field(min_length=4, max_length=20)
    momo_numero: str = Field(min_length=4, max_length=30)
    momo_operateur: str = Field(max_length=20)

    @field_validator("momo_operateur")
    @classmethod
    def _operateur_valide(cls, v: str) -> str:
        v = v.strip().upper()
        if v not in OPERATEURS_MOMO:
            raise ValueError(
                f"Opérateur invalide. Valeurs acceptées : {sorted(OPERATEURS_MOMO)}"
            )
        return v


class AmbassadeurLoginRequest(BaseModel):
    """Connexion d'un ambassadeur (email + mot de passe)."""

    email: EmailStr
    mot_de_passe: str


class CodeDisponibleResponse(BaseModel):
    """Réponse de la vérification de disponibilité d'un code."""

    code: str
    disponible: bool
    # None si disponible, sinon : "format" | "reserve" | "pris"
    raison: str | None = None


class AmbassadeurOut(BaseModel):
    """Profil ambassadeur (données non sensibles)."""

    id: str
    nom: str
    email: str | None = None
    code: str
    momo_numero: str
    momo_operateur: str
    actif: bool


class MonEspaceOut(BaseModel):
    """Synthèse de l'espace ambassadeur (accueil « genre Wave »)."""

    id: str
    nom: str
    email: str | None = None
    code: str
    momo_numero: str
    momo_operateur: str
    actif: bool
    nb_filleuls: int
    nb_filleuls_payants: int
    # Commissions validées non encore versées (= à recevoir au prochain lot).
    solde_a_recevoir: Decimal
    # Total gagné à vie (validé + déjà versé).
    total_gagne: Decimal


class FilleulOut(BaseModel):
    """Un filleul et l'état de son abonnement, vus par l'ambassadeur."""

    filleul_id: str
    nom: str
    plan: str
    abonnement_actif: bool
    date_inscription: datetime
    commission_cumulee: Decimal


class CommissionOut(BaseModel):
    """Une ligne d'activité (commission) de l'ambassadeur."""

    id: str
    filleul_nom: str
    montant_paye: Decimal
    montant_commission: Decimal
    statut: str
    date_creation: datetime


class VersementOut(BaseModel):
    """Un lot de versement hebdomadaire."""

    id: str
    semaine: str
    montant_total: Decimal
    statut: str
    reference_transfert: str | None = None
    date_creation: datetime
    date_execution: datetime | None = None


class MomoUpdateRequest(BaseModel):
    """Mise à jour des coordonnées de versement."""

    momo_numero: str = Field(min_length=4, max_length=30)
    momo_operateur: str = Field(max_length=20)

    @field_validator("momo_operateur")
    @classmethod
    def _operateur_valide(cls, v: str) -> str:
        v = v.strip().upper()
        if v not in OPERATEURS_MOMO:
            raise ValueError(
                f"Opérateur invalide. Valeurs acceptées : {sorted(OPERATEURS_MOMO)}"
            )
        return v
