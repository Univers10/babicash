import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.recu import RecuOut


# ----- PUSH (smartphone -> serveur) -----
class LigneVenteIn(BaseModel):
    produit_id: uuid.UUID | None = None
    quantite: int = Field(default=1, ge=1)
    prix_vendu_reel: Decimal = Field(ge=0)


class VenteIn(BaseModel):
    id_local_smartphone: str
    session_id: uuid.UUID | None = None
    tier_id: uuid.UUID | None = None
    date_vente: datetime | None = None
    mode_paiement: str  # ESPECES | MOBILE_MONEY | CREDIT
    lignes: list[LigneVenteIn]


class DepenseIn(BaseModel):
    id_local_smartphone: str
    session_id: uuid.UUID | None = None
    type_transaction: str = "SORTIE_DEPENSE"  # ENTREE | SORTIE_DEPENSE
    montant: Decimal = Field(ge=0)
    motif: str
    date_transaction: datetime | None = None


class LigneEntreeStockIn(BaseModel):
    produit_id: uuid.UUID
    quantite: int = Field(ge=1)
    prix_achat_unitaire: Decimal = Field(ge=0)  # prix payé au fournisseur


class EntreeStockIn(BaseModel):
    id_local_smartphone: str
    session_id: uuid.UUID | None = None
    fournisseur_id: uuid.UUID | None = None  # CompteTiers de type FOURNISSEUR
    mode_paiement: str = "ESPECES"  # ESPECES | MOBILE_MONEY | CREDIT
    date_entree: datetime | None = None
    lignes: list[LigneEntreeStockIn]


class SyncPushRequest(BaseModel):
    boutique_id: uuid.UUID
    ventes: list[VenteIn] = []
    depenses: list[DepenseIn] = []
    entrees_stock: list[EntreeStockIn] = []


class VentePushResult(BaseModel):
    id_local_smartphone: str
    vente_id: uuid.UUID
    deja_synchronisee: bool = False
    signale_proprietaire: bool = False
    avertissement: str | None = None
    recu: RecuOut | None = None


class DepensePushResult(BaseModel):
    id_local_smartphone: str
    transaction_id: uuid.UUID
    deja_synchronisee: bool = False


class EntreeStockPushResult(BaseModel):
    id_local_smartphone: str
    transaction_id: uuid.UUID
    deja_synchronisee: bool = False
    produits_mis_a_jour: list[uuid.UUID] = []  # IDs des produits dont le stock a changé


class AlerteStockItem(BaseModel):
    produit_id: uuid.UUID
    nom: str
    stock_actuel: int
    stock_alerte: int
    en_rupture: bool  # True si stock_actuel <= 0


class SyncPushResponse(BaseModel):
    ventes: list[VentePushResult] = []
    depenses: list[DepensePushResult] = []
    entrees_stock: list[EntreeStockPushResult] = []
    alertes_stock: list[AlerteStockItem] = []


# ----- PULL (serveur -> smartphone) -----
class ProduitOut(BaseModel):
    id: uuid.UUID
    boutique_id: uuid.UUID
    categorie_id: uuid.UUID | None
    nom: str
    prix_achat_moyen: Decimal
    prix_vente_suggere: Decimal
    stock_actuel: int
    stock_alerte: int

    model_config = ConfigDict(from_attributes=True)


class CategorieOut(BaseModel):
    id: uuid.UUID
    boutique_id: uuid.UUID
    nom: str

    model_config = ConfigDict(from_attributes=True)


class SyncPullResponse(BaseModel):
    boutique_id: uuid.UUID
    produits: list[ProduitOut]
    categories: list[CategorieOut]
    server_time: datetime
