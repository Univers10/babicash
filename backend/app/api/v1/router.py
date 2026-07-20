from fastapi import APIRouter

from app.api.v1 import (
    abonnements,
    analytics,
    auth,
    boutiques,
    categories,
    dashboard,
    mouvements_stock,
    oauth,
    produits,
    sessions,
    sync,
    tiers,
    users,
    ventes,
)

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(oauth.router, prefix="/auth", tags=["auth"])
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
    mouvements_stock.router,
    prefix="/mouvements-stock",
    tags=["mouvements-stock"],
)
api_router.include_router(
    analytics.router, prefix="/analytics", tags=["analytics"]
)
api_router.include_router(
    abonnements.router, prefix="/abonnements", tags=["abonnements"]
)
api_router.include_router(ventes.router, prefix="/ventes", tags=["ventes"])
api_router.include_router(
    dashboard.router, prefix="/dashboard", tags=["dashboard"]
)
