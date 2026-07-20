import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user
from app.models import MouvementStock
from app.schemas.auth import CurrentUser
from app.schemas.sync import MouvementStockOut

router = APIRouter()


@router.get("/", response_model=list[MouvementStockOut])
async def list_mouvements_stock(
    boutique_id: uuid.UUID = Query(...),
    produit_id: uuid.UUID | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[MouvementStock]:
    """Journal des mouvements de stock d'une boutique (plus récents d'abord)."""
    await get_authorized_boutique(db, current_user, boutique_id)
    query = (
        select(MouvementStock)
        .where(MouvementStock.boutique_id == boutique_id)
        .order_by(MouvementStock.date_mouvement.desc())
        .limit(limit)
        .offset(offset)
    )
    if produit_id is not None:
        query = query.where(MouvementStock.produit_id == produit_id)
    rows = (await db.execute(query)).scalars().all()
    return list(rows)
