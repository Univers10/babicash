"""Vérification des identity tokens Google / Apple pour la connexion sociale."""
from dataclasses import dataclass

import jwt
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from jwt import PyJWKClient
from jwt.exceptions import InvalidTokenError
from starlette.concurrency import run_in_threadpool

from app.core.config import settings

APPLE_ISSUER = "https://appleid.apple.com"
APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys"

_apple_jwk_client = PyJWKClient(APPLE_JWKS_URL)


class OAuthVerificationError(Exception):
    """Levée quand un identity token Google/Apple est invalide ou non vérifiable."""


@dataclass
class OAuthClaims:
    provider: str
    sub: str
    email: str | None
    email_verified: bool
    name: str | None
    picture: str | None


async def verify_google_id_token(id_token_str: str) -> OAuthClaims:
    if not settings.GOOGLE_CLIENT_ID:
        raise OAuthVerificationError("Connexion Google non configurée")

    def _verify() -> dict:
        return google_id_token.verify_oauth2_token(
            id_token_str,
            google_requests.Request(),
            audience=settings.GOOGLE_CLIENT_ID,
        )

    try:
        claims = await run_in_threadpool(_verify)
    except ValueError as exc:
        raise OAuthVerificationError(f"Token Google invalide : {exc}") from exc

    return OAuthClaims(
        provider="google",
        sub=claims["sub"],
        email=claims.get("email"),
        email_verified=bool(claims.get("email_verified", False)),
        name=claims.get("name"),
        picture=claims.get("picture"),
    )


async def verify_apple_id_token(identity_token: str) -> OAuthClaims:
    if not settings.APPLE_CLIENT_ID:
        raise OAuthVerificationError("Connexion Apple non configurée")

    def _verify() -> dict:
        signing_key = _apple_jwk_client.get_signing_key_from_jwt(identity_token)
        return jwt.decode(
            identity_token,
            signing_key.key,
            algorithms=["RS256"],
            audience=settings.APPLE_CLIENT_ID,
            issuer=APPLE_ISSUER,
        )

    try:
        claims = await run_in_threadpool(_verify)
    except (InvalidTokenError, jwt.PyJWKClientError) as exc:
        raise OAuthVerificationError(f"Token Apple invalide : {exc}") from exc

    return OAuthClaims(
        provider="apple",
        sub=claims["sub"],
        email=claims.get("email"),
        # Apple ne renvoie email_verified qu'en string ("true"/"false") selon les cas
        email_verified=str(claims.get("email_verified", "false")).lower() == "true",
        name=None,  # Apple ne met jamais le nom dans le token, seulement hors-bande
        picture=None,
    )
