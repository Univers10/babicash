"""Tests du modèle freemium : quota ventes, upgrade PRO, multi-boutique."""
import pytest
from datetime import datetime, timedelta, timezone

from tests.conftest import login


def _vente(boutique_id, produit_id, id_local):
    return {
        "boutique_id": str(boutique_id),
        "ventes": [
            {
                "id_local_smartphone": id_local,
                "mode_paiement": "ESPECES",
                "lignes": [
                    {
                        "produit_id": str(produit_id),
                        "quantite": 1,
                        "prix_vendu_reel": "500.00",
                    }
                ],
            }
        ],
    }


@pytest.mark.asyncio
async def test_abonnement_cree_automatiquement(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "FREE"
    assert body["quota_ventes_par_boutique"] == 20
    assert body["actif"] is True
    assert body["nb_boutiques"] == 1
    assert float(body["prix_total_mensuel"]) == 5000.0


@pytest.mark.asyncio
async def test_prix_multi_boutique(client, seeded):
    """2 boutiques → 5000 + 3750 = 8750 FCFA/mois (nécessite le plan PRO)."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer en PRO pour pouvoir créer une 2e boutique
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "PRO"}, headers=headers)

    # Créer une 2ème boutique
    r = await client.post(
        "/api/v1/boutiques/",
        json={"nom": "Boutique 2"},
        headers=headers,
    )
    assert r.status_code == 201, r.text

    r = await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["nb_boutiques"] == 2
    assert float(body["prix_total_mensuel"]) == pytest.approx(8750.0, abs=0.01)


@pytest.mark.asyncio
async def test_boutique_supplementaire_necessite_pro(client, seeded):
    """La 1ère boutique (créée par le seed) est gratuite ; la 2e exige le plan PRO."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # FREE : la création d'une 2e boutique est bloquée
    r = await client.post("/api/v1/boutiques/", json={"nom": "Boutique 2"}, headers=headers)
    assert r.status_code == 402, r.text
    assert r.json()["detail"]["code"] == "ABONNEMENT_REQUIS"

    # Après upgrade PRO : autorisé
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "PRO"}, headers=headers)
    r = await client.post("/api/v1/boutiques/", json={"nom": "Boutique 2"}, headers=headers)
    assert r.status_code == 201, r.text


@pytest.mark.asyncio
async def test_manager_ne_peut_pas_creer_boutique(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}
    r = await client.post("/api/v1/boutiques/", json={"nom": "Boutique manager"}, headers=headers)
    assert r.status_code == 403


