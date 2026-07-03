from fastapi import APIRouter

from app.api.v1 import (
    analytics,
    auth,
    boutiques,
    categories,
    produits,
    sessions,
    sync,
    tiers,
    users,
)

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(boutiques.router, prefix="/boutiques", tags=["boutiques"])
api_router.include_router(produits.router, prefix="/produits", tags=["produits"])
api_router.include_router(
    categories.router, prefix="/categories", tags=["categories"]
)
api_router.include_router(tiers.router, prefix="/tiers", tags=["tiers"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(sessions.router, prefix="/sessions", tags=["sessions"])
api_router.include_router(sync.router, prefix="/sync", tags=["sync"])
api_router.include_router(
    analytics.router, prefix="/analytics", tags=["analytics"]
)
