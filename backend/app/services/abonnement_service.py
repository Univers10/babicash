"""Service de gestion des abonnements et quotas freemium (multi-boutique)."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Abonnement, Boutique, Vente

_VALID_PLANS = {"FREE", "PRO"}
_QUOTA_FREE = 20
_PRIX_BASE = Decimal("5000.00")   # FCFA/mois pour la 1ère boutique
_REMISE_MULTI = Decimal("0.75")   # chaque boutique supplémentaire = 75% du prix de base


def _maintenant() -> datetime:
    """Retourne maintenant en UTC. Si la colonne date_fin est naive, on compare naive."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _est_expire(abo: Abonnement) -> bool:
    """Vérifie si l'abonnement PRO a une date d'expiration dépassée."""
    if abo.plan != "PRO" or not abo.actif or abo.date_fin is None:
        return False
    now = _maintenant()
    df = abo.date_fin
    # Normaliser : si l'un est aware et l'autre naive, on retire le tzinfo
    if df.tzinfo is not None and now.tzinfo is None:
        df = df.replace(tzinfo=None)
    return df <= now


def est_pro_actif(abo: Abonnement) -> bool:
    """PRO actif et non expiré. Passe par _est_expire pour gérer naive/aware."""
    return abo.plan == "PRO" and abo.actif and not _est_expire(abo)


async def _revertir_si_expire(db: AsyncSession, abo: Abonnement) -> Abonnement:
    """Révertit automatiquement un abonnement PRO expiré vers FREE.
    Retourne l'abonnement potentiellement modifié (et flush si changement)."""
    if _est_expire(abo):
        abo.plan = "FREE"
        abo.quota_ventes_par_boutique = _QUOTA_FREE
        abo.actif = True
        await db.flush()
    return abo


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

    await _revertir_si_expire(db, abo)

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


async def peut_creer_boutique(
    db: AsyncSession, proprietaire_id: str
) -> tuple[bool, Abonnement, int]:
    """Vérifie si le propriétaire peut créer une boutique supplémentaire.

    La 1ère boutique est incluse dans tous les plans. À partir de la 2e,
    un abonnement PRO actif (et non expiré) est requis.
    Retourne (autorise, abonnement, nb_boutiques_actuelles).
    """
    abo = await get_or_create_abonnement(db, proprietaire_id)
    nb_boutiques = await compter_boutiques_owner(db, proprietaire_id)

    if nb_boutiques == 0:
        return True, abo, nb_boutiques

    pro_actif = abo.plan == "PRO" and abo.actif and (
        abo.date_fin is None or abo.date_fin > datetime.now(timezone.utc)
    )
    return pro_actif, abo, nb_boutiques


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

    ventes_mois = await compter_ventes_mois(db, boutique_id)

    # Plan PRO actif et non expiré : toujours autorisé
    if est_pro_actif(abo):
        return True, abo, ventes_mois

    if not abo.actif:
        return False, abo, ventes_mois

    autorise = (ventes_mois + nb_nouvelles_ventes) <= abo.quota_ventes_par_boutique

    return autorise, abo, ventes_mois


async def upgrader_plan(
    db: AsyncSession,
    proprietaire_id: str,
    plan: str,
    date_fin: datetime | None = None,
) -> Abonnement:
    """Passe l'OWNER en plan PRO (ou redescend en FREE)."""
    if plan not in _VALID_PLANS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Plan invalide : '{plan}'. Valeurs acceptées : {sorted(_VALID_PLANS)}",
        )

    abo = await get_or_create_abonnement(db, proprietaire_id)

    # Protection downgrade : vérifier si le downgrade est possible
    if plan == "FREE" and abo.plan == "PRO":
        nb_boutiques = await compter_boutiques_owner(db, proprietaire_id)
        if nb_boutiques > 1:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={
                    "code": "DOWNGRADE_BLOQUE",
                    "message": (
                        f"Vous avez {nb_boutiques} boutiques. "
                        "Supprimez les boutiques supplémentaires avant de redescendre en plan FREE (1 boutique max)."
                    ),
                    "nb_boutiques": nb_boutiques,
                },
            )
        ventes_mois = 0
        # Vérifier pour chaque boutique si le quota serait dépassé
        boutiques = (
            await db.execute(
                select(Boutique.id).where(Boutique.proprietaire_id == proprietaire_id)
            )
        ).scalars().all()
        for bid in boutiques:
            count = await compter_ventes_mois(db, bid)
            if count > _QUOTA_FREE:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail={
                        "code": "DOWNGRADE_VENTES",
                        "message": (
                            f"Une de vos boutiques a déjà {count} ventes ce mois. "
                            f"Le plan FREE limite à {_QUOTA_FREE} ventes/mois. "
                            "Attendez le prochain mois ou restez en plan PRO."
                        ),
                        "ventes_mois": count,
                        "quota_free": _QUOTA_FREE,
                    },
                )
            ventes_mois = max(ventes_mois, count)

    abo.plan = plan
    abo.quota_ventes_par_boutique = _QUOTA_FREE if plan == "FREE" else 2_147_483_647  # sentinel illimité
    abo.date_fin = date_fin
    abo.actif = True
    await db.commit()
    await db.refresh(abo)
    return abo
