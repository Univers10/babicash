"""Routes admin : pages Jinja2 + endpoints API admin."""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.admin.deps import require_admin
from app.core.csrf import verify_csrf_token
from app.core.db import get_db
from app.core.security import hash_password
from app.models import Abonnement, Boutique, User
from app.schemas.auth import CurrentUser
from app.services import abonnement_service
from app.services.abonnement_service import compter_ventes_mois

router = APIRouter()
templates = Jinja2Templates(directory="templates")

_PLAN_CATALOG = abonnement_service.PLAN_CATALOG


# ── Helpers ──────────────────────────────────────────────────────────

async def _stats(db: AsyncSession) -> dict:
    nb_owners = (
        await db.execute(
            select(func.count(User.id)).where(User.role == "OWNER")
        )
    ).scalar_one()

    nb_boutiques = (await db.execute(select(func.count(Boutique.id)))).scalar_one()

    nb_abos_actifs = (
        await db.execute(
            select(func.count(Abonnement.id)).where(Abonnement.actif.is_(True))
        )
    ).scalar_one()

    # Répartition des plans
    plan_rows = (
        await db.execute(
            select(Abonnement.plan, func.count(Abonnement.id)).group_by(Abonnement.plan)
        )
    ).all()
    plans = {row[0]: row[1] for row in plan_rows}

    # Revenus estimés (prix_base * nb_boutiques pour chaque abonnement actif)
    revenu_total = Decimal("0.00")
    abos = (await db.execute(select(Abonnement).where(Abonnement.actif.is_(True)))).scalars().all()
    for abo in abos:
        cfg = _PLAN_CATALOG.get(abo.plan, {})
        nb_bout = (
            await db.execute(
                select(func.count(Boutique.id)).where(Boutique.proprietaire_id == abo.proprietaire_id)
            )
        ).scalar_one()
        prix = abonnement_service.calculer_prix_total(abo.prix_base, nb_bout)
        revenu_total += prix

    # Derniers owners
    last_owners = (
        await db.execute(
            select(User)
            .where(User.role == "OWNER")
            .order_by(User.date_creation.desc())
            .limit(5)
        )
    ).scalars().all()

    return {
        "nb_owners": nb_owners,
        "nb_boutiques": nb_boutiques,
        "nb_abos_actifs": nb_abos_actifs,
        "plans": plans,
        "revenu_total": float(revenu_total),
        "last_owners": last_owners,
    }


async def _get_user_by_id(db: AsyncSession, user_id: str) -> User | None:
    """Récupère un User par son id (string UUID)."""
    try:
        uid = uuid.UUID(user_id)
    except (ValueError, AttributeError):
        return None
    result = await db.execute(select(User).where(User.id == uid))
    return result.scalar_one_or_none()


async def _owner_with_abo(db: AsyncSession, owner_id: str):
    user = await _get_user_by_id(db, owner_id)
    if user is None or user.role != "OWNER":
        return None, None, [], 0
    abo = (
        await db.execute(
            select(Abonnement).where(Abonnement.proprietaire_id == owner_id)
        )
    ).scalar_one_or_none()
    boutiques = (
        await db.execute(
            select(Boutique).where(Boutique.proprietaire_id == owner_id)
        )
    ).scalars().all()
    nb_ventes = 0
    for b in boutiques:
        nb_ventes += await compter_ventes_mois(db, b.id)
    return user, abo, boutiques, nb_ventes


# ── Dashboard ────────────────────────────────────────────────────────

