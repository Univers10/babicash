"""Service parrainage : paiements confirmés, commissions et synthèse ambassadeur."""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models import (
    Abonnement,
    Ambassadeur,
    CommissionParrainage,
    PaiementAbonnement,
    Payout,
    User,
)
from app.services import notification_service

TAUX_COMMISSION = Decimal("0.200")
FENETRE_JOURS = 365  # droits de l'ambassadeur : 12 mois après le 1er paiement
_CENT = Decimal("0.01")


def _maintenant() -> datetime:
    """Maintenant en UTC, naïf (cohérent avec les colonnes de la base)."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _naive(dt: datetime) -> datetime:
    return dt.replace(tzinfo=None) if dt.tzinfo is not None else dt


async def _dans_fenetre_droits(db: AsyncSession, proprietaire_id: str) -> bool:
    """Vrai si on est dans les 12 mois suivant le 1er paiement du filleul.

    Le paiement courant venant d'être inséré, ``min(date_paiement)`` renvoie la
    date du tout premier paiement (celui-ci s'il est le premier).
    """
    premier = (
        await db.execute(
            select(func.min(PaiementAbonnement.date_paiement)).where(
                PaiementAbonnement.proprietaire_id == proprietaire_id,
                PaiementAbonnement.montant > 0,
            )
        )
    ).scalar_one_or_none()
    if premier is None:
        return True
    return _maintenant() <= _naive(premier) + timedelta(days=FENETRE_JOURS)


async def _generer_commission(
    db: AsyncSession, paiement: PaiementAbonnement
) -> CommissionParrainage | None:
    """Crée la commission de parrainage liée à un paiement, si éligible."""
    if paiement.plan == "FREE" or paiement.montant is None or paiement.montant <= 0:
        return None

    filleul = await db.get(User, uuid.UUID(paiement.proprietaire_id))
    if filleul is None or filleul.parraine_par_ambassadeur_id is None:
        return None

    ambassadeur = await db.get(Ambassadeur, filleul.parraine_par_ambassadeur_id)
    if ambassadeur is None or not ambassadeur.actif:
        return None

    if not await _dans_fenetre_droits(db, paiement.proprietaire_id):
        return None

    montant_commission = (paiement.montant * TAUX_COMMISSION).quantize(_CENT)
    commission = CommissionParrainage(
        ambassadeur_id=ambassadeur.id,
        filleul_id=filleul.id,
        paiement_id=paiement.id,
        montant_paye=paiement.montant,
        taux=TAUX_COMMISSION,
        montant_commission=montant_commission,
        statut="VALIDEE",
    )
    db.add(commission)
    await db.flush()

    await notification_service.creer_notification(
        db,
        ambassadeur.id,
        notification_service.TYPE_COMMISSION,
        "Nouvelle commission 💰",
        f"Vous avez gagné {montant_commission:.0f} FCFA grâce à {filleul.nom}.",
    )

    return commission


async def confirmer_paiement(
    db: AsyncSession,
    proprietaire_id: str,
    plan: str,
    montant: Decimal,
    *,
    confirme_par: str | uuid.UUID | None = None,
    abonnement_id: uuid.UUID | None = None,
    periode_debut: datetime | None = None,
    periode_fin: datetime | None = None,
) -> PaiementAbonnement:
    """Enregistre un paiement d'abonnement confirmé (par l'admin) et génère la
    commission de parrainage éligible. Primitive réutilisable (renouvellements,
    futur webhook de passerelle, etc.)."""
    if isinstance(confirme_par, str):
        try:
            confirme_par = uuid.UUID(confirme_par)
        except ValueError:
            confirme_par = None

    paiement = PaiementAbonnement(
        proprietaire_id=str(proprietaire_id),
        abonnement_id=abonnement_id,
        plan=plan,
        montant=montant,
        periode_debut=periode_debut or _maintenant(),
        periode_fin=periode_fin,
        confirme_par=confirme_par,
    )
    db.add(paiement)
    await db.flush()

    await _generer_commission(db, paiement)

    await db.commit()
    await db.refresh(paiement)
    return paiement


# ── Lecture (dashboard ambassadeur) ──────────────────────────────────


def _to_decimal(value) -> Decimal:
    return value if isinstance(value, Decimal) else Decimal(str(value or 0))


async def synthese(db: AsyncSession, ambassadeur_id: uuid.UUID) -> dict:
    """Totaux affichés sur l'accueil de l'espace ambassadeur."""
    solde = (
        await db.execute(
            select(func.coalesce(func.sum(CommissionParrainage.montant_commission), 0))
            .where(
                CommissionParrainage.ambassadeur_id == ambassadeur_id,
                CommissionParrainage.statut == "VALIDEE",
                CommissionParrainage.payout_id.is_(None),
            )
        )
    ).scalar_one()

    total = (
        await db.execute(
            select(func.coalesce(func.sum(CommissionParrainage.montant_commission), 0))
            .where(
                CommissionParrainage.ambassadeur_id == ambassadeur_id,
                CommissionParrainage.statut.in_(("VALIDEE", "PAYEE")),
            )
        )
    ).scalar_one()

    nb_filleuls = (
        await db.execute(
            select(func.count(User.id)).where(
                User.parraine_par_ambassadeur_id == ambassadeur_id
            )
        )
    ).scalar_one()

    # « Payant » = filleul ayant généré au moins une commission (proxy fiable,
    # évite une jointure users↔abonnements sur des types de clés différents).
    nb_payants = (
        await db.execute(
            select(func.count(func.distinct(CommissionParrainage.filleul_id))).where(
                CommissionParrainage.ambassadeur_id == ambassadeur_id,
                CommissionParrainage.statut != "ANNULEE",
            )
        )
    ).scalar_one()

    return {
        "solde_a_recevoir": _to_decimal(solde),
        "total_gagne": _to_decimal(total),
        "nb_filleuls": int(nb_filleuls),
        "nb_filleuls_payants": int(nb_payants),
    }


async def lister_filleuls(
    db: AsyncSession,
    ambassadeur_id: uuid.UUID,
    *,
    limit: int = 50,
    offset: int = 0,
) -> list[dict]:
    """Filleuls de l'ambassadeur avec l'état de leur abonnement + commission cumulée."""
    filleuls = (
        await db.execute(
            select(User)
            .where(User.parraine_par_ambassadeur_id == ambassadeur_id)
            .order_by(User.date_creation.desc())
            .limit(limit)
            .offset(offset)
        )
    ).scalars().all()

    resultats: list[dict] = []
    for f in filleuls:
        abo = (
            await db.execute(
                select(Abonnement).where(Abonnement.proprietaire_id == str(f.id))
            )
        ).scalar_one_or_none()
        cumul = (
            await db.execute(
                select(
                    func.coalesce(func.sum(CommissionParrainage.montant_commission), 0)
                ).where(
                    CommissionParrainage.filleul_id == f.id,
                    CommissionParrainage.statut != "ANNULEE",
                )
            )
        ).scalar_one()
        resultats.append(
            {
                "filleul_id": str(f.id),
                "nom": f.nom,
                "plan": abo.plan if abo else "FREE",
                "abonnement_actif": bool(abo.actif) if abo else False,
                "date_inscription": f.date_creation,
                "commission_cumulee": _to_decimal(cumul),
            }
        )
    return resultats


async def lister_commissions(
    db: AsyncSession,
    ambassadeur_id: uuid.UUID,
    *,
    limit: int = 50,
    offset: int = 0,
) -> list[dict]:
    """Historique des commissions (activité, style « transactions »)."""
    rows = (
        await db.execute(
            select(CommissionParrainage, User.nom)
            .join(User, User.id == CommissionParrainage.filleul_id)
            .where(CommissionParrainage.ambassadeur_id == ambassadeur_id)
            .order_by(CommissionParrainage.date_creation.desc())
            .limit(limit)
            .offset(offset)
        )
    ).all()

    return [
        {
            "id": str(c.id),
            "filleul_nom": nom,
            "montant_paye": c.montant_paye,
            "montant_commission": c.montant_commission,
            "statut": c.statut,
            "date_creation": c.date_creation,
        }
        for c, nom in rows
    ]


async def lister_versements(
    db: AsyncSession,
    ambassadeur_id: uuid.UUID,
    *,
    limit: int = 50,
    offset: int = 0,
) -> list[dict]:
    """Historique des lots de versement d'un ambassadeur (récent d'abord)."""
    payouts = (
        await db.execute(
            select(Payout)
            .where(Payout.ambassadeur_id == ambassadeur_id)
            .order_by(Payout.date_creation.desc())
            .limit(limit)
            .offset(offset)
        )
    ).scalars().all()
    return [
        {
            "id": str(p.id),
            "semaine": p.semaine,
            "montant_total": p.montant_total,
            "statut": p.statut,
            "reference_transfert": p.reference_transfert,
            "date_creation": p.date_creation,
            "date_execution": p.date_execution,
        }
        for p in payouts
    ]


# ── Versements hebdomadaires (admin) ─────────────────────────────────


def semaine_courante(dt: datetime | None = None) -> str:
    """Identifiant ISO de la semaine, ex. ``2026-W31``."""
    d = dt or _maintenant()
    iso = d.isocalendar()
    return f"{iso[0]}-W{iso[1]:02d}"


def _mois_courant(dt: datetime | None = None) -> tuple[datetime, datetime]:
    """Borne [début, fin) du mois calendaire courant (UTC)."""
    d = dt or _maintenant()
    debut = d.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    if d.month == 12:
        fin = debut.replace(year=debut.year + 1, month=1)
    else:
        fin = debut.replace(month=debut.month + 1)
    return debut, fin


async def _total_deja_verse_mois(
    db: AsyncSession, ambassadeur_id: uuid.UUID
) -> Decimal:
    """Montant déjà engagé dans le mois calendaire courant.

    Compte les lots ``PAYE`` exécutés dans le mois, plus les lots ``A_PAYER``
    créés dans le mois (déjà engagés, non encore exécutés).
    """
    debut, fin = _mois_courant()
    total = (
        await db.execute(
            select(func.coalesce(func.sum(Payout.montant_total), 0)).where(
                Payout.ambassadeur_id == ambassadeur_id,
                ((Payout.statut == "PAYE") & (Payout.date_execution >= debut) & (Payout.date_execution < fin))
                | ((Payout.statut == "A_PAYER") & (Payout.date_creation >= debut) & (Payout.date_creation < fin)),
            )
        )
    ).scalar_one()
    return _to_decimal(total)


async def generer_payouts_semaine(
    db: AsyncSession,
    *,
    semaine: str | None = None,
    seuil_min: Decimal = Decimal("0"),
) -> list[Payout]:
    """Regroupe les commissions VALIDÉE non versées en lots hebdomadaires.

    Pour chaque ambassadeur ayant un solde ``>= seuil_min`` : trouve (ou crée)
    le lot ``A_PAYER`` de la semaine, y rattache ses commissions non affectées
    et recalcule le montant total. Sous le seuil, le solde est reporté.
    """
    semaine = semaine or semaine_courante()

    soldes = (
        await db.execute(
            select(
                CommissionParrainage.ambassadeur_id,
                func.coalesce(func.sum(CommissionParrainage.montant_commission), 0),
            )
            .where(
                CommissionParrainage.statut == "VALIDEE",
                CommissionParrainage.payout_id.is_(None),
            )
            .group_by(CommissionParrainage.ambassadeur_id)
        )
    ).all()

    lots: list[Payout] = []
    for ambassadeur_id, montant in soldes:
        montant = _to_decimal(montant)
        if montant <= 0 or montant < seuil_min:
            continue

        amb = await db.get(Ambassadeur, ambassadeur_id)
        plafond_restant: Decimal | None = None
        if amb is not None and not amb.valide:
            deja_verse = await _total_deja_verse_mois(db, ambassadeur_id)
            plafond_restant = max(
                settings.AMBASSADEUR_PLAFOND_MENSUEL - deja_verse, Decimal("0")
            )
            if plafond_restant <= 0:
                continue

        en_attente = (
            await db.execute(
                select(CommissionParrainage)
                .where(
                    CommissionParrainage.ambassadeur_id == ambassadeur_id,
                    CommissionParrainage.statut == "VALIDEE",
                    CommissionParrainage.payout_id.is_(None),
                )
                .order_by(CommissionParrainage.date_creation.asc())
            )
        ).scalars().all()
        if not en_attente:
            continue

        payout = (
            await db.execute(
                select(Payout).where(
                    Payout.ambassadeur_id == ambassadeur_id,
                    Payout.semaine == semaine,
                    Payout.statut == "A_PAYER",
                )
            )
        ).scalar_one_or_none()
        if payout is None:
            payout = Payout(
                ambassadeur_id=ambassadeur_id,
                semaine=semaine,
                montant_total=Decimal("0.00"),
                momo_numero=amb.momo_numero if amb else "",
                statut="A_PAYER",
            )
            db.add(payout)
            await db.flush()

        # Rattache les commissions en attente, dans l'ordre, jusqu'au plafond
        # mensuel restant (compte non validé) ou en totalité (compte validé).
        montant_lot = Decimal("0.00")
        for c in en_attente:
            if (
                plafond_restant is not None
                and montant_lot + c.montant_commission > plafond_restant
            ):
                break
            c.payout_id = payout.id
            montant_lot += c.montant_commission

        if montant_lot <= 0:
            continue

        await db.flush()
        total = (
            await db.execute(
                select(
                    func.coalesce(func.sum(CommissionParrainage.montant_commission), 0)
                ).where(CommissionParrainage.payout_id == payout.id)
            )
        ).scalar_one()
        payout.montant_total = _to_decimal(total)
        lots.append(payout)

    await db.commit()
    return lots


async def marquer_payout_paye(
    db: AsyncSession,
    payout_id: uuid.UUID,
    reference_transfert: str | None = None,
) -> Payout | None:
    """Marque un lot comme payé et bascule ses commissions en ``PAYEE``."""
    payout = await db.get(Payout, payout_id)
    if payout is None or payout.statut == "PAYE":
        return payout

    payout.statut = "PAYE"
    payout.date_execution = _maintenant()
    if reference_transfert:
        payout.reference_transfert = reference_transfert

    await db.execute(
        update(CommissionParrainage)
        .where(
            CommissionParrainage.payout_id == payout.id,
            CommissionParrainage.statut == "VALIDEE",
        )
        .values(statut="PAYEE")
    )

    await notification_service.creer_notification(
        db,
        payout.ambassadeur_id,
        notification_service.TYPE_VERSEMENT,
        "Versement reçu 💸",
        f"Votre versement de {payout.montant_total:.0f} FCFA pour la semaine "
        f"{payout.semaine} a été effectué.",
    )

    await db.commit()
    await db.refresh(payout)
    return payout


async def lister_ambassadeurs_admin(db: AsyncSession) -> list[dict]:
    """Liste des ambassadeurs avec leurs agrégats, pour le backoffice admin."""
    ambs = (
        await db.execute(
            select(Ambassadeur).order_by(Ambassadeur.date_creation.desc())
        )
    ).scalars().all()

    resultats: list[dict] = []
    for a in ambs:
        user = await db.get(User, a.user_id)
        agg = await synthese(db, a.id)
        resultats.append({"ambassadeur": a, "user": user, **agg})
    return resultats
