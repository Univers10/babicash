from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.security import create_access_token, verify_password, verify_pin
from app.deps import get_current_user
from app.models import User
from app.schemas.auth import CurrentUser, LoginPinRequest, LoginRequest, Token

router = APIRouter()


def _token_for(user: User) -> Token:
    boutique_id = str(user.boutique_id) if user.boutique_id else None
    token = create_access_token(
        subject=str(user.id),
        role=user.role,
        nom=user.nom,
        email=user.email,
        telephone=user.telephone,
        boutique_id=boutique_id,
    )
    return Token(
        access_token=token,
        role=user.role,
        boutique_id=boutique_id,
        nom=user.nom,
    )


@router.post("/login", response_model=Token)
async def login(payload: LoginRequest, db: AsyncSession = Depends(get_db)) -> Token:
    user = (
        await db.execute(select(User).where(User.email == payload.email))
    ).scalar_one_or_none()

    if (
        user is None
        or not user.actif
        or user.mot_de_passe_hash is None
        or not verify_password(payload.mot_de_passe, user.mot_de_passe_hash)
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe incorrect",
        )

    return _token_for(user)


@router.post("/login-pin", response_model=Token)
async def login_pin(
    payload: LoginPinRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Connexion simplifiée par téléphone + code PIN (gérants surtout)."""
    user = (
        await db.execute(
            select(User).where(User.telephone == payload.telephone)
        )
    ).scalar_one_or_none()

    if (
        user is None
        or not user.actif
        or user.code_pin_hash is None
        or not verify_pin(payload.code_pin, user.code_pin_hash)
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Numéro ou code PIN incorrect",
        )

    return _token_for(user)


@router.get("/me", response_model=CurrentUser)
async def me(current_user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    return current_user
