"""Protection CSRF pour les formulaires admin (synchronizer token pattern)."""
import hashlib
import hmac
import secrets
import time

from app.core.config import settings

_CSRF_SECRET = settings.SECRET_KEY.encode()
_CSRF_EXPIRY = 3600  # 1 heure


def generate_csrf_token(session_id: str) -> str:
    """Génère un token CSRF signé pour la session."""
    expires = int(time.time()) + _CSRF_EXPIRY
    payload = f"{session_id}:{expires}"
    signature = hmac.new(_CSRF_SECRET, payload.encode(), hashlib.sha256).hexdigest()
    token = f"{expires}:{signature}"
    return token


def verify_csrf_token(token: str, session_id: str) -> bool:
    """Vérifie qu'un token CSRF est valide."""
    try:
        parts = token.split(":", 1)
        expires = int(parts[0])
        signature = parts[1]
    except (ValueError, IndexError):
        return False

    if time.time() > expires:
        return False

    payload = f"{session_id}:{expires}"
    expected = hmac.new(_CSRF_SECRET, payload.encode(), hashlib.sha256).hexdigest()
    return hmac.compare_digest(signature, expected)
