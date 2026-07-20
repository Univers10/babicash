import pytest

from tests.conftest import login


def _mouvement_payload(
    boutique_id,
    produit_id,
    id_local,
    type_mouvement="ENTREE",
    quantite=10,
    motif="Réception fournisseur",
    auteur_nom="Gerant",
):
    return {
        "boutique_id": str(boutique_id),
        "mouvements_stock": [
            {
                "id_local_smartphone": id_local,
                "produit_id": str(produit_id),
                "type_mouvement": type_mouvement,
                "quantite": quantite,
                "motif": motif,
                "auteur_nom": auteur_nom,
            }
        ],
    }


async def _stock_actuel(client, headers, boutique_id, produit_id) -> int:
    pull = await client.get(
        f"/api/v1/sync/pull?boutique_id={boutique_id}", headers=headers
    )
    produit = next(p for p in pull.json()["produits"] if p["id"] == produit_id)
    return produit["stock_actuel"]


@pytest.mark.asyncio
async def test_mouvement_entree_incremente_stock(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Stock initial = 100
    payload = _mouvement_payload(
        seeded["boutique_id"], seeded["produit_id"], "mvt-entree-1", quantite=15
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    body = resp.json()
    assert len(body["mouvements_stock"]) == 1
    result = body["mouvements_stock"][0]
    assert result["deja_synchronise"] is False
    assert result["mouvement_id"]
    assert result["stock_actuel"] == 115  # 100 + 15

    assert await _stock_actuel(
        client, headers, seeded["boutique_id"], seeded["produit_id"]
    ) == 115


@pytest.mark.asyncio
async def test_mouvement_sortie_decremente_stock(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _mouvement_payload(
        seeded["boutique_id"],
        seeded["produit_id"],
        "mvt-sortie-1",
        type_mouvement="SORTIE",
        quantite=30,
        motif="Casse",
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    result = resp.json()["mouvements_stock"][0]
    assert result["stock_actuel"] == 70  # 100 - 30

    assert await _stock_actuel(
        client, headers, seeded["boutique_id"], seeded["produit_id"]
    ) == 70


@pytest.mark.asyncio
async def test_mouvement_idempotent(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _mouvement_payload(
        seeded["boutique_id"], seeded["produit_id"], "mvt-idem-1", quantite=5
    )
    await client.post("/api/v1/sync/push", json=payload, headers=headers)
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    result = resp.json()["mouvements_stock"][0]
    assert result["deja_synchronise"] is True

    # Le stock ne doit avoir bougé qu'une seule fois : 100 + 5 = 105
    assert await _stock_actuel(
        client, headers, seeded["boutique_id"], seeded["produit_id"]
    ) == 105


@pytest.mark.asyncio
async def test_mouvement_sortie_declenche_alerte_stock(client, seeded):
    """Une sortie qui fait passer le stock sous le seuil déclenche une alerte."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Stock initial 100, seuil alerte par défaut = 5 → sortie de 97 → stock 3
    payload = _mouvement_payload(
        seeded["boutique_id"],
        seeded["produit_id"],
        "mvt-alerte-1",
        type_mouvement="SORTIE",
        quantite=97,
        motif="Inventaire",
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 200, resp.text

    alertes = resp.json()["alertes_stock"]
    assert any(a["produit_id"] == seeded["produit_id"] for a in alertes)


@pytest.mark.asyncio
async def test_liste_mouvements_avec_auteur(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _mouvement_payload(
        seeded["boutique_id"],
        seeded["produit_id"],
        "mvt-liste-1",
        quantite=8,
        motif="Réassort",
        auteur_nom="Awa Kone",
    )
    await client.post("/api/v1/sync/push", json=payload, headers=headers)

    resp = await client.get(
        f"/api/v1/mouvements-stock/?boutique_id={seeded['boutique_id']}",
        headers=headers,
    )
    assert resp.status_code == 200, resp.text
    mouvements = resp.json()
    assert len(mouvements) == 1
    mvt = mouvements[0]
    assert mvt["type_mouvement"] == "ENTREE"
    assert mvt["quantite"] == 8
    assert mvt["motif"] == "Réassort"
    assert mvt["auteur_nom"] == "Awa Kone"
    assert mvt["auteur_id"]  # renseigné côté serveur depuis le JWT
    assert mvt["produit_nom"] == "Savon"


@pytest.mark.asyncio
async def test_mouvement_type_invalide_rejete(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    payload = _mouvement_payload(
        seeded["boutique_id"],
        seeded["produit_id"],
        "mvt-invalide-1",
        type_mouvement="AJUSTEMENT",
    )
    resp = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_liste_mouvements_boutique_non_autorisee(client, seeded):
    """Un utilisateur ne peut pas lister les mouvements d'une autre boutique."""
    # Créer un autre owner sans lien avec la boutique seedée
    r = await client.post(
        "/api/v1/auth/register",
        json={
            "nom": "Autre Boss",
            "email": "autre@test.ci",
            "mot_de_passe": "autre1234",
        },
    )
    assert r.status_code in (200, 201), r.text
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.get(
        f"/api/v1/mouvements-stock/?boutique_id={seeded['boutique_id']}",
        headers=headers,
    )
    assert resp.status_code in (403, 404)
