import uuid
from decimal import Decimal

from pydantic import BaseModel


class BestSellerItem(BaseModel):
    produit_id: uuid.UUID | None
    nom: str
    quantite_totale: int
    marge_nette_totale: Decimal
    chiffre_affaires: Decimal


class BestSellersResponse(BaseModel):
    boutique_id: uuid.UUID
    tri: str  # 'quantite' | 'marge'
    items: list[BestSellerItem]
