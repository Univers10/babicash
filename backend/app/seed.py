"""Script de seed: crée un propriétaire, une boutique, un gérant et des produits.

Usage:
    python -m app.seed
"""
import asyncio
from decimal import Decimal

from sqlalchemy import select

from app.core.db import AsyncSessionLocal
from app.core.security import hash_password, hash_pin
from app.models import Boutique, Produit, User


async def seed() -> None:
    async with AsyncSessionLocal() as db:
        existing = (
            await db.execute(select(User).where(User.email == "boss@babicash.ci"))
        ).scalar_one_or_none()
        if existing is not None:
            print("Seed déjà présent, rien à faire.")
            return

        owner = User(
            nom="Le Boss",
            email="boss@babicash.ci",
            mot_de_passe_hash=hash_password("boss1234"),
            telephone="0700000000",
            code_pin_hash=hash_pin("1234"),
            role="OWNER",
        )
        db.add(owner)
        await db.flush()

        boutique = Boutique(nom="Boutique Adjamé", proprietaire_id=str(owner.id))
        db.add(boutique)
        await db.flush()

        manager = User(
            nom="Gérant Adjamé",
            telephone="0700000001",
            code_pin_hash=hash_pin("4321"),
            role="MANAGER",
            boutique_id=boutique.id,
        )
        db.add(manager)

        db.add_all(
            [
                Produit(
                    boutique_id=boutique.id,
                    nom="Savon de Marseille",
                    prix_achat_moyen=Decimal("300.00"),
                    prix_vente_suggere=Decimal("500.00"),
                    stock_actuel=100,
                ),
                Produit(
                    boutique_id=boutique.id,
                    nom="Bouteille d'eau 1.5L",
                    prix_achat_moyen=Decimal("200.00"),
                    prix_vente_suggere=Decimal("300.00"),
                    stock_actuel=200,
                ),
            ]
        )

        await db.commit()
        print("Seed terminé.")
        print("  OWNER  : email boss@babicash.ci / boss1234 (ou tél 0700000000 + PIN 1234)")
        print("  MANAGER: tél 0700000001 + PIN 4321")
        print(f"  boutique_id = {boutique.id}")


if __name__ == "__main__":
    asyncio.run(seed())
