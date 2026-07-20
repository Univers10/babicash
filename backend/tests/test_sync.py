import uuid

import pytest
from sqlalchemy import select

from app.models import LigneVente
from tests.conftest import login


def _vente_payload(boutique_id, produit_id, id_local, prix):
    return {
        "boutique_id": boutique_id,
        "ventes": [
            {
                "id_local_smartphone": id_local,
                "mode_paiement": "ESPECES",
                "lignes": [
                    {
                        "produit_id": produit_id,
                        "quantite": 2,
                        "prix_vendu_reel": prix,
                    }
                ],
            }
        ],
    }


@pytest.mark.asyncio
async def test_push_cree_vente_et_recu(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    payload = _vente_payload(
        seeded["boutique_id"], seeded["produit_id"], "local-1", "500.00"
    )
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    vente = resp.json()["ventes"][0]
    assert vente["deja_synchronisee"] is False
    assert vente["signale_proprietaire"] is False
    assert vente["avertissement"] is None
    assert vente["recu"]["montant_total"] == "1000.00"
    assert len(vente["recu"]["lignes"]) == 1


@pytest.mark.asyncio
async def test_push_idempotent(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    payload = _vente_payload(
        seeded["boutique_id"], seeded["produit_id"], "local-dup", "500.00"
    )
    headers = {"Authorization": f"Bearer {token}"}

    r1 = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    r2 = await client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert r1.status_code == 200 and r2.status_code == 200
    v1 = r1.json()["ventes"][0]
    v2 = r2.json()["ventes"][0]
    assert v1["deja_synchronisee"] is False
    assert v2["deja_synchronisee"] is True
    assert v1["vente_id"] == v2["vente_id"]


@pytest.mark.asyncio
async def test_vente_a_perte_signalee(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    # prix_achat_moyen = 300, on vend à 200 => perte
    payload = _vente_payload(
        seeded["boutique_id"], seeded["produit_id"], "local-perte", "200.00"
    )
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    vente = resp.json()["ventes"][0]
    assert vente["signale_proprietaire"] is True
    assert "signalée au propriétaire" in vente["avertissement"]


@pytest.mark.asyncio
async def test_stock_insuffisant_avertissement(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    # stock_actuel = 100, on vend 200 => stock insuffisant
    payload = _vente_payload(
        seeded["boutique_id"], seeded["produit_id"], "local-stock-insuf", "500.00"
    )
    payload["ventes"][0]["lignes"][0]["quantite"] = 200
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    vente = resp.json()["ventes"][0]
    assert vente["avertissement"] is not None
    assert "Stock insuffisant" in vente["avertissement"]


@pytest.mark.asyncio
async def test_alerte_stock_bas_dans_reponse(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    # stock_actuel = 100, stock_alerte = 5, on vend 98 => stock_actuel = 2 <= stock_alerte
    payload = _vente_payload(
        seeded["boutique_id"], seeded["produit_id"], "local-alerte-stock", "500.00"
    )
    payload["ventes"][0]["lignes"][0]["quantite"] = 98
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["alertes_stock"]) == 1
    alerte = body["alertes_stock"][0]
    assert alerte["produit_id"] == seeded["produit_id"]
    assert alerte["stock_actuel"] == 2
    assert alerte["en_rupture"] is False


@pytest.mark.asyncio
async def test_push_vente_avec_lot(client, seeded, session_factory):
    """Un lot (prix de groupe) persiste lot_id/lot_nom sur chaque ligne."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    lot_id = "11111111-1111-1111-1111-111111111111"
    payload = {
        "boutique_id": seeded["boutique_id"],
        "ventes": [
            {
                "id_local_smartphone": "local-lot",
                "mode_paiement": "ESPECES",
                "lignes": [
                    {
                        "produit_id": seeded["produit_id"],
                        "quantite": 2,
                        "prix_vendu_reel": "667.00",
                        "lot_id": lot_id,
                        "lot_nom": "Kit 3 bieres",
                    },
                    {
                        "produit_id": seeded["produit_id"],
                        "quantite": 1,
                        "prix_vendu_reel": "666.00",
                        "lot_id": lot_id,
                        "lot_nom": "Kit 3 bieres",
                    },
                ],
            }
        ],
    }
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    # 667*2 + 666*1 = 2000, la somme des lignes vaut exactement le prix du lot.
    assert resp.json()["ventes"][0]["recu"]["montant_total"] == "2000.00"

    async with session_factory() as db:
        rows = (
            await db.execute(
                select(LigneVente).where(LigneVente.lot_id == uuid.UUID(lot_id))
            )
        ).scalars().all()
        assert len(rows) == 2
        assert all(r.lot_nom == "Kit 3 bieres" for r in rows)


@pytest.mark.asyncio
async def test_push_vente_sans_lot_retrocompatible(client, seeded, session_factory):
    """Une vente sans champs de lot reste valide (lot_id/lot_nom = NULL)."""
    token = await login(client, seeded["manager_email"], "gerant1234")
    payload = _vente_payload(
        seeded["boutique_id"], seeded["produit_id"], "local-nolot", "500.00"
    )
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text

    async with session_factory() as db:
        vente_id = uuid.UUID(resp.json()["ventes"][0]["vente_id"])
        rows = (
            await db.execute(
                select(LigneVente).where(LigneVente.vente_id == vente_id)
            )
        ).scalars().all()
        assert len(rows) == 1
        assert rows[0].lot_id is None
        assert rows[0].lot_nom is None


@pytest.mark.asyncio
async def test_manager_ne_peut_pas_pusher_autre_boutique(client, seeded):
    token = await login(client, seeded["manager_email"], "gerant1234")
    payload = _vente_payload(
        "00000000-0000-0000-0000-000000000000",
        seeded["produit_id"],
        "local-x",
        "500.00",
    )
    resp = await client.post(
        "/api/v1/sync/push",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403
