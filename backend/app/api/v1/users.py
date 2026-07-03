import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.core.security import hash_password, hash_pin
from app.deps import get_current_user, require_owner
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
        # Un OWNER sans boutique_id ne peut pas être modifié via cette route
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cet utilisateur n'est pas rattaché à une boutique",
        )
    # Vérifie que le gérant appartient à une boutique du propriétaire connecté
    await get_authorized_boutique(db, current_user, user.boutique_id)
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


@router.get("/", response_model=list[UserOut])
async def list_managers(
    boutique_id: uuid.UUID = Query(...),
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> list[User]:
    await get_authorized_boutique(db, current_user, boutique_id)
    rows = (
        (
            await db.execute(
                select(User)
                .where(User.boutique_id == boutique_id)
                .order_by(User.nom)
            )
        )
        .scalars()
        .all()
    )
    return list(rows)


@router.post("/", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_manager(
    payload: UserCreate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> User:
    # Un propriétaire ne crée que des gérants (MANAGER) sur ses propres boutiques
    if payload.role != "MANAGER":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Seuls des comptes MANAGER peuvent être créés ici",
        )
    if payload.boutique_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="boutique_id requis pour un gérant",
        )
    await get_authorized_boutique(db, current_user, payload.boutique_id)

    user = User(
        nom=payload.nom,
        telephone=payload.telephone,
        code_pin_hash=hash_pin(payload.code_pin),
        email=payload.email,
        mot_de_passe_hash=(
            hash_password(payload.mot_de_passe) if payload.mot_de_passe else None
        ),
        role="MANAGER",
        boutique_id=payload.boutique_id,
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
    current_user: CurrentUser = Depends(require_owner),
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
    if payload.actif is not None:
        user.actif = payload.actif
    if payload.boutique_id is not None:
        # Réaffectation: vérifier que la nouvelle boutique appartient au propriétaire
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
