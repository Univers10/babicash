import uuid

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.models import Boutique
from app.schemas.auth import CurrentUser
from app.schemas.boutique import BoutiqueOut
from app.schemas.crud import BoutiqueCreate, BoutiqueUpdate

router = APIRouter()


@router.get("/", response_model=list[BoutiqueOut])
async def list_boutiques(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[Boutique]:
    stmt = select(Boutique)
    if current_user.role == "OWNER":
        stmt = stmt.where(Boutique.proprietaire_id == current_user.id)
    elif current_user.boutique_id is not None:
        # Le gérant est verrouillé sur sa boutique
        stmt = stmt.where(Boutique.id == current_user.boutique_id)
    else:
        return []

    rows = (await db.execute(stmt.order_by(Boutique.nom))).scalars().all()
    return list(rows)


@router.post(
    "/", response_model=BoutiqueOut, status_code=status.HTTP_201_CREATED
)
async def create_boutique(
    payload: BoutiqueCreate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Boutique:
    boutique = Boutique(nom=payload.nom, proprietaire_id=current_user.id)
    db.add(boutique)
    await db.commit()
    await db.refresh(boutique)
    return boutique


@router.get("/{boutique_id}", response_model=BoutiqueOut)
async def get_boutique(
    boutique_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Boutique:
    return await get_authorized_boutique(db, current_user, boutique_id)


@router.patch("/{boutique_id}", response_model=BoutiqueOut)
async def update_boutique(
    boutique_id: uuid.UUID,
    payload: BoutiqueUpdate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Boutique:
    boutique = await get_authorized_boutique(db, current_user, boutique_id)
    if payload.nom is not None:
        boutique.nom = payload.nom
    await db.commit()
    await db.refresh(boutique)
    return boutique
