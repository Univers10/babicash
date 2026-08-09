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
    nb_boutiques_max: int
    nb_gerants_max: int
    prix_total_mensuel: Decimal
    date_fin: datetime | None
    actif: bool


class UpgradeRequest(BaseModel):
    plan: str = Field(pattern="^(FREE|KIOSQUE|BOUTIQUE|COMMERCE|ENTREPRISE|EMPIRE)$")
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
        nb_boutiques_max=abo.nb_boutiques_max,
        nb_gerants_max=abo.nb_gerants_max,
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
    """Retourne le quota utilisé pour une boutique donnée.

    Pour l'essai FREE sans parrainage, les ventes sont comptées sur
    l'ensemble de la vie du compte (pas seulement le mois), car l'essai est
    limité en nombre total de ventes plutôt qu'en durée.
    """
    boutique = await get_authorized_boutique(db, current_user, boutique_id)
    abo = await abonnement_service.get_or_create_abonnement(db, boutique.proprietaire_id)
    ventes_mois = await abonnement_service.compter_ventes_mois(db, boutique_id)

    pro_actif = abonnement_service.est_pro_actif(abo)
    essai_chronometre = abo.plan == "FREE" and abo.date_fin is not None
    essai_par_ventes = abo.plan == "FREE" and abo.date_fin is None

    jours_essai_restant = None
    if essai_chronometre:
        jours_essai_restant = max(
            0, (abo.date_fin.replace(tzinfo=None) - abonnement_service._maintenant()).days
        )

    ventes_comptees = (
        await abonnement_service.compter_ventes_totales(db, boutique.proprietaire_id)
        if essai_par_ventes
        else ventes_mois
    )

    illimite = pro_actif or essai_chronometre
    ventes_restantes = (
        None if illimite else max(0, abo.quota_ventes_par_boutique - ventes_comptees)
    )

    return {
        "boutique_id": str(boutique_id),
        "plan": abo.plan,
        "quota_par_boutique": abo.quota_ventes_par_boutique,
        "ventes_ce_mois": ventes_comptees,
        "ventes_restantes": ventes_restantes,
        "illimite": illimite,
        "jours_essai_restant": jours_essai_restant,
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
        nb_boutiques_max=abo.nb_boutiques_max,
        nb_gerants_max=abo.nb_gerants_max,
        prix_total_mensuel=prix_total,
        date_fin=abo.date_fin,
        actif=abo.actif,
    )
