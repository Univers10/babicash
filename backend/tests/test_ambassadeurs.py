import pytest

from tests.conftest import login


def _auth(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


_REG = {
    "nom": "Kouassi Ambassadeur",
    "email": "kouassi@promo.ci",
    "mot_de_passe": "promo1234",
    "telephone": "0700111222",
    "code": "kouassi7",  # sera normalisé en majuscules
    "momo_numero": "0700111222",
    "momo_operateur": "wave",  # sera normalisé en majuscules
}


async def _register(client, **overrides) -> dict:
    payload = {**_REG, **overrides}
    resp = await client.post("/api/v1/ambassadeurs/register", json=payload)
    return resp


@pytest.mark.asyncio
async def test_code_disponible_libre(client):
    resp = await client.get("/api/v1/ambassadeurs/code-disponible", params={"code": "promo225"})
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["code"] == "PROMO225"
    assert body["disponible"] is True
    assert body["raison"] is None


@pytest.mark.asyncio
async def test_code_disponible_format_invalide(client):
    resp = await client.get("/api/v1/ambassadeurs/code-disponible", params={"code": "ab"})
    assert resp.status_code == 200, resp.text
    assert resp.json()["disponible"] is False
    assert resp.json()["raison"] == "format"


@pytest.mark.asyncio
async def test_code_disponible_reserve(client):
    resp = await client.get("/api/v1/ambassadeurs/code-disponible", params={"code": "babicash"})
    assert resp.status_code == 200, resp.text
    assert resp.json()["disponible"] is False
    assert resp.json()["raison"] == "reserve"


@pytest.mark.asyncio
async def test_register_ok_et_code_normalise(client):
    resp = await _register(client)
    assert resp.status_code == 201, resp.text
    body = resp.json()
    assert body["role"] == "AMBASSADEUR"
    assert body["boutique_id"] is None
    assert "access_token" in body

    # Le profil expose le code normalisé.
    token = body["access_token"]
    moi = await client.get("/api/v1/ambassadeurs/moi", headers=_auth(token))
    assert moi.status_code == 200, moi.text
    assert moi.json()["code"] == "KOUASSI7"
    assert moi.json()["momo_operateur"] == "WAVE"
    assert moi.json()["actif"] is True


@pytest.mark.asyncio
async def test_register_code_deja_pris(client):
    r1 = await _register(client)
    assert r1.status_code == 201, r1.text

    # Même code (autre casse), autre email => conflit.
    r2 = await _register(client, email="autre@promo.ci", code="KOUASSI7")
    assert r2.status_code == 409, r2.text

    # Et la vérif de dispo le confirme.
    dispo = await client.get(
        "/api/v1/ambassadeurs/code-disponible", params={"code": "kouassi7"}
    )
    assert dispo.json()["disponible"] is False
    assert dispo.json()["raison"] == "pris"


@pytest.mark.asyncio
async def test_register_email_deja_utilise(client):
    r1 = await _register(client)
    assert r1.status_code == 201
    r2 = await _register(client, code="AUTRECODE")
    assert r2.status_code == 400, r2.text


@pytest.mark.asyncio
async def test_register_code_reserve_refuse(client):
    resp = await _register(client, code="admin")
    assert resp.status_code == 400, resp.text


@pytest.mark.asyncio
async def test_register_operateur_invalide(client):
    resp = await _register(client, momo_operateur="paypal")
    assert resp.status_code == 422, resp.text


@pytest.mark.asyncio
async def test_login_ambassadeur(client):
    await _register(client)
    ok = await client.post(
        "/api/v1/ambassadeurs/login",
        json={"email": _REG["email"], "mot_de_passe": _REG["mot_de_passe"]},
    )
    assert ok.status_code == 200, ok.text
    assert ok.json()["role"] == "AMBASSADEUR"

    ko = await client.post(
        "/api/v1/ambassadeurs/login",
        json={"email": _REG["email"], "mot_de_passe": "mauvais"},
    )
    assert ko.status_code == 401, ko.text


@pytest.mark.asyncio
async def test_maj_momo(client):
    token = (await _register(client)).json()["access_token"]
    patch = await client.patch(
        "/api/v1/ambassadeurs/moi",
        json={"momo_numero": "0500999888", "momo_operateur": "orange"},
        headers=_auth(token),
    )
    assert patch.status_code == 200, patch.text
    assert patch.json()["momo_numero"] == "0500999888"
    assert patch.json()["momo_operateur"] == "ORANGE"


@pytest.mark.asyncio
async def test_owner_ne_peut_pas_acceder_espace_ambassadeur(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    resp = await client.get("/api/v1/ambassadeurs/moi", headers=_auth(token))
    assert resp.status_code == 403, resp.text
