from decimal import Decimal

import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.db import Base, get_db
from app.core.security import hash_password, hash_pin
from app.main import app
from app.models import Boutique, Produit, User

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
    """Crée owner, boutique, manager et un produit. Retourne des ids utiles."""
    async with session_factory() as db:
        owner = User(
            nom="Boss",
            email="boss@test.ci",
            mot_de_passe_hash=hash_password("boss1234"),
            role="OWNER",
        )
        db.add(owner)
        await db.flush()

        boutique = Boutique(nom="Test Boutique", proprietaire_id=str(owner.id))
        db.add(boutique)
        await db.flush()

        manager = User(
            nom="Gerant",
            email="gerant@test.ci",
            mot_de_passe_hash=hash_password("gerant1234"),
            telephone="0700000001",
            code_pin_hash=hash_pin("4321"),
            role="MANAGER",
            boutique_id=boutique.id,
        )
        db.add(manager)

        produit = Produit(
            boutique_id=boutique.id,
            nom="Savon",
            prix_achat_moyen=Decimal("300.00"),
            prix_vente_suggere=Decimal("500.00"),
            stock_actuel=100,
        )
        db.add(produit)
        await db.commit()

        return {
            "boutique_id": str(boutique.id),
            "produit_id": str(produit.id),
            "owner_email": "boss@test.ci",
            "manager_email": "gerant@test.ci",
            "manager_telephone": "0700000001",
            "manager_pin": "4321",
        }


@pytest_asyncio.fixture
async def client(session_factory):
    async def override_get_db():
        async with session_factory() as db:
            yield db

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()


async def login(client: AsyncClient, email: str, mot_de_passe: str) -> str:
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "mot_de_passe": mot_de_passe},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()["access_token"]


async def login_pin(client: AsyncClient, telephone: str, code_pin: str) -> str:
    resp = await client.post(
        "/api/v1/auth/login-pin",
        json={"telephone": telephone, "code_pin": code_pin},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()["access_token"]
