"""Tests du backoffice admin."""
import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings
from app.core.csrf import generate_csrf_token
from app.core.db import Base, get_db
from app.core.security import hash_password
from app.main import app
from app.models import Abonnement, Boutique, User


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
async def admin_seeded(session_factory):
    """Crée un admin + un owner + boutique + abonnement."""
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

        boutique = Boutique(nom="Test Shop", proprietaire_id=str(owner.id))
        db.add(boutique)
        await db.flush()

        abo = Abonnement(
            proprietaire_id=str(owner.id),
            plan="FREE",
            prix_base=0.00,
            quota_ventes_par_boutique=20,
            nb_boutiques_max=1,
            nb_gerants_max=1,
            actif=True,
        )
        db.add(abo)
        await db.commit()

        return {
            "admin_email": "admin@test.ci",
            "admin_mdp": "admin1234",
            "owner_id": str(owner.id),
            "owner_email": "boss@test.ci",
        }


@pytest_asyncio.fixture
async def client(session_factory):
    async def override_get_db():
        async with session_factory() as db:
            yield db

    app.dependency_overrides[get_db] = override_get_db
    # Tests en HTTP : le cookie admin ne doit pas être marqué Secure,
    # sinon httpx ne le renvoie pas et l'auth admin échoue (307).
    settings.SECURE_COOKIES = False
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()


async def _csrf(client: AsyncClient) -> str:
    """Récupère un token CSRF valide.

    Le GET /admin/login pose l'éventuel cookie de session ; le token est
    ensuite dérivé du même session_id que celui vérifié par le serveur.
    """
    await client.get("/admin/login")
    session_id = client.cookies.get("admin_session_id", "")
    return generate_csrf_token(session_id)


async def admin_login(client: AsyncClient, email: str, mdp: str) -> dict:
    """Login admin, retourne les cookies."""
    resp = await client.post(
        "/admin/login",
        data={"email": email, "mot_de_passe": mdp, "csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert resp.status_code == 303, resp.text
    return dict(client.cookies)


# ── Tests login ──────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_login_page_affiche(client):
    """La page de login s'affiche."""
    r = await client.get("/admin/login")
    assert r.status_code == 200
    assert "BabiCash" in r.text


@pytest.mark.asyncio
async def test_login_succes(client, admin_seeded):
    """Login admin avec bons identifiants → redirect vers dashboard."""
    r = await client.post(
        "/admin/login",
        data={
            "email": admin_seeded["admin_email"],
            "mot_de_passe": admin_seeded["admin_mdp"],
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )
    assert r.status_code == 303
    assert r.headers["location"] == "/admin/"
    assert "admin_token" in r.cookies


@pytest.mark.asyncio
async def test_login_mauvais_mdp(client, admin_seeded):
    """Login avec mauvais mot de passe → redirect avec error."""
    r = await client.post(
        "/admin/login",
        data={
            "email": admin_seeded["admin_email"],
            "mot_de_passe": "mauvais",
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )
    assert r.status_code == 303
    assert "error=1" in r.headers["location"]


@pytest.mark.asyncio
async def test_login_owner_rejete(client, admin_seeded):
    """Un OWNER ne peut pas se connecter en admin."""
    r = await client.post(
        "/admin/login",
        data={
            "email": admin_seeded["owner_email"],
            "mot_de_passe": "boss1234",
            "csrf_token": await _csrf(client),
        },
        follow_redirects=False,
    )
    assert r.status_code == 303
    assert "error=1" in r.headers["location"]


@pytest.mark.asyncio
async def test_logout(client, admin_seeded):
    """Logout supprime le cookie et redirige vers login."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get("/admin/logout", follow_redirects=False)
    assert r.status_code == 303
    assert "/admin/login" in r.headers["location"]


# ── Tests accès protégé ─────────────────────────────────────────────

@pytest.mark.asyncio
async def test_dashboard_sans_cookie_redirect(client):
    """Sans cookie → redirect vers login."""
    r = await client.get("/admin/", follow_redirects=False)
    assert r.status_code == 307
    assert "/admin/login" in r.headers["location"]


@pytest.mark.asyncio
async def test_dashboard_avec_cookie(client, admin_seeded):
    """Avec cookie admin valide → page dashboard."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get("/admin/")
    assert r.status_code == 200
    assert "Dashboard" in r.text
    assert "Boss" in r.text or "babicash" in r.text.lower()


# ── Tests owners ─────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_owners_list(client, admin_seeded):
    """Liste des owners affiche le owner seeded."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get("/admin/owners")
    assert r.status_code == 200
    assert "Boss" in r.text


@pytest.mark.asyncio
async def test_owner_detail(client, admin_seeded):
    """Détail d'un owner affiche ses infos."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get(f"/admin/owners/{admin_seeded['owner_id']}")
    assert r.status_code == 200
    assert "Boss" in r.text
    assert "FREE" in r.text


@pytest.mark.asyncio
async def test_owner_toggle(client, admin_seeded):
    """Toggle le statut d'un owner."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.post(
        f"/admin/owners/{admin_seeded['owner_id']}/toggle",
        data={"csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert r.status_code == 303

    # Vérifier que le owner est maintenant inactif
    r2 = await client.get(f"/admin/owners/{admin_seeded['owner_id']}")
    assert "Inactif" in r2.text


@pytest.mark.asyncio
async def test_owner_change_plan(client, admin_seeded):
    """Changer le plan d'un owner."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.post(
        f"/admin/owners/{admin_seeded['owner_id']}/plan",
        data={"plan": "BOUTIQUE", "csrf_token": await _csrf(client)},
        follow_redirects=False,
    )
    assert r.status_code == 303

    # Vérifier que le plan a changé
    r2 = await client.get(f"/admin/owners/{admin_seeded['owner_id']}")
    assert "BOUTIQUE" in r2.text


# ── Tests abonnements ────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_abonnements_list(client, admin_seeded):
    """Liste des abonnements."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get("/admin/abonnements")
    assert r.status_code == 200
    assert "Abonnements" in r.text


@pytest.mark.asyncio
async def test_abonnements_filtre_plan(client, admin_seeded):
    """Filtre par plan."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get("/admin/abonnements?filtre_plan=FREE")
    assert r.status_code == 200


# ── Tests boutiques ──────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_boutiques_list(client, admin_seeded):
    """Liste des boutiques."""
    await admin_login(client, admin_seeded["admin_email"], admin_seeded["admin_mdp"])
    r = await client.get("/admin/boutiques")
    assert r.status_code == 200
    assert "Test Shop" in r.text