@pytest.mark.asyncio
async def test_manager_peut_modifier_sa_boutique(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}
    r = await client.patch(
        f"/api/v1/boutiques/{seeded['boutique_id']}",
        json={"adresse": "Adjamé, Abidjan", "telephone": "0708000000"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["adresse"] == "Adjamé, Abidjan"


@pytest.mark.asyncio
async def test_quota_free_bloque_a_20(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Pousser 20 ventes — toutes doivent passer
    for i in range(20):
        resp = await client.post(
            "/api/v1/sync/push",
            json=_vente(seeded["boutique_id"], seeded["produit_id"], f"quota-test-{i}"),
            headers=headers,
        )
        assert resp.status_code == 200, f"vente {i} refusée: {resp.text}"

    # La 21ème doit être bloquée (402)
    resp = await client.post(
        "/api/v1/sync/push",
        json=_vente(seeded["boutique_id"], seeded["produit_id"], "quota-test-20"),
        headers=headers,
    )
    assert resp.status_code == 402, resp.text
    detail = resp.json()["detail"]
    assert detail["code"] == "QUOTA_DEPASSE"
    assert detail["ventes_utilisees"] == 20
    assert detail["quota"] == 20


@pytest.mark.asyncio
async def test_quota_boutique(client, seeded):
    """GET /abonnements/quota/{boutique_id} retourne le quota de la boutique."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "FREE"
    assert body["quota_par_boutique"] == 20
    assert body["ventes_ce_mois"] == 0
    assert body["ventes_restantes"] == 20
    assert body["illimite"] is False


@pytest.mark.asyncio
async def test_vente_idempotente_ne_compte_pas_quota(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    await client.post(
        "/api/v1/sync/push",
        json=_vente(seeded["boutique_id"], seeded["produit_id"], "idem-quota-1"),
        headers=headers,
    )
    # Re-push identique — ne doit pas consommer de quota
    resp = await client.post(
        "/api/v1/sync/push",
        json=_vente(seeded["boutique_id"], seeded["produit_id"], "idem-quota-1"),
        headers=headers,
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["ventes"][0]["deja_synchronisee"] is True


@pytest.mark.asyncio
async def test_upgrade_pro_leve_le_quota(client, seeded):
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "PRO"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "PRO"

    # Sync illimité maintenant
    resp = await client.post(
        "/api/v1/sync/push",
        json=_vente(seeded["boutique_id"], seeded["produit_id"], "pro-vente-1"),
        headers=headers,
    )
    assert resp.status_code == 200, resp.text

    # quota route doit indiquer illimité
    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.json()["illimite"] is True


@pytest.mark.asyncio
async def test_upgrade_reserve_owner(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "PRO"},
        headers=headers,
    )
    assert r.status_code == 403


@pytest.mark.asyncio
async def test_upgrade_plan_invalide_rejeté(client, seeded):
    """Un plan inconnu (ex: 'PREMIUM') doit être rejeté par le service."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "PREMIUM"},
        headers=headers,
    )
    assert r.status_code == 422, r.text  # Pydantic pattern validation


@pytest.mark.asyncio
async def test_downgrade_protege_trop_boutiques(client, seeded):
    """Impossible de redescendre en FREE quand on a > 1 boutique."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer PRO + créer 2e boutique
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "PRO"}, headers=headers)
    r = await client.post("/api/v1/boutiques/", json={"nom": "Boutique 2"}, headers=headers)
    assert r.status_code == 201, r.text

    # Downgrade vers FREE → bloqué (409)
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "FREE"},
        headers=headers,
    )
    assert r.status_code == 409, r.text
    assert r.json()["detail"]["code"] == "DOWNGRADE_BLOQUE"


@pytest.mark.asyncio
async def test_downgrade_protege_trop_ventes(client, seeded):
    """Impossible de redescendre en FREE si une boutique a > 20 ventes ce mois."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer PRO pour pouvoir pousser > 20 ventes
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "PRO"}, headers=headers)

    # Pousser 21 ventes
    for i in range(21):
        resp = await client.post(
            "/api/v1/sync/push",
            json=_vente(seeded["boutique_id"], seeded["produit_id"], f"downgrade-test-{i}"),
            headers=headers,
        )
        assert resp.status_code == 200, f"vente {i} refusée: {resp.text}"

    # Downgrade vers FREE → bloqué (409) car 21 > 20
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "FREE"},
        headers=headers,
    )
    assert r.status_code == 409, r.text
    assert r.json()["detail"]["code"] == "DOWNGRADE_VENTES"


@pytest.mark.asyncio
async def test_downgrade_autorise_sans_surplus(client, seeded):
    """Downgrade FREE autorisé si 1 boutique et ventes ≤ 20."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer PRO (1 seule boutique, 0 ventes)
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "PRO"}, headers=headers)

    # Downgrade → autorisé
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "FREE"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "FREE"
    assert r.json()["quota_ventes_par_boutique"] == 20


@pytest.mark.asyncio
async def test_abonnement_expire_revert_auto(client, seeded):
    """Un abonnement PRO avec date_fin dépassée revient automatiquement à FREE."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer PRO avec date_fin dans le passé
    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "PRO", "date_fin": hier},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "PRO"  # encore PRO immédiatement après upgrade

    # Vérifier le plan → l'auto-revert doit se déclencher
    r = await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "FREE", "Le plan PRO expiré doit revenir à FREE"
    assert body["quota_ventes_par_boutique"] == 20

    # Le quota doit aussi refléter FREE
    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "FREE"
    assert r.json()["illimite"] is False
