"""Tests du catalogue de 6 plans d'abonnement."""
import pytest
from datetime import datetime, timedelta, timezone

from tests.conftest import login


# ── helpers ──────────────────────────────────────────────────────────

async def _upgrade(client, headers, plan, date_fin=None):
    payload = {"plan": plan}
    if date_fin:
        payload["date_fin"] = date_fin
    return await client.post("/api/v1/abonnements/upgrade", json=payload, headers=headers)


async def _mon_plan(client, headers):
    r = await client.get("/api/v1/abonnements/mon-plan", headers=headers)
    assert r.status_code == 200, r.text
    return r.json()


# ── 1. Tous les plans sont acceptés ──────────────────────────────────

@pytest.mark.asyncio
@pytest.mark.parametrize("plan", ["FREE", "KIOSQUE", "BOUTIQUE", "COMMERCE", "ENTREPRISE", "EMPIRE"])
async def test_upgrade_chaque_plan(client, seeded, plan):
    """Chaque plan du catalogue doit être accepté par l'endpoint upgrade."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await _upgrade(client, headers, plan)
    assert r.status_code == 200, f"Plan {plan} rejeté : {r.text}"
    assert r.json()["plan"] == plan


# ── 2. Plans invalides rejetés ──────────────────────────────────────

@pytest.mark.asyncio
@pytest.mark.parametrize("plan", ["PREMIUM", "PRO", "ULTIME", "BASIC", ""])
async def test_plan_invalide_rejeté(client, seeded, plan):
    """Un plan hors catalogue doit être rejeté (422 Pydantic)."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await _upgrade(client, headers, plan)
    assert r.status_code == 422, f"Plan invalide '{plan}' accepté à tort : {r.text}"


# ── 3. Chaque plan a les bonnes propriétés ──────────────────────────

@pytest.mark.asyncio
@pytest.mark.parametrize(
    "plan, expected_prix, expected_quota, expected_boutiques, expected_gerants",
    [
        ("FREE", 0.0, 20, 1, 1),
        ("KIOSQUE", 2000.0, 200, 1, 1),
        ("BOUTIQUE", 5000.0, 2147483647, 1, 3),
        ("COMMERCE", 10000.0, 2147483647, 3, 6),
        ("ENTREPRISE", 15000.0, 2147483647, 6, 12),
        ("EMPIRE", 20000.0, 2147483647, 2147483647, 2147483647),
    ],
)
async def test_propriétés_plan(
    client, seeded, plan, expected_prix, expected_quota, expected_boutiques, expected_gerants
):
    """Vérifie prix_base, quota, nb_boutiques_max, nb_gerants_max pour chaque plan."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, plan)
    body = await _mon_plan(client, headers)

    assert body["plan"] == plan
    assert float(body["prix_base"]) == expected_prix, f"prix_base incorrect pour {plan}"
    assert body["quota_ventes_par_boutique"] == expected_quota, f"quota incorrect pour {plan}"
    assert body["nb_boutiques_max"] == expected_boutiques, f"nb_boutiques_max incorrect pour {plan}"
    assert body["nb_gerants_max"] == expected_gerants, f"nb_gerants_max incorrect pour {plan}"


# ── 4. Upgrade entre plans payants ───────────────────────────────────

@pytest.mark.asyncio
async def test_upgrade_kiosque_vers_boutique(client, seeded):
    """Passer de KIOSQUE à BOUTIQUE : quota passe de 200 à illimité."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "KIOSQUE")
    body = await _mon_plan(client, headers)
    assert body["quota_ventes_par_boutique"] == 200

    await _upgrade(client, headers, "BOUTIQUE")
    body = await _mon_plan(client, headers)
    assert body["plan"] == "BOUTIQUE"
    assert body["quota_ventes_par_boutique"] == 2147483647
    assert body["nb_gerants_max"] == 3


@pytest.mark.asyncio
async def test_upgrade_boutique_vers_commerce(client, seeded):
    """Passer de BOUTIQUE à COMMERCE : nb_boutiques_max passe de 1 à 3."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "BOUTIQUE")
    body = await _mon_plan(client, headers)
    assert body["nb_boutiques_max"] == 1

    await _upgrade(client, headers, "COMMERCE")
    body = await _mon_plan(client, headers)
    assert body["plan"] == "COMMERCE"
    assert body["nb_boutiques_max"] == 3
    assert body["nb_gerants_max"] == 6


@pytest.mark.asyncio
async def test_upgrade_commerce_vers_entreprise(client, seeded):
    """Passer de COMMERCE à ENTREPRISE : nb_boutiques_max passe de 3 à 6."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "COMMERCE")
    await _upgrade(client, headers, "ENTREPRISE")
    body = await _mon_plan(client, headers)
    assert body["plan"] == "ENTREPRISE"
    assert body["nb_boutiques_max"] == 6
    assert body["nb_gerants_max"] == 12


