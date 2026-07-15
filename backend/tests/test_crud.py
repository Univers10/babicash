import pytest

from app.core.security import hash_password
from app.models import Boutique, User
from tests.conftest import login, login_pin


@pytest.mark.asyncio
async def test_owner_cree_boutique_et_produit(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passe en PRO : la boutique du seed compte déjà comme la 1ère
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "PRO"}, headers=headers)

    # Crée une nouvelle boutique
    r = await client.post("/api/v1/boutiques/", json={"nom": "Boutique 2"}, headers=headers)
    assert r.status_code == 201, r.text
    boutique2 = r.json()["id"]

    # Crée un produit dans cette boutique
    r = await client.post(
        "/api/v1/produits/",
        json={
            "boutique_id": boutique2,
            "nom": "Sucre 1kg",
            "prix_achat_moyen": "400.00",
            "prix_vente_suggere": "600.00",
            "stock_actuel": 50,
        },
        headers=headers,
    )
    assert r.status_code == 201, r.text

    # Liste les produits
    r = await client.get(
        f"/api/v1/produits/?boutique_id={boutique2}", headers=headers
    )
    assert r.status_code == 200
    assert len(r.json()) == 1


@pytest.mark.asyncio
async def test_manager_ne_peut_pas_creer_produit(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}
    r = await client.post(
        "/api/v1/produits/",
        json={"boutique_id": seeded["boutique_id"], "nom": "X"},
        headers=headers,
    )
    assert r.status_code == 403


@pytest.mark.asyncio
async def test_isolation_entre_proprietaires(client, seeded, session_factory):
    # Crée un second propriétaire avec sa propre boutique
    async with session_factory() as db:
        owner2 = User(
            nom="Boss2",
            email="boss2@test.ci",
            mot_de_passe_hash=hash_password("boss1234"),
            role="OWNER",
        )
        db.add(owner2)
        await db.flush()
        boutique2 = Boutique(nom="Boutique Boss2", proprietaire_id=str(owner2.id))
        db.add(boutique2)
        await db.commit()
        boutique2_id = str(boutique2.id)

    # Le propriétaire 1 ne doit PAS accéder à la boutique du propriétaire 2
    token1 = await login(client, seeded["owner_email"], "boss1234")
    headers1 = {"Authorization": f"Bearer {token1}"}

    r = await client.get(f"/api/v1/boutiques/{boutique2_id}", headers=headers1)
    assert r.status_code == 403

    r = await client.get(
        f"/api/v1/analytics/best-sellers?boutique_id={boutique2_id}",
        headers=headers1,
    )
    assert r.status_code == 403

    r = await client.post(
        "/api/v1/sync/push",
        json={"boutique_id": boutique2_id, "ventes": [], "depenses": []},
        headers=headers1,
    )
    assert r.status_code == 403


@pytest.mark.asyncio
async def test_owner_cree_gerant(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}
    r = await client.post(
        "/api/v1/users/",
        json={
            "nom": "Nouveau Gérant",
            "telephone": "0500000010",
            "code_pin": "1357",
            "role": "MANAGER",
            "boutique_id": seeded["boutique_id"],
        },
        headers=headers,
    )
    assert r.status_code == 201, r.text

    # Le nouveau gérant peut se connecter par téléphone + PIN
    token2 = await login_pin(client, "0500000010", "1357")
    assert token2


@pytest.mark.asyncio
async def test_creation_tiers_client(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}
    r = await client.post(
        "/api/v1/tiers/",
        json={
            "boutique_id": seeded["boutique_id"],
            "nom": "Awa Cliente",
            "telephone": "0700000000",
            "type_tiers": "CLIENT",
        },
        headers=headers,
    )
    assert r.status_code == 201, r.text
    assert r.json()["solde_du"] == "0.00"


@pytest.mark.asyncio
async def test_paiement_credit_client(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Crée un client
    r = await client.post(
        "/api/v1/tiers/",
        json={
            "boutique_id": seeded["boutique_id"],
            "nom": "Konan Crédit",
            "telephone": "0600000001",
            "type_tiers": "CLIENT",
        },
        headers=headers,
    )
    assert r.status_code == 201
    tier_id = r.json()["id"]

    # Vente à crédit: solde_du doit augmenter
    await client.post(
        "/api/v1/sync/push",
        json={
            "boutique_id": seeded["boutique_id"],
            "ventes": [
                {
                    "id_local_smartphone": "credit-test-1",
                    "tier_id": tier_id,
                    "mode_paiement": "CREDIT",
                    "lignes": [
                        {
                            "produit_id": seeded["produit_id"],
                            "quantite": 1,
                            "prix_vendu_reel": "500.00",
                        }
                    ],
                }
            ],
        },
        headers=headers,
    )

    r = await client.get(
        f"/api/v1/tiers/?boutique_id={seeded['boutique_id']}&type_tiers=CLIENT",
        headers=headers,
    )
    client_data = next(t for t in r.json() if t["id"] == tier_id)
    assert client_data["solde_du"] == "500.00"

    # Remboursement partiel
    r = await client.post(
        f"/api/v1/tiers/{tier_id}/paiement",
        json={"montant": "200.00", "motif": "Acompte"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["solde_du"] == "300.00"

    # Remboursement total (on solde tout)
    r = await client.post(
        f"/api/v1/tiers/{tier_id}/paiement",
        json={"montant": "300.00"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["solde_du"] == "0.00"

    # Paiement sur solde nul => 400
    r = await client.post(
        f"/api/v1/tiers/{tier_id}/paiement",
        json={"montant": "100.00"},
        headers=headers,
    )
    assert r.status_code == 400
