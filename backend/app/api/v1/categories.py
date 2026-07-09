import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.models import Categorie, Produit
from app.schemas.auth import CurrentUser
from app.schemas.crud import CategorieCreate, CategorieOut, CategorieUpdate

router = APIRouter()


@router.get("/", response_model=list[CategorieOut])
async def list_categories(
    boutique_id: uuid.UUID = Query(...),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[Categorie]:
    await get_authorized_boutique(db, current_user, boutique_id)
    rows = (
        (
            await db.execute(
                select(Categorie)
                .where(Categorie.boutique_id == boutique_id)
                .order_by(Categorie.nom)
            )
        )
        .scalars()
        .all()
    )
    return list(rows)


@router.post("/", response_model=CategorieOut, status_code=status.HTTP_201_CREATED)
async def create_categorie(
    payload: CategorieCreate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Categorie:
    await get_authorized_boutique(db, current_user, payload.boutique_id)
    categorie = Categorie(boutique_id=payload.boutique_id, nom=payload.nom)
    db.add(categorie)
    await db.commit()
    await db.refresh(categorie)
    return categorie


@router.patch("/{categorie_id}", response_model=CategorieOut)
async def update_categorie(
    categorie_id: uuid.UUID,
    payload: CategorieUpdate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Categorie:
    categorie = await db.get(Categorie, categorie_id)
    if categorie is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Catégorie introuvable"
        )
    await get_authorized_boutique(db, current_user, categorie.boutique_id)
    if payload.nom is not None:
        categorie.nom = payload.nom
    await db.commit()
    await db.refresh(categorie)
    return categorie


@router.delete("/{categorie_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_categorie(
    categorie_id: uuid.UUID,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> None:
    categorie = await db.get(Categorie, categorie_id)
    if categorie is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Catégorie introuvable"
        )
    await get_authorized_boutique(db, current_user, categorie.boutique_id)

    # Vérifier si des produits utilisent cette catégorie
    count = (
        await db.execute(
            select(func.count()).where(Produit.categorie_id == categorie_id)
        )
    ).scalar_one()
    if count > 0:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Impossible de supprimer : {count} produit(s) utilisent cette catégorie. Déplacez-les d'abord.",
        )

    await db.delete(categorie)
    await db.commit()
