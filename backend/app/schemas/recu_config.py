from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class RecuConfigUpdate(BaseModel):
    """Payload d'enregistrement (upsert) de la personnalisation du reçu.

    Tous les champs ont une valeur par défaut : un `PUT` remplace intégralement
    la config de la boutique (sémantique dernier-écrivain-gagne).
    """

    nom_boutique: str = Field(default="", max_length=255)
    adresse: str = Field(default="", max_length=255)
    telephone: str = Field(default="", max_length=30)
    entete: str = Field(default="", max_length=500)
    pied_message: str = Field(default="Merci pour votre achat !", max_length=500)
    afficher_logo: bool = True
    afficher_vendeur: bool = True


class RecuConfigOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    nom_boutique: str
    adresse: str
    telephone: str
    entete: str
    pied_message: str
    afficher_logo: bool
    afficher_vendeur: bool
    updated_at: datetime
