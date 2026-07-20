import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/errors/app_exception.dart';
import '../../data/local/database.dart';
import '../../data/models/sync_model.dart';
import '../../data/remote/sync_api.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/boutiques/providers/boutique_provider.dart';

class SyncService {
  const SyncService(this._ref);
  final Ref _ref;

  /// Pousse toutes les données non-sync vers le backend.
  /// Retourne le nombre d'items synchronisés.
  Future<int> pushPending() async {
    final user = _ref.read(authStateProvider).value;
    final boutiqueId = await _ref.read(currentBoutiqueIdProvider.future);
    if (user == null || boutiqueId == null) return 0;

    // Vérifier connectivité
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return 0;

    final db = _ref.read(appDatabaseProvider);
    final syncApi = _ref.read(syncApiProvider);

    int synced = 0;

    try {
      // ── Ventes non sync ───────────────────────────────────────────────────
      final ventesPending = await db.getVentesNonSync(boutiqueId);
      if (ventesPending.isNotEmpty) {
        final ventesIn = <VenteIn>[];

        for (final vente in ventesPending) {
          final lignes = await db.getLignesByVente(vente.idLocal);
          ventesIn.add(VenteIn(
            idLocal: vente.idLocal,
            modePaiement: vente.modePaiement,
            sessionId: vente.sessionId,
            tierId: vente.tierId,
            dateVente: vente.dateVente,
            lignes: lignes
                .map((l) => LigneVenteIn(
                      produitId: l.produitId,
                      quantite: l.quantite,
                      prixVenduReel: l.prixVenduReel,
                      lotId: l.lotId,
                      lotNom: l.lotNom,
                    ))
                .toList(),
          ));
        }

        final resp = await syncApi.push(SyncPushRequest(
          boutiqueId: boutiqueId,
          ventes: ventesIn,
        ));

        for (final result in resp.ventes) {
          await db.marquerVenteSync(result.idLocal, result.venteId);
          synced++;
        }
      }

      // ── Mouvements de stock non sync ──────────────────────────────────────
      final mouvementsPending = await db.getMouvementsNonSync(boutiqueId);
      if (mouvementsPending.isNotEmpty) {
        final mouvementsIn = mouvementsPending
            .map((m) => MouvementStockIn(
                  idLocal: m.id,
                  produitId: m.produitId,
                  produitNom: m.produitNom,
                  typeMouvement: m.typeMouvement,
                  quantite: m.quantite,
                  motif: m.motif,
                  auteurNom: m.auteurNom,
                  dateMouvement: m.dateMouvement,
                ))
            .toList();

        final respMvt = await syncApi.push(SyncPushRequest(
          boutiqueId: boutiqueId,
          mouvementsStock: mouvementsIn,
        ));

        for (final result in respMvt.mouvementsStock) {
          await db.marquerMouvementSync(result.idLocal);
          synced++;
        }
      }

      // ── Dépenses non sync ─────────────────────────────────────────────────
      final depensesPending = await db.getDepensesNonSync(boutiqueId);
      if (depensesPending.isNotEmpty) {
        final depensesIn = depensesPending
            .map((d) => DepenseIn(
                  idLocal: d.idLocal,
                  montant: d.montant,
                  motif: d.motif,
                  sessionId: d.sessionId,
                  dateTransaction: d.dateTransaction,
                ))
            .toList();

        await syncApi.push(SyncPushRequest(
          boutiqueId: boutiqueId,
          depenses: depensesIn,
        ));

        for (final d in depensesPending) {
          await db.marquerDepenseSync(d.idLocal);
          synced++;
        }
      }
    } on AppException {
      // Silencieux — sera retenté au prochain appel
    }

    return synced;
  }

  /// Pull le catalogue (produits + catégories) depuis le backend.
  Future<void> pullCatalogue() async {
    final user = _ref.read(authStateProvider).value;
    final boutiqueId = await _ref.read(currentBoutiqueIdProvider.future);
    if (user == null || boutiqueId == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final db = _ref.read(appDatabaseProvider);
    final syncApi = _ref.read(syncApiProvider);

    try {
      final resp = await syncApi.pull(boutiqueId);

      await db.upsertAllProduits(resp.produits
          .map((p) => LocalProduitsCompanion(
                id: drift.Value(p.id),
                boutiqueId: drift.Value(boutiqueId),
                nom: drift.Value(p.nom),
                prixAchatMoyen: drift.Value(p.prixAchatMoyen),
                prixVenteSuggere: drift.Value(p.prixVenteSuggere),
                stockActuel: drift.Value(p.stockActuel),
                stockAlerte: drift.Value(p.stockAlerte),
                categorieId: drift.Value(p.categorieId),
              ))
          .toList());

      await db.upsertAllCategories(resp.categories
          .map((c) => LocalCategoriesCompanion(
                id: drift.Value(c.id),
                boutiqueId: drift.Value(boutiqueId),
                nom: drift.Value(c.nom),
              ))
          .toList());
    } on AppException {
      // Silencieux
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

/// Provider qui déclenche un pull + push au démarrage et écoute la connectivité.
final syncInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(syncServiceProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return;

  await service.pullCatalogue();
  await service.pushPending();

  // Écoute reconnexion réseau → re-sync automatique
  final subscription = Connectivity().onConnectivityChanged.listen((results) async {
    if (!results.contains(ConnectivityResult.none)) {
      await service.pushPending();
    }
  });
  ref.onDispose(subscription.cancel);
});
