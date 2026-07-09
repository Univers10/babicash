"""Script de seed: crée un propriétaire, une boutique, un gérant, 8 catégories et 50 produits.

Usage:
    python -m app.seed
"""
import asyncio
from decimal import Decimal

from sqlalchemy import select

from app.core.db import AsyncSessionLocal
from app.core.security import hash_password, hash_pin
from app.models import Boutique, Categorie, Produit, User


CATEGORIES_PRODUITS = {
    "Boissons": [
        ("Eau minérale 1.5L", 200, 300, 120),
        ("Eau minérale 0.5L", 100, 150, 200),
        ("Coca-Cola 33cl", 250, 400, 80),
        ("Fanta Orange 33cl", 250, 400, 75),
        ("Sprite 33cl", 250, 400, 60),
        ("Jus de bissap 1L", 500, 800, 30),
        ("Bière Flag 65cl", 600, 900, 50),
    ],
    "Hygiène & Beauté": [
        ("Savon de Marseille", 300, 500, 100),
        ("Dentifrice Colgate 100ml", 500, 800, 60),
        ("Éponge de bain", 100, 200, 150),
        ("Déodorant spray 150ml", 800, 1200, 40),
        ("Crème nivea 100ml", 700, 1100, 35),
        ("Shampooing sachet", 50, 100, 300),
        ("Papier hygiénique x4", 600, 900, 80),
    ],
    "Alimentaire": [
        ("Riz parfumé 1kg", 700, 1000, 90),
        ("Huile de palme 1L", 800, 1200, 50),
        ("Sucre en morceaux 1kg", 600, 900, 70),
        ("Sel iodé 1kg", 200, 350, 100),
        ("Pâtes spaghetti 500g", 400, 600, 60),
        ("Lait concentré 400g", 500, 750, 55),
        ("Tomate concentrée 400g", 350, 550, 65),
    ],
    "Biscuits & Snacks": [
        ("Biscuit Sablé x10", 200, 350, 120),
        ("Chips Pringles 40g", 300, 500, 80),
        ("Bonbons menthe sachet", 50, 100, 250),
        ("Chewing-gum x5", 50, 100, 300),
        ("Chocolat tablette 100g", 500, 800, 40),
        ("Cacahuètes grillées 200g", 300, 500, 60),
    ],
    "Petit-déjeuner": [
        ("Café Nescafé sachet", 50, 100, 400),
        ("Thé Lipton sachet", 25, 50, 500),
        ("Lait en poudre 400g", 1500, 2200, 30),
        ("Cacao en poudre 200g", 800, 1200, 25),
        ("Pain de mie tranché", 500, 750, 40),
        ("Confiture fraise 250g", 700, 1100, 20),
    ],
    "Électronique & Téléphonie": [
        ("Chargeur USB universel", 1000, 1500, 30),
        ("Écouteurs filaires", 500, 1000, 50),
        ("Carte mémoire 16Go", 2000, 3500, 20),
        ("Coque téléphone", 300, 700, 60),
        ("Lampe torche LED", 800, 1500, 25),
        ("Pile AA x2", 200, 400, 100),
    ],
    "Papeterie": [
        ("Cahier 200 pages", 400, 700, 80),
        ("Stylo BIC bleu", 50, 100, 300),
        ("Crayon à papier HB", 25, 50, 400),
        ("Gomme blanche", 50, 100, 200),
        ("Règle 30cm", 100, 200, 100),
        ("Colle en bâton", 150, 300, 80),
    ],
    "Ménage & Entretien": [
        ("Javel 1L", 300, 500, 60),
        ("Éponge vaisselle x3", 150, 300, 100),
        ("Détergent poudre 500g", 500, 800, 50),
        ("Sac poubelle x10", 200, 400, 80),
        ("Balai plastique", 1000, 1800, 20),
        ("Insecticide spray", 1200, 2000, 25),
    ],
}


async def seed() -> None:
    async with AsyncSessionLocal() as db:
        # Owner
        owner = (
            await db.execute(select(User).where(User.email == "boss@babicash.ci"))
        ).scalar_one_or_none()
        if owner is None:
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
            print("  Owner créé.")

        # Boutique
        boutique = (
            await db.execute(select(Boutique).where(Boutique.proprietaire_id == str(owner.id)))
        ).scalar_one_or_none()
        if boutique is None:
            boutique = Boutique(nom="Boutique Adjamé", proprietaire_id=str(owner.id))
            db.add(boutique)
            await db.flush()
            print("  Boutique créée.")

        # Manager
        manager = (
            await db.execute(select(User).where(User.telephone == "0700000001"))
        ).scalar_one_or_none()
        if manager is None:
            manager = User(
                nom="Gérant Adjamé",
                telephone="0700000001",
                code_pin_hash=hash_pin("4321"),
                role="MANAGER",
                boutique_id=boutique.id,
            )
            db.add(manager)
            print("  Manager créé.")

        # Catégories et produits
        existing_cats = (
            await db.execute(select(Categorie).where(Categorie.boutique_id == boutique.id))
        ).scalars().all()
        existing_cat_noms = {c.nom for c in existing_cats}

        produit_count = 0
        for cat_nom, produits in CATEGORIES_PRODUITS.items():
            if cat_nom in existing_cat_noms:
                continue
            cat = Categorie(boutique_id=boutique.id, nom=cat_nom)
            db.add(cat)
            await db.flush()

            for nom, achat, vente, stock in produits:
                db.add(Produit(
                    boutique_id=boutique.id,
                    categorie_id=cat.id,
                    nom=nom,
                    prix_achat_moyen=Decimal(str(achat)),
                    prix_vente_suggere=Decimal(str(vente)),
                    stock_actuel=stock,
                ))
                produit_count += 1

        await db.commit()
        print(f"Seed terminé — {produit_count} nouveaux produits ajoutés.")
        print("  OWNER  : email boss@babicash.ci / boss1234 (ou tél 0700000000 + PIN 1234)")
        print("  MANAGER: tél 0700000001 + PIN 4321")
        print(f"  boutique_id = {boutique.id}")


if __name__ == "__main__":
    asyncio.run(seed())
