"""Analytics admin : séries temporelles (revenus, inscriptions, ventes, ambassadeurs).

Les agrégations sont faites en Python (pas en SQL `date_trunc`) pour rester
compatibles à la fois avec PostgreSQL (production) et SQLite (tests).
"""
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import (
    CommissionParrainage,
    PaiementAbonnement,
    Payout,
    User,
    Vente,
)

MAX_MOIS = 36
MAX_ANNEES = 6
_NOMS_MOIS = ["Jan", "Fév", "Mar", "Avr", "Mai", "Jun", "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc"]


def _naive(dt: datetime) -> datetime:
    return dt.replace(tzinfo=None) if dt.tzinfo is not None else dt


def _cle_periode(dt: datetime, granularite: str) -> str:
    if granularite == "annee":
        return str(dt.year)
    return f"{dt.year}-{dt.month:02d}"


def _label_periode(cle: str, granularite: str) -> str:
    if granularite == "annee":
        return cle
    annee, mois = cle.split("-")
    return f"{_NOMS_MOIS[int(mois) - 1]} {annee}"


def _periodes(granularite: str, nb: int) -> list[str]:
    """Liste ordonnée des `nb` dernières périodes (clés), la plus ancienne en premier."""
    now = datetime.now(timezone.utc)
    if granularite == "annee":
        return [str(now.year - i) for i in range(nb - 1, -1, -1)]
    cles = []
    y, m = now.year, now.month
    for i in range(nb - 1, -1, -1):
        mm = m - i
        yy = y
        while mm <= 0:
            mm += 12
            yy -= 1
        cles.append(f"{yy}-{mm:02d}")
    return cles


def _borne_debut(granularite: str, nb: int) -> datetime:
    """Date de début (naïve) couvrant les `nb` dernières périodes."""
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    if granularite == "annee":
        return now.replace(year=now.year - nb + 1, month=1, day=1, hour=0, minute=0, second=0, microsecond=0)
    y, m = now.year, now.month
    mm = m - (nb - 1)
    yy = y
    while mm <= 0:
        mm += 12
        yy -= 1
    return datetime(yy, mm, 1)


def normaliser_params(granularite: str | None, nb: int | None) -> tuple[str, int]:
    """Valide/clamp les paramètres de période acceptés par les endpoints analytics."""
    g = granularite if granularite in ("mois", "annee") else "mois"
    plafond = MAX_ANNEES if g == "annee" else MAX_MOIS
    defaut = 6 if g == "annee" else 12
    n = nb if nb and nb > 0 else defaut
    return g, min(n, plafond)


def _serie(cles: list[str], granularite: str, totaux: dict[str, Decimal | int]) -> dict:
    return {
        "labels": [_label_periode(c, granularite) for c in cles],
        "values": [
            float(totaux[c]) if isinstance(totaux.get(c), Decimal) else totaux.get(c, 0)
            for c in cles
        ],
    }


async def serie_revenus(db: AsyncSession, granularite: str = "mois", nb: int = 12) -> dict:
    """Revenus réels encaissés (paiements d'abonnement confirmés), par période."""
    debut = _borne_debut(granularite, nb)
    rows = (
        await db.execute(
            select(PaiementAbonnement.date_paiement, PaiementAbonnement.montant).where(
                PaiementAbonnement.date_paiement >= debut,
                PaiementAbonnement.montant > 0,
            )
        )
    ).all()
    totaux: dict[str, Decimal] = {}
    for date_paiement, montant in rows:
        cle = _cle_periode(_naive(date_paiement), granularite)
        totaux[cle] = totaux.get(cle, Decimal("0")) + Decimal(str(montant))
    return _serie(_periodes(granularite, nb), granularite, totaux)


async def serie_inscriptions(db: AsyncSession, granularite: str = "mois", nb: int = 12) -> dict:
    """Nouveaux propriétaires (OWNER) inscrits, par période."""
    debut = _borne_debut(granularite, nb)
    rows = (
        await db.execute(
            select(User.date_creation).where(
                User.role == "OWNER", User.date_creation >= debut
            )
        )
    ).all()
    totaux: dict[str, int] = {}
    for (date_creation,) in rows:
        cle = _cle_periode(_naive(date_creation), granularite)
        totaux[cle] = totaux.get(cle, 0) + 1
    return _serie(_periodes(granularite, nb), granularite, totaux)


async def serie_ventes(db: AsyncSession, granularite: str = "mois", nb: int = 12) -> dict:
    """Chiffre d'affaires (toutes boutiques) et nombre de ventes, par période."""
    debut = _borne_debut(granularite, nb)
    rows = (
        await db.execute(
            select(Vente.id, Vente.date_vente, Vente.montant_total).where(
                Vente.date_vente >= debut
            )
        )
    ).all()
    totaux_ca: dict[str, Decimal] = {}
    totaux_nb: dict[str, int] = {}
    for _id, date_vente, montant_total in rows:
        cle = _cle_periode(_naive(date_vente), granularite)
        totaux_ca[cle] = totaux_ca.get(cle, Decimal("0")) + Decimal(str(montant_total))
        totaux_nb[cle] = totaux_nb.get(cle, 0) + 1
    cles = _periodes(granularite, nb)
    return {
        "ca": _serie(cles, granularite, totaux_ca),
        "nb_ventes": _serie(cles, granularite, totaux_nb),
    }


async def serie_ambassadeurs(db: AsyncSession, granularite: str = "mois", nb: int = 12) -> dict:
    """Commissions générées vs montants réellement versés aux ambassadeurs, par période."""
    debut = _borne_debut(granularite, nb)

    commissions_rows = (
        await db.execute(
            select(
                CommissionParrainage.date_creation, CommissionParrainage.montant_commission
            ).where(
                CommissionParrainage.date_creation >= debut,
                CommissionParrainage.statut != "ANNULEE",
            )
        )
    ).all()
    totaux_commissions: dict[str, Decimal] = {}
    for date_creation, montant in commissions_rows:
        cle = _cle_periode(_naive(date_creation), granularite)
        totaux_commissions[cle] = totaux_commissions.get(cle, Decimal("0")) + Decimal(str(montant))

    versements_rows = (
        await db.execute(
            select(Payout.date_execution, Payout.montant_total).where(
                Payout.statut == "PAYE",
                Payout.date_execution.is_not(None),
                Payout.date_execution >= debut,
            )
        )
    ).all()
    totaux_versements: dict[str, Decimal] = {}
    for date_execution, montant in versements_rows:
        cle = _cle_periode(_naive(date_execution), granularite)
        totaux_versements[cle] = totaux_versements.get(cle, Decimal("0")) + Decimal(str(montant))

    cles = _periodes(granularite, nb)
    return {
        "commissions": _serie(cles, granularite, totaux_commissions),
        "versements": _serie(cles, granularite, totaux_versements),
    }
