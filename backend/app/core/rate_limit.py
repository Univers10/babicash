"""Rate limiting simple en mémoire pour les endpoints d'authentification."""
import time
from collections import defaultdict
from dataclasses import dataclass, field


@dataclass
class _Attempt:
    count: int = 0
    first_at: float = 0.0
    locked_until: float = 0.0


class LoginRateLimiter:
    """Limiteur de tentatives de connexion.

    - max_attempts: nombre max de tentatives dans la fenêtre
    - window: durée de la fenêtre en secondes
    - lockout: durée du blocage en secondes après dépassement
    """

    def __init__(
        self,
        max_attempts: int = 5,
        window: int = 300,  # 5 minutes
        lockout: int = 900,  # 15 minutes
    ):
        self.max_attempts = max_attempts
        self.window = window
        self.lockout = lockout
        self._attempts: dict[str, _Attempt] = defaultdict(_Attempt)

    def is_locked(self, key: str) -> bool:
        """Vérifie si la clé est bloquée."""
        attempt = self._attempts[key]
        now = time.time()
        if attempt.locked_until > now:
            return True
        # Débloquer si la fenêtre a expiré
        if now - attempt.first_at > self.window:
            attempt.count = 0
            attempt.locked_until = 0.0
        return False

    def record_failure(self, key: str) -> None:
        """Enregistre un échec et bloque si dépassement."""
        attempt = self._attempts[key]
        now = time.time()

        # Reset si fenêtre expirée
        if now - attempt.first_at > self.window:
            attempt.count = 0
            attempt.first_at = now

        attempt.count += 1
        if attempt.count >= self.max_attempts:
            attempt.locked_until = now + self.lockout

    def record_success(self, key: str) -> None:
        """Réinitialise les compteurs après un succès."""
        if key in self._attempts:
            del self._attempts[key]

    def remaining_seconds(self, key: str) -> int:
        """Retourne les secondes restantes de blocage."""
        attempt = self._attempts[key]
        now = time.time()
        if attempt.locked_until > now:
            return int(attempt.locked_until - now)
        return 0


# Instances globales
login_rate_limiter = LoginRateLimiter(max_attempts=5, window=300, lockout=900)
pin_rate_limiter = LoginRateLimiter(max_attempts=10, window=300, lockout=600)
