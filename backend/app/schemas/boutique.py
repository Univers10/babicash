import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class BoutiqueOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    nom: str
    proprietaire_id: str
    date_creation: datetime
