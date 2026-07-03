"""Service de gestion des abonnements et quotas freemium (multi-boutique)."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Abonnement, Boutique, Vente

_QUOTA_FREE = 20
_PRIX_BASE = Decimal("5000.00")   # FCFA/mois pour la 1ère boutique
_REMISE_MULTI = Decimal("0.75")   # chaque boutique supplémentaire = 75% du prix de base


def calculer_prix_total(prix_base: Decimal, nb_boutiques: int) -> Decimal:
    """
    Prix mensuel selon nombre de boutiques actives :
      1 boutique  → prix_base
      2 boutiques → prix_base + prix_base * 0.75
      N boutiques → prix_base * (1 + 0.75 * (N-1))
    """
    if nb_boutiques <= 0:
        return Decimal("0.00")
    return prix_base * (1 + _REMISE_MULTI * (nb_boutiques - 1))


async def get_or_create_abonnement(
    db: AsyncSession, proprietaire_id: str
) -> Abonnement:
    """Retourne l'abonnement du propriétaire, en crée un FREE si absent."""
    abo = (
        await db.execute(
            select(Abonnement).where(Abonnement.proprietaire_id == proprietaire_id)
        )
    ).scalar_one_or_none()

    if abo is None:
        abo = Abonnement(
            proprietaire_id=proprietaire_id,
            plan="FREE",
            prix_base=_PRIX_BASE,
            quota_ventes_par_boutique=_QUOTA_FREE,
        )
        db.add(abo)
        await db.flush()

    return abo


async def compter_boutiques_owner(
    db: AsyncSession, proprietaire_id: str
) -> int:
    """Compte les boutiques actives d'un propriétaire."""
    count = (
        await db.execute(
            select(func.count(Boutique.id)).where(
                Boutique.proprietaire_id == proprietaire_id
            )
        )
    ).scalar_one()
    return int(count)


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
    db: AsyncSession,
    boutique_id: uuid.UUID,
    proprietaire_id: str,
    nb_nouvelles_ventes: int = 1,
) -> tuple[bool, Abonnement, int]:
    """
    Vérifie si la boutique peut encore créer nb_nouvelles_ventes ventes.
    Retourne (autorise, abonnement, ventes_utilisees_ce_mois).
    """
    abo = await get_or_create_abonnement(db, proprietaire_id)

    # Plan PRO actif et non expiré : toujours autorisé
    if abo.plan == "PRO" and abo.actif:
        if abo.date_fin is None or abo.date_fin > datetime.now(timezone.utc):
            return True, abo, 0

    if not abo.actif:
        return False, abo, 0

    ventes_mois = await compter_ventes_mois(db, boutique_id)
    autorise = (ventes_mois + nb_nouvelles_ventes) <= abo.quota_ventes_par_boutique

    return autorise, abo, ventes_mois


async def upgrader_plan(
    db: AsyncSession,
    proprietaire_id: str,
    plan: str,
    date_fin: datetime | None = None,
) -> Abonnement:
    """Passe l'OWNER en plan PRO (ou redescend en FREE)."""
    abo = await get_or_create_abonnement(db, proprietaire_id)
    abo.plan = plan
    abo.quota_ventes_par_boutique = 999_999 if plan == "PRO" else _QUOTA_FREE
    abo.date_fin = date_fin
    abo.actif = True
    await db.commit()
    await db.refresh(abo)
    return abo
