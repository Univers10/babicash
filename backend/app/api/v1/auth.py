import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.rate_limit import login_rate_limiter, pin_rate_limiter
from app.core.security import create_access_token, hash_password, verify_password, verify_pin
from app.deps import get_current_user
from app.models import Abonnement, Boutique, User
from app.services.abonnement_service import PLAN_CATALOG
from app.schemas.auth import (
    CurrentUser,
    LoginIdRequest,
    LoginPinRequest,
    LoginRequest,
    RegisterRequest,
    Token,
)

router = APIRouter()


def _token_for(user: User) -> Token:
    boutique_id = str(user.boutique_id) if user.boutique_id else None
    token = create_access_token(
        subject=str(user.id),
        role=user.role,
        token_version=user.token_version,
    )
    return Token(
        access_token=token,
        role=user.role,
        boutique_id=boutique_id,
        nom=user.nom,
        email=user.email,
        avatar_url=user.avatar_url,
    )


async def provision_owner_with_boutique(
    db: AsyncSession,
    *,
    nom: str,
    email: str | None = None,
    mot_de_passe_hash: str | None = None,
    telephone: str | None = None,
    oauth_provider: str | None = None,
    oauth_id: str | None = None,
    avatar_url: str | None = None,
) -> User:
    """Crée un propriétaire + sa boutique par défaut + un abonnement FREE.

    Utilisé aussi bien par /register (mot de passe) que par les endpoints
    OAuth (/oauth/google, /oauth/apple) pour l'inscription à la volée.
    """
    user = User(
        nom=nom,
        email=email,
        mot_de_passe_hash=mot_de_passe_hash,
        telephone=telephone,
        role="OWNER",
        oauth_provider=oauth_provider,
        oauth_id=oauth_id,
        avatar_url=avatar_url,
    )
    db.add(user)
    await db.flush()

    boutique = Boutique(
        nom=f"Boutique de {nom}",
        proprietaire_id=str(user.id),
    )
    db.add(boutique)
    await db.flush()

    cfg = PLAN_CATALOG["FREE"]
    abonnement = Abonnement(
        proprietaire_id=str(user.id),
        plan="FREE",
        prix_base=cfg["prix_base"],
        quota_ventes_par_boutique=cfg["quota_ventes"],
        nb_boutiques_max=cfg["nb_boutiques_max"],
        nb_gerants_max=cfg["nb_gerants_max"],
    )
    db.add(abonnement)

    await db.commit()
    await db.refresh(user)
    return user


@router.post("/login", response_model=Token)
async def login(payload: LoginRequest, db: AsyncSession = Depends(get_db)) -> Token:
    rate_key = f"login:email:{payload.email}"

    if login_rate_limiter.is_locked(rate_key):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Trop de tentatives. Réessayez plus tard.",
        )

    user = (
        await db.execute(select(User).where(User.email == payload.email))
    ).scalar_one_or_none()

    if (
        user is None
        or not user.actif
        or user.mot_de_passe_hash is None
        or not verify_password(payload.mot_de_passe, user.mot_de_passe_hash)
    ):
        login_rate_limiter.record_failure(rate_key)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe incorrect",
        )

    login_rate_limiter.record_success(rate_key)
    return _token_for(user)


@router.post("/login-pin", response_model=Token)
async def login_pin(
    payload: LoginPinRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Connexion simplifiée par téléphone + code PIN (gérants surtout)."""
    rate_key = f"login:pin:{payload.telephone}"

    if pin_rate_limiter.is_locked(rate_key):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Trop de tentatives. Réessayez plus tard.",
        )

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
        pin_rate_limiter.record_failure(rate_key)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Numéro ou code PIN incorrect",
        )

    pin_rate_limiter.record_success(rate_key)
    return _token_for(user)


@router.post("/login-id", response_model=Token)
async def login_id(
    payload: LoginIdRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Connexion par ID propriétaire (UUID)."""
    rate_key = f"login:id:{payload.id_proprietaire}"

    if login_rate_limiter.is_locked(rate_key):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Trop de tentatives. Réessayez plus tard.",
        )

    try:
        user_id = uuid.UUID(payload.id_proprietaire)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID propriétaire invalide",
        )

    user = await db.get(User, user_id)

    if (
        user is None
        or not user.actif
        or user.mot_de_passe_hash is None
        or not verify_password(payload.mot_de_passe, user.mot_de_passe_hash)
    ):
        login_rate_limiter.record_failure(rate_key)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="ID propriétaire ou mot de passe incorrect",
        )

    login_rate_limiter.record_success(rate_key)
    return _token_for(user)


@router.post("/register", response_model=Token)
async def register(
    payload: RegisterRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Inscription d'un nouveau propriétaire avec création de boutique et abonnement FREE."""
    # Vérifier si l'email existe déjà
    existing = (
        await db.execute(select(User).where(User.email == payload.email))
    ).scalar_one_or_none()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cet email est déjà utilisé",
        )

    user = await provision_owner_with_boutique(
        db,
        nom=payload.nom,
        email=payload.email,
        mot_de_passe_hash=hash_password(payload.mot_de_passe),
        telephone=payload.telephone,
    )

    return _token_for(user)


@router.get("/me", response_model=CurrentUser)
async def me(current_user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    return current_user
