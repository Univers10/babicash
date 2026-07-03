import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user
from app.schemas.analytics import BestSellersResponse
from app.schemas.auth import CurrentUser
from app.services import analytics_service

router = APIRouter()


@router.get("/best-sellers", response_model=BestSellersResponse)
async def best_sellers(
    boutique_id: uuid.UUID = Query(...),
    tri: str = Query("quantite", pattern="^(quantite|marge)$"),
    date_debut: datetime | None = Query(None),
    date_fin: datetime | None = Query(None),
    limite: int = Query(20, ge=1, le=100),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> BestSellersResponse:
    # Cloisonnement multi-tenant (OWNER propriétaire / MANAGER verrouillé)
    await get_authorized_boutique(db, current_user, boutique_id)

    return await analytics_service.best_sellers(
        db,
        boutique_id=boutique_id,
        tri=tri,
        date_debut=date_debut,
        date_fin=date_fin,
        limite=limite,
    )
