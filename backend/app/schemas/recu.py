import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel


class RecuLigne(BaseModel):
    nom: str
    quantite: int
    prix_unitaire: Decimal
    total_ligne: Decimal


class RecuOut(BaseModel):
    """Données structurées d'un reçu, réutilisables pour:
    - le partage WhatsApp (PDF),
    - l'impression sur imprimante thermique Bluetooth (ESC/POS) côté Flutter.
    """

    vente_id: uuid.UUID
    numero: str
    boutique_nom: str
    date_vente: datetime
    mode_paiement: str
    lignes: list[RecuLigne]
    montant_total: Decimal
    client_nom: str | None = None
    message_pied: str = "Merci de votre visite !"
