import pytest

from tests.conftest import login, login_pin


def _entree_payload(boutique_id, produit_id, id_local, prix_achat="400.00", quantite=10):
    return {
        "boutique_id": str(boutique_id),
        "entrees_stock": [
            {
                "id_local_smartphone": id_local,
                "mode_paiement": "ESPECES",
                "lignes": [
                    {
                        "produit_id": str(produit_id),
                        "quantite": quantite,
                        "prix_achat_unitaire": prix_achat,
                    }
                ],
            }
        ],
    }


@pytest.mark.asyncio
async def test_entree_stock_incremente_stock(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Stock initial = 100
    payload = _entree_payload(
        seeded["boutique_id"], seeded["produit_id"], "entree-1", quantite=20
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    body = resp.json()
    assert len(body["entrees_stock"]) == 1
    result = body["entrees_stock"][0]
    assert result["deja_synchronisee"] is False
    assert result["transaction_id"]
    assert seeded["produit_id"] in result["produits_mis_a_jour"]

    # Vérifier le stock via pull
    pull = await client.get(
        f"/api/v1/sync/pull?boutique_id={seeded['boutique_id']}", headers=headers
    )
    produit = next(p for p in pull.json()["produits"] if p["id"] == seeded["produit_id"])
    assert produit["stock_actuel"] == 120  # 100 + 20


@pytest.mark.asyncio
async def test_entree_stock_idempotente(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _entree_payload(
        seeded["boutique_id"], seeded["produit_id"], "entree-idem-1", quantite=5
    )
    # Premier push
    await client.post("/api/v1/sync/push", json=payload, headers=headers)
    # Deuxième push identique
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    result = resp.json()["entrees_stock"][0]
    assert result["deja_synchronisee"] is True

    # Le stock ne doit avoir bougé qu'une seule fois : 100 + 5 = 105
    pull = await client.get(
        f"/api/v1/sync/pull?boutique_id={seeded['boutique_id']}", headers=headers
    )
    produit = next(p for p in pull.json()["produits"] if p["id"] == seeded["produit_id"])
    assert produit["stock_actuel"] == 105


@pytest.mark.asyncio
async def test_entree_stock_recalcule_prix_achat_moyen(client, seeded):
    """
    Stock initial: 100 unités à 300.00 FCFA
    Entrée: 100 unités à 400.00 FCFA
    CMP attendu: (100*300 + 100*400) / 200 = 350.00
    """
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _entree_payload(
        seeded["boutique_id"],
        seeded["produit_id"],
        "entree-cmp-1",
        prix_achat="400.00",
        quantite=100,
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    pull = await client.get(
        f"/api/v1/sync/pull?boutique_id={seeded['boutique_id']}", headers=headers
    )
    produit = next(p for p in pull.json()["produits"] if p["id"] == seeded["produit_id"])
    assert produit["stock_actuel"] == 200
    assert float(produit["prix_achat_moyen"]) == pytest.approx(350.0, abs=0.01)


@pytest.mark.asyncio
async def test_entree_stock_dette_fournisseur(client, seeded):
    """Une entrée à crédit augmente le solde_du du fournisseur."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Créer un fournisseur
    r = await client.post(
        "/api/v1/tiers/",
        json={
            "boutique_id": seeded["boutique_id"],
            "nom": "Fournisseur Diallo",
            "telephone": "0700000099",
            "type_tiers": "FOURNISSEUR",
        },
        headers=headers,
    )
    assert r.status_code == 201
    fournisseur_id = r.json()["id"]

    payload = {
        "boutique_id": seeded["boutique_id"],
        "entrees_stock": [
            {
                "id_local_smartphone": "entree-credit-1",
                "fournisseur_id": fournisseur_id,
                "mode_paiement": "CREDIT",
                "lignes": [
                    {
                        "produit_id": seeded["produit_id"],
                        "quantite": 10,
                        "prix_achat_unitaire": "300.00",
                    }
                ],
            }
        ],
    }
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    # solde_du fournisseur = 10 * 300 = 3000
    r = await client.get(
        f"/api/v1/tiers/?boutique_id={seeded['boutique_id']}&type_tiers=FOURNISSEUR",
        headers=headers,
    )
    fournisseur = next(t for t in r.json() if t["id"] == fournisseur_id)
    assert fournisseur["solde_du"] == "3000.00"


@pytest.mark.asyncio
async def test_entree_stock_pas_alerte_stock(client, seeded):
    """Une entrée de stock ne doit jamais générer d'alerte stock (stock monte)."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _entree_payload(
        seeded["boutique_id"], seeded["produit_id"], "entree-no-alerte", quantite=50
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text
    assert resp.json()["alertes_stock"] == []