@router.get("/", response_class=HTMLResponse)
async def dashboard(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    stats = await _stats(db)
    return templates.TemplateResponse(request, "dashboard.html", {
        "user": current_user,
        "stats": stats,
    })


# ── Owners ───────────────────────────────────────────────────────────

@router.get("/owners", response_class=HTMLResponse)
async def owners_list(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    users = (
        await db.execute(
            select(User)
            .where(User.role == "OWNER")
            .order_by(User.date_creation.desc())
        )
    ).scalars().all()

    # Joindre abonnements
    owners_data = []
    for u in users:
        abo = (
            await db.execute(
                select(Abonnement).where(Abonnement.proprietaire_id == str(u.id))
            )
        ).scalar_one_or_none()
        nb_boutiques = (
            await db.execute(
                select(func.count(Boutique.id)).where(Boutique.proprietaire_id == str(u.id))
            )
        ).scalar_one()
        owners_data.append({
            "user": u,
            "abo": abo,
            "nb_boutiques": nb_boutiques,
        })

    return templates.TemplateResponse(request, "owners/list.html", {
        "user": current_user,
        "owners_data": owners_data,
    })


@router.get("/owners/{owner_id}", response_class=HTMLResponse)
async def owner_detail(
    request: Request,
    owner_id: str,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user, abo, boutiques, nb_ventes = await _owner_with_abo(db, owner_id)
    if user is None:
        return RedirectResponse(url="/admin/owners", status_code=303)

    from app.core.csrf import generate_csrf_token
    session_id = request.cookies.get("admin_session_id", "")
    csrf_token = generate_csrf_token(session_id)

    return templates.TemplateResponse(request, "owners/detail.html", {
        "user": current_user,
        "owner": user,
        "abo": abo,
        "boutiques": boutiques,
        "nb_ventes": nb_ventes,
        "plans": _PLAN_CATALOG,
        "csrf_token": csrf_token,
    })


@router.post("/owners/{owner_id}/toggle")
async def owner_toggle(
    owner_id: str,
    request: Request,
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url=f"/admin/owners/{owner_id}", status_code=303)

    user = await _get_user_by_id(db, owner_id)
    if user and user.role == "OWNER":
        user.actif = not user.actif
        await db.commit()
    return RedirectResponse(url=f"/admin/owners/{owner_id}", status_code=303)


@router.post("/owners/{owner_id}/plan")
async def owner_change_plan(
    owner_id: str,
    request: Request,
    plan: str = Form(...),
    csrf_token: str = Form(""),
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url=f"/admin/owners/{owner_id}", status_code=303)

    await abonnement_service.upgrader_plan(db, owner_id, plan)
    return RedirectResponse(url=f"/admin/owners/{owner_id}", status_code=303)


# ── Abonnements ──────────────────────────────────────────────────────

@router.get("/abonnements", response_class=HTMLResponse)
async def abonnements_list(
    request: Request,
    filtre_plan: str = "",
    filtre_statut: str = "",
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Abonnement).order_by(Abonnement.date_debut.desc())

    if filtre_plan:
        stmt = stmt.where(Abonnement.plan == filtre_plan)

    abos = (await db.execute(stmt)).scalars().all()

    # Joindre owners + calculer statut
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    abos_data = []
    for abo in abos:
        owner = await _get_user_by_id(db, abo.proprietaire_id)
        if abo.actif and abo.date_fin and abo.date_fin <= now:
            statut = "EXPIRE"
        elif abo.actif:
            statut = "ACTIF"
        else:
            statut = "INACTIF"

        if filtre_statut and statut != filtre_statut:
            continue

        nb_boutiques = (
            await db.execute(
                select(func.count(Boutique.id)).where(Boutique.proprietaire_id == abo.proprietaire_id)
            )
        ).scalar_one()
        abos_data.append({
            "abo": abo,
            "owner": owner,
            "nb_boutiques": nb_boutiques,
            "statut": statut,
        })

    return templates.TemplateResponse(request, "abonnements/list.html", {
        "user": current_user,
        "abos_data": abos_data,
        "filtre_plan": filtre_plan,
        "filtre_statut": filtre_statut,
        "all_plans": list(_PLAN_CATALOG.keys()),
    })


# ── Boutiques ────────────────────────────────────────────────────────

@router.get("/boutiques", response_class=HTMLResponse)
async def boutiques_list(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    boutiques = (
        await db.execute(
            select(Boutique).order_by(Boutique.date_creation.desc())
        )
    ).scalars().all()

    boutiques_data = []
    for b in boutiques:
        owner = await _get_user_by_id(db, b.proprietaire_id) if b.proprietaire_id else None
        nb_ventes = await compter_ventes_mois(db, b.id)
        boutiques_data.append({
            "boutique": b,
            "owner": owner,
            "nb_ventes": nb_ventes,
        })

    return templates.TemplateResponse(request, "boutiques/list.html", {
        "user": current_user,
        "boutiques_data": boutiques_data,
    })
