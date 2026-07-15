import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.security import create_access_token, hash_password, verify_password, verify_pin
from app.deps import get_current_user
from app.models import Abonnement, Boutique, User
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


@router.post("/login-id", response_model=Token)
async def login_id(
    payload: LoginIdRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Connexion par ID propriétaire (UUID)."""
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
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="ID propriétaire ou mot de passe incorrect",
        )

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

    # Créer l'utilisateur propriétaire
    user = User(
        nom=payload.nom,
        email=payload.email,
        mot_de_passe_hash=hash_password(payload.mot_de_passe),
        telephone=payload.telephone,
        role="OWNER",
    )
    db.add(user)
    await db.flush()

    # Créer la boutique par défaut
    boutique = Boutique(
        nom=f"Boutique de {payload.nom}",
        proprietaire_id=str(user.id),
    )
    db.add(boutique)
    await db.flush()

    # Créer l'abonnement FREE
    from decimal import Decimal
    abonnement = Abonnement(
        proprietaire_id=str(user.id),
        plan="FREE",
        prix_base=Decimal("5000.00"),
        quota_ventes_par_boutique=20,
    )
    db.add(abonnement)

    await db.commit()
    await db.refresh(user)

    return _token_for(user)


@router.get("/me", response_model=CurrentUser)
async def me(current_user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    return current_user
