import uuid
from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import (
    Boutique,
    CompteTiers,
    LigneVente,
    Produit,
    TransactionCaisse,
    Vente,
)
from app.schemas.recu import RecuLigne, RecuOut
from app.schemas.sync import (
    AlerteStockItem,
    DepenseIn,
    DepensePushResult,
    EntreeStockIn,
    EntreeStockPushResult,
    SyncPushRequest,
    SyncPushResponse,
    VenteIn,
    VentePushResult,
)


def _build_recu(
    vente: Vente,
    boutique_nom: str,
    lignes_data: list[tuple[str, int, Decimal, Decimal]],
    client_nom: str | None,
) -> RecuOut:
    return RecuOut(
        vente_id=vente.id,
        numero=str(vente.id)[:8].upper(),
        boutique_nom=boutique_nom,
        date_vente=vente.date_vente,
        mode_paiement=vente.mode_paiement,
        lignes=[
            RecuLigne(
                nom=nom,
                quantite=qte,
                prix_unitaire=pu,
                total_ligne=total,
            )
            for (nom, qte, pu, total) in lignes_data
        ],
        montant_total=vente.montant_total,
        client_nom=client_nom,
    )


async def _process_vente(
    db: AsyncSession, boutique: Boutique, vente_in: VenteIn
) -> tuple[VentePushResult, dict[uuid.UUID, Produit]]:
    # Idempotence: si l'id_local existe déjà, ne pas recréer.
    existing = (
        await db.execute(
            select(Vente).where(
                Vente.id_local_smartphone == vente_in.id_local_smartphone
            )
        )
    ).scalar_one_or_none()
    if existing is not None:
        return VentePushResult(
            id_local_smartphone=vente_in.id_local_smartphone,
            vente_id=existing.id,
            deja_synchronisee=True,
            signale_proprietaire=existing.signale_proprietaire,
        ), {}

    # Précharger les produits référencés
    produit_ids = [l.produit_id for l in vente_in.lignes if l.produit_id]
    produits: dict[uuid.UUID, Produit] = {}
    if produit_ids:
        rows = (
            await db.execute(
                select(Produit).where(Produit.id.in_(produit_ids))
            )
        ).scalars()
        produits = {p.id: p for p in rows}

    vente = Vente(
        boutique_id=boutique.id,
        session_id=vente_in.session_id,
        tier_id=vente_in.tier_id,
        mode_paiement=vente_in.mode_paiement,
        id_local_smartphone=vente_in.id_local_smartphone,
        montant_total=Decimal("0.00"),
        synced=True,
    )
    if vente_in.date_vente is not None:
        vente.date_vente = vente_in.date_vente

    total = Decimal("0.00")
    a_perte = False
    avertissement: str | None = None
    recu_lignes: list[tuple[str, int, Decimal, Decimal]] = []

    for ligne_in in vente_in.lignes:
        produit = (
            produits.get(ligne_in.produit_id) if ligne_in.produit_id else None
        )
        prix_achat = produit.prix_achat_moyen if produit else Decimal("0.00")
        nom_article = produit.nom if produit else "Article libre"

        # Marge calculée côté serveur (jamais celle du client)
        marge = (ligne_in.prix_vendu_reel - prix_achat) * ligne_in.quantite
        ligne_a_perte = produit is not None and ligne_in.prix_vendu_reel < prix_achat
        if ligne_a_perte:
            a_perte = True

        total_ligne = ligne_in.prix_vendu_reel * ligne_in.quantite
        total += total_ligne

        vente.lignes.append(
            LigneVente(
                produit_id=ligne_in.produit_id,
                quantite=ligne_in.quantite,
                prix_vendu_reel=ligne_in.prix_vendu_reel,
                marge_calculee=marge,
                vente_a_perte=ligne_a_perte,
            )
        )
        recu_lignes.append(
            (
                nom_article,
                ligne_in.quantite,
                ligne_in.prix_vendu_reel,
                total_ligne,
            )
        )

        # Décrémenter le stock (avec garde-fou contre le stock négatif)
        if produit is not None:
            if produit.stock_actuel < ligne_in.quantite:
                avertissement_stock = (
                    f"Stock insuffisant pour '{produit.nom}' : "
                    f"{produit.stock_actuel} disponible(s), {ligne_in.quantite} demandé(s). "
                    "Vente enregistrée mais le stock sera négatif."
                )
                if avertissement is None:
                    avertissement = avertissement_stock
                else:
                    avertissement = f"{avertissement} | {avertissement_stock}"
            produit.stock_actuel -= ligne_in.quantite

    vente.montant_total = total
    vente.signale_proprietaire = a_perte

    # Crédit client: augmente le solde dû
    client_nom: str | None = None
    if vente_in.tier_id is not None:
        tier = (
            await db.execute(
                select(CompteTiers).where(CompteTiers.id == vente_in.tier_id)
            )
        ).scalar_one_or_none()
        if tier is not None:
            client_nom = tier.nom
            if vente_in.mode_paiement == "CREDIT":
                tier.solde_du += total

    db.add(vente)
    await db.flush()

    if a_perte:
        msg_perte = "Vente à perte détectée : cette vente sera signalée au propriétaire."
        avertissement = f"{avertissement} | {msg_perte}" if avertissement else msg_perte

    recu = _build_recu(vente, boutique.nom, recu_lignes, client_nom)

    return VentePushResult(
        id_local_smartphone=vente_in.id_local_smartphone,
        vente_id=vente.id,
        deja_synchronisee=False,
        signale_proprietaire=a_perte,
        avertissement=avertissement,
        recu=recu,
    ), produits


