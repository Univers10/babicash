import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.models import Abonnement
from app.schemas.auth import CurrentUser
from app.services import abonnement_service

router = APIRouter()


class AbonnementOut(BaseModel):
    boutique_id: uuid.UUID
    plan: str
    quota_ventes_mois: int
    date_fin: datetime | None
    actif: bool
    ventes_utilisees_ce_mois: int
    ventes_restantes: int | None  # None si plan PRO illimité

    model_config = {"from_attributes": True}


class UpgradeRequest(BaseModel):
    plan: str = Field(pattern="^(FREE|PRO)$")
    date_fin: datetime | None = None


@router.get("/{boutique_id}", response_model=AbonnementOut)
async def get_abonnement(
    boutique_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> AbonnementOut:
    """Retourne l'état de l'abonnement et le quota utilisé ce mois."""
    from app.access import get_authorized_boutique
    await get_authorized_boutique(db, current_user, boutique_id)

    abo = await abonnement_service.get_or_create_abonnement(db, boutique_id)
    ventes_mois = await abonnement_service.compter_ventes_mois(db, boutique_id)

    if abo.plan == "PRO" and abo.actif:
        ventes_restantes = None
    else:
        ventes_restantes = max(0, abo.quota_ventes_mois - ventes_mois)

    return AbonnementOut(
        boutique_id=abo.boutique_id,
        plan=abo.plan,
        quota_ventes_mois=abo.quota_ventes_mois,
        date_fin=abo.date_fin,
        actif=abo.actif,
        ventes_utilisees_ce_mois=ventes_mois,
        ventes_restantes=ventes_restantes,
    )


@router.post("/{boutique_id}/upgrade", response_model=AbonnementOut)
async def upgrade_abonnement(
    boutique_id: uuid.UUID,
    payload: UpgradeRequest,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> AbonnementOut:
    """Upgrade ou downgrade le plan d'une boutique (OWNER uniquement)."""
    from app.access import get_authorized_boutique
    await get_authorized_boutique(db, current_user, boutique_id)

    abo = await abonnement_service.upgrader_plan(
        db, boutique_id, payload.plan, payload.date_fin
    )
    ventes_mois = await abonnement_service.compter_ventes_mois(db, boutique_id)

    if abo.plan == "PRO" and abo.actif:
        ventes_restantes = None
    else:
        ventes_restantes = max(0, abo.quota_ventes_mois - ventes_mois)

    return AbonnementOut(
        boutique_id=abo.boutique_id,
        plan=abo.plan,
        quota_ventes_mois=abo.quota_ventes_mois,
        date_fin=abo.date_fin,
        actif=abo.actif,
        ventes_utilisees_ce_mois=ventes_mois,
        ventes_restantes=ventes_restantes,
    )
