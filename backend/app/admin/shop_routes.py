"""Routes admin : gestion de la boutique « Matériel & accessoires ».

Produits : CRUD complet + stock + mise en vente.
Commandes : liste, détail, changement de statut, saisie manuelle d'une
commande reçue par WhatsApp.
"""
import uuid
from decimal import Decimal, InvalidOperation

from fastapi import APIRouter, Depends, Form, HTTPException, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.admin.deps import require_admin
from app.core.csrf import generate_csrf_token, verify_csrf_token
from app.core.db import get_db
from app.models import CommandeShop, CommandeShopLigne, ShopProduit
from app.schemas.auth import CurrentUser

router = APIRouter()
templates = Jinja2Templates(directory="templates")

_STATUTS = ["NOUVELLE", "CONFIRMEE", "PREPARATION", "EXPEDIEE", "LIVREE", "ANNULEE"]
_CATEGORIES = ["IMPRIMANTES", "ROULEAUX", "ACCESSOIRES"]
_ICONES = [
    "print",
    "receipt",
    "tablet_mac",
    "barcode_scanner",
    "payments",
    "router",
    "watch",
    "memory",
]

_LABEL_STATUT = {
    "NOUVELLE": "Nouvelle",
    "CONFIRMEE": "Confirmée",
    "PREPARATION": "Préparation",
    "EXPEDIEE": "Expédiée",
    "LIVREE": "Livrée",
    "ANNULEE": "Annulée",
}

_LABEL_CATEGORIE = {
    "IMPRIMANTES": "Imprimantes",
    "ROULEAUX": "Rouleaux",
    "ACCESSOIRES": "Accessoires",
}


def _fmt(v) -> str:
    """Formate un montant : 12 500 FCFA."""
    try:
        montant = int(round(float(v)))
    except (TypeError, ValueError):
        return "0 FCFA"
    return f"{montant:,}".replace(",", " ") + " FCFA"


def _to_decimal(v: str, default: Decimal = Decimal("0.00")) -> Decimal:
    try:
        return Decimal(v or "0")
    except (InvalidOperation, ValueError):
        return default


def _split_specs(v: str) -> list[str]:
    return [s.strip() for s in v.replace("\n", ",").split(",") if s.strip()]


def _parse_uuid(v: str) -> uuid.UUID | None:
    try:
        return uuid.UUID(v)
    except (ValueError, AttributeError):
        return None


async def _charger_commande(db: AsyncSession, commande_id: str) -> CommandeShop | None:
    cid = _parse_uuid(commande_id)
    if cid is None:
        return None
    result = await db.execute(
        select(CommandeShop)
        .options(selectinload(CommandeShop.lignes).selectinload(CommandeShopLigne.produit))
        .where(CommandeShop.id == cid)
    )
    return result.scalar_one_or_none()


async def _appliquer_statut(db: AsyncSession, commande: CommandeShop, nouveau: str) -> None:
    """Applique le changement de statut, avec gestion du stock.

    - → LIVREE : déduit les quantités du stock du catalogue.
    - ← LIVREE (annulation / retour) : remet le stock.
    """
    if commande.statut == nouveau:
        return

    def _reserve(increment: bool) -> None:
        delta = 1 if increment else -1
        for ligne in commande.lignes:
            if ligne.produit_id is None or ligne.produit is None:
                continue
            ligne.produit.stock = max(0, ligne.produit.stock + delta * ligne.quantite)

    if nouveau == "LIVREE" and commande.statut != "LIVREE":
        _reserve(increment=False)
    elif commande.statut == "LIVREE" and nouveau != "LIVREE":
        _reserve(increment=True)

    commande.statut = nouveau


# ── Produits ────────────────────────────────────────────────────────────

