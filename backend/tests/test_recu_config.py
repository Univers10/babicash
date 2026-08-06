import uuid

import pytest

from tests.conftest import login, login_pin


def _auth(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_get_recu_config_absent_renvoie_null(client, seeded):
    """Aucune config enregistrée => 200 avec corps null (le client garde ses
    valeurs par défaut sans être écrasé)."""
    token = await login(client, seeded["owner_email"], "boss1234")
    resp = await client.get(
        f"/api/v1/boutiques/{seeded['boutique_id']}/recu-config",
        headers=_auth(token),
    )
    assert resp.status_code == 200, resp.text
    assert resp.json() is None


@pytest.mark.asyncio
async def test_put_puis_get_recu_config(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    payload = {
        "nom_boutique": "Chez Awa",
        "adresse": "Cocody, Abidjan",
        "telephone": "+225 07 00 00 00 00",
        "entete": "RCCM: CI-ABJ-2024-B-1234",
        "pied_message": "Merci de votre visite !",
        "afficher_logo": False,
        "afficher_vendeur": False,
    }
    put = await client.put(
        f"/api/v1/boutiques/{seeded['boutique_id']}/recu-config",
        json=payload,
        headers=_auth(token),
    )
    assert put.status_code == 200, put.text
    body = put.json()
    assert body["nom_boutique"] == "Chez Awa"
    assert body["afficher_logo"] is False
    assert body["afficher_vendeur"] is False
    assert "updated_at" in body

    get = await client.get(
        f"/api/v1/boutiques/{seeded['boutique_id']}/recu-config",
        headers=_auth(token),
    )
    assert get.status_code == 200, get.text
    assert get.json()["nom_boutique"] == "Chez Awa"
    assert get.json()["pied_message"] == "Merci de votre visite !"


@pytest.mark.asyncio
async def test_put_upsert_remplace_la_config(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    url = f"/api/v1/boutiques/{seeded['boutique_id']}/recu-config"

    r1 = await client.put(url, json={"nom_boutique": "V1"}, headers=_auth(token))
    r2 = await client.put(url, json={"nom_boutique": "V2"}, headers=_auth(token))
    assert r1.status_code == 200 and r2.status_code == 200
    assert r2.json()["nom_boutique"] == "V2"
    # Les champs non fournis reprennent les valeurs par défaut du schéma.
    assert r2.json()["pied_message"] == "Merci pour votre achat !"

    get = await client.get(url, headers=_auth(token))
    assert get.json()["nom_boutique"] == "V2"


@pytest.mark.asyncio
async def test_manager_peut_gerer_sa_config(client, seeded):
    token = await login_pin(
        client, seeded["manager_telephone"], seeded["manager_pin"]
    )
    url = f"/api/v1/boutiques/{seeded['boutique_id']}/recu-config"
    put = await client.put(url, json={"entete": "Gérant"}, headers=_auth(token))
    assert put.status_code == 200, put.text
    assert put.json()["entete"] == "Gérant"


@pytest.mark.asyncio
async def test_acces_autre_boutique_refuse(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    autre = uuid.uuid4()
    resp = await client.get(
        f"/api/v1/boutiques/{autre}/recu-config", headers=_auth(token)
    )
    # Le propriétaire n'accède pas à une boutique qui n'est pas la sienne.
    assert resp.status_code in (403, 404), resp.text
