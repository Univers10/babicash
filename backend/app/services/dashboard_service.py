"""Service dashboard : CA, caisse, dettes, stock, vue consolidée."""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Boutique, CompteTiers, LigneVente, Produit, TransactionCaisse, Vente


# ── helpers ────────────────────────────────────────────────────────────────────

def _debut_periode(granularite: str) -> datetime:
    now = datetime.now(timezone.utc)
    if granularite == "jour":
        return now.replace(hour=0, minute=0, second=0, microsecond=0)
    if granularite == "semaine":
        return (now - timedelta(days=now.weekday())).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
    # mois
    return now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)


# ── CA par période ──────────────────────────────────────────────────────────────

async def chiffre_affaires(
    db: AsyncSession,
    boutique_id: uuid.UUID,
    granularite: str = "mois",
    date_debut: datetime | None = None,
    date_fin: datetime | None = None,
) -> dict:
    """CA, marge nette et nombre de ventes sur la période."""
    debut = date_debut or _debut_periode(granularite)
    fin = date_fin or datetime.now(timezone.utc)

    stmt = (
        select(
            func.coalesce(func.sum(LigneVente.prix_vendu_reel * LigneVente.quantite), 0).label("ca"),
            func.coalesce(func.sum(LigneVente.marge_calculee), 0).label("marge"),
            func.count(func.distinct(Vente.id)).label("nb_ventes"),
        )
        .join(Vente, Vente.id == LigneVente.vente_id)
        .where(
            Vente.boutique_id == boutique_id,
            Vente.date_vente >= debut,
            Vente.date_vente <= fin,
        )
    )
    row = (await db.execute(stmt)).one()

    return {
        "boutique_id": str(boutique_id),
        "granularite": granularite,
        "date_debut": debut.isoformat(),
        "date_fin": fin.isoformat(),
        "chiffre_affaires": Decimal(str(row.ca)),
        "marge_nette": Decimal(str(row.marge)),
        "nb_ventes": int(row.nb_ventes),
    }


# ── Résumé de caisse ────────────────────────────────────────────────────────────

async def resume_caisse(
    db: AsyncSession,
    boutique_id: uuid.UUID,
    granularite: str = "mois",
    date_debut: datetime | None = None,
    date_fin: datetime | None = None,
) -> dict:
    """Recettes ventes + entrées, dépenses, solde net sur la période."""
    debut = date_debut or _debut_periode(granularite)
    fin = date_fin or datetime.now(timezone.utc)

    stmt = (
        select(
            TransactionCaisse.type_transaction,
            func.coalesce(func.sum(TransactionCaisse.montant), 0).label("total"),
        )
        .where(
            TransactionCaisse.boutique_id == boutique_id,
            TransactionCaisse.date_transaction >= debut,
            TransactionCaisse.date_transaction <= fin,
        )
        .group_by(TransactionCaisse.type_transaction)
    )
    rows = (await db.execute(stmt)).all()

    totaux: dict[str, Decimal] = {}
    for row in rows:
        totaux[row.type_transaction] = Decimal(str(row.total))

    recettes = totaux.get("VENTE", Decimal("0")) + totaux.get("ENTREE", Decimal("0"))
    depenses = totaux.get("SORTIE_DEPENSE", Decimal("0"))
    entrees_stock = totaux.get("ENTREE_STOCK", Decimal("0"))

    return {
        "boutique_id": str(boutique_id),
        "granularite": granularite,
        "date_debut": debut.isoformat(),
        "date_fin": fin.isoformat(),
        "recettes_ventes": totaux.get("VENTE", Decimal("0")),
        "depenses": depenses,
        "entrees_stock_montant": entrees_stock,
        "solde_net": recettes - depenses,
        "detail_par_type": {k: str(v) for k, v in totaux.items()},
    }


# ── Dettes clients & fournisseurs ───────────────────────────────────────────────

