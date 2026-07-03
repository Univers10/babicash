import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.schemas.auth import CurrentUser
from app.services import dashboard_service

router = APIRouter()

_GRANULARITES = {"jour", "semaine", "mois"}


def _valider_granularite(granularite: str) -> str:
    if granularite not in _GRANULARITES:
        granularite = "mois"
    return granularite


@router.get("/ca/{boutique_id}")
async def get_ca(
    boutique_id: uuid.UUID,
    granularite: str = Query("mois", description="jour | semaine | mois"),
    date_debut: datetime | None = Query(None),
    date_fin: datetime | None = Query(None),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Chiffre d'affaires, marge et nombre de ventes sur la période."""
    await get_authorized_boutique(db, current_user, boutique_id)
    return await dashboard_service.chiffre_affaires(
        db, boutique_id, _valider_granularite(granularite), date_debut, date_fin
    )


@router.get("/caisse/{boutique_id}")
async def get_caisse(
    boutique_id: uuid.UUID,
    granularite: str = Query("mois", description="jour | semaine | mois"),
    date_debut: datetime | None = Query(None),
    date_fin: datetime | None = Query(None),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Résumé de caisse : recettes, dépenses, solde net."""
    await get_authorized_boutique(db, current_user, boutique_id)
    return await dashboard_service.resume_caisse(
        db, boutique_id, _valider_granularite(granularite), date_debut, date_fin
    )


@router.get("/dettes/{boutique_id}")
async def get_dettes(
    boutique_id: uuid.UUID,
    type_tiers: str | None = Query(None, description="CLIENT | FOURNISSEUR"),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Dettes globales clients et/ou fournisseurs."""
    await get_authorized_boutique(db, current_user, boutique_id)
    return await dashboard_service.dettes(db, boutique_id, type_tiers)


@router.get("/debiteurs/{boutique_id}")
async def get_top_debiteurs(
    boutique_id: uuid.UUID,
    type_tiers: str = Query("CLIENT", description="CLIENT | FOURNISSEUR"),
    limite: int = Query(10, ge=1, le=50),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list:
    """Top débiteurs triés par montant dû."""
    await get_authorized_boutique(db, current_user, boutique_id)
    return await dashboard_service.top_debiteurs(db, boutique_id, type_tiers, limite)


@router.get("/stock/{boutique_id}")
async def get_etat_stock(
    boutique_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """État du stock : valeur totale, ruptures, alertes."""
    await get_authorized_boutique(db, current_user, boutique_id)
    return await dashboard_service.etat_stock(db, boutique_id)


@router.get("/consolide")
async def get_consolide(
    granularite: str = Query("mois", description="jour | semaine | mois"),
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Vue consolidée CA + marge sur toutes les boutiques de l'OWNER."""
    return await dashboard_service.consolide_owner(
        db, current_user.id, _valider_granularite(granularite)
    )
