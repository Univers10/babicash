import uuid
from datetime import date, datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, ConfigDict
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user
from app.models import CompteTiers, LigneVente, Produit, User, Vente
from app.schemas.auth import CurrentUser

router = APIRouter()


# ── Schemas ───────────────────────────────────────────────────────────────────

class LigneVenteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    produit_id: uuid.UUID | None
    produit_nom: str | None = None
    quantite: int
    prix_vendu_reel: Decimal
    marge_calculee: Decimal
    vente_a_perte: bool


class VenteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    boutique_id: uuid.UUID
    date_vente: datetime
    montant_total: Decimal
    mode_paiement: str
    signale_proprietaire: bool
    tier_id: uuid.UUID | None
    client_nom: str | None = None
    caissier_id: uuid.UUID | None = None
    caissier_nom: str | None = None
    lignes: list[LigneVenteOut] = []


class VenteListResponse(BaseModel):
    total: int
    ventes: list[VenteOut]


# ── Endpoint ──────────────────────────────────────────────────────────────────

@router.get("/", response_model=VenteListResponse)
async def list_ventes(
    boutique_id: uuid.UUID = Query(...),
    mode_paiement: str | None = Query(None),
    date_debut: date | None = Query(None),
    date_fin: date | None = Query(None),
    search: str | None = Query(None, description="Recherche par nom client"),
    signale_seulement: bool = Query(False),
    caissier_id: uuid.UUID | None = Query(None, description="Filtrer par caissier"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> VenteListResponse:
    await get_authorized_boutique(db, current_user, boutique_id)

    stmt = (
        select(Vente)
        .where(Vente.boutique_id == boutique_id)
        .options(
            selectinload(Vente.lignes),
        )
    )

    if mode_paiement:
        stmt = stmt.where(Vente.mode_paiement == mode_paiement)
    if date_debut:
        stmt = stmt.where(
            Vente.date_vente >= datetime(date_debut.year, date_debut.month, date_debut.day, tzinfo=timezone.utc)
        )
    if date_fin:
        stmt = stmt.where(
            Vente.date_vente < datetime(date_fin.year, date_fin.month, date_fin.day + 1, tzinfo=timezone.utc)
        )
    if signale_seulement:
        stmt = stmt.where(Vente.signale_proprietaire.is_(True))
    if caissier_id:
        stmt = stmt.where(Vente.caissier_id == caissier_id)

    # Filtre par nom client via jointure
    if search:
        stmt = stmt.join(CompteTiers, Vente.tier_id == CompteTiers.id, isouter=True).where(
            CompteTiers.nom.ilike(f"%{search}%")
        )

    total_stmt = stmt.with_only_columns(select(Vente.id).where(Vente.boutique_id == boutique_id).subquery().c.id)

    rows = (
        await db.execute(
            stmt.order_by(Vente.date_vente.desc()).limit(limit).offset(offset)
        )
    ).scalars().unique().all()

    # Charger les noms des produits, clients et caissiers en batch
    tier_ids = {v.tier_id for v in rows if v.tier_id}
    tiers: dict[uuid.UUID, str] = {}
    if tier_ids:
        tier_rows = (
            await db.execute(select(CompteTiers).where(CompteTiers.id.in_(tier_ids)))
        ).scalars().all()
        tiers = {t.id: t.nom for t in tier_rows}

    caissier_ids = {v.caissier_id for v in rows if v.caissier_id}
    caissiers: dict[uuid.UUID, str] = {}
    if caissier_ids:
        user_rows = (
            await db.execute(select(User).where(User.id.in_(caissier_ids)))
        ).scalars().all()
        caissiers = {u.id: u.nom for u in user_rows}

    produit_ids = {l.produit_id for v in rows for l in v.lignes if l.produit_id}
    produits: dict[uuid.UUID, str] = {}
    if produit_ids:
        prod_rows = (
            await db.execute(select(Produit).where(Produit.id.in_(produit_ids)))
        ).scalars().all()
        produits = {p.id: p.nom for p in prod_rows}

    # Compter le total (sans limit/offset)
    count_stmt = select(Vente.id).where(Vente.boutique_id == boutique_id)
    if mode_paiement:
        count_stmt = count_stmt.where(Vente.mode_paiement == mode_paiement)
    if date_debut:
        count_stmt = count_stmt.where(
            Vente.date_vente >= datetime(date_debut.year, date_debut.month, date_debut.day, tzinfo=timezone.utc)
        )
    if date_fin:
        count_stmt = count_stmt.where(
            Vente.date_vente < datetime(date_fin.year, date_fin.month, date_fin.day + 1, tzinfo=timezone.utc)
        )
    if signale_seulement:
        count_stmt = count_stmt.where(Vente.signale_proprietaire.is_(True))
    if caissier_id:
        count_stmt = count_stmt.where(Vente.caissier_id == caissier_id)
    if search:
        count_stmt = count_stmt.join(CompteTiers, Vente.tier_id == CompteTiers.id, isouter=True).where(
            CompteTiers.nom.ilike(f"%{search}%")
        )
    total = len((await db.execute(count_stmt)).scalars().all())

    ventes_out: list[VenteOut] = []
    for v in rows:
        lignes_out = [
            LigneVenteOut(
                id=l.id,
                produit_id=l.produit_id,
                produit_nom=produits.get(l.produit_id) if l.produit_id else "Article libre",
                quantite=l.quantite,
                prix_vendu_reel=l.prix_vendu_reel,
                marge_calculee=l.marge_calculee,
                vente_a_perte=l.vente_a_perte,
            )
            for l in v.lignes
        ]
        ventes_out.append(
            VenteOut(
                id=v.id,
                boutique_id=v.boutique_id,
                date_vente=v.date_vente,
                montant_total=v.montant_total,
                mode_paiement=v.mode_paiement,
                signale_proprietaire=v.signale_proprietaire,
                tier_id=v.tier_id,
                client_nom=tiers.get(v.tier_id) if v.tier_id else None,
                caissier_id=v.caissier_id,
                caissier_nom=caissiers.get(v.caissier_id) if v.caissier_id else None,
                lignes=lignes_out,
            )
        )

    return VenteListResponse(total=total, ventes=ventes_out)


# ── Retour marchandise ────────────────────────────────────────────────────────

class RetourResponse(BaseModel):
    vente_id: uuid.UUID
    message: str
    stock_remis: dict[str, int]  # {nom_produit: quantite remise}


@router.post("/{vente_id}/retour", response_model=RetourResponse)
async def retour_marchandise(
    vente_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> RetourResponse:
    """Annule une vente et remet le stock des produits associés."""
    vente = (
        await db.execute(
            select(Vente)
            .where(Vente.id == vente_id)
            .options(selectinload(Vente.lignes))
        )
    ).scalar_one_or_none()

    if vente is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vente introuvable.")

    await get_authorized_boutique(db, current_user, vente.boutique_id)

    # Remettre le stock pour chaque ligne
    stock_remis: dict[str, int] = {}
    produit_ids = [l.produit_id for l in vente.lignes if l.produit_id]
    produits: dict[uuid.UUID, Produit] = {}
    if produit_ids:
        rows = (await db.execute(select(Produit).where(Produit.id.in_(produit_ids)))).scalars().all()
        produits = {p.id: p for p in rows}

    for ligne in vente.lignes:
        if ligne.produit_id and ligne.produit_id in produits:
            produit = produits[ligne.produit_id]
            produit.stock_actuel += ligne.quantite
            stock_remis[produit.nom] = ligne.quantite

    # Rembourser le solde client si crédit
    if vente.mode_paiement == "CREDIT" and vente.tier_id:
        tier = (
            await db.execute(select(CompteTiers).where(CompteTiers.id == vente.tier_id))
        ).scalar_one_or_none()
        if tier is not None:
            tier.solde_du = max(Decimal("0.00"), tier.solde_du - vente.montant_total)

    # Supprimer la vente (cascade supprime les lignes)
    await db.delete(vente)
    await db.commit()

    return RetourResponse(
        vente_id=vente_id,
        message=f"Vente annulée. {len(stock_remis)} produit(s) remis en stock.",
        stock_remis=stock_remis,
    )
