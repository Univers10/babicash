"""Notifications ambassadeur : centre in-app + envoi Web Push (best-effort).

Une notification est toujours enregistrée en base (visible dans le centre de
notifications du PWA ambassadeur). L'envoi push (navigateur) est une couche
supplémentaire, non bloquante : si les clés VAPID ne sont pas configurées, ou
si l'envoi échoue, la notification in-app reste disponible normalement.
"""
import json
import logging
import uuid

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models import Notification, PushSubscription

logger = logging.getLogger(__name__)

TYPE_NOUVEAU_FILLEUL = "NOUVEAU_FILLEUL"
TYPE_COMMISSION = "COMMISSION"
TYPE_VERSEMENT = "VERSEMENT"


async def _envoyer_push(
    db: AsyncSession, ambassadeur_id: uuid.UUID, titre: str, message: str
) -> None:
    """Envoie une notification push à tous les abonnements de l'ambassadeur.

    Best-effort : les erreurs réseau/serveur push n'interrompent jamais le
    flux appelant. Les abonnements expirés (404/410) sont supprimés.
    """
    if not settings.VAPID_PRIVATE_KEY or not settings.VAPID_PUBLIC_KEY:
        return

    from pywebpush import WebPushException, webpush

    subs = (
        await db.execute(
            select(PushSubscription).where(
                PushSubscription.ambassadeur_id == ambassadeur_id
            )
        )
    ).scalars().all()
    if not subs:
        return

    payload = json.dumps({"title": titre, "body": message})
    for sub in subs:
        try:
            webpush(
                subscription_info={
                    "endpoint": sub.endpoint,
                    "keys": {"p256dh": sub.p256dh, "auth": sub.auth},
                },
                data=payload,
                vapid_private_key=settings.VAPID_PRIVATE_KEY,
                vapid_claims={"sub": settings.VAPID_CLAIMS_EMAIL},
            )
        except WebPushException as exc:
            status_code = getattr(exc.response, "status_code", None)
            if status_code in (404, 410):
                await db.execute(
                    delete(PushSubscription).where(PushSubscription.id == sub.id)
                )
            else:
                logger.warning(
                    "Échec envoi push ambassadeur %s : %s", ambassadeur_id, exc
                )
        except Exception:  # pragma: no cover - défense en profondeur
            logger.exception(
                "Erreur inattendue lors de l'envoi push ambassadeur %s", ambassadeur_id
            )


async def creer_notification(
    db: AsyncSession,
    ambassadeur_id: uuid.UUID,
    type_: str,
    titre: str,
    message: str,
) -> Notification:
    """Enregistre une notification in-app et tente un envoi push (best-effort).

    Ne committe pas : à intégrer dans la transaction de l'appelant.
    """
    notif = Notification(
        ambassadeur_id=ambassadeur_id, type=type_, titre=titre, message=message
    )
    db.add(notif)
    await db.flush()
    await _envoyer_push(db, ambassadeur_id, titre, message)
    return notif


async def lister_notifications(
    db: AsyncSession,
    ambassadeur_id: uuid.UUID,
    *,
    limit: int = 50,
    offset: int = 0,
) -> list[Notification]:
    return (
        await db.execute(
            select(Notification)
            .where(Notification.ambassadeur_id == ambassadeur_id)
            .order_by(Notification.date_creation.desc())
            .limit(limit)
            .offset(offset)
        )
    ).scalars().all()


async def compter_non_lues(db: AsyncSession, ambassadeur_id: uuid.UUID) -> int:
    count = (
        await db.execute(
            select(func.count(Notification.id)).where(
                Notification.ambassadeur_id == ambassadeur_id,
                Notification.lu.is_(False),
            )
        )
    ).scalar_one()
    return int(count)


async def marquer_lue(
    db: AsyncSession, ambassadeur_id: uuid.UUID, notif_id: uuid.UUID
) -> bool:
    notif = await db.get(Notification, notif_id)
    if notif is None or notif.ambassadeur_id != ambassadeur_id:
        return False
    notif.lu = True
    await db.commit()
    return True


async def marquer_toutes_lues(db: AsyncSession, ambassadeur_id: uuid.UUID) -> None:
    await db.execute(
        update(Notification)
        .where(
            Notification.ambassadeur_id == ambassadeur_id,
            Notification.lu.is_(False),
        )
        .values(lu=True)
    )
    await db.commit()


async def enregistrer_subscription(
    db: AsyncSession,
    ambassadeur_id: uuid.UUID,
    endpoint: str,
    p256dh: str,
    auth: str,
) -> PushSubscription:
    """Enregistre (ou met à jour) un abonnement Web Push."""
    existing = (
        await db.execute(
            select(PushSubscription).where(PushSubscription.endpoint == endpoint)
        )
    ).scalar_one_or_none()
    if existing is not None:
        existing.ambassadeur_id = ambassadeur_id
        existing.p256dh = p256dh
        existing.auth = auth
        await db.commit()
        await db.refresh(existing)
        return existing

    sub = PushSubscription(
        ambassadeur_id=ambassadeur_id, endpoint=endpoint, p256dh=p256dh, auth=auth
    )
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub


async def supprimer_subscription(
    db: AsyncSession, ambassadeur_id: uuid.UUID, endpoint: str
) -> None:
    await db.execute(
        delete(PushSubscription).where(
            PushSubscription.ambassadeur_id == ambassadeur_id,
            PushSubscription.endpoint == endpoint,
        )
    )
    await db.commit()
