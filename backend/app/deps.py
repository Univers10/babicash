import uuid

from fastapi import Depends, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.security import decode_access_token
from app.models import User
from app.schemas.auth import CurrentUser

_bearer_scheme = HTTPBearer()

_CREDENTIALS_ERROR = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Identifiants invalides ou token expiré",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(_bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> CurrentUser:
    token = credentials.credentials
    payload = decode_access_token(token)
    if payload is None or "sub" not in payload:
        raise _CREDENTIALS_ERROR

    try:
        user_id = uuid.UUID(payload["sub"])
    except ValueError:
        raise _CREDENTIALS_ERROR

    user = (
        await db.execute(select(User).where(User.id == user_id))
    ).scalar_one_or_none()

    if user is None or not user.actif:
        raise _CREDENTIALS_ERROR

    # Vérifier que le token n'a pas été révoqué (changement de mot de passe)
    token_version = payload.get("tv", 0)
    if token_version != user.token_version:
        raise _CREDENTIALS_ERROR

    return CurrentUser(
        id=str(user.id),
        nom=user.nom,
        email=user.email,
        telephone=user.telephone,
        role=user.role,
        boutique_id=str(user.boutique_id) if user.boutique_id else None,
    )


def require_owner(
    current_user: CurrentUser = Depends(get_current_user),
) -> CurrentUser:
    if current_user.role != "OWNER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Accès réservé au propriétaire (OWNER)",
        )
    return current_user
