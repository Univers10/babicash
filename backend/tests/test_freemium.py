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
    """Sans code de parrainage : essai FREE limité à 20 ventes, sans date de fin."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "FREE"
    assert body["quota_ventes_par_boutique"] == 20
    assert body["actif"] is True
    assert body["nb_boutiques"] == 1
    assert float(body["prix_base"]) == 0.0
    assert body["date_fin"] is None


@pytest.mark.asyncio
async def test_prix_multi_boutique(client, seeded):
    """2 boutiques → 5000 + 3750 = 8750 FCFA/mois (nécessite le plan PRO)."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer en BOUTIQUE pour pouvoir créer une 2e boutique
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "BOUTIQUE"}, headers=headers)

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

    # Après upgrade BOUTIQUE : autorisé
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "BOUTIQUE"}, headers=headers)
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
async def test_quota_kiosque_10000_ventes(client, seeded):
    """KIOSQUE : quota de 10 000 ventes/mois, décrémenté à chaque vente."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer KIOSQUE
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "KIOSQUE"}, headers=headers)

    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    assert r.json()["quota_par_boutique"] == 10000
    assert r.json()["ventes_restantes"] == 10000

    # Quelques ventes passent
    for i in range(3):
        resp = await client.post(
            "/api/v1/sync/push",
            json=_vente(seeded["boutique_id"], seeded["produit_id"], f"quota-test-{i}"),
            headers=headers,
        )
        assert resp.status_code == 200, f"vente {i} refusée: {resp.text}"

    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    body = r.json()
    assert body["ventes_ce_mois"] == 3
    assert body["ventes_restantes"] == 9997


@pytest.mark.asyncio
async def test_quota_boutique_essai_gratuit_sans_parrainage(client, seeded):
    """Sans parrainage : GET /abonnements/quota retourne un essai de 20 ventes (pas de durée)."""
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
    assert body["jours_essai_restant"] is None


@pytest.mark.asyncio
async def test_essai_avec_parrainage_14_jours_illimite(client, session_factory):
    """Avec un code de parrainage valide : essai de 14 jours, ventes illimitées."""
    r = await client.post(
        "/api/v1/ambassadeurs/register",
        json={
            "nom": "Amb",
            "email": "amb@promo.ci",
            "mot_de_passe": "promo1234",
            "telephone": None,
            "code": "PROMO2026",
            "momo_numero": "0700888999",
            "momo_operateur": "wave",
        },
    )
    assert r.status_code == 201, r.text

    r = await client.post(
        "/api/v1/auth/register",
        json={
            "nom": "Proprio",
            "email": "filleul@boutique.ci",
            "mot_de_passe": "boss1234",
            "code_parrainage": "PROMO2026",
        },
    )
    assert r.status_code == 200, r.text
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    body = (
        await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    ).json()
    assert body["plan"] == "FREE"
    assert body["quota_ventes_par_boutique"] == 2147483647
    assert body["date_fin"] is not None


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
        json={"plan": "BOUTIQUE"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "BOUTIQUE"

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
        json={"plan": "BOUTIQUE"},
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

    # Passer BOUTIQUE + créer 2e boutique
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "BOUTIQUE"}, headers=headers)
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
async def test_downgrade_free_inactif_essai_unique(client, seeded):
    """Après avoir quitté FREE, un retour à FREE désactive l'abonnement."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer BOUTIQUE puis revenir à FREE
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "BOUTIQUE"}, headers=headers)
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "FREE"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "FREE"
    assert body["actif"] is False


@pytest.mark.asyncio
async def test_downgrade_autorise_mais_inactif(client, seeded):
    """Downgrade vers FREE autorisé mais désactivé (essai déjà utilisé)."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer BOUTIQUE (1 seule boutique, 0 ventes)
    await client.post("/api/v1/abonnements/upgrade", json={"plan": "BOUTIQUE"}, headers=headers)

    # Downgrade → autorisé mais inactif
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "FREE"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "FREE"
    assert body["quota_ventes_par_boutique"] == 2147483647
    assert body["actif"] is False


@pytest.mark.asyncio
async def test_abonnement_expire_revert_auto(client, seeded):
    """Un abonnement BOUTIQUE expiré est conservé mais marqué inactif."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer BOUTIQUE avec date_fin dans le passé
    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    r = await client.post(
        "/api/v1/abonnements/upgrade",
        json={"plan": "BOUTIQUE", "date_fin": hier},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "BOUTIQUE"  # encore BOUTIQUE immédiatement après upgrade

    # Vérifier le plan → le plan est conservé mais actif=False
    r = await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "BOUTIQUE", "Le plan BOUTIQUE expiré doit être conservé"
    assert body["actif"] is False, "L'abonnement doit être marqué inactif"

    # Le quota doit refléter que le plan n'est plus actif
    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "BOUTIQUE"
    assert r.json()["illimite"] is False
