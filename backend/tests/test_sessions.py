import pytest

from tests.conftest import login_pin


async def _open_session(client, headers, boutique_id, montant_initial="1000.00"):
    r = await client.post(
        "/api/v1/sessions/ouvrir",
        json={"boutique_id": boutique_id, "montant_initial": montant_initial},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    return r.json()


@pytest.mark.asyncio
async def test_ouvrir_session(client, seeded):
    token = await login_pin(client, seeded["manager_telephone"], seeded["manager_pin"])
    headers = {"Authorization": f"Bearer {token}"}
    s = await _open_session(client, headers, seeded["boutique_id"])
    assert s["statut"] == "OUVERT"
    assert s["montant_initial"] == "1000.00"
    assert s["utilisateur_nom"] == "Gerant"


@pytest.mark.asyncio
async def test_une_seule_session_ouverte(client, seeded):
    token = await login_pin(client, seeded["manager_telephone"], seeded["manager_pin"])
    headers = {"Authorization": f"Bearer {token}"}
    await _open_session(client, headers, seeded["boutique_id"])
    r = await client.post(
        "/api/v1/sessions/ouvrir",
        json={"boutique_id": seeded["boutique_id"], "montant_initial": "0.00"},
        headers=headers,
    )
    assert r.status_code == 409


@pytest.mark.asyncio
async def test_reconciliation_et_fermeture_equilibree(client, seeded):
    token = await login_pin(client, seeded["manager_telephone"], seeded["manager_pin"])
    headers = {"Authorization": f"Bearer {token}"}
    session = await _open_session(client, headers, seeded["boutique_id"], "1000.00")
    session_id = session["id"]

    # Vente espèces de 2 x 500 = 1000
    await client.post(
        "/api/v1/sync/push",
        json={
            "boutique_id": seeded["boutique_id"],
            "ventes": [
                {
                    "id_local_smartphone": "s-vente-1",
                    "session_id": session_id,
                    "mode_paiement": "ESPECES",
                    "lignes": [
                        {
                            "produit_id": seeded["produit_id"],
                            "quantite": 2,
                            "prix_vendu_reel": "500.00",
                        }
                    ],
                }
            ],
            "depenses": [
                {
                    "id_local_smartphone": "s-dep-1",
                    "session_id": session_id,
                    "type_transaction": "SORTIE_DEPENSE",
                    "montant": "300.00",
                    "motif": "Transport",
                }
            ],
        },
        headers=headers,
    )

    # Réconciliation: 1000 (initial) + 1000 (ventes espèces) - 300 (sortie) = 1700
    r = await client.get(
        f"/api/v1/sessions/active?boutique_id={seeded['boutique_id']}",
        headers=headers,
    )
    assert r.status_code == 200, r.text
    resume = r.json()
    assert resume["montant_theorique"] == "1700.00"
    assert resume["total_ventes_especes"] == "1000.00"
    assert resume["total_sorties"] == "300.00"
    assert resume["nb_ventes"] == 1

    # Fermeture équilibrée
    r = await client.post(
        f"/api/v1/sessions/{session_id}/fermer",
        json={"montant_final_declare": "1700.00"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    fin = r.json()
    assert fin["session"]["statut"] == "FERME"
    assert fin["ecart"] == "0.00"
    assert fin["ecart_signale"] is False


@pytest.mark.asyncio
async def test_fermeture_avec_ecart(client, seeded):
    token = await login_pin(client, seeded["manager_telephone"], seeded["manager_pin"])
    headers = {"Authorization": f"Bearer {token}"}
    session = await _open_session(client, headers, seeded["boutique_id"], "1000.00")
    session_id = session["id"]

    # Déclare 900 alors que le théorique est 1000 => écart -100 (manque en caisse)
    r = await client.post(
        f"/api/v1/sessions/{session_id}/fermer",
        json={"montant_final_declare": "900.00"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    fin = r.json()
    assert fin["ecart"] == "-100.00"
    assert fin["ecart_signale"] is True


@pytest.mark.asyncio
async def test_session_fermee_immuable(client, seeded):
    token = await login_pin(client, seeded["manager_telephone"], seeded["manager_pin"])
    headers = {"Authorization": f"Bearer {token}"}
    session = await _open_session(client, headers, seeded["boutique_id"])
    session_id = session["id"]

    r1 = await client.post(
        f"/api/v1/sessions/{session_id}/fermer",
        json={"montant_final_declare": "1000.00"},
        headers=headers,
    )
    assert r1.status_code == 200
    # Re-fermer doit échouer (immuabilité)
    r2 = await client.post(
        f"/api/v1/sessions/{session_id}/fermer",
        json={"montant_final_declare": "1000.00"},
        headers=headers,
    )
    assert r2.status_code == 409


@pytest.mark.asyncio
async def test_session_isolation_autre_boutique(client, seeded):
    # Le gérant ne peut pas ouvrir une session pour une autre boutique
    token = await login_pin(client, seeded["manager_telephone"], seeded["manager_pin"])
    headers = {"Authorization": f"Bearer {token}"}
    r = await client.post(
        "/api/v1/sessions/ouvrir",
        json={
            "boutique_id": "00000000-0000-0000-0000-000000000000",
            "montant_initial": "0.00",
        },
        headers=headers,
    )
    assert r.status_code == 403
