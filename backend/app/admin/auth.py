"""Routes d'authentification admin (login / logout / change password)."""
from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.admin.deps import require_admin
from app.core.config import settings
from app.core.csrf import generate_csrf_token, verify_csrf_token
from app.core.db import get_db
from app.core.rate_limit import login_rate_limiter
from app.core.security import create_access_token, hash_password, verify_password
from app.models import User
from app.schemas.auth import CurrentUser

router = APIRouter()
templates = Jinja2Templates(directory="templates")


@router.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    error = request.query_params.get("error")
    session_id = request.cookies.get("admin_session_id", "")
    csrf_token = generate_csrf_token(session_id)
    return templates.TemplateResponse(request, "login.html", {
        "error": error,
        "csrf_token": csrf_token,
    })


@router.post("/login")
async def login_submit(
    request: Request,
    email: str = Form(...),
    mot_de_passe: str = Form(...),
    csrf_token: str = Form(""),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(url="/admin/login?error=3", status_code=303)
    rate_key = f"admin:login:{email}"

    if login_rate_limiter.is_locked(rate_key):
        return RedirectResponse(
            url="/admin/login?error=2", status_code=303
        )

    user = (
        await db.execute(select(User).where(User.email == email))
    ).scalar_one_or_none()

    if (
        user is None
        or not user.actif
        or user.role != "ADMIN"
        or user.mot_de_passe_hash is None
        or not verify_password(mot_de_passe, user.mot_de_passe_hash)
    ):
        login_rate_limiter.record_failure(rate_key)
        return RedirectResponse(
            url="/admin/login?error=1", status_code=303
        )

    login_rate_limiter.record_success(rate_key)

    # Audit log
    import logging
    logger = logging.getLogger("admin.auth")
    logger.info(
        "Admin login réussi",
        extra={"email": email, "user_id": str(user.id), "ip": request.client.host if request.client else "unknown"},
    )

    token = create_access_token(
        subject=str(user.id),
        role=user.role,
        token_version=user.token_version,
    )

    response = RedirectResponse(url="/admin/", status_code=303)
    response.set_cookie(
        key="admin_token",
        value=token,
        httponly=True,
        secure=settings.SECURE_COOKIES,
        samesite="lax",
        max_age=28800,  # 8 heures
        path="/",
    )
    return response


@router.get("/logout")
async def logout():
    response = RedirectResponse(url="/admin/login", status_code=303)
    response.delete_cookie(key="admin_token", path="/")
    return response


@router.get("/change-password", response_class=HTMLResponse)
async def change_password_page(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
):
    error = request.query_params.get("error")
    success = request.query_params.get("success")
    session_id = request.cookies.get("admin_session_id", "")
    csrf_token = generate_csrf_token(session_id)
    return templates.TemplateResponse(request, "change_password.html", {
        "user": current_user,
        "error": error,
        "success": success,
        "csrf_token": csrf_token,
    })


@router.post("/change-password")
async def change_password_submit(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
    ancien_mot_de_passe: str = Form(...),
    nouveau_mot_de_passe: str = Form(...),
    confirmation: str = Form(...),
    csrf_token: str = Form(""),
    db: AsyncSession = Depends(get_db),
):
    session_id = request.cookies.get("admin_session_id", "")
    if not verify_csrf_token(csrf_token, session_id):
        return RedirectResponse(
            url="/admin/change-password?error=5", status_code=303
        )

    if nouveau_mot_de_passe != confirmation:
        return RedirectResponse(
            url="/admin/change-password?error=1", status_code=303
        )

    if len(nouveau_mot_de_passe) < 8:
        return RedirectResponse(
            url="/admin/change-password?error=2", status_code=303
        )

    user = (
        await db.execute(
            select(User).where(User.id == int(current_user.id))
        )
    ).scalar_one_or_none()

    if user is None or user.mot_de_passe_hash is None:
        return RedirectResponse(
            url="/admin/change-password?error=3", status_code=303
        )

    if not verify_password(ancien_mot_de_passe, user.mot_de_passe_hash):
        return RedirectResponse(
            url="/admin/change-password?error=4", status_code=303
        )

    user.mot_de_passe_hash = hash_password(nouveau_mot_de_passe)
    user.token_version = user.token_version + 1
    await db.commit()

    return RedirectResponse(
        url="/admin/change-password?success=1", status_code=303
    )
