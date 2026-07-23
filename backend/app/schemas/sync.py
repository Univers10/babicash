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
    # Lot (prix de groupe) : optionnels et rétro-compatibles — un client
    # antérieur qui ne les envoie pas continue de fonctionner.
    lot_id: uuid.UUID | None = None
    lot_nom: str | None = None


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


class MouvementStockIn(BaseModel):
    """Mouvement de stock manuel (entrée ou sortie) saisi sur le smartphone."""

    id_local_smartphone: str
    produit_id: uuid.UUID
    produit_nom: str = ""
    type_mouvement: str = Field(pattern="^(ENTREE|SORTIE)$")
    quantite: int = Field(ge=1)
    motif: str = Field(min_length=1, max_length=255)
    auteur_nom: str = ""
    date_mouvement: datetime | None = None


class SyncPushRequest(BaseModel):
    boutique_id: uuid.UUID
    ventes: list[VenteIn] = []
    depenses: list[DepenseIn] = []
    entrees_stock: list[EntreeStockIn] = []
    mouvements_stock: list[MouvementStockIn] = []


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


class MouvementStockPushResult(BaseModel):
    id_local_smartphone: str
    mouvement_id: uuid.UUID
    deja_synchronise: bool = False
    stock_actuel: int | None = None  # stock du produit après application


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
    mouvements_stock: list[MouvementStockPushResult] = []
    alertes_stock: list[AlerteStockItem] = []


class MouvementStockOut(BaseModel):
    id: uuid.UUID
    boutique_id: uuid.UUID
    produit_id: uuid.UUID | None
    produit_nom: str
    type_mouvement: str
    quantite: int
    motif: str
    auteur_id: uuid.UUID | None
    auteur_nom: str
    date_mouvement: datetime

    model_config = ConfigDict(from_attributes=True)


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
    image_url: str | None = None

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
