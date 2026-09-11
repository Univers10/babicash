"""Schémas de la boutique « Matériel & accessoires » (produits + commandes)."""
import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


# ── Produits ───────────────────────────────────────────────────────────────

class ShopProduitCreate(BaseModel):
    nom: str = Field(min_length=1, max_length=255)
    description: str = Field(default="", max_length=5000)
    tagline: str = Field(default="", max_length=255)
    prix: Decimal = Field(default=Decimal("0.00"), ge=0)
    ancien_prix: Decimal | None = Field(default=None, ge=0)
    categorie: str = Field(
        default="ACCESSOIRES", pattern="^(IMPRIMANTES|ROULEAUX|ACCESSOIRES)$"
    )
    icone: str = Field(default="print", max_length=50)
    specs: list[str] = Field(default_factory=list)
    stock: int = Field(default=0, ge=0)
    stock_alerte: int = Field(default=5, ge=0)
    en_vente: bool = True
    is_new: bool = False
    is_populaire: bool = False
    position: int = Field(default=0, ge=0)


class ShopProduitUpdate(BaseModel):
    nom: str | None = Field(default=None, min_length=1, max_length=255)
    description: str | None = Field(default=None, max_length=5000)
    tagline: str | None = Field(default=None, max_length=255)
    prix: Decimal | None = Field(default=None, ge=0)
    ancien_prix: Decimal | None = Field(default=None, ge=0)
    categorie: str | None = Field(
        default=None, pattern="^(IMPRIMANTES|ROULEAUX|ACCESSOIRES)$"
    )
    icone: str | None = Field(default=None, max_length=50)
    specs: list[str] | None = None
    stock: int | None = Field(default=None, ge=0)
    stock_alerte: int | None = Field(default=None, ge=0)
    en_vente: bool | None = None
    is_new: bool | None = None
    is_populaire: bool | None = None
    position: int | None = Field(default=None, ge=0)


class ShopProduitOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    nom: str
    description: str
    tagline: str
    prix: Decimal
    ancien_prix: Decimal | None
    categorie: str
    icone: str
    specs: list[str]
    stock: int
    stock_alerte: int
    en_vente: bool
    is_new: bool
    is_populaire: bool
    position: int


# ── Commandes ──────────────────────────────────────────────────────────────

class CommandeLigneCreate(BaseModel):
    produit_id: uuid.UUID | None = None
    nom: str | None = Field(default=None, max_length=255)
    prix_unitaire: Decimal = Field(default=Decimal("0.00"), ge=0)
    quantite: int = Field(default=1, ge=1, le=999)


class CommandeCreate(BaseModel):
    client_nom: str = Field(min_length=1, max_length=255)
    client_telephone: str | None = Field(default=None, max_length=30)
    client_adresse: str | None = Field(default=None, max_length=255)
    notes: str | None = Field(default=None, max_length=2000)
    source: str = Field(default="APP", pattern="^(APP|WHATSAPP|ADMIN)$")
    lignes: list[CommandeLigneCreate] = Field(min_length=1)


class CommandeLigneOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    produit_id: uuid.UUID | None
    nom: str
    prix_unitaire: Decimal
    quantite: int


class CommandeShopOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    client_nom: str
    client_telephone: str | None
    client_adresse: str | None
    statut: str
    source: str
    total: Decimal
    notes: str | None
    date_creation: datetime
    lignes: list[CommandeLigneOut]


class CommandeStatutUpdate(BaseModel):
    statut: str = Field(
        pattern="^(NOUVELLE|CONFIRMEE|PREPARATION|EXPEDIEE|LIVREE|ANNULEE)$"
    )