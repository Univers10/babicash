"""Dependencies admin : authentification par cookie."""
from fastapi import Cookie, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse

from app.core.security import decode_access_token
from app.schemas.auth import CurrentUser


def _token_from_cookie(request: Request) -> str | None:
    return request.cookies.get("admin_token")


def require_admin(request: Request) -> CurrentUser:
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

    return CurrentUser(
        id=payload["sub"],
        nom=payload.get("nom", ""),
        email=payload.get("email"),
        telephone=payload.get("telephone"),
        role=payload.get("role", ""),
        boutique_id=payload.get("boutique_id"),
    )
