"""Endpoints ambassadeurs : inscription, connexion, disponibilité du code, profil."""
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.rate_limit import login_rate_limiter
from app.core.security import create_access_token, hash_password, verify_password
from app.deps import require_ambassadeur
from app.models import Ambassadeur, User
from app.schemas.ambassadeur import (
    AmbassadeurLoginRequest,
    AmbassadeurOut,
    AmbassadeurRegisterRequest,
    CodeDisponibleResponse,
    CommissionOut,
    FilleulOut,
    MomoUpdateRequest,
    MonEspaceOut,
    VersementOut,
)
from app.schemas.auth import CurrentUser, Token
from app.services import ambassadeur_service, parrainage_service

router = APIRouter()

# Messages associés à chaque raison d'indisponibilité de code.
_RAISON_MESSAGE = {
    "format": "Code invalide : 4 à 20 lettres (A-Z) ou chiffres, sans espace.",
    "reserve": "Ce code est réservé et ne peut pas être utilisé.",
    "pris": "Ce code est déjà utilisé par un autre ambassadeur.",
}


def _token_for(user: User) -> Token:
    token = create_access_token(
        subject=str(user.id),
        role=user.role,
        token_version=user.token_version,
    )
    return Token(
        access_token=token,
        role=user.role,
        boutique_id=None,
        nom=user.nom,
        email=user.email,
        avatar_url=user.avatar_url,
    )


@router.get("/code-disponible", response_model=CodeDisponibleResponse)
async def code_disponible(
    code: str, db: AsyncSession = Depends(get_db)
) -> CodeDisponibleResponse:
    """Vérifie en temps réel qu'un code de parrainage est libre et valide."""
    disponible, raison = await ambassadeur_service.code_disponible(db, code)
    return CodeDisponibleResponse(
        code=ambassadeur_service.normaliser_code(code),
        disponible=disponible,
        raison=raison,
    )


@router.post(
    "/register", response_model=Token, status_code=status.HTTP_201_CREATED
)
async def register(
    payload: AmbassadeurRegisterRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Inscription d'un ambassadeur : crée un compte (role=AMBASSADEUR) sans
    boutique ni abonnement, plus son profil ambassadeur avec le code choisi."""
    existing = (
        await db.execute(select(User).where(User.email == payload.email))
    ).scalar_one_or_none()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cet email est déjà utilisé",
        )

    code = ambassadeur_service.normaliser_code(payload.code)
    disponible, raison = await ambassadeur_service.code_disponible(db, code)
    if not disponible:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT
            if raison == "pris"
            else status.HTTP_400_BAD_REQUEST,
            detail=_RAISON_MESSAGE.get(raison, "Code invalide"),
        )

    user = User(
        nom=payload.nom,
        email=payload.email,
        mot_de_passe_hash=hash_password(payload.mot_de_passe),
        telephone=payload.telephone,
        role="AMBASSADEUR",
    )
    db.add(user)
    await db.flush()

    ambassadeur = Ambassadeur(
        user_id=user.id,
        code=code,
        momo_numero=payload.momo_numero,
        momo_operateur=payload.momo_operateur,
    )
    db.add(ambassadeur)

    await db.commit()
    await db.refresh(user)
    return _token_for(user)


@router.post("/login", response_model=Token)
async def login(
    payload: AmbassadeurLoginRequest, db: AsyncSession = Depends(get_db)
) -> Token:
    """Connexion d'un ambassadeur par email + mot de passe."""
    rate_key = f"login:ambassadeur:{payload.email}"

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
        or user.role != "AMBASSADEUR"
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


async def _get_profil(db: AsyncSession, user_id: str) -> Ambassadeur:
    amb = (
        await db.execute(
            select(Ambassadeur).where(Ambassadeur.user_id == uuid.UUID(user_id))
        )
    ).scalar_one_or_none()
    if amb is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profil ambassadeur introuvable",
        )
    return amb


@router.get("/moi", response_model=MonEspaceOut)
async def moi(
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> MonEspaceOut:
    """Synthèse de l'espace ambassadeur (accueil) : profil + solde + totaux."""
    amb = await _get_profil(db, current_user.id)
    synthese = await parrainage_service.synthese(db, amb.id)
    return MonEspaceOut(
        id=str(amb.id),
        nom=current_user.nom,
        email=current_user.email,
        code=amb.code,
        momo_numero=amb.momo_numero,
        momo_operateur=amb.momo_operateur,
        actif=amb.actif,
        **synthese,
    )


@router.get("/filleuls", response_model=list[FilleulOut])
async def filleuls(
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[FilleulOut]:
    """Liste des filleuls de l'ambassadeur avec l'état de leur abonnement."""
    amb = await _get_profil(db, current_user.id)
    return [FilleulOut(**d) for d in await parrainage_service.lister_filleuls(db, amb.id)]


@router.get("/commissions", response_model=list[CommissionOut])
async def commissions(
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[CommissionOut]:
    """Historique des commissions (activité) de l'ambassadeur."""
    amb = await _get_profil(db, current_user.id)
    return [
        CommissionOut(**d)
        for d in await parrainage_service.lister_commissions(db, amb.id)
    ]


@router.get("/versements", response_model=list[VersementOut])
async def versements(
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[VersementOut]:
    """Historique des lots de versement hebdomadaires de l'ambassadeur."""
    amb = await _get_profil(db, current_user.id)
    return [
        VersementOut(**d)
        for d in await parrainage_service.lister_versements(db, amb.id)
    ]


@router.patch("/moi", response_model=AmbassadeurOut)
async def maj_momo(
    payload: MomoUpdateRequest,
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> AmbassadeurOut:
    """Met à jour les coordonnées Mobile Money de versement."""
    amb = await _get_profil(db, current_user.id)
    amb.momo_numero = payload.momo_numero
    amb.momo_operateur = payload.momo_operateur
    await db.commit()
    await db.refresh(amb)
    return AmbassadeurOut(
        id=str(amb.id),
        nom=current_user.nom,
        email=current_user.email,
        code=amb.code,
        momo_numero=amb.momo_numero,
        momo_operateur=amb.momo_operateur,
        actif=amb.actif,
    )
