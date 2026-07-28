from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models import CommissionParrainage, Payout, User
from app.services import parrainage_service


def _auth(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


async def _setup(client, session_factory, *, code="PROMO2026", amb_email="amb@promo.ci",
                 filleul_email="filleul@boutique.ci"):
    r = await client.post(
        "/api/v1/ambassadeurs/register",
        json={
            "nom": "Amb", "email": amb_email, "mot_de_passe": "promo1234",
            "telephone": None, "code": code,
            "momo_numero": "0700888999", "momo_operateur": "wave",
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
            "nom": "Filleul", "email": filleul_email,
            "mot_de_passe": "boss1234", "code_parrainage": code,
        },
    )
    assert ro.status_code == 200, ro.text
    async with session_factory() as db:
        filleul_id = str(
            (await db.execute(select(User).where(User.email == filleul_email)))
            .scalar_one().id
        )
    return amb_id, amb_token, filleul_id


@pytest.mark.asyncio
async def test_generer_et_payer_payout(client, session_factory):
    _, amb_token, filleul_id = await _setup(client, session_factory)
    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
        lots = await parrainage_service.generer_payouts_semaine(db)
    assert len(lots) == 1
    assert lots[0].montant_total == Decimal("1000")
    assert lots[0].statut == "A_PAYER"

    # La commission est rattachée au lot.
    async with session_factory() as db:
        c = (await db.execute(select(CommissionParrainage))).scalar_one()
        assert c.payout_id is not None
        payout_id = (await db.execute(select(Payout))).scalar_one().id

    # L'endpoint ambassadeur voit le versement.
    v = await client.get("/api/v1/ambassadeurs/versements", headers=_auth(amb_token))
    assert v.status_code == 200, v.text
    assert len(v.json()) == 1
    assert v.json()[0]["statut"] == "A_PAYER"

    # Le solde à recevoir tombe à 0 (commission affectée à un lot).
    moi = await client.get("/api/v1/ambassadeurs/moi", headers=_auth(amb_token))
    assert Decimal(str(moi.json()["solde_a_recevoir"])) == Decimal("0")
    assert Decimal(str(moi.json()["total_gagne"])) == Decimal("1000")

    # Paiement du lot.
    async with session_factory() as db:
        payout = await parrainage_service.marquer_payout_paye(db, payout_id, "TX-123")
    assert payout.statut == "PAYE"
    assert payout.reference_transfert == "TX-123"
    async with session_factory() as db:
        c = (await db.execute(select(CommissionParrainage))).scalar_one()
        assert c.statut == "PAYEE"


@pytest.mark.asyncio
async def test_seuil_minimum_reporte(client, session_factory):
    _, _, filleul_id = await _setup(client, session_factory)
    async with session_factory() as db:
        # KIOSQUE 2000 => commission 400
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "KIOSQUE", Decimal("2000.00")
        )
        lots = await parrainage_service.generer_payouts_semaine(
            db, seuil_min=Decimal("1000")
        )
    assert lots == []
    async with session_factory() as db:
        assert (await db.execute(select(Payout))).scalars().all() == []


@pytest.mark.asyncio
async def test_generer_idempotent_et_fusion(client, session_factory):
    _, _, filleul_id = await _setup(client, session_factory)
    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
        await parrainage_service.generer_payouts_semaine(db)
        # Re-générer sans nouvelle commission : aucun nouveau lot.
        lots2 = await parrainage_service.generer_payouts_semaine(db)
    assert lots2 == []

    async with session_factory() as db:
        # Une nouvelle commission (renouvellement) rejoint le lot de la semaine.
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
        lots3 = await parrainage_service.generer_payouts_semaine(db)
    assert len(lots3) == 1
    assert lots3[0].montant_total == Decimal("2000")

    async with session_factory() as db:
        payouts = (await db.execute(select(Payout))).scalars().all()
        assert len(payouts) == 1  # fusionné, pas de doublon
