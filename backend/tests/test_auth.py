import pytest

from tests.conftest import login


@pytest.mark.asyncio
async def test_login_ok(client, seeded):
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": seeded["owner_email"], "mot_de_passe": "boss1234"},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["role"] == "OWNER"
    assert body["access_token"]


@pytest.mark.asyncio
async def test_login_mauvais_mot_de_passe(client, seeded):
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": seeded["owner_email"], "mot_de_passe": "mauvais"},
    )
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_boutiques_requiert_auth(client, seeded):
    resp = await client.get("/api/v1/boutiques/")
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_owner_liste_ses_boutiques(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    resp = await client.get(
        "/api/v1/boutiques/", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 1
    assert data[0]["id"] == seeded["boutique_id"]