@router.get("/shop/produits", response_class=HTMLResponse)
async def shop_produits_list(
    request: Request,
    cat: str = "",
    rupture: str = "",
    q: str = "",
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(ShopProduit)
    if cat in _CATEGORIES:
        stmt = stmt.where(ShopProduit.categorie == cat)
    if rupture == "1":
        stmt = stmt.where(ShopProduit.stock <= ShopProduit.stock_alerte)
    if q.strip():
        stmt = stmt.where(ShopProduit.nom.ilike(f"%{q.strip()}%"))
    stmt = stmt.order_by(ShopProduit.position, ShopProduit.nom)

    produits = (await db.execute(stmt)).scalars().all()
    session_id = request.cookies.get("admin_session_id", "")
    return templates.TemplateResponse(request, "shop/produits/list.html", {
        "user": current_user,
        "produits": produits,
        "cat": cat,
        "rupture": rupture,
        "q": q,
        "categories": _CATEGORIES,
        "labels": _LABEL_CATEGORIE,
        "fmt": _fmt,
        "csrf_token": generate_csrf_token(session_id),
    })


@router.get("/shop/produits/nouveau", response_class=HTMLResponse)
async def shop_produit_nouveau(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
):
    session_id = request.cookies.get("admin_session_id", "")
    return templates.TemplateResponse(request, "shop/produits/form.html", {
        "user": current_user,
        "produit": None,
        "categories": _CATEGORIES,
        "icones": _ICONES,
        "labels": _LABEL_CATEGORIE,
        "csrf_token": generate_csrf_token(session_id),
    })


@router.post("/shop/produits/nouveau")
async def shop_produit_creer(
    request: Request,
    nom: str = Form(...),
    tagline: str = Form(""),
    description: str = Form(""),
    prix: str = Form("0"),
    ancien_prix: str = Form(""),
    categorie: str = Form("ACCESSOIRES"),
    icone: str = Form("print"),
    specs: str = Form(""),
    stock: str = Form("0"),
    stock_alerte: str = Form("5"),
    position: str = Form("0"),
    en_vente: str = Form(""),
    is_new: str = Form(""),
    is_populaire: str = Form(""),
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/produits", status_code=303)
    if categorie not in _CATEGORIES:
        categorie = "ACCESSOIRES"
    if icone not in _ICONES:
        icone = "print"

    produit = ShopProduit(
        nom=nom.strip(),
        tagline=tagline.strip(),
        description=description.strip(),
        prix=_to_decimal(prix),
        ancien_prix=_to_decimal(ancien_prix) if ancien_prix.strip() else None,
        categorie=categorie,
        icone=icone,
        specs=_split_specs(specs),
        stock=max(0, int(stock or "0")),
        stock_alerte=max(0, int(stock_alerte or "5")),
        position=max(0, int(position or "0")),
        en_vente=en_vente == "on",
        is_new=is_new == "on",
        is_populaire=is_populaire == "on",
    )
    db.add(produit)
    await db.commit()
    return RedirectResponse(url="/admin/shop/produits", status_code=303)


@router.get("/shop/produits/{produit_id}", response_class=HTMLResponse)
async def shop_produit_edit(
    request: Request,
    produit_id: str,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    pid = _parse_uuid(produit_id)
    produit = await db.get(ShopProduit, pid) if pid else None
    if produit is None:
        return RedirectResponse(url="/admin/shop/produits", status_code=303)
    session_id = request.cookies.get("admin_session_id", "")
    return templates.TemplateResponse(request, "shop/produits/form.html", {
        "user": current_user,
        "produit": produit,
        "categories": _CATEGORIES,
        "icones": _ICONES,
        "labels": _LABEL_CATEGORIE,
        "csrf_token": generate_csrf_token(session_id),
    })


@router.post("/shop/produits/{produit_id}")
async def shop_produit_modifier(
    produit_id: str,
    request: Request,
    nom: str = Form(...),
    tagline: str = Form(""),
    description: str = Form(""),
    prix: str = Form("0"),
    ancien_prix: str = Form(""),
    categorie: str = Form("ACCESSOIRES"),
    icone: str = Form("print"),
    specs: str = Form(""),
    stock: str = Form("0"),
    stock_alerte: str = Form("5"),
    position: str = Form("0"),
    en_vente: str = Form(""),
    is_new: str = Form(""),
    is_populaire: str = Form(""),
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/produits", status_code=303)
    pid = _parse_uuid(produit_id)
    produit = await db.get(ShopProduit, pid) if pid else None
    if produit is None:
        return RedirectResponse(url="/admin/shop/produits", status_code=303)

    if categorie not in _CATEGORIES:
        categorie = produit.categorie
    if icone not in _ICONES:
        icone = produit.icone

    produit.nom = nom.strip()
    produit.tagline = tagline.strip()
    produit.description = description.strip()
    produit.prix = _to_decimal(prix)
    produit.ancien_prix = _to_decimal(ancien_prix) if ancien_prix.strip() else None
    produit.categorie = categorie
    produit.icone = icone
    produit.specs = _split_specs(specs)
    produit.stock = max(0, int(stock or "0"))
    produit.stock_alerte = max(0, int(stock_alerte or "5"))
    produit.position = max(0, int(position or "0"))
    produit.en_vente = en_vente == "on"
    produit.is_new = is_new == "on"
    produit.is_populaire = is_populaire == "on"
    await db.commit()
    return RedirectResponse(url="/admin/shop/produits", status_code=303)


@router.post("/shop/produits/{produit_id}/toggle")
async def shop_produit_toggle(
    produit_id: str,
    request: Request,
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/produits", status_code=303)
    pid = _parse_uuid(produit_id)
    produit = await db.get(ShopProduit, pid) if pid else None
    if produit is not None:
        produit.en_vente = not produit.en_vente
        await db.commit()
    return RedirectResponse(url="/admin/shop/produits", status_code=303)


@router.post("/shop/produits/{produit_id}/supprimer")
async def shop_produit_supprimer(
    produit_id: str,
    request: Request,
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/produits", status_code=303)
    pid = _parse_uuid(produit_id)
    produit = await db.get(ShopProduit, pid) if pid else None
    if produit is None:
        return RedirectResponse(url="/admin/shop/produits", status_code=303)

    referencee = (
        await db.execute(
            select(CommandeShopLigne.id)
            .where(CommandeShopLigne.produit_id == pid)
            .limit(1)
        )
    ).scalar_one_or_none()
    if referencee is not None:
        produit.en_vente = False
        produit.stock = 0
        await db.commit()
        return RedirectResponse(url="/admin/shop/produits", status_code=303)
    await db.delete(produit)
    await db.commit()
    return RedirectResponse(url="/admin/shop/produits", status_code=303)


# ── Commandes ───────────────────────────────────────────────────────────

@router.get("/shop/commandes", response_class=HTMLResponse)
async def shop_commandes_list(
    request: Request,
    statut: str = "",
    q: str = "",
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(CommandeShop)
        .options(selectinload(CommandeShop.lignes))
        .order_by(CommandeShop.date_creation.desc())
    )
    if statut in _STATUTS:
        stmt = stmt.where(CommandeShop.statut == statut)
    if q.strip():
        like = f"%{q.strip()}%"
        stmt = stmt.where(
            or_(
                CommandeShop.client_nom.ilike(like),
                CommandeShop.client_telephone.ilike(like),
            )
        )

    commandes = (await db.execute(stmt)).scalars().unique().all()

    decompte = (await db.execute(
        select(CommandeShop.statut, func.count(CommandeShop.id)).group_by(
            CommandeShop.statut
        )
    )).all()
    nb_par_statut = dict(decompte)

    session_id = request.cookies.get("admin_session_id", "")
    return templates.TemplateResponse(request, "shop/commandes/list.html", {
        "user": current_user,
        "commandes": commandes,
        "statut": statut,
        "q": q,
        "statuts": _STATUTS,
        "labels": _LABEL_STATUT,
        "nb_par_statut": nb_par_statut,
        "fmt": _fmt,
        "csrf_token": generate_csrf_token(session_id),
    })


@router.get("/shop/commandes/{commande_id}", response_class=HTMLResponse)
async def shop_commande_detail(
    request: Request,
    commande_id: str,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    commande = await _charger_commande(db, commande_id)
    if commande is None:
        return RedirectResponse(url="/admin/shop/commandes", status_code=303)
    session_id = request.cookies.get("admin_session_id", "")
    return templates.TemplateResponse(request, "shop/commandes/detail.html", {
        "user": current_user,
        "commande": commande,
        "statuts": _STATUTS,
        "labels": _LABEL_STATUT,
        "fmt": _fmt,
        "csrf_token": generate_csrf_token(session_id),
    })


@router.post("/shop/commandes/{commande_id}/statut")
async def shop_commande_statut(
    commande_id: str,
    request: Request,
    statut: str = Form(...),
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/commandes", status_code=303)
    commande = await _charger_commande(db, commande_id)
    if commande is not None and statut in _STATUTS:
        await _appliquer_statut(db, commande, statut)
        await db.commit()
    return RedirectResponse(
        url=f"/admin/shop/commandes/{commande_id}", status_code=303
    )


@router.post("/shop/commandes/{commande_id}/supprimer")
async def shop_commande_supprimer(
    commande_id: str,
    request: Request,
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/commandes", status_code=303)
    commande = await _charger_commande(db, commande_id)
    if commande is not None:
        await db.delete(commande)
        await db.commit()
    return RedirectResponse(url="/admin/shop/commandes", status_code=303)


@router.get("/shop/commandes/nouvelle", response_class=HTMLResponse)
async def shop_commande_nouvelle(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    produits = (
        await db.execute(
            select(ShopProduit).where(ShopProduit.en_vente.is_(True))
            .order_by(ShopProduit.nom)
        )
    ).scalars().all()
    session_id = request.cookies.get("admin_session_id", "")
    return templates.TemplateResponse(request, "shop/commandes/form.html", {
        "user": current_user,
        "produits": produits,
        "csrf_token": generate_csrf_token(session_id),
        "fmt": _fmt,
    })


@router.post("/shop/commandes/nouvelle")
async def shop_commande_creer(
    request: Request,
    client_nom: str = Form(...),
    client_telephone: str = Form(""),
    client_adresse: str = Form(""),
    notes: str = Form(""),
    produit_id: list[str] = Form(default=[]),
    quantite: list[str] = Form(default=[]),
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/shop/commandes", status_code=303)

    commande = CommandeShop(
        client_nom=client_nom.strip(),
        client_telephone=client_telephone.strip() or None,
        client_adresse=client_adresse.strip() or None,
        notes=notes.strip() or None,
        source="ADMIN",
        total=Decimal("0.00"),
    )
    commande.lignes = []

    total = Decimal("0.00")
    for pid_s, qte_s in zip(produit_id, quantite):
        pid = _parse_uuid(pid_s)
        quantite_int = max(1, int(qte_s or "1"))
        produit = await db.get(ShopProduit, pid) if pid else None
        if produit is None:
            continue
        ligne = CommandeShopLigne(
            produit_id=produit.id,
            nom=produit.nom,
            prix_unitaire=produit.prix,
            quantite=quantite_int,
        )
        commande.lignes.append(ligne)
        total += produit.prix * quantite_int

    if not commande.lignes:
        # Rien de valide saisi — retour au formulaire avec un statut d'erreur.
        produits = (
            await db.execute(
                select(ShopProduit).where(ShopProduit.en_vente.is_(True))
                .order_by(ShopProduit.nom)
            )
        ).scalars().all()
        return templates.TemplateResponse(request, "shop/commandes/form.html", {
            "user": current_user,
            "produits": produits,
            "csrf_token": generate_csrf_token(session_id),
            "fmt": _fmt,
            "erreur": "Ajoutez au moins une ligne de produit valide.",
            "client_nom": client_nom,
            "client_telephone": client_telephone,
            "client_adresse": client_adresse,
            "notes": notes,
        }, status_code=422)

    commande.total = total
    db.add(commande)
    await db.commit()
    return RedirectResponse(url="/admin/shop/commandes", status_code=303)