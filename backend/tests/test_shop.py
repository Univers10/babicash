"""Tests de la boutique « Matériel & accessoires » : API mobile + backoffice.

Couvre : catalogue lu par l'app, enregistrement d'une commande (avec prix
recalculé côté serveur), et la gestion admin (CRUD produit, stock, statuts
des commandes avec décrément/remise du stock à la livraison).
"""
from decimal import Decimal

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings
from app.core.csrf import generate_csrf_token
from app.core.db import Base, get_db
from app.core.security import hash_password
from app.main import app
from app.models import ShopProduit, User

TEST_DB_URL = "sqlite+aiosqlite:///:memory:"


@pytest_asyncio.fixture
async def engine():
    eng = create_async_engine(TEST_DB_URL, future=True)
    async with eng.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield eng
    await eng.dispose()


@pytest_asyncio.fixture
async def session_factory(engine):
    return async_sessionmaker(
        bind=engine, class_=AsyncSession, expire_on_commit=False, autoflush=False
    )


@pytest_asyncio.fixture
async def seeded(session_factory):
    """Admin + owner + catalogue boutique (3 produits)."""
    async with session_factory() as db:
        admin = User(
            nom="Admin",
            email="admin@test.ci",
            mot_de_passe_hash=hash_password("admin1234"),
            role="ADMIN",
            actif=True,
        )
        db.add(admin)

        owner = User(
            nom="Boss",
            email="boss@test.ci",
            mot_de_passe_hash=hash_password("boss1234"),
            role="OWNER",
            actif=True,
        )
        db.add(owner)
        await db.flush()

        p1 = ShopProduit(
            nom="Imprimante 58",
            prix=Decimal("25000.00"),
            categorie="IMPRIMANTES",
            stock=10,
            stock_alerte=5,
            en_vente=True,
            position=10,
        )
        p2 = ShopProduit(
            nom="Rouleaux 58",
            prix=Decimal("2500.00"),
            categorie="ROULEAUX",
            stock=0,
            stock_alerte=5,
            en_vente=True,
            position=20,
        )
        p3 = ShopProduit(
            nom="Retiré des ventes",
            prix=Decimal("1000.00"),
            categorie="ACCESSOIRES",
            stock=3,
            en_vente=False,
            position=30,
        )
        db.add_all([p1, p2, p3])
        await db.commit()

        return {
            "admin_email": "admin@test.ci",
            "admin_mdp": "admin1234",
            "owner_email": "boss@test.ci",
            "owner_mdp": "boss1234",
            "p1_id": str(p1.id),
            "p2_id": str(p2.id),
            "p3_id": str(p3.id),
        }


@pytest_asyncio.fixture
async def client(session_factory):
    async def override_get_db():
        async with session_factory() as db:
            yield db

    app.dependency_overrides[get_db] = override_get_db
    settings.SECURE_COOKIES = False
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()


async def api_login(client: AsyncClient, email: str, mdp: str) -> str:
    resp = await client.post(
        "/api/v1/auth/login", json={"email": email, "mot_de_passe": mdp}
    )
    assert resp.status_code == 200, resp.text
    return resp.json()["access_token"]


async def _csrf(client: AsyncClient) -> str:
    await client.get("/admin/login")
    session_id = client.cookies.get("admin_session_id", "")
    return generate_csrf_token(session_id)