@pytest.mark.asyncio
async def test_upgrade_entreprise_vers_empire(client, seeded):
    """Passer d'ENTREPRISE à EMPIRE : tout devient illimité."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "ENTREPRISE")
    await _upgrade(client, headers, "EMPIRE")
    body = await _mon_plan(client, headers)
    assert body["plan"] == "EMPIRE"
    assert body["nb_boutiques_max"] == 2147483647
    assert body["nb_gerants_max"] == 2147483647


# ── 5. Downgrade inter-plans payants ─────────────────────────────────

@pytest.mark.asyncio
async def test_downgrade_boutique_vers_kiosque_bloque_si_2_boutiques(client, seeded):
    """BOUTIQUE→KIOSQUE bloqué si > 1 boutique (KIOSQUE max=1)."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    # Passer COMMERCE (max 3 boutiques) pour créer 2 boutiques
    await _upgrade(client, headers, "COMMERCE")
    r = await client.post("/api/v1/boutiques/", json={"nom": "B2"}, headers=headers)
    assert r.status_code == 201, r.text

    # Downgrade vers BOUTIQUE (max 1) → bloqué
    r = await _upgrade(client, headers, "BOUTIQUE")
    assert r.status_code == 409, r.text
    assert r.json()["detail"]["code"] == "DOWNGRADE_BLOQUE"


@pytest.mark.asyncio
async def test_downgrade_free_bloque_si_2_boutiques(client, seeded):
    """FREE→ impossible si 2 boutiques existent."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "COMMERCE")
    r = await client.post("/api/v1/boutiques/", json={"nom": "B2"}, headers=headers)
    assert r.status_code == 201, r.text

    r = await _upgrade(client, headers, "FREE")
    assert r.status_code == 409, r.text
    assert r.json()["detail"]["code"] == "DOWNGRADE_BLOQUE"


@pytest.mark.asyncio
async def test_downgrade_autorise_sans_surplus(client, seeded):
    """Downgrade autorisé si nb_boutiques ≤ max du plan cible."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "COMMERCE")
    # 1 seule boutique → downgrade vers BOUTIQUE (max=1) autorisé
    r = await _upgrade(client, headers, "BOUTIQUE")
    assert r.status_code == 200, r.text
    assert r.json()["plan"] == "BOUTIQUE"


# ── 6. Quota libre KIOSQUE (200 ventes) ──────────────────────────────

@pytest.mark.asyncio
async def test_kiosque_quota_200(client, seeded):
    """KIOSQUE : le quota est bien de 200 ventes/mois."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "KIOSQUE")
    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["plan"] == "KIOSQUE"
    assert body["quota_par_boutique"] == 200
    assert body["illimite"] is False


# ── 7. Plans payants → ventes illimitées ─────────────────────────────

@pytest.mark.asyncio
@pytest.mark.parametrize("plan", ["BOUTIQUE", "COMMERCE", "ENTREPRISE", "EMPIRE"])
async def test_plan_payant_illimite(client, seeded, plan):
    """Les plans BOUTIQUE+ ont des ventes illimitées."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, plan)
    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["illimite"] is True
    assert body["ventes_restantes"] is None


# ── 8. Prix total multi-boutiques ────────────────────────────────────

@pytest.mark.asyncio
async def test_prix_total_commerce_2_boutiques(client, seeded):
    """COMMERCE : prix_total = 10000 + 10000*0.75 = 17500 pour 2 boutiques."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "COMMERCE")
    r = await client.post("/api/v1/boutiques/", json={"nom": "B2"}, headers=headers)
    assert r.status_code == 201, r.text

    body = await _mon_plan(client, headers)
    assert body["nb_boutiques"] == 2
    assert float(body["prix_total_mensuel"]) == pytest.approx(17500.0, abs=0.01)


# ── 9. Expiry : plan conservé, actif=False ────────────────────────────

@pytest.mark.asyncio
@pytest.mark.parametrize("plan", ["KIOSQUE", "BOUTIQUE", "COMMERCE", "ENTREPRISE", "EMPIRE"])
async def test_expiration_plan_conserve(client, seeded, plan):
    """Un plan payant expiré est conservé (affichage) mais marqué inactif."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    r = await _upgrade(client, headers, plan, date_fin=hier)
    assert r.status_code == 200, r.text

    # L'appel mon-plan doit marquer inactif mais garder le plan
    body = await _mon_plan(client, headers)
    assert body["plan"] == plan, f"Plan {plan} expiré ne doit pas changer"
    assert body["actif"] is False


# ── 10. Expiry bloque les opérations d'écriture ──────────────────────