async def _process_depense(
    db: AsyncSession, boutique: Boutique, depense_in: DepenseIn
) -> DepensePushResult:
    existing = (
        await db.execute(
            select(TransactionCaisse).where(
                TransactionCaisse.id_local_smartphone
                == depense_in.id_local_smartphone
            )
        )
    ).scalar_one_or_none()
    if existing is not None:
        return DepensePushResult(
            id_local_smartphone=depense_in.id_local_smartphone,
            transaction_id=existing.id,
            deja_synchronisee=True,
        )

    tx = TransactionCaisse(
        boutique_id=boutique.id,
        session_id=depense_in.session_id,
        type_transaction=depense_in.type_transaction,
        montant=depense_in.montant,
        motif=depense_in.motif,
        id_local_smartphone=depense_in.id_local_smartphone,
        synced=True,
    )
    if depense_in.date_transaction is not None:
        tx.date_transaction = depense_in.date_transaction

    db.add(tx)
    await db.flush()

    return DepensePushResult(
        id_local_smartphone=depense_in.id_local_smartphone,
        transaction_id=tx.id,
        deja_synchronisee=False,
    )


async def _process_entree_stock(
    db: AsyncSession, boutique: Boutique, entree_in: EntreeStockIn
) -> tuple[EntreeStockPushResult, dict[uuid.UUID, Produit]]:
    # Idempotence
    existing = (
        await db.execute(
            select(TransactionCaisse).where(
                TransactionCaisse.id_local_smartphone == entree_in.id_local_smartphone
            )
        )
    ).scalar_one_or_none()
    if existing is not None:
        return EntreeStockPushResult(
            id_local_smartphone=entree_in.id_local_smartphone,
            transaction_id=existing.id,
            deja_synchronisee=True,
        ), {}

    # Précharger les produits référencés
    produit_ids = [l.produit_id for l in entree_in.lignes]
    rows = (
        await db.execute(select(Produit).where(Produit.id.in_(produit_ids)))
    ).scalars()
    produits: dict[uuid.UUID, Produit] = {p.id: p for p in rows}

    montant_total = Decimal("0.00")
    produits_mis_a_jour: list[uuid.UUID] = []

    for ligne in entree_in.lignes:
        produit = produits.get(ligne.produit_id)
        if produit is None:
            continue  # produit inconnu, on ignore la ligne

        # Recalcul du prix d'achat moyen (Coût Moyen Pondéré)
        ancien_stock = Decimal(produit.stock_actuel)
        if ancien_stock > 0:
            produit.prix_achat_moyen = (
                ancien_stock * produit.prix_achat_moyen
                + Decimal(ligne.quantite) * ligne.prix_achat_unitaire
            ) / (ancien_stock + Decimal(ligne.quantite))
        else:
            # Stock à zéro ou négatif : le nouveau prix devient le prix de référence
            produit.prix_achat_moyen = ligne.prix_achat_unitaire

        produit.stock_actuel += ligne.quantite
        montant_total += ligne.prix_achat_unitaire * Decimal(ligne.quantite)
        produits_mis_a_jour.append(produit.id)

    # Transaction caisse pour traçabilité (ENTREE_STOCK)
    tx = TransactionCaisse(
        boutique_id=boutique.id,
        session_id=entree_in.session_id,
        type_transaction="ENTREE_STOCK",
        montant=montant_total,
        motif=f"Réception stock ({len(produits_mis_a_jour)} réf.)",
        id_local_smartphone=entree_in.id_local_smartphone,
        synced=True,
    )
    if entree_in.date_entree is not None:
        tx.date_transaction = entree_in.date_entree
    db.add(tx)

    # Dette fournisseur si paiement différé
    if entree_in.fournisseur_id is not None and entree_in.mode_paiement == "CREDIT":
        fournisseur = (
            await db.execute(
                select(CompteTiers).where(CompteTiers.id == entree_in.fournisseur_id)
            )
        ).scalar_one_or_none()
        if fournisseur is not None:
            fournisseur.solde_du += montant_total

    await db.flush()

    return EntreeStockPushResult(
        id_local_smartphone=entree_in.id_local_smartphone,
        transaction_id=tx.id,
        deja_synchronisee=False,
        produits_mis_a_jour=produits_mis_a_jour,
    ), produits


