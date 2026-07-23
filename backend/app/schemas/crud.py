import uuid
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# ----- Boutique -----
class BoutiqueCreate(BaseModel):
    nom: str = Field(min_length=1, max_length=255)
    adresse: str | None = Field(default=None, max_length=255)
    telephone: str | None = Field(default=None, max_length=30)
    type_commerce: str | None = Field(default=None, max_length=100)


class BoutiqueUpdate(BaseModel):
    nom: str | None = Field(default=None, min_length=1, max_length=255)
    adresse: str | None = Field(default=None, max_length=255)
    telephone: str | None = Field(default=None, max_length=30)
    type_commerce: str | None = Field(default=None, max_length=100)
    logo_url: str | None = Field(default=None, max_length=500)


# ----- Catégorie -----
class CategorieCreate(BaseModel):
    boutique_id: uuid.UUID
    nom: str = Field(min_length=1, max_length=100)


class CategorieUpdate(BaseModel):
    nom: str | None = Field(default=None, min_length=1, max_length=100)


class CategorieOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    boutique_id: uuid.UUID
    nom: str


# ----- Produit -----
class ProduitCreate(BaseModel):
    boutique_id: uuid.UUID
    categorie_id: uuid.UUID | None = None
    nom: str = Field(min_length=1, max_length=255)
    prix_achat_moyen: Decimal = Field(default=Decimal("0.00"), ge=0)
    prix_vente_suggere: Decimal = Field(default=Decimal("0.00"), ge=0)
    stock_actuel: int = Field(default=0, ge=0)
    stock_alerte: int = Field(default=5, ge=0)
    image_url: str | None = Field(default=None, max_length=500)


class ProduitUpdate(BaseModel):
    categorie_id: uuid.UUID | None = None
    nom: str | None = Field(default=None, min_length=1, max_length=255)
    prix_achat_moyen: Decimal | None = Field(default=None, ge=0)
    prix_vente_suggere: Decimal | None = Field(default=None, ge=0)
    stock_actuel: int | None = Field(default=None, ge=0)
    stock_alerte: int | None = Field(default=None, ge=0)
    image_url: str | None = Field(default=None, max_length=500)


class ProduitOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    boutique_id: uuid.UUID
    categorie_id: uuid.UUID | None
    nom: str
    prix_achat_moyen: Decimal
    prix_vente_suggere: Decimal
    stock_actuel: int
    stock_alerte: int
    image_url: str | None = None


# ----- Compte tiers (Client / Fournisseur) -----
class CompteTiersCreate(BaseModel):
    boutique_id: uuid.UUID
    nom: str = Field(min_length=1, max_length=255)
    telephone: str | None = Field(default=None, max_length=50)
    type_tiers: str = Field(pattern="^(CLIENT|FOURNISSEUR)$")


class CompteTiersUpdate(BaseModel):
    nom: str | None = Field(default=None, min_length=1, max_length=255)
    telephone: str | None = Field(default=None, max_length=50)


class PaiementTiersRequest(BaseModel):
    """Enregistre un remboursement (client) ou un paiement (fournisseur).
    Le montant vient en déduction du solde_du.
    """

    montant: Decimal = Field(gt=0)
    motif: str | None = Field(default=None, max_length=255)


class CompteTiersOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    boutique_id: uuid.UUID
    nom: str
    telephone: str | None
    type_tiers: str
    solde_du: Decimal


# ----- Utilisateur (gérant) -----
class UserCreate(BaseModel):
    """Création d'un gérant : connexion simplifiée par téléphone + code PIN.

    L'email/mot de passe restent optionnels (utiles surtout pour le propriétaire).
    """

    nom: str = Field(min_length=1, max_length=255)
    telephone: str = Field(min_length=4, max_length=30)
    code_pin: str = Field(pattern=r"^\d{4}$")
    role: str = Field(default="MANAGER", pattern="^(OWNER|MANAGER)$")
    boutique_id: uuid.UUID | None = None
    email: EmailStr | None = None
    mot_de_passe: str | None = Field(default=None, min_length=6, max_length=128)


class UserUpdate(BaseModel):
    nom: str | None = Field(default=None, min_length=1, max_length=255)
    telephone: str | None = Field(default=None, min_length=4, max_length=30)
    code_pin: str | None = Field(default=None, pattern=r"^\d{4}$")
    mot_de_passe: str | None = Field(default=None, min_length=6, max_length=128)
    actif: bool | None = None
    boutique_id: uuid.UUID | None = None


class SetPinRequest(BaseModel):
    """Définir/réinitialiser le code PIN (par soi-même ou par le propriétaire)."""

    code_pin: str = Field(pattern=r"^\d{4}$")


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    nom: str
    email: EmailStr | None
    telephone: str | None
    role: str
    boutique_id: uuid.UUID | None
    actif: bool
