import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user
from app.models import CompteTiers
from app.schemas.auth import CurrentUser
from app.schemas.crud import (
    CompteTiersCreate,
    CompteTiersOut,
    CompteTiersUpdate,
    PaiementTiersRequest,
)

router = APIRouter()


async def _get_tiers_owned(
    db: AsyncSession, current_user: CurrentUser, tier_id: uuid.UUID
) -> CompteTiers:
    tier = await db.get(CompteTiers, tier_id)
    if tier is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Compte tiers introuvable"
        )
    await get_authorized_boutique(db, current_user, tier.boutique_id)
    return tier


@router.get("/", response_model=list[CompteTiersOut])
async def list_tiers(
    boutique_id: uuid.UUID = Query(...),
    type_tiers: str | None = Query(None, pattern="^(CLIENT|FOURNISSEUR)$"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[CompteTiers]:
    await get_authorized_boutique(db, current_user, boutique_id)
    stmt = select(CompteTiers).where(CompteTiers.boutique_id == boutique_id)
    if type_tiers is not None:
        stmt = stmt.where(CompteTiers.type_tiers == type_tiers)
    stmt = stmt.order_by(CompteTiers.nom).limit(limit).offset(offset)
    rows = (await db.execute(stmt)).scalars().all()
    return list(rows)


@router.post(
    "/", response_model=CompteTiersOut, status_code=status.HTTP_201_CREATED
)
async def create_tiers(
    payload: CompteTiersCreate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CompteTiers:
    # OWNER et MANAGER (verrouillé sur sa boutique) peuvent créer un tiers
    await get_authorized_boutique(db, current_user, payload.boutique_id)
    if payload.telephone:
        existing = (
            await db.execute(
                select(CompteTiers).where(
                    and_(
                        CompteTiers.boutique_id == payload.boutique_id,
                        CompteTiers.telephone == payload.telephone,
                    )
                )
            )
        ).scalar_one_or_none()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Un client avec le numéro {payload.telephone} existe déjà.",
            )
    tier = CompteTiers(
        boutique_id=payload.boutique_id,
        nom=payload.nom,
        telephone=payload.telephone,
        type_tiers=payload.type_tiers,
    )
    db.add(tier)
    await db.commit()
    await db.refresh(tier)
    return tier


@router.patch("/{tier_id}", response_model=CompteTiersOut)
async def update_tiers(
    tier_id: uuid.UUID,
    payload: CompteTiersUpdate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CompteTiers:
    tier = await _get_tiers_owned(db, current_user, tier_id)
    if payload.nom is not None:
        tier.nom = payload.nom
    if payload.telephone is not None:
        tier.telephone = payload.telephone
    await db.commit()
    await db.refresh(tier)
    return tier


@router.post("/{tier_id}/paiement", response_model=CompteTiersOut)
async def enregistrer_paiement(
    tier_id: uuid.UUID,
    payload: PaiementTiersRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CompteTiers:
    """Enregistre un remboursement client ou un paiement fournisseur.
    Réduit le solde_du du montant indiqué, sans jamais descendre sous zéro.
    """
    tier = await _get_tiers_owned(db, current_user, tier_id)

    if tier.solde_du <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ce compte n'a pas de solde dû à solder.",
        )

    # On ne peut pas rembourser plus que le solde dû
    montant_applique = min(payload.montant, tier.solde_du)
    tier.solde_du -= montant_applique

    await db.commit()
    await db.refresh(tier)
    return tier
