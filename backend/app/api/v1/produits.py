import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.models import Produit
from app.schemas.auth import CurrentUser
from app.schemas.crud import ProduitCreate, ProduitOut, ProduitUpdate

router = APIRouter()


async def _get_produit_owned(
    db: AsyncSession, current_user: CurrentUser, produit_id: uuid.UUID
) -> Produit:
    produit = await db.get(Produit, produit_id)
    if produit is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Produit introuvable"
        )
    await get_authorized_boutique(db, current_user, produit.boutique_id)
    return produit


@router.get("/", response_model=list[ProduitOut])
async def list_produits(
    boutique_id: uuid.UUID = Query(...),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[Produit]:
    await get_authorized_boutique(db, current_user, boutique_id)
    rows = (
        (
            await db.execute(
                select(Produit)
                .where(Produit.boutique_id == boutique_id)
                .order_by(Produit.nom)
                .limit(limit)
                .offset(offset)
            )
        )
        .scalars()
        .all()
    )
    return list(rows)


@router.post("/", response_model=ProduitOut, status_code=status.HTTP_201_CREATED)
async def create_produit(
    payload: ProduitCreate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Produit:
    await get_authorized_boutique(db, current_user, payload.boutique_id)
    produit = Produit(
        boutique_id=payload.boutique_id,
        categorie_id=payload.categorie_id,
        nom=payload.nom,
        prix_achat_moyen=payload.prix_achat_moyen,
        prix_vente_suggere=payload.prix_vente_suggere,
        stock_actuel=payload.stock_actuel,
        stock_alerte=payload.stock_alerte,
        image_url=payload.image_url,
    )
    db.add(produit)
    await db.commit()
    await db.refresh(produit)
    return produit


@router.patch("/{produit_id}", response_model=ProduitOut)
async def update_produit(
    produit_id: uuid.UUID,
    payload: ProduitUpdate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Produit:
    produit = await _get_produit_owned(db, current_user, produit_id)
    data = payload.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(produit, field, value)
    await db.commit()
    await db.refresh(produit)
    return produit


@router.delete("/{produit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_produit(
    produit_id: uuid.UUID,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> None:
    produit = await _get_produit_owned(db, current_user, produit_id)
    await db.delete(produit)
    await db.commit()
