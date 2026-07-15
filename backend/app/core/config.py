from functools import lru_cache

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_INSECURE_DEFAULT = "change-me-in-production-use-a-long-random-string"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )

    PROJECT_NAME: str = "BabiCash API"
    API_V1_PREFIX: str = "/api/v1"

    DATABASE_URL: str = (
        "postgresql+asyncpg://babicash:babicash@localhost:5432/babicash"
    )

    SECRET_KEY: str = _INSECURE_DEFAULT
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 heures
    SECURE_COOKIES: bool = True  # False en dev local (HTTP)

    # CORS : liste séparée par des virgules, ex: "https://app.babicash.ci,https://dashboard.babicash.ci"
    # Laisser vide ou mettre "*" pour tout autoriser (dev uniquement)
    ALLOWED_ORIGINS: str = "*"

    @field_validator("SECRET_KEY")
    @classmethod
    def secret_key_must_be_changed(cls, v: str) -> str:
        if v == _INSECURE_DEFAULT:
            raise ValueError(
                "SECRET_KEY doit être défini dans .env (valeur par défaut interdite). "
                "Générez une clé avec : python -c \"import secrets; print(secrets.token_urlsafe(64))\""
            )
        if len(v) < 32:
            raise ValueError("SECRET_KEY doit faire au moins 32 caractères.")
        return v

    @property
    def cors_origins(self) -> list[str]:
        if self.ALLOWED_ORIGINS.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
