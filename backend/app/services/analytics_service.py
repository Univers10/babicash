import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import LigneVente, Produit, Vente
from app.schemas.analytics import BestSellerItem, BestSellersResponse


async def best_sellers(
    db: AsyncSession,
    boutique_id: uuid.UUID,
    tri: str = "quantite",
    date_debut: datetime | None = None,
    date_fin: datetime | None = None,
    limite: int = 20,
) -> BestSellersResponse:
    qte_totale = func.sum(LigneVente.quantite).label("quantite_totale")
    marge_totale = func.sum(LigneVente.marge_calculee).label("marge_nette_totale")
    ca_total = func.sum(
        LigneVente.prix_vendu_reel * LigneVente.quantite
    ).label("chiffre_affaires")

    # func.max(Produit.nom) permet de récupérer le nom sans l'inclure dans GROUP BY
    # (PostgreSQL strict : toutes les colonnes non-agrégées doivent être dans GROUP BY)
    nom_col = func.coalesce(func.max(Produit.nom), "Article libre").label("nom")

    stmt = (
        select(
            LigneVente.produit_id,
            nom_col,
            qte_totale,
            marge_totale,
            ca_total,
        )
        .join(Vente, Vente.id == LigneVente.vente_id)
        .outerjoin(Produit, Produit.id == LigneVente.produit_id)
        .where(Vente.boutique_id == boutique_id)
        .group_by(LigneVente.produit_id)
    )

    if date_debut is not None:
        stmt = stmt.where(Vente.date_vente >= date_debut)
    if date_fin is not None:
        stmt = stmt.where(Vente.date_vente <= date_fin)

    if tri == "marge":
        stmt = stmt.order_by(marge_totale.desc())
    else:
        tri = "quantite"
        stmt = stmt.order_by(qte_totale.desc())

    stmt = stmt.limit(limite)

    rows = (await db.execute(stmt)).all()

    items = [
        BestSellerItem(
            produit_id=row.produit_id,
            nom=row.nom,
            quantite_totale=int(row.quantite_totale or 0),
            marge_nette_totale=Decimal(row.marge_nette_totale or 0),
            chiffre_affaires=Decimal(row.chiffre_affaires or 0),
        )
        for row in rows
    ]

    return BestSellersResponse(boutique_id=boutique_id, tri=tri, items=items)
