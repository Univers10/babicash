"""Tests de l'analytics admin : revenu net (déduit des versements ambassadeurs)
et de la page /admin/analytics (séries temporelles)."""
from datetime import datetime, timezone
from decimal import Decimal

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
from app.models import Abonnement, Ambassadeur, Boutique, PaiementAbonnement, Payout, User
from app.services import admin_analytics_service

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


@pytest_asyncio.fixture
async def admin_owner_payout_seeded(session_factory):
    """Admin + owner avec abonnement payant BOUTIQUE (5000 F) + un versement
    ambassadeur payé de 1000 F, pour vérifier le revenu net déduit."""
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
            nom="Boss", email="boss@test.ci",
            mot_de_passe_hash=hash_password("boss1234"), role="OWNER", actif=True,
        )
        db.add(owner)

        amb_user = User(
            nom="Amb", email="amb@promo.ci",
            mot_de_passe_hash=hash_password("promo1234"), role="AMBASSADEUR", actif=True,
        )
        db.add(amb_user)
        await db.flush()

        boutique = Boutique(nom="Boutique Test", proprietaire_id=str(owner.id))
        db.add(boutique)

        abo = Abonnement(
            proprietaire_id=str(owner.id),
            plan="BOUTIQUE",
            prix_base=Decimal("5000.00"),
            quota_ventes_par_boutique=2147483647,
            nb_boutiques_max=1,
            nb_gerants_max=3,
            actif=True,
        )
        db.add(abo)

        ambassadeur = Ambassadeur(
            user_id=amb_user.id, code="PROMO2026",
            momo_numero="0700888999", momo_operateur="WAVE", actif=True,
        )
        db.add(ambassadeur)
        await db.flush()

        payout = Payout(
            ambassadeur_id=ambassadeur.id,
            semaine="2026-W20",
            montant_total=Decimal("1000.00"),
            momo_numero="0700888999",
            statut="PAYE",
            date_execution=datetime.now(timezone.utc).replace(tzinfo=None),
        )
        db.add(payout)

        db.add(
            PaiementAbonnement(
                proprietaire_id=str(owner.id),
                plan="BOUTIQUE",
                montant=Decimal("5000.00"),
                date_paiement=datetime.now(timezone.utc).replace(tzinfo=None),
            )
        )

        await db.commit()

        return {
            "admin_email": "admin@test.ci",
            "admin_mdp": "admin1234",
            "owner_id": str(owner.id),
        }


@pytest.mark.asyncio
async def test_revenu_net_deduit_des_versements_ambassadeurs(client, admin_owner_payout_seeded):
    """Le dashboard affiche un revenu net = revenu brut - versements payés."""
    await admin_login(
        client,
        admin_owner_payout_seeded["admin_email"],
        admin_owner_payout_seeded["admin_mdp"],
    )
    r = await client.get("/admin/")
    assert r.status_code == 200, r.text
    # 5000 F de MRR (BOUTIQUE, 1 boutique) - 1000 F versés à l'ambassadeur = 4000 F net.
    assert "Revenu net" in r.text
    assert "4000" in r.text.replace("&nbsp;", " ").replace(" ", "")


@pytest.mark.asyncio
async def test_analytics_page_accessible(client, admin_owner_payout_seeded):
    await admin_login(
        client,
        admin_owner_payout_seeded["admin_email"],
        admin_owner_payout_seeded["admin_mdp"],
    )
    r = await client.get("/admin/analytics")
    assert r.status_code == 200, r.text
    assert "Analytics" in r.text
    assert "chart-revenus" in r.text


@pytest.mark.asyncio
async def test_analytics_page_granularite_annee(client, admin_owner_payout_seeded):
    await admin_login(
        client,
        admin_owner_payout_seeded["admin_email"],
        admin_owner_payout_seeded["admin_mdp"],
    )
    r = await client.get("/admin/analytics?granularite=annee&nb=3")
    assert r.status_code == 200, r.text


@pytest.mark.asyncio
async def test_analytics_page_sans_cookie_redirect(client):
    r = await client.get("/admin/analytics", follow_redirects=False)
    assert r.status_code == 307
    assert "/admin/login" in r.headers["location"]


# ── Tests unitaires du service admin_analytics_service ─────────────────

def test_normaliser_params_defaut_mois():
    granularite, nb = admin_analytics_service.normaliser_params(None, None)
    assert granularite == "mois"
    assert nb == 12


def test_normaliser_params_defaut_annee():
    granularite, nb = admin_analytics_service.normaliser_params("annee", None)
    assert granularite == "annee"
    assert nb == 6


def test_normaliser_params_plafonne():
    granularite, nb = admin_analytics_service.normaliser_params("mois", 999)
    assert nb == admin_analytics_service.MAX_MOIS
    granularite, nb = admin_analytics_service.normaliser_params("annee", 999)
    assert nb == admin_analytics_service.MAX_ANNEES


def test_normaliser_params_valeur_invalide_repli_mois():
    granularite, _ = admin_analytics_service.normaliser_params("semaine", 5)
    assert granularite == "mois"


@pytest.mark.asyncio
async def test_serie_revenus_agrege_par_mois(session_factory):
    async with session_factory() as db:
        now = datetime.now(timezone.utc).replace(tzinfo=None)
        db.add(PaiementAbonnement(proprietaire_id="p1", plan="BOUTIQUE", montant=Decimal("5000.00"), date_paiement=now))
        db.add(PaiementAbonnement(proprietaire_id="p2", plan="KIOSQUE", montant=Decimal("2000.00"), date_paiement=now))
        await db.commit()

    async with session_factory() as db:
        serie = await admin_analytics_service.serie_revenus(db, "mois", 3)
        assert len(serie["labels"]) == 3
        assert serie["values"][-1] == pytest.approx(7000.0)
        assert serie["values"][0] == 0
        assert serie["values"][1] == 0
