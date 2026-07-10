"""
Script pour créer le premier propriétaire + boutique en production.

Usage (depuis le container) :
    docker compose exec api python -m scripts.seed_owner

Ou depuis le répertoire backend :
    python -m scripts.seed_owner
"""

import asyncio
import uuid

import bcrypt
from sqlalchemy import select

from app.core.db import AsyncSessionLocal
from app.models.models import User, Boutique, Abonnement


async def seed():
    async with AsyncSessionLocal() as db:
        # Vérifier si un owner existe déjà
        result = await db.execute(select(User).where(User.role == "OWNER").limit(1))
        existing = result.scalar_one_or_none()
        if existing:
            print(f"✅ Un propriétaire existe déjà : {existing.email}")
            return

        # Créer le propriétaire
        owner_id = uuid.uuid4()
        hashed_pw = bcrypt.hashpw("boss@1234".encode(), bcrypt.gensalt()).decode()

        owner = User(
            id=owner_id,
            email="boss@babicash.ci",
            nom="Boss",
            mot_de_passe_hash=hashed_pw,
            role="OWNER",
        )
        db.add(owner)

        # Créer la boutique
        boutique_id = uuid.uuid4()
        boutique = Boutique(
            id=boutique_id,
            nom="Ma Boutique",
            proprietaire_id=str(owner_id),
        )
        db.add(boutique)

        # Créer l'abonnement FREE
        abonnement = Abonnement(
            id=uuid.uuid4(),
            proprietaire_id=str(owner_id),
            plan="FREE",
        )
        db.add(abonnement)

        await db.commit()
        print("🎉 Propriétaire créé !")
        print(f"   Email       : boss@babicash.ci")
        print(f"   Mot de passe: boss@1234")
        print(f"   Boutique    : Ma Boutique ({boutique_id})")


if __name__ == "__main__":
    asyncio.run(seed())
