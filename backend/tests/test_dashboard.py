"""Tests dashboard : CA, caisse, dettes, stock, consolidé."""
import pytest

from tests.conftest import login


async def _push_vente(client, headers, boutique_id, produit_id, id_local, prix="500.00", qte=2):
    payload = {
        "boutique_id": str(boutique_id),
        "ventes": [
            {
                "id_local_smartphone": id_local,
                "mode_paiement": "ESPECES",
                "lignes": [
                    {"produit_id": str(produit_id), "quantite": qte, "prix_vendu_reel": prix}
                ],
            }
        ],
    }
    r = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert r.status_code == 200, r.text


async def _push_depense(client, headers, boutique_id, id_local, montant="2000.00"):
    payload = {
        "boutique_id": str(boutique_id),
        "depenses": [
            {
                "id_local_smartphone": id_local,
                "montant": montant,
                "motif": "Transport",
            }
        ],
    }
    r = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert r.status_code == 200, r.text


@pytest.mark.asyncio
async def test_ca_initial_zero(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get(
        f"/api/v1/dashboard/ca/{seeded['boutique_id']}?granularite=mois",
        headers=headers,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert float(body["chiffre_affaires"]) == 0.0
    assert body["nb_ventes"] == 0


@pytest.mark.asyncio
async def test_ca_apres_ventes(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _push_vente(client, headers, seeded["boutique_id"], seeded["produit_id"], "dash-v1", qte=2)
    await _push_vente(client, headers, seeded["boutique_id"], seeded["produit_id"], "dash-v2", qte=3)

    r = await client.get(
        f"/api/v1/dashboard/ca/{seeded['boutique_id']}?granularite=mois",
        headers=headers,
    )
    body = r.json()
    # 2 ventes × 500 × (2+3) = 2500
    assert float(body["chiffre_affaires"]) == pytest.approx(2500.0)
    # marge = (500-300) × 5 = 1000
    assert float(body["marge_nette"]) == pytest.approx(1000.0)
    assert body["nb_ventes"] == 2


@pytest.mark.asyncio
async def test_resume_caisse(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _push_vente(client, headers, seeded["boutique_id"], seeded["produit_id"], "caisse-v1", qte=1)
    await _push_depense(client, headers, seeded["boutique_id"], "caisse-d1", "1500.00")

    r = await client.get(
        f"/api/v1/dashboard/caisse/{seeded['boutique_id']}?granularite=mois",
        headers=headers,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert float(body["depenses"]) == pytest.approx(1500.0)
    assert "solde_net" in body


@pytest.mark.asyncio
async def test_dettes_clients(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Créer un client avec crédit
    r = await client.post(
        "/api/v1/tiers/",
        json={
            "boutique_id": seeded["boutique_id"],
            "nom": "Client Koné",
            "telephone": "0700000099",
            "type_tiers": "CLIENT",
        },
        headers=headers,
    )
    assert r.status_code == 201
    client_id = r.json()["id"]

    # Vente à crédit
    payload = {
        "boutique_id": seeded["boutique_id"],
        "ventes": [
            {
                "id_local_smartphone": "dette-v1",
                "mode_paiement": "CREDIT",
                "tier_id": client_id,
                "lignes": [
                    {"produit_id": seeded["produit_id"], "quantite": 1, "prix_vendu_reel": "500.00"}
                ],
            }
        ],
    }
    await client.post("/api/v1/sync/push", json=payload, headers=headers)

    r = await client.get(
        f"/api/v1/dashboard/dettes/{seeded['boutique_id']}?type_tiers=CLIENT",
        headers=headers,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert float(body["total_dettes"]) > 0
    assert body["detail"][0]["type_tiers"] == "CLIENT"


@pytest.mark.asyncio
async def test_etat_stock(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get(
        f"/api/v1/dashboard/stock/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["nb_references"] >= 1
    # stock initial = 100 × 300 = 30000 FCFA
    assert float(body["valeur_stock_fcfa"]) >= 30000.0
    assert "produits_rupture" in body
    assert "produits_alerte" in body


@pytest.mark.asyncio
async def test_consolide_owner(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get(
        "/api/v1/dashboard/consolide?granularite=mois", headers=headers
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert "boutiques" in body
    assert len(body["boutiques"]) >= 1
    assert "ca_total" in body
    assert "marge_totale" in body


@pytest.mark.asyncio
async def test_consolide_reserve_owner(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get("/api/v1/dashboard/consolide", headers=headers)
    assert r.status_code == 403
