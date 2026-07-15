import uuid
from datetime import datetime
from decimal import Decimal

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.schemas.auth import CurrentUser
from app.services import abonnement_service

router = APIRouter()


class AbonnementOut(BaseModel):
    proprietaire_id: str
    plan: str
    quota_ventes_par_boutique: int
    prix_base: Decimal
    nb_boutiques: int
    prix_total_mensuel: Decimal  # prix_base * (1 + 0.75 * (nb_boutiques - 1))
    date_fin: datetime | None
    actif: bool


class UpgradeRequest(BaseModel):
    plan: str = Field(pattern="^(FREE|PRO)$")
    date_fin: datetime | None = None


@router.get("/mon-plan", response_model=AbonnementOut)
async def get_mon_abonnement(
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> AbonnementOut:
    """Retourne l'état de l'abonnement du propriétaire connecté."""
    abo = await abonnement_service.get_or_create_abonnement(db, current_user.id)
    nb_boutiques = await abonnement_service.compter_boutiques_owner(db, current_user.id)
    prix_total = abonnement_service.calculer_prix_total(abo.prix_base, nb_boutiques)

    return AbonnementOut(
        proprietaire_id=abo.proprietaire_id,
        plan=abo.plan,
        quota_ventes_par_boutique=abo.quota_ventes_par_boutique,
        prix_base=abo.prix_base,
        nb_boutiques=nb_boutiques,
        prix_total_mensuel=prix_total,
        date_fin=abo.date_fin,
        actif=abo.actif,
    )


@router.get("/quota/{boutique_id}")
async def get_quota_boutique(
    boutique_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Retourne le quota utilisé ce mois pour une boutique donnée."""
    await get_authorized_boutique(db, current_user, boutique_id)
    abo = await abonnement_service.get_or_create_abonnement(db, current_user.id)
    ventes_mois = await abonnement_service.compter_ventes_mois(db, boutique_id)

    pro_actif = abonnement_service.est_pro_actif(abo)

    return {
        "boutique_id": str(boutique_id),
        "plan": abo.plan,
        "quota_par_boutique": abo.quota_ventes_par_boutique,
        "ventes_ce_mois": ventes_mois,
        "ventes_restantes": None if pro_actif else max(0, abo.quota_ventes_par_boutique - ventes_mois),
        "illimite": pro_actif,
    }


@router.post("/upgrade", response_model=AbonnementOut)
async def upgrade_abonnement(
    payload: UpgradeRequest,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> AbonnementOut:
    """Upgrade ou downgrade le plan de l'OWNER (couvre toutes ses boutiques)."""
    abo = await abonnement_service.upgrader_plan(
        db, current_user.id, payload.plan, payload.date_fin
    )
    nb_boutiques = await abonnement_service.compter_boutiques_owner(db, current_user.id)
    prix_total = abonnement_service.calculer_prix_total(abo.prix_base, nb_boutiques)

    return AbonnementOut(
        proprietaire_id=abo.proprietaire_id,
        plan=abo.plan,
        quota_ventes_par_boutique=abo.quota_ventes_par_boutique,
        prix_base=abo.prix_base,
        nb_boutiques=nb_boutiques,
        prix_total_mensuel=prix_total,
        date_fin=abo.date_fin,
        actif=abo.actif,
    )
