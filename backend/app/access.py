import uuid

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Boutique
from app.schemas.auth import CurrentUser

_FORBIDDEN = HTTPException(
    status_code=status.HTTP_403_FORBIDDEN,
    detail="Accès non autorisé à cette boutique",
)
_NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="Boutique introuvable"
)


async def get_authorized_boutique(
    db: AsyncSession, current_user: CurrentUser, boutique_id: uuid.UUID
) -> Boutique:
    """Récupère une boutique en garantissant le cloisonnement multi-tenant.

    - OWNER : doit être le propriétaire de la boutique.
    - MANAGER : doit être verrouillé sur cette boutique (`boutique_id`).
    """
    # Contrôle basé sur le token AVANT tout accès BD (évite la fuite d'existence)
    if current_user.role == "MANAGER":
        if current_user.boutique_id != str(boutique_id):
            raise _FORBIDDEN
    elif current_user.role != "OWNER":
        raise _FORBIDDEN

    boutique = await db.get(Boutique, boutique_id)
    if boutique is None:
        raise _NOT_FOUND

    # Un propriétaire ne peut accéder qu'à ses propres boutiques
    if current_user.role == "OWNER" and boutique.proprietaire_id != current_user.id:
        raise _FORBIDDEN

    return boutique
