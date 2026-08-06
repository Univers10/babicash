from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models import Ambassadeur, CommissionParrainage, PaiementAbonnement, User
from app.services import abonnement_service, parrainage_service


def _auth(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


async def _setup_amb_et_filleul(
    client,
    session_factory,
    *,
    code: str = "PROMO2026",
    amb_email: str = "amb@promo.ci",
    filleul_email: str = "filleul@boutique.ci",
    avec_code: bool = True,
):
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

    payload = {"nom": "Filleul", "email": filleul_email, "mot_de_passe": "boss1234"}
    if avec_code:
        payload["code_parrainage"] = code
    ro = await client.post("/api/v1/auth/register", json=payload)
    assert ro.status_code == 200, ro.text

    async with session_factory() as db:
        filleul = (
            await db.execute(select(User).where(User.email == filleul_email))
        ).scalar_one()
        filleul_id = str(filleul.id)
    return amb_id, amb_token, filleul_id


@pytest.mark.asyncio
async def test_commission_creee_sur_plan_payant(client, session_factory):
    amb_id, _, filleul_id = await _setup_amb_et_filleul(client, session_factory)
    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )

    async with session_factory() as db:
        comms = (await db.execute(select(CommissionParrainage))).scalars().all()
        assert len(comms) == 1
        c = comms[0]
        assert c.montant_commission == Decimal("1000")  # 20% de 5000
        assert c.statut == "VALIDEE"
        assert str(c.ambassadeur_id) == amb_id


@pytest.mark.asyncio
async def test_pas_de_commission_sans_parrain(client, session_factory):
    _, _, filleul_id = await _setup_amb_et_filleul(
        client, session_factory, avec_code=False
    )
    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
    async with session_factory() as db:
        assert (await db.execute(select(CommissionParrainage))).scalars().all() == []


@pytest.mark.asyncio
async def test_pas_de_commission_plan_free(client, session_factory):
    _, _, filleul_id = await _setup_amb_et_filleul(client, session_factory)
    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "FREE", Decimal("0.00")
        )
    async with session_factory() as db:
        assert (await db.execute(select(CommissionParrainage))).scalars().all() == []


@pytest.mark.asyncio
async def test_pas_de_commission_ambassadeur_inactif(client, session_factory):
    _, _, filleul_id = await _setup_amb_et_filleul(client, session_factory)
    async with session_factory() as db:
        amb = (
            await db.execute(select(Ambassadeur).where(Ambassadeur.code == "PROMO2026"))
        ).scalar_one()
        amb.actif = False
        await db.commit()

    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
    async with session_factory() as db:
        assert (await db.execute(select(CommissionParrainage))).scalars().all() == []


@pytest.mark.asyncio
async def test_pas_de_commission_hors_fenetre_12_mois(client, session_factory):
    _, _, filleul_id = await _setup_amb_et_filleul(client, session_factory)
    # Premier paiement payant il y a 400 jours (hors des 12 mois).
    vieux = datetime.now(timezone.utc).replace(tzinfo=None) - timedelta(days=400)
    async with session_factory() as db:
        db.add(
            PaiementAbonnement(
                proprietaire_id=filleul_id,
                plan="BOUTIQUE",
                montant=Decimal("5000.00"),
                date_paiement=vieux,
            )
        )
        await db.commit()

    async with session_factory() as db:
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )
    async with session_factory() as db:
        assert (await db.execute(select(CommissionParrainage))).scalars().all() == []


@pytest.mark.asyncio
async def test_dashboard_endpoints(client, session_factory):
    amb_id, amb_token, filleul_id = await _setup_amb_et_filleul(client, session_factory)
    async with session_factory() as db:
        await abonnement_service.upgrader_plan(db, filleul_id, "BOUTIQUE")
        await parrainage_service.confirmer_paiement(
            db, filleul_id, "BOUTIQUE", Decimal("5000.00")
        )

    moi = await client.get("/api/v1/ambassadeurs/moi", headers=_auth(amb_token))
    assert moi.status_code == 200, moi.text
    body = moi.json()
    assert body["nb_filleuls"] == 1
    assert body["nb_filleuls_payants"] == 1
    assert Decimal(str(body["solde_a_recevoir"])) == Decimal("1000")
    assert Decimal(str(body["total_gagne"])) == Decimal("1000")

    fill = await client.get("/api/v1/ambassadeurs/filleuls", headers=_auth(amb_token))
    assert fill.status_code == 200, fill.text
    assert len(fill.json()) == 1
    assert fill.json()[0]["plan"] == "BOUTIQUE"
    assert Decimal(str(fill.json()[0]["commission_cumulee"])) == Decimal("1000")

    comm = await client.get(
        "/api/v1/ambassadeurs/commissions", headers=_auth(amb_token)
    )
    assert comm.status_code == 200, comm.text
    assert len(comm.json()) == 1
    assert comm.json()[0]["filleul_nom"] == "Filleul"
    assert comm.json()[0]["statut"] == "VALIDEE"
