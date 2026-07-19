from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    """Connexion classique (email + mot de passe) — surtout pour le propriétaire."""

    email: EmailStr
    mot_de_passe: str


class LoginPinRequest(BaseModel):
    """Connexion simplifiée (numéro de téléphone + code PIN) — surtout les gérants."""

    telephone: str = Field(min_length=4, max_length=30)
    code_pin: str = Field(pattern=r"^\d{4}$")


class RegisterRequest(BaseModel):
    """Inscription d'un nouveau propriétaire."""

    nom: str = Field(min_length=1, max_length=255)
    email: EmailStr
    mot_de_passe: str = Field(min_length=6, max_length=128)
    telephone: str | None = Field(default=None, max_length=30)


class LoginIdRequest(BaseModel):
    """Connexion par ID propriétaire (UUID)."""

    id_proprietaire: str = Field(min_length=36, max_length=36)
    mot_de_passe: str


class GoogleTokenRequest(BaseModel):
    """Connexion / inscription via Google Sign-In."""

    id_token: str


class AppleTokenRequest(BaseModel):
    """Connexion / inscription via Apple Sign-In (flux web)."""

    identity_token: str
    # Apple ne renvoie le nom qu'à la toute première autorisation, hors du token.
    nom: str | None = Field(default=None, max_length=255)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    boutique_id: str | None = None
    nom: str | None = None
    email: str | None = None
    avatar_url: str | None = None


class CurrentUser(BaseModel):
    id: str
    nom: str
    email: str | None = None
    telephone: str | None = None
    role: str
    boutique_id: str | None = None
