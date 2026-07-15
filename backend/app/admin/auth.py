"""Routes d'authentification admin (login / logout)."""
from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.security import create_access_token, verify_password
from app.models import User

router = APIRouter()
templates = Jinja2Templates(directory="templates")


@router.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    error = request.query_params.get("error")
    return templates.TemplateResponse(request, "login.html", {"error": error})


@router.post("/login")
async def login_submit(
    request: Request,
    email: str = Form(...),
    mot_de_passe: str = Form(...),
    db: AsyncSession = Depends(get_db),
):
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
        return RedirectResponse(
            url="/admin/login?error=1", status_code=303
        )

    token = create_access_token(
        subject=str(user.id),
        role=user.role,
        nom=user.nom,
        email=user.email,
    )

    response = RedirectResponse(url="/admin/", status_code=303)
    response.set_cookie(
        key="admin_token",
        value=token,
        httponly=True,
        samesite="lax",
        max_age=86400 * 7,
        path="/",
    )
    return response


@router.get("/logout")
async def logout():
    response = RedirectResponse(url="/admin/login", status_code=303)
    response.delete_cookie(key="admin_token", path="/")
    return response
