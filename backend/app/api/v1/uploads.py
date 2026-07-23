"""Upload d'images (produits, logos de boutique).

Les images arrivent déjà recadrées et compressées côté application
(≈ 800 px, JPEG). Le serveur se contente de valider (type + taille),
d'écrire le fichier dans `static/uploads/<kind>/` et de renvoyer son URL
relative — servie ensuite par le mount `/static`.
"""

import os
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from pydantic import BaseModel

from app.deps import get_current_user
from app.schemas.auth import CurrentUser

router = APIRouter()

# Racine des uploads, alignée sur le mount StaticFiles(directory="static").
_UPLOAD_ROOT = os.path.join("static", "uploads")

# Types acceptés → extension normalisée.
_ALLOWED_TYPES: dict[str, str] = {
    "image/jpeg": "jpg",
    "image/jpg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
}

# Sous-dossiers autorisés (évite le path traversal via `kind`).
_ALLOWED_KINDS = {"produits", "logos"}

# Garde-fou serveur : l'app compresse bien en-dessous, mais on plafonne.
_MAX_BYTES = 6 * 1024 * 1024  # 6 Mo


class UploadResponse(BaseModel):
    url: str


@router.post("/image", response_model=UploadResponse, status_code=status.HTTP_201_CREATED)
async def upload_image(
    file: UploadFile = File(...),
    kind: str = "produits",
    current_user: CurrentUser = Depends(get_current_user),
) -> UploadResponse:
    if kind not in _ALLOWED_KINDS:
        kind = "produits"

    ext = _ALLOWED_TYPES.get((file.content_type or "").lower())
    if ext is None:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Format d'image non supporté (JPEG, PNG ou WebP attendus).",
        )

    content = await file.read()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Fichier vide."
        )
    if len(content) > _MAX_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image trop volumineuse (max 6 Mo).",
        )

    dest_dir = os.path.join(_UPLOAD_ROOT, kind)
    os.makedirs(dest_dir, exist_ok=True)

    filename = f"{uuid.uuid4().hex}.{ext}"
    dest_path = os.path.join(dest_dir, filename)
    with open(dest_path, "wb") as f:
        f.write(content)

    # URL relative — servie par le mount `/static` (hors préfixe /api/v1).
    return UploadResponse(url=f"/static/uploads/{kind}/{filename}")
