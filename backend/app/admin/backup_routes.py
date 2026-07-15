"""Routes admin pour la gestion des backups."""
from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates

from app.admin.deps import require_admin
from app.schemas.auth import CurrentUser
from app.services.backup_service import (
    creer_backup,
    lister_backups,
    restaurer_backup,
    supprimer_backup,
)

router = APIRouter()
templates = Jinja2Templates(directory="templates")


@router.get("/backups", response_class=HTMLResponse)
async def backups_page(
    request: Request,
    current_user: CurrentUser = Depends(require_admin),
):
    backups = lister_backups()
    return templates.TemplateResponse(request, "backups/list.html", {
        "user": current_user,
        "backups": backups,
    })


@router.post("/backups/create")
async def backups_create(
    current_user: CurrentUser = Depends(require_admin),
):
    creer_backup()
    return RedirectResponse(url="/admin/backups", status_code=303)


@router.post("/backups/restore/{nom_fichier}")
async def backups_restore(
    nom_fichier: str,
    current_user: CurrentUser = Depends(require_admin),
):
    restaurer_backup(nom_fichier)
    return RedirectResponse(url="/admin/backups", status_code=303)


@router.post("/backups/delete/{nom_fichier}")
async def backups_delete(
    nom_fichier: str,
    current_user: CurrentUser = Depends(require_admin),
):
    supprimer_backup(nom_fichier)
    return RedirectResponse(url="/admin/backups", status_code=303)
