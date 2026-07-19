"""Dependencies admin : authentification par cookie."""
import uuid

from fastapi import Cookie, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.security import decode_access_token
from app.models import User
from app.schemas.auth import CurrentUser


def _token_from_cookie(request: Request) -> str | None:
    return request.cookies.get("admin_token")


async def require_admin(
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> CurrentUser:
    """Exige un token admin valide via le cookie 'admin_token'.

    Si absent ou invalide → redirect vers /admin/login.
    """
    token = _token_from_cookie(request)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Location": "/admin/login"},
        )

    payload = decode_access_token(token)
    if payload is None or "sub" not in payload:
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Location": "/admin/login"},
        )

    if payload.get("role") != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Location": "/admin/login"},
        )

    # Vérifier que l'utilisateur existe toujours et que le token n'a pas été révoqué
    try:
        user_id = uuid.UUID(payload["sub"])
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Location": "/admin/login"},
        )

    user = (
        await db.execute(select(User).where(User.id == user_id))
    ).scalar_one_or_none()

    if user is None or not user.actif or user.role != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Location": "/admin/login"},
        )

    token_version = payload.get("tv", 0)
    if token_version != user.token_version:
        raise HTTPException(
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Location": "/admin/login"},
        )

    return CurrentUser(
        id=str(user.id),
        nom=user.nom,
        email=user.email,
        telephone=user.telephone,
        role=user.role,
        boutique_id=str(user.boutique_id) if user.boutique_id else None,
    )
