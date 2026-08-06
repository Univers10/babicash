import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user, require_owner
from app.models import Boutique, RecuConfig
from app.schemas.auth import CurrentUser
from app.schemas.boutique import BoutiqueOut
from app.schemas.crud import BoutiqueCreate, BoutiqueUpdate
from app.schemas.recu_config import RecuConfigOut, RecuConfigUpdate
from app.services import abonnement_service

router = APIRouter()


@router.get("/", response_model=list[BoutiqueOut])
async def list_boutiques(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[Boutique]:
    stmt = select(Boutique)
    if current_user.role == "OWNER":
        stmt = stmt.where(Boutique.proprietaire_id == current_user.id)
    elif current_user.boutique_id is not None:
        # Le gérant est verrouillé sur sa boutique
        stmt = stmt.where(Boutique.id == current_user.boutique_id)
    else:
        return []

    rows = (await db.execute(stmt.order_by(Boutique.nom))).scalars().all()
    return list(rows)


@router.post(
    "/", response_model=BoutiqueOut, status_code=status.HTTP_201_CREATED
)
async def create_boutique(
    payload: BoutiqueCreate,
    current_user: CurrentUser = Depends(require_owner),
    db: AsyncSession = Depends(get_db),
) -> Boutique:
    """Crée une boutique. La 1ère est incluse dans tous les plans ; à partir
    de la 2e, un abonnement PRO actif est requis."""
    autorise, abo, nb_boutiques = await abonnement_service.peut_creer_boutique(
        db, current_user.id
    )
    if not autorise:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail={
                "code": "ABONNEMENT_REQUIS",
                "message": "Passez au plan PRO pour créer une boutique supplémentaire.",
                "nb_boutiques": nb_boutiques,
                "plan": abo.plan,
            },
        )

    boutique = Boutique(
        nom=payload.nom,
        proprietaire_id=current_user.id,
        adresse=payload.adresse,
        telephone=payload.telephone,
        type_commerce=payload.type_commerce,
    )
    db.add(boutique)
    await db.commit()
    await db.refresh(boutique)
    return boutique


@router.get("/{boutique_id}", response_model=BoutiqueOut)
async def get_boutique(
    boutique_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Boutique:
    return await get_authorized_boutique(db, current_user, boutique_id)


@router.patch("/{boutique_id}", response_model=BoutiqueOut)
async def update_boutique(
    boutique_id: uuid.UUID,
    payload: BoutiqueUpdate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Boutique:
    """Modifie une boutique. OWNER et MANAGER peuvent tous deux gérer les
    informations de leur boutique ; `get_authorized_boutique` verrouille
    chacun sur son propre périmètre."""
    boutique = await get_authorized_boutique(db, current_user, boutique_id)
    if payload.nom is not None:
        boutique.nom = payload.nom
    if payload.adresse is not None:
        boutique.adresse = payload.adresse
    if payload.telephone is not None:
        boutique.telephone = payload.telephone
    if payload.type_commerce is not None:
        boutique.type_commerce = payload.type_commerce
    if payload.logo_url is not None:
        boutique.logo_url = payload.logo_url
    await db.commit()
    await db.refresh(boutique)
    return boutique


# ----- Personnalisation du reçu (1:1 par boutique) -----
@router.get("/{boutique_id}/recu-config", response_model=RecuConfigOut | None)
async def get_recu_config(
    boutique_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> RecuConfig | None:
    """Retourne la personnalisation du reçu de la boutique, ou `null` si aucune
    n'a encore été enregistrée (le client applique alors ses valeurs par défaut
    sans écraser une éventuelle config locale)."""
    await get_authorized_boutique(db, current_user, boutique_id)
    return await db.get(RecuConfig, boutique_id)


@router.put("/{boutique_id}/recu-config", response_model=RecuConfigOut)
async def put_recu_config(
    boutique_id: uuid.UUID,
    payload: RecuConfigUpdate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> RecuConfig:
    """Enregistre (upsert) la personnalisation du reçu. OWNER comme MANAGER
    peuvent la modifier pour leur boutique."""
    await get_authorized_boutique(db, current_user, boutique_id)
    config = await db.get(RecuConfig, boutique_id)
    if config is None:
        config = RecuConfig(boutique_id=boutique_id)
        db.add(config)
    config.nom_boutique = payload.nom_boutique
    config.adresse = payload.adresse
    config.telephone = payload.telephone
    config.entete = payload.entete
    config.pied_message = payload.pied_message
    config.afficher_logo = payload.afficher_logo
    config.afficher_vendeur = payload.afficher_vendeur
    await db.commit()
    await db.refresh(config)
    return config
