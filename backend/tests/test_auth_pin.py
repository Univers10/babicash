import pytest

from tests.conftest import login, login_pin


@pytest.mark.asyncio
async def test_login_pin_ok(client, seeded):
    resp = await client.post(
        "/api/v1/auth/login-pin",
        json={
            "telephone": seeded["manager_telephone"],
            "code_pin": seeded["manager_pin"],
        },
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["role"] == "MANAGER"
    assert body["access_token"]


@pytest.mark.asyncio
async def test_login_pin_mauvais_code(client, seeded):
    resp = await client.post(
        "/api/v1/auth/login-pin",
        json={"telephone": seeded["manager_telephone"], "code_pin": "0000"},
    )
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_login_pin_format_invalide(client, seeded):
    # PIN doit être 4 chiffres
    resp = await client.post(
        "/api/v1/auth/login-pin",
        json={"telephone": seeded["manager_telephone"], "code_pin": "12"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_token_pin_donne_acces_sync(client, seeded):
    token = await login_pin(
        client, seeded["manager_telephone"], seeded["manager_pin"]
    )
    headers = {"Authorization": f"Bearer {token}"}
    resp = await client.get(
        f"/api/v1/sync/pull?boutique_id={seeded['boutique_id']}", headers=headers
    )
    assert resp.status_code == 200, resp.text


@pytest.mark.asyncio
async def test_owner_cree_gerant_par_telephone_pin(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.post(
        "/api/v1/users/",
        json={
            "nom": "Kouassi",
            "telephone": "0500000009",
            "code_pin": "2580",
            "boutique_id": seeded["boutique_id"],
        },
        headers=headers,
    )
    assert r.status_code == 201, r.text
    assert r.json()["telephone"] == "0500000009"
    assert r.json()["email"] is None

    # Le nouveau gérant se connecte avec téléphone + PIN
    token2 = await login_pin(client, "0500000009", "2580")
    assert token2


@pytest.mark.asyncio
async def test_telephone_deja_utilise(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}
    body = {
        "nom": "Doublon",
        "telephone": seeded["manager_telephone"],  # déjà pris
        "code_pin": "1111",
        "boutique_id": seeded["boutique_id"],
    }
    r = await client.post("/api/v1/users/", json=body, headers=headers)
    assert r.status_code == 409


@pytest.mark.asyncio
async def test_set_my_pin(client, seeded):
    token = await login_pin(
        client, seeded["manager_telephone"], seeded["manager_pin"]
    )
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.put(
        "/api/v1/users/me/pin", json={"code_pin": "9999"}, headers=headers
    )
    assert r.status_code == 200, r.text

    # L'ancien PIN ne marche plus, le nouveau oui
    bad = await client.post(
        "/api/v1/auth/login-pin",
        json={"telephone": seeded["manager_telephone"], "code_pin": seeded["manager_pin"]},
    )
    assert bad.status_code == 401
    good = await login_pin(client, seeded["manager_telephone"], "9999")
    assert good