async def dettes(
    db: AsyncSession,
    boutique_id: uuid.UUID,
    type_tiers: str | None = None,
) -> dict:
    """Somme des soldes_du par type de tiers (CLIENT / FOURNISSEUR)."""
    stmt = select(
        CompteTiers.type_tiers,
        func.count(CompteTiers.id).label("nb"),
        func.coalesce(func.sum(CompteTiers.solde_du), 0).label("total_du"),
    ).where(
        CompteTiers.boutique_id == boutique_id,
        CompteTiers.solde_du > 0,
    )
    if type_tiers:
        stmt = stmt.where(CompteTiers.type_tiers == type_tiers)
    stmt = stmt.group_by(CompteTiers.type_tiers)

    rows = (await db.execute(stmt)).all()

    detail = [
        {
            "type_tiers": row.type_tiers,
            "nb_debiteurs": int(row.nb),
            "total_du": Decimal(str(row.total_du)),
        }
        for row in rows
    ]
    total_global = sum(d["total_du"] for d in detail)

    return {
        "boutique_id": str(boutique_id),
        "total_dettes": total_global,
        "detail": detail,
    }


async def top_debiteurs(
    db: AsyncSession,
    boutique_id: uuid.UUID,
    type_tiers: str = "CLIENT",
    limite: int = 10,
) -> list[dict]:
    """Top débiteurs (clients ou fournisseurs) triés par montant dû."""
    stmt = (
        select(
            CompteTiers.id,
            CompteTiers.nom,
            CompteTiers.telephone,
            CompteTiers.solde_du,
        )
        .where(
            CompteTiers.boutique_id == boutique_id,
            CompteTiers.type_tiers == type_tiers,
            CompteTiers.solde_du > 0,
        )
        .order_by(CompteTiers.solde_du.desc())
        .limit(limite)
    )
    rows = (await db.execute(stmt)).all()
    return [
        {
            "id": str(row.id),
            "nom": row.nom,
            "telephone": row.telephone,
            "solde_du": Decimal(str(row.solde_du)),
        }
        for row in rows
    ]


# ── État du stock ───────────────────────────────────────────────────────────────

async def etat_stock(
    db: AsyncSession,
    boutique_id: uuid.UUID,
) -> dict:
    """Valeur totale du stock, produits en rupture, produits en alerte."""
    stmt = select(Produit).where(Produit.boutique_id == boutique_id)
    produits = (await db.execute(stmt)).scalars().all()

    valeur_totale = Decimal("0")
    ruptures = []
    alertes = []

    for p in produits:
        valeur_totale += Decimal(str(p.stock_actuel)) * p.prix_achat_moyen
        if p.stock_actuel <= 0:
            ruptures.append({"id": str(p.id), "nom": p.nom, "stock": p.stock_actuel})
        elif p.stock_actuel <= p.stock_alerte:
            alertes.append(
                {
                    "id": str(p.id),
                    "nom": p.nom,
                    "stock": p.stock_actuel,
                    "stock_alerte": p.stock_alerte,
                }
            )

    return {
        "boutique_id": str(boutique_id),
        "nb_references": len(produits),
        "valeur_stock_fcfa": valeur_totale,
        "nb_ruptures": len(ruptures),
        "nb_alertes": len(alertes),
        "produits_rupture": ruptures,
        "produits_alerte": alertes,
    }


# ── Vue consolidée OWNER (toutes boutiques) ─────────────────────────────────────

async def consolide_owner(
    db: AsyncSession,
    proprietaire_id: str,
    granularite: str = "mois",
) -> dict:
    """Agrégation CA + marge sur toutes les boutiques de l'OWNER."""
    boutiques = (
        await db.execute(
            select(Boutique).where(Boutique.proprietaire_id == proprietaire_id)
        )
    ).scalars().all()

    resultats = []
    ca_total = Decimal("0")
    marge_totale = Decimal("0")
    nb_ventes_total = 0

    for b in boutiques:
        r = await chiffre_affaires(db, b.id, granularite)
        ca_total += r["chiffre_affaires"]
        marge_totale += r["marge_nette"]
        nb_ventes_total += r["nb_ventes"]
        resultats.append(
            {
                "boutique_id": str(b.id),
                "boutique_nom": b.nom,
                "chiffre_affaires": r["chiffre_affaires"],
                "marge_nette": r["marge_nette"],
                "nb_ventes": r["nb_ventes"],
            }
        )

    return {
        "granularite": granularite,
        "ca_total": ca_total,
        "marge_totale": marge_totale,
        "nb_ventes_total": nb_ventes_total,
        "boutiques": resultats,
    }
