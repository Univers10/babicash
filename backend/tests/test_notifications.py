"""Tests du centre de notifications ambassadeur (filleul, commission, versement)."""
from decimal import Decimal

import pytest

from app.services import parrainage_service


def _auth(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


async def _setup_amb_et_filleul(
    client,
    session_factory,
    *,
    code: str = "PROMO2026",
    amb_email: str = "amb@promo.ci",
    filleul_email: str = "filleul@boutique.ci",
):
    from sqlalchemy import select

    from app.models import User

    r = await client.post(
        "/api/v1/ambassadeurs/register",
        json={
            "nom": "Amb",
            "email": amb_email,
            "mot_de_passe": "promo1234",
            "telephone": None,
            "code": code,
            "momo_numero": "0700888999",
            "momo_operateur": "wave",
        },
    )
    assert r.status_code == 201, r.text
    amb_token = r.json()["access_token"]
    amb_id = (
        await client.get("/api/v1/ambassadeurs/moi", headers=_auth(amb_token))
    ).json()["id"]

    ro = await client.post(
        "/api/v1/auth/register",
        json={
            "nom": "Filleul",
            "email": filleul_email,
            "mot_de_passe": "boss1234",
            "code_parrainage": code,
        },
    )
    assert ro.status_code == 200, ro.text

    async with session_factory() as db:
        filleul = (
            await db.execute(select(User).where(User.email == filleul_email))
        ).scalar_one()
        filleul_id = str(filleul.id)
    return amb_id, amb_token, filleul_id


@pytest.mark.asyncio
async def test_notification_nouveau_filleul(client, session_factory):
    """L'inscription d'un filleul crée une notification NOUVEAU_FILLEUL chez l'ambassadeur."""
    amb_id, amb_token, _ = await _setup_amb_et_filleul(client, session_factory)

    r = await client.get(
        "/api/v1/ambassadeurs/notifications", headers=_auth(amb_token)
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert len(body) == 1
    assert body[0]["type"] == "NOUVEAU_FILLEUL"
    assert "Filleul" in body[0]["message"]
    assert body[0]["lu"] is False

    non_lues = await client.get(
        "/api/v1/ambassadeurs/notifications/non-lues", headers=_auth(amb_token)
    )
    assert non_lues.json()["count"] == 1


@pytest.mark.asyncio
async def test_notification_commission(client, session_factory):
    """Un paiement confirmé crée une notification COMMISSION chez l'ambassadeur."""
    amb_id, amb_token, filleul_id = await _setup_amb_et_filleul(client, session_factory)

    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )

    r = await client.get(
        "/api/v1/ambassadeurs/notifications", headers=_auth(amb_token)
    )
    types = [n["type"] for n in r.json()]
    assert "COMMISSION" in types
    commission_notif = next(n for n in r.json() if n["type"] == "COMMISSION")
    assert "1000" in commission_notif["message"]  # 20% de 5000


@pytest.mark.asyncio
async def test_notification_versement(client, session_factory):
    """Un versement marqué payé crée une notification VERSEMENT chez l'ambassadeur."""
    amb_id, amb_token, filleul_id = await _setup_amb_et_filleul(client, session_factory)

    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
        lots = await parrainage_service.generer_payouts_semaine(db)
        assert len(lots) == 1
        await parrainage_service.marquer_payout_paye(db, lots[0].id, "REF-TEST-1")

    r = await client.get(
        "/api/v1/ambassadeurs/notifications", headers=_auth(amb_token)
    )
    types = [n["type"] for n in r.json()]
    assert "VERSEMENT" in types
    versement_notif = next(n for n in r.json() if n["type"] == "VERSEMENT")
    assert "1000" in versement_notif["message"]


@pytest.mark.asyncio
async def test_marquer_notification_lue(client, session_factory):
    amb_id, amb_token, _ = await _setup_amb_et_filleul(client, session_factory)

    liste = (
        await client.get(
            "/api/v1/ambassadeurs/notifications", headers=_auth(amb_token)
        )
    ).json()
    notif_id = liste[0]["id"]

    r = await client.post(
        f"/api/v1/ambassadeurs/notifications/{notif_id}/lu", headers=_auth(amb_token)
    )
    assert r.status_code == 204, r.text

    non_lues = await client.get(
        "/api/v1/ambassadeurs/notifications/non-lues", headers=_auth(amb_token)
    )
    assert non_lues.json()["count"] == 0


@pytest.mark.asyncio
async def test_marquer_toutes_notifications_lues(client, session_factory):
    amb_id, amb_token, filleul_id = await _setup_amb_et_filleul(client, session_factory)
    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )

    r = await client.post(
        "/api/v1/ambassadeurs/notifications/lu-tout", headers=_auth(amb_token)
    )
    assert r.status_code == 204, r.text

    non_lues = await client.get(
        "/api/v1/ambassadeurs/notifications/non-lues", headers=_auth(amb_token)
    )
    assert non_lues.json()["count"] == 0


