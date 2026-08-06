import pytest
from sqlalchemy import select

from app.models import Ambassadeur, User


def _auth(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


async def _register_ambassadeur(
    client,
    *,
    email: str = "amb@promo.ci",
    code: str = "PROMO2026",
    telephone: str | None = None,
    momo: str = "0700888999",
    operateur: str = "wave",
) -> str:
    resp = await client.post(
        "/api/v1/ambassadeurs/register",
        json={
            "nom": "Ambassadeur",
            "email": email,
            "mot_de_passe": "promo1234",
            "telephone": telephone,
            "code": code,
            "momo_numero": momo,
            "momo_operateur": operateur,
        },
    )
    assert resp.status_code == 201, resp.text
    token = resp.json()["access_token"]
    moi = await client.get("/api/v1/ambassadeurs/moi", headers=_auth(token))
    return moi.json()["id"]


async def _register_owner(
    client, *, email: str, code_parrainage=None, telephone=None
):
    payload = {"nom": "Proprio", "email": email, "mot_de_passe": "boss1234"}
    if telephone is not None:
        payload["telephone"] = telephone
    if code_parrainage is not None:
        payload["code_parrainage"] = code_parrainage
    return await client.post("/api/v1/auth/register", json=payload)


async def _parrain_id(session_factory, email: str):
    async with session_factory() as db:
        user = (
            await db.execute(select(User).where(User.email == email))
        ).scalar_one()
        return user.parraine_par_ambassadeur_id


@pytest.mark.asyncio
async def test_rattachement_ok_code_insensible_casse(client, session_factory):
    amb_id = await _register_ambassadeur(client, code="PROMO2026")
    resp = await _register_owner(
        client, email="filleul@boutique.ci", code_parrainage="promo2026"
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["role"] == "OWNER"
    assert str(await _parrain_id(session_factory, "filleul@boutique.ci")) == amb_id


@pytest.mark.asyncio
async def test_inscription_sans_code(client, session_factory):
    resp = await _register_owner(client, email="solo@boutique.ci")
    assert resp.status_code == 200, resp.text
    assert await _parrain_id(session_factory, "solo@boutique.ci") is None


@pytest.mark.asyncio
async def test_code_inconnu_inscription_ok_sans_parrain(client, session_factory):
    resp = await _register_owner(
        client, email="orphelin@boutique.ci", code_parrainage="INCONNU999"
    )
    assert resp.status_code == 200, resp.text
    assert await _parrain_id(session_factory, "orphelin@boutique.ci") is None


@pytest.mark.asyncio
async def test_code_mal_forme_ignore(client, session_factory):
    resp = await _register_owner(
        client, email="badcode@boutique.ci", code_parrainage="ab"
    )
    assert resp.status_code == 200, resp.text
    assert await _parrain_id(session_factory, "badcode@boutique.ci") is None


@pytest.mark.asyncio
async def test_code_ambassadeur_inactif_ignore(client, session_factory):
    await _register_ambassadeur(client, code="INACTIF01")
    # Désactivation (simule l'action admin de la phase 4).
    async with session_factory() as db:
        amb = (
            await db.execute(
                select(Ambassadeur).where(Ambassadeur.code == "INACTIF01")
            )
        ).scalar_one()
        amb.actif = False
        await db.commit()

    resp = await _register_owner(
        client, email="apresdesactivation@boutique.ci", code_parrainage="INACTIF01"
    )
    assert resp.status_code == 200, resp.text
    assert await _parrain_id(session_factory, "apresdesactivation@boutique.ci") is None


@pytest.mark.asyncio
async def test_auto_parrainage_via_momo_ignore(client, session_factory):
    # Ambassadeur sans téléphone, dont le numéro MoMo servira au filleul.
    await _register_ambassadeur(
        client, email="mixte@promo.ci", code="MIXTE2026", momo="0500777888"
    )
    resp = await _register_owner(
        client,
        email="memepersonne@boutique.ci",
        code_parrainage="MIXTE2026",
        telephone="0500777888",
    )
    assert resp.status_code == 200, resp.text
    # Même personne (numéro MoMo == téléphone) => pas de rattachement.
    assert await _parrain_id(session_factory, "memepersonne@boutique.ci") is None
