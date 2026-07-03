import pytest

from tests.conftest import login


@pytest.mark.asyncio
async def test_best_sellers_apres_vente(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "boutique_id": seeded["boutique_id"],
        "ventes": [
            {
                "id_local_smartphone": "bs-1",
                "mode_paiement": "ESPECES",
                "lignes": [
                    {
                        "produit_id": seeded["produit_id"],
                        "quantite": 3,
                        "prix_vendu_reel": "500.00",
                    }
                ],
            }
        ],
    }
    await client.post("/api/v1/sync/push", json=payload, headers=headers)

    resp = await client.get(
        f"/api/v1/analytics/best-sellers?boutique_id={seeded['boutique_id']}&tri=marge",
        headers=headers,
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["tri"] == "marge"
    assert body["items"][0]["quantite_totale"] == 3
    # marge = (500 - 300) * 3 = 600
    assert body["items"][0]["marge_nette_totale"] == "600.00"