@pytest.mark.asyncio
async def test_notification_isolee_par_ambassadeur(client, session_factory):
    """Un ambassadeur ne voit pas les notifications d'un autre."""
    _, amb1_token, _ = await _setup_amb_et_filleul(
        client, session_factory, code="CODE0001", amb_email="a1@promo.ci",
        filleul_email="f1@boutique.ci",
    )
    _, amb2_token, _ = await _setup_amb_et_filleul(
        client, session_factory, code="CODE0002", amb_email="a2@promo.ci",
        filleul_email="f2@boutique.ci",
    )

    liste2 = (
        await client.get(
            "/api/v1/ambassadeurs/notifications", headers=_auth(amb2_token)
        )
    ).json()
    assert len(liste2) == 1

    notif_id_amb1 = (
        await client.get(
            "/api/v1/ambassadeurs/notifications", headers=_auth(amb1_token)
        )
    ).json()[0]["id"]

    r = await client.post(
        f"/api/v1/ambassadeurs/notifications/{notif_id_amb1}/lu",
        headers=_auth(amb2_token),
    )
    assert r.status_code == 404


@pytest.mark.asyncio
async def test_push_cle_publique_vide_si_non_configure(client, monkeypatch):
    """Sans VAPID configuré, la clé publique est une chaîne vide (push désactivé)."""
    from app.api.v1 import ambassadeurs as ambassadeurs_module

    monkeypatch.setattr(ambassadeurs_module.settings, "VAPID_PUBLIC_KEY", "")

    r = await client.get("/api/v1/ambassadeurs/push/cle-publique")
    assert r.status_code == 200, r.text
    assert r.json()["public_key"] == ""


@pytest.mark.asyncio
async def test_push_cle_publique_reflete_la_config(client, monkeypatch):
    """Quand VAPID est configuré, la clé publique exposée correspond."""
    from app.api.v1 import ambassadeurs as ambassadeurs_module

    monkeypatch.setattr(ambassadeurs_module.settings, "VAPID_PUBLIC_KEY", "cle-de-test")

    r = await client.get("/api/v1/ambassadeurs/push/cle-publique")
    assert r.status_code == 200, r.text
    assert r.json()["public_key"] == "cle-de-test"


@pytest.mark.asyncio
async def test_push_abonner_et_desabonner(client, session_factory):
    _, amb_token, _ = await _setup_amb_et_filleul(client, session_factory)

    r = await client.post(
        "/api/v1/ambassadeurs/push/abonner",
        json={
            "endpoint": "https://push.example.com/sub-1",
            "keys": {"p256dh": "fakep256dh", "auth": "fakeauth"},
        },
        headers=_auth(amb_token),
    )
    assert r.status_code == 204, r.text

    r = await client.post(
        "/api/v1/ambassadeurs/push/desabonner",
        json={"endpoint": "https://push.example.com/sub-1"},
        headers=_auth(amb_token),
    )
    assert r.status_code == 204, r.text
