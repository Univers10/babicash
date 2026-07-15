"""Service de gestion des abonnements et quotas freemium (multi-boutique)."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Abonnement, Boutique, Vente

_UNLIMITED = 2_147_483_647  # sentinel pour "illimité"

# Catalogue des plans — doit correspondre au frontend plan_catalog.dart
PLAN_CATALOG: dict[str, dict] = {
    "FREE": {
        "prix_base": Decimal("0.00"),
        "quota_ventes": 20,
        "nb_boutiques_max": 1,
        "nb_gerants_max": 1,
    },
    "KIOSQUE": {
        "prix_base": Decimal("2000.00"),
        "quota_ventes": 200,
        "nb_boutiques_max": 1,
        "nb_gerants_max": 1,
    },
    "BOUTIQUE": {
        "prix_base": Decimal("5000.00"),
        "quota_ventes": _UNLIMITED,
        "nb_boutiques_max": 1,
        "nb_gerants_max": 3,
    },
    "COMMERCE": {
        "prix_base": Decimal("10000.00"),
        "quota_ventes": _UNLIMITED,
        "nb_boutiques_max": 3,
        "nb_gerants_max": 6,
    },
    "ENTREPRISE": {
        "prix_base": Decimal("15000.00"),
        "quota_ventes": _UNLIMITED,
        "nb_boutiques_max": 6,
        "nb_gerants_max": 12,
    },
    "EMPIRE": {
        "prix_base": Decimal("20000.00"),
        "quota_ventes": _UNLIMITED,
        "nb_boutiques_max": _UNLIMITED,
        "nb_gerants_max": _UNLIMITED,
    },
}

_VALID_PLANS = set(PLAN_CATALOG.keys())
_QUOTA_FREE = PLAN_CATALOG["FREE"]["quota_ventes"]
_REMISE_MULTI = Decimal("0.75")  # chaque boutique supplémentaire = 75% du prix de base


def _maintenant() -> datetime:
    """Retourne maintenant en UTC. Si la colonne date_fin est naive, on compare naive."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _est_expire(abo: Abonnement) -> bool:
    """Vérifie si l'abonnement payant a une date d'expiration dépassée."""
    if abo.plan == "FREE" or not abo.actif or abo.date_fin is None:
        return False
    now = _maintenant()
    df = abo.date_fin
    if df.tzinfo is not None and now.tzinfo is None:
        df = df.replace(tzinfo=None)
    return df <= now


def est_pro_actif(abo: Abonnement) -> bool:
    """Plan payant actif et non expiré (tous plans sauf FREE)."""
    return abo.plan != "FREE" and abo.plan in _VALID_PLANS and abo.actif and not _est_expire(abo)


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
        cfg = PLAN_CATALOG["FREE"]
        abo = Abonnement(
            proprietaire_id=proprietaire_id,
            plan="FREE",
            prix_base=cfg["prix_base"],
            quota_ventes_par_boutique=cfg["quota_ventes"],
            nb_boutiques_max=cfg["nb_boutiques_max"],
            nb_gerants_max=cfg["nb_gerants_max"],
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
    un plan payant actif (et non expiré) est requis.
    Retourne (autorise, abonnement, nb_boutiques_actuelles).
    """
    abo = await get_or_create_abonnement(db, proprietaire_id)
    nb_boutiques = await compter_boutiques_owner(db, proprietaire_id)

    if nb_boutiques == 0:
        return True, abo, nb_boutiques

    pro_actif = est_pro_actif(abo)
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
    """Change le plan de l'OWNER (upgrade ou downgrade)."""
    if plan not in _VALID_PLANS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Plan invalide : '{plan}'. Valeurs acceptées : {sorted(_VALID_PLANS)}",
        )

    abo = await get_or_create_abonnement(db, proprietaire_id)
    cfg = PLAN_CATALOG[plan]

    # Protection downgrade : vérifier si le downgrade est possible
    if plan == "FREE" and abo.plan != "FREE":
        nb_boutiques = await compter_boutiques_owner(db, proprietaire_id)
        if nb_boutiques > cfg["nb_boutiques_max"]:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={
                    "code": "DOWNGRADE_BLOQUE",
                    "message": (
                        f"Vous avez {nb_boutiques} boutiques. "
                        f"Le plan {plan} limite à {cfg['nb_boutiques_max']} boutique(s). "
                        "Supprimez les boutiques supplémentaires avant de redescendre."
                    ),
                    "nb_boutiques": nb_boutiques,
                },
            )
        if cfg["quota_ventes"] != _UNLIMITED:
            boutiques = (
                await db.execute(
                    select(Boutique.id).where(Boutique.proprietaire_id == proprietaire_id)
                )
            ).scalars().all()
            for bid in boutiques:
                count = await compter_ventes_mois(db, bid)
                if count > cfg["quota_ventes"]:
                    raise HTTPException(
                        status_code=status.HTTP_409_CONFLICT,
                        detail={
                            "code": "DOWNGRADE_VENTES",
                            "message": (
                                f"Une de vos boutiques a déjà {count} ventes ce mois. "
                                f"Le plan {plan} limite à {cfg['quota_ventes']} ventes/mois. "
                                "Attendez le prochain mois ou choisissez un plan supérieur."
                            ),
                            "ventes_mois": count,
                            "quota_plan": cfg["quota_ventes"],
                        },
                    )

    # Protection downgrade inter-plans payants
    if plan != "FREE" and abo.plan != "FREE" and plan != abo.plan:
        old_idx = list(_VALID_PLANS).index(abo.plan)
        new_idx = list(_VALID_PLANS).index(plan)
        if new_idx < old_idx:
            nb_boutiques = await compter_boutiques_owner(db, proprietaire_id)
            if nb_boutiques > cfg["nb_boutiques_max"]:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail={
                        "code": "DOWNGRADE_BLOQUE",
                        "message": (
                            f"Vous avez {nb_boutiques} boutiques. "
                            f"Le plan {plan} limite à {cfg['nb_boutiques_max']} boutique(s)."
                        ),
                        "nb_boutiques": nb_boutiques,
                    },
                )

    abo.plan = plan
    abo.prix_base = cfg["prix_base"]
    abo.quota_ventes_par_boutique = cfg["quota_ventes"]
    abo.nb_boutiques_max = cfg["nb_boutiques_max"]
    abo.nb_gerants_max = cfg["nb_gerants_max"]
    abo.date_fin = date_fin
    abo.actif = True
    await db.commit()
    await db.refresh(abo)
    return abo
