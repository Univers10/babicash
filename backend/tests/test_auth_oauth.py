import pytest
from sqlalchemy import select

import app.api.v1.oauth as oauth_module
from app.core.oauth import OAuthClaims
from app.models import Boutique, User


def _claims(**overrides) -> OAuthClaims:
    defaults = dict(
        provider="google",
        sub="google-sub-123",
        email="nouveau@gmail.com",
        email_verified=True,
        name="Nouvel Utilisateur",
        picture="https://example.com/avatar.png",
    )
    defaults.update(overrides)
    return OAuthClaims(**defaults)


@pytest.mark.asyncio
async def test_google_nouveau_compte_cree(client, session_factory, monkeypatch):
    async def fake_verify(id_token: str):
        return _claims()

    monkeypatch.setattr(oauth_module, "verify_google_id_token", fake_verify)

    resp = await client.post("/api/v1/auth/oauth/google", json={"id_token": "fake"})
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["role"] == "OWNER"
    assert body["email"] == "nouveau@gmail.com"
    assert body["access_token"]

    async with session_factory() as db:
        user = (
            await db.execute(select(User).where(User.email == "nouveau@gmail.com"))
        ).scalar_one()
        assert user.oauth_provider == "google"
        assert user.oauth_id == "google-sub-123"
        boutiques = (
            await db.execute(
                select(Boutique).where(Boutique.proprietaire_id == str(user.id))
            )
        ).scalars().all()
        assert len(boutiques) == 1


@pytest.mark.asyncio
async def test_google_reconnexion_meme_compte_pas_de_doublon(
    client, session_factory, monkeypatch
):
    async def fake_verify(id_token: str):
        return _claims()

    monkeypatch.setattr(oauth_module, "verify_google_id_token", fake_verify)

    first = await client.post("/api/v1/auth/oauth/google", json={"id_token": "fake"})
    second = await client.post("/api/v1/auth/oauth/google", json={"id_token": "fake"})
    assert first.status_code == 200
    assert second.status_code == 200

    async with session_factory() as db:
        users = (
            await db.execute(
                select(User).where(User.email == "nouveau@gmail.com")
            )
        ).scalars().all()
        assert len(users) == 1
        boutiques = (
            await db.execute(
                select(Boutique).where(
                    Boutique.proprietaire_id == str(users[0].id)
                )
            )
        ).scalars().all()
        assert len(boutiques) == 1


@pytest.mark.asyncio
async def test_google_auto_liaison_compte_mot_de_passe_existant(
    client, seeded, monkeypatch
):
    async def fake_verify(id_token: str):
        return _claims(email=seeded["owner_email"])

    monkeypatch.setattr(oauth_module, "verify_google_id_token", fake_verify)

    resp = await client.post("/api/v1/auth/oauth/google", json={"id_token": "fake"})
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["email"] == seeded["owner_email"]


@pytest.mark.asyncio
async def test_conflit_si_email_deja_lie_a_un_autre_provider(
    client, monkeypatch
):
    async def fake_google(id_token: str):
        return _claims(provider="google", sub="g-1", email="partage@gmail.com")

    async def fake_apple(identity_token: str):
        return _claims(provider="apple", sub="a-1", email="partage@gmail.com")

    monkeypatch.setattr(oauth_module, "verify_google_id_token", fake_google)
    monkeypatch.setattr(oauth_module, "verify_apple_id_token", fake_apple)

    first = await client.post("/api/v1/auth/oauth/google", json={"id_token": "fake"})
    assert first.status_code == 200

    second = await client.post(
        "/api/v1/auth/oauth/apple", json={"identity_token": "fake"}
    )
    assert second.status_code == 409


@pytest.mark.asyncio
async def test_token_invalide_renvoie_401(client, monkeypatch):
    from app.core.oauth import OAuthVerificationError

    async def fake_verify(id_token: str):
        raise OAuthVerificationError("signature invalide")

    monkeypatch.setattr(oauth_module, "verify_google_id_token", fake_verify)

    resp = await client.post("/api/v1/auth/oauth/google", json={"id_token": "bad"})
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_apple_sans_email_reconnexion_ok(client, monkeypatch):
    """Apple n'envoie l'email qu'à la première autorisation."""

    async def fake_apple_first(identity_token: str):
        return _claims(
            provider="apple", sub="apple-sub-1", email="premiere@icloud.com"
        )

    monkeypatch.setattr(oauth_module, "verify_apple_id_token", fake_apple_first)
    first = await client.post(
        "/api/v1/auth/oauth/apple", json={"identity_token": "fake"}
    )
    assert first.status_code == 200

    async def fake_apple_second(identity_token: str):
        return _claims(
            provider="apple",
            sub="apple-sub-1",
            email=None,
            email_verified=False,
            name=None,
            picture=None,
        )

    monkeypatch.setattr(oauth_module, "verify_apple_id_token", fake_apple_second)
    second = await client.post(
        "/api/v1/auth/oauth/apple", json={"identity_token": "fake"}
    )
    assert second.status_code == 200
