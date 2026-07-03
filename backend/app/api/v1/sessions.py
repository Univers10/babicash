import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.access import get_authorized_boutique
from app.core.db import get_db
from app.deps import get_current_user
from app.models import SessionCaisse
from app.schemas.auth import CurrentUser
from app.schemas.session import (
    SessionFermerRequest,
    SessionOuvrirRequest,
    SessionOut,
    SessionResume,
)
from app.services import session_service

router = APIRouter()


async def _get_session_in_boutique(
    db: AsyncSession, current_user: CurrentUser, session_id: uuid.UUID
) -> SessionCaisse:
    session = await db.get(SessionCaisse, session_id)
    if session is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Session introuvable"
        )
    await get_authorized_boutique(db, current_user, session.boutique_id)
    return session


@router.post("/ouvrir", response_model=SessionOut, status_code=status.HTTP_201_CREATED)
async def ouvrir_session(
    payload: SessionOuvrirRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SessionCaisse:
    await get_authorized_boutique(db, current_user, payload.boutique_id)

    # Une seule session ouverte par boutique à la fois
    deja_ouverte = (
        await db.execute(
            select(SessionCaisse).where(
                SessionCaisse.boutique_id == payload.boutique_id,
                SessionCaisse.statut == "OUVERT",
            )
        )
    ).scalar_one_or_none()
    if deja_ouverte is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Une session de caisse est déjà ouverte pour cette boutique",
        )

    session = SessionCaisse(
        boutique_id=payload.boutique_id,
        utilisateur_nom=current_user.nom,
        montant_initial=payload.montant_initial,
        statut="OUVERT",
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session


@router.get("/active", response_model=SessionResume | None)
async def session_active(
    boutique_id: uuid.UUID = Query(...),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SessionResume | None:
    await get_authorized_boutique(db, current_user, boutique_id)
    session = (
        await db.execute(
            select(SessionCaisse).where(
                SessionCaisse.boutique_id == boutique_id,
                SessionCaisse.statut == "OUVERT",
            )
        )
    ).scalar_one_or_none()
    if session is None:
        return None
    return await session_service.compute_resume(db, session)


@router.get("/", response_model=list[SessionOut])
async def list_sessions(
    boutique_id: uuid.UUID = Query(...),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[SessionCaisse]:
    await get_authorized_boutique(db, current_user, boutique_id)
    rows = (
        (
            await db.execute(
                select(SessionCaisse)
                .where(SessionCaisse.boutique_id == boutique_id)
                .order_by(SessionCaisse.date_ouverture.desc())
                .limit(limit)
                .offset(offset)
            )
        )
        .scalars()
        .all()
    )
    return list(rows)


@router.get("/{session_id}", response_model=SessionResume)
async def detail_session(
    session_id: uuid.UUID,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SessionResume:
    session = await _get_session_in_boutique(db, current_user, session_id)
    return await session_service.compute_resume(db, session)


@router.post("/{session_id}/fermer", response_model=SessionResume)
async def fermer_session(
    session_id: uuid.UUID,
    payload: SessionFermerRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SessionResume:
    session = await _get_session_in_boutique(db, current_user, session_id)

    # Immuabilité: une session fermée ne peut pas être rouverte/modifiée
    if session.statut == "FERME":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Cette session est déjà fermée",
        )

    session.montant_final_declare = payload.montant_final_declare
    session.statut = "FERME"
    session.date_fermeture = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(session)
    return await session_service.compute_resume(db, session)
