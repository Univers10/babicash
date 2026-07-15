"""Seed le compte admin dans la base de données."""
import asyncio
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.core.security import hash_password
from app.models import User


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
            admin = User(
                nom="Admin",
                email="admin@babicash.com",
                mot_de_passe_hash=hash_password("admin1234"),
                role="ADMIN",
                actif=True,
            )
            db.add(admin)
            await db.commit()
            print("✅ Compte admin créé : admin@babicash.com / admin1234")
        else:
            print("ℹ️  Compte admin existe déjà.")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed_admin())
