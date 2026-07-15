import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.core.security import hash_password, hash_pin
from app.deps import get_current_user
from app.models import User
from app.schemas.auth import CurrentUser
from app.schemas.crud import SetPinRequest, UserCreate, UserOut, UserUpdate

router = APIRouter()


async def _get_managed_user(
    db: AsyncSession, current_user: CurrentUser, user_id: uuid.UUID
) -> User:
    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur introuvable"
        )
    if user.boutique_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cet utilisateur n'est pas rattaché à une boutique",
        )
    await get_authorized_boutique(db, current_user, user.boutique_id)
    return user


# ── Profil personnel ────────────────────────────────────────────────────────

@router.get("/me", response_model=UserOut)
async def get_my_profile(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Retourne le profil de l'utilisateur connecté."""
    user = await db.get(User, uuid.UUID(current_user.id))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur introuvable"
        )
    return user


@router.patch("/me", response_model=UserOut)
async def update_my_profile(
    payload: UserUpdate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Permet à l'utilisateur connecté de modifier son propre profil."""
    user = await db.get(User, uuid.UUID(current_user.id))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur introuvable"
        )
    if payload.nom is not None:
        user.nom = payload.nom
    if payload.telephone is not None:
        user.telephone = payload.telephone
    if payload.mot_de_passe is not None:
        user.mot_de_passe_hash = hash_password(payload.mot_de_passe)
        user.token_version = user.token_version + 1
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ce numéro de téléphone (ou email) est déjà utilisé",
        )
    await db.refresh(user)
    return user


@router.put("/me/pin", response_model=UserOut)
async def set_my_pin(
    payload: SetPinRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Permet à l'utilisateur connecté de définir/changer son propre code PIN."""
    user = await db.get(User, uuid.UUID(current_user.id))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur introuvable"
        )
    user.code_pin_hash = hash_pin(payload.code_pin)
    await db.commit()
    await db.refresh(user)
    return user


# ── Gestion équipe (OWNER et MANAGER) ──────────────────────────────────────

@router.get("/", response_model=list[UserOut])
async def list_managers(
    boutique_id: uuid.UUID | None = Query(default=None),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[User]:
    """Liste les utilisateurs d'une boutique.

    - OWNER : fournit boutique_id en query param.
    - MANAGER : utilise automatiquement son propre boutique_id.
    """
    if current_user.role == "MANAGER":
        if current_user.boutique_id is None:
            return []
        effective_id = uuid.UUID(current_user.boutique_id)
    else:
        if boutique_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="boutique_id requis",
            )
        effective_id = boutique_id

    await get_authorized_boutique(db, current_user, effective_id)
    rows = (
        await db.execute(
            select(User).where(User.boutique_id == effective_id).order_by(User.nom)
        )
    ).scalars().all()
    return list(rows)


@router.post("/", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_manager(
    payload: UserCreate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Crée un compte gérant (MANAGER uniquement).

    - OWNER : peut spécifier boutique_id dans le corps.
    - MANAGER : son propre boutique_id est utilisé automatiquement.
    """
    if payload.role != "MANAGER":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Seuls des comptes MANAGER peuvent être créés ici",
        )

    if current_user.role == "MANAGER":
        if current_user.boutique_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Manager sans boutique associée",
            )
        effective_id = uuid.UUID(current_user.boutique_id)
    else:
        if payload.boutique_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="boutique_id requis pour un gérant",
            )
        effective_id = payload.boutique_id

    await get_authorized_boutique(db, current_user, effective_id)

    # Vérifier la limite de gérants
    from app.models import Abonnement, Boutique
    from app.services.abonnement_service import PLAN_CATALOG
    from sqlalchemy import func

    owner_id = None
    boutique = await db.get(Boutique, effective_id)
    if boutique:
        owner_id = boutique.proprietaire_id

    if owner_id:
        abo = (
            await db.execute(
                select(Abonnement).where(Abonnement.proprietaire_id == owner_id)
            )
        ).scalar_one_or_none()

        if abo:
            cfg = PLAN_CATALOG.get(abo.plan, {})
            nb_gerants_max = cfg.get("nb_gerants_max", 1)

            nb_gerants_actuels = (
                await db.execute(
                    select(func.count(User.id)).where(
                        User.boutique_id == effective_id,
                        User.role == "MANAGER",
                    )
                )
            ).scalar_one()

            if nb_gerants_actuels >= nb_gerants_max:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Limite de {nb_gerants_max} gérant(s) atteinte pour le plan {abo.plan}",
                )

    user = User(
        nom=payload.nom,
        telephone=payload.telephone,
        code_pin_hash=hash_pin(payload.code_pin),
        email=payload.email,
        mot_de_passe_hash=(
            hash_password(payload.mot_de_passe) if payload.mot_de_passe else None
        ),
        role="MANAGER",
        boutique_id=effective_id,
    )
    db.add(user)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ce numéro de téléphone (ou email) est déjà utilisé",
        )
    await db.refresh(user)
    return user


@router.patch("/{user_id}", response_model=UserOut)
async def update_manager(
    user_id: uuid.UUID,
    payload: UserUpdate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    user = await _get_managed_user(db, current_user, user_id)

    if payload.nom is not None:
        user.nom = payload.nom
    if payload.telephone is not None:
        user.telephone = payload.telephone
    if payload.code_pin is not None:
        user.code_pin_hash = hash_pin(payload.code_pin)
    if payload.mot_de_passe is not None:
        user.mot_de_passe_hash = hash_password(payload.mot_de_passe)
        user.token_version = user.token_version + 1
    if payload.actif is not None:
        user.actif = payload.actif
    if payload.boutique_id is not None:
        await get_authorized_boutique(db, current_user, payload.boutique_id)
        user.boutique_id = payload.boutique_id

    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ce numéro de téléphone (ou email) est déjà utilisé",
        )
    await db.refresh(user)
    return user


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_manager(
    user_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    """Supprime un gérant.

    - MANAGER ne peut pas supprimer un OWNER.
    - Personne ne peut supprimer son propre compte.
    """
    user = await _get_managed_user(db, current_user, user_id)

    if user.role == "OWNER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Impossible de supprimer un propriétaire",
        )
    if str(user.id) == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Vous ne pouvez pas supprimer votre propre compte",
        )

    await db.delete(user)
    await db.commit()
