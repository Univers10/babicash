"""API mobile de la boutique « Matériel & accessoires ».

Le catalogue (produits) est lu par l'app mobile pour afficher la boutique.
Les commandes passées depuis l'app (via WhatsApp) sont enregistrées ici afin
qu'elles soient gérées dans le backoffice admin.
"""
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.db import get_db
from app.deps import get_current_user
from app.models import CommandeShop, CommandeShopLigne, ShopProduit
from app.schemas.auth import CurrentUser
from app.schemas.shop import (
    CommandeCreate,
    CommandeShopOut,
    ShopProduitOut,
)

router = APIRouter()


@router.get("/produits", response_model=list[ShopProduitOut])
async def list_produits(
    actifs: bool = Query(True, description="Uniquement les produits en vente"),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[ShopProduit]:
    """Catalogue boutique. ``actifs=false`` renvoie aussi les produits en
    rupture ou retirés de la vente (usage admin)."""
    stmt = (
        select(ShopProduit)
        .order_by(ShopProduit.position, ShopProduit.nom)
    )
    if actifs:
        stmt = stmt.where(ShopProduit.en_vente.is_(True))
    rows = (await db.execute(stmt)).scalars().all()
    return list(rows)


@router.post(
    "/commandes",
    response_model=CommandeShopOut,
    status_code=status.HTTP_201_CREATED,
)
async def creer_commande(
    payload: CommandeCreate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CommandeShop:
    """Enregistre une commande passée depuis la boutique de l'app.

    Le total est recalculé côté serveur : si une ligne référence un produit
    du catalogue, son prix actuel (et son nom) font foi.
    """
    commande = CommandeShop(
        client_nom=payload.client_nom.strip(),
        client_telephone=payload.client_telephone,
        client_adresse=payload.client_adresse,
        notes=payload.notes,
        source=payload.source,
        total=Decimal("0.00"),
    )
    commande.lignes = []

    total = Decimal("0.00")
    for ligne_in in payload.lignes:
        nom = (ligne_in.nom or "").strip()
        prix = Decimal("0.00")
        produit_id = ligne_in.produit_id
        if produit_id is not None:
            produit = await db.get(ShopProduit, produit_id)
            if produit is not None:
                nom = produit.nom
                prix = produit.prix
        else:
            prix = ligne_in.prix_unitaire

        if not nom:
            raise HTTPException(
                status_code=422,
                detail="Chaque ligne doit avoir un nom ou référencer un produit du catalogue.",
            )

        ligne = CommandeShopLigne(
            produit_id=produit_id,
            nom=nom,
            prix_unitaire=prix,
            quantite=ligne_in.quantite,
        )
        commande.lignes.append(ligne)
        total += prix * ligne_in.quantite

    commande.total = total
    db.add(commande)
    await db.commit()
    await db.refresh(commande)

    result = await db.execute(
        select(CommandeShop)
        .options(selectinload(CommandeShop.lignes))
        .where(CommandeShop.id == commande.id)
    )
    return result.scalar_one()