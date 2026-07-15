from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.v1.router import api_router
from app.core.config import settings

app = FastAPI(title=settings.PROJECT_NAME)

# CORS — refuser "*" avec credentials en production
cors_origins = settings.cors_origins
allow_credentials = True
if cors_origins == ["*"]:
    allow_credentials = False  # le navigateur rejette "*" + credentials

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_PREFIX)

# ── Admin backoffice ────────────────────────────────────────────────
from app.admin.routes import router as admin_router
from app.admin.auth import router as admin_auth_router
from app.admin.backup_routes import router as backup_router

app.mount("/static", StaticFiles(directory="static"), name="static")
app.include_router(admin_auth_router, prefix="/admin")
app.include_router(admin_router, prefix="/admin")
app.include_router(backup_router, prefix="/admin")


@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    return {"status": "ok", "service": settings.PROJECT_NAME}
