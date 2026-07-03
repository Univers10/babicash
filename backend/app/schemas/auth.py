from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    """Connexion classique (email + mot de passe) — surtout pour le propriétaire."""

    email: EmailStr
    mot_de_passe: str


class LoginPinRequest(BaseModel):
    """Connexion simplifiée (numéro de téléphone + code PIN) — surtout les gérants."""

    telephone: str = Field(min_length=4, max_length=30)
    code_pin: str = Field(pattern=r"^\d{4}$")


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    boutique_id: str | None = None
    nom: str | None = None


class CurrentUser(BaseModel):
    id: str
    nom: str
    email: str | None = None
    telephone: str | None = None
    role: str
    boutique_id: str | None = None
