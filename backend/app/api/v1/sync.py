import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user
from app.models import Categorie, Produit
from app.schemas.auth import CurrentUser
from app.schemas.sync import (
    SyncPullResponse,
    SyncPushRequest,
    SyncPushResponse,
)
from app.services import sync_service

router = APIRouter()


@router.post("/push", response_model=SyncPushResponse)
async def sync_push(
    payload: SyncPushRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SyncPushResponse:
    boutique = await get_authorized_boutique(db, current_user, payload.boutique_id)
    caissier_id = uuid.UUID(current_user.id) if current_user.id else None
    return await sync_service.push(db, boutique, payload, caissier_id=caissier_id)


@router.get("/pull", response_model=SyncPullResponse)
async def sync_pull(
    boutique_id: uuid.UUID = Query(...),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SyncPullResponse:
    await get_authorized_boutique(db, current_user, boutique_id)

    produits = (
        (
            await db.execute(
                select(Produit).where(Produit.boutique_id == boutique_id)
            )
        )
        .scalars()
        .all()
    )
    categories = (
        (
            await db.execute(
                select(Categorie).where(Categorie.boutique_id == boutique_id)
            )
        )
        .scalars()
        .all()
    )

    return SyncPullResponse(
        boutique_id=boutique_id,
        produits=list(produits),
        categories=list(categories),
        server_time=datetime.now(timezone.utc),
    )
