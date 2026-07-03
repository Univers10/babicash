import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class SessionOuvrirRequest(BaseModel):
    boutique_id: uuid.UUID
    montant_initial: Decimal = Field(default=Decimal("0.00"), ge=0)


class SessionFermerRequest(BaseModel):
    montant_final_declare: Decimal = Field(ge=0)


class SessionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    boutique_id: uuid.UUID
    utilisateur_nom: str
    date_ouverture: datetime
    date_fermeture: datetime | None
    montant_initial: Decimal
    montant_final_declare: Decimal
    statut: str  # OUVERT | FERME


class SessionResume(BaseModel):
    """Détail d'une session avec réconciliation de caisse (anti-fraude)."""

    session: SessionOut
    nb_ventes: int
    total_ventes_especes: Decimal
    total_ventes_autres: Decimal  # Mobile Money + Crédit (hors tiroir-caisse)
    total_entrees: Decimal
    total_sorties: Decimal
    # montant attendu en espèces dans le tiroir-caisse
    montant_theorique: Decimal
    # écart = déclaré - théorique (rempli après fermeture)
    ecart: Decimal | None = None
    ecart_signale: bool = False
