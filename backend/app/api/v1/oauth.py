from urllib.parse import urlencode

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.v1.auth import _token_for, provision_owner_with_boutique
from app.core.db import get_db
from app.core.oauth import (
    OAuthClaims,
    OAuthVerificationError,
    verify_apple_id_token,
    verify_google_id_token,
)
from app.core.rate_limit import login_rate_limiter
from app.models import User
from app.schemas.auth import AppleTokenRequest, GoogleTokenRequest, Token

router = APIRouter()


async def _resolve_oauth_user(
    db: AsyncSession, claims: OAuthClaims, *, nom_hint: str | None = None
) -> User:
    rate_key = f"login:oauth:{claims.provider}:{claims.email or claims.sub}"
    if login_rate_limiter.is_locked(rate_key):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Trop de tentatives. Réessayez plus tard.",
        )

    # 1. Compte déjà lié à cette identité OAuth
    user = (
        await db.execute(
            select(User).where(
                User.oauth_provider == claims.provider,
                User.oauth_id == claims.sub,
            )
        )
    ).scalar_one_or_none()

    if user is not None:
        if not user.actif:
            login_rate_limiter.record_failure(rate_key)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Compte désactivé",
            )
        login_rate_limiter.record_success(rate_key)
        return user

    # 2. Email vérifié correspondant à un compte existant -> auto-liaison
    if claims.email and claims.email_verified:
        existing = (
            await db.execute(select(User).where(User.email == claims.email))
        ).scalar_one_or_none()

        if existing is not None:
            if existing.oauth_provider is not None:
                login_rate_limiter.record_failure(rate_key)
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Cet email est déjà lié à un autre compte de connexion sociale",
                )
            if not existing.actif:
                login_rate_limiter.record_failure(rate_key)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Compte désactivé",
                )
            existing.oauth_provider = claims.provider
            existing.oauth_id = claims.sub
            if claims.picture:
                existing.avatar_url = claims.picture
            await db.commit()
            await db.refresh(existing)
            login_rate_limiter.record_success(rate_key)
            return existing

    # 3. Nouveau compte propriétaire
    nom = claims.name or nom_hint or "Utilisateur"
    user = await provision_owner_with_boutique(
        db,
        nom=nom,
        email=claims.email,
        oauth_provider=claims.provider,
        oauth_id=claims.sub,
        avatar_url=claims.picture,
    )
    login_rate_limiter.record_success(rate_key)
    return user


@router.post("/oauth/google", response_model=Token)
async def login_google(
    payload: GoogleTokenRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    try:
        claims = await verify_google_id_token(payload.id_token)
    except OAuthVerificationError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)
        ) from exc

    user = await _resolve_oauth_user(db, claims)
    return _token_for(user)


@router.post("/oauth/apple", response_model=Token)
async def login_apple(
    payload: AppleTokenRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    try:
        claims = await verify_apple_id_token(payload.identity_token)
    except OAuthVerificationError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)
        ) from exc

    user = await _resolve_oauth_user(db, claims, nom_hint=payload.nom)
    return _token_for(user)


_ANDROID_PACKAGE = "com.babicash.app"


@router.post("/oauth/apple/callback")
async def apple_callback(request: Request) -> RedirectResponse:
    """Relais du flux web Apple vers l'app Android.

    Apple POSTe (form_post) code/id_token/state/user sur cette URL après la
    connexion dans le Custom Tab. On redirige vers le deep link intercepté
    par le plugin sign_in_with_apple (scheme `signinwithapple`), qui termine
    le flux côté Flutter.
    """
    form = await request.form()
    allowed = {
        k: v for k, v in form.items()
        if k in ("code", "id_token", "state", "user") and isinstance(v, str)
    }
    redirect_url = (
        f"intent://callback?{urlencode(allowed)}"
        f"#Intent;package={_ANDROID_PACKAGE};scheme=signinwithapple;end"
    )
    return RedirectResponse(url=redirect_url, status_code=status.HTTP_307_TEMPORARY_REDIRECT)