async def push(
    db: AsyncSession, boutique: Boutique, payload: SyncPushRequest
) -> SyncPushResponse:
    # Vérification quota freemium — uniquement pour les nouvelles ventes
    # (les idempotentes ne comptent pas, on les détecte en avance)
    if payload.ventes:
        from app.services import abonnement_service  # import local pour éviter circulaire

        # Compter combien sont réellement nouvelles (non encore synchronisées)
        ids_locaux = [v.id_local_smartphone for v in payload.ventes]
        deja_sync = (
            await db.execute(
                select(Vente.id_local_smartphone).where(
                    Vente.id_local_smartphone.in_(ids_locaux)
                )
            )
        ).scalars().all()
        nb_nouvelles = len(payload.ventes) - len(deja_sync)

        if nb_nouvelles > 0:
            autorise, abo, ventes_mois = await abonnement_service.verifier_quota(
                db, boutique.id, nb_nouvelles
            )
            if not autorise:
                raise HTTPException(
                    status_code=status.HTTP_402_PAYMENT_REQUIRED,
                    detail={
                        "code": "QUOTA_DEPASSE",
                        "message": f"Quota mensuel atteint ({ventes_mois}/{abo.quota_ventes_mois} ventes). "
                                   f"Passez au plan PRO pour continuer.",
                        "ventes_utilisees": ventes_mois,
                        "quota": abo.quota_ventes_mois,
                        "plan": abo.plan,
                    },
                )

    response = SyncPushResponse()
    # Accumule les produits modifiés pour détecter les alertes stock
    produits_modifies: dict[uuid.UUID, Produit] = {}
    for vente_in in payload.ventes:
        result, produits_vente = await _process_vente(db, boutique, vente_in)
        response.ventes.append(result)
        produits_modifies.update(produits_vente)
    for depense_in in payload.depenses:
        response.depenses.append(await _process_depense(db, boutique, depense_in))
    for entree_in in payload.entrees_stock:
        result, produits_entree = await _process_entree_stock(db, boutique, entree_in)
        response.entrees_stock.append(result)
        produits_modifies.update(produits_entree)
    await db.commit()
    # Alertes stock : uniquement pour les produits dont le stock a baissé (ventes),
    # pas pour les entrées de stock (stock qui monte).
    entrees_produits = {
        pid for res in response.entrees_stock for pid in res.produits_mis_a_jour
    }
    for produit in produits_modifies.values():
        if produit.id in entrees_produits:
            continue  # stock en hausse : pas d'alerte
        if produit.stock_actuel <= produit.stock_alerte:
            response.alertes_stock.append(
                AlerteStockItem(
                    produit_id=produit.id,
                    nom=produit.nom,
                    stock_actuel=produit.stock_actuel,
                    stock_alerte=produit.stock_alerte,
                    en_rupture=produit.stock_actuel <= 0,
                )
            )
    return response
