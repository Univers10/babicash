"""Seed le compte admin dans la base de données."""
import asyncio
import secrets
import string
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.core.security import hash_password
from app.models import User


def _generate_password(length: int = 16) -> str:
    """Génère un mot de passe aléatoire sûr."""
    alphabet = string.ascii_letters + string.digits + "!@#$%&*"
    while True:
        pwd = ''.join(secrets.choice(alphabet) for _ in range(length))
        if (any(c.islower() for c in pwd) and any(c.isupper() for c in pwd)
                and any(c.isdigit() for c in pwd)):
            return pwd


async def seed_admin():
    engine = create_async_engine(settings.DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as db:
        admin = (
            await db.execute(
                select(User).where(User.email == "admin@babicash.com")
            )
        ).scalar_one_or_none()

        if admin is None:
            password = _generate_password()
            admin = User(
                nom="Admin",
                email="admin@babicash.com",
                mot_de_passe_hash=hash_password(password),
                role="ADMIN",
                actif=True,
            )
            db.add(admin)
            await db.commit()
            print("=" * 60)
            print("✅ Compte admin créé")
            print(f"   Email    : admin@babicash.com")
            print(f"   Mot de passe : {password}")
            print("   ⚠️  Changez ce mot de passe immédiatement après connexion!")
            print("=" * 60)
        else:
            print("ℹ️  Compte admin existe déjà.")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed_admin())
