"""Endpoint public pour recevoir les demandes du formulaire landing."""
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.models import LandingLead

router = APIRouter()


class LandingLeadIn(BaseModel):
    nom: str | None = Field(None, max_length=255)
    contact: str | None = Field(None, max_length=255)
    message: str | None = Field(None, max_length=2000)


class LandingLeadOut(BaseModel):
    id: uuid.UUID
    nom: str | None
    contact: str | None
    message: str | None
    traite: bool
    date_creation: datetime

    class Config:
        from_attributes = True


@router.post("/", response_model=LandingLeadOut, status_code=status.HTTP_201_CREATED)
async def creer_lead(payload: LandingLeadIn, db: AsyncSession = Depends(get_db)) -> LandingLead:
    """Enregistre une demande de contact issue de la landing page."""
    lead = LandingLead(
        nom=payload.nom,
        contact=payload.contact,
        message=payload.message,
    )
    db.add(lead)
    await db.commit()
    await db.refresh(lead)
    return lead
