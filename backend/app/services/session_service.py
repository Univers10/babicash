from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import SessionCaisse, TransactionCaisse, Vente
from app.schemas.session import SessionOut, SessionResume

_ZERO = Decimal("0.00")


async def compute_resume(db: AsyncSession, session: SessionCaisse) -> SessionResume:
    """Calcule la réconciliation de caisse d'une session.

    Le tiroir-caisse physique ne contient que les espèces :
    montant_theorique = montant_initial + ventes ESPECES + entrées - sorties.
    Les paiements Mobile Money / Crédit n'impactent pas le tiroir.
    """
    # Ventes espèces
    total_especes = (
        await db.execute(
            select(func.coalesce(func.sum(Vente.montant_total), 0)).where(
                Vente.session_id == session.id,
                Vente.mode_paiement == "ESPECES",
            )
        )
    ).scalar_one()

    # Ventes hors espèces (Mobile Money + Crédit)
    total_autres = (
        await db.execute(
            select(func.coalesce(func.sum(Vente.montant_total), 0)).where(
                Vente.session_id == session.id,
                Vente.mode_paiement != "ESPECES",
            )
        )
    ).scalar_one()

    nb_ventes = (
        await db.execute(
            select(func.count(Vente.id)).where(Vente.session_id == session.id)
        )
    ).scalar_one()

    total_entrees = (
        await db.execute(
            select(func.coalesce(func.sum(TransactionCaisse.montant), 0)).where(
                TransactionCaisse.session_id == session.id,
                TransactionCaisse.type_transaction == "ENTREE",
            )
        )
    ).scalar_one()

    total_sorties = (
        await db.execute(
            select(func.coalesce(func.sum(TransactionCaisse.montant), 0)).where(
                TransactionCaisse.session_id == session.id,
                TransactionCaisse.type_transaction == "SORTIE_DEPENSE",
            )
        )
    ).scalar_one()

    total_especes = Decimal(str(total_especes))
    total_autres = Decimal(str(total_autres))
    total_entrees = Decimal(str(total_entrees))
    total_sorties = Decimal(str(total_sorties))

    montant_theorique = (
        session.montant_initial + total_especes + total_entrees - total_sorties
    )

    ecart: Decimal | None = None
    ecart_signale = False
    if session.statut == "FERME":
        ecart = session.montant_final_declare - montant_theorique
        ecart_signale = ecart != _ZERO

    return SessionResume(
        session=SessionOut.model_validate(session),
        nb_ventes=int(nb_ventes),
        total_ventes_especes=total_especes,
        total_ventes_autres=total_autres,
        total_entrees=total_entrees,
        total_sorties=total_sorties,
        montant_theorique=montant_theorique,
        ecart=ecart,
        ecart_signale=ecart_signale,
    )