async def admin_login(client: AsyncClient, email: str, mdp: str) -> None:
    resp = await client.post(
        "/admin/login",
        data={"email": email, "mot_de_passe": mdp, "csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert resp.status_code == 303, resp.text


# ── API mobile : catalogue ───────────────────────────────────────────

@pytest.mark.asyncio
async def test_produits_actifs(client, seeded):
    """GET /api/v1/shop/produits ne renvoie que les produits en vente."""
    token = await api_login(client, seeded["owner_email"], seeded["owner_mdp"])
    r = await client.get(
        "/api/v1/shop/produits", headers={"Authorization": f"Bearer {token}"}
    )
    assert r.status_code == 200
    data = r.json()
    assert len(data) == 2
    assert all(p["en_vente"] for p in data)
    assert data[0]["nom"] == "Imprimante 58"  # tri par position


@pytest.mark.asyncio
async def test_produits_actifs_false(client, seeded):
    """actifs=false renvoie aussi les produits retirés (usage admin)."""
    token = await api_login(client, seeded["owner_email"], seeded["owner_mdp"])
    r = await client.get(
        "/api/v1/shop/produits?actifs=false",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert r.status_code == 200
    assert len(r.json()) == 3


@pytest.mark.asyncio
async def test_produits_sans_token(client, seeded):
    """Sans token → 401."""
    r = await client.get("/api/v1/shop/produits")
    assert r.status_code == 401


# ── API mobile : création de commande ────────────────────────────────

@pytest.mark.asyncio
async def test_commande_recalcule_prix(client, seeded):
    """Le prix serveur fait foi quand une ligne référence un produit."""
    token = await api_login(client, seeded["owner_email"], seeded["owner_mdp"])
    r = await client.post(
        "/api/v1/shop/commandes",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "client_nom": "Awa Diop",
            "client_telephone": "0700000002",
            "source": "APP",
            "lignes": [
                {
                    "produit_id": seeded["p1_id"],
                    "nom": "Tentative de fausse valeur",
                    "prix_unitaire": 10,
                    "quantite": 2,
                },
                {"produit_id": seeded["p2_id"], "quantite": 1},
            ],
        },
    )
    assert r.status_code == 201, r.text
    data = r.json()
    assert data["statut"] == "NOUVELLE"
    assert data["source"] == "APP"
    assert data["total"] == "52500.00"  # 2×25000 + 1×2500
    assert data["lignes"][0]["nom"] == "Imprimante 58"
    assert data["lignes"][0]["prix_unitaire"] == "25000.00"


@pytest.mark.asyncio
async def test_commande_sans_ligne_refusee(client, seeded):
    token = await api_login(client, seeded["owner_email"], seeded["owner_mdp"])
    r = await client.post(
        "/api/v1/shop/commandes",
        headers={"Authorization": f"Bearer {token}"},
        json={"client_nom": "X", "lignes": []},
    )
    assert r.status_code == 422


# ── Backoffice : produits ────────────────────────────────────────────

@pytest.mark.asyncio
async def test_admin_produits_list(client, seeded):
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    r = await client.get("/admin/shop/produits")
    assert r.status_code == 200
    assert "Imprimante 58" in r.text
    assert "Rupture" in r.text  # p2 stock 0


@pytest.mark.asyncio
async def test_admin_produits_creation(client, seeded):
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    r = await client.post(
        "/admin/shop/produits/nouveau",
        data={
            "nom": "Étiqueteuse 90",
            "prix": "15000",
            "categorie": "ACCESSOIRES",
            "icone": "print",
            "specs": "USB\nRapide",
            "stock": "4",
            "stock_alerte": "3",
            "en_vente": "on",
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )
    assert r.status_code == 303
    r2 = await client.get("/admin/shop/produits")
    assert "Étiqueteuse 90" in r2.text


@pytest.mark.asyncio
async def test_admin_produits_modification(client, seeded):
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    r = await client.post(
        f"/admin/shop/produits/{seeded['p1_id']}",
        data={
            "nom": "Imprimante 58 Pro",
            "tagline": "Améliorée",
            "prix": "26000",
            "categorie": "IMPRIMANTES",
            "icone": "print",
            "specs": "Bluetooth",
            "stock": "7",
            "stock_alerte": "3",
            "en_vente": "on",
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )
    assert r.status_code == 303
    r2 = await client.get(f"/admin/shop/produits/{seeded['p1_id']}")
    assert "Imprimante 58 Pro" in r2.text
    assert "7" in r2.text


@pytest.mark.asyncio
async def test_admin_produit_toggle(client, seeded):
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    r = await client.post(
        f"/admin/shop/produits/{seeded['p1_id']}/toggle",
        data={"csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert r.status_code == 303
    r2 = await client.get("/admin/shop/produits")
    assert "Retiré" in r2.text


@pytest.mark.asyncio
async def test_admin_produit_suppression(client, seeded):
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    r = await client.post(
        f"/admin/shop/produits/{seeded['p3_id']}/supprimer",
        data={"csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert r.status_code == 303
    r2 = await client.get("/admin/shop/produits")
    assert "Retiré des ventes" not in r2.text


# ── Backoffice : commandes ───────────────────────────────────────────

@pytest.mark.asyncio
async def test_admin_commande_manuelle(client, seeded, session_factory):
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    r = await client.post(
        "/admin/shop/commandes/nouvelle",
        data={
            "client_nom": "Moussa Kone",
            "client_telephone": "+2250500000000",
            "produit_id": [seeded["p1_id"], seeded["p1_id"]],
            "quantite": ["2", "1"],
            "notes": "Commande reçue par WhatsApp",
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )
    assert r.status_code == 303, r.text

    r2 = await client.get("/admin/shop/commandes")
    assert r2.status_code == 200
    assert "Moussa Kone" in r2.text
    assert "Saisie" in r2.text  # badge source ADMIN
    assert "75 000 FCFA" in r2.text  # 3 × 25000


@pytest.mark.asyncio
async def test_admin_commande_livree_decremente_stock(client, seeded, session_factory):
    """Passer une commande en LIVREE décrémente le stock du catalogue."""
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    # Créer une commande de 2 imprimantes
    await client.post(
        "/admin/shop/commandes/nouvelle",
        data={
            "client_nom": "Fatou",
            "produit_id": [seeded["p1_id"]],
            "quantite": ["2"],
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )

    async with session_factory() as db:
        from sqlalchemy import select

        from app.models import CommandeShop

        commande_id = (
            await db.execute(
                select(CommandeShop.id).order_by(CommandeShop.date_creation.desc()).limit(1)
            )
        ).scalar_one()

    # → LIVREE
    r = await client.post(
        f"/admin/shop/commandes/{commande_id}/statut",
        data={"statut": "LIVREE", "csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert r.status_code == 303

    # Vérifier le stock via l'API
    token = await api_login(client, seeded["owner_email"], seeded["owner_mdp"])
    r = await client.get(
        "/api/v1/shop/produits?actifs=false",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert r.status_code == 200
    p1 = next(p for p in r.json() if p["id"] == seeded["p1_id"])
    assert p1["stock"] == 8  # 10 - 2


@pytest.mark.asyncio
async def test_admin_commande_annulee_apres_livree_remet_stock(client, seeded, session_factory):
    """Annuler après LIVREE restaure le stock."""
    await admin_login(client, seeded["admin_email"], seeded["admin_mdp"])
    await client.post(
        "/admin/shop/commandes/nouvelle",
        data={
            "client_nom": "Idrissa",
            "produit_id": [seeded["p1_id"]],
            "quantite": ["3"],
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )

    async with session_factory() as db:
        from sqlalchemy import select

        from app.models import CommandeShop

        commande_id = (
            await db.execute(
                select(CommandeShop.id).order_by(CommandeShop.date_creation.desc()).limit(1)
            )
        ).scalar_one()

    await client.post(
        f"/admin/shop/commandes/{commande_id}/statut",
        data={"statut": "LIVREE", "csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    await client.post(
        f"/admin/shop/commandes/{commande_id}/statut",
        data={"statut": "ANNULEE", "csrf_token": await _csrf(client)},
        follow_redirects=False,
    )

    token = await api_login(client, seeded["owner_email"], seeded["owner_mdp"])
    r = await client.get(
        "/api/v1/shop/produits?actifs=false",
        headers={"Authorization": f"Bearer {token}"},
    )
    p1 = next(p for p in r.json() if p["id"] == seeded["p1_id"])
    assert p1["stock"] == 10  # 10 - 3 + 3