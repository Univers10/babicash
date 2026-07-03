"""Service de gestion des abonnements et quotas freemium."""
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Abonnement, Vente

_QUOTA_FREE = 20
_QUOTA_PRO = 999_999  # illimité en pratique


async def get_or_create_abonnement(
    db: AsyncSession, boutique_id: uuid.UUID
) -> Abonnement:
    """Retourne l'abonnement de la boutique, en crée un FREE si absent."""
    abo = (
        await db.execute(
            select(Abonnement).where(Abonnement.boutique_id == boutique_id)
        )
    ).scalar_one_or_none()

    if abo is None:
        abo = Abonnement(
            boutique_id=boutique_id,
            plan="FREE",
            quota_ventes_mois=_QUOTA_FREE,
        )
        db.add(abo)
        await db.flush()

    return abo


async def compter_ventes_mois(
    db: AsyncSession, boutique_id: uuid.UUID
) -> int:
    """Compte les ventes du mois calendaire en cours pour cette boutique."""
    now = datetime.now(timezone.utc)
    debut_mois = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    count = (
        await db.execute(
            select(func.count(Vente.id)).where(
                Vente.boutique_id == boutique_id,
                Vente.date_vente >= debut_mois,
            )
        )
    ).scalar_one()

    return int(count)


async def verifier_quota(
    db: AsyncSession, boutique_id: uuid.UUID, nb_nouvelles_ventes: int = 1
) -> tuple[bool, "Abonnement", int]:
    """
    Vérifie si la boutique peut encore créer nb_nouvelles_ventes ventes.
    Retourne (autorise, abonnement, ventes_utilisees_ce_mois).
    """
    abo = await get_or_create_abonnement(db, boutique_id)

    # Plan PRO actif : toujours autorisé
    if abo.plan == "PRO" and abo.actif:
        if abo.date_fin is None or abo.date_fin > datetime.now(timezone.utc):
            return True, abo, 0

    # Plan FREE expiré → repasse en FREE standard
    if not abo.actif:
        return False, abo, 0

    ventes_mois = await compter_ventes_mois(db, boutique_id)
    autorise = (ventes_mois + nb_nouvelles_ventes) <= abo.quota_ventes_mois

    return autorise, abo, ventes_mois


async def upgrader_plan(
    db: AsyncSession,
    boutique_id: uuid.UUID,
    plan: str,
    date_fin: datetime | None = None,
) -> Abonnement:
    """Passe la boutique en plan PRO (ou redescend en FREE)."""
    abo = await get_or_create_abonnement(db, boutique_id)
    abo.plan = plan
    abo.quota_ventes_mois = _QUOTA_PRO if plan == "PRO" else _QUOTA_FREE
    abo.date_fin = date_fin
    abo.actif = True
    await db.commit()
    await db.refresh(abo)
    return abo