@pytest.mark.asyncio
async def test_expiration_bloque_ventes(client, seeded):
    """Plan expiré : les ventes sont bloquées."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    await _upgrade(client, headers, "BOUTIQUE", date_fin=hier)
    await _mon_plan(client, headers)  # déclenche le marquage inactif

    r = await client.get(
        f"/api/v1/abonnements/quota/{seeded['boutique_id']}", headers=headers
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["illimite"] is False, "Plan inactif ne doit pas être illimité"


@pytest.mark.asyncio
async def test_expiration_bloque_creation_boutique(client, seeded):
    """Plan expiré : la création de boutique est bloquée."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    await _upgrade(client, headers, "COMMERCE", date_fin=hier)
    await _mon_plan(client, headers)  # déclenche le marquage inactif

    r = await client.post("/api/v1/boutiques/", json={"nom": "B2"}, headers=headers)
    assert r.status_code == 402, r.text


@pytest.mark.asyncio
async def test_expiration_renouvellement_reactive(client, seeded):
    """Plan expiré : un upgrade (renouvellement) réactive le plan."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    await _upgrade(client, headers, "BOUTIQUE", date_fin=hier)
    await _mon_plan(client, headers)  # déclenche le marquage inactif

    # Renouveler
    r = await _upgrade(client, headers, "BOUTIQUE")
    assert r.status_code == 200, r.text
    body = await _mon_plan(client, headers)
    assert body["plan"] == "BOUTIQUE"
    assert body["actif"] is True


# ── 11. Manager ne peut pas upgrader ─────────────────────────────────

@pytest.mark.asyncio
async def test_manager_ne_peut_pas_upgrader(client, seeded):
    """Seul l'OWNER peut upgrader le plan."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    headers = {"Authorization": f"Bearer {token}"}

    r = await _upgrade(client, headers, "BOUTIQUE")
    assert r.status_code == 403


# ── 11. FREE : propriétés initiales ──────────────────────────────────

@pytest.mark.asyncio
async def test_free_prix_zero(client, seeded):
    """Le plan FREE a un prix_base de 0."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    body = await _mon_plan(client, headers)
    assert body["plan"] == "FREE"
    assert float(body["prix_base"]) == 0.0
    assert body["nb_boutiques_max"] == 1
    assert body["nb_gerants_max"] == 1


# ── 12. Round-trip upgrade puis downgrade ─────────────────────────────

@pytest.mark.asyncio
async def test_round_trip_free_kiosque_free(client, seeded):
    """FREE → KIOSQUE → FREE : les valeurs reviennent à zéro."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "KIOSQUE")
    body = await _mon_plan(client, headers)
    assert body["plan"] == "KIOSQUE"
    assert float(body["prix_base"]) == 2000.0

    await _upgrade(client, headers, "FREE")
    body = await _mon_plan(client, headers)
    assert body["plan"] == "FREE"
    assert float(body["prix_base"]) == 0.0
    assert body["quota_ventes_par_boutique"] == 20


# ── 13. Sécurité : upgrade vérifie toujours les boutiques ─────────────

@pytest.mark.asyncio
async def test_upgrade_bloque_si_trop_boutiques_meme_inactif(client, seeded):
    """EMPIRE inactif avec 3 boutiques → upgrade vers BOUTIQUE (max 1) bloqué."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    await _upgrade(client, headers, "COMMERCE")
    r = await client.post("/api/v1/boutiques/", json={"nom": "B2"}, headers=headers)
    assert r.status_code == 201, r.text
    r = await client.post("/api/v1/boutiques/", json={"nom": "B3"}, headers=headers)
    assert r.status_code == 201, r.text

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    await _upgrade(client, headers, "EMPIRE", date_fin=hier)
    await _mon_plan(client, headers)  # marquer inactif

    # Upgrade vers BOUTIQUE (max 1) → bloqué car 3 > 1
    r = await _upgrade(client, headers, "BOUTIQUE")
    assert r.status_code == 409, r.text
    assert r.json()["detail"]["code"] == "DOWNGRADE_BLOQUE"


@pytest.mark.asyncio
async def test_upgrade_depuis_inactif_ok_si_compatible(client, seeded):
    """EMPIRE inactif avec 1 boutique → upgrade vers COMMERCE (max 3) autorisé."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    await _upgrade(client, headers, "EMPIRE", date_fin=hier)
    await _mon_plan(client, headers)  # marquer inactif

    r = await _upgrade(client, headers, "COMMERCE")
    assert r.status_code == 200, r.text
    body = await _mon_plan(client, headers)
    assert body["plan"] == "COMMERCE"
    assert body["actif"] is True


@pytest.mark.asyncio
async def test_expiration_renouvellement_change_plan(client, seeded):
    """Plan expiré : renouvellement vers un autre plan valide."""
    token = await login(client, seeded["owner_email"], "boss1234")
    headers = {"Authorization": f"Bearer {token}"}

    hier = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
    await _upgrade(client, headers, "BOUTIQUE", date_fin=hier)
    await _mon_plan(client, headers)

    # Renouveler vers COMMERCE (upgrade)
    r = await _upgrade(client, headers, "COMMERCE")
    assert r.status_code == 200, r.text
    body = await _mon_plan(client, headers)
    assert body["plan"] == "COMMERCE"
    assert body["actif"] is True
