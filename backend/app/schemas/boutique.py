import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class BoutiqueOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    nom: str
    proprietaire_id: str
    adresse: str | None
    telephone: str | None
    type_commerce: str | None
    date_creation: datetime
