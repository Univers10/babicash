"""Endpoints ambassadeurs : inscription, connexion, disponibilité du code, profil."""
import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
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
    NonLuesOut,
    NotificationOut,
    PushSubscriptionRequest,
    PushUnsubscribeRequest,
    VapidPublicKeyOut,
    VersementOut,
)
from app.schemas.auth import CurrentUser, Token
from app.services import ambassadeur_service, notification_service, parrainage_service

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
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[FilleulOut]:
    """Liste des filleuls de l'ambassadeur avec l'état de leur abonnement."""
    amb = await _get_profil(db, current_user.id)
    return [
        FilleulOut(**d)
        for d in await parrainage_service.lister_filleuls(
            db, amb.id, limit=limit, offset=offset
        )
    ]


@router.get("/commissions", response_model=list[CommissionOut])
async def commissions(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[CommissionOut]:
    """Historique des commissions (activité) de l'ambassadeur."""
    amb = await _get_profil(db, current_user.id)
    return [
        CommissionOut(**d)
        for d in await parrainage_service.lister_commissions(
            db, amb.id, limit=limit, offset=offset
        )
    ]


@router.get("/versements", response_model=list[VersementOut])
async def versements(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[VersementOut]:
    """Historique des lots de versement hebdomadaires de l'ambassadeur."""
    amb = await _get_profil(db, current_user.id)
    return [
        VersementOut(**d)
        for d in await parrainage_service.lister_versements(
            db, amb.id, limit=limit, offset=offset
        )
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


# ── Notifications ─────────────────────────────────────────────────────


@router.get("/notifications", response_model=list[NotificationOut])
async def notifications(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> list[NotificationOut]:
    """Centre de notifications de l'ambassadeur (nouveau filleul, commission, versement)."""
    amb = await _get_profil(db, current_user.id)
    rows = await notification_service.lister_notifications(
        db, amb.id, limit=limit, offset=offset
    )
    return [
        NotificationOut(
            id=str(n.id),
            type=n.type,
            titre=n.titre,
            message=n.message,
            lu=n.lu,
            date_creation=n.date_creation,
        )
        for n in rows
    ]


@router.get("/notifications/non-lues", response_model=NonLuesOut)
async def notifications_non_lues(
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> NonLuesOut:
    """Nombre de notifications non lues (badge)."""
    amb = await _get_profil(db, current_user.id)
    count = await notification_service.compter_non_lues(db, amb.id)
    return NonLuesOut(count=count)


@router.post("/notifications/{notif_id}/lu", status_code=status.HTTP_204_NO_CONTENT)
async def marquer_notification_lue(
    notif_id: uuid.UUID,
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> None:
    amb = await _get_profil(db, current_user.id)
    ok = await notification_service.marquer_lue(db, amb.id, notif_id)
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Notification introuvable"
        )


@router.post("/notifications/lu-tout", status_code=status.HTTP_204_NO_CONTENT)
async def marquer_toutes_notifications_lues(
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> None:
    amb = await _get_profil(db, current_user.id)
    await notification_service.marquer_toutes_lues(db, amb.id)


# ── Notifications push (Web Push) ────────────────────────────────────


@router.get("/push/cle-publique", response_model=VapidPublicKeyOut)
async def push_cle_publique() -> VapidPublicKeyOut:
    """Clé publique VAPID à utiliser côté navigateur pour s'abonner au push.

    Chaîne vide si le push n'est pas configuré côté serveur (les
    notifications restent disponibles dans le centre in-app).
    """
    return VapidPublicKeyOut(public_key=settings.VAPID_PUBLIC_KEY)


@router.post("/push/abonner", status_code=status.HTTP_204_NO_CONTENT)
async def push_abonner(
    payload: PushSubscriptionRequest,
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> None:
    """Enregistre l'abonnement Web Push du navigateur de l'ambassadeur."""
    amb = await _get_profil(db, current_user.id)
    await notification_service.enregistrer_subscription(
        db,
        amb.id,
        endpoint=payload.endpoint,
        p256dh=payload.keys.p256dh,
        auth=payload.keys.auth,
    )


@router.post("/push/desabonner", status_code=status.HTTP_204_NO_CONTENT)
async def push_desabonner(
    payload: PushUnsubscribeRequest,
    current_user: CurrentUser = Depends(require_ambassadeur),
    db: AsyncSession = Depends(get_db),
) -> None:
    amb = await _get_profil(db, current_user.id)
    await notification_service.supprimer_subscription(db, amb.id, payload.endpoint)
